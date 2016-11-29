local TableProfit = class("TableProfit")

function TableProfit:ctor()
	self.m_code = 0

	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_userId = ""

	self.m_bPlaying = false
	self.m_userChips = 0.0
	self.m_totalChip = 0.0
	self.m_userHandChip = 0.0
	self.m_payType = ""
	self.m_profitChip = false
end


function TableProfit:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_tableId = jsonTable[TABLE_ID]..""
		self.m_userId = jsonTable[USER_ID]..""
		self.m_bPlaying = jsonTable[IS_PLAYING]=="YES"
		self.m_userChips = jsonTable[USER_CHIPS]+0.0
		self.m_totalChip = jsonTable[TOTAL_BUY_CHIPS]+0.0
		self.m_userHandChip = jsonTable[HAND_CHIPS]+0.0
		self.m_payType = jsonTable[PAY_TYPE]..""
		self.m_profitChip = jsonTable[PROFIT_MONEY]+0.0
		
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

return TableProfit