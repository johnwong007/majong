local RewardRespInfo = class("RewardRespInfo")

function RewardRespInfo:ctor()
	self.transMoney = ""
	self.tips = ""
	self.orderId = ""
	self.description = ""
	self.gainType = ""
	self.tradeType = ""
end

function RewardRespInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.transMoney = jsonTable[TRANS_MONEY]
		self.tips = jsonTable[TIPS]
		self.orderId = jsonTable[ORDER_ID]
		self.description = jsonTable[DSCRIPTION]
		self.gainType = jsonTable[GAIN_TYPE]
		self.tradeType = jsonTable[TRADE_TYPE]
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RewardRespInfo