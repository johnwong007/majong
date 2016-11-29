local TourneyMatchDetail = 
{
    isRebuy = "",
    startTime = "",
    matchId = "",
    gameStatus = "",
    regStatus = 0,
    curUnum = "", --已报名人数
}

local TourneyMatchesData = class("TourneyMatchesData")

function TourneyMatchesData:ctor()
	self.matchDetailList = {}
    self.serverTime = 0
end

function TourneyMatchesData:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then

		for index=1,#jsonTable do
            local eachJson = jsonTable[index]
            local matchDetail = clone(TourneyMatchDetail)
            if jsonTable[index][IS_REBUYTOURNEY] then
            	matchDetail.isRebuy = jsonTable[index][IS_REBUYTOURNEY]..""
            end
            matchDetail.startTime = jsonTable[index][START_TIME]..""
           	matchDetail.matchId = jsonTable[index][MATCH_ID]..""
            matchDetail.gameStatus = jsonTable[index][GAME_STATUS]..""
            matchDetail.regStatus = jsonTable[index][REG_STATUS]+0
            matchDetail.curUnum = jsonTable[index][CUR_UNUM]..""
                
            local eStrTime = EStringTime:create(matchDetail.startTime)
            local t = eStrTime:getTimeStamp()
             --大于一天以上的比赛不显示
            if (t-self.serverTime<86401) then
            	self.matchDetailList[#self.matchDetailList+1]=matchDetail
            end		
        end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TourneyMatchesData