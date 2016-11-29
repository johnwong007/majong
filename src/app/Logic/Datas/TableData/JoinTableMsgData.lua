require("app.Logic.Datas.TableData.BoardInfo")
local JoinTableMsgData = class("JoinTableMsgData")

function JoinTableMsgData:ctor()
	 self.nCode = 0
	self.tableId = ""
	self.userId = ""
	self.handId = ""
	self.userName = ""
end

function JoinTableMsgData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.nCode = jsonTable[CODE] or 0
		self.tableId = jsonTable[TABLE_ID] or ""
		self.userId = jsonTable[USER_ID] or ""
		self.handId = jsonTable[HAND_ID] or ""
		self.userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		BoardInfo:getInstance().handID = ""
		BoardInfo:getInstance().handID=self.handId 
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return JoinTableMsgData