local MatchGroupInfo = {
    isRebuy = false, --是否rebuy
    curUnum = "", --已报名人数
    maxUnum = 0, --最大报名人数
    channelVisiable = "", --注册渠道可见
    payType = "", --支付类型
    preSetStartTime = "", --预设开始时间
    serviceCharge = "", --服务费
    regStatus = 0, --报名状态
    picURL = "", --活动图片URL
    payNum = "", --支付数目
    matchId = "", --赛事ID
    dispColor = 0, --大厅展示牌桌的字体颜色
    matchName = "", --赛事名称
    ticketFlag = 0, --门票标记
    priority = 0, --锦标赛展示优先级
    tourneyMatchType = "", --锦标赛奖励类型
    regDelayTime = 0, --延迟报名时间
    matchStatus = "", --赛事状态
    ticketId = "", 
    mobilePic = "", 
}

local GameMatchGroupData = class("GameMatchGroupData")

function GameMatchGroupData:ctor()
    self.listType = ""
    self.matchInfoList = {}
end

function GameMatchGroupData:parseJson(strJson)
    local jsonTable = json.decode(strJson)
    if type(jsonTable) == "table" then
        self.listType = jsonTable[LIST_REQUEST_TYPE]..""
        local matchList = jsonTable[LIST_DATA]
        for index=1,#matchList do
            local eachJson = matchList[index]
            local matchInfo = clone(MatchGroupInfo)
            if eachJson[IS_REBUYTOURNEY].."" == "YES" then
                matchInfo.isRebuy = true
            else
                matchInfo.isRebuy = false
            end
                matchInfo.curUnum = eachJson[CUR_UNUM]
                matchInfo.maxUnum = eachJson[MAX_UNUM]
                matchInfo.channelVisiable = eachJson[CHANNEL_VISIABLE]
                matchInfo.payType = eachJson[PAY_TYPE]
                matchInfo.preSetStartTime = eachJson[PRESET_START_TIME]
                matchInfo.serviceCharge =eachJson[SERVICE_CHARGE]
                matchInfo.regStatus = eachJson[REG_STATUS]
                matchInfo.picURL = eachJson[PICTURE_URL]
                matchInfo.payNum =eachJson[PAY_NUM]
                matchInfo.matchId = eachJson[MATCH_ID]
                matchInfo.dispColor = eachJson[DISP_COLOR]
                matchInfo.matchName = eachJson[MATCH_NAME]
                matchInfo.ticketFlag = eachJson[TICKET_FLAG]
                matchInfo.priority = eachJson[PRIORITY]
                matchInfo.tourneyMatchType = eachJson[TOURNEY_MATCH_TYPE]
                matchInfo.regDelayTime = eachJson[REG_DELAY_TIME]
                matchInfo.matchStatus = eachJson[MATCH_STATUS]
                matchInfo.ticketId = eachJson[TICKET_ID]
                matchInfo.mobilePic = eachJson[MOBILE_PIC_URL]
                self.matchInfoList[#self.matchInfoList+1] = matchInfo
        end



        return BIZ_PARS_JSON_SUCCESS
    end
    return BIZ_PARS_JSON_FAILED
end

return GameMatchGroupData