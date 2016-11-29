local DebaoCoin = class("DebaoCoin")

function DebaoCoin:ctor()
	self.debaoCoin = 0
end

function DebaoCoin:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "number" then
		self.debaoCoin = jsonTable
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end


return DebaoCoin