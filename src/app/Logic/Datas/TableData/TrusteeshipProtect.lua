--
-- Author: wangj
-- Date: 2016-06-27 14:18:32
--
local TrusteeshipProtect = class("TrusteeshipProtect")

function TrusteeshipProtect:ctor()
	self.m_code = 0
	self.m_userId = ""
	self.m_tableId = ""
end


function TrusteeshipProtect:parseJson(strJson)
	local jsonTable = strJson
	-- dump(jsonTable)
	self.m_code = tonumber(jsonTable[CODE])
	self.m_userId = tostring(jsonTable[USER_ID])
	self.m_tableId = tostring(jsonTable[TABLE_ID])
	
	return BIZ_PARS_JSON_SUCCESS
end

return TrusteeshipProtect