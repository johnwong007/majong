local RebuyInfo = class("RebuyInfo")

function RebuyInfo:ctor()
	self.respCode = 0
	self.tableId = ""
	self.userId = ""
end


function RebuyInfo:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "number" then
		self.respCode = jsonTable or 0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end

	if type(jsonTable) == "table" then
		self.respCode = jsonTable[CODE] or 0
		self.tableId = jsonTable[TABLE_ID] or ""
		self.userId = jsonTable[USER_ID] or ""
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RebuyInfo