local RiverCardMSGData = class("RiverCardMSGData")

function RiverCardMSGData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_communityCards = {}
end


function RiverCardMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		if jsonTable[CODE] then
			self.m_code = jsonTable[CODE] or 0
		end
		self.m_tableId = jsonTable[TABLE_ID] or ""
		
		self.m_communityCards = jsonTable[COMMUNITY_CARDS] or {}
		
		if jsonTable[RUSH_PLAYER_ID] then
			self.m_rushPlayerId = jsonTable[RUSH_PLAYER_ID]..""
		end
		if self.m_rushPlayerId and string.len(self.m_rushPlayerId)>1 then
			self.m_tableId = self.m_rushPlayerId
		end
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RiverCardMSGData