--
-- Author: wangj
-- Date: 2016-06-27 14:18:32
--
local ApplyPublicCard = class("ApplyPublicCard")

function ApplyPublicCard:ctor()
	self.m_code = 0
	self.m_userId = ""
	self.m_tableId = ""
	self.m_cardList = nil
end


function ApplyPublicCard:parseJson(strJson)
	local jsonTable = strJson
	-- dump(jsonTable)
	self.m_code = tonumber(jsonTable[CODE])
	self.m_userId = tostring(jsonTable[USER_ID])
	self.m_tableId = tostring(jsonTable[TABLE_ID])
	self.m_handId = tostring(jsonTable[HAND_ID])
	self.m_cardList = jsonTable[CARD_LIST]
	
	return BIZ_PARS_JSON_SUCCESS
end

return ApplyPublicCard