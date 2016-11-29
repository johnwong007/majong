require("app.LangStringDefine")

local CurrentInfoFromMath = 
{
	leftTime,
	curUnum,
	userRanking,
}

local GainEach = 
{
	startRank,
	endRank,
	gainStr,
    gainName,
	gainNum,
}

local MatchInfo = class("MatchInfo")

function MatchInfo:ctor()
	self.gameSpeed = ""
	self.seatNum = -1
	self.matchId = ""
	self.matchName = ""
	self.matchType = ""
	self.startTime = ""
	self.endTime = ""
	self.matchStatus = ""
	self.blindLevel = ""
	self.prizePool = ""
	self.blindType = ""
	self.presetStartTime = ""
	self.payType = ""
	self.payNum = ""
	self.serviceCharge = ""
	self.bonusRatio = ""
	self.auditStatus = false
	self.bonusName = ""
	self.matchDesc = ""
	self.matchCopyCnt = ""
	self.ex1 = ""
	self.ex2 = ""
	self.ex3 = ""
	self.ex4 = ""
	self.ex5 = ""
	self.ticketGroup = ""
	self.ticketFlag = ""
	self.announceTime = ""
	self.initChips = ""
	self.regBeginTime = ""
	self.gainName = ""
	self.ticketId = ""
	self.ticketName = ""
	self.regDelayTime = ""
	self.remoteName = ""
	self.ex6 = ""
	self.minUnumv = 0
	self.retireDeadline = ""
	self.ex7 = false
	self.ex8 = ""
	self.curUnum = 0
	self.ex9 = ""
	self.maxUnum = ""
	self.leftTime = 0
	self.currentInfo = clone(CurrentInfoFromMath)
	self.gainList = {}
end

function MatchInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "number" then
		self.code = jsonTable+0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "table" then
		self.gameSpeed = jsonTable[GAME_SPEED]
        local temp = jsonTable[SEAT_NUM]
        self.seatNum = temp+0
        self.matchId = jsonTable[MATCH_ID]
        self.matchName = jsonTable[MATCH_NAME]
        self.matchType = jsonTable[MATCH_TYPE]
        self.startTime = jsonTable[START_TIME]
        self.endTime = jsonTable[END_TIME]
        self.matchStatus = jsonTable[MATCH_STATUS]
        self.blindLevel = jsonTable[BLIND_LEVEL]
        self.prizePool = jsonTable[PRIZE_POOL]
        self.blindType = jsonTable[BLIND_TYPE]
        self.presetStartTime = jsonTable[PRESET_START_TIME]
        self.payType = jsonTable[PAY_TYPE]
        self.payNum = jsonTable[PAY_NUM]
        self.serviceCharge = jsonTable[SERVICE_CHARGE]
        self.bonusRatio = jsonTable[BONUS_RATIO]
        self.auditStatus = jsonTable[AUDIT_STATUS] == "YES"
        self.bonusName = jsonTable[BONUS_NAME]
        self.matchDesc = jsonTable[MATCH_DESC]
        self.matchCopyCnt = jsonTable[MATCH_COPY_CNT]
        self.ticketGroup = jsonTable[TICKET_GROUP]
        self.ticketFlag = jsonTable[TICKET_FLAG]
        self.announceTime = jsonTable[ANNOUNCE_TIME]
        self.initChips = jsonTable[INIT_CHIPS]
        self.regBeginTime = jsonTable[REG_BEGIN_TIME]
        self.gainName = jsonTable[GAIN_NAME]
        self.ticketId = jsonTable[TICKET_ID]
        self.ticketName = jsonTable[TICKET_NAME]
        self.regDelayTime = jsonTable[REG_DELAY_TIME]
        self.remoteName = jsonTable[REMOTE_NAME]
        self.minUnum = jsonTable[MIN_UNUM]
        self.retireDeadline = jsonTable[RETIRE_DEADLINE]
        temp = jsonTable[CUR_UNUM]
        self.curUnum = temp+0
        self.maxUnum = jsonTable[MAX_UNUM]
        self.leftTime = jsonTable[TOURNEY_LEFTTIME]
        self.rebuyLimitCount = tonumber(jsonTable[REBUY_LIMIT_COUNT])

        local info = jsonTable["current"]
        self.currentInfo.curUnum = info[CUR_UNUM]
        self.currentInfo.leftTime = info["left_time"]
        self.currentInfo.userRanking = info[USER_RANKING]
        
        
        local gain = jsonTable[GAIN_INFO]
        if type(gain) == "table" then
            -- dump(gain)
        for index=1,#gain do
            local tmp = clone(GainEach)
            local startRank = gain[index][PRIZE_BEGIN_RANK]
            local endRank = gain[index][PRIZE_END_RANK]
            local gName = gain[index][GOODS_NAME]
            tmp.gainName = gain[index][GOODS_NAME]
            local goodIdStr = gain[index][GOODS_ID]
            
            tmp.startRank = startRank+0
            tmp.endRank = endRank+0
            
            local goodId = goodIdStr+0
            if ((goodId==0 or gName == nil or gName == "") and gain[index][GAIN_TYPE] =="GOLD") then
                gName = Lang_Chip
            end
            if (gain[index][GAIN_TYPE] =="RAKEPOINT") then
                gName = "积分"
            end
            
            --local bonus = gain[index][GAIN_NUM]+0
            local bonus = gain[index][GAIN_NUM]
            tmp.gainNum =  bonus+0.0
            
            local gainCNNumNew = ""
            local findStr1 = "充值卡"
            local findStr2 = "手机"
            local findStr3 = "京东"
            local position2
            position2 = string.find(gName,findStr2)
            if (position2 ~= nil) then
                gainCNNumNew = "部"
            end
            local position1 
            position1 = string.find(gName,findStr1) 
            if (position1 ~= nil) then
                gainCNNumNew = "张"
            end
            local position3 
            position3 = string.find(gName,findStr3) 

            local fileNameNewName = string.format("%s%s%s",bonus, gainCNNumNew, gName)
            if (position3 ~= nil) then
                fileNameNewName = gName
            end

            local newgoodsName = fileNameNewName
            tmp.gainStr = newgoodsName

            self.gainList[#self.gainList+1] = tmp
        end
        end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return MatchInfo