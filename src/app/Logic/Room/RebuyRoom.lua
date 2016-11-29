local TourneyRoom = require("app.Logic.Room.TourneyRoom")
local BaseRoom = require("app.Logic.Room.BaseRoom")
local myInfo = require("app.Model.Login.MyInfo")

local RebuyRoom = class("RebuyRoom", function()
		return TourneyRoom:new()
	end)

function RebuyRoom:create(seatNum)
	local rebuyRoom = RebuyRoom:new()
	rebuyRoom:initData(seatNum)
	return rebuyRoom
end

function RebuyRoom:ctor()

	self.m_legalRebuyBlindLevel = 0	--合法盲足级别
	self.m_currentBlindLevel = 0	--当前盲足级别
	self.m_rebuyPay = 0.0			--成功rebuy的话费
	self.m_rebuyAdd = 0.0				--成功rebuy增加的筹码
	self.m_rebuyLimit = 0			--rebuy的次数
	self.m_rebuyTimes = 0			--已rebuy的次数
	self.m_playerInitChips = 0.0		--玩家初始筹码
    
	self.m_passiveRebuyUsers = {}	--被动rebuy玩家
end

function RebuyRoom:showRoomInfo()

	self.m_pCallbackUI:showTourneyRoomInfo_Callback(self.m_matchId,self.m_bonusName,self.m_gainName,self.m_curPlayer,self.m_roomInfo.tableId,self.m_roomInfo.tableName, self.m_roomInfo.smallBlind, self.m_roomInfo.bigBlind, true)
end

function RebuyRoom:reqMyRebuyDiaglog()

	local bEnoughMoney = myInfo:getTotalChips() >= self.m_rebuyPay
	self.m_pCallbackUI:showRebuyDialog_Callback(self.m_roomInfo.payType,self.m_roomInfo.tableId, true, self.m_rebuyPay, self.m_rebuyAdd, bEnoughMoney, -1)
end

function RebuyRoom:reqMyAddOnDiaglog(time)

    local bEnoughMoney = myInfo:getTotalChips() >= self.m_rebuyPay
    self.m_pCallbackUI:showAddOnDialog_Callback(self.m_roomInfo.payType,self.m_roomInfo.tableId, true, self.m_rebuyPay, self.m_rebuyAdd, bEnoughMoney, time)
end

function RebuyRoom:reqAddOn()
	DBHttpRequest:addOn(handler(self, self.httpResponse),self.m_matchId , self.m_roomInfo.tableId)
end

function RebuyRoom:reqRebuy(type)

	self.tcpRequest:rebuy(myInfo.data.userId, myInfo.data.userName, self.m_roomInfo.tableId, type)
end
function RebuyRoom:dealRebuyResp(dataModel)

	local info = dataModel
	if (info.respCode == 1 or info.respCode == 10000) then
	
		if (info.userId == myInfo.data.userId) then
		
			if (self.m_rebuyTimes + 1 > self.m_rebuyLimit or self:getSeat(self.m_myselfSeatId).seatChips + self.m_rebuyAdd > self.m_playerInitChips ) then
			
				self.m_pCallbackUI:enabledRebuyButton_Callback(self.m_roomInfo.tableId ,false)
			end
			self:setMyTotalMoney(self:getMyTotalMoney() - self.m_rebuyPay)
			if (self:getSeat(self.m_myselfSeatId).seatChips <= 0) then
			
				self.m_pCallbackUI:showRebuyResult_Callback(self.m_roomInfo.tableId, "恭喜您复活成功！成功买入"..self.m_rebuyAdd.."筹码！", true)
			else
			
				self.m_pCallbackUI:showRebuyResult_Callback(self.m_roomInfo.tableId, "恭喜您成功买入"..self.m_rebuyAdd.."筹码！请再接再厉", true)
			end
			
		else
		
			local seat = self:getSeat(info.userId)
			if (seat and seat.seatChips <= 0) then
			
				self.m_pCallbackUI:showInfoHint_Callback(self.m_roomInfo.tableId,
                                                     seat.userName.."已复活成功")
			end
		end
	elseif(info.userId == myInfo.data.userId) then
	
		local errorInfo
		if (info.respCode == -11048) then
			errorInfo = Lang_REBUY_ERROR_MORETHENINIT
		elseif (info.respCode == -11049) then
			errorInfo = Lang_REBUY_ERROR_BLINDLEVEL
		elseif(info.respCode == -11051) then
			errorInfo = Lang_REBUY_ERROR_MAXCOUNT
		elseif(info.respCode == -13017) then
			errorInfo = Lang_REBUY_ERROR_FREQUENTLY
		elseif (info.respCode == -13016) then
			errorInfo = Lang_REBUY_ERROR_QIANQUAN
		else
		
			errorInfo = Lang_REBUY_ERROR_OTHER
			errorInfo = errorInfo..info.respCode
		end
		self.m_pCallbackUI:showRebuyResult_Callback(self.m_roomInfo.tableId, errorInfo, false)
	end
end

function RebuyRoom:dealTableInfoResp(dataModel)

	TourneyRoom.dealTableInfoResp(self, dataModel)
	local tableInfo = dataModel
	self.m_legalRebuyBlindLevel = tableInfo.currentTableInfo.legalBlindLevel
	self.m_currentBlindLevel = tableInfo.currentTableInfo.blindLevel
	self.m_rebuyPay = tableInfo.currentTableInfo.rebuyPayMoney
	self.m_rebuyAdd = tableInfo.currentTableInfo.rebuyValue
	self.m_rebuyLimit = tableInfo.currentTableInfo.rebuyLimitCount
	self.m_rebuyTimes = tableInfo.playerMyInfo.rebuyCount
	self.m_playerInitChips = tableInfo.currentTableInfo.tableInitChips--playerInitChips
	
	-- dump(self.m_myselfSeatId)

	local bEnableRebuy = self.m_legalRebuyBlindLevel > self.m_currentBlindLevel and
    	self.m_rebuyTimes < self.m_rebuyLimit and
    	self:getSeat(self.m_myselfSeatId).seatChips <= self.m_playerInitChips and
    	self.m_endRank < self.m_totalPlayerCount
	self.m_pCallbackUI:enabledRebuyButton_Callback(self.m_roomInfo.tableId, bEnableRebuy)
end

function RebuyRoom:passiveRebuyUserExisted(userId)

	for i=1,#self.m_passiveRebuyUsers do
	
		if (self.m_passiveRebuyUsers[i] == userId) then
		
			return i
		end
	end
	return -1
end

function RebuyRoom:dealPassiveRebuyReq(dataModel)

	local req = dataModel
	local userList = ""
	for i=1,#req.m_passiveRebuyUsers do
	
		if (req.m_passiveRebuyUsers[i] == myInfo.data.userId) then
		
			local bEnoughMoney = myInfo:getTotalChips() >= self.m_rebuyPay
			--此处time减2避免极端情况用户买入但已被淘汰
			self.m_pCallbackUI:showRebuyDialog_Callback(self.m_roomInfo.payType,self.m_roomInfo.tableId, false, self.m_rebuyPay, self.m_rebuyAdd, bEnoughMoney, req.m_passiveRebuyWaitTime - 2)
		else
			if i~=1 then
				userList =  userList..","
			end
			local seat = self:getSeat(req.m_passiveRebuyUsers[i])
			if (seat) then
			
				if (self:passiveRebuyUserExisted(req.m_passiveRebuyUsers[i]) < 0) then
					self.m_passiveRebuyUsers[#self.m_passiveRebuyUsers+1] = req.m_passiveRebuyUsers[i]
				end
				userList = userList..seat.userName
			end
		end
	end
	if (userList ~= "") then
		local infoTip = "玩家"..userList.."正在决定是否复活继续比赛"
		self.m_pCallbackUI:showInfoHint_Callback(self.m_roomInfo.tableId, infoTip)
	end
end

function RebuyRoom:dealHandStartResp(dataModel)

	TourneyRoom.dealHandStartResp(self, dataModel)
	local tableInfo = dataModel
	self.m_rebuyTimes = tableInfo.playerMyInfo.rebuyCount
	self.m_currentBlindLevel = tableInfo.currentTableInfo.blindLevel
    self.m_pCallbackUI:showStartNextHand(self.m_roomInfo.tableId,"",false)

	local bEnableRebuy = self.m_legalRebuyBlindLevel > self.m_currentBlindLevel and
    	self.m_rebuyTimes < self.m_rebuyLimit and
    	self:getSeat(self.m_myselfSeatId).seatChips <= self.m_playerInitChips and
    	self.m_endRank < self.m_totalPlayerCount

    
	self.m_pCallbackUI:enabledRebuyButton_Callback(self.m_roomInfo.tableId, bEnableRebuy)
    
	local userList = ""
	for i=1,#tableInfo.playerList do
	
		local eachPlayer = tableInfo.playerList[i]
		if (eachPlayer.userChips > 0) then
		
			for j=#self.m_passiveRebuyUsers,1,-1 do
			
				if (self.m_passiveRebuyUsers[j] == eachPlayer.userId) then
					
					userList = userList..eachPlayer.userName
					if j~=1 then
						userList = userList..","
					end
					table.remove(self.m_passiveRebuyUsers, j)
				end
			end
		end
	end
	if (userList ~= "") then
		local infoTip = "玩家" .. userList .. "已复活成功"
		self.m_pCallbackUI:showInfoHint_Callback(self.m_roomInfo.tableId, infoTip)
	end
end

function RebuyRoom:dealSitOutResp(dataModel)

	TourneyRoom.dealSitOutResp(self, dataModel)
	local data = dataModel
	local seat = self:getSeat(data.m_userId)
	if (not seat) then
		return
	end
	local isMyself = self:isMyseat(seat.userId)
	if(not isMyself) then
	
		local index = self:passiveRebuyUserExisted(data.m_userId)
		if (index >=1) then
			table.remove(self.m_passiveRebuyUsers, index)
		end
	end
end

function RebuyRoom:dealPrizeMsgResp(dataModel)

	BaseRoom.dealPrizeMsgResp(self, dataModel)
    
	local bEnableRebuy = self.m_legalRebuyBlindLevel > self.m_currentBlindLevel and
    	self.m_rebuyTimes < self.m_rebuyLimit and
    	self:getSeat(self.m_myselfSeatId).seatChips <= self.m_playerInitChips and
    	self.m_endRank < self.m_totalPlayerCount
	self.m_pCallbackUI:enabledRebuyButton_Callback(self.m_roomInfo.tableId, bEnableRebuy)
end

return RebuyRoom