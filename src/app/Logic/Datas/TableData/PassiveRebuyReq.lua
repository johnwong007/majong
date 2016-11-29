local PassiveRebuyReq = class("PassiveRebuyReq")

function PassiveRebuyReq:ctor()
	self.m_tableId = ""
	self.m_code = 0
	self.m_rebuyPayMoney = 0.0
	self.m_rebuyValue = 0.0
	self.m_passiveRebuyUsers = {}
	self.m_passiveRebuyWaitTime = 0
end


function PassiveRebuyReq:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_passiveRebuyWaitTime = jsonTable[PASSIVE_REBUY_WAITTIME] or 0
		self.m_rebuyPayMoney = jsonTable[REBUY_PAY_MONEY] or 0.0
		self.m_rebuyValue = jsonTable[REBUY_VALUE] or 0.0
	
		
		self.m_passiveRebuyUsers = jsonTable[PASSIVE_REBUY_USER] 
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return PassiveRebuyReq