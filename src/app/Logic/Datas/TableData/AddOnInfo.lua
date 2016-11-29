local AddOnInfo = class("AddOnInfo")

function AddOnInfo:ctor()
	self.m_code = 0
	self.cmdCode = 0
	self.addOnTime = 0
	self.addOnStartTime = 0
	self.tableId = ""
end


function AddOnInfo:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.code = jsonTable[CODE]
		if self.code then
			self.code = tonumber(self.code)
		else
			self.code = 0
		end
		self.cmdCode = jsonTable[COMMAND_ID] or 0
		self.addOnTime = jsonTable[ADDON_WAIT_TIME] or 0
		self.addOnStartTime = jsonTable[ADDON_START_TIME] or 0
		self.tableId = jsonTable[TABLE_ID] or ""
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return AddOnInfo