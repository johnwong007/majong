local myInfo = require("app.Model.Login.MyInfo")
require("app.GUI.GameSceneManager")
require("app.Logic.UserConfig")
require("app.Tools.EStringTime")
require("app.Tools.StringFormat")
require("app.GUI.roomView.RoomViewDefine")

eTourneyStateUnkown = 0
eTourneyStateSignUp = 1
eTourneyStateSigned = 2
eTourneyStateFull = 3
eTourneyStateJoin = 4
eTourneyStatePlaying = 5
eTourneyStateDelay = 6

eTourneyTableViewTag = 111
eSngTableViewTag = 222

local TourneyExInfo = {

	index = 0,
	isSaved = 0,
	chimpionName = "",
	chimpionImage = "",

	imagePath = "",
	state = 0,
	tableId = "",
}

eTourneyBulletUnkow = 0
eTourneyBulletShow = 1
eTourneyBulletHide = 2

eMatchListRecommend = 0
eMatchListGold = 1
eMatchListRakepoint = 2
eMatchListCalls = 3

AlertApplyResult=1
AlertNewerProtect=2
AlertApplyMatch=3
AlertNetworkError=4
AlertApplyResultToStore=5
AlertApplyResultToQuickStart=6
AlertApplyToSng=7
AlertQuitMatch=8
AlertQuitTourney=9

local kCellHeight = 70

local kCountDownNextStart = 213
local kRefreshViewData = 214

local kMenuActionType = {"signUpSng", "joinSng"}

local FREE_MATCH_APPLY_DIALOG_TAG = 1001
local TOURNEY_MATCH_LAYER_TAG = 1002
local TOURNEY_APPLY_MATCH_LAYER_TAG = 1003

-- cell
eTagTicketName = 10
eTagTicketNum = 100
eTagTicketButton = 200
eTagTicketHeadImage = 300
eTagTicketSurroundImage = 400
eTagTicketImage = 500
eTagTicketLabel = 600
eTagTicketBackground = 700

local FONT_NAME = "黑体"
local SNG_CELL_BACKGROUND = "picdata/tourney/cellBackground.png"
local SNG_CELL_HEAD_GOLD = "picdata/public/sta_13_jinbi_android.png"
local SNG_CELL_HEAD_DIAMOND = "picdata/public/sta_3_diamond_android.png"
local SNG_CELL_SNGSTA     = "picdata/tourney/sng_sta_1.png"
local SNG_CELL_SURROUND1   = "picdata/tourney/sng_sta_4_1.png"
local SNG_CELL_SURROUND2   = "picdata/tourney/sng_sta_4_2.png"
local SNG_CELL_SURROUND3   = "picdata/tourney/sng_sta_4_3.png"
local SNG_CELL_SURROUND4   = "picdata/tourney/sng_sta_4_4.png"
local SNG_CELL_SURROUND5   = "picdata/tourney/sng_sta_4_5.png"
local SNG_CELL_SURROUND6   = "picdata/tourney/sng_sta_4_6.png"
local SNG_CELL_BUTTON_UP   = "picdata/tourney/sng_btn_3_up.png"
local SNG_CELL_BUTTON_DOWN   = "picdata/tourney/sng_btn_3_down.png"

local TourneyList = class("TourneyList", function()
		return display.newLayer()
	end)

function TourneyList:scene(matchListType)
	local tourney = TourneyList:new()
	tourney:init(matchListType)
	local pScene = display.newScene()
	tourney:addTo(pScene)
	return pScene
end

function TourneyList:ctor()
	self.m_tourneyMatchLayer = nil
    self.m_applyLayer = nil
	self.m_tableView = nil
	self.m_sngTableView = nil
    self.m_prizeTableView = nil
    
	self.m_matchList = nil
    self.m_recomMatchList = {}
    self.m_goldMatchList = {}
    self.m_rakepointMatchList = {}
    self.m_callsMatchList = {}
    
	self.m_totalInfo = nil
	self.m_userTableList = nil
    
	self.m_bInvoker = false
	--区分锦标赛和SNG赛
	self.m_tableViewType = 0
	self.m_signupIndex = 0
	self.m_pLoadingView = nil
    
	self.eTextAdvert = nil
	self.textAdvertSngPk = nil
    
	self.m_bulletState = nil
    
	self.m_userCoin = nil
    self.m_diamond = nil
    
	self.m_layerTourney = nil
	self.m_layerSngPK = nil
	self.m_layerSngNew = nil--sng赛
    
	self.m_beginTime = ""
	self.m_endTime = ""
	self.m_nextStart = 0
	self.m_timeSpan = 0
	self.m_singUp = false

	self.m_bAwadCoin = {false,false,false}    --3,6,10连胜是否奖励金币
	self.m_awadNum = {"", "", ""}		--奖励 从小到大
    
	self.m_sngPkInfo = nil
	self.m_sngMatchList = nil
    
	self.m_bNeedShowSingup = false
    self.m_tourneyDetail = nil
    self.m_tourneyMatchName = ""
    self.m_tourneyMatchId = ""
    self.m_tourneyTicketId = ""
    self.m_tourneyPayNum = ""
    self.m_tourneyServiceCharge = ""
    self.m_tourneyPayType = ""
    self.m_tourneyTicketFlag = 0
    self.m_tourneyRegStatus = 0
    self.m_tourneyNameColor = nil
--    推荐赛事报名暂存数据
    self.m_recommendMatchName = ""
    self.m_recommendTicketId = ""
    self.m_recommendPayNum = ""
    self.m_recommendServiceCharge = ""
    self.m_recommendPayType = ""

    
    self.goldNum = nil
    self.scoreNum = nil
    
    self.m_serverTime = 0
	self.m_currentType = 0

	self:setNodeEventEnabled(true)
        DBHttpRequest:getAccountInfo(handler(self, self.httpResponse))
end

function TourneyList:onNodeEvent(event)
    if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    end
end

function TourneyList:onEnter()
    TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
end

function TourneyList:onExit()
    TourneyGuideReceiver:sharedInstance():registerCurrentView(nil)
end

function TourneyList:switchTab(matchListType)

    -- self.m_pLoadingView:start()
    
    self.m_currentType = matchListType
    local tagDis1 = nil
    local tagDis2 = nil
    local tagDis3 = nil
    local tagNor = nil
   	local tmpInfo = {}
    
    if (matchListType == eMatchListRecommend) then
        tagDis1 = self.goldMatch
        tagDis2 = self.rakepointMatch
        tagDis3 = self.callsMatch
        tagNor = self.recommendedMatch
        tmpInfo = self.m_recomMatchList
    elseif(matchListType == eMatchListGold) then
        tagDis1 = self.rakepointMatch
        tagDis2 = self.callsMatch
        tagDis3 = self.recommendedMatch
        tagNor = self.goldMatch
        tmpInfo = self.m_goldMatchList
    elseif (matchListType == eMatchListRakepoint) then
        tagDis1 = self.callsMatch
        tagDis2 = self.recommendedMatch
        tagDis3 = self.goldMatch
        tagNor = self.rakepointMatch
        tmpInfo = self.m_rakepointMatchList
    elseif (matchListType == eMatchListCalls) then
        tagDis1 = self.recommendedMatch
        tagDis2 = self.goldMatch
        tagDis3 = self.rakepointMatch
        tagNor = self.callsMatch
        tmpInfo = self.m_callsMatchList
    end

    tagDis1:setTouchEnabled(true)
    tagDis2:setTouchEnabled(true)
    tagDis3:setTouchEnabled(true)
    tagNor:setTouchEnabled(false)
    
    if (self.m_tourneyMatchLayer) then
        self.m_tourneyMatchLayer:getParent():removeChild(self.m_tourneyMatchLayer, true)
    end

        self.m_tourneyMatchLayer = require("app.GUI.Tourney.TourneyMatchSlideLayer"):create(tmpInfo)
        self.m_tourneyMatchLayer:setAnchorPoint(cc.p(0.5,0.5))
        self.m_tourneyMatchLayer:setPosition(cc.p(display.cx,275-120))
        self:addChild(self.m_tourneyMatchLayer,8)

    -- self.m_pLoadingView:stop()

end

function TourneyList:init(matchListType)

	self:manualLoadxml()

    
	-- self.m_pLoadingView = require("app.GUI.BuyLoadingScene"):createLoading()
	-- self:addChild(self.m_pLoadingView,1000)

    -- self.goldNum = cc.ui.UILabel.new({
    -- 	UILabelType = 1,
    -- 	text = StringFormat:FormatDecimals(myInfo:getTotalChips(),2),
    -- 	font = "picdata/MainPage/goldNum.fnt",
    -- 	align = display.LEFT_CENTER, 
    -- 	x = SCREEN_IPHONE5 and 351 or 263,
    -- 	y = 597,
    -- 	})
    -- self.goldNum:addTo(self, 5)

    -- self.scoreNum = cc.ui.UILabel.new({
    -- 	UILabelType = 1,
    -- 	text = StringFormat:FormatDecimals(myInfo.data.diamondBalance,2),
    -- 	font = "picdata/MainPage/scorenum.fnt",
    -- 	align = display.LEFT_CENTER, 
    -- 	x = SCREEN_IPHONE5 and 651 or 563,
    -- 	y = 597,
    -- 	})
    -- self.scoreNum:addTo(self, 5)


    local toolBarTop = require("app.Component.ToolBarTop"):new()
    self:addChild(toolBarTop, 2)
    toolBarTop:setPosition(CONFIG_SCREEN_WIDTH/2,display.height - 50)
    self.m_goldNum = toolBarTop.m_goldNum
    self.m_scoreNum = toolBarTop.m_scoreNum
    
    -- local tempChar = "picdata/public/level/lv"..myInfo.data.userLevel..".png"
    
    -- local infoButton = cc.MenuItemSprite:create(
    --                                                   cc.Sprite:create(tempChar),
    --                                                   cc.Sprite:create(tempChar),
    --                                                   cc.Sprite:create(tempChar))
    -- infoButton:registerScriptTapHandler(handler(self,self.userLevelClick))
    -- infoButton:setAnchorPoint(cc.p(0,0))
    -- infoButton:setPosition(cc.p(0,0))
    -- infoButton:setEnabled(true)
    -- local infoMenu = cc.Menu:create(infoButton)
    -- infoMenu:setPosition(cc.p(97,590))
    -- infoMenu:setAnchorPoint(cc.p(0,0))
    -- self.headerLayer:addChild(infoMenu,4,0)

    
    -- local nextLevel=(myInfo.data.userExp)/100		--计算下一级的经验值
    -- local scale=0.0
    
    -- for i=15,23 do
    --     if (nextLevel<i) then
    --         scale=myInfo.data.userExp/(i*100)
    --         break
    --     end
    -- end
    
    -- print("nextLevel ["..nextLevel.."]  scale ["..scale.."]")
    -- print(" === myInfo->userExp  ["..myInfo.data.userExp.."]")
    
    -- self.progress:setScaleX(scale)

    DBHttpRequest:getMatchListByGroup(handler(self,self.httpResponse),"TOURNEY","0","0","","ASC",1)

    return true
end

function TourneyList:manualLoadxml()

	---------------------------------------------
	self.BackLayer = display.newNode()
	self.BackLayer:addTo(self, 2)

        local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/tourney_dif/tourneyBG.png")
	local bg = cc.ui.UIImage.new(tmpFilename)
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self.BackLayer)
        CMDealAdapter(bg)
	---------------------------------------------
	self.headerLayer = display.newNode()
	self.headerLayer:addTo(self, 3)

	self.backToMainpage = cc.ui.UIPushButton.new({normal="back.png",pressed="back.png",disabled="back.png"})
	self.backToMainpage:align(display.CENTER, 30, 595)
		:onButtonClicked(function()
				self:button_click(99)
			end)
		:addTo(self.headerLayer, 2)

	-- cc.ui.UIImage.new("top_1_bg.png")
	-- 	:align(display.CENTER, 480, 595)
	-- 	:addTo(self.headerLayer, 2)
	-- cc.ui.UIImage.new("top_3_icon_coin.png")
	-- 	:align(display.LEFT_CENTER, 195, 595)
	-- 	:addTo(self.headerLayer, 2)

	-- self.exchangegold = cc.ui.UIPushButton.new({normal="top_3_btn_add.png",pressed="top_3_btn_add2.png",disabled="top_3_btn_add2.png"})
	-- self.exchangegold:align(display.LEFT_CENTER, 432, 595)
	-- 	:onButtonClicked(function()
	-- 			self:button_click(201)
	-- 		end)
	-- 	:addTo(self.headerLayer, 7)

	-- cc.ui.UIImage.new("top_4_icon_integral.png")
	-- 	:align(display.LEFT_CENTER, 493, 595)
	-- 	:addTo(self.headerLayer, 2)

	-- self.exchangescore = cc.ui.UIPushButton.new({normal="top_4_btn_gift.png",pressed="top_4_btn_gift2.png",disabled="top_4_btn_gift2.png"})
	-- self.exchangescore:align(display.LEFT_CENTER, 710, 595)
	-- 	:onButtonClicked(function()
	-- 			self:button_click(202)
	-- 		end)
	-- 	:addTo(self.headerLayer, 7)

	---------------------------------------------
	self.sliderLayer = display.newNode()
	self.sliderLayer:addTo(self, 3)
	self.sliderLayer:setVisible(false)

	self.sliderBg = cc.ui.UIImage.new("touneySlider.png")
	self.sliderBg:align(display.LEFT_CENTER, 188, 510)
		:addTo(self.sliderLayer, 2)

	self.recommendedMatch = cc.ui.UIPushButton.new({normal="recommendedUnSe.png", pressed={"sliderBtn.png", "recommendedSe.png"},
		disabled={"sliderBtn.png", "recommendedSe.png"}})
	self.recommendedMatch:align(display.CENTER, 265, 510)
		:onButtonClicked(function(event)
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.recommendedMatch
                self.recommendedMatch:setButtonEnabled(false)
				self:button_click(101)
			end)
		:addTo(self.sliderLayer, 7)
    self.m_currentButton = self.recommendedMatch
    self.recommendedMatch:setButtonEnabled(false)

	self.goldMatch = cc.ui.UIPushButton.new({normal="goldUnSe.png", pressed={"sliderBtn.png", "goldSe.png"},
		disabled={"sliderBtn.png", "goldSe.png"}})
	self.goldMatch:align(display.CENTER, 413, 510)
		:onButtonClicked(function()
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.goldMatch
                self.goldMatch:setButtonEnabled(false)
				self:button_click(102)
			end)
		:addTo(self.sliderLayer, 7)

	self.rakepointMatch = cc.ui.UIPushButton.new({normal="rakepointUnSe.png", pressed={"sliderBtn.png", "rakepointSe.png"},
		disabled={"sliderBtn.png", "rakepointSe.png"}})
	self.rakepointMatch:align(display.CENTER, 561, 510)
		:onButtonClicked(function()
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.rakepointMatch
                self.rakepointMatch:setButtonEnabled(false)
				self:button_click(103)
			end)
		:addTo(self.sliderLayer, 7)

	self.callsMatch = cc.ui.UIPushButton.new({normal="callsUnSe.png", pressed={"sliderBtn.png", "callsSe.png"},
		disabled={"sliderBtn.png", "callsSe.png"}})
	self.callsMatch:align(display.CENTER, 709, 510)
		:onButtonClicked(function()
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.callsMatch
                self.callsMatch:setButtonEnabled(false)
				self:button_click(104)
			end)
		:addTo(self.sliderLayer, 7)
                if  GIOSCHECK then

        --[[隐藏话费赛]]
            -- dump("隐藏话费赛")
            self.callsMatch:setVisible(false)
        end
        -- dump("隐藏话费赛")
	self.signedMatchBg = cc.ui.UIImage.new("recentBtn2.png")
	self.signedMatchBg:align(display.CENTER, 865, 510)
		:addTo(self.sliderLayer, 7)

	self.signedMatch = cc.ui.UIPushButton.new({normal="signedBtn.png", pressed="signedBtn.png",
		disabled="signedBtn.png"})
	self.signedMatch:align(display.CENTER, 865, 510)
		:onButtonClicked(function()
				self:button_click(105)
			end)
		:addTo(self.sliderLayer, 7)

end

function TourneyList:showApplyMatch()
    local numLabel = self.signedNum
    numLabel:setString("0")
    numLabel:setColor(cc.c3b(255,255,255))
    local signedLayer = self.matchSigned
    signedLayer:setVisible(true)
    local alreadySigned = self.alreadySigned
    alreadySigned:setVisible(false)
    
    DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))

    local detailLayer = self.matchDetail
    detailLayer:setVisible(false)
    local menu=self.tourneySigned
    
    menu:setEnabled(false)

end

function TourneyList:applyOrQuitMatch()
    if(self.m_tourneyRegStatus ==0) then
        local _dialog = require("app.GUI.Tourney.TourneyApplyDialog"):create(
                                                                 self.m_tourneyMatchName,
                                                                 self.m_tourneyTicketId,
                                                                 atof(self.m_tourneyPayNum),
                                                                 atof(self.m_tourneyServiceCharge),
                                                                 self,handler(self, self.applyMatchCallback),
                                                                 self.m_tourneyPayType)
        self:addChild(_dialog,kZMax)
    else
        local payType = ""
        
        local str ="是否取消锦标赛报名？"
        local resultStr = str
        local alert = require("app.Component.EAlertView"):alertView(
                                                  self,
                                                  self,
                                                  "温馨提示",
                                                  resultStr,
                                                  "取消",
                                                  "确定",
                                                  nil
                                                  )
        alert.alertType = AlertQuitTourney
        if (alert) then
        
            alert:alertShow()
        end
    end
end

function TourneyList:keyBackClicked()

	GameSceneManager:switchSceneWithType(EGSMainPage)
end

function TourneyList:applyRecommendMatch()
    local _dialog = require("app.GUI.Tourney.TourneyApplyDialog"):create(self.m_recommendMatchName,
                                                             self.m_recommendTicketId,
                                                             self.m_recommendPayNum+0.0,
                                                             self.m_recommendServiceCharge+0.0,
                                                             self,handler(self, self.applyMatchCallback),
                                                             self.m_recommendPayType)
    
    self:addChild(_dialog,kZMax)
end

function TourneyList:button_click(tag)
    if tag==201 then --打开金币充值商城
        
            local mainPage = MainPageView:scene("TourneyGold")
            GameSceneManager:switchSceneWithNode(mainPage)
            
    elseif tag==202 then --打开积分充值
        
            local mainPage = MainPageView:scene("TourneyScore")
            GameSceneManager:switchSceneWithNode(mainPage)
            
    elseif tag==101 then

            self:switchTab(eMatchListRecommend)
    elseif tag==102 then
        
            self:switchTab(eMatchListGold)
    elseif tag==103 then
        
            self:switchTab(eMatchListRakepoint)

    elseif tag==104 then
        
            self:switchTab(eMatchListCalls)
    elseif tag==105 then
        
            local applyLayer = require("app.GUI.Tourney.ApplyMatchLayer"):layer()
            self:addChild(applyLayer,999,TOURNEY_APPLY_MATCH_LAYER_TAG)
    
--            最近场次
    elseif tag==131 then
        
            local layer = TourneyMatchesLayer:scene(self.m_tourneyDetail,self.m_tourneyMatchName,self.m_tourneyNameColor)
            self:addChild(layer,999,TOURNEY_MATCH_LAYER_TAG)
    
--            报名最近
    elseif tag==132 then
            self:applyOrQuitMatch()
    elseif tag==130 then
--            显示已报名赛事
        
            self:showApplyMatch()
    
--            报名推荐赛事
    elseif tag==133 then
        
            self:applyRecommendMatch()
    elseif tag==100 then
		
--			self:switchTab(eMatchListSngNew)
	elseif tag==111 then
            local dialog = SngRuleDialog:create()
            self:addChild(dialog, 1000)
            dialog:show()
            
            
    elseif tag==200 then
		
--			self:switchTab(eMatchListTourney)
	elseif tag==99 then
		
			GameSceneManager:switchSceneWithType(EGSMainPage)
	elseif tag==500 then
		
            
			if (menuItem:getUserObject() == nil) then
			
				if (self.m_sngPkInfo) then
				
					local _dialog = require("app.GUI.Tourney.TourneyApplyDialog"):create(
                                                                             "PK赛",
                                                                             self.m_sngPkInfo.ticketId,
                                                                             self.m_sngPkInfo.serviceCharge,
                                                                             0.0,
                                                                             self,handler(self, self.applySngCallback))
					self:addChild(_dialog,kZMax)
				end
			else
			
				local tableId = menuItem:getUserObject()
				local roomViewManager = RoomViewManager:createRoomViewManager()
				GameSceneManager:switchSceneWithNode(roomViewManager)
				roomViewManager:enterRoomWithTableId(tableId)
			end
    elseif tag==600 then
		
            
			local info = "PK赛比赛时间：全天开放\n比赛期间，定时开赛，报名玩家随机分配两两一桌进行PK，胜者获得单场奖励。每天连胜一定场数即可获得相应的终极大奖。非连胜活动时间获得的连胜不计算在奖励范围内。本赛事最终解释权归德堡所有，刷分一律封号处理。"
			local alert = require("app.Component.EAlertView"):alertView(
                                                      self,
                                                      self,
                                                      "比赛规则",
                                                      info,
                                                      nil
                                                      )
			alert:show()
	elseif tag==301 or tag==302 or tag==303 then 
			local rewardId = menuItem:getUserObject()
			DBHttpRequest:fetchReward(handler(self, self.self), myInfo.data.userId, rewardId)
	end
end
function TourneyList:onEnter()

	self:setKeypadEnabled(true)
    
	TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
	-- ProfitNotification:sharedInstance():registerCurrentView(self, eProViewHallView)
end
function TourneyList:onExit()

	TourneyGuideReceiver:sharedInstance():registerCurrentView(nil)
	-- ProfitNotification:sharedInstance():registerCurrentView(nil, eProViewHallView)
end

function TourneyList:updateTabelView()

	self.m_tableViewType = eTourneyTableViewTag
	if (self.m_matchList.matchInfoList.size() <= 0 ) then
		return
	end
    
end

function TourneyList:tableCellHighlight(table,  cell)

	if (self.m_tableViewType == eTourneyTableViewTag) then
	
		self.m_bInvoker = false
        cell:getChildByTag(TAG_CELL_MASK):setVisible(true)
	end
end
function TourneyList:tableCellUnhighlight(table,  cell)

    if (self.m_tableViewType == eTourneyTableViewTag) then
    
        cell:getChildByTag(TAG_CELL_MASK):setVisible(false)
    end
end

function TourneyList:tableCellTouched(table, cell)

	if (self.m_tableViewType ==eTourneyTableViewTag) then
	
        local numLabel = self.signedNum
        numLabel:setColor(cc.c3b(96,98,102))
        local btnLayer = self.matchButton
        btnLayer:setVisible(false)
        local signedLayer = self.matchSigned
        signedLayer:setVisible(false)
        local detailLayer = self.matchDetail
        detailLayer:setVisible(true)
        local prizeLayer = self.prizeLayer
        prizeLayer:setVisible(false)
        local alreadySigned = self.alreadySigned
        alreadySigned:setVisible(false)
        local menu=self.tourneySigned
        menu:setEnabled(true)
        local matchLayer = self:getChildByTag(TOURNEY_MATCH_LAYER_TAG)
        if (matchLayer) then
            matchLayer:getParent():removeChild(matchLayer, true)
        end
        
        local groupCell = cell
        DBHttpRequest:getMatchDetailByName(self,groupCell.groupInfo.matchName)
        DBHttpRequest:getMatchInfo(self,groupCell.groupInfo.matchId,"")
--        无法反选,在这里获取位置后直接移动遮罩框.
        self.m_tourneyPayNum = groupCell.groupInfo.payNum
        self.m_tourneyServiceCharge = groupCell.groupInfo.serviceCharge
        self.m_tourneyTicketId =groupCell.groupInfo.ticketId
        self.m_tourneyTicketFlag = groupCell.groupInfo.ticketFlag

        self.m_tourneyMatchName = groupCell.groupInfo.matchName
        self.m_tourneyMatchId = groupCell.groupInfo.matchId
        self.m_tourneyNameColor = groupCell.m_name.getColor()
        self.m_tourneyRegStatus = groupCell.groupInfo.regStatus
        self.m_tourneyPayType = groupCell.groupInfo.payType
        local signLabel = self.signLabel
        if (self.m_tourneyRegStatus ==0) then
            signLabel:setString("报名")
        else
            signLabel:setString("退赛")
        end
        
        local nameLabel = self.matchName
        nameLabel:setString(groupCell.groupInfo.matchName)
        nameLabel:setColor(groupCell.m_name:getColor())
        
        local isRebuy = groupCell.groupInfo.isRebuy
        local rebuyLayer = self.isRebuy
        rebuyLayer:setVisible(isRebuy)
        
        local payTypeLabel = self.payType
        local payTypeIcon = self.payTypeIcon 
        local payType = groupCell.groupInfo.payType
        local matchListTypeTmp
        if (payType == "RAKEPOINT") then
            matchListTypeTmp = groupCell.groupInfo.payNum.."积分+"..groupCell.groupInfo.serviceCharge .. "积分"
            payTypeIcon:setTexture(cc.Sprite:create("picdata/tourney/jb_ico_1_jf.png"):getTexture())
        elseif(payType == "GOLD") then
            matchListTypeTmp = groupCell.groupInfo.payNum.."金币+"..groupCell.groupInfo.serviceCharge .. "金币"
            payTypeIcon:setTexture(cc.Sprite:create("picdata/tourney/jb_ico_1_jb.png"):getTexture())
        else
            payTypeIcon:setTexture(cc.Sprite:create("picdata/tourney/jb_ico_1_mp.png"):getTexture())
            matchListTypeTmp = "门票"
        end
        payTypeLabel:setString(matchListTypeTmp)

        local startTime = self.startTime
        startTime:setString(groupCell.groupInfo.preSetStartTime)
        
        local curUnumLabel = self.signedPlayerNum
        local signedNum = groupCell.groupInfo.curUnum .."人"
        curUnumLabel:setString(signedNum)
        
        local delayTimeLabel = self.delayTime
        local delayTime = groupCell.groupInfo.regDelayTime/60 .. "分钟"
        delayTimeLabel:setString(delayTime)
        
        self.m_bInvoker = true
	elseif(self.m_tableViewType == eSngTableViewTag) then
		local regStatus = self.m_sngMatchList.gameMatchInfoList[cell:getIdx()].regStatus+0
		if (regStatus==0) then
			--        报名
			local payType
			if (self.m_sngMatchList.gameMatchInfoList[cell:getIdx()].payType == "GOLD") then
				payType="金币"
			else
				payType="积分"
			end
			
			local str ="报名赛事:"
            ..self.m_sngMatchList.gameMatchInfoList[cell:getIdx()].matchName+"\n"
            .."报名费用:"
            ..ItoA(atoi(self.m_sngMatchList.gameMatchInfoList[cell:getIdx()].payNum))
            ..payType
            .."+服务费"
            ..self.m_sngMatchList.gameMatchInfoList[cell:getIdx()].serviceCharge
            ..payType
			local alert = require("app.Component.EAlertView"):alertView(
                                                      self,
                                                      self,
                                                      "赛事报名",
                                                      str,
                                                      "取消",
                                                      "确定",
                                                      nil
                                                      )
			alert:setTag(cell:getIdx())
			alert.alertType = AlertApplyToSng
			if (alert) then
			
				alert:alertShow()
			end
		else
			--        退赛
			--        报名
			local payType
            
			local str ="是否取消sng赛报名？"
			local resultStr = str
			local alert = require("app.Component.EAlertView"):alertView(
                                                      self,
                                                      self,
                                                      "",
                                                      resultStr,
                                                      "取消",
                                                      "确定",
                                                      nil
                                                      )
			alert:setTag(cell:getIdx())
			alert.alertType = AlertQuitMatch
			if (alert) then
			
				alert:alertShow()
			end
		end
	end
end

function TourneyList:cellSizeForTable(table)

	if (self.m_tableViewType ==eTourneyTableViewTag) then
	
        return cc.size(325, kCellHeight)
	elseif(self.m_tableViewType == eSngTableViewTag) then
		return cc.size(470, 140)
	end
end

function TourneyList:tableCellAtIndex(table, idx)

	if (self.m_tableViewType ==eTourneyTableViewTag) then
	
		if (idx == 4) then
		
			local a =0
			a = a+1
		end
        
		local cell = table:dequeueCell()
		if (not cell) then
		
            cell = TourneyGroupListCell:create()
		end
        cell:updateInfo(self.m_matchList.matchInfoList[idx], self.m_totalInfo[idx])

        return cell
	elseif(self.m_tableViewType == eSngTableViewTag) then

    end
end

function TourneyList:numberOfCellsInTableView(table)

	if (self.m_tableViewType ==eTourneyTableViewTag) then
	
		local count = #self.m_matchList.matchInfoList
        return count
	elseif(self.m_tableViewType == eSngTableViewTag) then
	
		return #self.m_sngMatchList.gameMatchInfoList
    end
end

function TourneyList:onHttpDownloadResponse(event)
    local ok = (event.name == "completed") 
    if ok then 
        local request = event.request  
        local filename = cc.FileUtils:getInstance():getWritablePath()..self.m_filename
        request:saveResponseData(filename) 
    end
end

function TourneyList:refreshViewData()

--	switchTab(eMatchListSngNew)
end

function TourneyList:countDownStartTime()

	self.m_timeSpan = self.m_timeSpan-1
	if (self.m_timeSpan <= 0) then
	
		self:stopActionByTag(kCountDownNextStart)
		return
	end
	local label = self.matchtime
	if (self.m_timeSpan <= 60) then
	
		label:setString("牌桌分配中")
		local menu = self.signupmatch
		menu:setEnabled(false)
		self:stopActionByTag(kCountDownNextStart)
	else
	
		local time = self.m_timeSpan/60
		time = time.."分"..(self.m_timeSpan%60).."秒"
		label:setString(time)
	end
end

function TourneyList:showError_Callback(errorInfo)

	local alert = require("app.Component.EAlertView"):alertView(
                                              self,
                                              self,
                                              Lang_Error_Prompt_Title,
                                              Lang_Error_Desc_Title..errorInfo,
                                              Lang_Button_Cancel,
                                              Lang_Button_Confirm,
                                              nil
                                              )
	alert:alertShow()
end

function TourneyList:updateTableSize()

	if (self.m_tableView) then
	
		self.m_tableView:setViewSize(cc.size(325, 450))
		self.m_tableView:reloadData()
	end
    
end

function TourneyList:httpResponse(event)

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

function TourneyList:onHttpResponse(tag, content, state)

    if tag==POST_COMMAND_ApplyedMatch then
        
            self:dealGetApplyMatch(content)

    elseif tag==POST_COMMAND_GETMATCHINFO then
        
            self:dealGetMatchInfo(content)

    elseif tag==POST_COMMAND_GetMatchDetailByName then
        
            self:dealGetMatchDetails(content)
    elseif tag==POST_COMMAND_GETACCOUNTINFO then
        
            self:dealGetAccountInfo(content)
    elseif tag==POST_COMMAND_GETMATCHLIST then
        
            self:dealTourneyList(content)
    elseif tag==POST_COMMAND_CHAMPIONSHIPLIST then
        
            self:dealTourneyListByGroup(content)
    elseif tag==POST_COMMAND_APPLYMATCH then
        
            self:dealApplyMatch(content)
    elseif tag==POST_COMMAND_GETUSERTABLELIST then
        
            self:dealUserTableList(content)
    elseif tag==POST_COMMAND_GETDEBAOCOIN then
        
            self:dealGetDebaoCoin(content)
    elseif tag==POST_COMMAND_GETBULLETIN then
        
            self:dealGetBulletin(content)
    elseif tag==POST_COMMAND_GETSNGPKMATCHINFO then
        
            self:dealGetSngPkMatchInfo(content)
    elseif tag==POST_COMMAND_GETSERVERTIME then
        
            self:dealGetServerTime(content)
    elseif tag==POST_COMMAND_GETUSERSNGPKINFO then
        
            self:dealGetUserSngPKInfo(content)
    elseif tag==POST_COMMAND_SELECTACTIVITYINFO then
        
            self:dealQueryActivityReward(content)
    elseif tag==POST_COMMAND_APPLYSNGPK then
        
            self:dealApplySngPk(content)
    elseif tag==POST_COMMAND_GETSNGPKBULLETIN then
        
            self:dealGetSngPkBulletin(content)
    elseif tag==POST_COMMAND_TAKEACTIVITYMONEY then
        
            self:dealTakeActivityReward(content)
    elseif tag==POST_COMMAND_GetSngMatch then
        
            self:dealSngList(content)
    elseif tag==POST_COMMAND_ApplySngMatch then
        
            self:dealApplySng(content)
    elseif tag==POST_COMMAND_QUITMATCH then
        
            self:dealQuitSng(content)
    end
end

function TourneyList:dealTakeActivityReward(content)

	local data = RewardRespInfo:new()
	if(data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		local info = "恭喜您获得"
		info = info .. data.description
		local alert = ETooltipView:alertView(
                                                      self,
                                                      "",
                                                      info
                                                      )
		alert:show()
		DBHttpRequest:getAccountInfo(handler(self, self.httpResponse))
		DBHttpRequest:queryActivityReward(handler(self, self.httpResponse), 93)
	else
	
		local alert = EAlertView:alertView(
                                                  self,
                                                  self,
                                                  "",
                                                  "获取奖励失败。",
                                                  "确定",
                                                  nil
                                                  )
		alert:alertShow()
	end
	data = nil
end

function TourneyList:dealGetSngPkBulletin(content)

	local data = GetBulletin:new()
	if( data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
	
		local bulletinStr = data.bulletinStr
		if (bulletinStr~="") then
		
			if (not self.textAdvertSngPkandbulletinStr~="") then
			
				self.textAdvertSngPk = ETextAdvert:alertView(cc.p(0,390),bulletinStr)
				self.m_layerSngPK:addChild(self.textAdvertSngPk,500)
			end
		end
	end
	data = nil
end

function TourneyList:dealApplySngPk(content)

	local code = content+0
	if (code == 0) then
	
		if(not UserDefaultSetting:getInstance():getPKMatchApplyed() and myInfo.data.isNewer) then
		
			local alert = EAlertView:alertView(
                                                      self,
                                                      self,
                                                      "",
                                                      "恭喜您成功报名PK赛，PK赛尚未开始，先去现金桌玩一下吧！",
                                                      "取消",
                                                      "立即开始",
                                                      nil
                                                      )
			alert.alertType = AlertApplyResultToQuickStart
			if (alert) then
			
				alert:alertShow()
			end
			UserDefaultSetting:getInstance():setPKMatchApplyed(true)
		else
		
			local alert = ETooltipView:alertView(
                                                          self,
                                                          "",
                                                          "恭喜您报名成功"
                                                          )
			alert:show()
		end
		DBHttpRequest:getAccountInfo(handler(self, self.httpResponse))

		local menu = self.signupmatch
		menu:setEnabled(false)
		self.signupmatchlabel:setString("已报名")
	elseif (code == -13001) then
	
		local resultStr = "对不起，您当前的余额无法支付本场比赛的报名费。是否立即充值？"
		local alert = EAlertView:alertView(
                                                  self,
                                                  self,
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
	
		local info
		if (code == -3) then
			info = "已报名，请等待比赛开始"
		elseif (code == -5) then
			info = "超过报名人数限制，请等待下一场赛事"
		elseif (code == -11) then
			info = "您有正在进行的比赛"
		else
			info = "报名失败，请重试"
		end
		local alert = EAlertView:alertView(
                                                  self,
                                                  self,
                                                  "",
                                                  info,
                                                  "确定",
                                                  nil
                                                  )
		alert:alertShow()
	end
end

function TourneyList:dealGetApplyMatch(content)
    local data = ApplyMatchData:new()
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
        if (data.matchDetailList and #data.matchDetailList>0) then

        end
    end
    data = nil
end

function TourneyList:dealGetMatchInfo(content)
    local info = MatchInfo:new()
    if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
    
            local data
            local max1 = (info.gainList and #info.gainList > 0) and ( info.gainList[#info.gainList].endRank) or 0
            local size = max1
            if(size <= 0) then
            
                return
            end
            
            
            --取出奖池奖励
            for i=1,#info.gainList do
            
                local node = info.gainList[i]
                for j=node.startRank,node.endRank do
                    data[j].first = j
                    data[j].second = node.gainStr
                end
            end
            --合并相同奖励内容
            local tmp = ""
            local needData = {}
            for i=1,#data do
            
                if #needData>0 then
                
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
                
                    needData[#needData+1] = data[i]
                end
            end
            
            if(tmp ~= "") then
            
                needData[#needData].first = needData[#needData].first .. "-" .. tmp
                tmp = ""
            end
        
        local prizeLayer = self.prizeLayer
        if (self.m_prizeTableView) then
            self.m_prizeTableView:updateTable(needData)
        else
            self.m_prizeTableView = PrizeTableView:scene(needData)
        end
        self.m_prizeTableView:setPosition(cc.p(0, 18))
        prizeLayer:addChild(self.m_prizeTableView)
        prizeLayer:setVisible(true)
    end
    info = nil
end

function TourneyList:dealGetMatchDetails(content)
    local data = TourneyMatchesData:new()
    data.serverTime=self.m_serverTime
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS and data.matchDetailList and #data.matchDetailList>0) then
        self.m_tourneyDetail = data
        local btnLayer = self.signButton
        local lastMatch = self.matchButton
        lastMatch:setVisible(true)
        local signLabel = self.signLabel

        if (data.matchDetailList[1].regStatus ==0) then
            signLabel:setString("报名")
        else
            signLabel:setString("退赛")
        end

    end
end

function TourneyList:dealGetAccountInfo(content)
   local data = require("app.Logic.Datas.Account.AccountInfo"):new()
	if( data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
	
		myInfo:setTotalChips(data.silverBalance+0.0)
        
        self.m_goldNum:setString(StringFormat:FormatDecimals(myInfo:getTotalChips(),2))
        
        --积分
        self.m_scoreNum:setString(StringFormat:FormatDecimals(myInfo.data.diamondBalance,2))
	end
	data = nil
end

function TourneyList:dealTourneyListByGroup(content)
    -- self.m_pLoadingView:stop()

    local data = require("app.Logic.Datas.Lobby.GameMatchGroupData"):new()
    if (data:parseJson(content)==BIZ_PARS_JSON_SUCCESS) then
        local time_index = -1
        local time = EStringTime:create("5432-12-31 21:30:00")
        -- dump(data.matchInfoList)
        -- dump("=========隐藏话费，实物========")
        if GIOSCHECK then
            for i=#data.matchInfoList,1,-1 do
                if string.find(data.matchInfoList[i].tourneyMatchType, "实物") or
                    string.find(data.matchInfoList[i].tourneyMatchType, "话费") or
                    string.find(data.matchInfoList[i].matchName, "门票") then
                    table.remove(data.matchInfoList, i)
                end
            end
        end

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

        for q=1,#data.matchInfoList do
            if (data.matchInfoList[q].tourneyMatchType=="积分") then
                self.m_rakepointMatchList[#self.m_rakepointMatchList+1]=data.matchInfoList[q]
            elseif(data.matchInfoList[q].tourneyMatchType=="金币" or data.matchInfoList[q].tourneyMatchType=="") then
                self.m_goldMatchList[#self.m_goldMatchList+1]=data.matchInfoList[q]
            elseif(data.matchInfoList[q].tourneyMatchType=="话费") then
                self.m_callsMatchList[#self.m_callsMatchList+1]=data.matchInfoList[q]
            end
        end
        -- dump(data.matchInfoList)
        if data.matchInfoList and #data.matchInfoList>0 then
            self.m_recomMatchList = data.matchInfoList
        end
--        self.m_matchList = data
        self.sliderLayer:setVisible(true)

        self:switchTab(eMatchListRecommend)
        self.m_totalInfo = nil
        self.m_totalInfo = {}
        for i=1,#data.matchInfoList do
        
--            string headImage = WEBSERVICEURL
--            string endImage = "_1.3.png"
			local headImage = "http:--cache.debao.com"
			if SERVER_ENVIROMENT == ENVIROMENT_TEST then
            	headImage = "http:--debaocache.boss.com"
			end
            local info = clone(TourneyExInfo)

            info.index = i
            info.chimpionImage = headImage..data.matchInfoList[i].picURL
            info.chimpionName = data.matchInfoList[i].picURL

            info.isSaved = 0
            
        end
    else
        self.m_matchList = nil
		self.m_matchList = {}
    end
    data = nil
end

function TourneyList:dealTourneyList(content)

	-- self.m_pLoadingView:stop()
	local data = GameMatchList:new()
	self.m_matchList = nil
	self.m_matchList = {}
	if( data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
	
		local time_index = -1
		local fristInfo
		local time = EStringTime:create("5432-12-31 21:30:00")--/data->gameMatchInfoList[0].presetStartTime)
		for i=1,#data.gameMatchInfoList do
		
			if (data.gameMatchInfoList[i].matchStatus == "REGISTERING") then
				
			
				local timeB = EStringTime:create(data.gameMatchInfoList[i].presetStartTime)
				if (time:isBiger(timeB)) then
			
					time = nil
					time = timeB
					time_index = i
				else
					timeB = nil
				end
			end
		end
		if (time_index >= 1) then
		
			fristInfo = data.gameMatchInfoList[time_index]
			table.remove(data.gameMatchInfoList,time_index)
		end
		local a = #data.gameMatchInfoList
		for j=1,#data.gameMatchInfoList-1 do
		
			local temp = data.gameMatchInfoList[j].priority
			local index = j
			for k=j,#data.gameMatchInfoList-1 do
			
				if (temp < data.gameMatchInfoList[k+1].priority) then
				
					temp = data.gameMatchInfoList[k+1].priority
					index = k + 1
				end
			end
			local info = data.gameMatchInfoList[index]
            table.remove(data.gameMatchInfoList,index)
            table.insert(data.gameMatchInfoList,j,info)
            
		end
		if (time_index >= 1) then
			 table.insert(data.gameMatchInfoList,1,fristInfo)
		end
        
--		self.m_matchList = data
		----------------------/图片----------------------------------------------------
		self.m_totalInfo = nil
		self.m_totalInfo = {}
		for i=1,#data.gameMatchInfoList do
		
			local gainName = data.gameMatchInfoList[i].gainName
			local headImage = WEBSERVICEURL
			local endImage = "_1.3.png"
            
			local info = clone(TourneyExInfo)
			info.chimpionName = gainName
			info.index = i
			info.chimpionImage = headImage..info.chimpionName..endImage
			--info.chimpionImage = "http:--ww2.sinaimg.cn/bmiddle/7f127a48jw1e0t5cnjnzsj.jpg"
			info.isSaved = 0
            
			local state = eTourneyStateUnkown
			local regStatus = data.gameMatchInfoList[i].regStatus+0
            if(regStatus == 0) then
                state = eTourneyStateSignUp
            else
                state = eTourneyStateSigned
            end
            
			local bFull = data.gameMatchInfoList[i].curUnum+0 >= data.gameMatchInfoList[i].maxUnum+0
            if(bFull) then
                state = eTourneyStateFull
            end
			if (data.gameMatchInfoList[i].matchStatus ~= "REGISTERING") then
			
				if (regStatus == 1 and self.m_userTableList.tableList and #self.m_userTableList.tableList > 0) then
				
					local matchId = data.gameMatchInfoList[i].matchId
					for j=1,#self.m_userTableList.tableList do
					
						local temp = string.sub(self.m_userTableList.tableList[j].usertableId, string.len(self.m_userTableList.tableList[j].usertableId)-
							string.len(matchId)+1)

						if (temp == matchId) then
						
							state = eTourneyStateJoin
							info.tableId = self.m_userTableList.tableList[j].usertableId
							break
						end
					end
				else
                    local startTime = data.gameMatchInfoList[i].presetStartTime
 					local tempTimeString = EStringTime:create(startTime)
  					local tmp_time = {}

					tmp_time.year = tempTimeString.year
					tmp_time.month = tempTimeString.month
					tmp_time.day = tempTimeString.day
					tmp_time.hour = tempTimeString.hour
					tmp_time.minute = tempTimeString.minute
					tmp_time.second = tempTimeString.second
					tmp_time.isdst=false

                    local t = os.time(tmp_time)
                    local timeDif = self.m_serverTime-t
                    tmp_time = nil
                    if (timeDif>0 and timeDif<data.gameMatchInfoList[i].regDelayTime+0)  then
                        state = eTourneyStateDelay
                    else
                    	state = eTourneyStatePlaying
                    end
                end
			end
            

            
			info.state = state
            
			local resPath = cc.FileUtils:getInstance():getWritablePath()
            local filePath = resPath..info.chimpionName..endImage
			local file = io.open(filePath,"r")
            
			if (not file) then
			
				--不存在就下载
				self.m_filename = info.chimpionName
				DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse),info.chimpionImage, info.chimpionName)
			else
			
				io.close(file)
				info.isSaved =1
				--存在就读本地的
				info.imagePath = filePath
			end
			self.m_totalInfo[#self.m_totalInfo+1] = info
		end
	else
		self.m_matchList = nil
		self.m_matchList = {}
	end
	self:updateTabelView()
end

function TourneyList:dealApplyMatch(content)

	local data = ApplyMatch:new()
    
	if( data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
	
		local datas = {}
		local result = data.applyMatchResult
        
		--特殊处理code  作为扩展当服务器返回此值直接取返回信息提示用户
		if (result == -16021) then
		
			local alert = EAlertView:alertView(
                                                      self,
                                                      self,
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
            
            
			if (result==resultTag1) then
			

				local alert = ETooltipView:alertView(
                                                              self,
                                                              "",
                                                              "恭喜您报名成功"
                                                              )
				alert:show()
                
                local signLabel = self.signLabel
                self.m_tourneyRegStatus = 1
                signLabel:setString("退赛")

                DBHttpRequest:getMatchListByGroup(handler(self, self.httpResponse),"TOURNEY","0","0","","ASC",1)
                self:updateTabelView()
			else
			
				local resultStr = "          报名失败"
				if (result==resultTag2) then --(result==-13001)
				
					resultStr = "对不起，您当前的余额无法支付当场比赛的报名费。是否立即充值？"
					local alert = EAlertView:alertView(
                                                              self,
                                                              self,
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
					local alert = EAlertView:alertView(
                                                              self,
                                                              self,
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
						local alert = EAlertView:alertView(
                                                                  self,
                                                                  self,
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

function TourneyList:dealUserTableList(content)

	local data = GetUserTableList:new()
	self.m_userTableList = nil
	self.m_userTableList = {}
	if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_userTableList = data

    end
end
function TourneyList:dealGetDebaoCoin(content)

end

function TourneyList:dealGetBulletin(content)

	local data = GetBulletin:new()
	if( data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
	
		local bulletinStr = data.bulletinStr
		if (bulletinStr~="") then
		
			self.m_bulletState = eTourneyBulletShow
			if (self.m_tableView) then
				self.m_tableView:setViewSize(cc.size(325, 450))
			end
			if (not self.eTextAdvertandbulletinStr~="") then
			
				self.eTextAdvert = ETextAdvert:alertView(cc.p(0,563),bulletinStr, self, handler(self, self.updateTableSize))
				self.m_layerTourney:addChild(self.eTextAdvert,500)
			end
		end
	end
	data = nil
end

function TourneyList:dealGetServerTime(content)

--    进入锦标赛先获取时间,给之后对比
	self.m_serverTime = content+0

end

function TourneyList:dealGetUserSngPKInfo(content)

	local data = GetUserSngPKInfo:new()
	if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		local label = self.wintimes
		local info = "目前已获得："..data.winTimes.."连胜"
		label:setString(info)
        
	end
	data = nil
end

function TourneyList:dealGetSngPkMatchInfo(content)

	local info = GetSngPKMatchInfo:new()
	if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_sngPkInfo = info
		self.m_beginTime = info.activityStartTime
		self.m_endTime = info.activityEndTime
		self.m_nextStart = info.startTime+0.0
		self.m_singUp = info.userStatus == "YES"
        
        
		local tmp = self.signupmatchlabel:getString()
		local bPlaying = tmp == "立即进入"
		local label = nil
		if (self.m_singUp) then
		
			self.signupmatchlabel:setString("已报名")
		end
        
		label = self.curnum
		local curNum = ""..info.curUnum.."人"
		label:setString(curNum)
        
		label = self.beginendtime
		local beginEndTime = "开放时间："..self.m_beginTime.."-"..self.m_endTime
		label:setString(beginEndTime)
        
		label = self.paynum
		local payNum = ""..info.serviceCharge.."金币"
		label:setString(payNum)
        
		label = self.gainnum
		local gainNum = ""..info.awardNum.."金币"
		label:setString(gainNum)
        
		for i=1,#info.gainList do
		
			if (info.gainList[i].rank == 3) then
			
				self.m_bAwadCoin[3] = info.gainList[i].gainType == eSngPkGainCoin
				self:updateMenuLabel("activity3", info.gainList[i].gainInfo)
				self.m_awadNum[1] = info.gainList[i].gainInfo
			elseif (info.gainList[i].rank == 6) then
			
				self.m_bAwadCoin[2] = info.gainList[i].gainType == eSngPkGainCoin
				self:updateMenuLabel("activity2", info.gainList[i].gainInfo)
				self.m_awadNum[2] = info.gainList[i].gainInfo
			elseif (info.gainList[i].rank == 10) then
			
				self.m_bAwadCoin[1] = info.gainList[i].gainType == eSngPkGainCoin
				self:updateMenuLabel("activity1", info.gainList[i].gainInfo)
				self.m_awadNum[3] = info.gainList[i].gainInfo
			end
		end
        
		if(bPlaying) then
		
			self.signupmatchlabel:setString("立即进入")
            
			label = self.curnum
			label:setString("")
            
			label = self.beginendtime
			local beginEndTime = "开放时间：正在进行中"
			label:setString(beginEndTime)
		end
		DBHttpRequest:getServerTime(handler(self, self.httpResponse))
        
		if (self.m_bNeedShowSingup) then
		
			self.m_bNeedShowSingup = false
			local _dialog = TourneyApplyDialog:create(
                                                                     "PK赛",
                                                                     self.m_sngPkInfo.ticketId,
                                                                     self.m_sngPkInfo.serviceCharge,
                                                                     0.0,
                                                                     self,handler(self, self.applySngCallback))
			self:addChild(_dialog,kZMax)
		end
        
	end
end


function TourneyList:tourneyCellCallBack(pSender)

end

-- function TourneyList:updateMenuLabel( menuId, info)

-- 	local temp = menuId
-- 	string label1 = temp + "_1"
-- 	((local)GetCCNodeByID(label1))->setString(info)
    
-- 	string label2 = temp + "_2"
-- 	((local)GetCCNodeByID(label2))->setString(info)
    
-- 	string label3 = temp + "_3"
-- 	((local)GetCCNodeByID(label3))->setString(info)
-- end

-- function TourneyList:applySngCallback(CCObject* pObject)

-- 	TourneyApplyDialog* _dialog = (TourneyApplyDialog*)pObject
-- 	CCDictionary* dict = (CCDictionary*)_dialog->getUserObject()
-- 	CCString *matchListType = (CCString*)dict->valueForKey("matchListType")
-- 	CCString *ticketId = (CCString*)dict->valueForKey("ticketId")
-- 	if(matchListType->compare("ticket") == 0) then
-- 		self.m_httpReceiver->applySngPK(self, true)
-- 	else
-- 		self.m_httpReceiver->applySngPK(self, false)
-- 	end
-- end

-- function TourneyList:applyMatchCallback(CCObject* pObject)

-- 	TourneyApplyDialog* _dialog = (TourneyApplyDialog*)pObject
-- 	CCDictionary* dict = (CCDictionary*)_dialog->getUserObject()
-- 	CCString *matchListType = (CCString*)dict->valueForKey("matchListType")
-- 	CCString *ticketId = (CCString*)dict->valueForKey("ticketId")
-- 	if(matchListType->compare("ticket") == 0) then
--         self.m_httpReceiver->applyMatch(self,self.m_tourneyMatchId,true,true)
-- 	else
--         self.m_httpReceiver->applyMatch(self,self.m_tourneyMatchId,false,true)
-- 	end
-- end

-- function TourneyList:clickButtonAtIndex(EAlertView* alertView, int index)

-- 	if (alertView.alertType == AlertApplyResultToStore) then
	
-- 		if(index == 0) then
		
-- 		else
		
-- 			GameSceneManager:sharedManager():switchScene(EGSShop)
-- 		end
-- 	elseif (alertView.alertType == AlertApplyResultToQuickStart) then
	
-- 		if (index == 1) then
		
-- 			RoomViewManager *roomViewManager = RoomViewManager:createRoomViewManager()
-- 			roomViewManager.m_isFromMainPage = false
-- --			roomViewManager.m_isFromPKMatch = (eMatchListSngNew == self.m_currentType)
-- 			GameSceneManager:sharedManager():switchScene(roomViewManager)
-- 			roomViewManager:quickStart()
-- 		end
-- 	elseif(alertView.alertType == AlertApplyToSng) then
-- 		if (index == 1) then
-- 			int tag = alertView:getTag()
-- 			string payType = self.m_sngMatchList.gameMatchInfoList[tag].payType
-- 			string payNum = self.m_sngMatchList.gameMatchInfoList[tag].payNum
-- 			string playType = self.m_sngMatchList.gameMatchInfoList[tag].tourneyType
-- 			self.m_httpReceiver->applySng(self, payType, payNum, playType, "")
-- 		end
-- 	elseif(alertView.alertType == AlertQuitMatch) then
-- 		if (index == 1) then
-- 			int tag = alertView:getTag()
-- 			string matchId = self.m_sngMatchList.gameMatchInfoList[tag].matchId
-- 			self.m_httpReceiver->quitMatch(self, matchId)
-- 		end
--     elseif (alertView.alertType == AlertQuitTourney) then
--         if (index == 1) then
-- --            string matchId = self.m_tourneyMatchId
--             self.m_httpReceiver->quitMatch(self, self.m_tourneyMatchId)
--         end
--     end
-- end

function TourneyList:dealQueryActivityReward(content)

    local menu3
    local menu6
    local menu10
    if self.activity3 then
        menu3 = self.activity3
        menu3:setEnabled(false)
    end
    if self.activity2 then

        menu6 = self.activity2
        menu6:setEnabled(false)
    end
    if self.activity1 then

        menu10 = self.activity1
        menu10:setEnabled(false)
    end
	
	local data = RewardList:new()
	if(data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
	
		if(data.rewardInfoList and #data.rewardInfoList > 0) then
		
            
			--fetchReward
			for i=1,#data.rewardInfoList do
			
				if (data.rewardInfoList[i].reMark == "3" and data.rewardInfoList[i].isRewarded == "NO") then
				
					menu3:setEnabled(true)
					menu3:setUserObject(data.rewardInfoList[i].rewardId)
				elseif (data.rewardInfoList[i].reMark == "6" and data.rewardInfoList[i].isRewarded == "NO") then
				
					menu6:setEnabled(true)
					menu6:setUserObject(data.rewardInfoList[i].rewardId)
				elseif (data.rewardInfoList[i].reMark == "10" and data.rewardInfoList[i].isRewarded == "NO") then
				
					menu10:setEnabled(true)
					menu10:setUserObject(data.rewardInfoList[i].rewardId)
				end
			end
			DBHttpRequest:getAccountInfo(handler(self, self.httpResponse))
		end
	end
end

--sngTableView相关方法
function TourneyList:dealSngList(content)

end

function TourneyList:updateSngTableView()
	if (self.m_sngMatchList.gameMatchInfoList <= 0 ) then
		return
	end
	self.m_tableViewType = eSngTableViewTag
	if (not self.m_sngTableView) then
	
		self.m_sngTableView = EPRTableView:create(self, cc.size(505, 540), ePRTableTypeNone, -1)
		self.m_sngTableView:setDirection(kCCScrollViewDirectionVertical)
		self.m_sngTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
		self.m_sngTableView:setDelegate(self)
		self.m_sngTableView:setAnchorPoint(cc.p(0,0))
		self.m_sngTableView:setPosition(cc.p( SCREEN_IPHONE5 and 530 or 450, 5))
		self:addChild(self.m_sngTableView,2)
	else
	
		self.m_sngTableView:reloadData()
	end
end


function TourneyList:dealApplySng(content)
	DBHttpRequest:getSngMatch(handler(self, self.httpResponse), 0, "SNG_CRAZY", "REGISTERING", "")
    
	local code = content+0
	if (code == 0) then
	
		if(not UserDefaultSetting:getInstance():getPKMatchApplyed() and myInfo.data.isNewer) then
		
			local alert = EAlertView:alertView(
                                                      self,
                                                      self,
                                                      "赛事报名",
                                                      "恭喜您成功报名SNG赛，PK赛尚未开始，先去现金桌玩一下吧！",
                                                      "取消",
                                                      "立即开始",
                                                      nil
                                                      )
			alert.alertType = AlertApplyResultToQuickStart
			if (alert) then
			
				alert:alertShow()
			end
			UserDefaultSetting:getInstance():setPKMatchApplyed(true)
		else
		
			local alert = ETooltipView:alertView(
                                                          self,
                                                          "赛事报名",
                                                          "恭喜您报名成功"
                                                          )
			alert:show()
		end
		DBHttpRequest:getAccountInfo(handler(self, self.httpResponse))
	elseif (code == -13001) then
	
		local resultStr = "对不起，您当前的余额无法支付本场比赛的报名费。是否立即充值？"
		local alert = EAlertView:alertView(
                                                  self,
                                                  self,
                                                  "",
                                                  resultStr,
                                                  "取消",
                                                  "立即充值",
                                                  nil
                                                  )
		alert.alertType = AlertApplyResultToStore
		if alert then
		
			alert:alertShow()
		end
	else
	
		local info
		if (code == -3) then
			info = "已报名，请等待比赛开始"
		elseif (code == -5) then
			info = "超过报名人数限制，请等待下一场赛事"
		elseif (code == -11) then
			info = "您有正在进行的比赛"
		else
			info = "报名失败，请重试"
		end
		local alert = EAlertView:alertView(
                                                  self,
                                                  self,
                                                  "",
                                                  info,
                                                  "确定",
                                                  nil
                                                  )
		alert:alertShow()
	end
    
end

function TourneyList:dealQuitSng(content)
	local code = content + 0
	if (code > 0) then
		local alert = ETooltipView:alertView(
                                                      self,
                                                      "",
                                                      "成功取消报名!"
                                                      )
		alert:show()
        
	else
		local info = "系统异常"
		if (code==-1)  then
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
		local alert = ETooltipView:alertView(
                                                      self,
                                                      "",
                                                      resultStr
                                                      )
		alert:show()
	end
end


return TourneyList
