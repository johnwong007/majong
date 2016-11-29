
TourneyStateUnkown = 0
TourneyStateSignUp = 1
TourneyStateSigned = 2
TourneyStateFull = 3
TourneyStateJoin = 4
TourneyStatePlaying = 5
TourneyStateDelay = 6

TourneyInfoSl =
{
    index = 0,
    isSaved = 0,
    chimpionName = "",
    chimpionImage = "",
    imagePath = "",
    state = 0,
    tableId = "",
}

TAG_INFO_DIALOG = 555

TourneyExInfo = {

    index = 0,
    isSaved = 0,
    chimpionName = "",
    chimpionImage = "",

    imagePath = "",
    state = 0,
    tableId = "",
}

eTagOnline = 10
eTagLight = 11
eTagMatchName = 12
eTagTime = 13
eTagTimeLabel = 14
eTagTimeMask = 15
eTagMatchStatus = 16
eTagLogo = 17
eTagSignNum = 18
eTagSignBtn = 19
eTagCell = 20
eTagPageTab = 21

eTourneyBulletUnkow = 0
eTourneyBulletShow = 1
eTourneyBulletHide = 2

eMatchListRecommend = 0
eMatchListGold = 1
eMatchListRakepoint = 2
eMatchListCalls = 3

eMatchListMyMatch = 4


AlertApplyResult=1
AlertNewerProtect=2
AlertApplyMatch=3
AlertNetworkError=4
AlertApplyResultToStore=5
AlertApplyResultToQuickStart=6
AlertApplyToSng=7
AlertQuitMatch=8
AlertQuitTourney=9

local TourneyHall = class("TourneyHall", function()
        return display.newNode()
    end)

function TourneyHall:ctor(params)
    self:resetData()
    self:setNodeEventEnabled(true)
    self.m_pCallbackUI = params.callback
end

function TourneyHall:resetData()
    self.m_matchList = nil
    self.m_recomMatchList = nil
    self.m_goldMatchList = nil
    self.m_rakepointMatchList = nil
    self.m_callsMatchList = nil
    self.m_recomMatchList = {}
    self.m_goldMatchList = {}
    self.m_rakepointMatchList = {}
    self.m_callsMatchList = {}
    self.m_totalInfo = nil
    self.m_userTableList = nil
    self.m_matchListType = nil

    self.m_date=os.date("%d")
    self.m_lastDate = cc.UserDefault:getInstance():getStringForKey("TOURNEY_CLEAR_FLAG", "")

    if self.m_date~=self.m_lastDate then
        self.m_clearCacheFlag = true
    end
end

function TourneyHall:onEnterTransitionFinish()
    DBHttpRequest:getMatchListByGroup(handler(self,self.httpResponse),"TOURNEY","0","0","","ASC",1)
    DBHttpRequest:getUserTableList(handler(self, self.httpResponse))
    transition.execute(self, cc.RepeatForever:create(cc.Sequence:create({cc.DelayTime:create(5), cc.CallFunc:create(handler(self, self.refresh))})))
end

function TourneyHall:refresh()
    DBHttpRequest:getUserTableList(handler(self, self.httpResponse))
    DBHttpRequest:getMatchListByGroup(handler(self,self.httpResponse),"TOURNEY","0","0","","ASC",1)
end

function TourneyHall:onEnter()
   
end

function TourneyHall:onExit()
    self:stopAllActions()
end

function TourneyHall:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    -- self:dealLoginResp(request:getResponseString())
    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function TourneyHall:onHttpResponse(tag, content, state)
    if tag==POST_COMMAND_CHAMPIONSHIPLIST then
        self:dealTourneyListByGroup(content)
    elseif tag==POST_COMMAND_GETMATCHINFO then
        self:dealGetMatchInfo(content)
    elseif tag==POST_COMMAND_APPLYMATCH then
        self:dealApplyMatch(content)
    elseif tag==POST_COMMAND_QUITMATCH then
        self:dealQuitMatch(content)
    elseif tag==POST_COMMAND_ApplyedMatch then
        self:dealGetApplyMatch(content)
    elseif tag==POST_COMMAND_GETUSERTABLELIST then
        self:dealUserTableList(content)
    end
end

function TourneyHall:dealTourneyListByGroup(content)
    local data = require("app.Logic.Datas.Lobby.GameMatchGroupData"):new()
    if (data:parseJson(content)==BIZ_PARS_JSON_SUCCESS) then
        local time_index = -1
        local time = EStringTime:create("5432-12-31 21:30:00")
        if GIOSCHECK then
            for i=#data.matchInfoList,1,-1 do
                if string.find(data.matchInfoList[i].tourneyMatchType, "实物") or
                    string.find(data.matchInfoList[i].tourneyMatchType, "话费") or 
                    string.find(data.matchInfoList[i].matchName, "金阶") or
                    string.find(data.matchInfoList[i].matchName, "京东") or
                    string.find(data.matchInfoList[i].matchName, "实物") or
                    string.find(data.matchInfoList[i].matchName, "话费") then
                    table.remove(data.matchInfoList, i)
                end
            end
        end
        -- dump(data.matchInfoList)
        for i=1,#data.matchInfoList do
            if (data.matchInfoList[i].matchStatus == "REGISTERING") then
                
                local timeB = EStringTime:create(data.matchInfoList[i].preSetStartTime)
                if (time:isBiger(timeB)) then
                    time = nil
                    time = timeB
                    time_index = i
                else
                    timeB = nil
                end
            end
        end


        for j=1,#data.matchInfoList-1 do
        
            local temp = data.matchInfoList[j].priority
            local index = j
            for k=j,#data.matchInfoList-1 do
            
                if (temp < data.matchInfoList[k+1].priority) then
                
                    temp = data.matchInfoList[k+1].priority
                    index = k + 1
                end
            end
            local info = data.matchInfoList[index]
            table.remove(data.matchInfoList,index)
            table.insert(data.matchInfoList,j,info)
        end


        if self.m_userTableList and self.m_userTableList.tableList and #self.m_userTableList.tableList>0 then 
            for idx=1,#data.matchInfoList do
                for i=1,#self.m_userTableList.tableList do 
                    if self.m_userTableList.tableList[i].usermatchId == data.matchInfoList[idx].matchId then
                        data.matchInfoList[idx].tableId = self.m_userTableList.tableList[i].usertableId
                    end
                end
            end
        end

        if data.matchInfoList and #data.matchInfoList>0 and self.m_clearCacheFlag then
            for i=1,#data.matchInfoList do
                local chimpionName = data.matchInfoList[i].mobilePic
                if chimpionName then
                    if chimpionName ~="" then
                        local resPath = cc.FileUtils:getInstance():getWritablePath()
                        local filePath = ""
                        local tmpPos = 1
                        local strLen = string.len(chimpionName)
                        for i=strLen,1,-1 do
                            if string.sub(chimpionName,i,i)=="/" then
                                tmpPos = i
                                break
                            end
                        end
                        local filename = string.sub(chimpionName,tmpPos+1,strLen)
                        filePath = resPath..filename
                        local file = io.open(filePath,"r")
                        if file then
                            --存在就读本地的
                            io.close(file)
                            os.remove (filePath) 
                        end
                    end
                end
            end
            self.m_clearCacheFlag = false
            self.m_lastDate = cc.UserDefault:getInstance():setStringForKey("TOURNEY_CLEAR_FLAG", self.m_date)
            cc.UserDefault:getInstance():flush()
        end


        self.m_rakepointMatchList = nil
        self.m_rakepointMatchList = {}
        self.m_goldMatchList = nil
        self.m_goldMatchList = {}
        self.m_callsMatchList = nil
        self.m_callsMatchList = {}
        for q=1,#data.matchInfoList do
            if (data.matchInfoList[q].tourneyMatchType=="积分") then
                self.m_rakepointMatchList[#self.m_rakepointMatchList+1]=data.matchInfoList[q]
            elseif(data.matchInfoList[q].tourneyMatchType=="金币" or data.matchInfoList[q].tourneyMatchType=="") then
                self.m_goldMatchList[#self.m_goldMatchList+1]=data.matchInfoList[q]
            elseif(data.matchInfoList[q].tourneyMatchType=="话费") then
                self.m_callsMatchList[#self.m_callsMatchList+1]=data.matchInfoList[q]
            end
        end
        if data.matchInfoList and #data.matchInfoList>0 then
            self.m_recomMatchList = nil
            self.m_recomMatchList = data.matchInfoList
        end
        -- dump(self.m_recomMatchList)
        if not self.m_matchListType then
            self.m_matchListType = eMatchListRecommend
            self:switchTab(self.m_matchListType)
        else
            self:switchTab(self.m_matchListType, true) 
        end
    else
        self.m_matchList = nil
        self.m_matchList = {}
    end
    data = nil
end

function TourneyHall:dealGetMatchInfo(content)
    local info = require("app.Logic.Datas.Lobby.MatchInfo"):new()
    if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
        -- dump(info)
        local data = {}
        local max1 = (info.gainList and #info.gainList > 0) and (info.gainList[#info.gainList].endRank) or 0
        local size = max1
       
        if(size <= 0) then
        
            if (info.prizePool ~="") then
                data[1] = clone(MatchStringNode)
                data[1].first = "1"
                data[1].second = info.prizePool
                self.m_pCallbackUI:updateInfoDialogRewardList(data)
            end
            return
        end
        
        
        --取出奖池奖励
        for i=1,#info.gainList do
        
            local node = info.gainList[i]
            for j=node.startRank,node.endRank do
                data[j] = clone(MatchStringNode)
                data[j].first = j
                data[j].second = node.gainStr
            end
        end
       
        --合并相同奖励内容
        local tmp = ""
        local needData = {}
        for i=1,#data do
        
            if #needData > 0 then
            
                if(data[i].second == needData[#needData].second) then
                
                    tmp = data[i].first
                else
                
                    if(tmp ~= "") then
                    
                        needData[#needData].first = needData[#needData].first .. "-" .. tmp
                        tmp = ""
                    end
                    needData[#needData+1] = data[i]
                end
            else
            
                needData[1]=data[i]
            end
        end
       
        if(tmp ~= "") then
        
            needData[#needData].first = needData[#needData].first .. "-" .. tmp
            tmp = ""
        end
     
        self.m_pCallbackUI:updateInfoDialogRewardList(needData)
    
    end
    info=nil
end

function TourneyHall:dealApplyMatch(content)
    local data = require("app.Logic.Datas.Lobby.ApplyMatch"):new()
    
    local dialog = self:getChildByTag(TAG_INFO_DIALOG)
    if (dialog) then 
        dialog:getParent():removeChild(dialog, true)
    end
    
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
     
        local datas = {}
        local result = data.applyMatchResult
        
        --特殊处理code  作为扩展当服务器返回此值直接取返回信息提示用户
        if (result == -16021) then
        
            local alert = require("app.Component.EAlertView"):alertView(
                                                      self:getParent(),
                                                      self:getParent(),
                                                      "",
                                                      data.errorStr,
                                                      "确定",
                                                      nil
                                                      )
            alert:alertShow()
        else
        

            local resultTag1 = 10000
            local resultTag2 = -11057
            local resultTag3 = -18
            if TRUNK_VERSION==DEBAO_TRUNK then
                resultTag1 = 0
                resultTag2 = -13001
                resultTag3 = -18
            end
            
            
            if result==resultTag1 then
            
                
                local alert = require("app.Component.ETooltipView"):alertView(
                                                              self:getParent(),
                                                              "",
                                                              "恭喜您报名成功"
                                                              )
                alert:show()
                
                DBHttpRequest:getMatchListByGroup(handler(self,self.httpResponse),"TOURNEY","0","0","","ASC",1)
            else
            
                local resultStr = "          报名失败"
                if (result==resultTag2) then --(result==-13001)
                
                    resultStr = "对不起，您当前的余额无法支付当场比赛的报名费。是否立即充值？"
                    local alert = require("app.Component.EAlertView"):alertView(
                                                              self:getParent(),
                                                              self:getParent(),
                                                              "",
                                                              resultStr,
                                                              "取消",
                                                              "立即充值",
                                                              nil
                                                              )
                    alert.alertType = AlertApplyResultToStore
                    if (alert) then
                    
                        alert:alertShow()
                    end
                elseif (result==resultTag3) then --(result==-5)
                
                    resultStr = "对不起，您不是付费用户，不能报名该场锦标赛。是否立即充值？"
                    local alert = require("app.Component.EAlertView"):alertView(
                                                              self:getParent(),
                                                              self:getParent(),
                                                              "",
                                                              resultStr,
                                                              "取消",
                                                              "立即充值",
                                                              nil
                                                              )
                    alert.alertType = AlertApplyResultToStore
                    if (alert) then
                    
                        alert:alertShow()
                    end
                    
                else
                
                    local resultTag = {-2,-3,-4,-5,-7,-8,-11,-12,-13,-14,-15,-16,-17,-403,-500,-501,-10000,-12016,-13004,-13006,-13007,-14017,-14037,-14038}
                    local resultStrNew = {
                        "对不起，您没有资格报名该场锦标赛。-2",---2
                        "对不起，您已经报名该场锦标赛，不能重复报名。-3",---3
                        "对不起，报名时间已截止。-4",---4
                        "对不起，名额已满，请刷新列表。-5",---5
                        "对不起，您没有该场锦标赛的门票。-7",---7
                        "对不起，您没有资格报名该场锦标赛。-8",---8
                        "对不起，您没有资格报名该场锦标赛。-11",---11
                        "对不起，您没有资格报名该场锦标赛。-12",---12
                        "对不起，您没有资格报名该场锦标赛。-13",---13
                        "对不起，系统异常，请稍候重试。-14",---14
                        "对不起，系统异常，请稍候重试。-15",---15
                        "对不起，您没有资格报名该场锦标赛。-16",---16
                        "对不起，您没有资格报名该场锦标赛。-17",---17
                        "对不起，您还未登录，请稍候重试。-403",---403
                        "对不起，系统异常，请稍候重试。-500",---500
                        "对不起，系统异常，请稍候重试。-501",---501
                        "对不起，系统异常，请稍候重试。-10000",---10000
                        "对不起，系统异常，请稍候重试。-12016",---12016
                        "对不起，系统异常，请稍候重试。-13004",---13004
                        "对不起，系统异常，请稍候重试。-13006",---13006
                        "对不起，系统异常，请稍候重试。-13007",---13007
                        "对不起，系统异常，请稍候重试。-14017",---14017
                        "对不起，系统异常，请稍候重试。-14037",---14037
                        "对不起，系统异常，请稍候重试。-14038"---14038
                    }
                    local flag = -1
                    for i=1,24 do
                    
                        if (result==resultTag[i]) then
                        
                            flag = i
                            break
                        end
                    end
                    
                    if (flag~=-1) then
                    
                        resultStr = resultStrNew[flag]
                        local alert = require("app.Component.EAlertView"):alertView(
                                                                  self:getParent(),
                                                                  self:getParent(),
                                                                  "",
                                                                  resultStr,
                                                                  "确定",
                                                                  nil
                                                                  )
                        alert.alertType = AlertApplyResult
                        if (alert) then
                        
                            alert:alertShow()
                        end
                    end
                end
            end
        end
    end
    
    data = nil
end

-- function TourneyHall:dealQuitMatch(content)
--     DBHttpRequest:getMatchListByGroup(handler(self,self.httpResponse),"TOURNEY","0","0","","ASC",1)
--     DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))
--     local code = content+0
--     if (code > 0) then
    
--         local alert = require("app.Component.ETooltipView"):alertView(self:getParent(),"","成功取消报名!")
--         alert:show()
        
--     else
--         local info = "系统异常"
--         if (code==-1) then 
--             info ="赛事不存在"
--         elseif(code==-4) then
--             info ="退赛截止时间已过"
--         elseif(code==-6) then
--             info ="该赛事目前不允许退赛"
--         elseif(code==-8) then
--             info ="未报名该赛事"
--         elseif(code==-10) then
--             info ="人满之后不能退赛"
--         elseif(code==-403) then
--             info ="未登录"
--         elseif(code==-500) then
--             info ="系统异常"
--         elseif(code==-501) then
--             info ="系统异常"
--         elseif(code==-10000) then
--             info ="系统异常"
--         elseif(code==-12016) then
--             info ="用户不存在"
--         elseif(code==-13004) then
--             info ="用户不存在"
--         end
--         local resultStr= "取消赛事失败,原因:"..info
--         local alert = require("app.Component.ETooltipView"):alertView(self:getParent(),"",resultStr)
--         alert:show()
--     end
-- end

function TourneyHall:dealGetApplyMatch(content)
    local data = require("app.Logic.Datas.Lobby.ApplyMatchData"):new()
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then 
        self.m_applyMatchList=data.matchDetailList
        if self.m_userTableList and self.m_userTableList.tableList and #self.m_userTableList.tableList>0 then 
            for idx=1,#self.m_applyMatchList do
                for i=1,#self.m_userTableList.tableList do 
                    if self.m_userTableList.tableList[i].usermatchId == self.m_applyMatchList[idx].matchId then
                        self.m_applyMatchList[idx].tableId = self.m_userTableList.tableList[i].usertableId
                    end
                end
            end
        end

        self:switchTab(self.m_matchListType)
    end
    data = nil
end

function TourneyHall:dealUserTableList(content)

    local data = require("app.Logic.Datas.Lobby.GetUserTableList"):new()
    self.m_userTableList = nil
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
    
        self.m_userTableList = data
        -- DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))
    end
    data = nil
end

function TourneyHall:dealQuitMatch(content)
        DBHttpRequest:getMatchListByGroup(handler(self,self.httpResponse),"TOURNEY","0","0","","ASC",1)
        DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))
    local code = content+0
    if (code > 0) then
        self.m_pCallbackUI:showQuitMatchResult(true, "成功取消报名!")
    else
        local info = "系统异常"
        if (code==-1) then 
            info ="赛事不存在"
        elseif(code==-4) then
            info ="退赛截止时间已过"
        elseif(code==-6) then
            info ="该赛事目前不允许退赛"
        elseif(code==-8) then
            info ="未报名该赛事"
        elseif(code==-10) then
            info ="人满之后不能退赛"
        elseif(code==-403) then
            info ="未登录"
        elseif(code==-500) then
            info ="系统异常"
        elseif(code==-501) then
            info ="系统异常"
        elseif(code==-10000) then
            info ="系统异常"
        elseif(code==-12016) then
            info ="用户不存在"
        elseif(code==-13004) then
            info ="用户不存在"
        end
        local resultStr= "取消赛事失败,原因:"..info

        self.m_pCallbackUI:showQuitMatchResult(false, resultStr)
    end
end

function TourneyHall:sortListData()
    table.sort(self.m_currentMatchList, function(a, b)
            if a.preSetStartTime and b.preSetStartTime then
                local timeA = EStringTime:create(a.preSetStartTime)
                local timeB = EStringTime:create(b.preSetStartTime)
                if timeA:isBiger(timeB) then
                    return false
                else
                    return true
                end
            elseif a.presetStartTime and b.presetStartTime then
                local timeA = EStringTime:create(a.presetStartTime)
                local timeB = EStringTime:create(b.presetStartTime)
                if timeA:isBiger(timeB) then
                    return false
                else
                    return true
                end
            end   
            return false
        end)
end

function TourneyHall:switchTab(matchListType, scrollToLastPos)
    self.m_currentType = matchListType
    self.m_currentMatchList = nil
    if matchListType == eMatchListRecommend then
        self.m_currentMatchList = self.m_recomMatchList
    elseif matchListType == eMatchListGold then
        self.m_currentMatchList = self.m_goldMatchList
    elseif matchListType == eMatchListRakepoint then
        self.m_currentMatchList = self.m_rakepointMatchList
    elseif matchListType == eMatchListCalls then
        self.m_currentMatchList = self.m_callsMatchList
    elseif matchListType == eMatchListMyMatch then
        self.m_currentMatchList = self.m_applyMatchList
    end

    self.m_matchListType = matchListType
    self:sortListData()
    self:getMobilePic()
    self.m_pCallbackUI:switchTab(self.m_currentMatchList, matchListType, scrollToLastPos)
end

function TourneyHall:getMobilePic()
    self.m_totalInfo = nil
    self.m_totalInfo = {}
    self.m_filename = nil
    self.m_filename = {}

    for i=1,#self.m_currentMatchList do
        if self.m_currentMatchList[i].mobilePic then
            local headImage = "http://cache.debao.com"
            if SERVER_ENVIROMENT == ENVIROMENT_TEST then
                headImage = "http://debao.boss.com"
            end
            local info = clone(TourneyExInfo)
            info.index = i
            info.chimpionImage = headImage..self.m_currentMatchList[i].mobilePic
            info.chimpionName = self.m_currentMatchList[i].mobilePic
            info.imagePath = ""
            if (info.chimpionName ~="") then
                info.isSaved = 0
                
                local state = TourneyStateUnkown
                local regStatus = self.m_currentMatchList[i].regStatus
                if(regStatus == 0) then
                    state = TourneyStateSignUp
                else
                    state = TourneyStateSigned
                end
                
                local bFull = self.m_currentMatchList[i].curUnum+0 >= self.m_currentMatchList[i].maxUnum+0
                if(bFull) then
                    state = TourneyStateFull
                end
                if (self.m_currentMatchList[i].matchStatus ~= "REGISTERING") then
                

                end
                
                info.state = state
                
                
                local resPath = cc.FileUtils:getInstance():getWritablePath()
                local filePath = ""
                local tmpPos = 1
                local strLen = string.len(info.chimpionName)
                for i=strLen,1,-1 do
                    if string.sub(info.chimpionName,i,i)=="/" then
                        tmpPos = i
                        break
                    end
                end
                local filename = string.sub(info.chimpionName,tmpPos+1,strLen)
                -- dump(filename)
                self.m_filename[#self.m_totalInfo+1] = filename
                filePath = resPath..filename
                local file = io.open(filePath,"r")
                if (not file) then
                    --不存在就下载
                    DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse), info.chimpionImage, info.chimpionName, false, #self.m_totalInfo+1)
                else
        
                    --存在就读本地的
                    io.close(file)
                    info.isSaved =1
                    --存在就读本地的
                    info.imagePath = filePath
                    self.m_currentMatchList[i].imagePath = filePath
                end
     
                self.m_totalInfo[#self.m_totalInfo+1] = info
            end
        end
            
    end
end

function TourneyHall:onHttpDownloadResponse(event)
    local ok = (event.name == "completed") 
    if not ok then 
        return
    end
    local request = event.request  
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
    local filename = cc.FileUtils:getInstance():getWritablePath()..self.m_filename[request.tag]
    request:saveResponseData(filename) 
    self.m_totalInfo[request.tag].imagePath = filename
    self:showMobileImage(request.tag)
    
end

function TourneyHall:showMobileImage(tag)
    if self.m_totalInfo[tag].imagePath~=nil and self.m_totalInfo[tag].imagePath~="" then 
        for j=1,#self.m_currentMatchList do
            if self.m_totalInfo[tag].index == j then
                self.m_pCallbackUI:showMobileImage(self.m_totalInfo[tag].imagePath, j)
            end
        end
    end
end

function TourneyHall:getMyApplyMatch()
    -- DBHttpRequest:getUserTableList(handler(self, self.httpResponse))
    DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))
end

function TourneyHall:showInfoDialog(tag)
    DBHttpRequest:getMatchInfo(handler(self,self.httpResponse), self.m_currentMatchList[tag].matchId, "")
    if self.m_pCallbackUI then
        self.m_pCallbackUI:showInfoDialog(self.m_currentMatchList[tag])
    end
end

function TourneyHall:applyMatch(params)
    if params==nil then
        return
    end
    local dialogType = params.dialogType
    local index = params.index
    if dialogType == "ticket" then
        DBHttpRequest:applyMatch(handler(self,self.httpResponse),self.m_currentMatchList[index].matchId,true,true)
    else
        DBHttpRequest:applyMatch(handler(self,self.httpResponse),self.m_currentMatchList[index].matchId,false,true)
    end
end

function TourneyHall:quitMatch(matchId)
    DBHttpRequest:quitMatch(handler(self,self.httpResponse), matchId)
end

return TourneyHall