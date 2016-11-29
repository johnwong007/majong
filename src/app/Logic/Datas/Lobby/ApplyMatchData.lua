local ApplyMatchDetail = {
    blindLv = "" ,
    startTime = "" ,
    tourneyType = "" ,
    matchId = "" ,
    matchName = "" ,
    announceTime = "" ,
    matchDesc = "" ,
    initChips = "" ,
    matchStatus = "" ,
    endTime = "" ,
    regBeginTime = "" ,
    gainName = "" ,
    bonusRatio = "" ,
    serviceCharge = "" ,
    payNum = "" ,
    payType = "" ,
    presetStartTime = "" ,
    blindType = "" ,
    regDelayTime = "" ,
    rebuyValidTime = "" ,
    remoteName = "" ,
    rebuyPayMoney = "" ,
    addOnWaitTime = "" ,
    addOnValue = "" ,
    addOnPayMoney = "" ,
    matchCopyCNT = "" ,
    minUnum = "" ,
    retireDeadline = "" ,
    isRebuy = "" ,
    prizePool = "" ,
    bonusName = "" ,
    rebuyValue = "" ,
    curUnum = "" ,
    rebuyLimitCount = "" ,
    maxUnum = "" ,
    auditStatus = "" ,
    seatNum = "" ,
    gameSpeed = "" ,
}
----------------------------------------------
local ApplyMatchData = class("ApplyMatchData")

function ApplyMatchData:ctor()
	self.matchDetailList = {}
end

function ApplyMatchData:parseJson(strJson)
	local var = json.decode(strJson)
	if type(var) == "table" then
	
        for index=1,#var do
            local eachJson = var[index]
            local matchDetail = clone(ApplyMatchDetail) 
                
            matchDetail.blindLv = var[index][BLIND_LEVEL]
            matchDetail.startTime = var[index][START_TIME]
            matchDetail.tourneyType = var[index][TOURNEY_TYPE]
            matchDetail.matchId = var[index][MATCH_ID]
            matchDetail.matchName = var[index][MATCH_NAME]
            matchDetail.announceTime = var[index][ANNOUNCE_TIME]
            matchDetail.matchDesc = var[index][MATCH_DESC]
            matchDetail.initChips = var[index][INIT_CHIPS]
            matchDetail.matchStatus = var[index][MATCH_STATUS]
            matchDetail.endTime = var[index][END_TIME]
            matchDetail.regBeginTime = var[index][REG_BEGIN_TIME]
            matchDetail.gainName = var[index][GAIN_NAME]
            matchDetail.bonusRatio = var[index][BONUS_RATIO]
            matchDetail.serviceCharge = var[index][SERVICE_CHARGE]
            matchDetail.payNum = var[index][PAY_NUM]
            matchDetail.payType = var[index][PAY_TYPE]
            matchDetail.presetStartTime = var[index][PRESET_START_TIME]
            matchDetail.blindType = var[index][BLIND_TYPE]
            matchDetail.regDelayTime = var[index][REG_DELAY_TIME]
            matchDetail.rebuyValidTime = var[index][REBUY_VALID_TIME]
            matchDetail.remoteName = var[index][REMOTE_NAME]
            matchDetail.rebuyPayMoney = var[index][REBUY_PAY_MONEY]
            matchDetail.addOnWaitTime = var[index][ADDON_WAIT_TIME]
            matchDetail.addOnValue = var[index][ADDON_VALUE]
            matchDetail.addOnPayMoney = var[index][ADDON_PAYMONEY]
            matchDetail.matchCopyCNT = var[index][MATCH_COPY_CNT]
            matchDetail.minUnum = var[index][MIN_UNUM]
            matchDetail.retireDeadline = var[index][RETIRE_DEADLINE]
            matchDetail.isRebuy = var[index][IS_REBUYTOURNEY]
            matchDetail.prizePool = var[index][PRIZE_POOL]
            matchDetail.bonusName = var[index][BONUS_NAME]
            matchDetail.rebuyValue = var[index][REBUY_VALUE]
            matchDetail.curUnum = var[index][CUR_UNUM]
            matchDetail.rebuyLimitCount = var[index][REBUY_LIMIT_COUNT]
            matchDetail.maxUnum = var[index][MAX_UNUM]
            matchDetail.auditStatus = var[index][AUDIT_STATUS]
            matchDetail.seatNum = var[index][SEAT_NUM]
            matchDetail.gameSpeed = var[index][GAME_SPEED]

        	self.matchDetailList[#self.matchDetailList+1] = matchDetail
        end
        parsResult = BIZ_PARS_JSON_SUCCESS
        return BIZ_PARS_JSON_SUCCESS
	end
    return BIZ_PARS_JSON_FAILED
end

return ApplyMatchData