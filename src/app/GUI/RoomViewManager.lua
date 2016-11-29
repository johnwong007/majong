require("app.Tools.EStringTime")
local RoomViewManager = class("RoomViewManager", function()
		return display.newLayer()
	end)

function RoomViewManager:createRoomViewManager(isRush)
	local manager = RoomViewManager:new()
	if manager.m_roomManager then
		manager.m_roomManager:setIsRush(isRush)
	end
	return manager
end

function RoomViewManager:ctor()
	self.m_isFromMainPage = false
	self.m_isGameType = false
	self.m_networkAlertView = nil
	self.m_isFromPKMatch = false
	self.m_enterClubOrNot = false

	self.m_isFromMainPage = false
    self.m_loadingView = require("app.GUI.LoadingSceneLayer"):new()
    self:addChild(self.m_loadingView, MAX_ZORDER)

    self.m_viewDic = {}

	self.m_roomManager = require("app.Logic.Room.RoomManager"):new()
	self.m_roomManager:setRoomManagerCallback(self)
	self:addChild(self.m_roomManager)

	self:retain()
    self.m_loadingView:retain()

    self:setNodeEventEnabled(true)
	-- self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
	-- 		if event.name == "back" then
	-- 			self:keyBackClicked()
	-- 		end
	-- 	end)
end

function RoomViewManager:setEnterClubOrNot(value)
	self.m_roomManager:setEnterClubOrNot(value)
end

function RoomViewManager:onExit()
		if self.m_loadingView then
			self.m_loadingView:release()
		end

		-- if self.m_roomManager then
		-- 	self.m_roomManager = nil
		-- end

		self:release()
		self.m_viewDic = nil
		self:removeMemory()
end
function RoomViewManager:removeMemory()
    local memoryPath = {}
    memoryPath[1] = require("app.GUI.allrespath.TablePath")
    memoryPath[2] = require("app.GUI.allrespath.PokerPath")
    memoryPath[3] = require("app.GUI.allrespath.GameScenePath")
   for j = 1,#memoryPath do 
        for i,v in pairs(memoryPath[j]) do
            display.removeSpriteFrameByImageName(v)
        end
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function RoomViewManager:gotoMainPageView()
	local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
	-- local GameLayerManager = require("app.GUI.GameLayerManager")
	-- GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD, cc.Director:getInstance():getRunningScene(),0,1) 
end

function RoomViewManager:keyBackClicked()
	if self.m_loadingView and self.m_loadingView:getParent() then
		if self.m_isFromMainPage then
			local mainpageScene = require("app.GUI.mainPage.MainPageView"):new()
			GameSceneManager:switchSceneWithNode(mainpageScene)
		end
	else
		for k,v in pairs(self.m_viewDic) do
			local roomView = v
			if roomView then
				roomView:leaveRoom()
			end
		end
	end
end

function RoomViewManager:getRoomView(tableId)
	local room = nil
	if self.m_viewDic and self.m_viewDic[tableId] then
		room = self.m_viewDic[tableId]
	end
	return room
end

--[[快速开始]]
function RoomViewManager:quickStart()
	if self.m_roomManager then
		self.m_roomManager:quickStart()
	end
end

--[[进入房间]]
function RoomViewManager:enterRoomWithTableId(tableId, passWord)
	if self.m_roomManager then
		self.m_roomManager:enterRoomWithTableId(tableId, passWord)
	end
end

--[[进入撮合制房间]]
function RoomViewManager:enterRoomRandom(params)
	if self.m_roomManager then
		self.m_roomManager:enterRoomRandom(params)
	end
end

function RoomViewManager:enterRoomWithRushInfo(dataModel)
	if self.m_roomManager then
		self.m_roomManager:enterRoomWithRushInfo(dataModel)
	end
end

--[[创建房间]]
function RoomViewManager:createRoomView_Callback(tableId, seatNum, isFromMainPage, isPKMatch, isRush, tableOwnerId)
	--[[如果是已经存在的tableId 直接切换]]
	-- dump("createRoomView_Callback")
	local room = nil
	room = self:getRoomView(tableId)
	if room==nil then
		--[[否则创建并保存]]
		room = require("app.GUI.RoomView"):create(tableId,seatNum,isRush,tableOwnerId)
		self.m_viewDic[tableId] = room
		room.m_isFromMainPage = self.m_isFromMainPage--[[记录是从主页还是大厅进入房间的]]
		room.m_isGameType = self.m_isGameType--[[记录是从游戏场进入的还是比赛长进入的]]
		room.m_fromWhere = self.m_fromWhere
		if self.m_isFromPKMatch==true then
			room.m_isFromPKMatch = true
		else
			room.m_isFromPKMatch = isPKMatch
		end
	else
		-- 如果已经已经存在，重置资源
		room:clearRoomViewAllElement_Callback()
	end
	room:setRoomManager(self.m_roomManager)   --RoomView获取RoomManger指针
	if not room:getParent() then
		self:addChild(room)
	end
end

--[[显示房间类型（新手场10/20)]]
function RoomViewManager:showRoomInfo_Callback(tableId, tableName, smallBlind, bigBlind)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showRoomInfo_Callback(tableName, smallBlind, bigBlind)
	end
end

function RoomViewManager:showTourneyRoomInfo_Callback(matchId, bonusName, gainName, curPlayer, tableId, tableName, smallBlind, bigBlind, bRebuy)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showTourneyRoomInfo_Callback(matchId,bonusName,gainName,curPlayer,tableName, smallBlind, bigBlind, bRebuy)
	end
end

function RoomViewManager:showTourneyPKRoomInfo_Callback(tableId, tableName, smallBlind, bigBlind)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showTourneyPKRoomInfo_Callback(tableName, smallBlind, bigBlind)
	end
end

function RoomViewManager:showSngRoomInfo_Callback(matchId, bonusName, gainName, curPlayer, tableId, tableName, smallBlind, bigBlind, bRebuy)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showSngRoomInfo_Callback(matchId,bonusName,gainName,curPlayer,tableName, smallBlind, bigBlind, bRebuy)
	end
end

--[[玩家离开房间]]
function RoomViewManager:leaveTable_Callback(isMyself, tableId, leaveType)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:leaveTable_Callback(isMyself,leaveType)
	end
end

--[[旋转所有玩家座位]]
function RoomViewManager:rotateAllSeats_Callback(tableId, seatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:rotateAllSeats_Callback(seatId)
	end
end

--[[玩家坐下]]
function RoomViewManager:playerSit_Callback(isMyself, tableId, seatId, name,
	sex, imageURL, userId, diamond)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerSit_Callback(isMyself,seatId,name,sex,imageURL,userId,diamond)
	end
end

--[[玩家站起]]
function RoomViewManager:playerSitOut_Callback(isMyself, myselfInSeat, tableId, seatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerSitOut_Callback(isMyself,myselfInSeat,seatId)
	end
end

--[[更新庄家的位置]]
function RoomViewManager:updateDealerPos_Callback(tableId, seatId, isAnimate)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateDealerPos_Callback(seatId,isAnimate)
	end
end

--[[显示公共牌]]
function RoomViewManager:showPublicCard_Callback(tableId, cardIndex, cardName, isAnimate)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showPublicCard_Callback(cardIndex, cardName, isAnimate)
	end
end

--[[显示玩家的牌]]
function RoomViewManager:showPlayerCards_Callback(tableId, seatId, poker1, poker2, isAnimation)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showPlayerCards_Callback(seatId,poker1,poker2,isAnimation)
	end
end

--[[有动画发牌]]
function RoomViewManager:dispatchPlayerCards_Callback(tableId, seatNo, index, delay, cardValue)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:dispatchPlayerCards_Callback(seatNo,index,delay,cardValue)
	end
end

--[[接收到handFinish消息处理]]
function RoomViewManager:dealHandFinish_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:dealHandFinish_Callback()
	end
end

--[[牌局结束清牌]]
function RoomViewManager:clearAllPlayerCards_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:clearAllPlayerCards_Callback(0.0)
	end
end

--[[牌局重连清理]]
function RoomViewManager:clearRoomViewAllElement_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:clearRoomViewAllElement_Callback()
	end
end

--[[Rush牌局清理]]
function RoomViewManager:clearRoomViewForRush_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:clearRoomViewForRush_Callback()
	end
end

--[[Rush显示快速弃牌]]
function RoomViewManager:showFastFoldForRush_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFastFoldForRush_Callback()
	end
end

function RoomViewManager:updateUserSngInfo(tableId, seatId, winTimes)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateUserSngInfo(seatId, winTimes)
	end
end

--[[玩家跟注(参数:座位号，跟注数，跟注后桌面钱数，跟注后Cell显示的钱数)]]
function RoomViewManager:playerCall_Callback(isMyself, tableId, seatId, callChips, seatChips, userChips)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerCall_Callback(isMyself,seatId,callChips,seatChips,userChips)
		-- roomView:showPreOperate()
	end
end

function RoomViewManager:showProtectedDialog_Callback(tableId, times, awardNum, maxBuyin, minBuyin)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showProtectedDialog_Callback(times, awardNum, maxBuyin, minBuyin)
	end
end

function RoomViewManager:showFreeGoldDialog_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFreeGoldDialog_Callback()
	end
end

function RoomViewManager:showFirstChargeDialog_Callback(tableId, showType, desc)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFirstChargeDialog_Callback(showType,desc)
	end
end

--[[玩家加注]]
function RoomViewManager:playerRaise_Callback(isMyself, tableId, seatId, raiseChips, seatChips, userChips, isReRaise)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerRaise_Callback(isMyself,seatId,raiseChips,seatChips,userChips, isReRaise)
		-- roomView:showPreOperate()
	end
end

--[[玩家AllIn]]
function RoomViewManager:playerAllin_Callback(isMyself, tableId, seatId, allInChips, seatChips, userChips)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerAllin_Callback(isMyself,seatId,allInChips,seatChips,userChips)
		-- roomView:showPreOperate()
	end
end


--[[
 玩家静态设置自己筹码(包含下盲注，初始进房间,购买筹码成功)
 handChips>0表示有发筹码动画
 roundChips>0表示有设置玩家桌前筹码
 userChips 表示图像显示的更新后筹码
]]
function RoomViewManager:playerChipsUpdate_Callback(tableId, seatId, handChips, roundChips, userChips)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerChipsUpdate_Callback(seatId,handChips,roundChips,userChips)
	end
end

--[[初始设置奖池和回收筹码]]
function RoomViewManager:updatePublicPots_Callback(tableId, potNum, index, potChips, isAnimate)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updatePublicPots_Callback(potNum,index,potChips,isAnimate)
	end
end

--[[底池返水动画(不结算筹码]]
function RoomViewManager:potReturn_Callback(tableId, prize, userId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:potReturn_Callback(userId,prize)
	end
end

--[[派奖参数意思分别为(从奖池，到座位，分的钱，分后玩家的钱，赢牌类型，最大五张牌)]]
function RoomViewManager:updatePrizePots_Callback(isMyself, tableId, potNum, fromPot, toSeat, prize, userChips, cardType, maxCard)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updatePrizePots_Callback(isMyself,potNum,fromPot,toSeat,prize,userChips,cardType,maxCard)
	end
end

--[[取消可能是自己的高亮牌]]
function RoomViewManager:prizeCancelHighLightPokers_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:prizeCancelHighLightPokers_Callback()
	end
end

--[[取消所有凸起牌]]
function RoomViewManager:prizeCancelUpPokers_Callback(tableId, maxCard)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:prizeCancelUpPokers_Callback(maxCard)
	end
end

--[[当前正在下注玩家]]
function RoomViewManager:waitForPlayerActioning_Callback(isMyself, tableId, seatId, remainTime, totalTime, callNum, mySeatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:waitForPlayerActioning_Callback(isMyself,seatId,remainTime,totalTime, callNum, mySeatId)
	end
end

--[[等待玩家亮牌]]
function RoomViewManager:waitForPlayerShowDown_Callback(tableId, seatId, card1, card2)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:waitForPlayerShowDown_Callback(seatId,card1,card2)
	end
end

--[[取消托管和我回来了]]
function RoomViewManager:playerCancelTrustee_Callback(tableId, isMyself, seatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerCancelTrustee_Callback(isMyself, seatId)
	end
end

--[[聊天信息]]
function RoomViewManager:showChatMsg_Callback(isMyself, tableId, seatId, userName, chatMsg, chargeChips)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showChatMsg_Callback(isMyself,seatId,userName,chatMsg,chargeChips)
	end
end

--[[弃牌动作]]
function RoomViewManager:playerFold_Callback(isMyself, isTourneyAndTrust, tableId, seatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerFold_Callback(isMyself,isTourneyAndTrust,seatId)
	end
end

--[[看牌动作]]
function RoomViewManager:playerCheck_Callback(isMyself, tableId, seatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerCheck_Callback(isMyself,seatId)
        -- roomView:showPreOperate()
	end
end

--[[
 牌型提示
 自己看到的发2567张牌时候成手牌
]]
function RoomViewManager:hightLightMyCards(tableId, seatId, cardsIndex, res)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:hightLightMyCards(seatId,cardsIndex,res)
	end
end

--[[买入筹码对话框提示]]
function RoomViewManager:showBuyinDiaglog_Callback(tableId, myChips, minBuyChips, maxBuyChips, defaultValue, bigBlind, tableStyle, isAdd, needShowAutoBuySign, serviceCharge, currentShow)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showBuyinDiaglog_Callback(myChips,minBuyChips,maxBuyChips,defaultValue,bigBlind,tableStyle,isAdd, needShowAutoBuySign, serviceCharge, currentShow)
	end
end

--[[请求加为好友]]
function RoomViewManager:actionFriend_Callback(tableId, seatId, userName, bAdd, bSuccess)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:applyFriend_Callback(userId, userName, bAdd, bSuccess)
	end
end

--[[玩家自己操作]]
----------------------------------------------------------
--[[我回来了]]
function RoomViewManager:playerOperateBackSeat(isMyself, tableId, seatId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:playerTimeout(isMyself,seatId)
	end
end

--[[预操作面板]]
function RoomViewManager:playerPreOperate(tableId, chips)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showPreOperate(chips)
	end
end

--[[弃牌看牌加注]]
function RoomViewManager:playerFoldCheckRaise(tableId, minRaNum, maxRaNum, blindNum, pot, extra)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFoldCheckRaiseOp(minRaNum,maxRaNum,blindNum,pot,extra)
	end
end

--[[弃牌跟注加注]]
function RoomViewManager:playerFoldCallRaise(tableId, callNum, minRaNum, maxRaNum, blindNum, pot, extra)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFoldCallRaiseOp(callNum,minRaNum,maxRaNum,blindNum,pot,extra)
	end
end

--[[弃牌Allin加注]]
function RoomViewManager:playerFoldCallAllin(tableId, callNum)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFoldCallAllIn(callNum)
	end
end

--[[清除预选]]
function RoomViewManager:playerOperateUnselectPre(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:unselectPreOperate()
	end
end

--[[ 
 *  上海电竞赛弹窗
 *
 *  @param tableId <#tableId description#>
 *  @param matchId <#matchId description#>
 *  @param flag    <#flag description#>
 ]]
function RoomViewManager:showSpecialTourneyResultDialog(tableId, matchId, flag)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showSpecialTourneyResultDialog(matchId,flag)
	end
end

--[[网络断线]]
function RoomViewManager:networkException_Callback(errorType)
	local content
	if errorType == NO_NETWORK then --无网络
		content = Lang_NO_NETWORK
	elseif errorType == ACCOUNT_EXCEPTION then --帐号登录异常(重连)
		content = Lang_ACCOUNT_ERROR
	elseif errorType == DATA_ERROR then --请求数据出错
		content = Lang_REQUEST_DATA_ERROR
	elseif errorType == OTHER_ERROR then --其他错误
		content = Lang_REQUEST_DATA_ERROR
	elseif errorType == QUICKSTART_ERROR then
		content = Lang_QuickStartError
	elseif errorType == TABLEID_NOEXIST then
		content = Lang_TableIdNotExist
	else
		content = Lang_REQUEST_DATA_ERROR
	end

	self.m_networkAlertView = require("app.Component.EAlertView"):alertView(
        self,self,Lang_Error_Prompt_Title,content,Lang_Button_Cancel,Lang_Button_Confirm)
	self.m_networkAlertView:setTag(100) --网络错误提示
	self.m_networkAlertView:alertShow()
	if errorType == QUICKSTART_ERROR then
		self.m_networkAlertView:setCloseCallback(handler(self, self.gotoMainPageView))
	end
end

function RoomViewManager:showAlertViewCallback(msg)
    local view = require("app.Component.EAlertView"):alertView(self,nil,"温馨提示",msg,"确定")
    
    view:alertShow()
end

function RoomViewManager:quickStartError_Callback(errorType)
	if errorType == QUICKSTART_ERROR then
		local view = require("app.Component.EAlertView"):alertView(
            self,self,Lang_Title_Prompt,Lang_QuickStartErrorNotEnoughMoney,Lang_Button_Cancel,Lang_Button_Charge)
		view:show()
		view:setTag(101) --筹码不够提示充值;
		view:setCloseCallback(handler(self, self.gotoMainPageView))
	elseif errorType == BANKRUPT_ERROR then
		local dialog = require("app.GUI.dialogs.FirstRechargeDialog"):create(self,nil,false,false)
		self:addChild(dialog,MAX_ZORDER)
	end
end

function RoomViewManager:firstChargeCancel(pObj)
	local mainpageScene = require("app.GUI.mainPage.MainPageView"):new()
	GameSceneManager:switchSceneNode(mainpageScene)
end

--[[坐下，购买失败提示]]
function RoomViewManager:showSitAndBuyFailureMsg_Callback(tableId, msg, balance, minBuyin, needShowStore, moreChips, type, isRakePoint)
	local roomView = self:getRoomView(tableId)

	if roomView then
		roomView:showSitAndBuyFailureMsg_Callback(msg,balance,minBuyin,needShowStore,moreChips, type,isRakePoint)
	end
end

--[[显示或者隐藏提示下局开始信息]]
function RoomViewManager:showStartNextHand(tableId, msg, isVisible)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showStartNextHand(msg,isVisible)
	end
end

--[[显示确认退出房间提示]]
function RoomViewManager:showConfirmQuitRoom(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showConfirmQuitRoom()
	end
end

function RoomViewManager:showConfirmQuitTourneyRoom(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showConfirmQuitTourneyRoom()
	end
end

function RoomViewManager:showConfirmQuitSngPkRoom_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showConfirmQuitSngPkRoom()
	end
end

--是否显示房间loading
function RoomViewManager:showRoomLoadingView(isVisible)
	isVisible = false
	if isVisible then
		if self.m_loadingView and self.m_loadingView:getParent()==nil then
			self:addChild(self.m_loadingView,MAX_ZORDER)
		end
	else
		if NEED_SPECIAL then
			CMDelay(GameSceneManager:getCurScene(), 1, function () 
				if self.m_loadingView and self.m_loadingView:getParent() then
					self:removeChild(self.m_loadingView,false)
				end
			end)
		else
			if self.m_loadingView and self.m_loadingView:getParent() then
				self:removeChild(self.m_loadingView,false)
			end
		end
	end
end

--[[显示表情聊天框]]
function RoomViewManager:showChatOrEmotionDialog_Callback(tableId, isChat)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showChatOrEmotionDialog_Callback(isChat)
	end
end

function RoomViewManager:clickButtonAtIndex(alertView, index)
	local tag = alertView:getTag()
    
	if tag == 100 then --网络错误提示
        GameSceneManager:switchSceneWithType(EGSMainPage)
    elseif tag == 101 then --筹码不够提示充值;
    	if index==0 then
        	GameSceneManager:switchSceneWithType(EGSMainPage)
    	else
			GameSceneManager:setJumpLayer(GameSceneManager.AllLayer.SHOP) 
			GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
		end
    end
end

function RoomViewManager:setIsRush(isRush)
	self.m_roomManager:setIsRush(isRush)
end


--[[新手引导]]
function RoomViewManager:showNewerGuideStage(tableId, stage)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showNewerGuideStage(stage)
	end
end

function RoomViewManager:setGuideConfig(tableId, needActionGuide, needGuideHint)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:setGuideConfig(needActionGuide,needGuideHint)
	end
end

function RoomViewManager:showNewerGuideActionHint(tableId, hintType, opHintType)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showNewerGuideActionHint(hintType,opHintType)
	end
end

function RoomViewManager:outCompetitionByElimination_Callback(tableId, userRanking, gainStr, matchPoint, matchName)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:outCompetitionByElimination(userRanking, gainStr, matchPoint, matchName)
	end
end

function RoomViewManager:updateBlind_Callback(tableId, bigBlind, smallBling, type)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateBlind(bigBlind, smallBling, type)
	end
end

function RoomViewManager:updateAnte_Callback(tableId, ante)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateAnte(ante)
	end
end

function RoomViewManager:updateUserRanking_Callback(tableId, userRanking, totoalNum)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateUserRanking(userRanking, totoalNum)
	end
end

function RoomViewManager:showEnterTourneyRoomPrompt(tableId, enterTableId, matchName)
	for key,view in pairs(self.m_viewDic) do
		view:showEnterTourneyRoomPrompt(enterTableId,matchName)
	end
end

function RoomViewManager:MergerTourneyRoom(tableId, enterTableId, matchName)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:MergerTourneyRoom(enterTableId,matchName)
	end
end

function RoomViewManager:showGameWaitPrompt_Callback(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showGameWaitPrompt()
	end
end

function RoomViewManager:setMatchInfo(tableId, matchId, bonusName, gainName, curPlayer)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:setMatchInfo(matchId,bonusName,gainName,curPlayer)
	end
end

function RoomViewManager:showCountDown_Callback(tableId, bstart, startCount, endCount, timeSpan)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showCountDown(bstart, startCount, endCount, timeSpan)
	end
end

function RoomViewManager:showAutoBuyin_Callback(tableId, buyNum)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showAutoBuyin(buyNum)
	end
end

function RoomViewManager:showPushMessage_Callback(type, message)
	for key,view in pairs(self.m_viewDic) do
		view:showPushMessage(type,message)
	end
end

--[[大小盲新手提示(seatNo:座位号,isBigBlind:是否是大盲，不是则表示小盲)]]
function RoomViewManager:showNewerBlindHint(tableId, seatNo, isBigBlind)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showNewerBlindHint(seatNo,isBigBlind)
	end
end

--[[提示领取任务奖励]]
function RoomViewManager:showTaskHappyHourInfo(tableId, taskConfig, happyHourConfig)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showTaskHappyHourInfo(taskConfig,happyHourConfig)
	end
end

function RoomViewManager:changeFirstRechargeButtonStatus(tableId, status)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:changeFirstRechargeButtonStatus(status)
	end
end

--[[更新用户显示信息]]
function RoomViewManager:updateUserShowInfo(tableId, seatId, imageURL, userName)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateUserShowInfo(seatId,imageURL,userName)
	end
end

--[[更新vip等级]]
function RoomViewManager:updateUserVipLevel(tableId, seatId, userid, viplevel)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateUserVipLevel(seatId,userid,viplevel)
	end
end

function RoomViewManager:updateUserCardHandPoint(tableId, seatId, point)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateUserCardHandPoint(seatId,point)
	end
end

--[[决赛桌提示]]
function RoomViewManager:tourneyFinalTable(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:tourneyFinalTable()
	end
end

function RoomViewManager:enabledRebuyButton_Callback(tableId, bEnabled)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:enabledRebuyButton(bEnabled)
	end
end

--[[主动或被动rebuy弹框]]
function RoomViewManager:showRebuyDialog_Callback(payType, tableId, bManually, rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showRebuyDialog(bManually, rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime,payType)
	end
end

function RoomViewManager:showInfoHint_Callback(tableId, infoToShow)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showInfoHint(infoToShow)
	end
end

function RoomViewManager:showRebuyResult_Callback(tableId, rebuyResult, bSecuss)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showRebuyResult(rebuyResult, bSecuss)
	end
end

--[[addon弹框]]
function RoomViewManager:showAddOnDialog_Callback(payType, tableId, bManually, rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showAddOnDialog(bManually, rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime,payType)
	end
end

--[[pk赛进度条]]
function RoomViewManager:showSngUserChipsSlider_Callback(tableId, myChips, otherChips)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showSngUserChipsSlider(myChips, otherChips)
	end
end

function RoomViewManager:sngOutCompetitionByElimination_Callback(tableId, userRanking, mySeatId, theOtherSeadId, mineWins, otherWins, bInActivity)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:sngOutCompetitionByElimination(userRanking, mySeatId, theOtherSeadId, mineWins, otherWins, bInActivity)
	end
end

function RoomViewManager:sngPkOutMessage_Callback()
	for key,view in pairs(self.m_viewDic) do
		view:sngPkOutMessage()
	end
end

function RoomViewManager:uploadBoardInfo(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:uploadBoardInfo()
	end
end

function RoomViewManager:updateBuyInfo(tableId, buyTableInfo)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateBuyInfo(buyTableInfo)
	end
end

function RoomViewManager:showPrivateRoomContent(tableId, isShow, isSng, destroyTime)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showPrivateRoomContent(isShow, isSng, destroyTime)
	end
end

function RoomViewManager:showSngContent(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showSngContent()
	end
end

function RoomViewManager:setTalkButtonVisible(tableId, isVisible)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:setTalkButtonVisible(isVisible)
	end
end

--[[payType:"GOLD"(金币)、"POINT"(德堡钻)]]
function RoomViewManager:setPayType(tableId, payType)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:setPayType(payType)
	end
end

function RoomViewManager:showFinalStatics(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showFinalStatics()
	end
end

function RoomViewManager:showBuyinWaitHint(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showBuyinWaitHint()
	end
end

function RoomViewManager:showTableConfigId(tableId, configId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showTableConfigId(configId)
	end
end

function RoomViewManager:hideOperateBoard(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:hideOperateBoard()
	end
end

function RoomViewManager:hideOperateDelayMenu(tableId)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:hideOperateDelayMenu()
	end
end

function RoomViewManager:showUserOperateDelay(tableId, isMyself, userId, remainTime)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showUserOperateDelay(isMyself, userId, remainTime)
	end
end

function RoomViewManager:updateApplyDelayTime(tableId, times)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateApplyDelayTime(times)
	end
end

function RoomViewManager:setApplyPublicCardVisible(tableId, isVisible)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:setApplyPublicCardVisible(isVisible)
	end
end

function RoomViewManager:showTrusteeshipProtectCallback(tableId, userId, isMyself, remainTime)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:showTrusteeshipProtectCallback(userId, isMyself, remainTime)
	end
end

function RoomViewManager:roomDelayBroadcast_Callback(tableId, remainTime)
	local roomView = self:getRoomView(tableId)
	if roomView then
		roomView:updateRemainTime(remainTime)
	end
end

function RoomViewManager:registerRongYun(callback)
	if self.m_roomManager then
		self.m_roomManager:registerRongYun(callback)
	end
end

return RoomViewManager