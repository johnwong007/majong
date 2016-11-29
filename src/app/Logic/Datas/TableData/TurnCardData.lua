local TurnCardData = class("TurnCardData")

function TurnCardData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_communityCards = {}
end


function TurnCardData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		if jsonTable[CODE] then
			self.m_code = jsonTable[CODE]+0
		end
		self.m_tableId = jsonTable[TABLE_ID]..""
		
		self.m_communityCards = jsonTable[COMMUNITY_CARDS]
		
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

return TurnCardData