local RushForceLeaveData = class("RushForceLeaveData")

function RushForceLeaveData:ctor()
	self.m_code = 0
	self.m_playerId = ""
	self.m_tableId = ""
	self.m_userId = ""
	self.payType = ""
	self.m_seatNum = 0
	self.m_bPlaying = false
	self.m_handChips = 0.0
	self.m_userChips = 0.0
	self.m_bigBlind = 0.0
	self.m_totalBuyChips = 0.0
	self.m_profitChip = 0.0
end


function RushForceLeaveData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_playerId = jsonTable[RUSH_PLAYER_ID] or ""
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_seatNum = jsonTable[SEAT_NUM] or 0
		self.m_userId = jsonTable[USER_ID] or ""
		self.m_userChips = jsonTable[USER_CHIPS] or 0.0
		self.m_handChips = jsonTable[HAND_CHIPS] or 0.0
		self.m_bigBlind = jsonTable[BIG_BLIND] or 0.0
		self.payType = jsonTable[PAY_TYPE] or ""
		self.m_bPlaying = jsonTable[IS_PLAYING] or false
		self.m_totalBuyChips = jsonTable[TOTAL_BUY_CHIPS] or 0.0
		self.m_profitChip = jsonTable[PROFIT_MONEY] or 0.0
		
		if jsonTable[RUSH_PLAYER_ID] then
			self.m_playerId = jsonTable[RUSH_PLAYER_ID]..""
		end
		if self.m_playerId and string.len(self.m_playerId)>1 then
			self.m_tableId = self.m_playerId
		end
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RushForceLeaveData