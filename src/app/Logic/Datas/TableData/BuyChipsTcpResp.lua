--[[tcp 买入和补充筹码买入返回]]
local BuyChipsTcpResp = class("BuyChipsTcpResp")

function BuyChipsTcpResp:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_userId = ""
	self.m_seatNo = 0
	self.m_buyChips = 0.0
	self.m_userChips = 0.0
	self.m_isRebuy = false
end


function BuyChipsTcpResp:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_userId = jsonTable[USER_ID] or ""
		self.m_seatNo = jsonTable[SEAT_NO] or 0
		self.m_buyChips = jsonTable[BUY_CHIPS] or 0.0
		self.m_userChips = jsonTable[USER_CHIPS] or 0.0

		self.m_isRebuy = (jsonTable[IS_RE_BUY] or 0)==1
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return BuyChipsTcpResp