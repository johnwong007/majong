local TourneyTableInfo = class("TourneyTableInfo")

function TourneyTableInfo:ctor()
	self.tableId = ""
	self.gameSpeed = ""
	self.tableName = ""
	self.seatNum = ""
	self.smallBlind = ""
	self.bigBlind = ""
	self.matchId = ""
	self.matchName = ""
	self.payType = ""
	self.curTnum = ""
	self.password = ""
	self.tableOwer = ""
end

function TourneyTableInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code = ""
		
		self.tableId = jsonTable[TABLE_ID]..""
		self.gameSpeed = jsonTable[GAME_SPEED]..""
		self.tableName = jsonTable[TABLE_NAME]..""
		self.seatNum = jsonTable[SEAT_NUM]..""
		self.smallBlind = jsonTable[SMALL_BLIND]..""
		self.bigBlind = jsonTable[BIG_BLIND]..""
		self.matchId = jsonTable[MATCH_ID]..""
		self.matchName = jsonTable[MATCH_NAME]..""
		self.payType = jsonTable[PAY_TYPE]..""

		self.curTnum = jsonTable[CUR_TNUM]
		if self.curTnum==nil then
			self.curTnum = "0"
		end
		self.password = jsonTable[PASSWORD]
		if self.password==nil then
			self.password = ""
		end
		self.tableOwer = jsonTable[TABLE_OWNER]
		if self.tableOwer==nil then
			self.tableOwer = ""
		end
		
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "number" then
		self.code = jsonTable+0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TourneyTableInfo