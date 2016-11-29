local BalanceChangeMsg = class("BalanceChangeMsg")

function BalanceChangeMsg:ctor()
	self.userId = ""
	self.tableId = ""
	self.payType = ""
	self.payNum = 0.0
end


function BalanceChangeMsg:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.userId = jsonTable[USER_ID] or ""
		self.tableId = jsonTable[TABLE_ID] or ""
		self.payType = jsonTable[PAY_TYPE] or ""
		self.payNum = jsonTable[PAY_NUM] or 0.0
		
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return BalanceChangeMsg