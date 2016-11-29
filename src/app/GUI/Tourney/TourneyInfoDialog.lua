local DialogBase = require("app.GUI.roomView.DialogBase")
local GameLayerManager  = require("app.GUI.GameLayerManager")
local TouneyPrizeInfo = {
	startRank,
	endRank,
	prizeCoin,
	gainInfo,
}

infoIntro=1
infoReward=2
infoRecent=3

local kCellHeight = 48
local kCellWidth = 480

local kMenuPics = {"picdata/tourney/recentSign.png", "picdata/tourney/recentSigned.png", 
	"picdata/tourney/recentQuitMatch.png", "picdata/tourney/recentJoinMatch.png",
 	"picdata/tourney/recentOnGaming.png","picdata/tourney/recentDelay.png"}
    
local AlertApplyResult=1
local AlertNewerProtect=2
local AlertApplyMatch=3
local AlertNetworkError=4
local AlertApplyResultToStore=5
local AlertApplyResultToQuickStart=6
local AlertApplyToSng=7
local AlertQuitMatch=8
local AlertQuitTourney=9

local CELL_TAG = 1


local TourneyInfoDialog = class("TourneyInfoDialog", function()
		return DialogBase:new()
	end)

function TourneyInfoDialog:create()
	local dialog = TourneyInfoDialog:new()
	dialog:init()
	return dialog
end

function TourneyInfoDialog:ctor()
	self.tableViewCells = nil
	self.m_pLoadingView = nil
	self.m_tableView = nil
    self.m_recentTableView = nil
	self.m_logic = require("app.Logic.Room.MatchRankLogic"):create(self)
	self.m_matchPrize = {}
    self.m_matchId = ""
    self.m_tourneyDetail = nil
    self.m_matchDetail = {}
    self.clickTag = false
    self.m_tabTag = 0
    self.m_matchName = ""
    self.m_serverTime = 0
    self.m_cellNum = 0

    self:setNodeEventEnabled(true)

    DBHttpRequest:getServerTime(handler(self,self.httpResponse))
end

function TourneyInfoDialog:onNodeEvent(event)
    if event == "onEnter" then
	    self:onEnter()
     elseif event == "onExit" then
		self:onExit()
    end
end

function TourneyInfoDialog:onEnter()
	self:switchTab(infoIntro)
end

function TourneyInfoDialog:onExit()

end

function TourneyInfoDialog:setFather(father)
	self.m_father = father
end

function TourneyInfoDialog:setRequestInfo(matchInfo)

	self.m_logic:getMatchRewardList(matchInfo.matchId, matchInfo.bonusName, matchInfo.gainName, matchInfo.curUnum)
	local temp = self.playernum
	temp:setString(matchInfo.curUnum)
	temp = self.signup
	temp:setString(matchInfo.payNum)
	temp = self.service
	temp:setString(matchInfo.serviceCharge)
end

function TourneyInfoDialog:init()
	--[["layout/tourney/TourneyInfo.xml"]]
    self:manualLoadxml()
    self.m_pLoadingView = require("app.GUI.BuyLoadingScene"):createLoading()
    self:addChild(self.m_pLoadingView,1000)
    self.m_pLoadingView:setVisible(false)
    self.clickTag = false
    return true
end

function TourneyInfoDialog:manualLoadxml()
	self.main_bg = cc.ui.UIImage.new("tourneyInfoBG.png")
		:align(display.CENTER, display.cx, display.cy) 
		:addTo(self)

	local width = 480
	local height = 325
	local node = display.newNode()
	node:addTo(self)
	node:setContentSize(self.main_bg:getContentSize())
	node:setPosition(self.main_bg:getPosition())

	self.backbutton = cc.ui.UIPushButton.new({normal="btn_2_close.png",
		pressed="btn_2_close2.png",disabled="btn_2_close2.png"})
		:align(display.CENTER, 745-width, 565-height)
		:onButtonClicked(function(event)
				self:button_click(111)
			end)
		:addTo(node, 3)

	-------------------------------------------------
	self.sliderLayer = display.newNode()
	self.sliderLayer:addTo(node, 3)
	self.sliderLayer:setPosition(-width, -height)

	self.sliderBg = cc.ui.UIImage.new("infoSlider.png")
		:align(display.CENTER, 485, 500)
		:addTo(self.sliderLayer, 2)

	self.introBtn = cc.ui.UIPushButton.new({normal="intro.png",pressed={"picdata/tourney/infoSliderBtn.png", "intro1.png"},
		disabled={"picdata/tourney/infoSliderBtn.png", "intro1.png"}})
		:align(display.CENTER, 358, 500)
		:onButtonClicked(function(event)
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.introBtn
                self.introBtn:setButtonEnabled(false)
				self:button_click(101)
			end)
		:addTo(self.sliderLayer, 7)

	self.recentBtn = cc.ui.UIPushButton.new({normal="recentMatch.png",pressed={"picdata/tourney/infoSliderBtn.png", "recentMatch1.png"},
		disabled={"picdata/tourney/infoSliderBtn.png", "recentMatch1.png"}})
		:align(display.CENTER, 480, 500)
		:onButtonClicked(function(event)
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.recentBtn
                self.recentBtn:setButtonEnabled(false)
				self:button_click(103)
			end)
		:addTo(self.sliderLayer, 7)

	self.rewardBtn = cc.ui.UIPushButton.new({normal="reward.png",pressed={"picdata/tourney/infoSliderBtn.png", "picdata/tourney/reward1.png"},
		disabled={"picdata/tourney/infoSliderBtn.png", "picdata/tourney/reward1.png"}})
		:align(display.CENTER, 605, 500)
		:onButtonClicked(function(event)
                self.m_currentButton:setButtonEnabled(true)
                self.m_currentButton = self.rewardBtn
                self.rewardBtn:setButtonEnabled(false)
				self:button_click(102)
			end)
		:addTo(self.sliderLayer, 7)
	self.m_currentButton = self.introBtn
	self.m_currentButton:setButtonEnabled(false)

	-------------------------------------------------
	self.introLayer = display.newNode()
	self.introLayer:addTo(node, 3)
	self.introLayer:setPosition(-width, -height)

	local textColor = cc.c3b(152, 186, 255)
	local textSize = 30

	self.matchNameLabel = cc.LabelTTF:create("测试比赛名字", "Arial", textSize)
	self.matchNameLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.matchNameLabel:setAnchorPoint(cc.p(0.5,0.5))
	self.matchNameLabel:setPosition(cc.p(480, 435))
	self.matchNameLabel:setColor(textColor)
	self.introLayer:addChild(self.matchNameLabel, 4)

	textSize = 24
	local feeLabel = cc.LabelTTF:create("报名费用：", "Arial", textSize)
	feeLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	feeLabel:setAnchorPoint(cc.p(0.5,0.5))
	feeLabel:setPosition(cc.p(410, 370))
	feeLabel:setColor(textColor)
	self.introLayer:addChild(feeLabel, 4)

	self.payNumLabel = cc.LabelTTF:create("金币10+3", "Arial", textSize)
	self.payNumLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.payNumLabel:setAnchorPoint(cc.p(0,0.5))
	self.payNumLabel:setPosition(cc.p(484, 370))
	self.payNumLabel:setColor(textColor)
	self.introLayer:addChild(self.payNumLabel, 4)

	local timeLabel = cc.LabelTTF:create("开赛时间：", "Arial", textSize)
	timeLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	timeLabel:setAnchorPoint(cc.p(0.5,0.5))
	timeLabel:setPosition(cc.p(410, 335))
	timeLabel:setColor(textColor)
	self.introLayer:addChild(timeLabel, 4)

	self.startTimeLabel = cc.LabelTTF:create("金币10+3", "Arial", textSize)
	self.startTimeLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.startTimeLabel:setAnchorPoint(cc.p(0,0.5))
	self.startTimeLabel:setPosition(cc.p(484, 335))
	self.startTimeLabel:setColor(textColor)
	self.introLayer:addChild(self.startTimeLabel, 4)

	local playNumLabel = cc.LabelTTF:create("报名人数：", "Arial", textSize)
	playNumLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	playNumLabel:setAnchorPoint(cc.p(0.5,0.5))
	playNumLabel:setPosition(cc.p(410, 300))
	playNumLabel:setColor(textColor)
	self.introLayer:addChild(playNumLabel, 4)

	self.curUnumLabel = cc.LabelTTF:create("金币10+3", "Arial", textSize)
	self.curUnumLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.curUnumLabel:setAnchorPoint(cc.p(0,0.5))
	self.curUnumLabel:setPosition(cc.p(484, 300))
	self.curUnumLabel:setColor(textColor)
	self.introLayer:addChild(self.curUnumLabel, 4)

	local signUpLabel = cc.LabelTTF:create("延时报名：", "Arial", textSize)
	signUpLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	signUpLabel:setAnchorPoint(cc.p(0.5,0.5))
	signUpLabel:setPosition(cc.p(410, 265))
	signUpLabel:setColor(textColor)
	self.introLayer:addChild(signUpLabel, 4)

	self.delayTimeLabel = cc.LabelTTF:create("金币10+3", "Arial", textSize)
	self.delayTimeLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.delayTimeLabel:setAnchorPoint(cc.p(0,0.5))
	self.delayTimeLabel:setPosition(cc.p(484, 265))
	self.delayTimeLabel:setColor(textColor)
	self.introLayer:addChild(self.delayTimeLabel, 4)

	cc.ui.UIImage.new("addonIcon.png")
		:align(display.CENTER, 410, 230)
		:addTo(self.introLayer, 4)

	local addOnLabel = cc.LabelTTF:create("(addon)", "Arial", textSize)
	addOnLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	addOnLabel:setAnchorPoint(cc.p(0.5,0.5))
	addOnLabel:setPosition(cc.p(500, 230))
	addOnLabel:setColor(textColor)
	self.introLayer:addChild(addOnLabel, 4)	

	self.rebuyLayer = display.newNode()
	self.rebuyLayer:addTo(self.introLayer, 3)
	self.rebuyLayer:setVisible(false)

	cc.ui.UIImage.new("rebuyIcon.png")
		:align(display.CENTER, 410, 195)
		:addTo(self.rebuyLayer, 4)
	local rebuyLabel = cc.LabelTTF:create("(rebuy)", "Arial", textSize)
	rebuyLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	rebuyLabel:setAnchorPoint(cc.p(0.5,0.5))
	rebuyLabel:setPosition(cc.p(500, 195))
	rebuyLabel:setColor(textColor)
	self.rebuyLayer:addChild(rebuyLabel, 4)	

	self.signBtn = cc.ui.UIPushButton.new({normal="infoSignBtn.png",
		pressed="infoSignBtn.png",disabled="infoSignBtn.png"})
		:align(display.CENTER, 480, 135)
		-- :onButtonClicked(function(event)
		-- 		self:button_click(104)
		-- 	end)
		:addTo(self.introLayer, 7)

	--------------------------------------------------------------------
	self.rewardLayer = display.newNode()
	self.rewardLayer:addTo(node, 3) 
	self.rewardLayer:setVisible(false)
	self.rewardLayer:setPosition(-width, -height)

	local rewardLabel = cc.LabelTTF:create("排名                       奖励", "Arial", 30)
	rewardLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	rewardLabel:setAnchorPoint(cc.p(0.5,0.5))
	rewardLabel:setPosition(cc.p(480-35, 435))
	rewardLabel:setColor(textColor)
	self.rewardLayer:addChild(rewardLabel, 4)	

	--------------------------------------------------------------------
	self.recentLayer = display.newNode()
	self.recentLayer:addTo(node, 3) 
	self.recentLayer:setVisible(false)
	self.recentLayer:setPosition(-width, -height)

	local recentLabel = cc.LabelTTF:create("开赛时间             已报名人数", "Arial", 30)
	recentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	recentLabel:setAnchorPoint(cc.p(0,0.5))
	recentLabel:setPosition(cc.p(265, 435))
	recentLabel:setColor(textColor)
	self.recentLayer:addChild(recentLabel, 4)	

end

function TourneyInfoDialog:updateMatchRankList(pData)

    
end

function TourneyInfoDialog:clickButtonAtIndex(alertView, index)
    if (alertView:getTag() == 101) then 
        self.clickTag = false
    end
    
    if (alertView.alertType == AlertApplyResultToStore) then
    
        if(index == 0) then
        
        else
			GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self:getParent()) 
			-- self:hide()
        end
        return
    end
    if (index == 1) then 
        if alertView:getTag() == 1 then
            local matchId = alertView:getUserObject()
            DBHttpRequest:applyMatch(handler(self,self.httpResponse), matchId, false, true)
        elseif alertView:getTag() == 2 then
            local matchId = alertView:getUserObject()
            DBHttpRequest:quitMatch(handler(self,self.httpResponse), matchId)
        end
    end
end

function TourneyInfoDialog:updateMatchRewardList(pData)

	if (not pData or #pData <= 0) then
		return
	end

	self.m_matchPrize = pData
    self.m_tabTag = infoReward

	self:initRewardTable()
	
end

function TourneyInfoDialog:cellSizeForTable(table)


    if (self.m_tabTag == infoReward) then 
        return kCellWidth, kCellHeight
    else
        return kCellWidth, kCellHeight+4
    end
end

function TourneyInfoDialog:tableCellAtIndex(index)
    local cell = display.newNode()
    if (self.m_tabTag == infoReward) then 
    	-- cell:setPosition(cc.p(-kCellWidth, -kCellHeight))

        local sprite = cc.Sprite:create("picdata/public/line.png")
        sprite:setAnchorPoint(cc.p(0.5, 0))
        sprite:setScaleX(48)
        sprite:setPosition(cc.p(15,-kCellHeight/2))
        cell:addChild(sprite, 1)
        
        local rank = cc.LabelTTF:create("", "黑体", 26, cc.p(0,0), cc.TEXT_ALIGNMENT_CENTER)
        rank:setColor(cc.c3b(255, 255, 255))
        rank:setAnchorPoint(cc.p(0.5, 0.5))
        rank:setPosition(cc.p(100-kCellWidth/2-20, 0))
        cell:addChild(rank, 5)
        local rankInfo = "第"..self.m_matchPrize[index].first.."名"
        rank:setString(rankInfo)
        
        local prize = cc.LabelTTF:create("", "黑体", 26, cc.p(0,0), cc.TEXT_ALIGNMENT_CENTER)
        prize:setColor(cc.c3b(255, 255, 255))
        prize:setAnchorPoint(cc.p(0.5, 0.5))
        prize:setPosition(cc.p(363-kCellWidth/2-30, 0))
        cell:addChild(prize, 5)
        prize:setString(self.m_matchPrize[index].second)
        -- dump(self.m_matchPrize[index].second)
        return cell
    elseif(self.m_tabTag == infoRecent) then

        local sprite = cc.Sprite:create("picdata/public/line.png")
        sprite:setAnchorPoint(cc.p(0.5, 0))
        sprite:setScaleX(48)
        sprite:setPosition(cc.p(15,-kCellHeight/2))
        cell:addChild(sprite, 1)
        
        local startTime =  cc.LabelTTF:create(self.m_matchDetail[index].startTime, "黑体", 26)
        startTime:setColor(cc.c3b(152, 186, 255))
        startTime:setAnchorPoint(cc.p(0, 0.5))
        startTime:setPosition(cc.p(18-kCellWidth/2, 0))
        cell:addChild(startTime,5)
        
        local curUnum = cc.LabelTTF:create(self.m_matchDetail[index].curUnum, "黑体", 26)
        curUnum:setColor(cc.c3b(152, 186, 255))
        curUnum:setAnchorPoint(cc.p(0, 0.5))
        curUnum:setPosition(cc.p(323-kCellWidth/2, 0))
        cell:addChild(curUnum, 5)
        
        
        local bgButton
        if (self.m_matchDetail[index].regStatus ==0 or self.m_matchDetail[index].regStatus ==3 or self.m_matchDetail[index].regStatus ==5) then 
           bgButton = cc.ui.UIPushButton.new({normal="picdata/tourney/recentBtn1.png",pressed="picdata/tourney/recentBtn1.png",
            	disabled="picdata/tourney/recentBtn1.png"})
           bgButton:onButtonClicked(handler(self, self.cellBtnClicked0))

        else
        	bgButton = cc.ui.UIPushButton.new({normal="picdata/tourney/recentBtn2.png",pressed="picdata/tourney/recentBtn2.png",
            	disabled="picdata/tourney/recentBtn1.png"})
           bgButton:onButtonClicked(handler(self, self.cellBtnClicked1))
        end
        bgButton:align(display.CENTER, 423-kCellWidth/2, 0)
        bgButton:setTag(index)
        cell:addChild(bgButton, 4)

        local btnName = cc.ui.UIImage.new(kMenuPics[self.m_matchDetail[index].regStatus+1])
        btnName:align(display.CENTER, 423-kCellWidth/2, 0)
        cell:addChild(btnName, 4)

        return cell
    end
end

function TourneyInfoDialog:initRewardTable()
	-- if true then return end
	if not self.m_tableView then
		self.m_tableView = cc.ui.UIListView.new{
			viewRect = cc.rect(225,90,480+30,300),
			direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
			:onTouch(handler(self, self.touchListener))
			:addTo(self.rewardLayer, 10)
		-- self.rewardLayer:setVisible(true)
	end

	self:initRewardTableCells()
end

function TourneyInfoDialog:initRecentTable()
	-- if true then return end
	if not self.m_recentTableView then
		self.m_recentTableView = cc.ui.UIListView.new{
			viewRect = cc.rect(225,90,480+30,300),
			direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
			:onTouch(handler(self, self.touchListener))
			:addTo(self.recentLayer, 13)
		-- self.recentLayer:setVisible(true)
	end

	self:initRecentTableCells()
end

function TourneyInfoDialog:initRewardTableCells()
	self.m_tableView:removeAllItems()
	for idx=1,#self.m_matchPrize do
		local item = self.m_tableView:newItem()
		local itemContent = self:tableCellAtIndex(idx)
		-- local itemContent = display.newNode()
		item:addContent(itemContent)
		item:setItemSize(kCellWidth,kCellHeight)
		self.m_tableView:addItem(item)
	end
	self.m_tableView:reload()
end

function TourneyInfoDialog:initRecentTableCells()
	self.m_recentTableView:removeAllItems()
	for idx=1,self.m_cellNum do
		local item = self.m_recentTableView:newItem()
		local itemContent = self:tableCellAtIndex(idx)
		-- local itemContent = display.newNode()
		item:addContent(itemContent)
		item:setItemSize(kCellWidth,kCellHeight+4)
		self.m_recentTableView:addItem(item)
	end
	self.m_recentTableView:reload()
end

function TourneyInfoDialog:touchListener(event)
    local listView = event.listView
    if "began" == event.name then
       
    elseif "clicked" == event.name then
    	if not self:isVisible() then
    		return
    	end
    elseif "moved" == event.name then
       
    elseif "ended" == event.name then
        
    else
        
    end
end

function TourneyInfoDialog:cellBtnClicked0(event)

    local tag = event.target:getTag()
    local matchId = self.m_matchDetail[tag].matchId
            --            报名
    local alert = require("app.Component.EAlertView"):alertView(self,self,
        "温馨提示","是否报名参加这场锦标赛?","取消","确定")
    alert:setTag(1)
    alert:setUserObject(matchId)
    if (alert) then
        alert:alertShow()
    end  
end

function TourneyInfoDialog:cellBtnClicked1(event)

    local tag = event.target:getTag()
    local matchId = self.m_matchDetail[tag].matchId

    local alert = require("app.Component.EAlertView"):alertView(self,self,"温馨提示",
        "是否退赛?","取消","确定")
    alert:setTag(2)
    alert:setUserObject(matchId)
    if (alert) then
        alert:alertShow()
    end
end

function TourneyInfoDialog:onShareWechat()
	local data = {
		title = string.format(lang_WECHATSHARE_TOURNEY_SIGNUP, self.m_matchName or ""),
		content = string.format(lang_WECHATSHARE_TOURNEY_SIGNUP, self.m_matchName or ""),
		nType = 1,
		url = "http://www.debao.com"}
	QManagerPlatform:shareToWeChat(data) 
end

function TourneyInfoDialog:numberOfCellsInTableView(table)
    if (self.m_tabTag == infoReward) then 
        return #self.m_matchPrize
    elseif(self.m_tabTag==infoRecent) then

            return self.m_cellNum

    else
        return 0
    end
end

function TourneyInfoDialog:updateTableView()

    self.m_cellNum = #self.m_matchDetail
    self.m_tabTag=infoRecent
    self:initRecentTable()
    self:updateInfoTabel()
end

function TourneyInfoDialog:updateInfoTabel()
	if (self.m_matchDetail[1].regStatus ==0 or self.m_matchDetail[1].regStatus ==3 or self.m_matchDetail[1].regStatus ==5) then 
        -- 可报名
        self.signBtn:onButtonClicked(handler(self, self.cellBtnClicked0))
	    self.signBtn:setTag(1)
       	return
    else
    	-- 退赛
    	self.signBtn:setButtonImage("normal", "picdata/tourney/recentBtn2.png")
    	self.signBtn:setButtonImage("pressed", "picdata/tourney/recentBtn2.png")
    	self.signBtn:setButtonImage("disabled", "picdata/tourney/recentBtn2.png")
       	self.signBtn:onButtonClicked(handler(self, self.cellBtnClicked1))
       	self.signBtn:setTag(1)
       	local btnName = cc.ui.UIImage.new(kMenuPics[self.m_matchDetail[1].regStatus+1])
	    btnName:align(display.CENTER, 0, 0)
	    self.signBtn:addChild(btnName)
       	local shareBtn = cc.ui.UIPushButton.new({normal="picdata/tourney/recentBtn1.png",pressed="picdata/tourney/recentBtn1.png",
        	disabled="picdata/tourney/recentBtn1.png"})
       	shareBtn:onButtonClicked(handler(self, self.onShareWechat))
       	shareBtn:setButtonLabel(cc.ui.UILabel.new({
		        text = "分享",
		        font = "黑体",
		        size = 22,
		        color = cc.c3b(255,255,255),
	        }))
       	self.introLayer:addChild(shareBtn, 7)
       	self.signBtn:align(display.CENTER, 480-100, 135)
       	shareBtn:align(display.CENTER, 480+100, 135)
    end
end

function TourneyInfoDialog:updateIntroInfo(info)
    local matchName = self.matchNameLabel
    local payNum = self.payNumLabel
    local startTime = self.startTimeLabel
    local curUnum = self.curUnumLabel
    local delayTime = self.delayTimeLabel
    matchName:setString(info.matchName)
    local pays = info.payNum .. "+" .. info.serviceCharge
    if (info.payType == "RAKEPOINT") then 
        pays = pays.."积分"
    else
        pays = pays.."金币"
    end
    
    payNum:setString(pays)
    startTime:setString(info.preSetStartTime)
    curUnum:setString(info.curUnum)
    local dTime = (info.regDelayTime/60).."分钟"
    delayTime:setString(dTime)
    if (info.isRebuy) then 
        self.rebuyLayer:setVisible(true)
    end
    self.m_matchId = info.matchId
    self.m_matchName = info.matchName
end

function TourneyInfoDialog:switchTab(tag)
    self.m_tabTag = tag
    local tagDis
    local tagDis2 
    local tagNor
    if (tag == infoIntro) then 
        tagDis = self.rewardBtn
        tagDis2= self.recentBtn
        tagNor = self.introBtn
        self.recentLayer:setVisible(false)
        self.introLayer:setVisible(true)
        self.rewardLayer:setVisible(false)
    elseif(tag == infoReward) then
        tagDis = self.introBtn
        tagDis2= self.recentBtn
        tagNor = self.rewardBtn
        self.recentLayer:setVisible(false)
        self.introLayer:setVisible(false)
        self.rewardLayer:setVisible(true)
        if (self.m_tableView) then 
            self.m_tableView:setVisible(true)
        end
        if (self.m_recentTableView) then 
            self.m_recentTableView:setVisible(false)
        end
    elseif(tag == infoRecent) then
        self.m_tabTag = infoRecent
        self:initRecentTable()
        tagDis = self.introBtn
        tagDis2= self.rewardBtn
        tagNor = self.recentBtn
        self.introLayer:setVisible(false)
        self.rewardLayer:setVisible(false)
        self.recentLayer:setVisible(true)

        if (self.m_tableView) then 
            self.m_tableView:setVisible(false)
        end
        if (self.m_recentTableView)  then
            self.m_recentTableView:setVisible(true)
        end
    end
    local menu = tagDis
   	menu:setTouchEnabled(true)
    local menu2 = tagDis2
    menu2:setTouchEnabled(true)
    local menu4 = tagNor
    menu4:setTouchEnabled(false)
    

end

function TourneyInfoDialog:httpResponse(event)

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

function TourneyInfoDialog:onHttpResponse(tag, content, state)

    if tag==POST_COMMAND_APPLYMATCH then
        
            self:dealApplyMatch(content)

    elseif tag==POST_COMMAND_GetMatchDetailByName then
        
            self:dealGetMatchDetails(content)

    elseif tag==POST_COMMAND_GETSERVERTIME then
        
            self:dealGetServerTime(content)

    elseif tag==POST_COMMAND_QUITMATCH then
        
            self:dealQuitMatch(content)

    end
end

function TourneyInfoDialog:dealQuitMatch(content)
    local code = content+0
    if (code > 0) then
    
        local alert = require("app.Component.ETooltipView"):alertView(
                                                      self:getParent(),
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
        local resultStr= "取消赛事失败,原因:"+info
        local alert = require("app.Component.ETooltipView"):alertView(
                                                      self:getParent(),
                                                      "",
                                                      resultStr
                                                      )
        alert:show()
    end
end


function TourneyInfoDialog:dealGetServerTime(content)
    --    进入锦标赛先获取时间,给之后对比
    self.m_serverTime = content+0
--    CCLog("`````````%s",self.m_matchName)
    DBHttpRequest:getMatchDetailByName(handler(self,self.httpResponse),self.m_matchName)
end

function TourneyInfoDialog:dealGetMatchDetails(content)

    local data = require("app.Logic.Datas.Lobby.TourneyMatchesData"):new()
    data.serverTime=self.m_serverTime
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS )  then
--        self.m_tourneyDetail = data
        self.m_matchDetail = nil
        self.m_matchDetail = data.matchDetailList
    end
    self:updateTableView()
    data = nil
end

function TourneyInfoDialog:dealApplyMatch(content)

    local data = require("app.Logic.Datas.Lobby.ApplyMatch"):new()
    self.m_pLoadingView:stop()
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
        local datas = {}
        local result = data.applyMatchResult
        
        --特殊处理code  作为扩展当服务器返回此值直接取返回信息提示用户
        if (result == -16021) then
        
            local alert = require("app.Component.EAlertView"):alertView(
                                                      self:getParent(),
                                                      self,
                                                      "",
                                                      data.errorStr,
                                                      "确定",
                                                      nil
                                                      )
            alert:setTag(101)
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
            
                
                local alert = require("app.Component.ETooltipView"):alertView(
                                                              self:getParent(),
                                                              "",
                                                              "恭喜您报名成功"
                                                              )
                alert:setTag(101)
                alert:show()
                
              
            else
            
                local resultStr = "          报名失败"
                if (result==resultTag2) then --(result==-13001)
                
                    resultStr = "对不起，您当前的余额无法支付当场比赛的报名费。是否立即充值？"
                    local alert = require("app.Component.EAlertView"):alertView(
                                                              self:getParent(),
                                                              self,
                                                              "",
                                                              resultStr,
                                                              "取消",
                                                              "立即充值",
                                                              nil
                                                              )
                    alert.alertType = AlertApplyResultToStore
                    if (alert) then
                    
                        alert:setTag(101)
                        alert:alertShow()
                    end
                elseif (result==resultTag3) then --(result==-5)
                
                    resultStr = "对不起，您不是付费用户，不能报名该场锦标赛。是否立即充值？"
                    local alert = require("app.Component.EAlertView"):alertView(
                                                              self:getParent(),
                                                              self,
                                                              "",
                                                              resultStr,
                                                              "取消",
                                                              "立即充值",
                                                              nil
                                                              )
                    alert.alertType = AlertApplyResultToStore
                    if (alert) then
                    
                        alert:setTag(101)
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
                        local alert = require("app.Component.EAlertView"):alertView(self:getParent(),
                            self,"",resultStr,"确定",nil)
                        alert.alertType = AlertApplyResult
                        if (alert) then
                        
                            alert:setTag(101)
                            alert:alertShow()
                        end
                    end
                end
            end
        end
    end
    
    self.clickTag = false

    data = nil
end

function TourneyInfoDialog:button_click(tag)
    if (self.clickTag) then
        return
    end

	if tag==111 then
		self.m_father.m_infoDialogHasShown = false
        self:remove()
    elseif tag==101 then
        self:switchTab(infoIntro)
    elseif tag==102 then
        self:switchTab(infoReward)
    elseif tag==103 then
        self:switchTab(infoRecent)
    elseif tag==104 then
        self.clickTag = true
        self.m_pLoadingView:start()
        DBHttpRequest:applyMatch(handler(self,self.httpResponse),self.m_matchId,true,true)
    end
	
end




return TourneyInfoDialog