local TableDestroyMsg = class("TableDestroyMsg")

function TableDestroyMsg:ctor()
	self.tableId = ""
end


function TableDestroyMsg:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.tableId = jsonTable[TABLE_ID] or ""
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableDestroyMsg