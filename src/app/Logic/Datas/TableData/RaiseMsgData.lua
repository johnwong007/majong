--[[玩家加注]]
local RaiseMsgData = class("RaiseMsgData")

function RaiseMsgData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_sitNo = 0
	self.m_userId = ""
	self.m_userChips = 0.0
	self.m_betChips = 0.0
	self.m_totalPot = 0.0
end


function RaiseMsgData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_sitNo = jsonTable[SEAT_NO] or 0
		self.m_userId = jsonTable[USER_ID] or ""
		self.m_userChips = jsonTable[USER_CHIPS] or 0.0
		self.m_betChips = jsonTable[BET_CHIPS] or 0.0
		self.m_totalPot = jsonTable[TOTAL_POT] or 0.0
		

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

return RaiseMsgData