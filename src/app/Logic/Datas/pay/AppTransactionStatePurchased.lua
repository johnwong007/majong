local AppTransactionStatePurchased = class("AppTransactionStatePurchased")

function AppTransactionStatePurchased:ctor()
	self.result = 0
end

function AppTransactionStatePurchased:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "number" then
		
		self.result = jsonTable+0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return AppTransactionStatePurchased