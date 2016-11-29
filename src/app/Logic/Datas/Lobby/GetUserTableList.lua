local UserImmTableEach = {
	usertableId = "",
	usertableType = "",
	usermatchId = ""
}

local GetUserTableList = class("GetUserTableList")

function GetUserTableList:ctor()
		self.code = ""
		self.tableList = {}
end

function GetUserTableList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	-- dump(jsonTable)
	if type(jsonTable) == "table" then
		self.code = ""
		for index=1,#jsonTable do 
			local eachJson = jsonTable[index]
			local usereachInfo = clone(UserImmTableEach)

			usereachInfo.usertableId = eachJson[TABLE_ID]..""
			local tableIdStr = usereachInfo.usertableId
			usereachInfo.usertableType = eachJson[TABLE_TYPE]..""
			if TRUNK_VERSION == DEBAO_TRUNK then
				if usereachInfo.usertableType=="TOURNEY" then
					local _,pos = string.find(tableIdStr, "TOURNEY")
                	local umatchId = string.sub(tableIdStr, pos+1, string.len(tableIdStr))
                	usereachInfo.usermatchId=umatchId
            	end
            else
            	usereachInfo.usermatchId = eachJson[MATCH_ID]..""
			end
			self.tableList[#self.tableList+1] = usereachInfo
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return GetUserTableList