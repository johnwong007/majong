local RushJoinData = class("RushJoinData")

function RushJoinData:ctor()
	self.m_code = 0
	self.m_playerId = ""
	self.m_userId = ""
	self.m_userName = ""
	self.isTrustee = false
	self.userStatus = 0
	self.m_tableName = ""
	self.m_tableConfigId = ""
	self.m_seatNum = 0
	self.m_userChips = 0.0
	self.m_smallBlind = 0.0
	self.m_bigBlind = 0.0
	self.m_minBuy = 0.0
	self.m_maxBuy = 0.0
end


function RushJoinData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_playerId = jsonTable[RUSH_PLAYER_ID] or ""
		self.m_seatNum = jsonTable[SEAT_NUM] or 0
		self.m_userId = jsonTable[USER_ID] or ""
		self.m_userName = jsonTable[USER_NAME] or ""
		self.m_tableConfigId = jsonTable[RUSH_TABLE_CONFIG_ID] or ""

		self.isTrustee = jsonTable[IS_TRUSTEE] or false
		self.userStatus = jsonTable[PLAYER_STATUS] or 0
		self.m_tableName = jsonTable[TABLE_NAME] or ""

		self.m_userChips = jsonTable[USER_CHIPS] or 0.0
		self.m_smallBlind = jsonTable[SMALL_BLIND] or 0.0
		self.m_bigBlind = jsonTable[BIG_BLIND] or 0.0
		self.m_minBuy = jsonTable[BUY_CHIPS_MIN] or 0.0
		self.m_maxBuy = jsonTable[BUY_CHIPS_MAX] or 0.0
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RushJoinData