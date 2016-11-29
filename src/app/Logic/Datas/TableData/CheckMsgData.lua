local CheckMsgData = class("CheckMsgData")

function CheckMsgData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_seatNo = 0
	self.m_userId = ""
	self.m_totalPot = 0.0
end


function CheckMsgData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = tonumber(jsonTable[CODE]) or 0
		self.m_tableId = tostring(jsonTable[TABLE_ID]) or ""
		self.m_seatNo = tonumber(jsonTable[SEAT_NO]) or 0
		self.m_userId = tostring(jsonTable[USER_ID]) or ""
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

return CheckMsgData