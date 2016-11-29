local RemindUserTableDestroy = class("RemindUserTableDestroy")

function RemindUserTableDestroy:ctor()
	self.nCode = 0
	self.tableId = ""
	self.message = ""
end


function RemindUserTableDestroy:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.nCode = jsonTable[CODE] or 0
		self.tableId = jsonTable[TABLE_ID] or ""
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RemindUserTableDestroy