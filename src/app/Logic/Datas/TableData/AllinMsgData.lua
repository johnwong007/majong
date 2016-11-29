local AllinMsgData = class("AllinMsgData")

function AllinMsgData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_seatNo = 0
	self.m_userId = ""
	self.m_userChips = 0.0
	self.m_betChips = 0.0
	self.m_totalPot = 0.0
end


function AllinMsgData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = tonumber(jsonTable[CODE]) or 0
		self.m_tableId = tostring(jsonTable[TABLE_ID]) or ""
		self.m_seatNo = tonumber(jsonTable[SEAT_NO]) or 0
		self.m_userId = tostring(jsonTable[USER_ID]) or ""
		self.m_userChips = tonumber(jsonTable[USER_CHIPS]) or 0
		self.m_betChips = tonumber(jsonTable[BET_CHIPS]) or 0
		self.m_totalPot = tonumber(jsonTable[TOTAL_POT]) or 0
		
		if jsonTable[RUSH_PLAYER_ID] then
			self.m_rushPlayerId = tostring(jsonTable[RUSH_PLAYER_ID])
		end
		if self.m_rushPlayerId and string.len(self.m_rushPlayerId)>1 then
			self.m_tableId = self.m_rushPlayerId
		end
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return AllinMsgData