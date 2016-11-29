local HandsByHandsData = class("HandsByHandsData")

function HandsByHandsData:ctor()
 	self.tableId = ""
 	--[[rebuy标识符,在Handsbyhands数据中用来判断是否handsbyhands]]
    self.isRebuy = ""
end



function HandsByHandsData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.tableId = jsonTable[TABLE_ID] or ""
		self.isRebuy = jsonTable[IS_RE_BUY] or ""
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return HandsByHandsData