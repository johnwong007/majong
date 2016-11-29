local MatchDetail = class("MatchDetail")

function MatchDetail:ctor()
	self.ante = 0
	self.smallBlind = 0
	self.bigBlind = 0
	self.ex1 = 0
	self.matchId = ""
	self.startTime = ""
	self.matchStatus = ""
	self.blindLevel = 0
	self.maxUchips = 0
	self.ex2 = 0
	self.minUchips = 0
	self.curUnum = 0
	self.ex3 = 0
	self.curTnum = 0
	self.userRanking = 0
	self.playingNum = 0
	self.seatNum = 0
end

function MatchDetail:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	-- dump(jsonTable)
	if type(jsonTable) == "number" then
		self.code = jsonTable+0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "table" then
		
		self.ante = jsonTable[ANTE]
		self.smallBlind = jsonTable[SMALL_BLIND]
		self.bigBlind = jsonTable[BIG_BLIND]
		self.matchId = jsonTable[MATCH_ID]
		self.startTime = jsonTable[START_TIME]
		self.matchStatus = jsonTable[MATCH_STATUS]
		self.blindLevel = jsonTable[BLIND_LEVEL]+0
		self.maxUchips = jsonTable[MAX_UCHIPS]
		self.minUchips = jsonTable[MIN_UCHIPS]
		self.curUnum = jsonTable[CUR_UNUM]
		self.curTnum = jsonTable[CUR_TNUM]
		self.userRanking = jsonTable[USER_RANKING]
		self.playingNum = jsonTable[PLAYING_UNUM]
		self.seatNum = jsonTable[SEAT_NUM]


		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return MatchDetail