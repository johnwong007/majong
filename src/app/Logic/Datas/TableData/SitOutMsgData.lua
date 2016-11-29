local SitOutMsgData = class("SitOutMsgData")

function SitOutMsgData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_sitNo = 0
	self.m_userId = ""
	self.m_userName = ""
end


function SitOutMsgData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		if jsonTable[SEAT_NO] then
			self.m_sitNo = tonumber(jsonTable[SEAT_NO]) or 0
		end
		self.m_userId = jsonTable[USER_ID] or ""
		self.m_userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return SitOutMsgData