local RushPreBuyData = class("RushPreBuyData")

function RushPreBuyData:ctor()
	self.m_code = 0
	self.m_playerId = ""
	self.m_tableId = ""
	self.m_userId = ""
	self.m_payType = ""
	self.m_userChips = 0.0
	self.m_buyChips = 0.0
	self.m_preBuyChips = 0.0
end


function RushPreBuyData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_playerId = jsonTable[RUSH_PLAYER_ID] or ""
		self.m_userId = jsonTable[USER_ID] or ""
		self.m_payType = jsonTable[PAY_TYPE] or ""
		self.m_userChips = jsonTable[USER_CHIPS] or 0.0
		self.m_buyChips = jsonTable[BUY_CHIPS] or 0.0
		self.m_preBuyChips = jsonTable[RUSH_PRE_BUY_CHIPS] or 0.0
		
		if jsonTable[RUSH_PLAYER_ID] then
			self.m_playerId = jsonTable[RUSH_PLAYER_ID]..""
		end
		if self.m_playerId and string.len(self.m_playerId)>1 then
			self.m_tableId = self.m_playerId
		end
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RushPreBuyData