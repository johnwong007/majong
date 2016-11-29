local TableGuide = class("TableGuide")

function TableGuide:ctor()
	self.matchId = ""
	self.matchName = ""
	self.fromTableId = ""
	self.tableId = ""
	self.tableName = ""
end


function TableGuide:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.matchId = jsonTable[MATCH_ID] or ""
		self.matchName = jsonTable[MATCH_NAME] or ""
		self.fromTableId = jsonTable[FROM_TABLE_ID] or ""
		self.tableId = jsonTable[TABLE_ID] or ""
		self.tableName = jsonTable[TABLE_NAME] or ""
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableGuide