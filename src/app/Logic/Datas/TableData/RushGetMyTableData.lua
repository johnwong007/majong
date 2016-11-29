local RushGetMyTableData = class("RushGetMyTableData")

function RushGetMyTableData:ctor()
	self.m_code = 0
	self.m_userId = ""
	self.rushPlayerTables = {}
end


function RushGetMyTableData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_userId = jsonTable[USER_ID] or ""
		
		self.rushPlayerTables = jsonTable[RUSH_MY_TABLELIST]
		end
		
		return BIZ_PARS_JSON_SUCCESS
end


return RushGetMyTableData