local BaseRoom = require("app.Logic.Room.BaseRoom")
require("app.GUI.ProfitNotification")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Tools.EStringTime")
require("app.Logic.newerGuide.NewerGuideControl")
require("app.Logic.Datas.TableData.PushMessage")
local MusicPlayer = require("app.Tools.MusicPlayer")

local TourneyRoom = class("TourneyRoom", function()
		return BaseRoom:new()
	end)

function TourneyRoom:create(seatNum)
	local tourneyRoom = TourneyRoom:new()
	tourneyRoom:initData(seatNum)
	return tourneyRoom
end

function TourneyRoom:ctor()
	BaseRoom.setChildRoom(self)

	self.m_totalPlayerCount      = 0
	self.m_userRanking      = 0
	self.m_matchId    = ""
	self.m_bonusName    = ""
	self.m_gainName    = ""
	self.m_curPlayer      = 0

	self.m_toTableId    = ""

	self.m_bCounting    = false
	self.m_bFirstHand = true

	self.m_matchInfo    = nil
	self.m_blindDSInfo = nil

	self.m_bInitBlindInfo    = false
	self.m_bFinalTableHint = false

	self.m_endRank      = 0
    
	--为区分现金场和锦标赛  不在牌桌中显示所以view传nil
	ProfitNotification:sharedInstance():registerCurrentView(nil, eProViewTourneyRoomView)
end

function TourneyRoom:showRoomInfo()

	self.m_pCallbackUI:showTourneyRoomInfo_Callback(self.m_matchId,self.m_bonusName,self.m_gainName,self.m_curPlayer,
		self.m_roomInfo.tableId,self.m_roomInfo.tableName, self.m_roomInfo.smallBlind, self.m_roomInfo.bigBlind, false)
end

function TourneyRoom:bankruptRequest()
	return
end

function TourneyRoom:sendChatMsg(content, chatType)

	self.tcpRequest:tableChat(self.m_roomInfo.tableId,content,0,chatType)
end

--退出锦标赛
function TourneyRoom:reqMyLeaveTable(isConfirm, leaveType)
	self.m_leaveRoomType = leaveType
	if(self.m_myselfSeatId >= 0 and isConfirm) then
	
		if(self.m_pCallbackUI) then
			self.m_pCallbackUI:showConfirmQuitTourneyRoom(self.m_roomInfo.tableId)--退出房间确认框
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

function TourneyRoom:dealTableInfoResp(dataModel)
	local data = dataModel
	BaseRoom.dealTableInfoResp(self, dataModel)
	DBHttpRequest:getTableInfo(handler(self,self.httpResponse),"TOURNEY", data.tableId, true)
end

function TourneyRoom:dealSitOutResp(dataModel)

	local data = dataModel
	local seat = self:getSeat(data.m_userId)
	if(not seat or not self.m_pCallbackUI)  then
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

--被淘汰出局
function TourneyRoom:dealOutCompetitionByEliminationResp(dataModel)
	local data = dataModel
	-- dump(self.m_matchInfo)
	if (self.m_matchInfo) then
	
		for i=1,#self.m_matchInfo.gainList do
		
			local info = self.m_matchInfo.gainList[i]
            local tmp=""
			if (data.userRanking >= info.startRank and data.userRanking <= info.endRank) then
				tmp=info.gainStr or ""
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
                    
				self.m_pCallbackUI:outCompetitionByElimination_Callback(self.m_roomInfo.tableId, data.userRanking, tmp, data.gainNum, self.m_matchInfo.matchName)
				return
			end
		end
	end
	self.m_pCallbackUI:outCompetitionByElimination_Callback(self.m_roomInfo.tableId, data.userRanking, "", data.gainNum, "本场锦标赛")
end

function TourneyRoom:dealHandStartResp(dataModel)
	if(not self.m_pCallbackUI)  then
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
    self.m_pCallbackUI:showStartNextHand(self.m_roomInfo.tableId,"",false)
	self.m_bFirstHand = false
end

function TourneyRoom:dealGetMatchInfo(content)
	local info = require("app.Logic.Datas.Lobby.MatchInfo"):new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
		self.m_matchInfo = info
		self.m_bonusName = self.m_matchInfo.bonusName
		self.m_gainName = self.m_matchInfo.gainName
		self.m_curPlayer = self.m_matchInfo.curUnum
		--DBHttpRequest:getBlindDSInfo(handler(self,self.httpResponse), info.blindType)
		self.m_totalPlayerCount = info.curUnum
		self.m_userRanking = info.currentInfo.userRanking
		self.m_pCallbackUI:setMatchInfo(self.m_roomInfo.tableId,self.m_matchId,self.m_bonusName,self.m_gainName,self.m_curPlayer,self.m_roomInfo.payType)
        
		
		MusicPlayer:getInstance():playGameStartSound()
		for i=1,#self.m_matchInfo.gainList do
		
			local info = self.m_matchInfo.gainList[i]
			if (info.endRank >= self.m_endRank) then
			
				self.m_endRank = info.endRank
			end
		end
        
        if info.startTime ~= "None" then
        	return
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

function TourneyRoom:dealGetBlindDSInfo(content)

	local info = require("app.Logic.Datas.Lobby.BlindDSInfo"):new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_blindDSInfo = info
		DBHttpRequest:getMatchDetail(handler(self,self.httpResponse),self.m_matchId, self.m_toTableId)
		return
	end
	self.m_blindDSInfo = nil
end

function TourneyRoom:dealHandFinishResp(dataModel)
	BaseRoom.dealHandFinishResp(self, dataModel)
	if (self.m_matchId ~= "") then
	
		DBHttpRequest:getMatchDetail(handler(self,self.httpResponse),self.m_matchId, self.m_roomInfo.tableId)
	end
	
end

--锦标赛排名信息
function TourneyRoom:dealGetMatchDetail(content)
	if (not self.m_pCallbackUI) then
		return
	end
	local info = require("app.Logic.Datas.Lobby.MatchDetail"):new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
		self.m_totalPlayerCount = info.playingNum
		if (info.userRanking > 0) then
		
			self.m_pCallbackUI:updateUserRanking_Callback(self.m_roomInfo.tableId, info.userRanking, info.playingNum)
		end
        
		--读秒时未显示值初始化一次
		if (not self.m_bInitBlindInfo) then
		
			if (info.bigBlind >= 0 and info.smallBlind >= 0) then
			
				self.m_pCallbackUI:updateBlind_Callback(self.m_roomInfo.tableId, info.bigBlind, info.smallBlind, eBlindCurrent)
			end
			if (info.ante >= 0) then
			
				self.m_pCallbackUI:updateAnte_Callback(self.m_roomInfo.tableId, info.ante)
			end
			self.m_bInitBlindInfo = true
		end
        if info.startTime ~= "None" then
        	return
        end
		--final table hint
		if(not self.m_bFinalTableHint) then
		
			local isFinalTable = false
			if TRUNK_VERSION == DEBAO_TRUNK then
				isFinalTable = (info.curTnum == 1)
			else
				isFinalTable = (info.playingNum <= info.seatNum)
			end

			if(isFinalTable and self.m_pCallbackUI) then
			
				self.m_pCallbackUI:tourneyFinalTable(self.m_roomInfo.tableId)
				self.m_bFinalTableHint = true
			end
		end
        
	end
	info = nil
end

function TourneyRoom:dealGetTableInfo(content)
	local info = require("app.Logic.Datas.Lobby.TourneyTableInfo"):new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
		self.m_matchId = info.matchId
		DBHttpRequest:getMatchInfo(handler(self,self.httpResponse),self.m_matchId, self.m_roomInfo.tableId)
		DBHttpRequest:getMatchDetail(handler(self,self.httpResponse),self.m_matchId, self.m_roomInfo.tableId)
	end
end

return TourneyRoom
