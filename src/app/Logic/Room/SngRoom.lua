local BaseRoom = require("app.Logic.Room.BaseRoom")
require("app.GUI.ProfitNotification")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Tools.EStringTime")
require("app.Logic.newerGuide.NewerGuideControl")
require("app.Logic.Datas.TableData.PushMessage")

local SngRoom = class("SngRoom", function()
		return BaseRoom:new()
	end)

function SngRoom:create(seatNum)
	local sngRoom = SngRoom:new()
	sngRoom:initData(seatNum)
	return sngRoom
end

function SngRoom:ctor()
	BaseRoom.setChildRoom(self)

	self.m_totalPlayerCount = 0
	self.m_userRanking = 0
	self.m_toTableId = ""
	self.m_bCounting = false
	self.m_bFirstHand = true
	self.m_matchInfo = nil
	self.m_blindDSInfo = nil
    
	self.m_bInitBlindInfo = false
	self.m_bFinalTableHint = false
    
	self.m_endRank = 0
	--为区分现金场和锦标赛  不在牌桌中显示所以view传nil
	ProfitNotification:sharedInstance():registerCurrentView(nil, eProViewCashRoomView)

	self.data = 1000
end

function SngRoom:onEnter()
end

function SngRoom:getTableInfo()
    DBHttpRequest:getTableInfo(function(event) if self.httpResponse then self:httpResponse(event) end
           end,"SITANDGO",self.m_roomInfo.tableId, true) 
end

function SngRoom:showRoomInfo()
	self.m_pCallbackUI:showSngRoomInfo_Callback(self.m_matchId,self.m_bonusName,self.m_gainName,self.m_curPlayer,self.m_roomInfo.tableId,self.m_roomInfo.tableName, self.m_roomInfo.smallBlind, self.m_roomInfo.bigBlind, false)
    --    倒计时,因为目前服务器不传时间过来,写死
    -- self.m_pCallbackUI:showInfoHint_Callback(self.m_roomInfo.tableId, "SNG赛即将开始")
    -- self.m_pCallbackUI:showCountDown_Callback(self.m_roomInfo.tableId, true, 25, 0, 1)
    self.m_bCounting = true
end
function SngRoom:bankruptRequest()

	return
end

function SngRoom:sendChatMsg(content, chatType)

	self.tcpRequest:tableChat(self.m_roomInfo.tableId,content,0,chatType)
end

--退出锦标赛
function SngRoom:reqMyLeaveTable(isConfirm, leaveType)

	self.m_leaveRoomType = leaveType
	if(self.m_myselfSeatId >= 0 and isConfirm) then
	
		if(self.m_pCallbackUI) then
			self.m_pCallbackUI:showConfirmQuitRoom(self.m_roomInfo.tableId)--退出房间确认框
		end
	elseif (leaveType == LEVAE_ROOM_TO_TOURNEYROOM) then
	
		--另一场锦标赛开始  先退出当前的赛事
		if(self.m_pCallbackUI) then
			self.m_pCallbackUI:showRoomLoadingView(true)--显示退出房间loading
		end
		self.tcpRequest:quitTourney(self.m_roomInfo.tableId,myInfo.data.userId)
	else
	
		if(self.m_pCallbackUI) then
			self.m_pCallbackUI:showRoomLoadingView(true)--显示退出房间loading
		end
		if (leaveType == LEVAE_ROOM_TO_QUITTOURNEY) then
		
			if(self.m_myselfSeatId>=0) then
			
				self.tcpRequest:quitTourney(self.m_roomInfo.tableId,myInfo.data.userId)
			end
		else
		
			self.m_pCallbackUI:leaveTable_Callback(true,self.m_roomInfo.tableId,leaveType)
		end
	end
end

function SngRoom:dealTableInfoResp(dataModel)

	local data = dataModel
	BaseRoom.dealTableInfoResp(self, dataModel)
	self:getTableInfo()
end

function SngRoom:dealSitOutResp(dataModel)

	local data = dataModel
	local seat = self:getSeat(data.m_userId)
	if not seat or not self.m_pCallbackUI then 
		return
	end
	local isMyself = self:isMyseat(seat.userId)
	if(isMyself) then
	
		self.m_myselfSeatId = -1
		self.m_myBestCardType = -1
		if(self.m_isQuitRoom) then--是否退出房间
			self:reqMyLeaveTable(false,self.m_leaveRoomType)
        end
		--新手引导
		self.m_pCallbackUI:showNewerGuideActionHint(self.m_roomInfo.tableId,kNGCNone,kOBOHNone)
	end
    
	self.m_pCallbackUI:playerSitOut_Callback(isMyself,self.m_myselfSeatId>=0,self.m_roomInfo.tableId,seat.seatId)
    
	seat:standup()
end

--牌局结束
function SngRoom:dealOutCompetitionByEliminationResp(dataModel)
	local data = dataModel
	if self.m_matchInfo then
	
		for i=1,#self.m_matchInfo.gainList do
		
			local info = self.m_matchInfo.gainList[i]
			if data.userRanking >= info.startRank and data.userRanking <= info.endRank then
				local tmp=info.gainStr or ""
				if TRUNK_VERSION == DEBAO_TRUNK then
					if string.find(info.gainStr, "金币")~=nil then

                        --刷新账户金币
                        self:setMyTotalMoney(self:getMyTotalMoney() + info.gainNum)
                        tmp=info.gainStr
                    end
				else
                    if string.find(info.gainStr, "筹码")~=nil then

                        --刷新账户金币
                        self:setMyTotalMoney(self:getMyTotalMoney() + info.gainNum)
                        tmp=info.gainStr
                    end
				end

				self.m_pCallbackUI:outCompetitionByElimination_Callback(self.m_roomInfo.tableId, data.userRanking, tmp, data.matchPoint, data.matchName)
				return
			end
		end
	end
	self.m_pCallbackUI:outCompetitionByElimination_Callback(self.m_roomInfo.tableId, data.userRanking, "", data.matchPoint, data.matchName)
end
function SngRoom:dealHandStartResp(dataModel)

	if not self.m_pCallbackUI then
		return
	end
	BaseRoom.dealHandStartResp(self, dataModel)
	local tableInfo = dataModel
	if (tableInfo.currentTableInfo.bigBlind >= 0 and tableInfo.currentTableInfo.smallBlind >= 0) then
	
		self.m_pCallbackUI:updateBlind_Callback(self.m_roomInfo.tableId, tableInfo.currentTableInfo.bigBlind, tableInfo.currentTableInfo.smallBlind, eBlindCurrent)
	end
    
	if (tableInfo.currentTableInfo.ante >= 0) then
	
		self.m_pCallbackUI:updateAnte_Callback(self.m_roomInfo.tableId, tableInfo.currentTableInfo.ante)
	end
	self.m_bInitBlindInfo = true
	if (self.m_bCounting and self.m_bFirstHand) then
	
		self.m_pCallbackUI:showCountDown_Callback(self.m_roomInfo.tableId, false, 0, 0, 0)
	end
	self.m_bFirstHand = false
end


function SngRoom:dealGetMatchInfo(content)

    local info = require("app.Logic.Datas.Lobby.MatchInfo"):new()
    if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_matchInfo = info
		self.m_bonusName = self.m_matchInfo.bonusName
		self.m_gainName = self.m_matchInfo.gainName
		self.m_curPlayer = self.m_matchInfo.curUnum
		
		self.m_totalPlayerCount = info.curUnum
		self.m_userRanking = info.currentInfo.userRanking
		self.m_pCallbackUI:setMatchInfo(self.m_roomInfo.tableId,self.m_matchId,self.m_bonusName,self.m_gainName,self.m_curPlayer,self.m_roomInfo.payType)
        
		
		for i=1,#self.m_matchInfo.gainList do
		
			local info = self.m_matchInfo.gainList[i]
			if (info.endRank >= self.m_endRank) then
			
				self.m_endRank = info.endRank
			end
		end
        
		local timeSpan = info.leftTime
		if timeSpan>25 then
			timeSpan = 25
		end
		if (timeSpan > 0) and not self.m_isPrivateRoom then
		
			self.m_pCallbackUI:showGameWaitPrompt_Callback(self.m_roomInfo.tableId)
			self.m_pCallbackUI:showCountDown_Callback(self.m_roomInfo.tableId, true, timeSpan, 0, 1)
			self.m_bCounting = true
		end
		return
	end
	info = nil
end
function SngRoom:dealGetBlindDSInfo(content)

	local info = require("app.Logic.Datas.Lobby.BlindDSInfo"):new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
		self.m_blindDSInfo = info
		DBHttpRequest:getMatchDetail(function(event) if self.httpResponse then self:httpResponse(event) end
            end,self.m_matchId,self.m_roomInfo.tableId) 
		return
	end
	self.m_blindDSInfo = nil
end
function SngRoom:dealHandFinishResp(dataModel)
	BaseRoom.dealHandFinishResp(self, dataModel)
	if self.m_matchId then
		DBHttpRequest:getMatchDetail(function(event) if self.httpResponse then self:httpResponse(event) end
            end,self.m_matchId,self.m_roomInfo.tableId) 
	end
end

--锦标赛排名信息
function SngRoom:dealGetMatchDetail(content)

	if not self.m_pCallbackUI then
		return
	end
	local info = require("app.Logic.Datas.Lobby.MatchDetail"):new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_totalPlayerCount = info.playingNum
		if (info.userRanking > 0) then
		
			self.m_pCallbackUI:updateUserRanking_Callback(self.m_roomInfo.tableId, info.userRanking, info.playingNum)
		end
        
		--读秒时未显示值初始化一次
		if not self.m_bInitBlindInfo then
		
			if (info.bigBlind >= 0 and info.smallBlind >= 0) then
			
				self.m_pCallbackUI:updateBlind_Callback(self.m_roomInfo.tableId, info.bigBlind, info.smallBlind, eBlindCurrent)
			end
			if (info.ante >= 0) then
			
				self.m_pCallbackUI:updateAnte_Callback(self.m_roomInfo.tableId, info.ante)
			end
			self.m_bInitBlindInfo = true
		end
        
		--final table hint
		if not self.m_bFinalTableHint then
		
			local isFinalTable = false
			if TRUNK_VERSION == DEBAO_TRUNK then
				isFinalTable = (info.curTnum == 1)
			else
				isFinalTable = (info.playingNum <= info.seatNum)
			end
			if isFinalTable and self.m_pCallbackUI then
				--[[SNG关闭决赛桌提示]]
				-- self.m_pCallbackUI:tourneyFinalTable(self.m_roomInfo.tableId)
				self.m_bFinalTableHint = true
			end
		end
        
		
	end
	info = nil
end

function SngRoom:dealGetTableInfo(content)
	local info = require("app.Logic.Datas.Lobby.TourneyTableInfo"):new()
	if info:parseJson(content) == BIZ_PARS_JSON_SUCCESS then
		self.m_matchId = info.matchId
		-- dump(self.m_matchId)
    	DBHttpRequest:getMatchInfo(function(event) if self.httpResponse then self:httpResponse(event) end
            end,self.m_matchId,self.m_roomInfo.tableId) 
    	DBHttpRequest:getMatchDetail(function(event) if self.httpResponse then self:httpResponse(event) end
            end,self.m_matchId,self.m_roomInfo.tableId) 
	end
end

-- function SngRoom:httpResponse(event)
-- 	BaseRoom.httpResponse(self, event)
-- end

return SngRoom