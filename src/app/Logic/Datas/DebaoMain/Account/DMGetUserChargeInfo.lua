local DMGetUserChargeInfo = class("DMGetUserChargeInfo")

function DMGetUserChargeInfo:ctor()
	self.times = 0
	self.transMoney = 0.0
	self.percent = ""
end

function DMGetUserChargeInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.times = jsonTable[TIMES]
		self.transMoney = jsonTable[TRANS_MONEY]
		self.percent = jsonTable[PAYEVENT]
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return DMGetUserChargeInfo