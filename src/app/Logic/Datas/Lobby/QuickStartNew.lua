local QuickStartNew = class("QuickStartNew")

function QuickStartNew:ctor()
	self.payType = ""
	self.bigBlind = ""
	self.money = ""
	self.gameAddr = ""
end

function QuickStartNew:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code = ""
		self.payType = jsonTable[PAY_TYPE]
		self.bigBlind = jsonTable[BIG_BLIND]
		self.money = jsonTable[MONEY_BALANCE]
		self.gameAddr = jsonTable[GAME_ADDR]
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "number" then
		self.code = tonumber(jsonTable)
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return QuickStartNew