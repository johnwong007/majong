local AccountInfo = class("AccountInfo")

function AccountInfo:ctor()
	self.code = ""
	self.debaoBalance = ""
	self.goldBalance = ""
	self.silverBalance = ""
	self.pointBalance = ""
	self.diamondBalance = ""
	self.cashChips = {}
end

function AccountInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code = ""
		self.debaoBalance = jsonTable[DEBAO_BALANCE]
		self.goldBalance = jsonTable[GOLD_BALANCE]
		self.silverBalance = self.goldBalance
		self.pointBalance = jsonTable[POINT_BALANCE]
		self.diamondBalance = jsonTable[DIAMOND_BALANCE]
		self.cashChips = jsonTable[CASH_CHIPS]
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return AccountInfo