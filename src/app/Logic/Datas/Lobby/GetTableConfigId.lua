
local GetTableConfigId = class("GetTableConfigId")

function GetTableConfigId:ctor()
	self.configId = ""
	self.tableType = ""
	self.smallBlind = 0
	self.bigBlind = 0
	self.tableStatus = ""
end


function GetTableConfigId:parseJson(strJson)
	local jsonTable = json.decode(strJson)

	if type(jsonTable) == "table" and jsonTable[1] then
		self.configId = jsonTable[1]["ROOM_ID"]
		self.tableName = jsonTable[1]["1007"]
		self.tableType = jsonTable[1]["1003"]
		self.smallBlind = jsonTable[1]["2008"]
		self.bigBlind = jsonTable[1]["2009"]
		self.tableStatus = jsonTable[1]["100B"]

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return GetTableConfigId