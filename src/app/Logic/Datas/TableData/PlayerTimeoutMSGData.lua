--[[12发玩家超时消息]]
local PlayerTimeoutMSGData = class("PlayerTimeoutMSGData")

function PlayerTimeoutMSGData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_seatNo = 0
	self.m_userId = ""
	self.m_rushPlayerId = ""
end


function PlayerTimeoutMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_seatNo = jsonTable[SEAT_NO] or 0
		self.m_userId = jsonTable[USER_ID] or ""
		
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

return PlayerTimeoutMSGData