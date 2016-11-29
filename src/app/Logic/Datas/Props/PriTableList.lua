local PriTableList = class("PriTableList")

function PriTableList:ctor()
	self.code = 0
	self.num = 0
	self.msg = ""
	self.tableList = {}
end

function PriTableList:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.code  = jsonTable["CODE"]
		self.num = jsonTable["INFO"]["num"]
		self.msg = jsonTable["MSG"]
		local list = jsonTable["LIST"]
		if list and #list>0 then
			for i=1,#list do
				local data = {}
				data["tableId"] = list[i]["1002"]
				data["tableType"] = list[i]["1003"]
				data["tableName"] = list[i]["1007"]
				data["smallBlind"] = list[i]["2008"]
				data["bigBlind"] = list[i]["2009"]
				data["startTime"] = list[i]["3007"]
				data["endTime"] = list[i]["3008"]
				data["id"] = list[i]["ID"]
				data["totalBuyin"] = list[i]["TOTAL_BUYIN"] 
				data["totalHands"] = list[i]["TOTAL_HANDS"] 
				data["winCount"] = list[i]["WIN_COUNT"] 
				self.tableList[i] = data
			end
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return PriTableList