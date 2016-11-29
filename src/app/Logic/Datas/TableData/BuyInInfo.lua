local BuyInInfo = class("BuyInInfo")

function BuyInInfo:ctor()
	self.code = 0
	self.infoBuyIn = 0
end


function BuyInInfo:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "number" or type(jsonTable) == "string" then
		self.code = jsonTable or 0
		self.infoBuyIn = jsonTable or 0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return BuyInInfo