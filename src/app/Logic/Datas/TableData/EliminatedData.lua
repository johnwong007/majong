local EliminatedData = class("EliminatedData")

function EliminatedData:ctor()
	self.userRanking = 0
	self.tableId = ""
	self.matchName = ""
	self.payType = ""
	self.payNum = 0.0
	self.gainType = ""
	self.gainNum = 0.0
	self.goodsId = 0
	self.matchPoint = 0
end


function EliminatedData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.tableId = jsonTable[TABLE_ID] or ""
		self.userRanking = jsonTable[USER_RANKING] or 0
		self.matchName = jsonTable[MATCH_NAME] or ""
		self.payType = jsonTable[PAY_TYPE] or ""
		self.payNum = jsonTable[PAY_NUM] or 0.0
		self.gainType = jsonTable[GAIN_TYPE] or ""
		self.gainNum = jsonTable[GAIN_NUM] or 0.0
		self.goodsId = jsonTable[GOODS_ID] or 0
		self.matchPoint = jsonTable[MATCH_POINT] or 0
		
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return EliminatedData