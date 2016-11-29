
local JoinTableInfo = class("JoinTableInfo")

function JoinTableInfo:ctor()
	self.tableId = ""
	self.tableType = ""
	self.tableName = ""
	self.smallBlind = 0
	self.bigBlind = 0
	self.tableStatus = ""
end


function JoinTableInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" and jsonTable[1] then
		self.tableId = jsonTable[1]["1002"]
		self.tableType = jsonTable[1]["1003"]
		self.tableName = jsonTable[1]["1007"]
		self.smallBlind = jsonTable[1]["2008"]
		self.bigBlind = jsonTable[1]["2009"]
		self.tableStatus = jsonTable[1]["100B"]

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return JoinTableInfo