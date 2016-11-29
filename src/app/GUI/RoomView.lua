require("app.EConfig")
require("app.GlobalConfig")
require("app.Logic.Config.UserDefaultSetting")
require("app.CommonDataDefine.CommonDataDefine")
require("app.GUI.roomView.RoomViewDefine")
require("app.Logic.Datas.TableData.BoardInfo")
local scheduler = require("framework.scheduler")
require("app.Logic.Room.RoomCallbackUI")
require("app.Tools.StringFormat")
local myInfo = require("app.Model.Login.MyInfo")
local MusicPlayer = require("app.Tools.MusicPlayer")
require("app.Tools.EStringTime")
local QDataActivityList = QManagerData:getCacheData("QDataActivityList")
local imageUtils = require("app.Tools.ImageUtils")

local HELP_SENCE_TAG   =   200
local BGTABLE_SP_TAG    =  300
local SHOWDOWN_VIEW_TAG  = 400
local TABLE_ICON_TAG     = 500

local REBUY_MANUL			=2312
local REBUY_AUTO			=2313
local ADDON_MANUL		=2311
local TASK_TAG			=2314
local HAPPYHOUR_TAG		=2315
local HAPPYHOUR_ANIMATION_TAG	=2317
local	QUICK_RECHAGE_TAG	=2318
local FIRST_RECHARGE_TAG  =2319
local SETTING_TAG =2320
local CARD_TYPE_TAG =2321
local PHONE_CARD_CHARGE =2322
local BACK_MENU_LAYER   =2323

local kProtectDialogTag =2411
local kInsufficientBalanceDialogTag =2412

local MY_POKER_VIEW_TAG =8888
local TOOL_TIP_TAG = 3333
local kRoomViewChatButtonTag	=2413

-- 400x的tag统一给gaf动画使用
local TAG_GAF_RECORD = 4001
local TAG_GAF_RECORD_BG = 4002

local kTagBuyChipDialog = 1000

local RoomView = class("RoomView", function()
		return display.newNode()
	end)

function RoomView:create(tableId, seatNum, isRush, tableOwnerId)
	local room = RoomView:new()
	room.m_onEventWhere = eOnEventUnkowRecharge --[[统计是在哪里走充值流程]]
	room:resetRoomView(tableId,seatNum)
	if isRush then
		room.m_tableType = eRushTable
	end
	room:initRoomView(tableOwnerId)		--[[初始化房间的资源]]
	return room
end

function RoomView:ctor()
	self:setNodeEventEnabled(true)
end


function RoomView:onNodeEvent(event)
	if event == "enter" then
		self:onEnter()
	end
	if event == "exit" then
	self:onExit()
	end
end

function RoomView:onExit()
	self.m_talkButton:removeLocalScheduler()
		if self.timeScheduler then
			scheduler.unscheduleGlobal(self.timeScheduler)
			self.timeScheduler = nil
		end
		if self.m_clearAPCCId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_clearAPCCId)
			self.m_clearAPCCId = nil
		end
    QManagerListener:Detach(eRoomViewID)
end

function RoomView:onEnter()
	TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
	QManagerListener:Attach({{layerID = eRoomViewID,layer = self}})
end

function RoomView:initReplayView()
	self.m_onEventWhere = eOnEventUnkowRecharge --[[统计是在哪里走充值流程]]
	self:resetRoomView("",9)
	self:initRoomView()		--[[初始化房间的资源]]
end

function RoomView:resetRoomView(tableId, seatNum)
	self.m_rebuyBtn = nil
	self.m_matchRankInfo = nil
	self.m_Menubar = nil
	self.m_tableId    = tableId
	self.m_nTotalSeat = seatNum
	self.m_seatOffset = 0
	self.m_bIsRoomClear = false
	self.m_allPotLayer  = nil
	self.m_operateBoard = nil
	self.m_newerGuideLayer = nil
    self.m_freeGoldTimes = 3
    self.m_dealerSeatId = 0
--    self.m_myPokerLayer = nil
	--    uploadflag
	BoardInfo:getInstance().uploadFlag=0
	BoardInfo:getInstance().clearFlag=0
	BoardInfo:getInstance().seatCount = seatNum
	--self.m_uploadBoardInfoButton=nil
	--self.m_chatBtn = nil
	--self.m_picBtn = nil
	self.m_tTimeLabel      = nil
    
	self.m_tourneyBlindInfo = nil
    
	self.m_tableType = eUnknowType
    
	self.m_userDefaultInstance = UserDefaultSetting:getInstance()
    
	self.m_pPlayersArray = {}
    
	self.m_pCommunityCardArray = {}
    
	self.m_pPlayerChip = {}
    
	--------handElement
	self.m_countDown = nil
	self.m_pStartNextHand = nil
    self.m_nextSprite = nil
	--happyhour
	self.m_needActionGuide = false
	self.m_needGuideHint = false
    
	self.m_bEnterTourneyHandFinish = false
    
	self.m_settingButton = nil
--	self.m_pokerTypeButton = nil
	self.m_rebuyButton = nil
	self.m_buyButton = nil
	self.m_newTipButton = nil
	self.m_quickRechargeButton = nil
	self.m_taskButton = nil
    self.m_freeGoldButton = nil
	self.m_happyHourButton = nil
	self.m_firstRechargeButton = nil
	self.m_sngPKSlider = nil
	self.m_myBetChips = 0.0
	self.m_betChips = 0.0
	self.m_chatMsgRecords = {}
end

-- local timeScheduler

function RoomView:initRoomView(tableOwnerId)

	--[[加载poker资源]]
	local visibleSize = cc.Director:getInstance():getWinSize()

	--[[房间背景]]
	    local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES..s_room_bg)
	self.m_roomBg = display.newSprite(tmpFilename)

	self.m_roomBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, display.cy)
		:addTo(self)

	--[[牌桌]]
	self.m_roomTableBg = cc.ui.UIImage.new(s_room_cash_table)
	self.m_roomTableBg:align(display.CENTER, display.cx, display.cy-30)
		:addTo(self,0,BGTABLE_SP_TAG)
	-- self.m_roomBg:setPosition(cc.pAdd(LAYOUT_OFFSET, ROOM_TABLE_POS))

	self.m_tableBg = display.newNode()
		:align(display.CENTER, 0, 0)
		:addTo(self,kZOperateBoard)
	self.m_tableBg:setContentSize(self.m_roomTableBg:getContentSize())
	self.m_tableBg:setPosition(self.m_roomTableBg:getPositionX(), self.m_roomTableBg:getPositionY())

	self.m_heGuan = cc.ui.UIPushButton.new({normal="hg.png", pressed="hg.png", disabled="hg.png"})
		:align(display.CENTER, 480+20, 495+10)
		:addTo(self.m_tableBg)

	self.m_daShang = cc.ui.UIPushButton.new({normal="btn_ds.png", pressed="btn_ds.png", disabled="btn_ds.png"})
		:align(display.CENTER, self.m_heGuan:getPositionX()-80, self.m_heGuan:getPositionY())
		:addTo(self.m_tableBg)
	self.m_daShang:setVisible(false)

	--[[牌桌标志]]
	local tableIcon = cc.ui.UIImage.new(s_room_cash_table_icon)
		:align(display.CENTER, 0, 0)
		-- :addTo(self, 1, TABLE_ICON_TAG)
	tableIcon:setPosition(cc.pAdd(LAYOUT_OFFSET, ROOM_TABLE_ICON_POS))

	--[[info]]
	self.m_infoLabel = display.newTTFLabel({
		text = "",
		font = "Arial",
		size = 24,
		align = cc.ui.TEXT_ALIGNMENT_CENTER,
		color = cc.c3b(255,255,255),
		x = visibleSize.width*0.5,
		y = visibleSize.height*0.5-50,
		-- dimensions = cc.size(120,40)
		})
	self.m_infoLabel:addTo(self):setVisible(false)

	--[[time]]
	self.m_tTimeLabel = cc.Label:createWithSystemFont("17:53", "Arial", 18)
	self.m_tTimeLabel:setColor(cc.c3b(255,255,255))
	self.m_tTimeLabel:setPosition(cc.p(120, display.height-40))
	self.m_tTimeLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.m_tTimeLabel:setColor(cc.c3b(185,185,202))
	self:addChild(self.m_tTimeLabel, 0)
	self:updateTimeLabel(0.0)
	-- 信号指示器
	self.m_signalIndicator = require("app.GUI.roomView.RoomSignalIndicator").new()
		:addTo(self)
		:pos(120 + self.m_tTimeLabel:getContentSize().width, display.height-40)

	self:initRemainTime(tableOwnerId)

	-- [[定时更新]]
	self.timeScheduler = scheduler.scheduleGlobal(handler(self, self.updateTimeLabel), 1)

	-- scheduler.unscheduleGlobal(self.timeScheduler)
	-- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timeScheduler)

	-- [[提示“本局尚未开始，请耐心等待，先观察一下对手吧！”("","",25)]]
	-- self.m_pStartNextHand = cc.ui.UILabel.newTTFLabel_({
	-- 	text = "本局尚未开始，请耐心等待，先观察一下对手吧",
	-- 	font = "Arial",
	-- 	size = 25,
	-- 	color = display.COLOR_BLACK,
	-- 	dimensions = cc.size(250,64),
	-- 	align = cc.ui.TEXT_ALIGNMENT_CENTER,
	-- 	x = LAYOUT_OFFSET.x+480,
	-- 	y = 131
	-- 	})
	-- self:addChild(self.m_pStartNextHand, kZInfoHint)

    self.m_nextSprite = cc.ui.UIImage.new("picdata/table/next.png")
    self.m_nextSprite:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2-60)
    self.m_nextSprite:setVisible(false)
    self:addChild(self.m_nextSprite,kZMax)

	self.m_pStartNextHand = cc.ui.UILabel.new({text="本局尚未开始，请耐心等待，先观察一下对手吧！",
		size = 22,
		color = display.COLOR_WHITE,
		-- dimensions = cc.size(150,64)
		})
    self.m_pStartNextHand:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2-60)
        :addTo(self,kZMax)
        :setVisible(false)


    --[[back]]
    self.m_backBtn = self:createMenuWithMyInfo(ROOM_BACK_BTN_POS,handler(self, self.doBackToLobby),s_room_backN,s_room_backS)
 	self:addChild(self.m_backBtn,kZOperateBoard)
 	-- cc.ui.UIPushButton.new({normal=s_room_backN, pressed=s_room_backS, disabled=s_room_backS})
 	-- 	:align(display.CENTER, ROOM_BACK_BTN_POS.x, ROOM_BACK_BTN_POS.y)
 	-- 	:onButtonClicked(function(event) 
 	-- 		GameSceneManager:switchSceneWithType(EGSMainPage)
 	-- 		end)
 	-- 	:addTo(self)


 	--[[牌局收藏按钮]]
 	self.m_uploadBoardInfoButton = self:createMenuWithMyInfo(cc.pAdd(cc.pMul(LAYOUT_OFFSET,2),ROOM_BACK_RECORD_POS),
 	 	handler(self, self.recordGame), s_room_recordN, s_room_recordS)
 	self:addChild(self.m_uploadBoardInfoButton,kZOperateBoard)

 	--[[牌型按钮]]
 	self.m_pokerTypeButton = self:createMenuWithMyInfo(ROOM_TYPE_BTN_POS, handler(self,self.doPokerType), s_room_typeN, s_room_typeS)
 	self:addChild(self.m_pokerTypeButton,kZOperateBoard)

 	-- --[[chat按钮]]
 	-- self.m_chatBtn = self:createMenuWithMyInfo(cc.pAdd(cc.pMul(LAYOUT_OFFSET,2),ROOM_CHAT_BTN_POS),
 	--  	handler(self,self.doSendWord), s_room_chatN, s_room_chatS)
 	-- self:addChild(self.m_chatBtn,511,kRoomViewChatButtonTag)

 	-- --[[pic按钮]]
 	-- self.m_picBtn = self:createMenuWithMyInfo(cc.pAdd(cc.pMul(LAYOUT_OFFSET,2),ROOM_PIC_BTN_POS),
 	--  	handler(self,self.doSendFace), s_room_picN,s_room_picS)
 	-- self:addChild(self.m_picBtn,511,kRoomViewChatButtonTag)

 	--[[聊天和表情统一按钮]]
 	self.m_chatAndPicBtn = self:createMenuWithMyInfo(cc.pAdd(cc.pMul(LAYOUT_OFFSET,2),ROOM_CHAT_PIC_BTN_POS),
 	 	handler(self,self.doSendWord), s_room_chatAndPicN, s_room_chatAndPicS)
 	self:addChild(self.m_chatAndPicBtn,kZOperateBoard,kRoomViewChatButtonTag)

 	--[[语音按钮]]
	-- self.m_talkButton = cc.ui.UIPushButton.new({normal = "picdata/table/icon_speech.png",pressed = "picdata/table/icon_speech2.png",
	-- 	disabled = "picdata/table/icon_nospeech.png"})
	-- self.m_talkButton:onButtonClicked(handler(self,self.pressTalk))
	-- 		 :align(display.CENTER, ROOM_CHAT_PIC_BTN_POS.x, ROOM_CHAT_PIC_BTN_POS.y)
 -- 	self:addChild(self.m_talkButton,kZOperateBoard)
 -- 	self.m_talkButton:setVisible(false)

 	local CMChatButton = require("app.Component.CMChatButton")
    self.m_talkButton = CMChatButton.new({normal = "picdata/table/icon_speech.png"},
    {
    	callBegin 	= function ()  self:onMenuCallBack(1) end,
    	callMoveIn 	= function ()  self:onMenuCallBack(2) end,
    	callMoveOut = function ()  self:onMenuCallBack(3) end,
    	callEndIn  	= function ()  self:onMenuCallBack(4) end,
    	callEndOut 	= function ()  self:onMenuCallBack(5) end,})    
    :align(display.CENTER, ROOM_CHAT_PIC_BTN_POS.x, ROOM_CHAT_PIC_BTN_POS.y) 
    :addTo(self)
 	self.m_talkButton:setVisible(false)
    self.m_talkButton.isClick = false
    self:setTalkButtonVisible(false)

 	--[[初始化玩家放置沙发]]
 	for i=1,self.m_nTotalSeat,1 do
 		local player = require("app.GUI.roomView.PlayerView"):new()
 		player:addTo(self)
 		player:initWithInfo(self.m_tableBg,handler(self, self.doSafaCall),self.m_nTotalSeat,i-1)
 		self.m_pPlayersArray[i] = player
 	end

 	--[[庄家位标志]]
 	self.m_dealerSprite = cc.ui.UIImage.new(s_room_dealer)
 	self.m_dealerSprite:align(display.LEFT_TOP, 0, 0)
 		:addTo(self.m_tableBg, kZPot)
 		:setVisible(false)

 	--[[操作面板]]
 	self.m_operateBoard = require("app.GUI.roomView.OperateBoard"):create(self.m_tableType==eRushTable)
 	self.m_operateBoard:setAnchorPoint(cc.p(0,0))
 	self.m_operateBoard:setPosition(LAYOUT_OFFSET)
 	self.m_operateBoard:setCallback(self, handler(self, self.operateBoardClicked_Callback))
 	self.m_operateBoard:addTo(self,kZOperateBoard)
 	if self.m_operateBoard then
 		self.m_operateBoard:hideAll()
 	end
 		
	--[[奖池]]
	self.m_allPotLayer = require("app.GUI.roomView.AllPotLayer"):new()
	self.m_allPotLayer:setPosition(cc.pAdd(LAYOUT_OFFSET, ROOM_VIEW_POT_POS))
	self.m_allPotLayer:setVisible(false)
	self.m_tableBg:addChild(self.m_allPotLayer,kZPot)
	-- self:addChild(self.m_allPotLayer,kZOperateBoard)
 
    
	--[[信息提示框]]
	self.m_tipsInfoHint = require("app.GUI.roomView.InfoHint"):create()--BubbleManger:manger()
	-- self.m_tipsInfoHint:setAnchorPoint(cc.p(0.5, 1))
	-- self.m_tipsInfoHint:setInitPosition(cc.pAdd(LAYOUT_OFFSET,cc.p(480,640)))
	self.m_tipsInfoHint:setInitPosition(cc.pAdd(LAYOUT_OFFSET,cc.p(0,0)))
	self:addChild(self.m_tipsInfoHint, kZMax)
    
	self.m_rebuyDialog = nil
	self.m_leaveType = LEAVE_ROOM_TO_QUITROOM
	self.m_isFromPKMatch = false

    self.m_btnMessage = CMButton.new({normal = "picdata/MainPage/btn_news2.png"},function() self:showMessage() end, {scale9 = false}, {redDot = myInfo.data.showApplyBuy})    
    -- :align(display.CENTER, display.width-120,display.height-140) --设置位置 锚点位置和坐标x,y
    :addTo(self)
    self.m_btnMessage:setPosition(self.m_roomBg:getContentSize().width-60, self.m_roomBg:getContentSize().height-110)

    self.m_btnBill = CMButton.new({normal = "picdata/instantBill/2.png",
    	pressed = "picdata/instantBill/icon.png",
    	disabled = "picdata/instantBill/icon.png"},function() self:showInstantBill() end)    
    :align(display.LEFT_CENTER, 0,display.height/2+140) --设置位置 锚点位置和坐标x,y
    :addTo(self,kZOperateBoard)
		self.m_btnMessage:setVisible(false) 
		self.m_btnBill:setVisible(false)

	self:bindDataObservers()
end

---
-- 视图信号强弱改变
-- @return [description]
--
function RoomView:onSignalStrengthChange(strength)
	CMPrintToScene("网络强度strength:" .. strength)
	if not CMIsNull(self.m_signalIndicator) then
		self.m_signalIndicator:setSignalStrength(strength or 3)
	end
end

function RoomView:initOperateDelayMenu()
	require("app.GUI.roomView.UserCellDefine")
	local cellLoc = getCellLocWith(self.m_nTotalSeat, 0)
	local RewardLayer      = require("app.GUI.roomView.OperateDelay").new({
		loc = cc.p(cellLoc.x-120,cellLoc.y-40),
		callback = handler(self,self.doOperateDelay)})
    RewardLayer:create()
    self.m_operateDelayMenu = RewardLayer
   	self.m_tableBg:addChild(RewardLayer, kZOperateBoard)

   	self.m_operateDelayMenu:setVisible(false)
end

function RoomView:initApplyPublicCardMenu()
	self.m_applyPublicCardUI = require("app.GUI.roomView.ApplyCard").new({
		loc = cc.p(600, 275),
		callback = handler(self,self.doApplyPublicCard),
		smallBlind = self.smallBlind})
	self.m_applyPublicCardUI:create()
	self.m_tableBg:addChild(self.m_applyPublicCardUI, kZOperateBoard)
	self.m_applyPublicCardUI:setVisible(false)

	self.m_publicPokerBg = {}
	local tmpPos = {
		cc.p(480-94-94+15,308),
		cc.p(480-94+15,308),
		cc.p(480+15,308),
		cc.p(480+94+15,308),
		cc.p(480+94+94+15,308)
	}

	self.m_applyPublicCardUI:setPokerBgPos(tmpPos)
	for i=1,5 do
		self.m_publicPokerBg[i] = require("app.GUI.roomView.PokerBg").new({index = i})
		:align(display.CENTER, tmpPos[i].x, tmpPos[i].y)
		:addTo(self.m_tableBg, kZCommunityCard)
		self.m_publicPokerBg[i]:create()
		self.m_publicPokerBg[i]:setVisible(false)
	end
end

function RoomView:initLeaveSitProtectMenu()
	self.m_leaveSitProtectUI = require("app.GUI.roomView.LeaveSitProtect").new({
		loc = cc.p(600, 80),
		callback = handler(self,self.doLeaveSitProtect),
		smallBlind = self.smallBlind,
		bgPic = "picdata/leaveSitProtect/coffee.png"})
	self.m_leaveSitProtectUI:create()
	self.m_tableBg:addChild(self.m_leaveSitProtectUI, kZOperateBoard)
	self.m_leaveSitProtectUI:setVisible(false)
end

function RoomView:setApplyPublicCardVisible(isVisible)
	if self.m_applyPublicCardUI then
		for i=1,5 do
			self.m_publicPokerBg[i]:setVisible(false)
		end
		local publicCardNum = #self.m_pCommunityCardArray
		if isVisible then
			for i=publicCardNum+1,5 do
				self.m_publicPokerBg[i]:setVisible(true)
			end
			self.m_applyPublicCardUI:updateApplyCardButtonPos(publicCardNum)
		end
		self.m_applyPublicCardUI:setViewVisible(isVisible)

		if publicCardNum>4 and isVisible then
			self.m_applyPublicCardUI:setViewVisible(false)
		end
	end
end

function RoomView:hideOperateDelayMenu()
	if self.m_operateDelayMenu then
   		self.m_operateDelayMenu:setVisible(false)
   	end
end

function RoomView:setLeaveSitProtectVisible(isVisible)
	if self.m_leaveSitProtectUI then
		self.m_leaveSitProtectUI:setVisible(isVisible)
	end
end

function RoomView:showTrusteeshipProtectCallback(userId, isMyself, remainTime)
	local player = self:findPlayerByUserId(userId)
	if player then
		player:showTrusteeshipProtectCountDown(self.m_tableBg, isMyself, remainTime)
	end
end

function RoomView:doLeaveSitProtect(payMoney)
    self:setLeaveSitProtectVisible(false)
	if tonumber(myInfo.data.userDebaoDiamond) < tonumber(payMoney) then
		self:showRebuyDialog(true, payMoney, payMoney, false, 15, "POINT")
		return
	end
	self.m_roomManager:reqLeaveSitProtect(self.m_tableId)
end

function RoomView:doApplyPublicCard(payMoney)
    self:setApplyPublicCardVisible(false)
	if tonumber(myInfo.data.userDebaoDiamond) < tonumber(payMoney) then
		self:showRebuyDialog(true, payMoney, payMoney, false, 15, "POINT")
		return
	end
	self.m_roomManager:reqApplyPublicCard(self.m_tableId)
end

function RoomView:doOperateDelay(payMoney)
	if tonumber(myInfo.data.userDebaoDiamond) < tonumber(payMoney) then
		-- self:showRebuyDialog(true, payMoney, payMoney, false, 15, self.payType)
		self:showRebuyDialog(true, payMoney, payMoney, false, 15, "POINT")
		return
	end
	self.m_roomManager:reqMyOperateDelay(self.m_tableId)
end

function RoomView:showUserOperateDelay(isMyself, userId, remainTime)
	if not self.m_operateDelayMenu then
		return
	end
	local player = self:findPlayerByUserId(userId)
	if player then

		player:resetWaitForMsg(isMyself, remainTime, remainTime)

		player:showChatMsg(self,isMyself,"使用延时功能",0,nil)

	end
	if isMyself then
		self.m_operateDelayMenu:addApplyDelayTimes()
	end
end

function RoomView:updateApplyDelayTime(times)
	if not self.m_operateDelayMenu then
		return
	end
	self.m_operateDelayMenu:updateApplyDelayTime(times)
end

function RoomView:showFirstUseTalk()
	-- if device.platform~="ios" or true then
	-- 	return
	-- end
	local value = cc.UserDefault:getInstance():getIntegerForKey("FIRST_TALK"..myInfo.data.userId, 1)
	if value==1 then
    	-- CMOpen(require("app.GUI.dialogs.TalkHint"), cc.Director:getInstance():getRunningScene(), 0, true, kZMax+1)
    	CMOpen(require("app.GUI.dialogs.TalkHint"), self, 0, true, kZMax+1)

		cc.UserDefault:getInstance():setIntegerForKey("FIRST_TALK"..myInfo.data.userId, 0)
		cc.UserDefault:getInstance():flush()
	end
end

function RoomView:showToolTips(data)
	if self:getChildByTag(TOOL_TIP_TAG) then
		self:removeChildByTag(TOOL_TIP_TAG,true)
	end
		local tip = require("app.Component.ETooltipView"):alertView(self, "", data.msg, data.flag)
		tip:setTouchHide(true)
		tip:setTag(TOOL_TIP_TAG)
		tip:show(data.duration or 1.5)
end

function RoomView:playGAF(data)
	local asset = gaf.GAFAsset:create(data.gafFile)
	local animation = asset:createObject()
	self:addChild(animation,kZOperateBoard+2,data.tag)
	-- local origin = cc.Director:getInstance():getVisibleOrigin()
	-- local size = cc.Director:getInstance():getVisibleSize()
	animation:setPosition(data.pos)
	animation:setAnchorPoint(cc.p(0.5,0.5))
	animation:setLooped(true, true)
	animation:start()
end

function RoomView:removeMicAnimations()
  	if self:getChildByTag(TAG_GAF_RECORD) then
        self:removeChildByTag(TAG_GAF_RECORD, true)
    end
    if self:getChildByTag(TAG_GAF_RECORD_BG) then
        self:removeChildByTag(TAG_GAF_RECORD_BG, true)
    end
end

function RoomView:onMenuCallBack(tag)
	if tag == 1 then
		-- start record
		self:removeMicAnimations()
		self.m_talkButton:setTexture("picdata/table/icon_speech2.png")
		QManagerPlatform:startRecord()
		
		local recordBG = cc.Sprite:create("picdata/table/bg_tips.png")
		recordBG:setPosition(display.cx,display.cy)
		local micImg = cc.Sprite:create("picdata/table/icon_mic.png")
		micImg:setPosition(146,176)
		recordBG:add(micImg, 2)
		self:addChild(recordBG,kZOperateBoard+1,TAG_GAF_RECORD_BG)
		local data = {['gafFile']="picdata/table/mic.gaf",['tag']=TAG_GAF_RECORD,['pos']=cc.p(display.cx+40,display.cy)}
		self:playGAF(data)

	elseif tag == 2 then 

	elseif tag == 3 then
		-- print(btnHelp:getTouchTime())
			self:removeMicAnimations()
			local data = {['msg']='录音取消',['flag']=false}
			self:showToolTips(data)
			QManagerPlatform:cancelRecord()
	 elseif tag == 4 then 
	 	self:removeMicAnimations()
		local time = self.m_talkButton:getTouchTime()
		if time < 1 then
			if self.m_talkButton.isClick ~= true then
				self.m_talkButton.isClick = true

				QManagerPlatform:setPlayFlag({['playFlag']='NO'})
				local data = {['msg']='关闭声音',['flag']=false,['duration'] = 1}
				self:showToolTips(data)
				self.m_talkButton:setTexture("picdata/table/icon_nospeech.png")
			else
				self.m_talkButton.isClick = false
				QManagerPlatform:setPlayFlag({['playFlag']='YES'})
				local data = {['msg']='开启声音',['flag']=true,['duration'] = 1}
				self:showToolTips(data)
				self.m_talkButton:setTexture("picdata/table/icon_speech.png")
			end
		else
			local data = {['msg']='发送语音',['flag']=true}
			self:showToolTips(data)
			self.m_talkButton:setTexture("picdata/table/icon_speech.png")

			QManagerPlatform:stopRecord({["TargetId"]=self.m_tableId,["userId"]=myInfo.data.userId,["duration"] = time,["fromWhere"] = "showTalkIcon"})
		end
	-- elseif tag == 4 then
		-- print(btnHelp:getTouchTime())
		-- local time 

	elseif tag == 5 then
		self:removeMicAnimations()
		-- print(btnHelp:getTouchTime())
		-- 结束
	end
end

function RoomView:setTalkButtonVisible(value)
	-- if device.platform~="ios" or true then
	-- 	return
	-- end
	self.m_talkButton:setVisible(value)
	if value then
		self:showFirstUseTalk()
		self.m_chatAndPicBtn:setPositionX(ROOM_BACK_RECORD_POS.x) 
		self.m_uploadBoardInfoButton:setPositionX(230)
	else
		self.m_chatAndPicBtn:setPositionX(ROOM_CHAT_PIC_BTN_POS.x) 
		self.m_uploadBoardInfoButton:setPositionX(ROOM_BACK_RECORD_POS.x)
	end
end

function RoomView:showInstantBill(event)
    -- CMOpen(require("app.GUI.dialogs.InstantBillDialog"), self, {m_tableId = self.m_tableId}, true, kZMax+1)
    local dialog = require("app.GUI.dialogs.InstantBillDialog").new({m_tableId = self.m_tableId,m_destroyTime = self.destroyTime})
    dialog:addTo(self, kZMax+1)
    dialog:setPositionX(-495)
end

function RoomView:showMessage(event)
	-- dump("showMessage")
	local RewardLayer = require("app.GUI.notice.NoticeLayer")
	CMOpen(RewardLayer,self,{nType = 5},1,kZMax+1)
end

function RoomView:setRoomManager(roomManager)
	self.m_roomManager = roomManager
end

function RoomView:initRemainTime()

	-- self.m_tTimeRemainLabel = cc.Label:createWithSystemFont("剩余时间:00:00:00", "Arial", 18)
	-- self.m_tTimeRemainLabel:setColor(cc.c3b(255,255,255))
	-- self.m_tTimeRemainLabel:setPosition(cc.p(80, display.height-120))
	-- self.m_tTimeRemainLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	-- self.m_tTimeRemainLabel:setColor(cc.c3b(185,185,202))
	-- self:addChild(self.m_tTimeRemainLabel, 0)
	-- self.m_tTimeRemainLabel:setVisible(false)


    local timeBg = cc.ui.UIImage.new("picdata/instantBill/bg_sysj.png", {scale9 = true})
		:align(display.CENTER, 105, CONFIG_SCREEN_HEIGHT-100)
		:addTo(self)
    timeBg:setLayoutSize(210, 44)
    local timeHint = cc.ui.UIImage.new("picdata/instantBill/w_sysj.png")
	timeHint:align(display.CENTER, timeHint:getContentSize().width/2+5, timeBg:getContentSize().height/2-2)
		:addTo(timeBg)
    local timeBg1 = cc.ui.UIImage.new("picdata/instantBill/bg_sysj_time.png")
	timeBg1:align(display.CENTER, timeBg:getContentSize().width-timeBg1:getContentSize().width/2-10, timeBg:getContentSize().height/2)
		:addTo(timeBg)
	local timeData = {timestamp=0,color=cc.c3b(255,102,0),padding=16, length=3,
		position = cc.p(3,timeBg1:getContentSize().height/2)}	
	self.timeLabel = require("app.GUI.dialogs.CountDownTimeLabel").new(timeData)
	self.timeLabel:addTo(timeBg1,1)
	self.timeLabel:create()

	self.timeLabel:setTimestamp(EStringTime:getTimeStampFromNow(self.destroyTime))
	self.m_tTimeRemainLabel = timeBg
	self.m_tTimeRemainLabel:setVisible(false)
end

--[[更新显示当前时间]]
function RoomView:updateTimeLabel(dt)
	--获取系统时间并转为当地时间
	-- local date=os.date("%Y-%m-%d %H:%M:%S")
	-- local currDate = os.date("%H:%M:%S")
	local currDate = os.date("%H:%M")
	-- dump(currDate)
	if self.m_tTimeLabel then
		-- self.m_tTimeLabel:setString("系统时间:"..currDate)
		self.m_tTimeLabel:setString(""..currDate)
	end
	-- dump(self.destroyTime)
	-- self.destroyTime = "2016-04-08 13:52:40"
	-- if self.destroyTime and self.m_tTimeRemainLabel then
	-- 	local remainTime = EStringTime:getTimeFromNow(self.destroyTime)
	-- 	self.m_tTimeRemainLabel:setString("剩余时间:"..remainTime)
	-- 	self.m_tTimeRemainLabel:setVisible(false)
	-- end

	local timestampDelta = EStringTime:getTimeStampFromNow(self.destroyTime)
	if timestampDelta<26 and timestampDelta>24 then
    	self:showCountDown(true, 25, 0, 1, 1)
	end 

	local isNetAvaible = network.isInternetConnectionAvailable()
	local netType = network.getInternetConnectionStatus()
	local netTypeString = "no"
	if netType == 1 then
		netTypeString = "wifi"
	elseif netType == 2 then
		netTypeString = "手机网络"
	end
	-- print(isNetAvaible, "网络状态判断")
	-- if isNetAvaible then
	-- 	CMPrintToScene("是否可上网：true, 网络类型：" .. netTypeString)
	-- else
	-- 	CMPrintToScene("是否以上网：false, 网络类型：" .. netTypeString)
	-- end
	-- print(network.getInternetConnectionStatus(), "网络类型")
	if not network.isInternetConnectionAvailable() then
		local tcpCommandRequest = TcpCommandRequest:shareInstance()
		if tcpCommandRequest:isConnect() then
			print(isNetAvaible, "网络状态判断后，关闭网络")
			CMPrintToScene("网络状态判断后，关闭网络")
			tcpCommandRequest:closeConnect(false)
		end
	end
end

function RoomView:leaveRoom()
	
	while true do
		--[[关闭游戏规则]]
		local helpScene = self:getChildByTag(HELP_SENCE_TAG)
		if helpScene then
			helpScene:getParent():removeChild(helpScene, true)
		end
        
		--[[关闭任务]]
		local task = self:getChildByTag(TASK_TAG)
		if task then
			task:getParent():removeChild(task, true)
			break
		end
     
		--[[关闭设置]]
		local setting = self:getChildByTag(SETTING_TAG)
		if setting then
			setting:getParent():removeChild(setting, true)
			break
		end
        
		--[[关闭牌型]]
		local cardType = self:getChildByTag(CARD_TYPE_TAG)
		if cardType then
			cardType:getParent():removeChild(cardType, true)
			break
		end
        
		--[[关闭首充]]
		local firstRecharge = self:getChildByTag(FIRST_RECHARGE_TAG)
		if firstRecharge then
			firstRecharge:getParent():removeChild(firstRecharge, true)
			break
		end
        
		--[[关闭快速充值]]
		local quickRecharge = self:getChildByTag(QUICK_RECHAGE_TAG)
		if quickRecharge then
			quickRecharge:getParent():removeChild(quickRecharge, true)
			break
		end
        
		--[[快速充值]]
		local shop = self:getChildByTag(PHONE_CARD_CHARGE)
		if shop then
			shop:getParent():removeChild(shop, true)
			break
		end

		if self.m_roomManager then
			self.m_roomManager:reqMyLeaveTable(self.m_tableId,true,self.m_leaveType)
		end
		break
	end
end

function RoomView:createMenu(normalPic, selectPic, selector)
	local pMenu = cc.ui.UIPushButton.new({normal = normalPic,pressed = selectPic,disabled = selectPic})
		pMenu:onButtonClicked(selector)
			 :align(display.CENTER, 0, 0)
			 :setTouchSwallowEnabled(true)
	return pMenu
end

--[[创建按钮]]
function RoomView:createMenuWithMyInfo(loc,selector,normalPic,selectPic)
	--[[老方法]]
	-- local normalSprite = cc.Sprite:create(normalPic)
	-- local selectSprite = cc.Sprite:create(selectPic)
	-- local pItem = cc.MenuItemImage:create()
	-- pItem:setNormalSpriteFrame(normalSprite:getSpriteFrame())
	-- pItem:setSelectedSpriteFrame(selectSprite:getSpriteFrame())
	-- pItem:registerScriptTapHandler(selector)
	-- pItem:setPosition(cc.p(0,0))
	-- local pMenu = cc.Menu:create(pItem)
	-- pMenu:setPosition(loc)

	--[[新方法]]
	local pMenu = cc.ui.UIPushButton.new({normal = normalPic,pressed = selectPic,disabled = selectPic})
		pMenu:onButtonClicked(selector)
			 :align(display.CENTER, loc.x, loc.y)
			 :setTouchSwallowEnabled(true)
	return pMenu
end

--[[
 * Menu完整显示顺序
 * 现金桌：任务、happyHour、充值、帮助、设置、牌型、买入
 * 锦标赛：rebuy、设置、牌型
]]
function RoomView:addMenubar(needHelp, needHappyHour, isTourney, isRebuy)
	local menuItemList = {}
	local menu = nil
	if isTourney then
		if isRebuy then
			if not self.m_rebuyButton then
				self.m_rebuyButton = self:createMenu(s_room_rebuyN,s_room_rebuyS,handler(self, self.doRebuyAction))
			end
			menuItemList[#menuItemList+1] = self.m_rebuyButton
		end
	else
		if not self.m_buyButton then
			self.m_buyButton = self:createMenu(s_room_buyN,s_room_buyS,handler(self, self.doBuyChip))
		end
		menuItemList[#menuItemList+1] = self.m_buyButton

		if not self.m_quickRechargeButton then
			self.m_quickRechargeButton = self:createMenu(s_room_quickRechagreN,s_room_quickRechagreS,handler(self, self.doQuickCharge))
		end
		menuItemList[#menuItemList+1] = self.m_quickRechargeButton

		if not self.m_freeGoldButton then
			self.m_freeGoldButton = self:createMenu(s_room_freeGoldN,s_room_freeGoldS,handler(self, self.doFreeGoldAction))
		end
		menuItemList[#menuItemList+1] = self.m_freeGoldButton

  --       if not GIOSCHECK then
		-- 	if not self.m_activityButton then
		-- 		self.m_activityButton = self:createMenu("picdata/table/icon_activity.png",
		-- 			"picdata/table/icon_activity.png",handler(self, self.doActivityAction))
		-- 	end
		-- 	menuItemList[#menuItemList+1] = self.m_activityButton
		-- end
	end

	if not self.m_Menubar then
		self.m_Menubar = require("app.GUI.roomView.MenubarContainer"):create(menuItemList)
		-- self.m_Menubar:setAnchorPoint(cc.p(1,1))
		self.m_Menubar:setPosition(cc.p(0, 0))
		-- self.m_Menubar:setPosition(cc.pAdd(cc.pAdd(LAYOUT_OFFSET,LAYOUT_OFFSET),ROOM_MENU_BAR_POS))
		self:addChild(self.m_Menubar, kZOperateBoard)
	else
		self.m_Menubar:updateItemList(menuItemList)
	end
end

function RoomView:doActivityAction()
	local id = tostring(QDataActivityList:getTableMsgData())
	if id then
		local url = ""
	    if SERVER_ENVIROMENT == ENVIROMENT_TEST then
	    	url = string.format("http://debao.boss.com/index.php?act=activity&mod=do_%s&PHPSESSID=%s",id,myInfo.data.phpSessionId)
	    else
	    	url = string.format("http://www.debao.com/index.php?act=activity&mod=do_%s&PHPSESSID=%s",id,myInfo.data.phpSessionId)    
	    end
		local data = {}
		data.url = url
		-- dump(data)
		QManagerPlatform:jumpToWebView(data)
	end
end

--[[
 * Menu完整显示顺序
 * 现金桌：任务、happyHour、充值、帮助、设置、牌型、买入
 * 锦标赛：rebuy、设置、牌型
]]


--[[触摸时间]]
--------------------------------------------------
--[[返回大厅]]
function RoomView:doBackToLobby(pObj)
	local layer = self:getChildByTag(BACK_MENU_LAYER)
	if not layer then
		layer = require("app.GUI.roomView.BackMenuLayer"):create(self,self.m_isPrivateRoom or self.m_tableType == eSngTable or 
			self.m_tableType == eTourneyTable, self.m_tableId)
		self:addChild(layer,kZMax,BACK_MENU_LAYER)
	end
end

function RoomView:backCallback(pNode)
	local layer = pNode
	local backActionType = layer:getBackAction()
	if backActionType==ebackQuickChange then
        self.m_leaveType = LEVAE_ROOM_TO_CHANGROOM
    elseif backActionType==ebackExitRoom then
        if self.m_tableType == eSngPKTable then
            self.m_leaveType = LEAVE_ROOM_TO_SNGPKMATCH
        else
            self.m_leaveType = LEAVE_ROOM_TO_QUITROOM
        end
    elseif backActionType==ebackShop then
        self.m_leaveType = LEAVE_ROOM_TO_SHOP
    elseif backActionType==ebackRank then
        self.m_leaveType = LEAVE_ROOM_TO_RANK
    elseif backActionType==ebackActivity then
        self.m_leaveType = LEAVE_ROOM_TO_ACTIVITY
    elseif backActionType==ebackAFK then
        self.m_roomManager:reqMySetAutoBlind(self.m_tableId,AUTO_BLIND_REFUSE_ALL)
        return
    end
	if self.m_roomManager then
		self.m_roomManager:reqMyLeaveTable(self.m_tableId,true,self.m_leaveType)
	end
end

--[[首充大礼包]]
function RoomView:doFirstRechargeAction(event)
	
	local pNode = event.target
	local data = pNode.status
	if data==nil then
		data = 0
	end
	if data ~= 0 then
		local dialog = require("app.GUI.dialogs.FirstRechargeRewardDialog"):create(self,
			handler(self,self.fetchFirstRechargeRewardSuccCallback),myInfo.data.userId)
		self:addChild(dialog,kZMax,FIRST_RECHARGE_TAG)
	elseif data == 0 then
		self:showFirstChargeDialog_Callback(0,"",true)
	end
end

--[[新手引导]]
function RoomView:doNewTipsAction(pNode)
	local ruleLayer = MoreRuleLayer:createLayer(handler(self, self.helpListSceneBackAction))
	self:addChild(ruleLayer,kZMax,HELP_SENCE_TAG)
end

--[[设置]]
function RoomView:doSettingAction(pNode)
	local settingD = SettingDialog:dialog(self.m_tableType, self.m_userDefaultInstance:getSoundEnable(),
													 self.m_userDefaultInstance:getBubbleEnable(),
													 self.m_userDefaultInstance:getNewTipsEnable(),
													 self.m_userDefaultInstance:needShowDown(),
													 self.m_userDefaultInstance:needWinLoseTip(),
													 handler(self, self.playerSettingCallBack))
    settingD:setPosition(cc.p(LAYOUT_OFFSET.x*2, 0))
	self:addChild(settingD,kZMax,SETTING_TAG)
	settingD:show()
end

--[[rebuy]]
function RoomView:doRebuyAction(pNode)
	if self.m_roomManager then	
		self.m_roomManager:reqMyRebuyDiaglog(self.m_tableId)
	end
end

function RoomView:recordGame(pNode)
	-- print("···",self.m_tableId)
	-- QManagerPlatform:stopRecord({["TargetId"]=self.m_tableId})

	if BoardInfo:getInstance().uploadFlag==1 then
		BoardInfo:getInstance().clearFlag=1
		local blink = cc.Blink:create(0.2, 1)

		self:runAction(blink)
		self.m_tipsInfoHint:addBubble("将在牌局结束后为您保存本场牌局", true)
	else
		self.m_tipsInfoHint:addBubble("请在本局结束后再点击录制牌局", true)
	end
end

--[[牌型]]
function RoomView:doPokerType(pNode)
	-- QManagerPlatform:startRecord()

	-- [[到BaseRoom请求当前最大手牌]]
	local cardType = -1
    
	if self.m_roomManager and self.m_tableId ~= "" then
		self.m_roomManager:reqMyBestCardsType(self.m_tableId,cardType)
	end
	
    
	local cardTips = require("app.GUI.roomView.CardTips"):create(self.m_tableType)
    cardTips:setPosition(cc.p(0, 0))
	self:addChild(cardTips,kZMax,CARD_TYPE_TAG)
	cardTips:highLightType(cardType)
end

--[[补充筹码]]
function RoomView:doBuyChip(pNode)
	if self.m_roomManager then	
		self.m_roomManager:reqMyAddBuyChipDiaglog(self.m_tableId)
	end
end

--[[happyHour]]
function RoomView:doHappyHour(pNode, data)
	if self.m_happyHourButton then
		local dialog = DialActivityDialog:create(self.m_happyHourButton)
		self:addChild(dialog,kZMax)
	end
end

--[[任务系统]]
function RoomView:doAllTaskAction(pNode, data)
end

function RoomView:doFreeGoldAction(pNode, data)
    if UserDefaultSetting:getInstance():getFreeGoldTimes() == 0 then
        self:freeGoldDialogCallBack(0)
        return
    end

    if self:getChildByTag(TASK_TAG) then
        self:removeChildByTag(TASK_TAG)
    end
   
    local me = self:findPlayerByUserId(myInfo.data.userId)
    local allOfMyMoney = 1000
    if me then
        allOfMyMoney = myInfo:getTotalChips() + me:getChips()
    else
        allOfMyMoney = myInfo:getTotalChips()
    end
    local tmpmoney = allOfMyMoney
    local enoughMoney = tmpmoney>1000 and true or false

    local dialog = require("app.GUI.roomView.FreeGoldDialog"):dialog(self,handler(self, self.freeGoldDialogCallBack),enoughMoney)
    if dialog then
        self:addChild(dialog,kZMax,TASK_TAG)
        dialog:setPosition(LAYOUT_OFFSET)
        dialog:show()
   	end
end

--[[表情]]
function RoomView:doSendFace(pObj)
	if self.m_roomManager then	
		self.m_roomManager:showChatOrEmotion(self.m_tableId,false)--[[请求显示表情框]]
	end
end

--[[聊天]]
function RoomView:doSendWord(pObj)
	if self.m_roomManager then	
		self.m_roomManager:showChatOrEmotion(self.m_tableId,true)--[[请求显示表情框]]
	end
end

--[[快速充值]]
function RoomView:doQuickCharge(pObj)
	if self.m_roomManager then	
		self.m_roomManager:reqMyQuickCharge(self.m_tableId)--[[请求快速充值]]
	end

	-- local max = self.m_buyTableInfo.max
	-- if max>self.m_buyTableInfo.originalBuyChipsMax then
	-- 	max = max-self.m_buyTableInfo.originalBuyChipsMax
	-- end
	-- 	local dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
	-- 	handler(self,self.buyChipDialogCallBack),max, self.m_buyTableInfo.min, 
	-- 	self.m_buyTableInfo.myChips, self.m_buyTableInfo.bigBlind, self.m_buyTableInfo.payType,self.m_buyTableInfo.isAdd, 
	-- 	self.m_buyTableInfo.defaultValue, self.m_buyTableInfo.needShowAutoBuySign,1,self.m_buyTableInfo.serviceCharge,self.m_isPrivateRoom)
	-- 	dialog:setPayType(self.payType)
	-- 	if dialog then
	-- 		self:addChild(dialog, kZMax)
	-- 		dialog:setPosition(LAYOUT_OFFSET)
	-- 		dialog:setTag(kTagBuyChipDialog)
	-- 		dialog:show()
	-- 	end
end

--[[点击沙发坐下]]
function RoomView:doSafaCall(pObj)
	-- normal_info_log("RoomView:doSafaCall 点击沙发坐下待完善")
	 if BoardInfo:getInstance().isReplay~=1 then
        local tmp = pObj
        local seatNo = tmp:getTag()-SAFAMENUTAG
        
        if self.m_roomManager then
        	self.m_roomManager:reqMySit(self.m_tableId, seatNo)
        end
    end
end

--[[UserCell点击事件的回调]]
function RoomView:userCellClick_Callback(pObj)
	local n = 5+m
	local clickedCell = pObj
	local seatId = self:viewSeatToServeSeat(clickedCell:getSeatNum())
	local userdata = {}
	userdata[USER_ID] = clickedCell:getUserId()
	userdata[USER_NAME] = clickedCell:getUserName()
	userdata[USER_PORTRAIT] = clickedCell.m_headPicStr
	userdata[USER_SEX] = clickedCell.m_sex
	userdata["VIP"] = clickedCell.m_vipLevel
	local FriendShowLayer = require("app.GUI.friends.FriendShowLayer")
	CMOpen(FriendShowLayer, self,{nType = "PlayerInfo",userdata = userdata},0)
end

--[[根据座位号查找玩家]]
function RoomView:findPlayerBySeatId(seatNO)
	if seatNO<0 or seatNO>= self.m_nTotalSeat then
		return nil
	end
    
	for i=1,#self.m_pPlayersArray do
		local eachP = self.m_pPlayersArray[i]
		if eachP:getSeatID() == seatNO then
			return eachP
		end
	end
    
	return nil
end

function RoomView:findPlayerByUserId(userId)
	for i=1,#self.m_pPlayersArray do
		local eachP = self.m_pPlayersArray[i]
		if eachP:getUserId() == userId then
			return eachP
		end
	end
	return nil
end

--[[根据usedid查找筹码]]
function RoomView:findPlayerChipByUserId(userId)
	local player =  self:findPlayerByUserId(userId)
    if (player == nil) then
        return nil
    end
    local seatNo = player:getSeatID()
    if(seatNo < 0 or seatNo >= self.m_nTotalSeat) then
    	return nil
    end
   
   	local eachP = nil
    for i=1,#self.m_pPlayerChip do
        eachP = self.m_pPlayerChip[i]
        if eachP then
        	if(eachP:getSeatNo() == seatNo) then
            	return eachP
        	end
        end
    end
    
	return nil
end

--[[根据座位号查找筹码]]
function RoomView:findPlayerChipBySeatId(seatNo)
	if seatNo < 0 or seatNo >= self.m_nTotalSeat then
		return nil
	end    
	if not self.m_pPlayerChip then
		return
	end
	local eachP = nil
	for i=1,#self.m_pPlayerChip do
		eachP = self.m_pPlayerChip[i]
		if eachP then
			if eachP:getSeatNo() == seatNo then
				return eachP
			end
		end
	end
    
	return nil
end

--[[服务器返回座位号到显示座位号]]
function RoomView:serveSeatToViewSeat(seatNo)
	return ((seatNo + self.m_seatOffset + self.m_nTotalSeat) % self.m_nTotalSeat)
end

--[[显示座位号到服务器返回座位号]]
function RoomView:viewSeatToServeSeat(viewNo)
	return ((seatNo - self.m_seatOffset + self.m_nTotalSeat) % self.m_nTotalSeat)
end

--------------------------------------------------
----[[用户操作事件回调]]
--------------------------------------------------
function RoomView:rebuyDialogCallBack(action, payType)
	payType = payType or self.payType
	-- dump(action)
	if action == eRebuyCharge then
		local dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
		handler(self,self.buyChipDialogCallBack),self.m_buyTableInfo.max, self.m_buyTableInfo.min, 
		self.m_buyTableInfo.myChips, self.m_buyTableInfo.bigBlind, self.m_buyTableInfo.payType,self.m_buyTableInfo.isAdd, 
		self.m_buyTableInfo.defaultValue, self.m_buyTableInfo.needShowAutoBuySign,1,self.m_buyTableInfo.serviceCharge,self.m_isPrivateRoom)
		dialog:setPayType(payType)
		if dialog then
			self:addChild(dialog, kZMax)
			dialog:setPosition(LAYOUT_OFFSET)
			dialog:setTag(kTagBuyChipDialog)
			dialog:show()
		end
	elseif action == eRebuyAddChips then
		-- print("xxxxxxxxxxxxxxxxxxxxx")
		if self.m_rebuyDialog:getTag() == REBUY_AUTO then
			self.m_roomManager:reqRebuy(self.m_tableId, ePassiveRebuyYes)
		elseif self.m_rebuyDialog:getTag() == REBUY_MANUL then
			self.m_roomManager:reqRebuy(self.m_tableId, ePassiveRebuyInit)
		elseif self.m_rebuyDialog:getTag()==ADDON_MANUL then
			self.m_roomManager:reqAddOn(self.m_tableId)
		end
	elseif action == eRebuyTimeOutPassive then
		if self.m_rebuyDialog:getTag() == REBUY_AUTO then
			local tip = require("app.Component.ETooltipView"):alertView(self, "", Lang_REBUY_ERROR_TIMEOUT, false)
			tip:setTouchHide(true)
			tip:show()
		end
	elseif action == eRebuyTimeOutManual then
		local tip = require("app.Component.ETooltipView"):alertView(self, "", Lang_REBUY_ERROR_MANULTIMEROUT, false)
		tip:setTouchHide(true)
		tip:show()
	else
		if self.m_rebuyDialog:getTag() == REBUY_AUTO then
			self.m_roomManager:reqRebuy(self.m_tableId, ePassiveRebuyNo)
			local tip = require("app.Component.ETooltipView"):alertView(self, "", Lang_REBUY_ERROR_CLOSE, false)
			tip:setTouchHide(true)
			tip:show()
		end
	end
	self.m_rebuyDialog:remove()
	self.m_rebuyDialog = nil
end

--[[请求购买筹码]]
function RoomView:buyChipDialogCallBack(chip, bAutoBuyChip, isAddBuyChips)
	if not self.m_roomManager then
		return
	end
	if chip > 0 then
		self.m_roomManager:reqMyBuyChips(self.m_tableId, chip, bAutoBuyChip,isAddBuyChips)
	elseif chip == -1 and not isAddBuyChips then --[[如果是点取消而且自己不是补充筹码就站起]]
		self.m_roomManager:reqMySit_out(self.m_tableId)
	end
end

-- [[发送聊天信息]]
function RoomView:chatDialogCallBack(message, chatType)
	if message ~= "" and self.m_roomManager then
		--发送聊天
		self.m_roomManager:reqMyTableChat(self.m_tableId, message,chatType)
	end
end

function RoomView:showMobileCharge(data)
	local view = MainShopView:create(data)
	view:setLogic(self.m_chargeLogic)
	self:addChild(view, kZMax, PHONE_CARD_CHARGE)
end

function RoomView:clickChannelSelectCallback(pNode, pData)
	if self.m_pLoadingView then
        self.m_pLoadingView:stop()
    end
    
	if pData == nil then
		return
	end
	
	local data = pData
	self.m_chargeLogic:setMainShopCallback(self)
    
	if data.payType and #data.payType>0 then
		local bValid = true
		local method = data.payType[1].method
		if method == "CM" then
			self.m_chargeLogic:reqChargingOrder(eRechargeWallet, data)
		elseif method == "MM" then
			self.m_chargeLogic:reqChargingOrder(eRechargeSMSPay, data)
		elseif method == "ZT" then
			showMobileCharge(data)
		elseif method == "ZFB" then
			self.m_chargeLogic:reqChargingOrder(eRechargeAliPay, data)
		elseif method == "LLPAY" then
            self.m_chargeLogic:reqChargingOrder(eRechargeLLPay, data)
        elseif method == "UP" then
			self.m_chargeLogic:reqChargingOrder(eRechargeUpomp, data)
		elseif method == "CFT" then
			self.m_chargeLogic:reqChargingOrder(eRechargeTenPay,data)
		elseif method == "WPAY" then
			self.m_chargeLogic:reqChargingOrder(eRechargeWpay,data)
		else
			bValid = false
		end
		if bValid then
			TalkingGameAnalytics:onEvent(self.m_onEventWhere, eOnEventActionSelectedChannel)
		end
	end
end

function RoomView:freeGoldDialogCallBack(tag)
	if tag ==0 then
        -- self.m_freeGoldTimes = 0
        local alertView = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
            "您今天免费金币的三次领取机会已经用完。明天再来领取吧。", "确定", "立即充值")
        alertView:setTag(116)
        alertView:show()
    else
        -- local dialog = MobileBlind:dialog(self)
        -- dialog:setPosition(LAYOUT_OFFSET)
        -- self:addChild(dialog,666)
        -- dialog:show()

        -- local dia = QuickRecharge:dialog(self, handler(self, self.quickRechargeDialogCallBack), 
        -- 	self.m_roomManager:reqMyBigBlind(self.m_tableId), m_chargeLogic)
        -- dia:setTag(QUICK_RECHAGE_TAG)
        -- self:addChild(dia, kZMax)
        -- dia:show()
        -- self.m_onEventWhere = eOnEventQuickRecharge


		local dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
		handler(self,self.buyChipDialogCallBack),self.m_buyTableInfo.max, self.m_buyTableInfo.min, 
		self.m_buyTableInfo.myChips, self.m_buyTableInfo.bigBlind, self.m_buyTableInfo.payType,self.m_buyTableInfo.isAdd, 
		self.m_buyTableInfo.defaultValue, self.m_buyTableInfo.needShowAutoBuySign,1,self.m_buyTableInfo.serviceCharge,self.m_isPrivateRoom)
		dialog:setPayType(self.payType)
		if dialog then
			self:addChild(dialog, kZMax)
			dialog:setPosition(LAYOUT_OFFSET)
			dialog:setTag(kTagBuyChipDialog)
			dialog:show()
		end
    end
end

function RoomView:quickRechargeDialogCallBack(value)
	-- if value < 0 then
	-- 	self.m_chargeLogic = nil
	-- else

	-- 	if (self.m_onEventWhere ~= eOnEventUnkowRecharge) then
	-- 		TalkingGameAnalytics:onEvent(self.m_onEventWhere, eOnEventActionClickItem)
	-- 	end
	-- 	local info = self.m_chargeLogic:reqBuyInfoWithValue(value)
	-- 	if info then
	-- 		if (DEBAO_PHONE_PLATFORM == DEBAO_ANDROID) then

	-- 			if (BRANCHES_VERSION == CHINAUNICOM) then
	-- 				self.m_chargeLogic:reqChargingOrder(eRechargeUniPay, info)
	-- 			elseif (BRANCHES_VERSION == TENCENT_WITH_PAY) then
	-- 				self.m_chargeLogic:reqChargingOrder(eRechargeTencentUnipay, info)
	-- 			elseif (BRANCHES_VERSION == PPSPLATFORM) then
	-- 				self.m_chargeLogic:reqChargingOrder(eRechargePPS, info)
	-- 			elseif(BRANCHES_VERSION == DKBAIDU) then
	-- 				self.m_chargeLogic:reqChargingOrder(eRechargeDKPay, info)
	-- 			elseif (BRANCHES_VERSION == ALIPAYOPEN) then
	-- 				self.m_chargeLogic:reqChargingOrder(eRechargeAliPayOpen, info)
	-- 			elseif (BRANCHES_VERSION == WIRELESS_91) then
	-- 				self.m_chargeLogic:reqChargingOrder(eRecharge91DPay, info)
	-- 			else
	-- 				local dialog = MainShopChannelDialog:dialog(info)
	-- 				dialog:setCallback(handler(self, self.clickChannelSelectCallback))
	-- 				self:addChild(dialog, kZMax)
	-- 			end
	-- 		else
 --            	self.m_chargeLogic:reqChargingOrder(eRechargeApple, info)
	-- 		end
	-- 	else
	-- 		local alertView = require("app.Component.EAlertView"):alertView(self, self, Lang_Title_Prompt, lang_RECHARGE_NOTEXIT,
 --                Lang_Button_Confirm)
	-- 		alertView:show()
	-- 	end
	-- end
		local dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
		handler(self,self.buyChipDialogCallBack),self.m_buyTableInfo.max, self.m_buyTableInfo.min, 
		self.m_buyTableInfo.myChips, self.m_buyTableInfo.bigBlind, self.m_buyTableInfo.payType,self.m_buyTableInfo.isAdd, 
		self.m_buyTableInfo.defaultValue, self.m_buyTableInfo.needShowAutoBuySign,1,self.m_buyTableInfo.serviceCharge,self.m_isPrivateRoom)
		dialog:setPayType(self.payType)
		if dialog then
			self:addChild(dialog, kZMax)
			dialog:setPosition(LAYOUT_OFFSET)
			dialog:setTag(kTagBuyChipDialog)
			dialog:show()
		end
end

-- [[请求个人信息]]
function RoomView:playerInfoDialogCallBack(action, seatNo)
	if self.m_roomManager then
		self.m_roomManager:addOrRemoveConcern(self.m_tableId, seatNo, action == eActionPlayerAdd)
	end
end

--[[设置的信息]]
function RoomView:playerSettingCallBack(soundEnable, bubbleEnable, newTipEnable)
	local needTip = self.m_userDefaultInstance:getNewTipsEnable()
    
	self.m_userDefaultInstance:setSoundEnable(soundEnable)
	self.m_userDefaultInstance:setBubbleEnable(bubbleEnable)
	self.m_userDefaultInstance:setNewTipsEnable(newTipEnable)
    
	--[[设置新手引导]]
	if needTip ~= newTipEnable then
		if self.m_tipsInfoHint then
			self.m_tipsInfoHint:addBubble(Lang_NewerGuideSetWorkNext, true)
		end
	end
end

--[[帮助界面返回]]
function RoomView:helpListSceneBackAction(helpListObj)
	local helpScene = helpListObj
	helpScene:getParent():removeChild(helpScene, true)
end

function RoomView:phoneCardChargeResult(bsuc, info)
	if not bsuc then
		local alertView = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,info,Lang_Button_Confirm)
		alertView:show()
	else
		self.m_chargeLogic:setMainShopCallback(nil)
		self.m_chargeLogic = nil
	end
end

function RoomView:chargeOrderResult(bsuc, info)
	if self.m_pLoadingView then
        self.m_pLoadingView:stop()
    end
	if not bsuc then
		local alertView = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,info,Lang_Button_Confirm)
		alertView:show()
	else
		if (DEBAO_PHONE_PLATFORM == DEBAO_ANDROID) then
			self.m_chargeLogic:setMainShopCallback(nil)
			self.m_chargeLogic = nil
		end
	end
end

--------------------------------------------------
				----[[对外接口]]
--------------------------------------------------
--[[显示购买对话框]]
function RoomView:showBuyinDiaglog_Callback(myChips, minBuyChips, maxBuyChips, defaultValue, 
	bigBlind, tableStyle, isAdd, needShowAutoBuySign, serviceCharge, currentShow)

	local dialog = self:getChildByTag(kTagBuyChipDialog)

	if dialog then
		return
	end

	local table_type
	table_type = tableStyle == "GOLD" and kGold or kSilver
	dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
		handler(self,self.buyChipDialogCallBack),maxBuyChips, minBuyChips, myChips, 
		bigBlind, type,isAdd, defaultValue, needShowAutoBuySign, currentShow, serviceCharge,self.m_isPrivateRoom)
	dialog:setPayType(self.payType)
	if dialog then
		self:addChild(dialog, kZMax)
		dialog:setPosition(LAYOUT_OFFSET)
		dialog:setTag(kTagBuyChipDialog)
		dialog:show()
	end

end

function RoomView:setGuideConfig(needActionGuide, needGuideHint)
	self.m_needActionGuide = needActionGuide
	self.m_needGuideHint = needGuideHint
end

--[[功能：显示牌桌信息（新手场10/20等）]]
function RoomView:showRoomInfo_Callback(tableName, smallBlind, bigBlind)
	self.tableName = tableName
	self.smallBlind = smallBlind
	self.bigBlind = bigBlind
	self.m_tableType = eCashTable
	local sBlind = StringFormat:FormatDecimals(smallBlind)
	local bBlind = StringFormat:FormatDecimals(bigBlind)
	local infoStr=tableName
	infoStr = infoStr.." "
	infoStr = infoStr..sBlind
	infoStr = infoStr.."/"
	infoStr = infoStr..bBlind
    
	self.m_infoLabel:setColor(cc.c3b(255,255,255))
	self.m_infoLabel:setVisible(true)
	self.m_infoLabel:setString(infoStr)
    
	--根据不同的场次 要不要显示新手教学
	local minBigBlind
	if(TRUNK_VERSION == DEBAO_TRUNK) then
		minBigBlind = 0.02
	else
		minBigBlind = 2
	end
	self:addMenubar(bigBlind <= minBigBlind,myInfo.data.m_happyHourChance>0,false,false)

	if string.find(self.tableName, "金阶") then
		SHOW_GIGESET = true
		self.m_roomTableBg:setTexture("picdata/table/Gigaset/table_jbs.png")
		self.m_roomBg:setTexture("picdata/table/Gigaset/table_bg_1136.jpg")
	else
		SHOW_GIGESET = nil
		self.m_roomTableBg:setTexture("picdata/table/gameTable.png")
    	local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES..s_room_bg)
		self.m_roomBg:setTexture(tmpFilename)
	end

	if self.m_isPrivateRoom then
		self:initApplyPublicCardMenu(true)
		self:initLeaveSitProtectMenu()
	end
end

--[[锦标赛场信息]]
function RoomView:showTourneyRoomInfo_Callback(matchId, bonusName, gainName, curPlayer, tableName, smallBlind, bigBlind, bRebuy)
	self.m_tableType = eTourneyTable
	self.tableName = tableName
	if(true) then
		--[[锦标赛背景和牌桌icon]]
		local bgTexture = cc.Sprite:create(s_room_tourney_table):getTexture()
		local bgSp = self:getChildByTag(BGTABLE_SP_TAG)
		bgSp:setTexture(bgTexture)

	if string.find(tableName, "金阶") then
		SHOW_GIGESET = true
		self.m_roomTableBg:setTexture("picdata/table/Gigaset/table_jbs.png")
		self.m_roomBg:setTexture("picdata/table/Gigaset/table_bg_1136.jpg")
	else
		SHOW_GIGESET = nil
		-- self.m_roomTableBg:setTexture("picdata/table/gameTable.png")
		self.m_roomTableBg:setTexture(bgTexture)
    	local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES..s_room_bg)
		self.m_roomBg:setTexture(tmpFilename)
	end
        
		local oldtableIcon = self:getChildByTag(TABLE_ICON_TAG)
		if(oldtableIcon) then
			self:removeChild(oldtableIcon, true)
		end
		local tableIcon = cc.Sprite:create(s_room_tourney_table_icon)
		tableIcon:setAnchorPoint(cc.p(0.5,0.5))
		tableIcon:setPosition(cc.pAdd(ROOM_TABLE_ICON_POS, LAYOUT_OFFSET))
		-- self:addChild(tableIcon,1,TABLE_ICON_TAG)
        
		--[[牌桌信息]]
		self.m_infoLabel:setColor(cc.c3b(255,255,255))
		self.m_infoLabel:setVisible(true)
		self.m_infoLabel:setString(tableName)
	end
	
	self:addMenubar(false,false,true,bRebuy)
	if not self.m_matchRankInfo then
		self.m_matchRankInfo = require("app.GUI.roomView.MatchRankTableView"):create(matchId,bonusName,gainName,curPlayer,self.payType)
		self.m_matchRankInfo:setAnchorPoint(cc.p(0,0))
		self.m_matchRankInfo:setPosition(cc.p(0,-40))
		self:addChild(self.m_matchRankInfo,kZMax)
	end
    
	self.m_matchRankInfo:updateMatchBlindInfo(smallBlind,bigBlind)
end

function RoomView:showSngRoomInfo_Callback(matchId, bonusName, gainName, curPlayer, tableName, smallBlind, bigBlind, bRebuy)
	self.m_tableType = eSngTable
	self.tableName = tableName
	if true then
		--背景和牌桌icon
		local bgTexture = cc.Sprite:create(s_room_tourney_table):getTexture()
		local bgSp = self:getChildByTag(BGTABLE_SP_TAG)
		bgSp:setTexture(bgTexture)

	if string.find(tableName, "金阶") then
		SHOW_GIGESET = true
		self.m_roomTableBg:setTexture("picdata/table/Gigaset/table_jbs.png")
		self.m_roomBg:setTexture("picdata/table/Gigaset/table_bg_1136.jpg")
	else
		SHOW_GIGESET = nil
		-- self.m_roomTableBg:setTexture("picdata/table/gameTable.png")
		self.m_roomTableBg:setTexture(bgTexture)
    	local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES..s_room_bg)
		self.m_roomBg:setTexture(tmpFilename)
	end
        
		local oldtableIcon = self:getChildByTag(TABLE_ICON_TAG)
		if(oldtableIcon) then
			oldtableIcon:getParent():removeChild(oldtableIcon, true)
		end
		local tableIcon = cc.Sprite:create(s_room_tourney_table_icon)
		tableIcon:setAnchorPoint(cc.p(0.5, 0.5))
		tableIcon:setPosition(cc.pAdd(ROOM_TABLE_ICON_POS, LAYOUT_OFFSET))
		-- self:addChild(tableIcon,1,TABLE_ICON_TAG)
        
		--牌桌信息
        self.m_infoLabel:setColor(cc.c3b(255,255,255))
		self.m_infoLabel:setString(tableName)
	end
    
	self:addMenubar(false,false,true,bRebuy)
	if not self.m_matchRankInfo then
		self.m_matchRankInfo = require("app.GUI.roomView.MatchRankTableView"):create(matchId,bonusName,gainName,curPlayer,self.payType)
		self.m_matchRankInfo:setAnchorPoint(cc.p(0,0))
		self.m_matchRankInfo:setPosition(cc.p(0,-40))
		self:addChild(self.m_matchRankInfo,kZMax)
		self.m_matchRankInfo:showSngContent()
	end
    
	self.m_matchRankInfo:updateMatchBlindInfo(smallBlind,bigBlind)
end

function RoomView:showTourneyPKRoomInfo_Callback(tableName, smallBlind, bigBlind)
end

--[[玩家离开房间]]
function RoomView:leaveTable_Callback(isMyself, leaveType)
	if isMyself then
		if leaveType == LEAVE_ROOM_TO_RANK then
 			GameSceneManager:switchSceneWithType(EGSRanking)
 			MusicPlayer:getInstance():playBackgroundMusic()
		elseif leaveType == LEAVE_ROOM_TO_ACTIVITY then
			GameSceneManager:switchSceneWithType(EGSActivity)
 			MusicPlayer:getInstance():playBackgroundMusic()
		elseif leaveType == LEAVE_ROOM_TO_SHOP then
			GameSceneManager:switchSceneWithType(EGSShop)
 			MusicPlayer:getInstance():playBackgroundMusic()
		elseif leaveType == LEVAE_ROOM_TO_QUITTOURNEY or leaveType == LEAVE_ROOM_TO_QUITROOM then
			if self.m_fromWhere == GameSceneManager.AllLayer.ZIDINGYI then
				GameSceneManager:setJumpLayer(GameSceneManager.AllLayer.ZIDINGYI)
				GameSceneManager:switchSceneWithType(EGSMainPage)
				return
			end
			if self.m_isFromMainPage then
				GameSceneManager:switchSceneWithType(EGSMainPage)
			else
				if self.m_isGameType then
					GameSceneManager:switchSceneWithType(EGSHall)
				else
					if self.m_isFromPKMatch then
						-- local scene = TourneyList:scene(eMatchListRecommend)
						-- GameSceneManager:switchScene(scene)
						GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)
					else
						GameSceneManager:switchSceneWithType(EGSTourney)
					end
				end
			end
 			MusicPlayer:getInstance():playBackgroundMusic()
		elseif leaveType == LEVAE_ROOM_TO_CHANGROOM then
			-- local loading = require("app.GUI.LoadingScene"):createLoading()
			-- GameSceneManager:switchScene(loading)
			-- loading:changeRoom()
			local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoadingScene)
			scene:changeRoom()
		elseif leaveType == LEVAE_ROOM_TO_TOURNEYROOM then
			-- local loading = require("app.GUI.LoadingScene"):createLoading()
			-- GameSceneManager:switchScene(loading)
			-- loading:enterTourneyRoom(self.m_tourneyTableId)
			local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoadingScene)
		elseif leaveType == LEAVE_ROOM_TO_SNGPKMATCH then
			-- local scene = TourneyList:scene(eMatchListRecommend)
			-- GameSceneManager:switchScene(scene)
			local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)
		end
	end
end

--[[旋转所有玩家座位]]
function RoomView:rotateAllSeats_Callback(seatId)
	-- normal_info_log("RoomView:rotateAllSeats_Callback 旋转所有玩家座位  先不旋转")

	--[[服务器返回的座位号到View的]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local tmpOffset = 0
	--计算最近的转动方向 顺时针为正
	local tmpMidSeat = self.m_nTotalSeat/2

	if self.m_nTotalSeat%2==1 then
		tmpMidSeat = (self.m_nTotalSeat+1)/2
	end
	if(seatId >= tmpMidSeat) then
		tmpOffset = self.m_nTotalSeat-seatId
	else
		tmpOffset = -seatId
    end

	if(tmpOffset == 0) then 
		return --自己坐到0位置不用偏移动画
    end

	self:stopAllActions()     --首先停止掉所有可能的动画 发牌/派奖池/下筹码

    for j=1,#self.m_pPlayersArray do  --每个已坐下的座位都移动
		local player = self.m_pPlayersArray[j]
		if(player)then
			player:moveWithOffset(tmpOffset)
		end
	end
	--旋转筹码
	local pChip = nil
	for i=1,#self.m_pPlayerChip do
		pChip = self.m_pPlayerChip[i]
		pChip:moveWithOffset(tmpOffset)
	end
    
	--设置庄家位
	self.m_dealerSeatId = self.m_dealerSeatId+tmpOffset
	if(self.m_dealerSeatId >= self.m_nTotalSeat) then
		self.m_dealerSeatId = self.m_dealerSeatId % self.m_nTotalSeat
	elseif(self.m_dealerSeatId < 0) then
		self.m_dealerSeatId = self.m_dealerSeatId+self.m_nTotalSeat
	end
	if(self.m_dealerSprite:isVisible()) then
		self.m_dealerSprite:setPosition(getDealerLocWith(self.m_nTotalSeat,self.m_dealerSeatId))
    end
	--自己有站起的时候累计偏移量

	self.m_seatOffset=self.m_seatOffset+tmpOffset
end

--[[玩家坐下]]
function RoomView:playerSit_Callback(isMyself, seatId, name, sex, imageURL, userId,
	diamond, needHint, needSex)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	--坐玩家
	local player = self:findPlayerByUserId(userId)
	if player then
		return
	end
	player = self:findPlayerBySeatId(seatId)
	if player then
		player:seat(self,sex,imageURL,name,
			userId,isMyself,diamond,needSex)
	end

	--隐藏所有沙发
	if isMyself then
		for i=1,#self.m_pPlayersArray do
			local playerE = self.m_pPlayersArray[i]
			if playerE then
				playerE:hiddenMySafa()
			end
		end
        
		if player then
			player:mySitAnimations1()
            
			if seatId == 0 and needHint then
				player:mySitAnimations2()
			end
		end
	end
end

--[[
 玩家站起
 是自己站起m_myselfSeatId肯定=false，
 别人站起时候要看自己有没有在座位
]]
function RoomView:playerSitOut_Callback(isMyself, myselfInSeat, seatId)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	
	if player then
		player:seatOut()
	end

	if isMyself then
		if self.m_leaveSitProtectUI then
			self.m_leaveSitProtectUI:setVisible(false)
		end
		--如果自己站起 别人可以显示沙发
		for i=1,#self.m_pPlayersArray do
			local playerE = self.m_pPlayersArray[i]
			if playerE then 
				playerE:displayMySafa()
			end
		end
        
		--取消所有公共牌的可能的高亮
		for i=1,#self.m_pCommunityCardArray do
			local poker = self.m_pCommunityCardArray[i]
			if poker then
				poker:cancelHighLightPoker()
			end
		end
        
		--隐藏操作面板
		if self.m_operateBoard ~= nil then
			self.m_operateBoard:hideAll()
--			self.m_newerGuideLayer:swithAdvanceHint(-1)
		end
	elseif not myselfInSeat then
		--别人站起时候 我自己坐下不能显示沙发 只有我也不在座位才显示沙发
		player:displayMySafa()
		if self.m_leaveSitProtectUI then
			self.m_leaveSitProtectUI:setVisible(false)
		end
	end
end

--[[更新庄家的位置]]
function RoomView:updateDealerPos_Callback(seatId, isAnimate)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
	
	self.m_dealerSeatId = seatId
    
	if(not isAnimate) then
		self.m_dealerSprite:setVisible(true)
		self.m_dealerSprite:setPosition(getDealerLocWith(self.m_nTotalSeat,seatId))
	else
		self.m_dealerSprite:setVisible(true)
		local dealerMoveTo = cc.MoveTo:create(0.3,getDealerLocWith(self.m_nTotalSeat,seatId))
		self.m_dealerSprite:runAction(dealerMoveTo)
	end
end

--[[显示公共牌]]
function RoomView:showPublicCard_Callback(cardIndex, cardName, isAnimate)
	-- if true then return end
	if cardIndex<0 or cardIndex>4 then
		return
	end
	local poker = require("app.GUI.roomView.Poker"):new()
    if poker then
        poker:initWithInfo(self.m_nTotalSeat,-1,cardIndex,cardName)
        self.m_tableBg:addChild(poker,kZCommunityCard)
        poker:createViewElements()
        self.m_pCommunityCardArray[#self.m_pCommunityCardArray+1] = poker

        self.m_betChips = 0
        self.m_myBetChips = 0

		MusicPlayer:getInstance():playDispatchCardSound1()
        if(cardIndex>2) then --第四和第五张公牌动画
            poker:dispatchPoker(false,isAnimate,0.0,9)
        else  --第一到三张牌动画
            poker:animationWithPublicCard31(isAnimate)
        end
    end
end

--[[显示玩家的牌]]
function RoomView:showPlayerCards_Callback(seatId, poker1, poker2, isAnimation)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
	local player = self:findPlayerBySeatId(seatId)
	if(player) then
        if (player:getUserId() == myInfo.data.userId) then
            self.m_betChips = 0
            self.m_bIsPlay = true
        end
		if(isAnimation) then   --玩家在座位亮牌
			player:switchPoker(0,poker1)
			player:switchPoker(1,poker2)
		else    --最初进房间给暗牌
			self.m_bIsRoomClear = false
			player:dispatchPoker(player:getUserId() == myInfo.data.userId,0,0.0,poker1,false)
			player:dispatchPoker(player:getUserId() == myInfo.data.userId,1,0.0,poker2,false)
		end
	end
end

function RoomView:callbackSDKPay(pObject)
	if self.m_pLoadingView then
        self.m_pLoadingView:stop()
    end

    
    if self.m_lastTourneyName == "上海电竞德州赛事预选赛" or self.m_lastTourneyName == "上海电竞扑克赛事预选赛" then
        self.m_roomManager:reqGetUserTicketList()
    else
        local tip = require("app.Component.ETooltipView"):alertView(self, "", "充值完成,稍候将刷新金币和物品数量", true)
        tip:setTouchHide(true)
        tip:show()
    end
end

--[[有动画发牌]]
function RoomView:dispatchPlayerCards_Callback(seatNo, index, delay, cardValue)
	--[[服务器返回座位对应的界面座位]]
	-- dump("dispatchPlayerCards_Callback")
	seatNo = self:serveSeatToViewSeat(seatNo)
    
	self.m_bIsRoomClear = false
    
	local player = self:findPlayerBySeatId(seatNo)

    if player:getUserId() == myInfo.data.userId then
        self.m_betChips = 0
        self.m_bIsPlay = true
    end
  
	if player then
		player:dispatchPoker(player:getUserId() == myInfo.data.userId,index,delay,cardValue,true)
	end
end

--[[接收到handFinish消息处理]]
function RoomView:dealHandFinish_Callback()
	self.m_clearAPCCId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		handler(self, self.clearAllPlayerCards_Callback),5.0,false)
	--[[请求亮牌界面]]
	local showDownView = self:getChildByTag(SHOWDOWN_VIEW_TAG)
	if showDownView then
		showDownView:getParent():removeChild(showDownView, true)
		showDownView = nil
	end
    self.m_bIsPlay = false

    if self.m_operateBoard then
		self.m_operateBoard:hideOperateBoard()
	end
    
	if self.m_bEnterTourneyHandFinish then
		self.m_bEnterTourneyHandFinish = false
		if self.m_roomManager then	
			self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEVAE_ROOM_TO_TOURNEYROOM)
		end
	end
end

--[[牌局结束清牌]]
function RoomView:clearAllPlayerCards_Callback(dt)

	if self.m_clearAPCCId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_clearAPCCId)
		self.m_clearAPCCId = nil
	end
	if self.m_bIsRoomClear then 
		return
	end
	self.m_bIsRoomClear = true
    
	if self.m_allPotLayer then
		self.m_allPotLayer:clearPots()
	end
    
    if self.m_pPlayersArray then
		for i=1,#self.m_pPlayersArray do
			local player = self.m_pPlayersArray[i]
			if player then
				player:clearPoker()
				player:winWithType(10)  --显示姓名
				player:resetMyWined()
			end
		end
	end
    
    if self.m_pCommunityCardArray then
		for i=1,#self.m_pCommunityCardArray do
			local poker = self.m_pCommunityCardArray[i]
			if poker then 
				poker:clearPoker()
			end
		end
	end
	self.m_pCommunityCardArray=nil
	self.m_pCommunityCardArray={}
end

--[[牌局重连清理]]
function RoomView:clearRoomViewAllElement_Callback()
	--请求亮牌界面
	local showDownView = self:getChildByTag(SHOWDOWN_VIEW_TAG)
	if showDownView then
		showDownView:getParent():removeChild(showDownView, true)
		showDownView = nil
	end
    
	-----------------
	if self.m_allPotLayer then
		self.m_allPotLayer:clearPots()
    end

	-----------------
	for i=1,#self.m_pPlayersArray do
		local player = self.m_pPlayersArray[i]
		if player then
			player:seatOut() 
			player:resetMyWined()
		end
	end
    
	-----------------
	for i=1,#self.m_pCommunityCardArray do
		local poker = self.m_pCommunityCardArray[i]
		if poker then 
			poker:clearPoker()
		end
	end
	self.m_pCommunityCardArray = nil
	self.m_pCommunityCardArray = {}
    
	-----------------
	for i=1,#self.m_pPlayerChip do
		local pNode = self.m_pPlayerChip[i]
		if pNode then 
			pNode:getParent():removeChild(pNode, true)
		end
	end
	self.m_pPlayerChip = nil
	self.m_pPlayerChip = {}
    
	----------------
	if self.m_operateBoard then
		self.m_operateBoard:hideAll()
	end
    
	---------------------------------------------
	if self.m_pStartNextHand then
		self.m_pStartNextHand:setVisible(false)
	end
    if self.m_nextSprite then
        self.m_nextSprite:setVisible(false)
    end
	---------------------------------------------
	self:showNewerGuideStage(kNewGuideStageNone)
	self.m_dealerSprite:setVisible(false)
end

--[[Rush牌局清理]]
function RoomView:clearRoomViewAllElement_Callback()
	--请求亮牌界面
	local showDownView = self:getChildByTag(SHOWDOWN_VIEW_TAG)
	if showDownView then
		showDownView:getParent():removeChild(showDownView, true)
		showDownView = nil
	end
    
	-----------------
	if self.m_allPotLayer then
		self.m_allPotLayer:clearPots()
    end
    
    -------------------
	for i=1,#self.m_pPlayersArray do
		local player = self.m_pPlayersArray[i]
		if player then
			if i~=1 then
				player:seatOut() 
				player:resetMyWined()
			else
				player:clearPoker()
				player:winWithType(10)  --显示姓名
				player:resetMyWined()
			end
		end
	end
    
	-----------------
	for i=1,#self.m_pCommunityCardArray do
		local poker = self.m_pCommunityCardArray[i]
		if poker then 
			poker:clearPoker()
		end
	end
	self.m_pCommunityCardArray = nil
	self.m_pCommunityCardArray = {}
    
	-----------------
	for i=1,#self.m_pPlayerChip do
		local pNode = self.m_pPlayerChip[i]
		if pNode then 
			pNode:getParent():removeChild(pNode, true)
		end
	end
	self.m_pPlayerChip = nil
	self.m_pPlayerChip = {}
    
	----------------
	if self.m_operateBoard then
		self.m_operateBoard:hideAll()
	end
    if self.m_pStartNextHand then
		self.m_pStartNextHand:setVisible(false)
	end
    if self.m_nextSprite then
        self.m_nextSprite:setVisible(false)
	end
	self:showNewerGuideStage(kNewGuideStageNone)

	self.m_dealerSprite:setVisible(false)
end

--[[玩家跟注(参数:座位号，跟注数，跟注后桌面钱数，跟注后Cell显示的钱数)]]
function RoomView:playerCall_Callback(isMyself, seatId, callChips, seatChips, userChips)
	--服务器返回座位对应的界面座位


	seatId = self:serveSeatToViewSeat(seatId)
    self.m_betChips = callChips
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:setChips(userChips)
		player:call(isMyself,callChips)
        
		--跟注动画
		local chip = require("app.GUI.roomView.AnimationChips")
			:create(self.m_nTotalSeat,seatId,callChips)
		self.m_tableBg:addChild(chip,kZAnimateChip)
        
        if (player:getUserId() == myInfo.data.userId) then
            self.m_betChips = 0
            self.m_myBetChips = callChips
        end
        
		local pRound = self:findPlayerChipBySeatId(seatId)
		if(not pRound) then
			self.m_pPlayerChip[#self.m_pPlayerChip+1] = chip
			chip:flyToUserRoundChip(callChips,false,nil,nil,nil,false)
		
		else
		
			pRound:setAddChipNum(callChips)
			chip:flyToUserRoundChip(callChips,true,self,handler(self,self.doAfterUserRaiseChip),pRound,true)
		end
	end
    
    local tmpRound1 = self:findPlayerChipBySeatId(seatId)
    if (tmpRound1) then
        local tmpRound = self:findPlayerChipByUserId(myInfo.data.userId)
        if (tmpRound) then
            self.m_betChips = tmpRound1.m_seatChip - tmpRound.m_seatChip
        else
            self.m_betChips = tmpRound1.m_seatChip
        end
    end
    if (self:findPlayerByUserId(myInfo.data.userId)) then
        if (self.m_betChips > self:findPlayerByUserId(myInfo.data.userId):getChips()) then
            self.m_betChips = self:findPlayerByUserId(myInfo.data.userId):getChips()
        end
    end
end

--[[玩家加注]]
function RoomView:playerRaise_Callback(isMyself, seatId, raiseChips, seatChips, userChips, isReRaise)
	--[[服务器返回座位对应的界面座位]]
	-- normal_info_log("RoomView:playerRaise_Callback玩家加注")

	seatId = self:serveSeatToViewSeat(seatId)
	self.m_betChips = raiseChips

    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:setChips(userChips)
		player:raise(isMyself,raiseChips,isReRaise)
        
		--跟注动画
		local chip = require("app.GUI.roomView.AnimationChips"):create(self.m_nTotalSeat,seatId,raiseChips)
		self.m_tableBg:addChild(chip,kZAnimateChip)
		chip:setPosition(cc.p(0,0))
        
        if player:getUserId() == myInfo.data.userId then
            self.m_betChips = 0
            self.m_myBetChips = raiseChips
        end
        
		local pRound = self:findPlayerChipBySeatId(seatId)

		if not pRound then
			self.m_pPlayerChip[#self.m_pPlayerChip+1] = chip
			chip:flyToUserRoundChip(raiseChips,false,nil,nil,nil,false)

			-- pRound = require("app.GUI.roomView.AnimationChips"):create(self.m_nTotalSeat,seatId,0)
			-- self.m_tableBg:addChild(pRound,kZAnimateChip)
			-- self.m_pPlayerChip[#self.m_pPlayerChip+1] = pRound
			-- pRound:setAddChipNum(raiseChips)
			-- chip:flyToUserRoundChip(raiseChips,true,self,handler(self,self.doAfterUserRaiseChip),pRound,true)
		else
			pRound:setAddChipNum(raiseChips)
			chip:flyToUserRoundChip(raiseChips,true,self,handler(self,self.doAfterUserRaiseChip),pRound,true)
		end
	end
    
    local tmpRound1 = self:findPlayerChipBySeatId(seatId)
    if tmpRound1 then
        local tmpRound = self:findPlayerChipByUserId(myInfo.data.userId)
        if tmpRound then
            self.m_betChips = tmpRound1.m_seatChip - tmpRound.m_seatChip
        else
            self.m_betChips = tmpRound1.m_seatChip
        end
    end
    if self:findPlayerByUserId(myInfo.data.userId) then
        if self.m_betChips > self:findPlayerByUserId(myInfo.data.userId):getChips() then
            self.m_betChips = self:findPlayerByUserId(myInfo.data.userId):getChips()
        end
    end

end

--[[玩家AllIn]]
function RoomView:playerAllin_Callback(isMyself, seatId, allInChips, seatChips, userChips)
	--服务器返回座位对应的界面座位
	seatId = self:serveSeatToViewSeat(seatId)
    
    if self.m_betChips<allInChips-self.m_myBetChips then
        self.m_betChips = allInChips- self.m_myBetChips
    end
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:setChips(userChips)
		player:allIn(isMyself)
        
		--跟注动画
		local chip = require("app.GUI.roomView.AnimationChips"):create(self.m_nTotalSeat,seatId,allInChips)
		self.m_tableBg:addChild(chip,kZAnimateChip)
        
        if player:getUserId() == myInfo.data.userId then
            self.m_betChips = 0
            self.m_myBetChips = allInChips
        end
        
		local pRound = self:findPlayerChipBySeatId(seatId)
		if not pRound then
			self.m_pPlayerChip[#self.m_pPlayerChip+1] = chip
			chip:flyToUserRoundChip(allInChips,false,nil,nil,nil,false)
		else
			pRound:setAddChipNum(allInChips)
			chip:flyToUserRoundChip(allInChips,true,self,handler(self,self.doAfterUserRaiseChip),pRound,true)
		end
	end
    
    local tmpRound1 = self:findPlayerChipBySeatId(seatId)
    if tmpRound1 then
        local tmpRound = self:findPlayerChipByUserId(myInfo.data.userId)
        if tmpRound then
            self.m_betChips = tmpRound1.m_seatChip - tmpRound.m_seatChip
        else
            self.m_betChips = tmpRound1.m_seatChip
        end
    end
    if self:findPlayerByUserId(myInfo.data.userId) then
        if self.m_betChips > self:findPlayerByUserId(myInfo.data.userId):getChips() then
            self.m_betChips = self:findPlayerByUserId(myInfo.data.userId):getChips()
        end
    end
end

--[[玩家静态设置自己筹码(包含下盲注，初始进房间,购买筹码成功)]]
function RoomView:playerChipsUpdate_Callback(seatId, handChips, roundChips, userChips)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
    if (self.m_betChips < roundChips - self.m_myBetChips) then
        self.m_betChips = roundChips - self.m_myBetChips
    end
	local player = self:findPlayerBySeatId(seatId)
    if(player) then
		player:setChips(userChips)
    end
    if player and (player:getUserId() == myInfo.data.userId) then
        self.m_betChips = 0
        self.m_myBetChips = roundChips
    end
	
	--[[改变桌面上筹码]]
	if(roundChips > 0) then
		local pRoundChip = self:findPlayerChipBySeatId(seatId)
		if(not pRoundChip) then
			pRoundChip = require("app.GUI.roomView.AnimationChips"):create(self.m_nTotalSeat,seatId,roundChips)
			if(pRoundChip) then
				self.m_tableBg:addChild(pRoundChip,kZAnimateChip)
				self.m_pPlayerChip[#self.m_pPlayerChip+1] = pRoundChip
			end
		end
	end
end

--[[底池返水]]
function RoomView:potReturn_Callback(userId, prize)
	local player = self:findPlayerByUserId(userId)
    local toSeat = player:getSeatID()

    --[[派奖筹码移动]]
    local chip = require("app.GUI.roomView.AnimationChips"):create(self.m_nTotalSeat,toSeat,prize)
    if chip then
        self.m_tableBg:addChild(chip,kZAnimateChip)
        chip:flyToWinerAndDisappear(prize,-1,toSeat)
    end
end

--[[更新公共奖池]]
function RoomView:updatePublicPots_Callback(potNum, index, potChips, isAnimate)
	--[[改变奖池]]
	if(potChips >= 0 and self.m_allPotLayer) then
		self.m_allPotLayer:setVisible(true)
		self.m_allPotLayer:addChipsWithInfo(index,potChips)
	end
    
	--[[收筹码至奖池动画]]
	local p = nil
	for i=1,#self.m_pPlayerChip do
		p = self.m_pPlayerChip[i]
		p:flyToDealerAndDisappear(potNum)
	end
	self.m_pPlayerChip = nil
	self.m_pPlayerChip = {}
end

--[[派奖]]
function RoomView:updatePrizePots_Callback(isMyself, potNum, fromPot, toSeat, prize, userChips, cardType, maxCard)
	--服务器返回座位对应的界面座位
	toSeat = self:serveSeatToViewSeat(toSeat)
	cardType = cardType+0
    local player = self:findPlayerBySeatId(toSeat)
	if cardType >= 0 and player and not player:hasMyWin() then  --当多个奖池分给同一个人时候只需调用一次
	 
        --显示谁赢了啥牌
        player:winWithType(cardType)

        --显示you win
		if isMyself and #maxCard>0 then
		-- if isMyself then
		
			require("app.GUI.roomView.WinAnimation"):runWinAnimation(self.m_tableBg,kZYouWin)
			--Music
			MusicPlayer:getInstance():playWinSound()
		else
			MusicPlayer:getInstance():playLoseSound()
		end
        
		--依次突起公牌
		for i=1,#maxCard do
			for j=1,#self.m_pCommunityCardArray do
				local poker = self.m_pCommunityCardArray[j]
				if poker then 
					poker:winPokerUp(maxCard[i])
				end
			end
		end
        
		--上移手牌
        for i=1,#maxCard do
			player:winPokerUp(maxCard[i])
        end
        
		--给未升起的牌加灰色
		for k=1,#self.m_pCommunityCardArray do
			local poker = self.m_pCommunityCardArray[k]
			if poker then
				poker:winPokerMask()
			end
		end
		player:winPokerMask()

	end
    
	--奖池变化
	if self.m_allPotLayer then
		self.m_allPotLayer:subChipsWithInfo(fromPot,prize)
    end

	--派奖筹码移动
	local chip = require("app.GUI.roomView.AnimationChips"):create(self.m_nTotalSeat,toSeat,prize)
	if chip then
		self.m_tableBg:addChild(chip,kZAnimateChip)
		chip:flyToWinerAndDisappear(prize,potNum,toSeat)
	end
end

--[[取消可能是自己的高亮牌]]
function RoomView:prizeCancelHighLightPokers_Callback()
	--[[隐藏面板]]
	if self.m_operateBoard ~= nil and self.m_operateBoard:getCurrentType() ~= 1 then
		self.m_operateBoard:hideOperateBoard()
	end
    
	--[[手牌]]
	local mine = self:findPlayerBySeatId(0)
	if mine then
		mine:cancelHighLightPoker(0)
		mine:cancelHighLightPoker(1)
	end
    
	--公共牌
	for j=1,#self.m_pCommunityCardArray do
		local poker = self.m_pCommunityCardArray[j]
		if poker then
			poker:cancelHighLightPoker()
		end
	end
end

--[[取消所有凸起牌]]
function RoomView:prizeCancelUpPokers_Callback(maxCard)
	--[[将玩家手牌下降]]
	for i=1,#self.m_pPlayersArray do
		local player = self.m_pPlayersArray[i]
		if player then
			local isUped = false
			for k=1,#maxCard do
				if player:hasUpedPoker(maxCard[k]) then
					isUped = true
					break
				end
			end
            
			if not isUped then
				player:winPokerDown()
            end
			player:winPokerCancelMask()
		end
	end
    
	--[[公牌下降]]
	for i=1,#self.m_pCommunityCardArray do
		local poker = self.m_pCommunityCardArray[i]
		if poker then
			local isUped = false
			for k=1,#maxCard do
				if poker.m_pokerName == maxCard[k] then
					isUped = true
					break
				end
			end
            
			if not isUped then --公牌有上升过且跟下轮牌不同
				poker:winPokerDown()
            end
			poker:winPokerCancelMask()
		end
	end
end

--[[当前正在下注玩家]]
function RoomView:waitForPlayerActioning_Callback(isMyself, seatId, remainTime, totalTime, callNum, mySeatId)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:waitForMsg(isMyself,remainTime,totalTime)
		if isMyself then

			if self.m_operateDelayMenu and self.m_operateBoard ~= nil and self.m_operateBoard:getCurrentType() ~= 1 then
   				self.m_operateDelayMenu:showDelayView(remainTime)
			end
			if self:getChildByTag(QUICK_RECHAGE_TAG) then
				self:removeChildByTag(QUICK_RECHAGE_TAG, true)
			end
		else

			if self.m_operateDelayMenu then
   				self.m_operateDelayMenu:setVisible(false)
			end
		end

		if self.m_operateBoard and self.m_roomManager then
			-- if mySeatId>-1 then
			-- 	self.m_operateBoard:callNumUpdate(callNum)
			-- end
			self.m_roomManager:reqMyPreOperateOpt(self.m_tableId,
				self.m_operateBoard:getSelectedCheckBoxIndex())
		elseif(self.m_roomManager) then
			self.m_roomManager:reqMyPreOperateOpt(self.m_tableId,-1)
		end
	end
end

--[[等待玩家亮牌]]
function RoomView:waitForPlayerShowDown_Callback(seatId, card1, card2)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
    if self.m_pPlayersArray then
		for i=1,#self.m_pPlayersArray do
			local player = self.m_pPlayersArray[i]
			if player then
				-- player:clearPoker()
			end
		end
	end

	local mine = self:findPlayerBySeatId(seatId)
	if mine then
		local showDowns = require("app.GUI.roomView.ShowDownMenu"):create(self,
			handler(self,self.showDownClicked_Callback), card1, card2)
		showDowns:setPosition(cc.p(0,0))
		self:addChild(showDowns,kZOperateBoard,SHOWDOWN_VIEW_TAG)
	end
end

--[[取消托管和我回来了]]
function RoomView:playerCancelTrustee_Callback(isMyself, seatId)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	--[[显示玩家姓名]]
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:cancelTrustee()
	end
	if isMyself then
		if self.m_leaveSitProtectUI then
			self.m_leaveSitProtectUI:setVisible(false)
		end
	end
end

--[[聊天信息]]
function RoomView:showTalkMsg_Callback(userId,duration,isMyself)
	local player = self:findPlayerByUserId(userId)
	if player then
		player:showTalkMsg(self.m_tableBg,duration,isMyself)
	end

end

--[[聊天信息]]
function RoomView:showChatMsg_Callback(isMyself, seatId, userName, chatMsg, chargeChips)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	-- dump(chatMsg)
	if player and chatMsg and string.len(chatMsg)>0 then
		--记录聊天记录 内容不包含表情
		local left
		local right
		local npos1 = string.find(chatMsg, "_", 12)
		local npos2 = string.find(chatMsg, "|", 10)
		if npos1 == nil or npos2 == nil then
			left = ""
			right = ""
		else
			left = string.sub(chatMsg, 1, npos1-1)
			right = "|"
		end
		-- dump(left)
		-- dump(right)
		local isFace = (left == "|exp_default") and (right == "|")
		if not isFace then
			local tmpMsg = clone(RVChatMsg)
			tmpMsg.boolIsMine = isMyself
			tmpMsg.userName   = userName
			tmpMsg.chatMsg    = chatMsg
			table.insert(self.m_chatMsgRecords, 1, tmpMsg)
			player:showChatMsg(self,isMyself,chatMsg,chargeChips,isFace)
		else
			player:showChatMsg(self,isMyself,string.sub(chatMsg, npos1+1, npos2-1),chargeChips,isFace)
		end
	end
	-- self:showTalkMsg_Callback(isMyself, seatId)
	
end

--[[弃牌动作]]
function RoomView:playerFold_Callback(isMyself, isTourneyAndTrust, seatId)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:fold(isMyself,isTourneyAndTrust)
	end
    
	if isMyself then
		--[[取消所有公共牌的可能的高亮]]
		for i =1,#self.m_pCommunityCardArray do
			local poker = self.m_pCommunityCardArray[i]
			if poker then
				poker:cancelHighLightPoker()
			end
		end
	end
end

--[[看牌动作]]
function RoomView:playerCheck_Callback(isMyself, seatId)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	if(player) then
		player:check(isMyself)
	end
end

--[[请求加为好友]]
function RoomView:applyFriend_Callback(userId, userName, bAdd, bSuccess)
	local tip
	if bAdd then
		tip = "申请好友"
	else
		tip = "删除好友"
	end

	if bSuccess then
		tip = tip.."成功"
	else
		tip = tip.."失败"
	end

	if self.m_tipsInfoHint then
		self.m_tipsInfoHint:addBubble(tip, true)
	end
end

function RoomView:clickButtonAtIndex(alertView, index)
	local tag = alertView:getTag()
	if tag == 99 then --加好友弹框
		for key,info in pairs(self.m_applyFriendInfos) do
			if info.view == alertView then
				if self.m_roomManager then
					self.m_roomManager:reqAgreeAddFriend(self.m_tableId, info.userId, info.userName, index==0 and false or true)
					table.remove(self.m_applyFriendInfos, info)
					return
				end
			end
		end
	elseif tag == 101 then --筹码超过房间的最大买入提示更换房间
		if index==1 then --重新快速开始
			if self.m_roomManager then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId, false, LEVAE_ROOM_TO_CHANGROOM)
			end
		end
	elseif tag == 102 then --确认是否退出房间提示
		if index==1 then
			if self.m_roomManager then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId, false,  self.m_leaveType)--LEAVE_ROOM_TO_QUITROOM)
			end
		end
	elseif tag == 103 then --确认是否进入锦标赛
		if index == 1 then 
			if self.m_roomManager then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEVAE_ROOM_TO_TOURNEYROOM)
			end
		end
	elseif tag == 104 then 
		if index == 0 then 
			if self.m_roomManager then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId, false, LEVAE_ROOM_TO_QUITTOURNEY)--LEVAE_ROOM_TO_QUITTOURNEY)
			end
		end
	elseif tag == 112 then 
		if index == 1 then 
			if self.m_roomManager then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEVAE_ROOM_TO_TOURNEYROOM)
			end
		else
			--锦标赛中提示锦标赛开始  用户取消则退出提示的比赛
			if self.m_roomManager then 	
				self.m_roomManager:reqQuitTourney(self.m_tourneyTableId)
			end
		end
	elseif tag == 113 then 
		if index == 0 then 
			if self.m_roomManager then 
				local bPlaying = self.m_roomManager:reqGamblingIsCarryOn(self.m_tableId)
				if bPlaying then 
					self.m_bEnterTourneyHandFinish = true
				else
					self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEVAE_ROOM_TO_TOURNEYROOM)
				end
			end
		elseif index == 1 then 
			if(self.m_roomManager) then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEVAE_ROOM_TO_TOURNEYROOM)
			end
		end
	elseif tag == 114 then 
		if index == 0 then 
			if self.m_roomManager then 	
				self.m_roomManager:reqMyLeaveTable(self.m_tableId, false, self.m_leaveType)--LEVAE_ROOself.m_TO_QUITTOURNEY)
			end
		end
	elseif tag == 115 then 
		if index == 0 then 
			GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)
			-- local scene = require("app.GUI.Tourney.TourneyList"):scene(eMatchListRecommend)
			-- GameSceneManager:switchScene(scene)
		else
			GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)
			-- local scene = require("app.GUI.Tourney.TourneyList"):scene(eMatchListRecommend)
			-- GameSceneManager:switchScene(scene)
		end
	elseif tag == 116 then 
        if index == 1 then 
            -- GameSceneManager:switchSceneWithType(EGSShop)

		local dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
		handler(self,self.buyChipDialogCallBack),self.m_buyTableInfo.max, self.m_buyTableInfo.min, 
		self.m_buyTableInfo.myChips, self.m_buyTableInfo.bigBlind, self.m_buyTableInfo.payType,self.m_buyTableInfo.isAdd, 
		self.m_buyTableInfo.defaultValue, self.m_buyTableInfo.needShowAutoBuySign,1,self.m_buyTableInfo.serviceCharge,self.m_isPrivateRoom)
		dialog:setPayType(self.payType)
		if dialog then
			self:addChild(dialog, kZMax)
			dialog:setPosition(LAYOUT_OFFSET)
			dialog:setTag(kTagBuyChipDialog)
			dialog:show()
		end
        end
    elseif tag == 117 then --上海电竞赛  充值弹窗
        if index == 1 then --直接充值
            self.m_chargeLogic = nil
            self.m_chargeLogic = new BaseMainShop()
            self.m_chargeLogic:setMainShopCallback(self)
            if self.m_pLoadingView then 
                self.m_pLoadingView:start()
            end

                
            if self.m_onEventWhere ~= eOnEventUnkowRecharge then 
                    TalkingGameAnalytics:onEvent(self.m_onEventWhere, eOnEventActionClickItem)
            end

			if DEBAO_PHONE_PLATFORM == DEBAO_ANDROID then
                local info = clone(BuyDebaoBIInfo)
                info.buyCoinId = "P1011"
                info.buyCoinInfo = "1080000金币"
                info.buyCoinpicUrl = "shop/P1011.png"
                info.awardNum = 0
                info.moneyBalance = 1080000
                info.buyCoinNum = 108
                info.goodDesc = "1080000金币"
                info.goodId =""
                local tmp = {}
                local tmp1 = clone(BuyDebaoBIPayInfo)
                tmp1.desc=""
                tmp1.method = "ZFB"
                tmp[#tmp+1] = tmp1
                local tmp2 = clone(BuyDebaoBIPayInfo)
                tmp2.desc=""
                tmp2.method = "UP"
                tmp[#tmp+1] = tmp2

                info.payType = tmp

				if BRANCHES_VERSION == CHINAUNICOM then
                    self.m_chargeLogic:reqChargingOrder(eRechargeUniPay, info)
				elseif BRANCHES_VERSION == TENCENT_WITH_PAY then
                    self.m_chargeLogic:reqChargingOrder(eRechargeTencentUnipay, info)
				elseif BRANCHES_VERSION == PPSPLATFORM then
                    self.m_chargeLogic:reqChargingOrder(eRechargePPS, info)
				elseif BRANCHES_VERSION == DKBAIDU then
                    self.m_chargeLogic:reqChargingOrder(eRechargeDKPay, info)
				elseif BRANCHES_VERSION == ALIPAYOPEN then
                    self.m_chargeLogic:reqChargingOrder(eRechargeAliPayOpen, info)
				elseif BRANCHES_VERSION == WIRELESS_91 then
                    self.m_chargeLogic:reqChargingOrder(eRecharge91DPay, info)
				else
                    local dialog = MainShopChannelDialog:dialog(info)
                    dialog:setCallback(handler(self, self.clickChannelSelectCallback))
                    self:addChild(dialog, kZMax)
				end
                
			else
                local info = clone(BuyDebaoBIInfo)
                info.buyCoinId = "P2005"
                self.m_chargeLogic:reqChargingOrder(eRechargeApple, info)
			end
        else
            GameSceneManager:switchSceneWithType(EGSMainPage)
        end
    end
end

--[[
 牌型提示
 自己看到的发2567张牌时候成手牌
]]
--[[封装牌发完翻完再比较大小]]
function RoomView:delayHighLightMyCards()
	--[[解析]]
	local resA = self.m_hightLightMyCards
	local seatId = resA[1]+0
	local res    = resA[2]+0
	local cardsIndex = {}
	for i=3,#resA do
		local tmp = resA[i]+0
		cardsIndex[i-2]=tmp
	end
    
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local mine = self:findPlayerBySeatId(seatId)
    
	--[[首先清除掉原来的可能的所有高亮牌]]
	mine:cancelHighLightPoker(0)
	mine:cancelHighLightPoker(1)
	for i=1,#self.m_pCommunityCardArray do
		local poker = self.m_pCommunityCardArray[i]
		if(poker) then
			poker:cancelHighLightPoker()
		end
	end
    
	--需要高亮牌的索引(23410)
	for i=1,#cardsIndex do
		if(cardsIndex[i] == 0 or cardsIndex[i] == 1) then --手上牌01
			mine:highLightPoker(cardsIndex[i])
		elseif(cardsIndex[i]>1 and cardsIndex[i]<7) then --公牌23456
			if cardsIndex[i]-2 < #self.m_pCommunityCardArray then
				local poker = self.m_pCommunityCardArray[cardsIndex[i]-2+1]
				if(poker) then
					poker:highLightPoker()
				end
			end
		end
	end
    
	--弹出提示
	local visibleSize = cc.Director:getInstance():getWinSize()
	local highLight = require("app.GUI.roomView.HighLightSprite"):createWithType(res,self.m_tableType)
	highLight:setPosition(cc.p(720,100))
	self.m_tableBg:addChild(highLight,kZMax)
end

function RoomView:hightLightMyCards(seatId, cardsIndex, res)
	--[[封装牌发完翻完再比较大小]]
	self.m_hightLightMyCards = nil
	self.m_hightLightMyCards = {}
	self.m_hightLightMyCards[1] = seatId
	self.m_hightLightMyCards[2] = res
	for i=1,#cardsIndex do
		self.m_hightLightMyCards[2+i] = cardsIndex[i]
	end

	local delay  = cc.DelayTime:create(POKER_DISP_ACTION_DURATION+POKER_SWITCH_ACTION_DURATION*2.0)
	local action = cc.Sequence:create(delay,cc.CallFunc:create(handler(self,self.delayHighLightMyCards)))
    
	self:runAction(action)
end

function RoomView:showConfirmQuitRoom()
	local view = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
        Lang_QuitRoom_Confirm, Lang_Button_Cancel, Lang_Button_Confirm)
	view:alertShow()
	view:setTag(102) --确认是否退出房间提示
end

function RoomView:showConfirmQuitTourneyRoom()
	local view = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
        Lang_QuitTourneyRoom_Confirm, "弃权", "继续比赛")
	view:alertShow()
	view:setTag(104)
end

function RoomView:showConfirmQuitSngPkRoom()
	local view = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
        "是否退出pk赛？", "退出", "继续比赛")
	view:alertShow()
	view:setTag(114)
end

function RoomView:showStartNextHand(msg, isVisible)
	if self.m_pStartNextHand then
		self.m_pStartNextHand:setString(msg)
		self.m_pStartNextHand:setVisible(isVisible)
        self.m_nextSprite:setVisible(isVisible)
	end
end

function RoomView:showProtectedDialog_Callback(times, awardNum, maxBuyin, minBuyin)
	self.m_freeGoldTimes = self.m_freeGoldTimes-1
    if self.m_freeGoldTimes>0 then
       self:showFreeGoldDialog_Callback()
    end
end

function RoomView:showFreeGoldDialog_Callback()
    if self:getChildByTag(TASK_TAG) then
        self:removeChildByTag(TASK_TAG)
    end
    
    
    local me = self:findPlayerByUserId(myInfo.data.userId)
    local allOfMyMoney = 200
    if me then
        allOfMyMoney = myInfo:getTotalChips() + me:getChips()
    else
        allOfMyMoney = myInfo:getTotalChips()
    end
    
    local enoughMoney = allOfMyMoney>200 and true or false
    
    local dialog = require("app.GUI.roomView.FreeGoldDialog"):dialog(self,handler(self, self.freeGoldDialogCallBack),enoughMoney)
    if dialog then
        self:addChild(dialog,kZMax,TASK_TAG)
        dialog:setPosition(LAYOUT_OFFSET)
        dialog:show()
    end
end

function RoomView:showFirstChargeDialog_Callback(showType, desc, isFromClick)
	local dialog = require("app.GUI.dialogs.FirstRechargeDialog"):create(
		self, handler(self, self.firstRechargeDialogCloseCallback),isFromClick,true)
    dialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
	self:addChild(dialog,kZMax)
end

--[[显示坐下购买提示信息]]
function RoomView:showSitAndBuyFailureMsg_Callback(msg, balance, minBuyin, needShowStore, moreChips, actionType, isRakePoint)
	balance = balance+0
	minBuyin = minBuyin+0
	moreChips = moreChips and moreChips or false
	actionType = actionType and actionType or 0
	actionType = actionType+0
   
	--[[弹出提示]]
    if not needShowStore and not moreChips and self.m_tipsInfoHint then
		self.m_tipsInfoHint:addBubble(msg, true)
	elseif needShowStore then--筹码不够弹窗
        if isRakePoint then
            local view = require("app.Component.EAlertView"):alertView(
                                                     self,
                                                     self,
                                                     Lang_Title_Prompt,
                                                     "积分余额不足，无法加入牌局",
                                                     Lang_Button_Cancel,
                                                     "前往金币桌")
            view:alertShow()
            view:setTag(101)
        else
            local action = (actionType == BUYINFAIL_ACTION_CHANGEROOM) and kChangeRoom or kLeaveRoom
            local dialog = require("app.GUI.dialogs.InsufficientBalanceDialog"):create(self, handler(self, self.quickRechargeDialogCallBack), 
            	nil,self.m_roomManager:reqMyBigBlind(self.m_tableId),balance,minBuyin,action)
            dialog:setPosition(LAYOUT_OFFSET)
            dialog:setButtonClickCallback(self,handler(self, self.leaveRoomCallback))
            self:addChild(dialog,kZMax)
            self.m_onEventWhere = eOnEventOtherRecharge
        end
	elseif moreChips then --筹码超过了房间的最大买入建议到更大的场次玩
		local view = require("app.Component.EAlertView"):alertView(
                                                 self,
                                                 self,
                                                 Lang_Title_Prompt,
                                                 msg,
                                                 Lang_Button_Cancel,
                                                 Lang_Button_Search)
		view:alertShow()
		view:setTag(101)--筹码超过了房间的最大买入建议到更大的场次玩
	end
end

--[[显示表情聊天框]]
function RoomView:showChatOrEmotionDialog_Callback(isChat)
	if isChat then --显示聊天框
		local dialog = require("app.GUI.roomView.ChatAndExpressionDialog"):dialog(self.m_chatMsgRecords, 
			handler(self,self.chatDialogCallBack), handler(self, self.chatDialogCallBack), 0)
        dialog:setPosition(LAYOUT_OFFSET)
		self:addChild(dialog, kZMax)
		dialog:show()
	else --显示表情框
		local dialog = require("app.GUI.roomView.ChatAndExpressionDialog"):dialog(self.m_chatMsgRecords, 
			handler(self,self.chatDialogCallBack), handler(self, self.chatDialogCallBack), 1)
        dialog:setPosition(LAYOUT_OFFSET)
		self:addChild(dialog, kZMax)
		dialog:show()
	end
end 

--[[请求亮牌]]
function RoomView:showDownClicked_Callback(pObj)
	local clickedMenu = pObj
	local indexS = clickedMenu:getSelectedIndex()
	if indexS>=0 and indexS <=3 then
		if self.m_roomManager then	
			self.m_roomManager:reqMyShowDown(self.m_tableId,indexS)
        end

		if indexS == 1 or indexS == 2 then
			--[[当选择亮一张牌的时候 把不亮的那张盖起]]
			local mine = self:findPlayerBySeatId(0)
			if mine then
				mine:showDownUp(indexS%2)
			end
		end
	else

    end
	clickedMenu:getParent():removeChild(clickedMenu, true)
end

--------------------------------------------------

--[[操作面板]]
--------------------------------------------------
--[[操作面板回调事件]]
function RoomView:operateBoardClicked_Callback(pObj)
	local p = pObj
	local nClickType = p:getClickType()

	if nClickType == 0 then --回座
        if self.m_leaveSitProtectUI then
        	self.m_leaveSitProtectUI:setVisible(false)
        end
        if self.m_roomManager then
            self.m_roomManager:reqMySetAutoBlind(self.m_tableId,AUTO_BLIND_ACCEPT_ALL)--设置同意自动支付新手盲、或者正常的前注、大盲注
            self.m_roomManager:reqMyCancel(self.m_tableId)
        end
    elseif nClickType == 1 then --弃牌
        if self.m_roomManager then	
        	self.m_roomManager:reqMyFoldPocker(self.m_tableId)
        end
    elseif nClickType == 2 then --看牌
        if self.m_roomManager then	
        	self.m_roomManager:reqMyCheckPoker(self.m_tableId)
        end
    elseif nClickType == 3 then --加注
        if self.m_roomManager then	
        	self.m_roomManager:reqMyRaise(self.m_tableId,p:getRaiseNum())
        end
    elseif nClickType == 4 then --All In
        if self.m_roomManager then	
        	self.m_roomManager:reqMyAllIn(self.m_tableId)
        end
    elseif nClickType == 5 then --跟注
        if self.m_roomManager then	
        	self.m_roomManager:reqMyCallPocker(self.m_tableId)
        end
    elseif nClickType == 9 then --快速弃牌
        if self.m_roomManager then	
        	self.m_roomManager:reqFastFold_Rush(self.m_tableId)
        end
    elseif nClickType == 6 then --预选弃牌
        return
    elseif nClickType == 7 then --预选看或弃
        return
    elseif nClickType == 8 then --预选跟任何注
        return
    elseif nClickType == 10 then --预选看牌
        return
    elseif nClickType == 11 then --预选跟注
        return
    end
	p:UnSelectProOperate()
	if self.m_roomManager then
		self.m_roomManager:setIsFirstRound(self.m_tableId,false)
	end
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)

	if self.m_operateDelayMenu then
   		self.m_operateDelayMenu:setVisible(false)
   	end
end


function RoomView:doAfterUserRaiseChip(pObj)
	local p = pObj
	p:runAddChipAnimation()
end

--[[玩家超时显示我回来了]]
function RoomView:playerTimeout(isMyself, seatID)
	--[[服务器返回座位对应的界面座位]]
	seatID = self:serveSeatToViewSeat(seatID)
    
	--[[显示玩家暂离]]
	local player = self:findPlayerBySeatId(seatID)
	if player then
		player:timeOutTrustee()
	end
    
	if isMyself then
		if(self.m_operateBoard ~= nil) then
			self.m_operateBoard:ShowComebackSeat()
			if self.m_leaveSitProtectUI then
				self.m_leaveSitProtectUI:setVisible(true)
			end
		end
	end
end

--[[看或弃 弃 跟注]]
function RoomView:showPreOperate(chips)
	 -- if self:findPlayerByUserId(myInfo.data.userId) and
	 --  	self:findPlayerChipByUserId(myInfo.data.userId) then
	 chips = chips or self.m_betChips
        if self.m_operateBoard ~= nil then
			self.m_operateBoard:ShowPreOperate(chips)
        end
    -- end
end

--[[Rush显示快速弃牌]]
function RoomView:showFastFoldForRush_Callback()
	if self.m_operateBoard~=nil then
		self.m_operateBoard:showFastFold()
	end
end

--[[弃牌看牌加注]]
function RoomView:showFoldCheckRaiseOp(minRaNum, maxRaNum, blindNum, pot, extra)
	if self.m_operateBoard ~= nil then
        self.m_operateBoard:ShowFoldCheckRaiseOp(minRaNum,maxRaNum,blindNum,pot,extra)
    end
end

--[[弃牌跟注加注]]
function RoomView:showFoldCallRaiseOp(callNum, minRaNum, maxRaNum, blindNum, pot, extra)
	if self.m_operateBoard ~= nil then
		self.m_operateBoard:ShowFoldCallRaiseOp(callNum,minRaNum,maxRaNum,blindNum,pot,extra)
    end
end

--[[弃牌Allin加注]]
function RoomView:showFoldCallAllIn(callNum)
	if self.m_operateBoard ~= nil then
		self.m_operateBoard:ShowFoldCallAllIn(callNum)
	end
end

--[[清除预选]]
function RoomView:unselectPreOperate()
	if self.m_operateBoard ~= nil then
		self.m_operateBoard:UnSelectProOperate()
	end
end

function RoomView:shanghaiTourneyDialogCallBack()
	self.m_roomManager:reqApplyMatch(self.m_shanghaiTourneyMatchId)
end

function RoomView:showSpecialTourneyResultDialog(matchId, flag)
	if flag then
        self.m_shanghaiTourneyMatchId = matchId
        local dialog = ShanghaiTourneyDialog:dialog(handler(self, self.shanghaiTourneyDialogCallBack))
        if dialog then
            self:addChild(dialog,kZMax,TASK_TAG)
            dialog:setPosition(LAYOUT_OFFSET)
            dialog:show()
        end
    else
		local view = require("app.Component.EAlertView"):alertView(self,self,"上海电竞预选赛",
            "您已经被淘汰\n是否花费108元重新进入比赛","返回大厅","充值购买")
        view:setTag(117)
        view:alertShow()
    end
end

--[[新手引导]]
--------------------------------------------------
function RoomView:showNewerGuideStage(guideType)
	local newerGuide = self.newer_guide_layer
	if newerGuide then
		if guideType >= kNewGuideStageFlop and guideType <= kNewGuideStageRiver then
			self.newer_guide_layer:setVisible(true)
			self.flop_guide_layer:setVisible(guideType >= kNewGuideStageFlop)
			self.turn_guide_layer:setVisible(guideType >= kNewGuideStageTurn)
			self.river_guide_layer:setVisible(guideType >= kNewGuideStageRiver)
		else
			self.newer_guide_layer:setVisible(false)
		end
	end
end



function RoomView:showNewerGuideActionHint(type, opType)
	if self.m_operateBoard~=nil then
		self.m_operateBoard:showNewerGuideHint(opType)
	end
end

--[[锦标赛]]
--------------------------------------------------
function RoomView:matchResultCallback(pNode, data)
	local index = data
	if index == 0 then
		self:leaveTable_Callback(true, LEAVE_ROOM_TO_QUITROOM)
	else
		self:leaveTable_Callback(true, LEVAE_ROOM_TO_CHANGROOM)
	end
end

function RoomView:leaveRoomCallback(pNode, data)
	if not self.m_roomManager then
		return
	end
	local action = data
	if action == 0 then
		self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEAVE_ROOM_TO_QUITROOM)
	elseif action == 1 then
		self.m_roomManager:reqMyLeaveTable(self.m_tableId,false,LEVAE_ROOM_TO_CHANGROOM)
	elseif action == 2 then
		local dialog = require("app.GUI.roomView.BuyChipAndQuickRecharge"):dialog(self,
		handler(self,self.buyChipDialogCallBack),self.m_buyTableInfo.max, self.m_buyTableInfo.min, 
		self.m_buyTableInfo.myChips, self.m_buyTableInfo.bigBlind, self.m_buyTableInfo.payType,self.m_buyTableInfo.isAdd, 
		self.m_buyTableInfo.defaultValue, self.m_buyTableInfo.needShowAutoBuySign, 1,self.m_buyTableInfo.serviceCharge,self.m_isPrivateRoom)
		dialog:setPayType(self.payType)
		if dialog then
			self:addChild(dialog, kZMax)
			dialog:setPosition(LAYOUT_OFFSET)
			dialog:setTag(kTagBuyChipDialog)
			dialog:show()
		end
        self.m_onEventWhere = eOnEventQuickRecharge
    end
end

function RoomView:firstRechargeDialogCloseCallback(pNode, data)
	self:doQuickCharge(self)
end

function RoomView:fetchFirstRechargeRewardSuccCallback()
	self:changeFirstRechargeButtonStatus(0)
end

function RoomView:outCompetitionByElimination(userRanking, gainStr, matchPoint, matchName)
	if self.m_rebuyDialog then
		self.m_rebuyDialog:hide()
		self.m_rebuyDialog = nil
	end
    
    if ((matchName == "上海电竞德州赛事预选赛" or matchName == "上海电竞扑克赛事预选赛" ) and userRanking>1) then
--        显示电竞赛重构
        self.m_lastTourneyName = matchName
        selfm_roomManager:reqGetUserTicketList()
        return
    end
    
	if (self.m_tableType == eTourneyTable) then
		local dialog = require("app.GUI.dialogs.MatchResultDialog"):create(self, handler(self,self.matchResultCallback),userRanking,gainStr,matchPoint, matchName,1)
        dialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
		self:addChild(dialog,kZMax,MatchResultDialog_TAG)
	
	elseif(self.m_tableType == eSngPKTable) then
	elseif(self.m_tableType == eSngTable) then
		local dialog = require("app.GUI.dialogs.MatchResultDialog"):create(self, handler(self,self.matchResultCallback),userRanking,gainStr,matchPoint, matchName,0)
        dialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
		self:addChild(dialog,kZMax,MatchResultDialog_TAG)
	end
end

function RoomView:updateBlind(bigBlind, smallBling, type)

	if self.m_matchRankInfo and self.m_tableType == eTourneyTable then
		self.m_matchRankInfo:updateMatchBlindInfo(smallBling,bigBlind)
	end
    
	if self.m_tourneyBlindInfo and self.m_tableType == eSngPKTable then
		self.m_tourneyBlindInfo:updateTourneyBlindInfo(bigBlind, smallBling, eBlindCurrent)
	end
end

function RoomView:updateUserRanking(userRanking, totoalNum)
	if self.m_matchRankInfo then
		self.m_matchRankInfo:updateMatchRankInfo(userRanking,totoalNum)
	end
end

function RoomView:updateAnte(ante)
	if self.m_matchRankInfo and self.m_tableType == eTourneyTable then
	
		self.m_matchRankInfo:updateMatchAnteInfo(ante)
	end
	if self.m_tourneyBlindInfo and  self.m_tableType == eSngPKTable then
	
		self.m_tourneyBlindInfo:updateTourneyBlindInfo(ante, 0, eBlindNext)
	end
end

function RoomView:MergerTourneyRoom(enterTableId, matchName)
    --请求亮牌界面
    local showDownView = self:getChildByTag(SHOWDOWN_VIEW_TAG)
    if showDownView then
    	showDownView:getParent():removeChild(showDownView, true)
        showDownView = nil
    end
    
    -----------------
    if self.m_allPotLayer then
        self.m_allPotLayer:clearPots()
    end
    -----------------
    for i=1,#self.m_pPlayersArray do
    
        local player = self.m_pPlayersArray[i]
        if player then
        
            if i~=1 then
            
                player:seatOut()
                player:resetMyWined()
            else
            
                player:clearPoker()
                player:winWithType(10)  --显示姓名
                player:resetMyWined()
            end
        end
    end
    
    -----------------
    for i=1,#self.m_pCommunityCardArray do
    
        local poker = self.m_pCommunityCardArray[i]
        if poker then 
        	poker:clearPoker()
        end
    end
    self.m_pCommunityCardArray = nil
    self.m_pCommunityCardArray = {}
    
    -----------------
    for i=1,#self.m_pPlayerChip do
    
        local pNode = self.m_pPlayerChip[i]
        if pNode then
        	pNode:getParent(pNode, true)
        end
    end
    self.m_pPlayerChip = nil
    self.m_pPlayerChip = {}
    
    ----------------
    if self.m_operateBoard then
    
        self.m_operateBoard:hideAll()
    end
    
    ---------------------------------------------
    self.m_dealerSprite:setVisible(false)
    
    
	local loading = require("app.GUI.LoadingScene"):createLoading()
	GameSceneManager:switchSceneWithNode(loading)
	loading:changeTipsType(ForChiampion_Loading_Tips)
	loading:enterTourneyRoom(enterTableId)
end

function RoomView:showEnterTourneyRoomPrompt(enterTableId, matchName)
	local view = nil
	--区分是否正在锦标赛中 此处处理遇到临界情况不可控
	if self.m_tableType == eTourneyTable then
	
		view = require("app.Component.EAlertView"):alertView(self,self,"比赛开始了",
            matchName.."锦标赛已经开始，是否放弃您正在进行的锦标赛，前往下一场？","取消","确定")
		view:setTag(112)
	else
	
		if TRUNK_VERSION==DEBAO_TRUNK then
			view = require("app.Component.EAlertView"):alertView(self,self,"比赛开始了",
            	"您参加的"..matchName.."比赛","取消","确定")
			view:setTag(103)
		else
			if self.m_roomManager then
		
				local bPlaying = self.m_roomManager:reqGamblingIsCarryOn(self.m_tableId)
				if bPlaying then
					view = require("app.Component.EAlertView"):alertView(self,self,"比赛开始了",
            			"您参加的"..matchName.."已经开始，是否立即进入？","本局结束后进入","立即进入")
					view:enableColseButton(true)
					view:setTag(113)
				else
					view = require("app.Component.EAlertView"):alertView(self,self,"比赛开始了",
            			"您参加的"..matchName.."已经开始，是否立即进入？","取消","立即进入")
					view:enableColseButton(true)
					view:setTag(103)
				end
			end
		
		end
	end
	
	self.m_tourneyTableId = enterTableId
	view:show()
end

function RoomView:setMatchInfo(matchdId, bonusName, gainName, curPlayer)
	if self.m_matchRankInfo then
	
		self.m_matchRankInfo:setMatchInfo(matchdId,bonusName,gainName,curPlayer,self.payType)
	end
end

function RoomView:showGameWaitPrompt()
	if self.m_tipsInfoHint then
		self.m_tipsInfoHint:addBubble(Lang_TOURNEY_STATR, true)
	end
end

function RoomView:showCountDown(bstart, startCount, endCount, timeSpan, showType)
	if bstart then
	
		if not self.m_countDown then
		
			self.m_countDown = require("app.GUI.roomView.CountDown"):create(startCount, endCount, timeSpan, self.m_tableType, showType)
			self:addChild(self.m_countDown, kZMax - 1)
			self.m_countDown:setPosition(cc.p(display.cx, display.cy))
		end
		self.m_countDown:startCount()
	else
	
		if not self.m_countDown then
			return
		end
		self.m_countDown:stopCount()
		self.m_countDown:getParent():removeChild(self.m_countDown, true)
		self.m_countDown = nil
	end
end

--[[决赛桌提示]]
function RoomView:tourneyFinalTable()
	local size = display.size
    
	local sprite = cc.Sprite:create(s_final_table_image)
	sprite:setScale(3)
	sprite:setOpacity(125)
	sprite:setPosition(cc.p(size.width / 2, size.height / 2))
	self:addChild(sprite,kZMax)
    
	local pIn = cc.Spawn:create(cc.ScaleTo:create(0.5,1),cc.FadeIn:create(0.5))
	local pDelay = cc.DelayTime:create(2.0)
	local pOut = cc.Spawn:create(cc.ScaleTo:create(0.5,3),cc.FadeOut:create(0.5))
	local pClean = cc.CallFunc:create(handler(self, self.removeNodeFromRoom), {sprite})
    
	local action = cc.Sequence:create(pIn,pDelay,pOut,pClean)
    
	sprite:runAction(action)
end

function RoomView:enabledRebuyButton(bEnable)
	local itemList = {}

	if not self.m_rebuyButton then
		self.m_rebuyButton = self:createMenu(s_room_rebuyN,s_room_rebuyS,handler(self,self.doRebuyAction))
	end
	itemList[#itemList+1]=self.m_rebuyButton

	self.m_Menubar:updateItemList(itemList)
end

function RoomView:showRebuyDialog(bManually, rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime,payType)
	if self.m_rebuyDialog then
		self.m_rebuyDialog = nil
	end

	self.m_rebuyDialog = require("app.GUI.roomView.RebuyDialog"):dialog(self, handler(self, self.rebuyDialogCallBack), rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime,false,payType)
	if bManually then
		self.m_rebuyDialog:setTag(REBUY_MANUL)
	else
		self.m_rebuyDialog:setTag(REBUY_AUTO)
    end

    self.m_rebuyDialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
	self:addChild(self.m_rebuyDialog, kZMax)
	self.m_rebuyDialog:show()
end

function RoomView:showAddOnDialog(bManually, rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime,payType)
	if self.m_rebuyDialog then
		self.m_rebuyDialog = nil
	end
	self.m_rebuyDialog = require("app.GUI.roomView.RebuyDialog"):dialog(self, handler(self, self.rebuyDialogCallBack), 
		rebuyValue, rebuyAdd, bEnoughMoney, rebuyLimitTime,true,payType)
	self.m_rebuyDialog:setTag(ADDON_MANUL)
    self.m_rebuyDialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
	self:addChild(self.m_rebuyDialog, kZMax)
	self.m_rebuyDialog:show()
end

function RoomView:showInfoHint(infoToShow)
	if self.m_tipsInfoHint then
		self.m_tipsInfoHint:addBubble(infoToShow, true)
	end
end

function RoomView:showRebuyResult(rebuyResult, bSecuss)
	local tip = require("app.Component.ETooltipView"):alertView(self, "", rebuyResult, bSecuss)
	tip:setTouchHide(true)
	tip:show()
end

function RoomView:showSngUserChipsSlider(myChips, otherChips)
	if self.m_sngPKSlider then
	
		local temp = myChips + otherChips
		self.m_sngPKSlider:setValue(temp == 0 and 0 or otherChips/temp)
	end
end

function RoomView:sngOutCompetitionByElimination(userRanking, mySeatId, theOtherSeadId, mineWins, otherWins, bInActivity)
	if bInActivity then
	
		mineWins = mineWins > 0 and mineWins or 0
		otherWins = otherWins > 0 and otherWins or 0
		self:updateUserSngInfo(mySeatId, mineWins)
		self:updateUserSngInfo(theOtherSeadId, otherWins)
	end
	
	if ((mineWins == 3 or mineWins == 6 or mineWins == 10) and bInActivity and userRanking == 1) then
		self.m_sngMineWinTimes = mineWins
	else
		self.m_sngMineWinTimes = -1
	end

	self.m_sngMineRanking = userRanking
	local bWin = userRanking == 1
	self.m_sngAnimationLayer = display.newLayer()
	self:addChild(self.m_sngAnimationLayer, kZMax)
	local me = self:findPlayerBySeatId(self:serveSeatToViewSeat(mySeatId))
	local headMe = me:getUserHeadView()
	local other = self:findPlayerBySeatId(self:serveSeatToViewSeat(theOtherSeadId))
	local headOther = other:getUserHeadView()
	headMe:setPosition(cc.p(728 + 25, 290 - 25 - 4))
	self.m_sngAnimationLayer:addChild(headMe, kZMax)
	headOther:setPosition(cc.p(20 + 25, 290 - 25 - 4))
	self.m_sngAnimationLayer:addChild(headOther, kZMax)
    
	local meMove = cc.MoveTo:create(1, cc.p(486 + 25, 290 - 25 - 4))
	local otherMove = cc.MoveTo:create(1, cc.p(234 + 25, 290 - 25 - 4))
	local spawMe = cc.Sequence:create(meMove, cc.CallFunc:create(handler(self,self.sngHeadMoveEnd),{headMe}))
	local spawOther = cc.Sequence:create(otherMove, cc.CallFunc:create(handler(self,self.sngHeadMoveEnd),{headOther}))
	headMe:runAction(spawMe)
	headOther:runAction(spawOther)
end

function RoomView:sngKOMoveEnd(node)
	local path = node:getUserObject()
	local sprite = cc.Sprite:create(path)
	sprite:setScale(1.2)
	sprite:setOpacity(200)
	sprite:setPosition(node:getPosition())
	self.m_sngAnimationLayer:addChild(sprite, kZMax)
	
	local temp = cc.Spawn:create(cc.DelayTime:create(0.7), cc.Blink:create(0.7, 2))
	localspawn = cc.Sequence:create(temp,cc.CallFunc:create(handler(self,self.sngKOBlinkEnd),{sprite}))
	sprite:runAction(spawn)
end

function RoomView:sngKOBlinkEnd(node)
	self:sngWinningAnimationEnd()
end

function RoomView:sngWinningAnimationEnd()
	local view = require("app.Component.EAlertView"):alertView(self,self,"", self.m_sngMineRanking == 1 and lang_SNGPK_WIN or lang_SNGPK_LOSE,
	 lang_ROOMVIEW_BACKTOMAINVIEW, lang_ROOMVIEW_GOONPLAY)
	view:setTag(115)
	view:show()
	view:enableColseButton(false)
end

function RoomView:sngHeadMoveEnd(node)
	local sprite = node:getChildByTag(1)
	sprite:setScale(0.9)
	sprite:setVisible(true)
	local spawn = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.1, 1.1),cc.ScaleTo:create(0.2, 1, 1))
	sprite:runAction(spawn)
end

function RoomView:removeNodeFromRoom(node)
	if pNode then
		pNode:getParent():removeChild(pNode, true)
	end
end

function RoomView:setPlayerClickable(seatNo, isClickable)
	local player = self:findPlayerBySeatId(seatNo)
	if player then
		player:setClickable(isClickable)
	end
end

--[[其他]]
--------------------------------------------------
function RoomView:showAutoBuyin(buyNum)
	if buyNum > 0 then
		if self.m_tipsInfoHint then
			self.m_tipsInfoHint:addBubble(Lang_AUTO_BUYIN, true)
		end
	end
end

--[[牌桌推送]]
function RoomView:showPushMessage(showType, msg)
	if showType == 2 then   --[[手数]]
		if self.m_taskButton then
			self.m_taskButton:swtichToStatus(eBlinkStatus)
		end
	elseif showType == 3 then --[[HappyHour活动]]
		if self.m_happyHourButton then
			self.m_happyHourButton:swtichToStatus(eBlinkStatus)
		end
	elseif showType == 1 then --[[全局通知]]
		if TRUNK_VERSION == DEBAO_TRUNK then 
			if self.m_tipsInfoHint and msg and string.len(msg)>0 then
				self.m_tipsInfoHint:addBubble(msg,true)
			end
		else
			if self.m_tipsInfoHint and msg and string.len(msg)>0 then
				self.m_tipsInfoHint:addBubble(msg,true)
			end
		end
			
	end
end

--[[大小盲新手提示]]
function RoomView:showNewerBlindHint(seatNo, isBigBlind)
	--[[服务器返回座位对应的界面座位]]
	local seatId = self:serveSeatToViewSeat(seatNo)
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		if isBigBlind then
			player:bigBlind()
		else
			player:smallBlind()
		end
	end
end

--[[提示领取任务奖励]]
function RoomView:showTaskHappyHourInfo(taskConfig, happyHourConfig)
	--任务
	if(self.m_taskButton and taskConfig == 2) then
		self.m_taskButton:swtichToStatus(eBlinkStatus)
	end
    
	--活动
	if(self.m_happyHourButton and happyHourConfig == 2) then
		self.m_happyHourButton:swtichToStatus(eBlinkStatus)
	end
end

function RoomView:changeFirstRechargeButtonStatus(status)
	if self.m_Menubar == nil then

		return
	end
	local menuItemList = {}
	if self.m_buyButton then
		menuItemList[#menuItemList+1] = self.m_buyButton
	end
	if self.m_quickRechargeButton then
		menuItemList[#menuItemList+1] = self.m_quickRechargeButton
	end
	if self.m_settingButton then
		menuItemList[#menuItemList+1] = self.m_settingButton
	end
	if self.m_newTipButton then
		menuItemList[#menuItemList+1] = self.m_newTipButton
	end
	if self.m_happyHourButton then
		menuItemList[#menuItemList+1] = self.m_happyHourButton
	end
	if self.m_freeGoldButton then
		menuItemList[#menuItemList+1] = self.m_freeGoldButton
	end
	if self.m_rebuyButton then
		menuItemList[#menuItemList+1] = self.m_rebuyButton
	end

	if not GIOSCHECK then
		-- if self.m_activityButton then
		-- 	menuItemList[#menuItemList+1] = self.m_activityButton
		-- end

		if(status == 1 or status == 2) then
			if(not self.m_firstRechargeButton) then

				self.m_firstRechargeButton = cc.ui.UIPushButton.new({normal=s_first_recharge_normal,selected=s_first_recharge_select,disabled=s_first_recharge_select})
				self.m_firstRechargeButton:onButtonClicked(handler(self, self.doFirstRechargeAction))
				self.m_firstRechargeButton:setTouchSwallowEnabled(true)
			end		
			menuItemList[#menuItemList+1] = self.m_firstRechargeButton		
		end
	end
    
	if(self.m_Menubar) then
		self.m_Menubar:updateItemList(menuItemList)
	end
end

function RoomView:runFreeGoldLight(node)
    local act1 = cc.FadeOut:create(0.6)
    local act2 = cc.FadeIn:create(0.6)
    local seq  = cc.Sequence:create(act1,act2)

    node:runAction(cc.RepeatForever:create(seq))
end

function RoomView:updateUserSngInfo(seatId, winTimes)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:updateUserSngPKInfo(winTimes)
	end
end

--[[更新用户显示信息]]
function RoomView:updateUserShowInfo(seatId, imageURL, userName)
	--[[服务器返回座位对应的界面座位]]
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:updateShowInfo(imageURL,userName)
	end
end

--[[更新VIP信息]]
function RoomView:updateUserVipLevel(seatId, userid, viplevel)
	--[[服务器返回座位对应的界面座位]]
    seatId = self:serveSeatToViewSeat(seatId)
    
    local player = self:findPlayerBySeatId(seatId)
    if player then
        player:updateVipLevel(userid,viplevel)
    end
end

--[[牌手分变化]]
function RoomView:updateUserCardHandPoint(seatId, point)
	seatId = self:serveSeatToViewSeat(seatId)
    
	local player = self:findPlayerBySeatId(seatId)
	if player then
		player:cardHandPointChange(point)
	end
end

function RoomView:sngPkOutMessage()
end

function RoomView:setGuideConfig(needActionGuide, needGuideHint)
	self.m_needActionGuide = needActionGuide
	self.m_needGuideHint = needGuideHint
end

function RoomView:updateBuyInfo(buyTableInfo)
	self.m_buyTableInfo = buyTableInfo
	-- dump(self.m_buyTableInfo)
end

function RoomView:showPrivateRoomContent(isShow, isOwner, destroyTime)
	self.destroyTime = destroyTime
	self.m_isPrivateRoom = isShow
    self:setTalkButtonVisible(isShow)
	if isShow then
		self:showFirstUseTalk()
		self.m_btnBill:setVisible(true)
		self.timeLabel:setTimestamp(EStringTime:getTimeStampFromNow(self.destroyTime))
		self.m_tTimeRemainLabel:setVisible(true)
	end
	if isOwner then
		self.m_btnMessage:setVisible(true) 
	end
	-- if self.payType == "POINT" then
		self:initOperateDelayMenu()
	-- end
end

--[[payType:"GOLD"(金币)、"POINT"(德堡钻)]]
function RoomView:setPayType(payType)
	self.payType = payType
end

function RoomView:showSngContent()
	self.m_isPrivateRoom = true
	self.m_btnBill:setVisible(false)
	self.m_tTimeRemainLabel:setVisible(false)
	self.m_btnMessage:setVisible(false) 
    self:setTalkButtonVisible(true)
end

function RoomView:showFinalStatics()
    CMOpen(require("app.GUI.dialogs.FinalStaticsDialog"), self, {m_tableId = self.m_tableId}, true, kZMax+1)
end

function RoomView:showBuyinWaitHint()
	CMShowTip("买入筹码需房主审核，请耐心等待回复")
end

function RoomView:showTableConfigId(configId)
	local tableName = self.tableName
	local sBlind = StringFormat:FormatDecimals(self.smallBlind)
	local bBlind = StringFormat:FormatDecimals(self.bigBlind)
	local infoStr=tableName.."(牌桌ID:"..configId..")"
	infoStr = infoStr.." "
	infoStr = infoStr..sBlind
	infoStr = infoStr.."/"
	infoStr = infoStr..bBlind
	self.m_infoLabel:setString(infoStr)
end

function RoomView:updateCallBack(data)
    if data.tag == "addApplyBuy" then
        myInfo.data.showApplyBuy = true
        self.m_btnMessage:addRedDot()
    elseif data.tag == "removeApplyBuy" then
        myInfo.data.showApplyBuy = false
        self.m_btnMessage:removeRedDot()
    elseif data.tag == "showTalkIcon" then
    	self:showTalkMsg_Callback(data.userId,data.duration)
    end
end

function RoomView:hideOperateBoard()
    if self.m_operateBoard then
		self.m_operateBoard:hideOperateBoard()
	end
end

---
-- 添加数据监听汇总处理
--
function RoomView:bindDataObservers()
    self.m_signalHandle = GV.CMDataProxy:addDataObserver(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, handler(self, self.onSignalStrengthChange))
end

---
-- 删除数据监听汇总处理
--
function RoomView:unBindDataObservers()
    GV.CMDataProxy:removeDataObserver(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, self.m_signalHandle)
end

---
-- 退出时清理资源
--
function RoomView:unBindDataObservers()
    self:unBindDataObservers()
end

return RoomView