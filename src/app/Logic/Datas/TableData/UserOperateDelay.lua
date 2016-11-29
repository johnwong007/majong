--
-- Author: wangj
-- Date: 2016-06-27 14:18:32
--
local UserOperateDelay = class("UserOperateDelay")

function UserOperateDelay:ctor()
	self.m_code = 0
	self.m_userId = ""
	self.m_tableId = ""
	self.m_sequence = 0
	self.m_seatNo = -1
	self.m_remainTime = 0
end


function UserOperateDelay:parseJson(strJson)
	local jsonTable = strJson
	
	self.m_code = tonumber(jsonTable[CODE])
	self.m_userId = tostring(jsonTable[USER_ID])
	self.m_tableId = tostring(jsonTable[TABLE_ID])
	self.m_sequence = tonumber(jsonTable[SEQUENCE])
	self.m_seatNo = tonumber(jsonTable[SEAT_NO])
	self.m_remainTime = tonumber(jsonTable[REMAIN_TIME])
		
	return BIZ_PARS_JSON_SUCCESS
end

return UserOperateDelay