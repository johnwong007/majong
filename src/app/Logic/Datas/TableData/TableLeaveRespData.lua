local TableLeaveRespData = class("TableLeaveRespData")

function TableLeaveRespData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_playerId = ""
	self.m_userName = ""
	self.m_userId = ""
end


function TableLeaveRespData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_userId = jsonTable[USER_ID] or ""
		self.userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		self.m_playerId = jsonTable[RUSH_PLAYER_ID]
		
		if self.m_playerId and string.len(self.m_playerId)>1 then
			self.m_tableId = self.m_playerId
		end

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableLeaveRespData