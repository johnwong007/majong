 local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
require("app.Logic.Datas.TableData.WaitForMSGData")
require("app.Logic.UserConfig")
require("app.LangStringDefine")
require("app.Logic.Datas.TableData.BoardInfo")
local DBHttpRequest = require("app.Network.Http.DBHttpRequest")
require("app.Logic.Room.Seat")
local MusicPlayer = require("app.Tools.MusicPlayer")

local BaseRoom = class("BaseRoom", function()
        return display.newNode()
    end)

-- function BaseRoom:create(seatNum)
--  local baseRoom = BaseRoom:new()
--  baseRoom:initData(seatNum)
--  return baseRoom
-- end

function BaseRoom:ctor()
    self.m_isAdd_buyinChips = false
    self.m_isQuickStart = false
    self.m_myselfSeatId = -1
    self.m_isQuitRoom = false
    self.m_bIsBroken = false
    self.m_bfirstSitAndBuy = true

    --[[不直接接收TCP数据处理 所有tcp数据都在RoomManager里面处理]]
    self.tcpRequest = TcpCommandRequest:shareInstance()

    self:setMyTotalMoney(myInfo:getTotalChips())

    self.m_calcMyPokers = require("app.Logic.CalcPokers.CalcPoker"):new()
    self.m_myBestCardType  = -1
    self.m_myBuyChipsNum   = 0.0
    self.m_myPreOperateOpt = -1
    self.m_roomInfo = require("app.Logic.Room.RoomInfo"):new()
    self.m_isAutoBuyinChips=UserDefaultSetting:getInstance():getAutoBuyChip()
    
    self.m_myWaitForData = nil
    self.m_bGreatThanThree = false
    
    self.m_bAutoBuyinReqing   = false
    
    self.m_prizeAllPotInfoDic  = {}
    self.m_previousPrizeSeatNo = -1

    self.m_childRoom = nil

    self.m_tmp = 1000

    self.m_pCallbackUI = nil
    self.mTargetId = "DebaoClub"..myInfo.data.userClubId
    self.mIsEnterClubSuc = false
    self:setNodeEventEnabled(true)
    self.m_schedulerPool = require("app.Tools.SchedulerPool").new()
    MusicPlayer:getInstance():stopBackgroundMusic()
end

function BaseRoom:onNodeEvent(event)
    if event == "exit" then
        self:onExit()
    end
end

function BaseRoom:onEnterTransitionFinish()
    self.m_keepTableId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,
        self.keepTable),300,false)
end

function BaseRoom:keepTable(dt)
    self.tcpRequest:keepTable(self.m_roomInfo.tableId, myInfo.data.userId)
end

function BaseRoom:onExit()
        self.m_pCallbackUI = nil
        self.tcpRequest:removeObserver(self)
        self.m_calcMyPokers = {}
        self.m_seatsArray = {}
        self.m_myWaitForData = {}
        self.m_prizeAllPotInfoDic = {}
    if self.m_prizeDFEPId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_prizeDFEPId)
        self.m_prizeDFEPId = nil
    end
    if self.m_keepTableId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_keepTableId)
        self.m_keepTableId = nil
    end
    
end

function BaseRoom:setChildRoom(room)
    self.m_childRoom = room
end

function BaseRoom:setMyTotalMoney(money)
    myInfo:setTotalChips((money<0) and 0 or money)
    self.m_myTotalMoney = myInfo:getTotalChips()
end

function BaseRoom:setMyDebaoDiamond(diamond)
    myInfo.data.userDebaoDiamond = diamond
    self.m_myTotalMoney = myInfo.data.userDebaoDiamond
end

function BaseRoom:getMyTotalMoney()
    if self.m_roomInfo.payType == "POINT" then
        self.m_myTotalMoney = tonumber(myInfo.data.userDebaoDiamond)
    else
        self.m_myTotalMoney = tonumber(myInfo:getTotalChips())
    end
    return self.m_myTotalMoney
end

--[[
 * 根据桌子数目初始化创建
 * 桌子 各玩家的筹码 公共筹码池 公牌
 ]]
function BaseRoom:initData(seatNum)
    if type(seatNum)~= "number" then
        return
    end 
    self.m_roomInfo.seatNum = seatNum
    self.m_seatsArray = {}
    for i=1,seatNum,1 do
        self.m_seatsArray[i] = require("app.Logic.Room.Seat"):new()
    end
end

function BaseRoom:setRoomCallback(callback)
    self.m_pCallbackUI = callback
end

function BaseRoom:getMyRakePoint()
    return myInfo.data.diamondBalance
end

function BaseRoom:reqMyBigBlind()
    return self.m_roomInfo.bigBlind
end

function BaseRoom:reqUserVipInfo(userid)
    DBHttpRequest:getVipInfo(function(event) if self.httpResponse then self:httpResponse(event) end
            end,userid,true)
end

function BaseRoom:isMyseat(seatOrUserId)
    if type(seatOrUserId) == "number" then
        return (self.m_myselfSeatId == seatOrUserId)
    else
        return (myInfo.data.userId == seatOrUserId)
    end
end


function BaseRoom:myselfIsPlaying() --自己在玩
    if self.m_myselfSeatId>=0 then
        local seat = self:getSeat(self.m_myselfSeatId)
        return (seat and seat.userStatus >= PLAYER_STATE_PLAY and 
            seat.userStatus~=PLAYER_STATE_FOLD and seat.userStatus~=PLAYER_STATE_AFK)
    end
    return false
end

function BaseRoom:myselfIsOnSeat()
    if self.m_myselfSeatId>=0 then
        local seat = self:getSeat(self.m_myselfSeatId)
        return (seat.userStatus >= PLAYER_STATE_REMAIN)
    end
    return false
end

--[[自己手上有牌]]
function BaseRoom:myselfHasCards()
    -- normal_info_log("BaseRoom:myselfHasCards")
    local hasCards = false
    if self.m_myselfSeatId>=0 then
        local seat = self:getSeat(self.m_myselfSeatId+0)
        if(seat.userStatus == PLAYER_STATE_PLAY  or
           seat.userStatus == PLAYER_STATE_ALLIN or
           seat.userStatus == PLAYER_STATE_AFK) then --暂离了但是服务器给自动看牌 手上还有牌
            hasCards = true
        end
    end
    
    return hasCards
end


function BaseRoom:showRoomInfo()
    self.m_pCallbackUI:showRoomInfo_Callback(self.m_roomInfo.tableId,
        self.m_roomInfo.tableName, self.m_roomInfo.smallBlind, self.m_roomInfo.bigBlind)
end

function BaseRoom:setIsFirstRound(var)
    self.m_roomInfo.isFirstRound = var
end

function BaseRoom:getSeat(seatOrUserId)

    local seat = nil
    if type(seatOrUserId) == "number" then
        if seatOrUserId>=0 and seatOrUserId < self.m_roomInfo.seatNum then
            seat = self.m_seatsArray[seatOrUserId+1]
        end
    else
        for i=1,self.m_roomInfo.seatNum do
            local tmpSeat = self.m_seatsArray[i]
            if seatOrUserId==tmpSeat.userId then
                seat = self.m_seatsArray[i]
            end
        end
    end
    return seat
end

function BaseRoom:DebaoBuyin()

end

----------------------------------------------------------
--[[处理进入房间数据]]
function BaseRoom:dealTableInfoResp(dataModel)
    if not self.m_pCallbackUI then
        return
    end
    -- dump("========================BaseRoom:dealTableInfoResp==================")
    local tableInfo = dataModel
    --[[保存初始化信息]]
    self.m_roomInfo.payType         = tableInfo.currentTableInfo.payType
    self.m_roomInfo.tableId         = tableInfo.currentTableInfo.tableId
    self.m_roomInfo.tableName       = tableInfo.currentTableInfo.tableName
    self.m_roomInfo.tableType       = tableInfo.currentTableInfo.tableType
    self.m_roomInfo.sequence        = tableInfo.currentTableInfo.sequence
    self.m_roomInfo.tableStatus     = tableInfo.currentTableInfo.gameStatus
    self.m_roomInfo.smallBlind      = tableInfo.currentTableInfo.smallBlind
    self.m_roomInfo.bigBlind        = tableInfo.currentTableInfo.bigBlind
    self.m_roomInfo.buttonNo        = tableInfo.currentTableInfo.dealerNo
    self.m_roomInfo.sBlindNo        = tableInfo.currentTableInfo.sBlindNo
    self.m_roomInfo.bBlindNo        = tableInfo.currentTableInfo.bBlindNo
    self.m_roomInfo.buyChipsMin     = tableInfo.currentTableInfo.buyChipsMin
    self.m_roomInfo.buyChipsMax     = tableInfo.currentTableInfo.buyChipsMax
    self.m_roomInfo.originalBuyChipsMax     = tableInfo.currentTableInfo.buyChipsMax
    self.m_roomInfo.gameSpeed       = tableInfo.currentTableInfo.gameSpeed
    self.m_roomInfo.tableOwner      = tableInfo.currentTableInfo.tableOwner
    self.m_roomInfo.serviceCharge   = tableInfo.currentTableInfo.serviceCharge
    self.m_roomInfo.destroyTime      = tableInfo.currentTableInfo.destroyTime
    self.m_roomInfo.playType        = tableInfo.currentTableInfo.playType
    self.m_roomInfo.tmpBuyChipsMin  = tableInfo.playerMyInfo.buyChipsMin
    self.m_roomInfo.tmpBuyChipsMax  = tableInfo.playerMyInfo.buyChipsMax

    if self.m_roomInfo.playType == "BIDA" then
        self.m_roomInfo.buyinTimes = tableInfo.playerMyInfo.buyinTimes or 0
    end

    if self.m_roomInfo.payType == "POINT" and 
        self.m_roomInfo.tableType == "CASH" and
        self.m_roomInfo.tableOwner ~= "sys" and 
        tonumber(self.m_roomInfo.serviceCharge) >= 0 then
        self.m_calcMyPokers.playType = 1
        dump("==============>")dump("==============>")dump("==============>")dump("==============>")
    end
    self:getMyTotalMoney()

    if(self.m_roomInfo.buyChipsMax == self.m_roomInfo.buyChipsMin) then
        self.m_roomInfo.gameMinBuyin = self.m_roomInfo.buyChipsMax
    else
        if (TRUNK_VERSION==DEBAO_TRUNK) then
            self.m_roomInfo.gameMinBuyin = tableInfo.currentTableInfo.buyChipsMin --主站最小买入40BB
        else
            self.m_roomInfo.gameMinBuyin = tableInfo.currentTableInfo.buyChipsMin --腾讯最小买入100BB
        end
    end

    for i=1,#tableInfo.playerList do
        local eachPlayer = tableInfo.playerList[i]
        local seat = self:getSeat(eachPlayer.seatNo)
        if seat then
            seat.seatId     = eachPlayer.seatNo
            seat.roundChips = eachPlayer.roundChips --用户本轮下的筹码数
            seat.handChips  = eachPlayer.handChips  --用户总共下的筹码数
            seat.seatChips  = eachPlayer.userChips  --用户座位上的总钱数
            seat.userStatus = eachPlayer.userStatus
            seat.isTrustee  = eachPlayer.isTrustee
            seat.userId     = eachPlayer.userId
            seat.userName   = eachPlayer.userName
            seat.userSex    = eachPlayer.userSex
            seat.imageURL   = eachPlayer.imageURL
            seat.privilege  = eachPlayer.privilege
            seat.applyDelayTime = eachPlayer.applyDelayTime
            seat.keepSeatSTime = eachPlayer.keepSeatSTime
        
            --获取vip信息
            self:reqUserVipInfo(seat.userId)
        
            --分别填充玩家信息
            if(seat.userId == myInfo.data.userId) then
                self.m_myselfSeatId = seat.seatId
            end
        
            --界面玩家坐下
            self.m_pCallbackUI:playerSit_Callback(
                                          self:isMyseat(seat.seatId),
                                          self.m_roomInfo.tableId,
                                          seat.seatId,
                                          seat.userName,
                                          seat.userSex,
                                          seat.imageURL,
                                          seat.userId,
                                          seat.privilege)
        
            --更新筹码
            self.m_pCallbackUI:playerChipsUpdate_Callback(
                                                  self.m_roomInfo.tableId,
                                                  seat.seatId,
                                                  seat.handChips,
                                                  seat.roundChips,
                                                  seat.seatChips)
            
            if seat.keepSeatSTime then
                local stamp = os.time()-seat.keepSeatSTime
                if stamp>0 and 600-stamp>0 then
                    self.m_pCallbackUI:showTrusteeshipProtectCallback(self.m_roomInfo.tableId, seat.userId, self:isMyseat(seat.userId), 600-stamp)
                end
            end

            --自己超时显示我回来了别人超时暂离
            if seat.isTrustee then
                self.m_pCallbackUI:playerOperateBackSeat(self:isMyseat(seat.seatId),self.m_roomInfo.tableId,seat.seatId)
            end
        
            --显示自己牌
            if(self:isMyseat(seat.userId)) then
                if(tableInfo.playerMyInfo.pocketCards and #tableInfo.playerMyInfo.pocketCards == 2) then
                    --保存自己两张手牌
                    seat.pokerCard1 = tableInfo.playerMyInfo.pocketCards[1]
                    seat.pokerCard2 = tableInfo.playerMyInfo.pocketCards[2]
                    
                    --亮牌
                    if(seat.pokerCard1 ~= "" and seat.pokerCard2 ~= "") then
                        self.m_pCallbackUI:showPlayerCards_Callback(self.m_roomInfo.tableId,seat.seatId,seat.pokerCard1,seat.pokerCard2,false)
                        self.m_calcMyPokers:showHandCards(seat.pokerCard1,seat.pokerCard2)
                        local res = self.m_calcMyPokers:calc2Cards()
                        self.m_myBestCardType = res
                        if(res>GaoPai) then
                            self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,seat.seatId,self.m_calcMyPokers:getResult(res),self.m_myBestCardType)
                        end
                    end
                
                    --回收牌
                    local isTourneyAndTrust = (self.m_roomInfo.tableType == "TOURNEY" and seat.isTrustee) --锦标赛玩家被托管
                    if(seat.userStatus == PLAYER_STATE_FOLD) then
                        self.m_pCallbackUI:playerFold_Callback(true,isTourneyAndTrust,self.m_roomInfo.tableId,seat.seatId)
                    end
                end
                if self.m_pCallbackUI then
                    self.m_pCallbackUI:updateApplyDelayTime(self.m_roomInfo.tableId, eachPlayer.applyDelayTime)
                end
            elseif(seat.userStatus == PLAYER_STATE_PLAY  or
                seat.userStatus == PLAYER_STATE_ALLIN ) then
                --保存两张手牌
                seat.pokerCard1 = ""
                seat.pokerCard2 = ""

                self.m_pCallbackUI:showPlayerCards_Callback(self.m_roomInfo.tableId,seat.seatId,"","",false)
            end
        
            if (TRUNK_VERSION==DEBAO_TRUNK) then
                DBHttpRequest:getUserShowInfo(function(event) if self.httpResponse then self:httpResponse(event) end
                end,seat.userId,true)
        
                if(myInfo.data.activityId=="") then--如果没有获取到破产配置信息就再获取一次
                    DBHttpRequest:getRookieProtectionConfig(function(event) if self.httpResponse then self:httpResponse(event) end
                    end)
                end
            end
        end
    end
    --[[快速开始 playerMyInfo.isTrustee与用户列表里的不一致]]
    if(tableInfo.playerMyInfo.seatNo ~= -1) then
        local mySeat = self:getSeat(tableInfo.playerMyInfo.seatNo)
        if(mySeat and not mySeat.isTrustee and mySeat.userStatus ~= PLAYER_STATE_PLAY 
            and mySeat.pokerCard1=="" and mySeat.pokerCard2=="") then
            if self.m_childRoom then
                self.m_childRoom:promptWaitNextHand()
            else
                self:promptWaitNextHand()
            end
        end
    end

    --[[获取该牌桌的信息]]
    if self.m_childRoom then
        self.m_childRoom:showRoomInfo()  
    else
        self:showRoomInfo()  
    end
    
    --设置庄家位
    if(self.m_roomInfo.buttonNo>=0 and #tableInfo.playerList>0) then
        self.m_pCallbackUI:updateDealerPos_Callback(self.m_roomInfo.tableId, self.m_roomInfo.buttonNo,false)
    end
    --显示公牌
    for index=1,#tableInfo.currentTableInfo.communityCards do
        local cardValue = tableInfo.currentTableInfo.communityCards[index]
        self.m_pCallbackUI:showPublicCard_Callback(self.m_roomInfo.tableId,index-1,cardValue,false)
        self.m_myPreOperateOpt = -1
        self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
    end
    --放置奖池筹码
    self.m_roomInfo.pot = 0
    local potNum = #tableInfo.currentTableInfo.potInfo
    for i=1,potNum do
        local pot = tableInfo.currentTableInfo.potInfo[i]
        self.m_roomInfo.pot = self.m_roomInfo.pot + pot
        self.m_pCallbackUI:updatePublicPots_Callback(self.m_roomInfo.tableId,potNum,i-1,pot,false)
    end
    
    --旋转座位
    if(tableInfo.playerMyInfo.seatNo >= 0) then
        self.m_pCallbackUI:rotateAllSeats_Callback(self.m_roomInfo.tableId,tableInfo.playerMyInfo.seatNo)
    end
    
    --当前下注玩家
    if(tableInfo.currentTableInfo.waitForNo>=0) then
        local waitData = WaitForMSGData:new()
        waitData.m_sequence = self.m_roomInfo.sequence
        waitData.m_waitForNo = tableInfo.currentTableInfo.waitForNo
        waitData.m_remainTime = tableInfo.currentTableInfo.remainTime
        waitData.m_optionAction = tableInfo.currentTableInfo.m_optionAction
        self:dealWaitForMsgResp(waitData)
    end

    --提示当前桌子已满
    if(#tableInfo.playerList >= self.m_roomInfo.seatNum and self.m_myselfSeatId < 0) then
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                Lang_CurrentRoomNotSeat,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
        end
    end
    
    --计算成手牌亮自己牌
    if(#tableInfo.playerMyInfo.pocketCards>1 and self.m_myselfSeatId>=0) then
        local cardsNum = #tableInfo.currentTableInfo.communityCards
        if cardsNum == 3 then  --翻牌
            self.m_calcMyPokers:showFlopCards(tableInfo.currentTableInfo.communityCards[1],
                tableInfo.currentTableInfo.communityCards[2],
                tableInfo.currentTableInfo.communityCards[3])
            local res = self.m_calcMyPokers:calc5Cards()
            self.m_myBestCardType = res
            if(res > GaoPai) then
                self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,tableInfo.playerMyInfo.seatNo,self.m_calcMyPokers:getResult(res),res)
            end
        elseif cardsNum == 4 then  --转牌
            self.m_calcMyPokers:showFlopCards(tableInfo.currentTableInfo.communityCards[1],
                tableInfo.currentTableInfo.communityCards[2],
                tableInfo.currentTableInfo.communityCards[3])
            self.m_calcMyPokers:showTurnCards(tableInfo.currentTableInfo.communityCards[4])
            local res = self.m_calcMyPokers:calc6Cards()
            self.m_myBestCardType = res
            if(res > GaoPai) then
                self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,tableInfo.playerMyInfo.seatNo,self.m_calcMyPokers:getResult(res),res)
            end
        elseif cardsNum == 5 then  --河牌
            self.m_calcMyPokers:showFlopCards(tableInfo.currentTableInfo.communityCards[1],
                tableInfo.currentTableInfo.communityCards[2],
                tableInfo.currentTableInfo.communityCards[3])
            self.m_calcMyPokers:showTurnCards(tableInfo.currentTableInfo.communityCards[4])
            self.m_calcMyPokers:showRiverCards(tableInfo.currentTableInfo.communityCards[5])
            local res = self.m_calcMyPokers:calc7Cards()
            self.m_myBestCardType = res
            if(res > GaoPai) then
                self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,tableInfo.playerMyInfo.seatNo,self.m_calcMyPokers:getResult(res),res)
            end
        end
    end
    
    
    if (TRUNK_VERSION==DEBAO_TRUNK) then
        if not myInfo.data.requestPayRecord then
            DBHttpRequest:getUserChargeInfo(function(event) if self.httpResponse then self:httpResponse(event) end
            end)
        end
        if self.m_childRoom then
            self.m_childRoom:DebaoBuyin()
        else
            self:DebaoBuyin()
        end
    end

    DBHttpRequest:getFaces(function(event) if self.httpResponse then self:httpResponse(event) end
            end)
    UserConfig.enteredRoom = true


    --[[将牌桌数据传递到roomView]]
    self.m_buyTableInfo = nil
    self.m_buyTableInfo = {}
    self.m_buyTableInfo.tableId = self.m_roomInfo.tableId
    self.m_buyTableInfo.myChips = self:getMyTotalMoney()
    local min = self.m_roomInfo.buyChipsMin
    local max = self.m_roomInfo.originalBuyChipsMax

    -- if self.m_roomInfo.playType == "BIDA" then
    --     if self.m_roomInfo.buyinTimes>0 and self.m_roomInfo.buyinTimes<2 then
    --         max = self.m_roomInfo.originalBuyChipsMax*2
    --     elseif self.m_roomInfo.buyinTimes>1 and self.m_roomInfo.buyinTimes<3 then
    --         max = self.m_roomInfo.originalBuyChipsMax*4
    --     elseif self.m_roomInfo.buyinTimes>2 then
    --         max = self.m_roomInfo.originalBuyChipsMax*6
    --     end
    -- end

    self.m_roomInfo.buyChipsMax = max
    self.m_roomInfo.tmpBuyChipsMax = max
    self.m_buyTableInfo.min = min
    self.m_buyTableInfo.max = max
    self.m_buyTableInfo.originalBuyChipsMax = self.m_roomInfo.originalBuyChipsMax
    self.m_buyTableInfo.defaultValue = (max>=self.m_roomInfo.gameMinBuyin) and (self.m_roomInfo.gameMinBuyin) or (max)
    self.m_buyTableInfo.bigBlind = self.m_roomInfo.bigBlind
    self.m_buyTableInfo.payType = self.m_roomInfo.payType
    self.m_buyTableInfo.isAdd = true
    self.m_buyTableInfo.needShowAutoBuySign = false
    self.m_buyTableInfo.serviceCharge = self.m_roomInfo.serviceCharge
    self.m_pCallbackUI:updateBuyInfo(self.m_roomInfo.tableId, self.m_buyTableInfo)

    local value = tonumber(self.m_roomInfo.tableOwner)
    local tableType = self.m_roomInfo.tableType
    -- dump(tableType)
    -- dump(tableInfo.currentTableInfo)
    if string.find(tableType, "CASH") then
        if value and value>0 then
            self.m_isPrivateRoom = true
            DBHttpRequest:getDiyFidByTableId(function(event) if self.httpResponse then self:httpResponse(event) end
                end,self.m_roomInfo.tableId, true)
            local isOwner = false

            if value==tonumber(myInfo.data.userId) and self.m_roomInfo.payType == "VGOLD" then
                isOwner = true
            end
            if self.m_pCallbackUI then
                self.m_pCallbackUI:showPrivateRoomContent(self.m_roomInfo.tableId, true, isOwner, self.m_roomInfo.destroyTime)
            end        
        self:enterClub("CASH")
        end
    elseif string.find(tableType, "SITANDGO") then
        if self.m_pCallbackUI then
            self.m_pCallbackUI:showSngContent(self.m_roomInfo.tableId)
        end
        self:enterClub("SITANDGO")
    elseif string.find(tableType, "TOURNEY") then
        if string.find(self.m_roomInfo.payType, "POINT") then
            self.m_pCallbackUI:setTalkButtonVisible(self.m_roomInfo.tableId, true)
            self:enterClub("MTT")
        end
    end

    if string.find(self.m_roomInfo.payType, "POINT") then
        if self.m_pCallbackUI then
            self.m_pCallbackUI:setPayType(self.m_roomInfo.tableId, "POINT")
        end
    end
    -- dump(self.m_roomInfo.tableId)
end

function BaseRoom:setEnterClubOrNot(value)
    self.enterClubOrNot = value
end

function BaseRoom:enterClub(matchType)
    self.m_schedulerPool:delayCall(handler(self, function() 
            if not self.enterClubOrNot or tonumber(myInfo.data.userClubId) == 0 then         --判断是否组局成功
                QManagerPlatform:enterChatRoom({["callBack"] = function (data) self:enterGameRoomCallBack(data) end,["messageCount"]=1,["TargetId"]=self.m_roomInfo.tableId})
                return
            end
            if not myInfo.data.userClubId or myInfo.data.userClubId == 0 then
                return
            end
            
            QManagerPlatform:enterClub({["callBack"] = function (data,tag) self:enterRoomCallBack(data,{nType = "enterClub"}) end,["messageCount"] = 1,['targetId']=self.mTargetId})
        end), 1, "EnterClub")
end
function BaseRoom:enterGameRoomCallBack(data)
    -- dump(data)
    self.mEnterChatRoomTimes = (self.mEnterChatRoomTimes or 0) + 1
    if device.platform == "android" then
        data = json.decode(tostring(data))
    end
    if data and data.success then
        CMShowTip("你已进入聊天室")
    else
        if self.mEnterChatRoomTimes < 3 then
            QManagerPlatform:enterChatRoom({["callBack"] = function (data) self:enterGameRoomCallBack(data) end,["messageCount"]=1,["TargetId"]=self.m_roomInfo.tableId})
            return
        end
        CMShowTip("进入聊天室失败,请返回大厅后重新进入牌桌！")
    end
end
function BaseRoom:enterRoomCallBack(data,msgData)
    self.mEnterFailTimes = self.mEnterFailTimes or 0
    self.mEnterFailTimes = self.mEnterFailTimes + 1
    if device.platform == "android" then
        data = json.decode(data)
    end
    local nType = msgData.nType
    if nType == "enterClub" then
        if data.success then
            self:sendTableMsgToClub()
            self.mEnterFailTimes = 0
        else
            -- CMShowTip("进入房间失败,错误代码为"..data.status)
            if self.mEnterFailTimes < 3 then
                self.m_schedulerPool:delayCall(handler(self, self.enterClub), 1, "EnterClub")
            else
                CMShowTip("进入房间失败")
                QManagerPlatform:quitClubRoom({['TargetId']=self.mTargetId})
                CMDelay(self,0.5,function () QManagerPlatform:enterChatRoom({["TargetId"]=self.m_roomInfo.tableId,["callBack"] = function (data) self:enterGameRoomCallBack(data) end,["messageCount"]=1,}) end)
            end
        end
    elseif nType == "tableMsg" then
        if data.success then
            CMShowTip("房间创建信息已在战队聊天面板显示")
        else
            CMShowTip("房间创建信息发送聊天面板失败")
        end
        QManagerPlatform:quitClubRoom({['TargetId']=self.mTargetId})
        CMDelay(self,0.5,function () QManagerPlatform:enterChatRoom({["TargetId"]=self.m_roomInfo.tableId,["callBack"] = function (data) self:enterGameRoomCallBack(data) end,["messageCount"]=1,}) end)
    end
    
end

--[[发送牌桌消息给战队]]
function BaseRoom:sendTableMsgToClub()
    -- if not myInfo.data.userClubId or myInfo.data.userClubId == 0 then
    --     return
    -- end

    local gameId = self.m_roomInfo.tableId
    local tableName = self.m_roomInfo.tableName
    local playType = self.m_roomInfo.playType
    local tableTime = self.m_roomInfo.destroyTime
    local tableMang = self.m_roomInfo.smallBlind .."/" .. self.m_roomInfo.bigBlind
    local tableOwner = self.m_roomInfo.tableOwner
    local tableType  = self.m_roomInfo.tableType
    local content   = string.format("%s;%s;%s;%s;%s;%s;%s",gameId,tableName,playType,tableTime,tableMang,tableOwner,tableType)   
    local msgData = {targetId=self.mTargetId,content=content,userId=myInfo.data.userId or "1234",nType="tableMsg"}
    -- dump(msgData,"sendTableMsgToClub")
    local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
    QManagerPlatform:sendMessage(msg)
    -- OCCallLuaFunc(msgData)
end

--[[正在等待谁（座位号用户id等）操作（或者什么事件）]]
function BaseRoom:dealWaitForMsgResp(dataModel)
    -- normal_info_log("BaseRoom:dealWaitForMsgResp".."正在等待谁（座位号用户id等）操作（或者什么事件）待完善")
    
    local data = dataModel
    self.m_roomInfo.sequence  = data.m_sequence
    local waitId           = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_waitForNo)
    local remainTime       = data.m_remainTime
    local callNum       = data.m_optionAction.m_call      --跟注数
    -- dump(callNum)
    local roundChip = 0
    local roundChipsVec = {}
    for i=1,#self.m_seatsArray do
        local seat = self.m_seatsArray[i]
        if(seat.seatId ~= -1) then
            roundChip = roundChip + seat.roundChips
            roundChipsVec[#roundChipsVec+1] = seat.roundChips
        end
    end
    
    local seat = self:getSeat(waitId)
    local mySeat = self:getSeat(myInfo.data.userId)
    if(not seat or not self.m_pCallbackUI or data.m_optionAction.m_raise==nil or #data.m_optionAction.m_raise<2) then
        return
    end
    -- dump(callNum+seat.roundChips-mySeat.roundChips)
    local serverRaise = data.m_optionAction.m_raise[1]
    
    local isMyself        =  self:isMyseat(waitId)--是不是轮到自己操作
    if self:myselfIsPlaying() and not self.m_bIsMyselfAllin then
        local needNum = callNum+seat.roundChips-mySeat.roundChips
        if needNum>tonumber(mySeat.seatChips) then
            needNum = tonumber(mySeat.seatChips)
        end
        if not self.m_roomInfo.hasAllIn then
            self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, needNum)
        end
        self.m_roomInfo.hasAllIn = false
    end
    self.m_pCallbackUI:waitForPlayerActioning_Callback(isMyself,self.m_roomInfo.tableId,seat.seatId,remainTime,self.m_roomInfo.gameSpeed,callNum,self.m_myselfSeatId)
    
    if(isMyself) then
    
        -- -1 没有预选
        -- 0  弃牌
        -- 1  看或弃
        -- 2  跟任何注
--        4 check
--        5 call
--        如果上一轮有人raise了   清除选择框
    -- if #roundChipsVec>0 then
    --     if callNum>roundChipsVec[#roundChipsVec] then
    --         if self.m_myPreOperateOpt == 5 then
    --             self.m_myPreOperateOpt = -1
    --             self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
    --         end
    --     end     
    -- end
        --如果自己之前有预选操作
        if(self.m_myPreOperateOpt ~= -1) then
             self.m_pCallbackUI:hideOperateDelayMenu(self.m_roomInfo.tableId)
            if(self.m_myPreOperateOpt == 0) then
            
                self:reqMyFoldPocker()
            elseif(self.m_myPreOperateOpt == 1) then
            
                if(callNum <= 0) then
                    self:reqMyCheckPoker()
                else
                    self:reqMyFoldPocker()
                end
            elseif(self.m_myPreOperateOpt == 2) then
            
                if(callNum <= 0) then
                    self:reqMyCheckPoker()
                elseif(callNum >= seat.seatChips) then
                    self:reqMyAllIn()
                else
                    self:reqMyCallPocker()
                end
            elseif (self.m_myPreOperateOpt == 4) then
                if (callNum <= 0) then
                    self:reqMyCheckPoker()
                else
                    if(seat.isTrustee) then
                    
                        self.m_pCallbackUI:playerOperateBackSeat(true,self.m_roomInfo.tableId,seat.seatId)
                        
                        self.m_myWaitForData = nil
                        self.m_myWaitForData = data
                    else
                    
                        local raiseMax = seat.seatChips + seat.roundChips
                        local raiseMin = (serverRaise >= raiseMax) and raiseMax or serverRaise
                        
                        if(callNum<=0) then
                            self.m_pCallbackUI:playerFoldCheckRaise(self.m_roomInfo.tableId,raiseMin,raiseMax,self.m_roomInfo.bigBlind,self.m_roomInfo.pot + roundChip + callNum,callNum + seat.roundChips) --界面看牌面板
                        elseif(callNum < raiseMin) then
                        
                            callNum = (callNum < seat.seatChips) and callNum or seat.seatChips
                            self.m_pCallbackUI:playerFoldCallRaise(self.m_roomInfo.tableId,callNum,raiseMin,raiseMax,self.m_roomInfo.bigBlind,self.m_roomInfo.pot + roundChip + callNum,callNum + seat.roundChips) --界面加注面板
                        else
                        
                            callNum = (callNum < seat.seatChips) and callNum or seat.seatChips
                            self.m_pCallbackUI:playerFoldCallAllin(self.m_roomInfo.tableId,callNum)   --界面Allin面板
                        end
                        
                        self:showOperateGuideBubble()
                    end
                end
            elseif(self.m_myPreOperateOpt == 5) then
                self:reqMyCallPocker()
            end
            --使用完了清除
            self.m_myPreOperateOpt = -1
            self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
            
            self.m_roomInfo.isFirstRound = false
        else
            if(seat.isTrustee) then
            
                self.m_pCallbackUI:playerOperateBackSeat(true,self.m_roomInfo.tableId,seat.seatId)
                
                self.m_myWaitForData = nil
                self.m_myWaitForData = data
            else
            
--                
                local raiseMax = seat.seatChips + seat.roundChips
                local raiseMin = (serverRaise >= raiseMax) and raiseMax or serverRaise
                
                if(callNum<=0) then
                    self.m_pCallbackUI:playerFoldCheckRaise(self.m_roomInfo.tableId,raiseMin,raiseMax,self.m_roomInfo.bigBlind,self.m_roomInfo.pot + roundChip + callNum,callNum + seat.roundChips) --界面看牌面板
                elseif(callNum < raiseMin) then
                
                    callNum = (callNum < seat.seatChips) and callNum or seat.seatChips
                    self.m_pCallbackUI:playerFoldCallRaise(self.m_roomInfo.tableId,callNum,raiseMin,raiseMax,self.m_roomInfo.bigBlind,self.m_roomInfo.pot + roundChip + callNum,callNum + seat.roundChips) --界面加注面板
                else
                
                    callNum = (callNum < seat.seatChips) and callNum or seat.seatChips
                    self.m_pCallbackUI:playerFoldCallAllin(self.m_roomInfo.tableId,callNum)   --界面Allin面板
                end
                
                self:showOperateGuideBubble()

            end
        end
    else
    
        -- --等待别人的时候：在座位上并且没有被托管
        -- local mySeat = self:getSeat(self.m_myselfSeatId) --自己有坐下且在玩
        -- if(mySeat and not mySeat.isTrustee and mySeat.userStatus == PLAYER_STATE_PLAY) then
        
        --     self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId)
        -- end
    end


end

--[[玩家离开座位站起]]
function BaseRoom:dealTableLeaveResp(dataModel)
    
    local data = dataModel
    local userId = data.m_userId
    local isMyself = self:isMyseat(userId)
    if(isMyself) then
        self.m_myselfSeatId = -1
    end
    --取消派奖定时器
    self:stopPrize()
    
    if(self.m_pCallbackUI) then
        self.m_pCallbackUI:leaveTable_Callback(isMyself,data.m_tableId,self.m_leaveRoomType)
    end
end





function BaseRoom:dealTableDestroy(dataModel)
    local flag = self.m_isPrivateRoom
    if(self.m_pCallbackUI) then
        self.m_pCallbackUI:leaveTable_Callback(true,dataModel.tableId,LEAVE_ROOM_TO_QUITROOM)
    end
    local data = dataModel
    if flag and self.m_pCallbackUI then

        -- self.m_pCallbackUI:showFinalStatics(data.tableId)
        -- cc.UserDefault:getInstance():setIntegerForKey("SHOW_FINAL_STATICS"..myInfo.data.userId, 1)
        -- cc.UserDefault:getInstance():setIntegerForKey("FINAL_STATICS_ID"..myInfo.data.userId, data.tableId)
        -- cc.UserDefault:getInstance():flush()
        -- return
        -- CMOpen(require("app.GUI.dialogs.FinalStaticsDialog"), cc.Director:getInstance():getRunningScene(), 
        --     {m_tableId = data.tableId}, true, 1001)

        SHOW_FINAL_STATICS = data.tableId
    end
end

--取消托管回应
function BaseRoom:dealCancelTrusteeShipResp(dataModel)

    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_seatNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end
    seat.isTrustee = false
    
    self.m_pCallbackUI:playerCancelTrustee_Callback(self.m_roomInfo.tableId, self:isMyseat(seat.seatId), seat.seatId)
    
    --如果有轮到我操作的数据
    if(self:isMyseat(seat.seatId)  and  self.m_myWaitForData) then
    
        self.m_roomInfo.sequence           = self.m_myWaitForData.m_sequence
        local waitId           = self.m_myWaitForData.m_waitForNo
        local remainTime       = self.m_myWaitForData.m_remainTime
        local callNum       = self.m_myWaitForData.m_optionAction.m_call      --跟注数
        
        local roundChip = 0
        for i=1,#self.m_seatsArray do
        
            local seat = self.m_seatsArray[i]
            if(seat.seatId ~= - 1) then
            
                roundChip = roundChip + seat.roundChips
            end
        end
        
        local seat = self:getSeat(waitId)
        if(not seat or not self.m_pCallbackUI or #self.m_myWaitForData.m_optionAction.m_raise<2)  then
            self.m_myWaitForData = nil
            
            return 
        end
        
        self.m_pCallbackUI:waitForPlayerActioning_Callback(true,self.m_roomInfo.tableId,seat.seatId,remainTime,self.m_roomInfo.gameSpeed)
        
        local serverRaise = self.m_myWaitForData.m_optionAction.m_raise[1]
        local raiseMax = seat.seatChips + seat.roundChips
        local raiseMin = (serverRaise >= raiseMax) and raiseMax or serverRaise
        
        if(callNum<=0) then
            self.m_pCallbackUI:playerFoldCheckRaise(self.m_roomInfo.tableId,raiseMin,raiseMax,self.m_roomInfo.bigBlind,self.m_roomInfo.pot + roundChip + callNum,callNum + seat.roundChips) --界面看牌面板
        elseif(callNum < raiseMin) then
        
            callNum = (callNum < seat.seatChips) and callNum or seat.seatChips
            self.m_pCallbackUI:playerFoldCallRaise(self.m_roomInfo.tableId,callNum,raiseMin,raiseMax,self.m_roomInfo.bigBlind,self.m_roomInfo.pot + roundChip,callNum + seat.roundChips) --界面加注面板
        
        else
        
            callNum = (callNum < seat.seatChips) and callNum or seat.seatChips
            self.m_pCallbackUI:playerFoldCallAllin(self.m_roomInfo.tableId,callNum)   --界面Allin面板
        end
        
        self.m_myWaitForData = nil
        
        
        if self.m_childRoom then
            self.m_childRoom:showOperateGuideBubble()
        else
            self:showOperateGuideBubble()
        end
    end
end

--设置亮牌
function BaseRoom:dealShowDownResp(dataModel)

    self.m_roomInfo.tableStatus = TABLE_STATE_SHOWDOWN
    local seat  = self:getSeat(self.m_myselfSeatId)
    if(not seat or not self.m_pCallbackUI or seat.isTrustee) then
        return
    end
    if(UserDefaultSetting:getInstance():needShowDown()) then
    
        self.m_pCallbackUI:waitForPlayerShowDown_Callback(self.m_roomInfo.tableId,self.m_myselfSeatId,seat.pokerCard1,seat.pokerCard2)
    end
end

--addon返回消息,如果返回成功1,则不处理,交由tcp消息接收ADDON_FINISH后处理addon,如果发回其他失败,则弹出错误
function BaseRoom:dealAddOnResp(strJson)
    local code = strJson+0
    if (code ~= 1) then
        local str = "最终加码失败not " .. strJson
        self.m_pCallbackUI:showRebuyResult_Callback(self.m_roomInfo.tableId, str, false)
    end
end

--发手牌
function BaseRoom:dealPocketCardResp(dataModel)
    -- dump("BaseRoom:dealPocketCardResp")

    if(not self.m_pCallbackUI or self.m_roomInfo.sBlindNo<0) then
        return
    end
    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    
    self.m_roomInfo.tableStatus = TABLE_STATE_HAND
    self.m_roomInfo.isFirstRound = true
    --发牌
    local seat = nil
    
    local countNums = 0                    --计数 共发了多少张牌
    for i=0,1 do           --分两圈发牌
    
        local j = self.m_roomInfo.sBlindNo+0 --从庄家开始发牌
        while true do
        
            seat = self:getSeat(j)
            if(seat  and  seat.userStatus == PLAYER_STATE_PLAY) then --如果这个座位上有人且在玩
            
                local isMyselfCard = ((data.m_seatNo >=0 )  and  self:isMyseat(seat.seatId+0))
            
                if(isMyselfCard) then
                    self.m_pCallbackUI:dispatchPlayerCards_Callback(self.m_roomInfo.tableId,j,i,countNums*0.2,data.m_pocketCards[i+1])
                else
                    self.m_pCallbackUI:dispatchPlayerCards_Callback(self.m_roomInfo.tableId,j,i,countNums*0.2,"")
                end
                countNums=countNums+1
            end
            j=j+1            --下移一位
            j=j%self.m_roomInfo.seatNum  --如果超过总桌子数 从0开始

            if(j == self.m_roomInfo.sBlindNo) then--从庄家开始 遍历到再次移到庄家结束
                break
            end
        end   
    end
    

    --给自己亮牌
    if(self:myselfHasCards() and #data.m_pocketCards>1) then
        
        self.m_calcMyPokers:showHandCards(data.m_pocketCards[1],data.m_pocketCards[2])
        local res = self.m_calcMyPokers:calc2Cards()
        self.m_myBestCardType = res
      
        if(res > GaoPai) then
            self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,self.m_myselfSeatId,self.m_calcMyPokers:getResult(res),res)
        end
    end
    
    --保存手牌
    seat = nil
    for i=1,#self.m_seatsArray do
    
        seat = self.m_seatsArray[i]
        if(seat.userId == data.m_user_id) then
        
            local nSize = #data.m_pocketCards
            seat.pokerCard1 = (nSize == 2) and data.m_pocketCards[1] or ""
            seat.pokerCard2 = (nSize == 2) and data.m_pocketCards[2] or ""
        
        else
        
            seat.pokerCard1 = ""
            seat.pokerCard2 = ""
        end
    end
end

--[[
 _TABLE_NOTFOUND_ERROR_      = -11002      # 不存在的赛桌
 _NOT_ACT_TABLE_TYPE_ERROR_  = -11017      # 不允许玩家操作的赛桌类型
 _NOTEXSIT_SEAT_ERROR_       = -11011      # 不存在的座位号
 _SITED_PLAYER_ERROR_        = -11018      # 已经在该桌入座的玩家
 _ONLINE_IP_TOO_MANY_        = -11060      #同桌在线ip人数过多（手机应该没有这个）
 _HAS_SEATED_POS_ERROR_      = -11014      # 该座位号已经有玩家
 _PLAYING_SIT_ERROR_         = -11019      # 在玩玩家离开不允许本手再次入座
 还有一个权限验证失败的错误码（无权限）：  在赛事那边定义的
 
 
 #如果调用快速开始走TCP协议，找座位失败，会返回这个
 _FAST_SIT_ERROR_            = -12001      #新快速入座错误
]]
--新人坐下
function BaseRoom:dealSitResp(dataModel)
    -- dump("==========BaseRoom:dealSitResp===========")
    local data = dataModel
    data.m_sitNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_sitNo)

    local seat = self:getSeat(data.m_sitNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end
    local isMyself = self:isMyseat(data.m_userId)
    -- dump(data.m_code)
    if(data.m_code == 10000) then
    
        seat.seatId = data.m_sitNo
        seat.roundChips        = 0
        seat.userStatus        = PLAYER_STATE_REMAIN
        seat.isTrustee     = false
        seat.seatChips     = data.m_userChip
        seat.userId            = data.m_userId
        seat.userName      = data.m_userName
        seat.userSex           = data.m_userSex
        seat.imageURL      = data.imageURL
        seat.privilege     = data.privilege
        
        --获取vip信息
        self:reqUserVipInfo(seat.userId)
        
        if (TRUNK_VERSION==DEBAO_TRUNK) then
            DBHttpRequest:getUserShowInfo(function(event) if self.httpResponse then self:httpResponse(event) end
            end,seat.userId,true)
        end
    
        if(isMyself) then
            self.m_myselfSeatId = seat.seatId
            -- print("+++++++++++++++++++++++++++++++++")
            -- print(self.m_myselfSeatId)
            -- print("+++++++++++++++++++++++++++++++++")
            if self.m_childRoom then
                self.m_childRoom:promptWaitNextHand()
            else
                self:promptWaitNextHand()
            end
            
        end

        --界面坐下
        self.m_pCallbackUI:playerSit_Callback(
                                          self:isMyseat(seat.seatId),
                                          self.m_roomInfo.tableId,
                                          seat.seatId,
                                          seat.userName,
                                          seat.userSex,
                                          seat.imageURL,
                                          seat.userId,
                                          seat.privilege)
        
        --更新筹码
        self.m_pCallbackUI:playerChipsUpdate_Callback(
                                                  self.m_roomInfo.tableId,
                                                  seat.seatId,
                                                  seat.handChips,
                                                  seat.roundChips,
                                                  seat.seatChips)
        
        if(isMyself) then
        
            --旋转大家座位
            self.m_pCallbackUI:rotateAllSeats_Callback(self.m_roomInfo.tableId,seat.seatId)
            
            if self.m_roomInfo.playType == "BIDA" then
                self.m_roomInfo.buyinTimes = data.buyinTimes or 0
                if self.m_roomInfo.buyinTimes>0 and self.m_roomInfo.buyinTimes<2 then
                    self.m_roomInfo.buyChipsMax = self.m_roomInfo.originalBuyChipsMax*2
                elseif self.m_roomInfo.buyinTimes>1 and self.m_roomInfo.buyinTimes<3 then
                    self.m_roomInfo.buyChipsMax = self.m_roomInfo.originalBuyChipsMax*4
                elseif self.m_roomInfo.buyinTimes>2 then
                    self.m_roomInfo.buyChipsMax = self.m_roomInfo.originalBuyChipsMax*6
                end
            end
            -- dump(self.m_roomInfo.buyinTimes)
            --记录本房间本人的最小最大买入
            self.m_roomInfo.tmpBuyChipsMin = data.m_buyMinChips

            self.m_roomInfo.tmpBuyChipsMax = data.m_buyMaxChips
            if self.m_roomInfo.tmpBuyChipsMax<self.m_roomInfo.buyChipsMax then
                self.m_roomInfo.tmpBuyChipsMax=self.m_roomInfo.buyChipsMax
            end
            
            if(self.m_isQuickStart) then
            
                if(self:getMyTotalMoney()>=self.m_roomInfo.buyChipsMin) then
                
                    local minBuyNum = (self.m_roomInfo.gameMinBuyin>self.m_roomInfo.tmpBuyChipsMin) and
                    (self.m_roomInfo.gameMinBuyin) or self.m_roomInfo.tmpBuyChipsMin
                    
                    self.m_myBuyChipsNum = (self:getMyTotalMoney()>= minBuyNum) and 
                    minBuyNum or self:getMyTotalMoney()
                    if self.m_childRoom then
                        self.m_childRoom:buyin(self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,false)
                    else
                        self:buyin(self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,false)
                    end

                else
                
                    --提示钱不够
                    local bQuickStartAble =  (self:getMyTotalMoney()) >= myInfo.data.brokeMoney
                    self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                                                    bQuickStartAble and Lang_LESS_MINBUYIN or Lang_BANKRUPT_MINBUYIN,
                                                                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                                                    true,
                                                                    false,
                                                                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM)
                    
                end
                self.m_isQuickStart=false
            else
            
                --显示购买对话框
                if self.m_childRoom then
                    self.m_childRoom:callBuyDialog(false)
                else
                    self:callBuyDialog(false)
                end
                self.m_bfirstSitAndBuy = false
            end
        end
    elseif(isMyself) then
        local tip
        if(data.m_code==-11011) then
        
            tip=Lang_SitErrorSeat..""
        elseif(data.m_code==-11014) then
        
            tip=Lang_SeatHasPlayer
        elseif(data.m_code==-11018) then
        
            tip=Lang_AlreadyInTableSeat
        elseif(data.m_code==-11019) then
        
            tip=Lang_CurrentRoundEndCanSit
        else
        
            tip=Lang_NextRoundCanSit
        end
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,tip,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
        end
    end
    
end

--玩家站起
function BaseRoom:dealSitOutResp(dataModel)
   
    local data = dataModel
    data.m_sitNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_sitNo)

    local seat = self:getSeat(data.m_userId)
  
    if(not seat or not self.m_pCallbackUI) then
        return
    end

    local isMyself = self:isMyseat(seat.userId)
    
    if(isMyself) then
        if self.m_roomInfo.payType == "POINT" then
            self:setMyDebaoDiamond(self:getMyTotalMoney()+seat.seatChips)
        else
            self:setMyTotalMoney(self:getMyTotalMoney()+seat.seatChips)--把自己的钱加回去
        end
        self.m_myselfSeatId = -1
        self.m_myBestCardType = -1
        if(self.m_isQuitRoom) then --是否退出房间
            self:reqMyLeaveTable(false,self.m_leaveRoomType)
        end
        --新手引导
        self.m_pCallbackUI:showNewerGuideActionHint(self.m_roomInfo.tableId,kNGCNone,kOBOHNone)
    end
    
    self.m_pCallbackUI:playerSitOut_Callback(isMyself,self.m_myselfSeatId>=0,self.m_roomInfo.tableId,seat.seatId)
    
    seat:standup()
end

--跟注消息
function BaseRoom:dealCallResp(dataModel)

    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_seatNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end
    seat.roundChips          = seat.roundChips+data.m_betChips  --下注（加注）筹码数
    seat.handChips           = data.m_betChips --这一圈的下的筹码数
    seat.seatChips           = data.m_userChips --座位上的钱数
    
    self.m_pCallbackUI:playerCall_Callback(self:isMyseat(seat.seatId),
        self.m_roomInfo.tableId,data.m_seatNo,data.m_betChips,seat.roundChips,data.m_userChips)
    
    if self:myselfIsPlaying() and not self.m_bIsMyselfAllin then
        -- self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, seat.roundChips - self:getSeat(myInfo.data.userId).roundChips)
    end
end
--加注消息
function BaseRoom:dealRaiseResp(dataModel)
    -- dump("====================> 加注消息")
    local data = dataModel
    data.m_sitNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_sitNo)
    local seat = self:getSeat(data.m_sitNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end
    seat.roundChips = seat.roundChips+data.m_betChips  --下注（加注）筹码数
    seat.handChips = data.m_betChips  --这一圈的下的筹码数
    seat.seatChips = data.m_userChips --座位上的钱数
    
    self.m_pCallbackUI:playerRaise_Callback(self:isMyseat(seat.seatId),
        self.m_roomInfo.tableId,data.m_sitNo,data.m_betChips,seat.roundChips,data.m_userChips, self.m_bIsRaisedInTheRound)

    self.m_bIsRaisedInTheRound = true
     if self:myselfIsPlaying() and not self.m_bIsMyselfAllin then
        local tmpChips = seat.roundChips - self:getSeat(myInfo.data.userId).roundChips
        if tmpChips > self:getSeat(myInfo.data.userId).seatChips then
            tmpChips = self:getSeat(myInfo.data.userId).seatChips
        end

        -- self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, tmpChips)
    end
end
--AllIn
function BaseRoom:dealAllInResp(dataModel)
    -- dump("============dealAllInResp=============")
    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_seatNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end
    seat.roundChips = seat.roundChips+data.m_betChips  --下注（加注）筹码数
    seat.handChips = data.m_betChips  --这一圈的下的筹码数
    seat.seatChips = data.m_userChips  --座位上的钱数
    seat.userStatus = PLAYER_STATE_ALLIN
    
    self.m_pCallbackUI:playerAllin_Callback(self:isMyseat(seat.seatId),
        self.m_roomInfo.tableId,seat.seatId,data.m_betChips,seat.roundChips,data.m_userChips)
    
    if self:myselfIsPlaying() then
        local tmpChips = seat.roundChips - self:getSeat(myInfo.data.userId).roundChips
        if tmpChips<0 then
            tmpChips = 0
        end
        if tmpChips > self:getSeat(myInfo.data.userId).seatChips then
            tmpChips = self:getSeat(myInfo.data.userId).seatChips
        end
        if not self:isMyseat(seat.seatId) then
            self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, tmpChips)
        end
    end

    if(self:myselfHasCards()) then
        self.m_roomInfo.hasAllIn = true
        self.m_bIsMyselfAllin = true
    end
end
--弃牌
function BaseRoom:dealFoldResp(dataModel)

    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_seatNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end
    seat.userStatus = PLAYER_STATE_FOLD
    if(self:isMyseat(seat.seatId)) then
    
        self.m_myBestCardType = -1
        self.m_myWaitForData = nil
        
    end
    
    if(self:isMyseat(seat.seatId)) then
        self.m_pCallbackUI:hideOperateBoard(self.m_roomInfo.tableId)
    end
    --回收牌
    local isTourneyAndTrust = (self.m_roomInfo.tableType == "TOURNEY"  and  seat.isTrustee) --锦标赛玩家被托管
    self.m_pCallbackUI:playerFold_Callback(self:isMyseat(seat.seatId),
        isTourneyAndTrust,self.m_roomInfo.tableId,seat.seatId)
end
--看牌
function BaseRoom:dealCheckResp(dataModel)

    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_seatNo)
    if(not seat) then
        return
    end
    if(self:isMyseat(seat.seatId)) then
        self.m_myWaitForData = nil
        
    end
    --看牌
    self.m_pCallbackUI:playerCheck_Callback(self:isMyseat(seat.seatId),
        self.m_roomInfo.tableId,data.m_seatNo)

    if self:myselfIsPlaying() and not self.m_bIsMyselfAllin then
        -- self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, 0)
    end
end
--这手牌局开始 gameStart
function BaseRoom:dealHandStartResp(dataModel)
    -- normal_info_log("BaseRoom:dealHandStartResp")
    if(not self.m_pCallbackUI) then 
        return
    end
    local tableInfo = dataModel
    
    -- self.m_pCallbackUI:setApplyPublicCardVisible(self.m_roomInfo.tableId, false)
    self:stopPrize()
    --牌局清理
    self.m_pCallbackUI:clearAllPlayerCards_Callback(self.m_roomInfo.tableId)
    self.m_bIsRaisedInTheRound = false--清空加注标志
    --填充桌子信息
    self.m_roomInfo.payType         = tableInfo.currentTableInfo.payType
    self.m_roomInfo.tableId         = tableInfo.currentTableInfo.tableId
    self.m_roomInfo.tableType       = tableInfo.currentTableInfo.tableType
    self.m_roomInfo.sequence        = tableInfo.currentTableInfo.sequence
    self.m_roomInfo.tableStatus     = tableInfo.currentTableInfo.gameStatus
    self.m_roomInfo.smallBlind      = tableInfo.currentTableInfo.smallBlind
    self.m_roomInfo.bigBlind        = tableInfo.currentTableInfo.bigBlind
    self.m_roomInfo.buttonNo        = tableInfo.currentTableInfo.dealerNo
    self.m_roomInfo.sBlindNo        = tableInfo.currentTableInfo.sBlindNo
    self.m_roomInfo.bBlindNo        = tableInfo.currentTableInfo.bBlindNo
    self.m_roomInfo.buyChipsMin     = tableInfo.currentTableInfo.buyChipsMin
    self.m_roomInfo.originalBuyChipsMax     = tableInfo.currentTableInfo.buyChipsMax
    self.m_roomInfo.buyChipsMax     = tableInfo.currentTableInfo.buyChipsMax
    self.m_roomInfo.gameSpeed       = tableInfo.currentTableInfo.gameSpeed
    self.m_roomInfo.tmpBuyChipsMin  = tableInfo.playerMyInfo.buyChipsMin

    self.m_roomInfo.tmpBuyChipsMax  = tableInfo.playerMyInfo.buyChipsMax
    
    self.m_roomInfo.handId          = tableInfo.currentTableInfo.handId
    -- dump(tableInfo.playerMyInfo.buyinTimes)
    if self.m_roomInfo.playType == "BIDA" then
        self.m_roomInfo.buyinTimes = tableInfo.playerMyInfo.buyinTimes or 0
    end
    
    if(self.m_roomInfo.buyChipsMax == self.m_roomInfo.buyChipsMin) then
        self.m_roomInfo.gameMinBuyin = self.m_roomInfo.buyChipsMax
    else
        if (TRUNK_VERSION==DEBAO_TRUNK) then
            self.m_roomInfo.gameMinBuyin    = tableInfo.currentTableInfo.buyChipsMin --主站最小买入40BB
        else
            self.m_roomInfo.gameMinBuyin    = tableInfo.currentTableInfo.buyChipsMin --腾讯最小买入100BB
        end
    end
    
    for i=1,#tableInfo.playerList do
        --分别填充座位信息
        local eachPlayer = tableInfo.playerList[i]
        local seat = self:getSeat(eachPlayer.seatNo)
        if(not seat) then
            
        else
            seat.seatId     = eachPlayer.seatNo
            seat.roundChips = eachPlayer.roundChips
            seat.userStatus = eachPlayer.userStatus
            seat.isTrustee  = eachPlayer.isTrustee
            --分别填充玩家信息
            seat.userId   = eachPlayer.userId
            seat.userName = eachPlayer.userName
            seat.userSex    = eachPlayer.userSex
            seat.seatChips= eachPlayer.userChips
            seat.imageURL = eachPlayer.imageURL
        
            self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
        end
    end
    self.m_roomInfo.pot = 0
    self.m_roomInfo.comunityCard = nil
    self.m_roomInfo.isFirstRound = true
    self.m_roomInfo.hasAllIn = false
    self.m_bIsMyselfAllin = false
    self.m_bGreatThanThree = false
    self.m_myPreOperateOpt = -1
    self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
    self:showRoomInfo()


    self.m_buyTableInfo.myChips = self:getMyTotalMoney()
    local min = self.m_roomInfo.buyChipsMin
    local max = self.m_roomInfo.originalBuyChipsMax
    if self.m_roomInfo.playType == "BIDA" then
        if self.m_roomInfo.buyinTimes>0 and self.m_roomInfo.buyinTimes<2 then
            max = self.m_roomInfo.originalBuyChipsMax*2
        elseif self.m_roomInfo.buyinTimes>1 and self.m_roomInfo.buyinTimes<3 then
            max = self.m_roomInfo.originalBuyChipsMax*4
        elseif self.m_roomInfo.buyinTimes>2 then
            max = self.m_roomInfo.originalBuyChipsMax*6
        end
    end
    self.m_roomInfo.buyChipsMax = max
    if self.m_roomInfo.tmpBuyChipsMax and self.m_roomInfo.tmpBuyChipsMax<max then
        self.m_roomInfo.tmpBuyChipsMax = max
    end
    self.m_buyTableInfo.min = min
    self.m_buyTableInfo.max = max
    self.m_buyTableInfo.defaultValue = (max>=self.m_roomInfo.gameMinBuyin) and (self.m_roomInfo.gameMinBuyin) or (max)
    self.m_pCallbackUI:updateBuyInfo(self.m_roomInfo.tableId, self.m_buyTableInfo)
end
--翻牌
function BaseRoom:dealFlopCardsResp(dataModel)
    self.m_roomInfo.tableStatus = TABLE_STATE_FLOP
    self.m_roomInfo.isFirstRound = true
    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    self.m_bIsRaisedInTheRound = false--清空加注标志
    
    for index=1,#data.m_communityCards do
    
        local cardValue = data.m_communityCards[index]
        self.m_pCallbackUI:showPublicCard_Callback(self.m_roomInfo.tableId,index-1,cardValue,true)
        self.m_myPreOperateOpt = -1
        self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
    end
    
    --给自己亮牌
    if(self:myselfHasCards()) then
    
        self.m_calcMyPokers:showFlopCards(data.m_communityCards[1],data.m_communityCards[2],data.m_communityCards[3])
        local res = self.m_calcMyPokers:calc5Cards()
        self.m_myBestCardType = res
        local maxIndex = {}
        maxIndex = self.m_calcMyPokers:getResult(res)
        if(res > GaoPai) then
            self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,self.m_myselfSeatId,maxIndex,res)
        end
        self.m_bGreatThanThree = false
        if(res > SanTiao) then
        
            self.m_bGreatThanThree = true
        elseif(res == SanTiao) then
        
            for i=1,#maxIndex do
            
                if(maxIndex[i] == 0 or maxIndex[i] == 1) then
                    self.m_bGreatThanThree = true
                end
                break
            end
        end
        
    end
    
    for i=0,self.m_roomInfo.seatNum-1 do
    
        local seat = self:getSeat(i)
        if(not seat) then
            
        else
            seat.roundChips = 0
            seat.handChips = 0
        end
    end
    
    --保存公共牌
    self.m_roomInfo.comunityCard = data.m_communityCards
end

--转牌
function BaseRoom:dealTurnCardResp(dataModel)

    self.m_roomInfo.tableStatus = TABLE_STATE_TURN
    self.m_roomInfo.isFirstRound = true
    if(not self.m_pCallbackUI) then
        return
    end
    self.m_bIsRaisedInTheRound = false--清空加注标志
    local data = dataModel
    
    for index=1,#data.m_communityCards do
    
        local cardValue = data.m_communityCards[index]
        self.m_pCallbackUI:showPublicCard_Callback(self.m_roomInfo.tableId,index+2,cardValue,true)
        self.m_myPreOperateOpt = -1
        self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
    end
    
    --给自己亮牌
    if(self:myselfHasCards()) then
    
        self.m_calcMyPokers:showTurnCards(data.m_communityCards[1])
        local res = self.m_calcMyPokers:calc6Cards()
        self.m_myBestCardType = res
        if(res > GaoPai) then
            self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,self.m_myselfSeatId,self.m_calcMyPokers:getResult(res),res)
        end
    end
    
    for i=0,self.m_roomInfo.seatNum-1 do
    
        local seat = self:getSeat(i)
        if(not seat) then
            
        else
            seat.roundChips = 0
            seat.handChips = 0
        end
    end
    
    --保存公共牌
    if data.m_communityCards and #data.m_communityCards == 1 then
        self.m_roomInfo.comunityCard[#self.m_roomInfo.comunityCard+1] = data.m_communityCards[1]
    end
end
--河牌
function BaseRoom:dealRiverCardResp(dataModel)
    self.m_roomInfo.tableStatus = TABLE_STATE_RIVER
    self.m_roomInfo.isFirstRound = true
    if(not self.m_pCallbackUI) then
        return
    end
    self.m_bIsRaisedInTheRound = false--清空加注标志
    local data = dataModel
    for index=1,#data.m_communityCards do
    
        local cardValue = data.m_communityCards[index]
        self.m_pCallbackUI:showPublicCard_Callback(self.m_roomInfo.tableId,index+3,cardValue,true)
        self.m_myPreOperateOpt = -1
        self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
    end
    
    --给自己亮牌
    if(self:myselfHasCards()) then
    
        self.m_calcMyPokers:showRiverCards(data.m_communityCards[1])
        local res = self.m_calcMyPokers:calc7Cards()
        self.m_myBestCardType = res
        if(res > GaoPai) then
        
            self.m_pCallbackUI:hightLightMyCards(self.m_roomInfo.tableId,self.m_myselfSeatId,self.m_calcMyPokers:getResult(res),res)
        end
    end
    
    for i=0,self.m_roomInfo.seatNum-1 do
    
        local seat = self:getSeat(i)
        if(not seat) then
            
        else
            seat.roundChips = 0
            seat.handChips = 0
        end
    end
    
    --保存公共牌
    if #data.m_communityCards == 1 then
        self.m_roomInfo.comunityCard[#self.m_roomInfo.comunityCard+1] = data.m_communityCards[1]
    end
end
--亮牌
function BaseRoom:dealShowDownMsgResp(dataModel)

    self.m_roomInfo.tableStatus = TABLE_STATE_SHOWDOWN
    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    for index=1,#data.m_cardList do
        local playerCard = data.m_cardList[index]
        playerCard.seatNo = self:transformSeatNoForRush(playerCard.seatNo)
        if #playerCard.pocketCards<2 then 
            
        else
            if playerCard.showDownType < 1 then   --不亮

            elseif playerCard.showDownType > 0 and playerCard.showDownType < 2 then   --亮第一张
                self.m_pCallbackUI:showPlayerCards_Callback(data.m_tableId,playerCard.seatNo,playerCard.pocketCards[1],"",true)
            elseif playerCard.showDownType > 1 and playerCard.showDownType < 3 then   --亮第二张
                self.m_pCallbackUI:showPlayerCards_Callback(data.m_tableId,playerCard.seatNo,"",playerCard.pocketCards[2],true)
            elseif playerCard.showDownType > 2 and playerCard.showDownType < 4 then   --全亮    
                self.m_pCallbackUI:showPlayerCards_Callback(data.m_tableId,playerCard.seatNo,playerCard.pocketCards[1],playerCard.pocketCards[2],true)
            end
        end
    end
end
--每轮回收筹码
function BaseRoom:dealPotResp(dataModel)

    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    
    self.m_roomInfo.pot = 0
    local potNum = #data.m_potInfo
    for j=1,potNum do
        self.m_roomInfo.pot = self.m_roomInfo.pot + data.m_potInfo[j]
        self.m_pCallbackUI:updatePublicPots_Callback(self.m_roomInfo.tableId,potNum,j-1,data.m_potInfo[j],true)
    end
end
--分别每个奖池派奖的间隔延迟
function BaseRoom:prizeDelayForEachPot(dt)
    -- normal_info_log("BaseRoom:prizeDelayForEachPot")
    if(not self.m_pCallbackUI) then
        return
    end
    if self:myselfIsOnSeat() then
        self.m_pCallbackUI:setApplyPublicCardVisible(self.m_roomInfo.tableId, true)
    end
    local tableId = self.m_prizeAllPotInfoDic["tableId"]..""
    local onePotInfo = self.m_prizeAllPotInfoDic["allPotInfo"][1]
    if onePotInfo and #onePotInfo>0 then
    
        for i=1,#onePotInfo do
        
            local eachPlayerInfoAry = onePotInfo[i]
            if not eachPlayerInfoAry or #eachPlayerInfoAry<6 then
                break
            end
            local potNum  = eachPlayerInfoAry[1]
            local fromPot = eachPlayerInfoAry[2]
            local toSeat  = eachPlayerInfoAry[3]
            local winChips  = eachPlayerInfoAry[4]
            local userChips = eachPlayerInfoAry[5]
            local cardType  = eachPlayerInfoAry[6]

            --最大手牌5
            local tmpMaxCard = {}
            for k=7,#eachPlayerInfoAry do
                tmpMaxCard[#tmpMaxCard+1] = eachPlayerInfoAry[k]..""
            end
            
            --清除已凸起的牌 连续给一个人派奖时候不用清理
            if(i==1  and  self.m_previousPrizeSeatNo ~=toSeat) then
                self.m_pCallbackUI:prizeCancelUpPokers_Callback(tableId,tmpMaxCard)
            end
            
                self.m_pCallbackUI:updatePrizePots_Callback(self:isMyseat(toSeat),tableId,potNum,fromPot,toSeat,winChips,userChips,cardType,tmpMaxCard)
            
                self.m_pCallbackUI:playerChipsUpdate_Callback(tableId,toSeat,0.0,0.0,userChips,self.m_roomInfo.pot)
            
                self.m_previousPrizeSeatNo = toSeat  --记录最后一次派奖到谁
        end
        table.remove(self.m_prizeAllPotInfoDic["allPotInfo"], 1)
        
        if self.m_prizeAllPotInfoDic["allPotInfo"]==nil or #self.m_prizeAllPotInfoDic["allPotInfo"]==0 then
        
            self.m_previousPrizeSeatNo = -1 --重置
            self:stopPrize()
        end
    end
end




function BaseRoom:stopPrize()
    if self.m_prizeDFEPId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_prizeDFEPId)
        self.m_prizeDFEPId = nil
    end
end


--派奖信息
function BaseRoom:dealPrizeMsgResp(dataModel)
    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    self.m_roomInfo.tableStatus = TABLE_STATE_PRIZE
    if(TRUNK_VERSION == DEBAO_TRUNK) then
        PRIZE_FOR_EACH_DELAY = 1.5
    else
        PRIZE_FOR_EACH_DELAY = 1.0
    end
    --将有可能自己的牌型提示的高亮牌都去掉
    self.m_pCallbackUI:prizeCancelHighLightPokers_Callback(data.m_tableId)
    self.m_potReturnList = data.potReturnList
    --封装奖池派发信息
    self.m_prizeAllPotInfoDic["tableId"]=self.m_roomInfo.tableId
    
    local potNum    = #data.potList --多少个奖池
    local allPotInfoAry = {}
    for j=1,#data.potReturnList do
        self.m_pCallbackUI:potReturn_Callback(self.m_roomInfo.tableId, data.potReturnList[j].chipNum, data.potReturnList[j].uid)
    end
    for i=1,#data.potList do
        local list1 = data.potList[i] --一个奖池分给多少人
        
        local eachPotInfoAry = {}
        
        for j=1,#list1 do
        
            local list2=list1[j] --分给的那个人
            list2.seatNo = self:transformSeatNoForRush(list2.seatNo)
            local eachPlayerInfoAry = {}
            
            local seat = self:getSeat(list2.seatNo)
            seat.seatChips = list2.userChips
            seat.handChips = 0
            seat.roundChips = 0
            
            eachPlayerInfoAry[#eachPlayerInfoAry+1] = potNum
            eachPlayerInfoAry[#eachPlayerInfoAry+1] = i-1
            eachPlayerInfoAry[#eachPlayerInfoAry+1] = seat.seatId
            eachPlayerInfoAry[#eachPlayerInfoAry+1] = list2.winChips
            eachPlayerInfoAry[#eachPlayerInfoAry+1] = list2.userChips
            eachPlayerInfoAry[#eachPlayerInfoAry+1] = list2.cardType
            --最大手牌5
            for k=1,#list2.maxCard do
                eachPlayerInfoAry[#eachPlayerInfoAry+1] = list2.maxCard[k]
            end
            
            eachPotInfoAry[#eachPotInfoAry+1] = eachPlayerInfoAry
        end
        
        potNum = potNum-1
        allPotInfoAry[#allPotInfoAry+1] = eachPotInfoAry
    end
    self.m_prizeAllPotInfoDic["allPotInfo"] = nil
    self.m_prizeAllPotInfoDic["allPotInfo"]=allPotInfoAry
    

    self.m_prizeDFEPId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,
        self.prizeDelayForEachPot),PRIZE_FOR_EACH_DELAY,false)
    
end
--聊天信息返回
function BaseRoom:dealChatMsgResp(dataModel)

    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
   local seat = self:getSeat(data.m_seatNo)
    if(not seat or not self.m_pCallbackUI) then
        return
    end

    if( string.find(data.m_content, "lvChange,") ~= nil or
       string.find(data.m_content, "pointChange,") ~= nil
       ) then
    
        return
    end
    
    if(not data.isForFlash) then
    
        self.m_pCallbackUI:showChatMsg_Callback(self:isMyseat(seat.seatId),self.m_roomInfo.tableId,seat.seatId,seat.userName,data.m_content,data.chargeChips)
    end
    
    seat.seatChips = seat.seatChips - data.chargeChips
    self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
end
--盲注返回
function BaseRoom:dealTableBlindResp(dataModel)

    if(not self.m_pCallbackUI) then

        return
    end
    local data = dataModel
    
    --盲注
    for i=1,#data.blindInfo do
        local blindInfoOne = data.blindInfo[i]
        blindInfoOne.sBlindNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(blindInfoOne.sBlindNo)
        
        --初始化记录盲注
        local seat = self:getSeat(blindInfoOne.sBlindNo)

        seat.roundChips = seat.roundChips + blindInfoOne.smallBlind
        seat.handChips = seat.roundChips
        seat.seatChips = blindInfoOne.userChips
        
        self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
        
        if self:myselfIsPlaying() and not self.m_bIsMyselfAllin then
            self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, seat.roundChips - self:getSeat(myInfo.data.userId).roundChips)
        end
    end
    --新手盲注
    for i=1,#data.newBlindInfo do
    
       local newBlindInfoOne = data.newBlindInfo[i]
        newBlindInfoOne.seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(newBlindInfoOne.seatNo)
        
        --初始化记录盲注
        local seat = self:getSeat(newBlindInfoOne.seatNo)
        seat.roundChips = seat.roundChips + newBlindInfoOne.newBlindChips
        seat.handChips = seat.roundChips
        seat.seatChips = newBlindInfoOne.userChips
        
        self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
        
        if self:myselfIsPlaying() and not self.m_bIsMyselfAllin then
            self.m_pCallbackUI:playerPreOperate(self.m_roomInfo.tableId, seat.roundChips - self:getSeat(myInfo.data.userId).roundChips)
        end
    end
end
--底注信息
function BaseRoom:dealTableAnteResp(dataModel)

    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    
    --底注
    for i=1,#data.m_anteInfo do
    
        local anteInfoOne = data.m_anteInfo[i]
        anteInfoOne.seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(anteInfoOne.seatNo)
        
        local seat = self:getSeat(anteInfoOne.seatNo)
        if(seat) then
        
            seat.roundChips = seat.roundChips + anteInfoOne.betChips
            seat.handChips  = seat.roundChips
            seat.seatChips = anteInfoOne.userChips
        end
        --回收底注到奖池
        self.m_pCallbackUI:updatePublicPots_Callback(self.m_roomInfo.tableId,1,0,data.m_totalPot,false)
        --更新显示
        self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
    end
end
--设置庄家位
function BaseRoom:dealTableDealerResp(dataModel)

    if(not self.m_pCallbackUI) then
        return
    end
    self.m_roomInfo.tableStatus = TABLE_STATE_SETBUTTON
    
    local data = dataModel
    data.m_buttonNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_buttonNo)
    self.m_roomInfo.buttonNo = data.m_buttonNo
    self.m_roomInfo.sBlindNo = data.m_sblindNo
    self.m_roomInfo.bBlindNo = data.m_bblindNo
    if(data.m_buttonNo>=0  and  self.m_pCallbackUI) then
        self.m_pCallbackUI:updateDealerPos_Callback(self.m_roomInfo.tableId, self.m_roomInfo.buttonNo,true)
    end
end
--玩家等待超时
function BaseRoom:dealPlayerTimeoutResp(dataModel)

    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_seatNo)
    if(not seat) then
        return
    end
    seat.userStatus = PLAYER_STATE_AFK
    seat.isTrustee = true
    
    --自己超时显示我回来了别人超时暂离
    if(self.m_pCallbackUI) then
        self.m_pCallbackUI:playerOperateBackSeat(self:isMyseat(data.m_seatNo),self.m_roomInfo.tableId,data.m_seatNo)
    end
end
--翻牌前抽水
function BaseRoom:dealTableRakeBfFlopResp(dataModel)

    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    
    for i=1,#data.m_rakeInfoBfFlop do
    
        local bfFlopInfo = data.m_rakeInfoBfFlop[i]
        bfFlopInfo.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(bfFlopInfo.m_seatNo)
        local seat = self:getSeat(bfFlopInfo.m_seatNo)
        if(seat) then
        
            seat.seatChips = bfFlopInfo.m_userChips
        end
        self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
        
    end
end
--玩家买入
function BaseRoom:dealBuyChipsResp(dataModel)

    if not self.m_pCallbackUI then
        return
    end
    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    
    local isMyself = self:isMyseat(data.m_userId)
    if(data.m_code == 10000) then
    
        local seat = self:getSeat(data.m_seatNo)
        if(not seat) then
            return
        end
        seat.seatChips = data.m_userChips
        seat.roundChips = 0
        seat.handChips = 0
        
        if(isMyself) then
        
            if self.m_roomInfo.payType == "POINT" then
                self:setMyDebaoDiamond(self:getMyTotalMoney()-data.m_buyChips)
            else
                self:setMyTotalMoney(self:getMyTotalMoney()-data.m_buyChips)
            end
            self.m_myBuyChipsNum = 0.0
        end
        
        self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
    end
    
end
--tcp 买入
function BaseRoom:dealBuyChipsTcpResp(dataModel)

    if not self.m_pCallbackUI then
        return
    end
    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    
    local isMyself = self:isMyseat(data.m_userId)
    if data.m_code == 10000 then
    
        local seat = self:getSeat(data.m_seatNo)
        if not seat then
            return
        end
        seat.seatChips = data.m_userChips
        seat.roundChips = 0
        seat.handChips = 0
        
        if isMyself then
        
            if self.m_roomInfo.payType == "POINT" then
                self:setMyDebaoDiamond(self:getMyTotalMoney()-data.m_buyChips)
            else
                self:setMyTotalMoney(self:getMyTotalMoney()-data.m_buyChips)
            end
            self.m_myBuyChipsNum = 0.0
            
            --此处的判断并不严谨 替代方案服务器支持客户端的userdata
            if self.m_bAutoBuyinReqing then
                self.m_pCallbackUI:showAutoBuyin_Callback(self.m_roomInfo.tableId, data.m_buyChips)
            end
            self.m_bAutoBuyinReqing=false
        end
        
        
        self.m_pCallbackUI:playerChipsUpdate_Callback(self.m_roomInfo.tableId,seat.seatId,seat.handChips,seat.roundChips,seat.seatChips)
    else
    
        local errorMsg = Lang_BuyinFail..data.m_code
        if self.m_pCallbackUI then
            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,errorMsg,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
        end
        if not data.m_isRebuy  and  isMyself then
            self:reqMySit_out()
        end
    end
end
--被淘汰出局
function BaseRoom:dealOutCompetitionByEliminationResp(dataModel)

end
--本手牌结束
function BaseRoom:dealHandFinishResp(dataModel)

    if not self.m_pCallbackUI then
        return
    end
    self.m_pCallbackUI:setApplyPublicCardVisible(self.m_roomInfo.tableId, false)
    local data = dataModel
    self.m_roomInfo.tableStatus = TABLE_STATE_END
    for i=0,self.m_roomInfo.seatNum-1 do
        local seat = self:getSeat(i)
        if not seat then
        else
            seat.roundChips = 0
            seat.handChips = 0
        end
    end
    
    self.m_pCallbackUI:dealHandFinish_Callback(self.m_roomInfo.tableId)

    if self:myselfIsOnSeat() then
        DBHttpRequest:getAccountInfo(function(event) if self.httpResponse then self:httpResponse(event) end
            end)
        if self.m_childRoom then
            self.m_childRoom:bankruptRequest() --破产保护判断 + 自动买入
        else
            self:bankruptRequest() --破产保护判断 + 自动买入
        end
    end
    
    
    --更新用户状态
    for i=0,self.m_roomInfo.seatNum-1 do
        local seat = self:getSeat(i)
        if seat then
            seat.userStatus = PLAYER_STATE_INIT
        end
    end
    
    
end
function BaseRoom:dealApplyFriendResp(dataModel)

    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
  
    self.m_pCallbackUI:actionFriend_Callback(self.m_roomInfo.tableId, data.userId, data.userName, true, data.applyFriendResult == 1)
    
end
function BaseRoom:dealRemoveFriendResp(dataModel)

    if(not self.m_pCallbackUI) then
        return
    end
    local data = dataModel
    self.m_pCallbackUI:actionFriend_Callback(self.m_roomInfo.tableId, data.userId, data.userName, false, (data.isSuccess == 1))
end

function BaseRoom:dealPushMessage(dataModel)

    
end

function BaseRoom:dealAddFriendResp(dataModel)

end

function BaseRoom:dealUserOperateDelayResp(dataModel)
    if not self.m_pCallbackUI then
        return
    end
    local data = dataModel
    data.m_seatNo = (self.m_childRoom and self.m_childRoom or self):transformSeatNoForRush(data.m_seatNo)
    local seat = self:getSeat(data.m_userId)

    local isMyself = self:isMyseat(data.m_userId)
    self.m_pCallbackUI:showUserOperateDelay(self.m_roomInfo.tableId, isMyself, data.m_userId, data.m_remainTime)
end

function BaseRoom:dealApplyPublicCardResp(dataModel)
    if not self.m_pCallbackUI then
        return
    end
    local data = dataModel
    if data and data.m_cardList and #data.m_cardList>0 then
        local cardIndex = 4
        for i=#data.m_cardList,1,-1 do
            self.m_pCallbackUI:showPublicCard_Callback(self.m_roomInfo.tableId,cardIndex,data.m_cardList[i],false)
            cardIndex = cardIndex - 1
        end
    end
end

function BaseRoom:dealTrusteeshipProtectResp(dataModel)
    if not self.m_pCallbackUI then
        return
    end
    local data = dataModel
    if data then
        if data.m_code and data.m_code == 10000 then
            local isMyself = self:isMyseat(data.m_userId)
            self.m_pCallbackUI:showTrusteeshipProtectCallback(data.m_tableId, data.m_userId, isMyself, 600)
        else
            local errMsg = nil
            if data.m_code and data.m_code == -11015 then
                errMsg = "该用户没有座位"
            elseif data.m_code and data.m_code == -11015 then
                errMsg = "不存在的赛桌"
            elseif data.m_code and data.m_code == -11015 then
                errMsg = "该座位不存在玩家"
            elseif data.m_code and data.m_code == -11015 then
                errMsg = "牌桌状态错误"
            else
                errMsg = "道具使用失败"
            end
            self.m_pCallbackUI:showInfoHint_Callback(self.m_roomInfo.tableId,errMsg)
        end
    end
end

----------------------------------------------------------

--[[http请求返回]]
----------------------------------------------------------
function BaseRoom:httpResponse(event)

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

function BaseRoom:onHttpResponse(tag, content, state)
    -- if(state not = ehttpSuccess)
    -- {
    --  if (tag == POST_COMMAND_GETUSERTABLELIST)
    --  {
    --      m_pCallbackUI.showAlertEnterChampion(NULL, 0)
    --      return
    --  }
    --  string errorMsg = state==ehttpNoNetwork?Lang_NO_NETWORK:Lang_REQUEST_DATA_ERROR
    --  if(m_pCallbackUI)
    --      m_pCallbackUI.showError_Callback(errorMsg)
    --  return
    -- }
    local tmpRoom = self
    if self.m_childRoom then
        tmpRoom = self.m_childRoom
    end
    if tag == POST_COMMAND_BUYIN then
        tmpRoom:dealBuyInResp(content)
    elseif tag == POST_COMMAND_REBUY then
        tmpRoom:dealRebuyResp(content)
    elseif tag == POST_COMMAND_FETCHROOKIEPROTECTION then--[[新手保护回应]]
        tmpRoom:dealBrokeProtectResp(content)
    elseif tag == POST_COMMAND_GETMATCHINFO then
        tmpRoom:dealGetMatchInfo(content)
    elseif tag == POST_COMMAND_GETBLINDDSINFO then
        tmpRoom:dealGetBlindDSInfo(content)
    elseif tag == POST_COMMAND_GETMATCHDETAIL then
        tmpRoom:dealGetMatchDetail(content)
    elseif tag == POST_COMMAND_GETTABLEINFO then
        tmpRoom:dealGetTableInfo(content)
    elseif tag == POST_COMMAND_TASK_HAPPYHOUR_INFO then
        tmpRoom:dealGetTaskHappyHourCongfig(content)
    elseif tag == POST_COMMAND_GETUSERSHOWINFO then--[[显示信息]]
        tmpRoom:dealGetUserShowInfo(content)
    elseif tag == POST_COMMAND_GET_VIP_INFO then--[[获取vip 信息]]
        tmpRoom:dealGetVipLevelInfo(content)
    elseif tag == POST_COM_GETROOKIEPROTECTIONCONFIG then
        tmpRoom:dealGetRookieProtectionConfig(content)
    elseif tag == POST_COMMAND_GETACCOUNTINFO then
        tmpRoom:dealGetAccountInfo(content)
    elseif tag == POST_COM_GET_USER_CHARGE_INFO then
        tmpRoom:dealGetUserChargeInfo(content)
    elseif tag == POST_COMMAND_SELECTACTIVITYINFO then--[[query reward idd]]
        tmpRoom:dealQueryRewardResp(content)
    elseif tag == POST_COMMAND_CHAT_FACE_INFO then--[[chat face info]]
        tmpRoom:dealFaceInfoResp(content)
    elseif tag == POST_COMMAND_GETUSERSNGPKINFO then
        tmpRoom:dealGetUserSngPKInfo(content)
    elseif tag == POST_COMMAND_GETSERVERTIME then
        tmpRoom:dealGetServerTime(content)
    elseif tag == POST_COMMAND_GETSNGPKMATCHINFO then
        tmpRoom:dealGetSngPKInfo(content)
    elseif tag == POST_COMMAND_GETGOODNAME then
        tmpRoom:dealGetGoodName(content)
    elseif tag == POST_COMMAND_QUITMATCH then
        tmpRoom:dealQuitMatch(content)
    elseif tag == POST_COMMAND_SENDBOARDINFO then
        tmpRoom:dealSaveBoardInfo(content)
    elseif tag == POST_COMMAND_AddOn then
        tmpRoom:dealAddOnResp(content)
    elseif tag == POST_COMMAND_GET_DiyFidByTableId then
        self:dealGetDiyFidByTableId(content)
    end
end

--====== http======
function BaseRoom:dealGetDiyFidByTableId(content)
   local data = require("app.Logic.Datas.Lobby.GetTableConfigId"):new()
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
        self.m_pCallbackUI:showTableConfigId(self.m_roomInfo.tableId, data.configId)
    end
end

function BaseRoom:dealBuyInResp(strJson)
    
    self.m_isAdd_buyinChips = false--还原购买标志位
    self.m_isQuickStart = false
    --static int s_sitNum = 0
    local data = require("app.Logic.Datas.TableData.BuyInInfo"):new()
        
    if((data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS)) then
        local code = data.code+0
        if code==1 then
                --买入筹码时在tcp返回中减自己的总钱
                --setMyTotalMoney(getMyTotalMoney()-self.m_myBuyChipsNum)
                --self.m_myBuyChipsNum = 0.0
                
                --此处的判断并不严谨 替代方案服务器支持客户端的userdata
                if (self.m_bAutoBuyinReqing) then
                    self.m_pCallbackUI:showAutoBuyin_Callback(self.m_roomInfo.tableId, self.m_myBuyChipsNum)
                end
        elseif code==-13001 then
                local errorMsg = Lang_LESS_MINBUYIN..data.code
                if(self.m_pCallbackUI) then
                    self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,errorMsg,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
                end
                self:reqMySit_out()
        else
                local errorMsg = Lang_BuyinFail
                if data.code then
                    errorMsg = errorMsg..data.code
                end
                if(self.m_pCallbackUI) then
                    self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,errorMsg,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
                end
                self:reqMySit_out()
                
        end
        
        self.m_bAutoBuyinReqing = false
    end
end

function BaseRoom:dealRebuyResp(content)
    self.m_isAdd_buyinChips = false--还原购买标志位
    self.m_isQuickStart = false
    local data = require("app.Logic.Datas.TableData.BuyInInfo"):new()
    if((data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS)) then
        local code = data.code
        if code == -13001 then--用户余额不足
            self:reqMySit_out()
        end
        if(code ~= 1)then
            -- local errorMsg = Lang_BuyinFail..data.code
            local errorMsg = Lang_BuyinFail
            if(self.m_pCallbackUI) then
                self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                    errorMsg,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
            end
        end
    end
    data = nil
end
-- function BaseRoom:dealBrokeProtectResp(content)
-- end
-- function BaseRoom:dealGetMatchInfo(content)
-- end
-- function BaseRoom:dealGetBlindDSInfo(content)
-- end
-- function BaseRoom:dealGetMatchDetail(content)
-- end
function BaseRoom:dealGetTableInfo(content)
    local info = require("app.Logic.Datas.Lobby.TourneyTableInfo"):new()
    if info:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
        self.m_matchId = info.matchId
    end
end

function BaseRoom:dealGetTaskHappyHourCongfig(content)
    -- normal_info_log("BaseRoom:dealGetTaskHappyHourCongfig 待完善")
    if self.m_childRoom and self.m_childRoom.dealGetTaskHappyHourCongfig then
        self.m_childRoom:dealGetTaskHappyHourCongfig(content)
    end
end

function BaseRoom:dealGetUserShowInfo(content)
    local data = require("app.Logic.Datas.DebaoMain.Account.DMGetUserShowInfo"):new()
    if data:parseJson(content) == BIZ_PARS_JSON_SUCCESS then

        local seat = self:getSeat(data.userId)
        if seat then
            seat.imageURL = data.userPortrait
            seat.userName = data.userName
            if self.m_pCallbackUI then
                self.m_pCallbackUI:updateUserShowInfo(
                                                  self.m_roomInfo.tableId,
                                                  seat.seatId,
                                                  seat.imageURL,
                                                  seat.userName)
            end
        end
    end
end

function BaseRoom:dealGetVipLevelInfo(content)
    local jsonTable = json.decode(content)
    if type(jsonTable) == "table" then
        for index=1,#jsonTable do
            local seat = self:getSeat(""..jsonTable[index]["2003"])
            if seat then
                if self.m_pCallbackUI then
                    self.m_pCallbackUI:updateUserVipLevel(self.m_roomInfo.tableId,seat.seatId,
                        ""..jsonTable[index]["2003"],""..jsonTable[index][USER_LEVEL])
                end
            end
        end
    end
end
-- function BaseRoom:dealGetRookieProtectionConfig(content)
-- end

function BaseRoom:dealGetAccountInfo(content)
    if TRUNK_VERSION == DEBAO_TRUNK then
        local data = require("app.Logic.Datas.Account.AccountInfo"):new()
        if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and data.code=="" then
            myInfo:setTotalChips(data.silverBalance+0.0)
            myInfo.diamondBalance = data.diamondBalance+0.0
            myInfo.data.userDebaoDiamond   = tonumber(data.pointBalance)
            --新手保护取消,改为免费金币
            if data.goldBalance < myInfo.brokeMoney then
                self.m_pCallbackUI:showProtectedDialog_Callback(self.m_roomInfo.tableId,4, 
                    myInfo.award_num, self.m_roomInfo.buyChipsMax, self.m_roomInfo.buyChipsMin)
            end
        end
        data = nil
    end
end

function BaseRoom:dealGetUserChargeInfo(content)
    local data = require("app.Logic.Datas.DebaoMain.Account.DMGetUserChargeInfo"):new()
    if data:parseJson(content) == BIZ_PARS_JSON_SUCCESS then
        myInfo.data.requestPayRecord = true
        myInfo.data.payamount = data.transMoney
    end
end

function BaseRoom:dealQueryRewardResp(content)
end

function BaseRoom:dealFaceInfoResp(content)
    local data = require("app.Logic.Datas.Others.FacesData"):new()
    if data:parseJson(content) == BIZ_PARS_JSON_SUCCESS then
        if data.picUrl ~= "" or data.version ~= "" then
            local localVersion = UserDefaultSetting:getInstance():getFaceVersion()
            if localVersion~=data.version then
                local npos = nil
                for i=string.len(data.picUrl),1,-1 do
                    if string.sub(data.picUrl,i,i)=="/" then
                        npos = i
                        break
                    end
                end
                if npos ~= nil then
                    DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse),
                        data.picUrl.."default_face/"..string.sub(data.picUrl,npos+1))
                    UserDefaultSetting:getInstance():setFaceVersion(data.version)
                end
            else
                local npos = nil
                for i=string.len(data.picUrl),1,-1 do
                    if string.sub(data.picUrl,i,i)=="/" then
                        npos = i
                        break
                    end
                end
                if npos ~= nil then
                    local filename = cc.FileUtils:getInstance():getWritablePath().."images/faces/"..string.sub(data.picUrl,npos+1)
                    if not cc.FileUtils:getInstance():isFileExist(filename) then
                        DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse),
                            data.picUrl)
                        UserDefaultSetting:getInstance():setFaceVersion(data.version)
                    end
                end
            end
        end
    end
end

-- function BaseRoom:dealGetUserSngPKInfo(content)
-- end
-- function BaseRoom:dealGetServerTime(content)
-- end
-- function BaseRoom:dealGetSngPKInfo(content)
-- end
-- function BaseRoom:dealGetGoodName(content)
-- end
-- function BaseRoom:dealQuitMatch(content)
-- end

function BaseRoom:dealSaveBoardInfo(strJson)
end

--[[addon返回消息,如果返回成功1,则不处理,交由tcp消息接收ADDON_FINISH后处理addon,如果发回其他失败,则弹出错误]]
-- function BaseRoom:dealAddOnResp(content)
    -- local code = 0+strJson
    -- if code ~= 1 then
    --     local str = "最终加码失败not " .. strJson
    --     self.m_pCallbackUI:showRebuyResult_Callback(self.m_roomInfo.tableId, str, false)
    -- end
-- end
----------------------------------------------------------
----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function BaseRoom:onHttpDownloadResponse(event)

    local ok = (event.name == "completed") 
    if ok then 
        local request = event.request  
        -- local filename = cc.FileUtils:getInstance():getWritablePath().."images/faces/".."face.zip"
        -- if CMCheckDirOK(cc.FileUtils:getInstance():getWritablePath().."images/") then
        --     if CMCheckDirOK(cc.FileUtils:getInstance():getWritablePath().."images/faces") then
        --         request:saveResponseData(filename) 
        --         require("app.Tools.FacePicManger"):getInstance():checkUncompress()
        --     end
        -- end
        
        if CMCreateDirectory(device.writablePath.."images/faces/") then

            local filename = device.writablePath.."images/faces/".."face.zip"
            -- if CMCheckDirOK(device.writablePath.."images/") then
            --     if CMCheckDirOK(device.writablePath.."images/faces") then
                    request:saveResponseData(filename) 
                    require("app.Tools.FacePicManger"):getInstance():checkUncompress()
                -- end
            -- end
        end
    end
end
----------------------------------------------------------
--[[自己请求加入桌子]]
function BaseRoom:reqMyJoinTable()
    self.tcpRequest:joinTable(self.m_roomInfo.tableId,"")
end

--自己离开桌子 --isConfirm第二次确认后退出房间则不提示用户
function BaseRoom:reqMyLeaveTable(isConfirm, leaveType)
    -- normal_info_log("BaseRoom:reqMyLeaveTable")
    self.m_leaveRoomType = leaveType
    if(self:myselfIsPlaying() and isConfirm) then
    
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showConfirmQuitRoom(self.m_roomInfo.tableId)--退出房间确认框
        end
    else
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showRoomLoadingView(true)--显示退出房间loading
        end
        
        if(self.m_myselfSeatId>=0) then
            self.m_isQuitRoom = true
            self:reqMySit_out()
        
        else
            self.tcpRequest:leaveTable(self.m_roomInfo.tableId)
        end
    end
end

--请求桌子信息
function BaseRoom:reqMyTableInfo()

    self.tcpRequest:tableInfo(m_roomInfo.tableId)
end
--坐下
function BaseRoom:reqMySit(seat_no)
    if(not self.m_pCallbackUI) then
    
        return
    end
    local chips = self.m_roomInfo.payType == "RAKEPOINT" and self:getMyRakePoint() or self:getMyTotalMoney()

    self.m_roomInfo.buyChipsMin = tonumber(self.m_roomInfo.buyChipsMin)
    chips                       = tonumber(chips)
    
    self.m_isAdd_buyinChips = false--坐下后设置为不自动补充筹码
    if(chips < self.m_roomInfo.buyChipsMin) then --判断钱不够提示是否充值
        if(myInfo.data.payamount <= 0 and self:getMyTotalMoney() < myInfo.data.brokeMoney) then
            if (self.m_roomInfo.gameMinBuyin>8000) then 
                if(myInfo.data.payamount<=0) then
                
                    self.m_pCallbackUI:showFirstChargeDialog_Callback(self.m_roomInfo.tableId,1,Lang_FirstOldBroken) --老用户提示首充活动
                
                else
                
                    self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                        Lang_OldUserBankrupt,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                        true,false,BUYINFAIL_ACTION_QUITEROOM)
                end
            else
                self.m_pCallbackUI:showFreeGoldDialog_Callback(self.m_roomInfo.tableId)
            end
    
        else
        
            local bQuickStartAble =  self:getMyTotalMoney() >= myInfo.data.brokeMoney
            if (self.m_roomInfo.payType == "RAKEPOINT")  then
                self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                    bQuickStartAble and Lang_LESS_MINBUYIN or Lang_BANKRUPT_MINBUYIN,
                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,true,false,
                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM,true)
            else
                -- dump("enter")
                -- dump(self.m_pCallbackUI)
                -- dump(self.m_roomInfo.tableId)
                -- dump(bQuickStartAble)
                -- dump(self.m_pCallbackUI)
                -- dump(self.m_pCallbackUI)
                self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                    bQuickStartAble and Lang_LESS_MINBUYIN or Lang_BANKRUPT_MINBUYIN,
                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,true,0,
                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM)
            end
            
        end
    else
        self.tcpRequest:sit(self.m_roomInfo.tableId,seat_no,myInfo.data.userId,myInfo.data.userName,
            myInfo.data.userSex,myInfo.data.userPotrait,myInfo.data.privilege)
    end
end
--站起
function BaseRoom:reqMySit_out()
    -- normal_info_log("BaseRoom:reqMySit_out")
    self.tcpRequest:sit_out(self.m_roomInfo.tableId,myInfo.data.userId)
    
    local seat = self:getSeat(myInfo.data.userId)
    if(not seat or not self.m_pCallbackUI)  then
        return
    end
    local isMyself = self:isMyseat(seat.userId)
    if(isMyself) then
        
        if self.m_roomInfo.payType == "POINT" then
            self:setMyDebaoDiamond(self:getMyTotalMoney()+seat.seatChips)
        else
            self:setMyTotalMoney(self:getMyTotalMoney()+seat.seatChips)--把自己的钱加回去
        end
        self.m_myselfSeatId = -1
        self.m_myBestCardType = -1
        if(self.m_isQuitRoom) then --是否退出房间
            self:reqMyLeaveTable(false,self.m_leaveRoomType)
        end
        --新手引导
        self.m_pCallbackUI:showNewerGuideActionHint(self.m_roomInfo.tableId,kNGCNone,kOBOHNone)
    end
    
    self.m_pCallbackUI:playerSitOut_Callback(isMyself,self.m_myselfSeatId>=0,self.m_roomInfo.tableId,seat.seatId)
    
    seat:standup()
end
--看牌
function BaseRoom:reqMyCheckPoker()

    self.tcpRequest:checkPoker(self.m_roomInfo.tableId,myInfo.data.userId,self.m_roomInfo.sequence)
    self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
end
--跟牌
function BaseRoom:reqMyCallPocker()

    self.tcpRequest:callPocker(self.m_roomInfo.tableId,myInfo.data.userId,self.m_roomInfo.sequence)
    self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
end
--弃牌
function BaseRoom:reqMyFoldPocker()

    self.tcpRequest:foldPocker(self.m_roomInfo.tableId,myInfo.data.userId,self.m_roomInfo.sequence)
    self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
end
--allIn
function BaseRoom:reqMyAllIn()

    self.tcpRequest:allIn(self.m_roomInfo.tableId,myInfo.data.userId,self.m_roomInfo.sequence)
    self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
end


--加注
function BaseRoom:reqMyRaise(bet_chips)

    self.tcpRequest:raise(self.m_roomInfo.tableId,myInfo.data.userId,bet_chips,self.m_roomInfo.sequence)
    self.m_pCallbackUI:playerOperateUnselectPre(self.m_roomInfo.tableId)
end
--取消托管 我回来了
function BaseRoom:reqMyCancel()

    self.tcpRequest:cancel(self.m_roomInfo.tableId,myInfo.data.userId)
end
--亮牌
function BaseRoom:reqMyShowDown(showDownType)

    self.tcpRequest:showDown(self.m_roomInfo.tableId,myInfo.data.userId,showDownType)
end
--自动缴纳盲注
function BaseRoom:reqMySetAutoBlind(autoBlindType)

    self.tcpRequest:setAutoBlind(self.m_roomInfo.tableId,myInfo.data.userId,autoBlindType)
end
--加入等待队列
function BaseRoom:reqMyJoinQueue()

    self.tcpRequest:joinQueue(self.m_roomInfo.tableId,myInfo.data.userId,myInfo.data.userName)
end
--退出等待队列
function BaseRoom:reqMyQuitQueue()

    self.tcpRequest:quitQueue(self.m_roomInfo.tableId,myInfo.data.userId,myInfo.data.userName)
end
--继续围观
function BaseRoom:reqMyKeepTable()

    self.tcpRequest:keepTable(self.m_roomInfo.tableId,myInfo.data.userId)
end
--发送聊天
function BaseRoom:reqMyTableChat(content, chatType)

    if(self.m_myselfSeatId>=0) then
        if self.m_childRoom then
            self.m_childRoom:sendChatMsg(content,chatType)
        else
            self:sendChatMsg(content,chatType)
        end
    
    else
    
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
                self.m_roomInfo.tableId,Lang_OnlySitCanChat,myInfo:getTotalChips(),
                self.m_roomInfo.buyChipsMin)
        end
    end
end
function BaseRoom:sendChatMsg(content, chatType)

    local seat = self:getSeat(self.m_myselfSeatId)
    --#if(TRUNK_VERSION==DEBAO_TRUNK)
    --  int isCharge = 0
    --  if(content[0] =='/' and seat)
    --#else
    --  int isCharge = 1
    --  if(content[0] =='/' and seat and seat:seatChips >= self.m_roomInfo.smallBlind)
    --#endif
    --  
    --      tcpRequest:tableChat(self.m_roomInfo.tableId,content,isCharge)
    --  }
    --  elseif(content[0] not ='/')
    --  
    if seat then
    
        self.tcpRequest:tableChat(self.m_roomInfo.tableId,content,0,chatType)
    
    else
    
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
                self.m_roomInfo.tableId,Lang_NotEnoughMoneyToPlayEmotion,
                myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
        end
    end
    
end
--购买筹码(包括补充筹码)
function BaseRoom:reqMyBuyChips(buyChips, isAutoAdd, isAddBuy)
    dump(buyChips)
    local seat = self:getSeat(self.m_myselfSeatId)
    if(not seat) then--[[自己不在座位上时提示]]
            if self.m_pCallbackUI then
                self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
                                                                self.m_roomInfo.tableId,
                                                                Lang_OnlySitCanBuyin,
                                                                myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
            end
        return
    end

    local owner = tonumber(self.m_roomInfo.tableOwner)
    if owner and owner>0 and self.m_roomInfo.payType == "VGOLD" and (buyChips-seat.seatChips)>0 then
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showBuyinWaitHint(self.m_roomInfo.tableId)
        end
    end

    self.m_isAutoBuyinChips = isAutoAdd--当筹码为0时是否自动买入
    self.m_isAdd_buyinChips = isAddBuy--是否为补充筹码
    self.m_myBuyChipsNum = buyChips
    -- dump(self.m_isAdd_buyinChips)
    -- dump(buyChips)
    -- dump(seat.seatChips)
    if(not self.m_isAdd_buyinChips and buyChips>0) then --刚进房间坐下购买
        if self.m_childRoom then
            self.m_childRoom:buyin(self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,false)
        else 
            self:buyin(self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,false)
        end
    elseif(self.m_isAdd_buyinChips and (buyChips-seat.seatChips)>0) then
    --补充筹码购买（需判断可否本局补充买入)
        
        if(self.m_roomInfo.tableStatus<=TABLE_STATE_INIT or self.m_roomInfo.tableStatus>=TABLE_STATE_PRIZE) then
        
            self.m_myBuyChipsNum = buyChips-seat.seatChips
            if self.m_childRoom then
                self.m_childRoom:buyin(self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,true)
            else
                self:buyin(self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,true)
            end
            self.m_isAdd_buyinChips = false
        
        else
        
            if(self.m_pCallbackUI) then
            
                self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
                    self.m_roomInfo.tableId,Lang_CurrentRoundEndBuyin,
                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
        
            end
        end
    end
    --补充筹码时当选择的钱和自己的一样的情况没做处理和提示

end
--buyin
function BaseRoom:buyin(tableId, userId, buyinChips, payType, isRebuy)
    -- dump(buyinChips)
    if(TRUNK_VERSION==DEBAO_TRUNK) then
        if(isRebuy) then
            local tmp = StringFormat:FtoA(buyinChips,2)
            DBHttpRequest:reBuy(handler(self,self.httpResponse),tableId,tmp)
        else
    
            local tmp = StringFormat:FtoA(buyinChips,2)
            DBHttpRequest:buyIn(handler(self,self.httpResponse),tableId,tmp)
        end
    else
        --tcpRequest:buyinReq(tableId,userId,buyinChips,payType,isRebuy)
        self.tcpRequest:newBuyinReq(tableId, userId, buyinChips, payType, isRebuy)
    end
end
--客户端坐下
function BaseRoom:localQuickSit()

    return
end

function BaseRoom:startPushServer()
    return
end


function BaseRoom:closePushServer()

    return
end
--显示补充筹码对话框
function BaseRoom:reqMyAddBuyChipDiaglog()
    --显示购买对话框
    if self.m_childRoom then
        self.m_childRoom:callBuyDialog(true)
    else
        self:callBuyDialog(true)
    end
end
--显示快速充值对话框
function BaseRoom:reqMyQuickCharge()
    --显示购买对话框
    if self.m_childRoom then
        self.m_childRoom:callQuickRechargeDialog(true)
    else
        self:callQuickRechargeDialog(true)
    end
end

--获取预选操作类型
function BaseRoom:reqMyPreOperateOpt(index)

    self.m_myPreOperateOpt = index
end
--不回调直接获取自己的最大手牌类型给roomview
function BaseRoom:reqMyBestCardsType(cardType)

    if(self:myselfHasCards()) then
        cardType=self.m_myBestCardType
    else
    
        self.m_myBestCardType=-1
        cardType=self.m_myBestCardType
    end
end
function BaseRoom:reqGamblingIsCarryOn()

    return false
end
function BaseRoom:reqApplyFriend(seatId)

    local seat = self:getSeat(seatId)
    if(seat) then
    
        self.tcpRequest:applyFriend(
                                self.m_roomInfo.tableId,
                                myInfo.data.userId,
                                myInfo.data.userName,
                                seat.userId,
                                seat.userName
                                )
    end
end
function BaseRoom:reqAgreeAddFriend(userId, userName, isAgree)

    self.tcpRequest:addFriend(
                          self.m_roomInfo.tableId,
                          myInfo.data.userId,
                          myInfo.data.userName,
                          userId,
                          userName,
                          isAgree)
end
function BaseRoom:addOrRemoveConcern(seatNo, bAdd, receiver)

    local seat = self:getSeat(seatNo)
    if(not seat) then
        return
    end
    if (bAdd) then
    
        DBHttpRequest:applyFriend(receiver,seat.userId, seat.userName, true)
    
    else
    
        DBHttpRequest:removeFriend(receiver,seat.userId, seat.userName, true)
    end
    
end


function BaseRoom:reqUploadBoardInfo()
    -- dump(BoardInfo:getInstance().postCommandString)
    local msg
    local msgStr = ""
    local count = #BoardInfo:getInstance().commandInfo
    -- count = 1
    for i=1,count do
        msgStr=BoardInfo:getInstance().commandInfo[i]
        BoardInfo:getInstance().postCommandString = BoardInfo:getInstance().postCommandString..msgStr
        if i~=count then
           BoardInfo:getInstance().postCommandString = BoardInfo:getInstance().postCommandString..","
        end
    end
    BoardInfo:getInstance().commandInfo = nil
    BoardInfo:getInstance().commandInfo = {}
    local postInfo = BoardInfo:getInstance().tableInfo
    if(string.len(BoardInfo:getInstance().postCommandString)>1) then
        local cmdStr ="{\"A3\":["..BoardInfo:getInstance().postCommandString.."],"
        -- local cmdStr ="{\"A3\":[".."".."],"
        -- postInfo = cmdStr.."\"A4\" : 1000}"
        postInfo = cmdStr..string.sub(postInfo, 2)

        postInfo = string.gsub(postInfo, "\"1008\"", "\"A1\"")
        postInfo = string.gsub(postInfo, "\"2001\"", "\"A2\"")
        
        postInfo = string.gsub(postInfo, "\"1002\"", "\"A4\"")
        postInfo = string.gsub(postInfo, "\"1007\"", "\"A5\"")
        postInfo = string.gsub(postInfo, "\"1003\"", "\"A6\"")
        postInfo = string.gsub(postInfo, "\"2002\"", "\"A7\"")
        postInfo = string.gsub(postInfo, "\"3026\"", "\"A8\"")
        postInfo = string.gsub(postInfo, "\"2006\"", "\"A9\"")
        postInfo = string.gsub(postInfo, "\"30A5\"", "\"10\"")
        postInfo = string.gsub(postInfo, "\"200F\"", "\"11\"")
        postInfo = string.gsub(postInfo, "\"2003\"", "\"12\"")
        postInfo = string.gsub(postInfo, "\"2004\"", "\"13\"")
        postInfo = string.gsub(postInfo, "\"2005\"", "\"14\"")
        postInfo = string.gsub(postInfo, "\"2026\"", "\"15\"")
        postInfo = string.gsub(postInfo, "\"2011\"", "\"16\"")
        
        postInfo = string.gsub(postInfo, "\"2013\"", "\"18\"")
        postInfo = string.gsub(postInfo, "\"2014\"", "\"19\"")
        postInfo = string.gsub(postInfo, "\"2015\"", "\"20\"")
        postInfo = string.gsub(postInfo, "\"2008\"", "\"21\"")
        postInfo = string.gsub(postInfo, "\"2009\"", "\"22\"")
        postInfo = string.gsub(postInfo, "\"1005\"", "\"23\"")
        postInfo = string.gsub(postInfo, "\"202A\"", "\"24\"")
        postInfo = string.gsub(postInfo, "\"201C\"", "\"25\"")
        postInfo = string.gsub(postInfo, "\"200B\"", "\"26\"")
        postInfo = string.gsub(postInfo, "\"200C\"", "\"27\"")
        postInfo = string.gsub(postInfo, "\"2019\"", "\"28\"")
        postInfo = string.gsub(postInfo, "\"2018\"", "\"29\"")
        postInfo = string.gsub(postInfo, "\"200A\"", "\"30\"")
        postInfo = string.gsub(postInfo, "\"2039\"", "\"31\"")
        postInfo = string.gsub(postInfo, "\"203C\"", "\"32\"")
        postInfo = string.gsub(postInfo, "\"201F\"", "\"33\"")
        postInfo = string.gsub(postInfo, "\"2020\"", "\"34\"")
        postInfo = string.gsub(postInfo, "\"2022\"", "\"35\"")
        postInfo = string.gsub(postInfo, "\"203E\"", "\"36\"")
        postInfo = string.gsub(postInfo, "\"202C\"", "\"37\"")
        postInfo = string.gsub(postInfo, "\"2045\"", "\"38\"")
        postInfo = string.gsub(postInfo, "\"2021\"", "\"39\"")
        postInfo = string.gsub(postInfo, "\"2044\"", "\"40\"")
        postInfo = string.gsub(postInfo, "\"2030\"", "\"41\"")
        
        postInfo = string.gsub(postInfo, "131607", "牌局结束")
        postInfo = string.gsub(postInfo, "131591", "亮牌")
        postInfo = string.gsub(postInfo, "131592", "奖池变动")
        postInfo = string.gsub(postInfo, "131602", "抽水")
        postInfo = string.gsub(postInfo, "131605", "新手盲")
        postInfo = string.gsub(postInfo, "131606", "惩罚盲")
        postInfo = string.gsub(postInfo, "131597", "下前注")
        postInfo = string.gsub(postInfo, "131586", "牌局开始")
        postInfo = string.gsub(postInfo, "131598", "设置庄家位")
        postInfo = string.gsub(postInfo, "131596", "下盲注")
        postInfo = string.gsub(postInfo, "131587", "发手牌")
        postInfo = string.gsub(postInfo, "131588", "翻牌")
        postInfo = string.gsub(postInfo, "131589", "转牌")
        postInfo = string.gsub(postInfo, "131590", "河牌")
        postInfo = string.gsub(postInfo, "2147614979", "弃牌")
        postInfo = string.gsub(postInfo, "131600", "超时")
        postInfo = string.gsub(postInfo, "2147614977", "跟注")
        postInfo = string.gsub(postInfo, "2147614978", "加注")
        postInfo = string.gsub(postInfo, "2147614981", "全下")
        postInfo = string.gsub(postInfo, "2147614980", "看牌")
        postInfo = string.gsub(postInfo, "2147614982", "取消托管")
        postInfo = string.gsub(postInfo, "131593", "牌局派奖")
        
        postInfo = string.gsub(postInfo, "\"0_2\"", "\"A_2\"")
        postInfo = string.gsub(postInfo, "\"0_3\"", "\"A_3\"")
        postInfo = string.gsub(postInfo, "\"0_4\"", "\"A_4\"")
        postInfo = string.gsub(postInfo, "\"0_5\"", "\"A_5\"")
        postInfo = string.gsub(postInfo, "\"0_6\"", "\"A_6\"")
        postInfo = string.gsub(postInfo, "\"0_7\"", "\"A_7\"")
        postInfo = string.gsub(postInfo, "\"0_8\"", "\"A_8\"")
        postInfo = string.gsub(postInfo, "\"0_9\"", "\"A_9\"")
        postInfo = string.gsub(postInfo, "\"0_10\"", "\"A_10\"")
        postInfo = string.gsub(postInfo, "\"0_J\"", "\"A_J\"")
        postInfo = string.gsub(postInfo, "\"0_Q\"", "\"A_Q\"")
        postInfo = string.gsub(postInfo, "\"0_K\"", "\"A_K\"")
        postInfo = string.gsub(postInfo, "\"0_A\"", "\"A_A\"")
        
        postInfo = string.gsub(postInfo, "\"1_2\"", "\"B_2\"")
        postInfo = string.gsub(postInfo, "\"1_3\"", "\"B_3\"")
        postInfo = string.gsub(postInfo, "\"1_4\"", "\"B_4\"")
        postInfo = string.gsub(postInfo, "\"1_5\"", "\"B_5\"")
        postInfo = string.gsub(postInfo, "\"1_6\"", "\"B_6\"")
        postInfo = string.gsub(postInfo, "\"1_7\"", "\"B_7\"")
        postInfo = string.gsub(postInfo, "\"1_8\"", "\"B_8\"")
        postInfo = string.gsub(postInfo, "\"1_9\"", "\"B_9\"")
        postInfo = string.gsub(postInfo, "\"1_10\"", "\"B_10\"")
        postInfo = string.gsub(postInfo, "\"1_J\"", "\"B_J\"")
        postInfo = string.gsub(postInfo, "\"1_Q\"", "\"B_Q\"")
        postInfo = string.gsub(postInfo, "\"1_K\"", "\"B_K\"")
        postInfo = string.gsub(postInfo, "\"1_A\"", "\"B_A\"")
        
        postInfo = string.gsub(postInfo, "\"2_2\"", "\"C_2\"")
        postInfo = string.gsub(postInfo, "\"2_3\"", "\"C_3\"")
        postInfo = string.gsub(postInfo, "\"2_4\"", "\"C_4\"")
        postInfo = string.gsub(postInfo, "\"2_5\"", "\"C_5\"")
        postInfo = string.gsub(postInfo, "\"2_6\"", "\"C_6\"")
        postInfo = string.gsub(postInfo, "\"2_7\"", "\"C_7\"")
        postInfo = string.gsub(postInfo, "\"2_8\"", "\"C_8\"")
        postInfo = string.gsub(postInfo, "\"2_9\"", "\"C_9\"")
        postInfo = string.gsub(postInfo, "\"2_10\"", "\"C_10\"")
        postInfo = string.gsub(postInfo, "\"2_J\"", "\"C_J\"")
        postInfo = string.gsub(postInfo, "\"2_Q\"", "\"C_Q\"")
        postInfo = string.gsub(postInfo, "\"2_K\"", "\"C_K\"")
        postInfo = string.gsub(postInfo, "\"2_A\"", "\"C_A\"")
        
        postInfo = string.gsub(postInfo, "\"3_2\"", "\"D_2\"")
        postInfo = string.gsub(postInfo, "\"3_3\"", "\"D_3\"")
        postInfo = string.gsub(postInfo, "\"3_4\"", "\"D_4\"")
        postInfo = string.gsub(postInfo, "\"3_5\"", "\"D_5\"")
        postInfo = string.gsub(postInfo, "\"3_6\"", "\"D_6\"")
        postInfo = string.gsub(postInfo, "\"3_7\"", "\"D_7\"")
        postInfo = string.gsub(postInfo, "\"3_8\"", "\"D_8\"")
        postInfo = string.gsub(postInfo, "\"3_9\"", "\"D_9\"")
        postInfo = string.gsub(postInfo, "\"3_10\"", "\"D_10\"")
        postInfo = string.gsub(postInfo, "\"3_J\"", "\"D_J\"")
        postInfo = string.gsub(postInfo, "\"3_Q\"", "\"D_Q\"")
        postInfo = string.gsub(postInfo, "\"3_K\"", "\"D_K\"")
        postInfo = string.gsub(postInfo, "\"3_A\"", "\"D_A\"")
        -- dump(postInfo)
    end
    
    local t = os.date("*t", os.time())
    local tmp = string.format("%02d日%02d时%02d分",t.day,t.hour,t.min)
    
    local name =tmp
    local targetPlatform = device.platform 
    if targetPlatform=="ios" or targetPlatform=="mac" then
        name = name.."iOS"
        DBHttpRequest:sendBoardInfo(handler(self, self.httpResponse), BoardInfo:getInstance().handID, name,postInfo, "iOS")
    end
    if targetPlatform=="android" then
        name = name.."Android"
        DBHttpRequest:sendBoardInfo(handler(self, self.httpResponse), BoardInfo:getInstance().handID,name, postInfo, "android")
    end
    if targetPlatform=="window" then
        name = name.."windowsTest"
        DBHttpRequest:sendBoardInfo(handler(self, self.httpResponse), BoardInfo:getInstance().handID, name, postInfo, "windowsTest")
    end
end

-- function BaseRoom:reqUploadBoardInfo()
--     local msg
--     local msgStr = ""
--     for i=1,#BoardInfo:getInstance().commandInfo do
--         msgStr=BoardInfo:getInstance().commandInfo[i]
--         BoardInfo:getInstance().postCommandString = BoardInfo:getInstance().postCommandString..msgStr..","
--     end
--     BoardInfo:getInstance().commandInfo = nil
--     BoardInfo:getInstance().commandInfo = {}
--     local postInfo = BoardInfo:getInstance().tableInfo
--     if(string.len(BoardInfo:getInstance().postCommandString)>1) then
--         local cmdStr ="\"A3\":["..BoardInfo:getInstance().postCommandString.."],"
--         postInfo = "{"..cmdStr..string.sub(postInfo, 2)
--         postInfo = string.gsub(postInfo, "1008", "A1")
--         postInfo = string.gsub(postInfo, "2001", "A2")
        
--         postInfo = string.gsub(postInfo, "1002", "A4")
--         postInfo = string.gsub(postInfo, "1007", "A5")
--         postInfo = string.gsub(postInfo, "1003", "A6")
--         postInfo = string.gsub(postInfo, "2002", "A7")
--         postInfo = string.gsub(postInfo, "3026", "A8")
--         postInfo = string.gsub(postInfo, "2006", "A9")
--         postInfo = string.gsub(postInfo, "30A5", "10")
--         postInfo = string.gsub(postInfo, "200F", "11")
--         postInfo = string.gsub(postInfo, "2003", "12")
--         postInfo = string.gsub(postInfo, "2004", "13")
--         postInfo = string.gsub(postInfo, "2005", "14")
--         postInfo = string.gsub(postInfo, "2026", "15")
--         postInfo = string.gsub(postInfo, "2011", "16")
        
--         postInfo = string.gsub(postInfo, "2013", "18")
--         postInfo = string.gsub(postInfo, "2014", "19")
--         postInfo = string.gsub(postInfo, "2015", "20")
--         postInfo = string.gsub(postInfo, "2008", "21")
--         postInfo = string.gsub(postInfo, "2009", "22")
--         postInfo = string.gsub(postInfo, "1005", "23")
--         postInfo = string.gsub(postInfo, "202A", "24")
--         postInfo = string.gsub(postInfo, "201C", "25")
--         postInfo = string.gsub(postInfo, "200B", "26")
--         postInfo = string.gsub(postInfo, "200C", "27")
--         postInfo = string.gsub(postInfo, "2019", "28")
--         postInfo = string.gsub(postInfo, "2018", "29")
--         postInfo = string.gsub(postInfo, "200A", "30")
--         postInfo = string.gsub(postInfo, "2039", "31")
--         postInfo = string.gsub(postInfo, "203C", "32")
--         postInfo = string.gsub(postInfo, "201F", "33")
--         postInfo = string.gsub(postInfo, "2020", "34")
--         postInfo = string.gsub(postInfo, "2022", "35")
--         postInfo = string.gsub(postInfo, "203E", "36")
--         postInfo = string.gsub(postInfo, "202C", "37")
--         postInfo = string.gsub(postInfo, "2045", "38")
--         postInfo = string.gsub(postInfo, "2021", "39")
--         postInfo = string.gsub(postInfo, "2044", "40")
--         postInfo = string.gsub(postInfo, "2030", "41")
        
--         postInfo = string.gsub(postInfo, "131607", "牌局结束")
--         postInfo = string.gsub(postInfo, "131591", "亮牌")
--         postInfo = string.gsub(postInfo, "131592", "奖池变动")
--         postInfo = string.gsub(postInfo, "131602", "抽水")
--         postInfo = string.gsub(postInfo, "131605", "新手盲")
--         postInfo = string.gsub(postInfo, "131606", "惩罚盲")
--         postInfo = string.gsub(postInfo, "131597", "下前注")
--         postInfo = string.gsub(postInfo, "131586", "牌局开始")
--         postInfo = string.gsub(postInfo, "131598", "设置庄家位")
--         postInfo = string.gsub(postInfo, "131596", "下盲注")
--         postInfo = string.gsub(postInfo, "131587", "发手牌")
--         postInfo = string.gsub(postInfo, "131588", "翻牌")
--         postInfo = string.gsub(postInfo, "131589", "转牌")
--         postInfo = string.gsub(postInfo, "131590", "河牌")
--         postInfo = string.gsub(postInfo, "2147614979", "弃牌")
--         postInfo = string.gsub(postInfo, "131600", "超时")
--         postInfo = string.gsub(postInfo, "2147614977", "跟注")
--         postInfo = string.gsub(postInfo, "2147614978", "加注")
--         postInfo = string.gsub(postInfo, "2147614981", "全下")
--         postInfo = string.gsub(postInfo, "2147614980", "看牌")
--         postInfo = string.gsub(postInfo, "2147614982", "取消托管")
--         postInfo = string.gsub(postInfo, "131593", "牌局派奖")
        
--         postInfo = string.gsub(postInfo, "0_2", "A_2")
--         postInfo = string.gsub(postInfo, "0_3", "A_3")
--         postInfo = string.gsub(postInfo, "0_4", "A_4")
--         postInfo = string.gsub(postInfo, "0_5", "A_5")
--         postInfo = string.gsub(postInfo, "0_6", "A_6")
--         postInfo = string.gsub(postInfo, "0_7", "A_7")
--         postInfo = string.gsub(postInfo, "0_8", "A_8")
--         postInfo = string.gsub(postInfo, "0_9", "A_9")
--         postInfo = string.gsub(postInfo, "0_10", "A_10")
--         postInfo = string.gsub(postInfo, "0_J", "A_J")
--         postInfo = string.gsub(postInfo, "0_Q", "A_Q")
--         postInfo = string.gsub(postInfo, "0_K", "A_K")
--         postInfo = string.gsub(postInfo, "0_A", "A_A")
        
--         postInfo = string.gsub(postInfo, "1_2", "B_2")
--         postInfo = string.gsub(postInfo, "1_3", "B_3")
--         postInfo = string.gsub(postInfo, "1_4", "B_4")
--         postInfo = string.gsub(postInfo, "1_5", "B_5")
--         postInfo = string.gsub(postInfo, "1_6", "B_6")
--         postInfo = string.gsub(postInfo, "1_7", "B_7")
--         postInfo = string.gsub(postInfo, "1_8", "B_8")
--         postInfo = string.gsub(postInfo, "1_9", "B_9")
--         postInfo = string.gsub(postInfo, "1_10", "B_10")
--         postInfo = string.gsub(postInfo, "1_J", "B_J")
--         postInfo = string.gsub(postInfo, "1_Q", "B_Q")
--         postInfo = string.gsub(postInfo, "1_K", "B_K")
--         postInfo = string.gsub(postInfo, "1_A", "B_A")
        
--         postInfo = string.gsub(postInfo, "2_2", "C_2")
--         postInfo = string.gsub(postInfo, "2_3", "C_3")
--         postInfo = string.gsub(postInfo, "2_4", "C_4")
--         postInfo = string.gsub(postInfo, "2_5", "C_5")
--         postInfo = string.gsub(postInfo, "2_6", "C_6")
--         postInfo = string.gsub(postInfo, "2_7", "C_7")
--         postInfo = string.gsub(postInfo, "2_8", "C_8")
--         postInfo = string.gsub(postInfo, "2_9", "C_9")
--         postInfo = string.gsub(postInfo, "2_10", "C_10")
--         postInfo = string.gsub(postInfo, "2_J", "C_J")
--         postInfo = string.gsub(postInfo, "2_Q", "C_Q")
--         postInfo = string.gsub(postInfo, "2_K", "C_K")
--         postInfo = string.gsub(postInfo, "2_A", "C_A")
        
--         postInfo = string.gsub(postInfo, "3_2", "D_2")
--         postInfo = string.gsub(postInfo, "3_3", "D_3")
--         postInfo = string.gsub(postInfo, "3_4", "D_4")
--         postInfo = string.gsub(postInfo, "3_5", "D_5")
--         postInfo = string.gsub(postInfo, "3_6", "D_6")
--         postInfo = string.gsub(postInfo, "3_7", "D_7")
--         postInfo = string.gsub(postInfo, "3_8", "D_8")
--         postInfo = string.gsub(postInfo, "3_9", "D_9")
--         postInfo = string.gsub(postInfo, "3_10", "D_10")
--         postInfo = string.gsub(postInfo, "3_J", "D_J")
--         postInfo = string.gsub(postInfo, "3_Q", "D_Q")
--         postInfo = string.gsub(postInfo, "3_K", "D_K")
--         postInfo = string.gsub(postInfo, "3_A", "D_A")
--         dump(postInfo)
--     end
    
--     local t = os.date("*t", os.time())
--     local tmp = string.format("%02d日%02d时%02d分",t.day,t.hour,t.min)
    
--     local name =tmp
--     local targetPlatform = device.platform 
--     dump(targetPlatform)
--     if targetPlatform=="ios" or targetPlatform=="mac" then
--         name = name.."iOS"
--         DBHttpRequest:sendBoardInfo(handler(self, self.httpResponse), BoardInfo:getInstance().handID, name,postInfo, "iOS")
--     end
--     if targetPlatform=="android" then
--         name = name.."Android"
--         DBHttpRequest:sendBoardInfo(handler(self, self.httpResponse), BoardInfo:getInstance().handID,name, postInfo, "android")
--     end
--     if targetPlatform=="window" then
--         name = name.."windowsTest"
--         DBHttpRequest:sendBoardInfo(handler(self, self.httpResponse), BoardInfo:getInstance().handID, name, postInfo, "windowsTest")
--     end
-- end


function BaseRoom:showChatOrEmotion(isChat)

    if(self.m_myselfSeatId>=0) then
    
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showChatOrEmotionDialog_Callback(self.m_roomInfo.tableId,isChat)
        end
    else
    
        if(self.m_pCallbackUI) then
            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
                                                            self.m_roomInfo.tableId,
                                                            Lang_OnlySitCanChat,
                                                            myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin
                                                            )
        end
    end
end
--显示购买筹码框
function BaseRoom:callBuyDialog(isAdd, needShowAutoBuySign, currentShow)
    needShowAutoBuySign = needShowAutoBuySign and needShowAutoBuySign or false
end
--显示快速充值框
function BaseRoom:callQuickRechargeDialog(isAdd)
    if self.m_childRoom then
        -- self.m_childRoom:callBuyDialog(true, false, 1)
        self.m_childRoom:callBuyDialog(true)
    else
        self:callBuyDialog(true)
        self:callBuyDialog(true)
    end
end

function BaseRoom:autoBuyinOrRebuy()

end
function BaseRoom:showOperateGuideBubble()

end
function BaseRoom:promptWaitNextHand()

end

--破产保护请求
function BaseRoom:bankruptRequest()

    
    local seat = self:getSeat(self.m_myselfSeatId)
    if(not seat) then 
        return
    end
    if(self:myselfIsPlaying()and seat.seatChips<=0 and 
       myInfo.data.brokeMoney > (self:getMyTotalMoney()+seat.seatChips) and 
       not self.m_bIsBroken) then       --破产用户
    
        
            if(TRUNK_VERSION==DEBAO_TRUNK) then
                if(myInfo.data.isNewer) then
        
                    DBHttpRequest:getAccountInfo(handler(self,self.httpResponse))
                
                else
        
--            最小买入大于80跳充值, 否则跳免费金币
                    if (self.m_roomInfo.gameMinBuyin>8000) then 
                        if(myInfo.data.payamount<=0) then
                
                            self.m_pCallbackUI:showFirstChargeDialog_Callback(self.m_roomInfo.tableId,1,Lang_FirstOldBroken) --老用户提示首充活动
                        else
                
                            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                Lang_OldUserBankrupt,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                true,false,BUYINFAIL_ACTION_QUITEROOM)
                        end
                    else
                        self.m_pCallbackUI:showFreeGoldDialog_Callback(self.m_roomInfo.tableId)
                    end
            
            
                end
            else
                if(myInfo.data.isNewer and self.m_roomInfo.smallBlind<=50) then
        
                    DBHttpRequest:fetchRookieProtection(handler(self,self.httpResponse))
                
                else
        
--            最小买入大于80跳充值, 否则跳免费金币
                    if (self.m_roomInfo.gameMinBuyin>8000) then 
                        if(myInfo.data.payamount<=0) then
                
                            self.m_pCallbackUI:showFirstChargeDialog_Callback(self.m_roomInfo.tableId,1,Lang_FirstOldBroken) --老用户提示首充活动
                        else
                
                            self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                Lang_OldUserBankrupt,myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                true,false,BUYINFAIL_ACTION_QUITEROOM)
                        end
                    else
                        self.m_pCallbackUI:showFreeGoldDialog_Callback(self.m_roomInfo.tableId)
                    end
            
            
                end
            end      
    else
        if self.m_childRoom then
            self.m_childRoom:autoBuyinOrRebuy()--自动买入
        else
            self:autoBuyinOrRebuy()--自动买入
        end
    end
end

function  BaseRoom:transformSeatNoForRush(seatNo)

    return seatNo
end

function  BaseRoom:reqMyOperateDelay()
    self.tcpRequest:delayOperate(self.m_roomInfo.tableId, self.m_roomInfo.sequence)
end

function  BaseRoom:reqApplyPublicCard()
    self.tcpRequest:applyPublicCard(self.m_roomInfo.tableId)
end

function  BaseRoom:reqLeaveSitProtect()
    self.tcpRequest:applyTrusteeshipProtect(self.m_roomInfo.tableId)
end

return BaseRoom