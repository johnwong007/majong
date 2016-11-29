local TableButtonMSGData = class("TableButtonMSGData")

function TableButtonMSGData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_buttonNo = 0
	self.m_bblindNo = 0
	self.m_sblindNo = 0
end


function TableButtonMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_buttonNo = jsonTable[BUTTON_NO] or 0
		self.m_bblindNo = jsonTable[BBLIND_NO] or 0
		self.m_sblindNo = jsonTable[SBLIND_NO] or 0
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableButtonMSGData