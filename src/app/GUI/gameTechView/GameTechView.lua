local firstLayer = 0
local secondLayer = 1
local thirdLayer = 2

local gameTechText = {
	["step1"] = "欢迎来到德堡扑克！我们先来学习一下德州扑克的基本规则吧!",
	["step2"] = "游戏开始时每人都会发两张手牌（仅自己可见）",
	["step3"] = "桌面上会分三轮陆续发出五张公共牌（所有玩家可见）",
	["step4"] = "牌型大小如左图所示。您的牌型就是[底牌]+[公共牌]的任意五张组合的最大牌型。您现在的牌型就是葫芦（三条带一对）。",
	["step5"] = "下面我们模拟来玩一局牌吧！",
	["step6"] = "每人发两张牌，您的位置为庄家位，您的上家在大盲注位下注2",
	["step7"] = "现在轮到您操作，跟注是不错的选择。",
	["step7_2"] = "小堡选择了跟注1。",
	["step8"] = "小德选择了看牌，三张公共牌翻出。现在您的牌型是？请选择\n答对获得500金币奖励",
	["step9"] = "小堡选择了看牌。",
	["step10"] = "小德选择了看牌。",
	["step11"] = "您现在的牌力不错，可以选择看牌！",
	["step12"] = "第四张公共牌发了，您的牌型又发生了变化，您现在的牌型是?",
	["step13"] = "小堡选择了加注2，看来她的牌不错哦！",
	["step14"] = "小德选择了“弃牌”，已下的2个筹码不能回收。",
	["step15"] = "小堡可能想试探下你，你的牌型比较大，可以跟注。",
	["step16"] = "最后一张河牌翻出，您的牌型又发生了变化，您现在的牌型是?",
	["step17"] = "小堡选择了全下！",
	["step18"] = "你的牌型为葫芦，有很大的胜算哦！可以选择全下,赢光对手所有筹码",
	["step19"] = "你的葫芦比她的顺子大，恭喜你获得桌上所有的筹码！",
	["step20"] = "你的葫芦比她的顺子大，恭喜你获得桌上所有的筹码！",
}

local RoomView = require("app.GUI.RoomView")

local GameTechView = class("GameTechView", function()
	return RoomView:new()
end)

function GameTechView:create(tableId, seatNum, fromWhere)
	local view = GameTechView:new()
	view.m_fromWhere = fromWhere
	view:initGameTechView("", 9)
	RoomView.setRoomManager(view, nil)
	return view
end

function GameTechView:ctor()
    self.m_allowNext = false
	self.m_currentStep = 0
	self.m_totalStep = 0
	self.m_isClicked = false
	self.m_myName = ""
	self.m_momoName = ""
	self.m_deName = ""
	self.m_rewardMsg = ""
	self.m_fromWhere = 0
	self.m_headUrl = ""
	self.m_maleSex = ""
	self.m_felalSex = ""
    self.m_activeArgs = ""
	self.m_pokerTypeClickable = false
    self.m_questionType = nil

	self.m_totalStep = 19
	self.m_currentStep = 1
	self.m_isClicked = false
	self.m_myName = MyInfo.data.userName
	self.m_momoName = "小堡"
	self.m_deName = "小德"
	self.m_headUrl = MyInfo.data.userPotrait
	self.m_felalSex = "女"
	self.m_maleSex = "男"
    self.m_allowNext=false


    self.m_maskLayer = display.newLayer()
    self:addChild(self.m_maskLayer, kZOperateBoard-1)
	-- 允许 node 接受触摸事件
    self.m_maskLayer:setTouchEnabled(true)

	-- 注册触摸事件
	self.m_maskLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    	-- event.x, event.y 是触摸点当前位置
    	-- event.prevX, event.prevY 是触摸点之前的位置
    	-- printf("sprite: %s x,y: %0.2f, %0.2f",
     --       event.name, event.x, event.y)

    	-- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
    	-- 则必须返回 true
    	if event.name == "began" then
        	return self:ccTouchBegan(event)
    	end
	end)
	self:setNodeEventEnabled(true)
end

function GameTechView:onNodeEvent(event)
    if event == "enter" then
    	self:onEnter(event)
    elseif event == "exit" then
    	self:onExit(event)
    end
end

function GameTechView:onEnter()
    
	UserDefaultSetting:getInstance():setIsLearn(true)

	self:enterTechStep(1)
end

function GameTechView:onExit()

end

function GameTechView:ccTouchBegan(event)
	if self.m_allowNext then
        self.m_allowNext = false
        self.m_currentStep = self.m_currentStep+1
        self:enterTechStep(self.m_currentStep)
    end

    if self.m_currentStep>19 then
        local layer = self.endTech
        layer:setPosition(LAYOUT_OFFSET)
       	self.endTech:setVisible(true)
    end
    return true
end

function GameTechView:initGameTechView()

	RoomView.resetRoomView(self,"",9)
	RoomView.initRoomView(self)		--[[初始化房间的资源]]

	self.m_backBtn:setButtonImage("normal", "back.png")
	self.m_backBtn:setButtonImage("pressed", "back1.png")
	self.m_backBtn:setButtonImage("disabled", "back1.png")

	local node = display.newNode()
	self:addChild(node, 10000)

	cc.ui.UIImage.new("infoBg.png")
		:align(display.LEFT_TOP, 395, 635)
		:addTo(node)

	self.game_tech_text = cc.ui.UILabel.new({
		text = "",
		font = "黑体",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		dimensions = cc.size(410, 400)
		})
		:align(display.LEFT_TOP, 435, 620)
		:addTo(node, 1)
		-----------------------
	self.firstQuestion = display.newNode()
	node:addChild(self.firstQuestion, 1) 
	self.firstQuestion:setVisible(false)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 490, 500)
		:addTo(self.firstQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "同花",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1000)
			end)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 640, 500)
		:addTo(self.firstQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "顺子",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1001)
			end)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 790, 500)
		:addTo(self.firstQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "对子",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1002)
			end)
		-----------------------
	self.secondQuestion = display.newNode()
	node:addChild(self.secondQuestion, 1) 
	self.secondQuestion:setVisible(false)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 490, 500)
		:addTo(self.secondQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "同花",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1000)
			end)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 640, 500)
		:addTo(self.secondQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "三条",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1004)
			end)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 790, 500)
		:addTo(self.secondQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "两对",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1005)
			end)
		-----------------------
	self.thirdQuestion = display.newNode()
	node:addChild(self.thirdQuestion, 1) 
	self.thirdQuestion:setVisible(false)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 490, 500)
		:addTo(self.thirdQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "同花顺",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1006)
			end)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 640, 500)
		:addTo(self.thirdQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "葫芦",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1007)
			end)

	cc.ui.UIPushButton.new({normal="grayBtn.png",pressed="grayBtn.png",disabled="grayBtn.png"})
		:align(display.CENTER, 790, 500)
		:addTo(self.thirdQuestion)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			UILabelType = 2,
			text = "两对",
			font = "FZZCHJW--GB1-0",
			size = 24,
			color = cc.c3b(127,127,135)
			}))
		:onButtonClicked(function(event)
				self:button_click(1008)
			end)
		-----------------------
	self.endTech = display.newNode()
	node:addChild(self.endTech, 1) 
	self.endTech:setVisible(false)

	cc.ui.UIImage.new("techBanner.png")
		:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, 430)
		:addTo(self.endTech)

	cc.ui.UIPushButton.new({normal="startGame.png",pressed="startGame1.png",disabled="startGame1.png"})
		:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, 300)
		:addTo(self.endTech)
		:onButtonClicked(function(event)
				self:button_click(1009)
			end)
		-----------------------
	self.getMoneyLayer = display.newNode()
	node:addChild(self.getMoneyLayer, 1) 
	self.getMoneyLayer:setVisible(false)

	cc.ui.UIPushButton.new({normal="getMoney.png",pressed="getMoney.png",disabled="getMoney.png"})
		:align(display.CENTER, 640, 500)
		:addTo(self.getMoneyLayer)
		:onButtonClicked(function(event)
				self:button_click(1003)
			end)
		-----------------------
	for i=0,8 do
		self:setPlayerClickable(i, false)
	end
end

function GameTechView:keyBackClicked()
	if self.m_currentStep == self.m_totalStep then
		self:leaveGameTechView(false)
	end
end

function GameTechView:button_click(tag)
	if tag == 1000 then
        local textView = self.game_tech_text
        local tmp = "自己的手牌和桌面上的牌进行随意组合五张牌同一花色才能组成同花哦"
        textView:setString(tmp)
    elseif tag == 1001 then
        local textView = self.game_tech_text
        local tmp = "自己的手牌和桌面上的牌进行随意组合,五张牌点数相连才能组成顺子哦"
        textView:setString(tmp)
    elseif tag == 1002 then
        local textView = self.game_tech_text
        local tmp = "恭喜你答对了,您的牌型是对子(一对Q)"
        textView:setString(tmp)
        self.m_activeArgs = "1"
        self.firstQuestion:setVisible(false)
        self.getMoneyLayer:setVisible(true)
    elseif tag == 1003 then
        require("app.GUI.roomView.WinAnimation"):runRewardAnimation(self,kZYouWin)
        DBHttpRequest:joinActivity(handler(self, self.httpResponse), "204", self.m_activeArgs)
        self.m_allowNext = true
        self.getMoneyLayer:setVisible(false)
        self.m_maskLayer:setTouchEnabled(true)
    elseif tag == 1004 then
        local textView = self.game_tech_text
        local tmp = "自己的手牌和桌面上的牌进行随意组合,三张牌点数相连才能组成三条哦"
        textView:setString(tmp)
    elseif tag == 1005 then
        local textView = self.game_tech_text
        local tmp = "恭喜你答对了,您的牌型是两队(一对Q,一对J)"
        textView:setString(tmp)
        self.m_activeArgs = "2"
        self.secondQuestion:setVisible(false)
        self.getMoneyLayer:setVisible(true)
    elseif tag == 1006 then
        local textView = self.game_tech_text
        local tmp = "自己的手牌和桌面上的牌进行随意组合,五张牌点数相连且花色相同才能组成同花顺"
        textView:setString(tmp)
    elseif tag == 1007 then
        local textView = self.game_tech_text
        local tmp = "恭喜你答对了,您的牌型是葫芦(三条J,一对Q)"
        textView:setString(tmp)
        self.m_activeArgs = "3"
        self.thirdQuestion:setVisible(false)
        self.getMoneyLayer:setVisible(true)
    elseif tag == 1008 then
        local textView = self.game_tech_text
        local tmp = "自己的手牌和桌面上的牌进行随意组合,有两个对子才能组成两对哦"
        textView:setString(tmp)
    elseif tag == 1009 then
        -- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
        -- roomViewManager.m_isFromMainPage = true
        -- GameSceneManager:switchSceneWithNode(roomViewManager)
        -- roomViewManager:quickStart()
        GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{m_isFromMainPage = true,isQuickStart = true })
    elseif tag == 1010 then
        -- local mainpageScene = require("app.GUI.mainPage.MainPageView"):scene("")
        -- GameSceneManager:switchScene(mainpageScene)
        GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
	end
end

function GameTechView:operateBoardClicked_Callback(pObj)
	self.m_maskLayer:setTouchEnabled(true)
	local pSender = pObj
	local tmpClickType = pSender:getClickType()
	if tmpClickType == 5 then --跟注
        self.m_isClicked = true
        if self.m_currentStep == 15 then
        	self.m_currentStep = self.m_currentStep+1
            self:enterTechStep(self.m_currentStep)
        else
            if self.m_currentStep ==7 then
                self:playerCall_Callback(true,0,2,0,38)
                self:waitForPlayerActioning_Callback(false,4,10,10)
            end
            self:doAfterClickCallButtonDelay()
            self.m_allowNext = true
        end
        self:setOperateSliderMark(false)
    elseif tmpClickType == 2 then --看牌
        self.m_isClicked = true
        self.m_currentStep = self.m_currentStep+1
        self:enterTechStep(self.m_currentStep)
        self:setOperateSliderMark(false)
    elseif tmpClickType == 4 then --全下
        self.m_allowNext = true
        self.m_isClicked = true
        self.m_currentStep = self.m_currentStep+1
        self:enterTechStep(self.m_currentStep)
        self:setOperateSliderMark(false)
	end
    

	local menu = self.next_button
	if menu then
		local menuItem = menu
		menuItem:setButtonEnabled(true)
	end
end

function GameTechView:doPokerType(pObj)

	local pNode = self:getChildByTag(20001)
	if pNode then
		return
	end
    
	local isClickable = (self.m_currentStep >= 5 or (self.m_pokerTypeClickable and self.m_currentStep == 4))
    
	if isClickable or not pObj then
        local cardTips = require("app.GUI.roomView.CardTips"):create(eCashTable)
		self:addChild(cardTips,kZMax,20001)
		cardTips:highLightType(6)
	end
end

function GameTechView:doSettingAction(pObj)

    
end

function GameTechView:doBackToLobby(pObj)

	if self.m_currentStep == self.m_totalStep then
		self:leaveGameTechView(false)
	else
		self:breakTechAlertDialog()
	end
end

function GameTechView:clickButtonAtIndex(alertView, index)

	local tag = alertView:getTag()
	if tag == 102 then--中途退出教学
        if index == 0 then
            --退出教学
            self:leaveGameTechView(false)
        end
    elseif tag == 103 then--完成教学退出
        if index == 1 then
            --立即游戏
            self:leaveGameTechView(true)
        elseif index == 0 then
            --返回
            self:leaveGameTechView(false)
        end
	end
end
--[[http请求返回]]
----------------------------------------------------------
function GameTechView:httpResponse(event)

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

function GameTechView:onHttpResponse(tag, content, state)
	if tag == POST_FINISH_GAME_TECH then
        self:dealFreshGuide(content)
	end
end

function GameTechView:leaveGameTechView(isPlayGame)

	if isPlayGame then
	
		-- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
		-- roomViewManager.m_isFromMainPage = true
		-- GameSceneManager:switchSceneWithNode(roomViewManager)
		-- roomViewManager:quickStart()
		GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{m_isFromMainPage = true,isQuickStart = true })
	else
	
        local mainpageScene = require("app.GUI.mainPage.MainPageView"):new()
        GameSceneManager:switchSceneWithNode(mainpageScene)
		
	end
end

function GameTechView:dealFreshGuide(strJson)

	self.m_rewardMsg = nil
	local data = require("app.Logic.Datas.Activity.FreshGuide"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
	
		self.m_rewardMsg = data.dscription
		if data.tradeType == "GOLD" then
		
			local tmp = data.transMoney+0.0
			if tmp > 0 then
			
				MyInfo:setTotalChips(MyInfo:getTotalChips() + tmp)
			end
		end
	end
	data = nil
	self:finishTechAlertDialog()
end

function GameTechView:breakTechAlertDialog()

	local view = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
        Lang_GAME_TECH_BREAK,"放弃奖金","继续教学")
	view:alertShow()
	view:setTag(102)
end

function GameTechView:finishTechAlertDialog()

	local msg = Lang_TECH_GAME_FINISH
	local view = require("app.Component.EAlertView"):alertView(self,self,"温馨提示",
        msg,Lang_Button_Back,"立即游戏")
	view:alertShow()
	view:setTag(103)
end

function GameTechView:changeNextBackOption()
    self.m_allowNext = true
end


function GameTechView:buttonVisible(isVisile)

end


function GameTechView:changeButtonEnabled()

end

function GameTechView:setOperateSliderMark(isVisble)

end

function GameTechView:changeGameTechText()

	if self.m_currentStep < 1 or self.m_currentStep > self.m_totalStep then	
		return
	end
	local textID = ""
    
    
	if self.m_currentStep == 7 and self.m_isClicked then
		textID = "step7_2"
	else
		textID = "step"..self.m_currentStep
	end
    
	local strText = gameTechText[textID]
    
	local textView = self.game_tech_text
    
    if textView and strText~="" then
        textView:setString(strText)
    end
    
end

function GameTechView:doAfterClickCallButton()
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
		cc.CallFunc:create(handler(self, self.changeGameTechText))))
end

function GameTechView:doAfterClickCallButtonDelay()

	self:buttonVisible(false)

	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.doAfterClickCallButton))))
end

function GameTechView:enterTechStep(step)

	self.m_isClicked = false
	self:buttonVisible(false)
	self:setOperateSliderMark(false)
	
	if step == 1 then
        self:enterStep1()
    elseif step == 2 then
        self:enterStep2()
    elseif step == 3 then
        self:enterStep3()
    elseif step == 4 then
        self:enterStep4()
    elseif step == 5 then
        self:enterStep5()
    elseif step == 6 then
        self:enterStep6()
    elseif step == 7 then
        self:enterStep7()
    elseif step == 8 then
        self:enterStep8()
    elseif step == 9 then
        self:enterStep9()
    elseif step == 10 then
        self:enterStep10()
    elseif step == 11 then
        self:enterStep11()
    elseif step == 12 then
        self:enterStep12()
    elseif step == 13 then
        self:enterStep13()
    elseif step == 14 then
        self:enterStep14()
    elseif step == 15 then
        self:enterStep15()
    elseif step == 16 then
        self:enterStep16()
    elseif step == 17 then
        self:enterStep17()
    elseif step == 18 then
        self:enterStep18()
    elseif step == 19 then
        self:enterStep19()
	end
end

function GameTechView:enterStep1()
	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,0,40)
	self:playerChipsUpdate_Callback(7,0,0,40)
    
    self:changeNextBackOption()
end

function GameTechView:enterStep2()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,0,40)
	self:playerChipsUpdate_Callback(7,0,0,40)
    
	self:updateDealerPos_Callback(0,false)
    
	self:showNewerBlindHint(2,false)
	self:showNewerBlindHint(7,true)
    
	self:showPlayerCards_Callback(0,"2_K","1_10",false)
	self:dispatchPlayerCards_Callback(2,0,0.2 * 1,"")
	self:dispatchPlayerCards_Callback(7,0,0.2 * 2,"")
    
	self:dispatchPlayerCards_Callback(2,1,0.2 * 4,"")
	self:dispatchPlayerCards_Callback(7,1,0.2 * 5,"")
    
	self:showNewerGuideStage(kNewGuideStagePocket)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
end

function GameTechView:enterStep3()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,0,40)
	self:playerChipsUpdate_Callback(7,0,0,40)
    
	self:updateDealerPos_Callback(0,false)
    
	self:showNewerBlindHint(2,false)
	self:showNewerBlindHint(7,true)
    
	self:showPlayerCards_Callback(0,"2_K","1_10",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
	self:showPublicCard_Callback(0,"1_8",true)
	self:showPublicCard_Callback(1,"2_Q",true)
	self:showPublicCard_Callback(2,"3_10",true)
	self:showPublicCard_Callback(3,"0_K",true)
	self:showPublicCard_Callback(4,"1_K",true)
    
    self:updatePublicPots_Callback(6,0,6,true)
    local index = {0,1,4,5,6}
    self:hightLightMyCards(0,index,7)

    local tips = cc.Sprite:create("picdata/gameTech/gameTechTips.png")
    tips:setPosition(cc.p(LAYOUT_OFFSET.x+470, 260))
    self:addChild(tips,999,1024)
    
	self:showNewerGuideStage(kNewGuideStageRiver)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
	
end

function GameTechView:enterStep4()

	self.m_pokerTypeClickable = false
	self:changeGameTechText()
    self:removeChildByTag(1024, true)
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,0,40)
	self:playerChipsUpdate_Callback(7,0,0,40)
    self:updatePublicPots_Callback(6,0,6,true)

	self:updateDealerPos_Callback(0,false)
    
	self:showNewerBlindHint(2,false)
	self:showNewerBlindHint(7,true)
    
	self:showPlayerCards_Callback(0,"2_K","3_10",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
	self:showPublicCard_Callback(0,"1_8",false)
	self:showPublicCard_Callback(1,"2_Q",false)
	self:showPublicCard_Callback(2,"3_10",false)
	self:showPublicCard_Callback(3,"0_K",false)
	self:showPublicCard_Callback(4,"1_K",false)
    
    local index = {0,1,4,5,6}
	self:hightLightMyCards(0,index,7)
    

	local poker1 = self.m_pCommunityCardArray[1]
	local poker2 = self.m_pCommunityCardArray[2]
	poker1:winPokerMask()
	poker2:winPokerMask()
    
	self:showNewerGuideStage(kNewGuideStageRiver)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.Step4Callback))))
	
end

function GameTechView:Step4Callback()

	self:removePokerType()
	self:doPokerType(nil)
    self:clearAllPlayerCards_Callback(0.2)
    
    self.m_pokerTypeClickable = true
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
        cc.CallFunc:create(handler(self, self.removePokerType)),
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
end

function GameTechView:removePokerType()

	local p = self:getChildByTag(20001)
	if p then
	
		p:removeFromParent(true)
	end
end

function GameTechView:enterStep5()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,0,40)
	self:playerChipsUpdate_Callback(7,0,0,40)
    
	self:changeNextBackOption()
end

function GameTechView:enterStep6()

    
	self:changeGameTechText()
  	self:clearRoomViewAllElement_Callback()
    
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
    
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
    
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,1,39)
	self:playerChipsUpdate_Callback(7,0,2,38)
    
	self:dispatchPlayerCards_Callback(0,0,0.2 * 0,"1_Q")
	self:dispatchPlayerCards_Callback(2,0,0.2 * 1,"")
	self:dispatchPlayerCards_Callback(7,0,0.2 * 2,"")
    
	self:dispatchPlayerCards_Callback(0,1,0.2 * 3,"0_J")
	self:dispatchPlayerCards_Callback(2,1,0.2 * 4,"")
	self:dispatchPlayerCards_Callback(7,1,0.2 * 5,"")
    
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
end

function GameTechView:enterStep7()
	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:playerChipsUpdate_Callback(0,0,0,40)
	self:playerChipsUpdate_Callback(2,0,1,39)
	self:playerChipsUpdate_Callback(7,0,2,38)
    
	self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
	
	self:waitForPlayerActioning_Callback(true,0,10,10)
	self:setOperateSliderMark(true)
	self:showFoldCallRaiseOp(2,4,40,2,0,2)
	self:showNewerGuideActionHint(kNGAPocketGoodCallRaise,kOBNGNone)
    
	self.m_operateBoard:setRaiseSliderEnabled(false)
	self.m_operateBoard.m_Fold_FCAR:setButtonEnabled(false)
	self.m_operateBoard.m_Fold_FCAR:setOpacity(125)
	self.m_operateBoard.m_Raise_FCAR:setButtonEnabled(false)
	self.m_operateBoard.m_Raise_FCAR:setOpacity(125)
    self.m_operateBoard.two_big_blind:setButtonEnabled(false)
    self.m_operateBoard.three_big_blind:setButtonEnabled(false)
    self.m_operateBoard.four_big_blind:setButtonEnabled(false)
	--暂时关闭触摸
	self.m_maskLayer:setTouchEnabled(false)

end

function GameTechView:enterStep8()

	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:playerChipsUpdate_Callback(0,0,2,38)
	self:playerChipsUpdate_Callback(2,0,2,38)
	self:playerChipsUpdate_Callback(7,0,2,38)
    
	self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
	self:waitForPlayerActioning_Callback(false,5,10,10)
    

    self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
        cc.CallFunc:create(handler(self, self.Step8CheckCallback))))

	--暂时关闭触摸
	self.m_maskLayer:setTouchEnabled(false)
end

function GameTechView:Step8CheckCallback()

    self.m_questionType = firstLayer
	self:playerCheck_Callback(true,7)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
                                       cc.CallFunc:create(handler(self, self.Step8CollectChipCallback)),
                                       cc.CallFunc:create(handler(self, self.Step8FlopCallback)),
                                       cc.CallFunc:create(handler(self, self.changeGameTechText)),
                                       cc.CallFunc:create(handler(self, self.showQuestionLayer))))
    
end

function GameTechView:showQuestionLayer()
    --提问
    if (self.m_questionType == firstLayer) then
        self.firstQuestion:setVisible(true)
    end
    if (self.m_questionType == secondLayer) then 
        self.secondQuestion:setVisible(true)
    end
    if (self.m_questionType == thirdLayer) then 
        self.thirdQuestion:setVisible(true)
    end
end

function GameTechView:Step8CollectChipCallback()

	self:updatePublicPots_Callback(6,0,6,true)
end

function GameTechView:Step8FlopCallback()

	self:showPublicCard_Callback(0,"0_10",true)
	self:showPublicCard_Callback(1,"0_Q",true)
	self:showPublicCard_Callback(2,"1_A",true)
end

function GameTechView:enterStep9()

    
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
	self:showPublicCard_Callback(0,"0_10",false)
	self:showPublicCard_Callback(1,"0_Q",false)
	self:showPublicCard_Callback(2,"1_A",false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,0,38)
	self:playerChipsUpdate_Callback(7,0,0,38)
	self:updatePublicPots_Callback(0,0,6,false)
    
	self:waitForPlayerActioning_Callback(false,2,10,10)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
        cc.CallFunc:create(handler(self, self.step9CheckCallback))))
end

function GameTechView:step9CheckCallback()

	self:playerCheck_Callback(false,2)
	self:changeGameTechText()
	self:changeNextBackOption()
end

function GameTechView:enterStep10()

	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,0,38)
	self:playerChipsUpdate_Callback(7,0,0,38)
	self:updatePublicPots_Callback(0,0,6,false)
    
	self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
	self:showPublicCard_Callback(0,"0_10",false)
	self:showPublicCard_Callback(1,"0_Q",false)
	self:showPublicCard_Callback(2,"1_A",false)
    
	self:waitForPlayerActioning_Callback(false,7,10,10)
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
        cc.CallFunc:create(handler(self, self.step10CheckCallback))))
end

function GameTechView:step10CheckCallback()

	self:playerCheck_Callback(true,7)
	self:changeGameTechText()
	self:changeNextBackOption()
end

function GameTechView:enterStep11()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,0,38)
	self:playerChipsUpdate_Callback(7,0,0,38)
	self:updatePublicPots_Callback(0,0,6,false)
    
	self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    
	self:waitForPlayerActioning_Callback(true,0,10,10)
	self:setOperateSliderMark(true)
	self:showFoldCheckRaiseOp(2,38,2,6,0)
	self:showNewerGuideActionHint(kNGAFlopCautious,kOBNGNone)
    
	self.m_operateBoard.m_Fold_FCHR:setButtonEnabled(false)
	self.m_operateBoard.m_Fold_FCHR:setOpacity(125)
	self.m_operateBoard.m_Raise_FCHR:setButtonEnabled(false)
	self.m_operateBoard.m_Raise_FCHR:setOpacity(125)
	self.m_operateBoard:setRaiseSliderEnabled(false)
	--暂时关闭触摸
	self.m_maskLayer:setTouchEnabled(false)
   
end

function GameTechView:enterStep12()

	self:clearRoomViewAllElement_Callback()
    self:changeGameTechText()

	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,0,38)
	self:playerChipsUpdate_Callback(7,0,0,38)
	self:updatePublicPots_Callback(0,0,6,false)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    
	self:showPublicCard_Callback(3,"1_J",true)
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)
    
    self.m_questionType = secondLayer
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.showQuestionLayer))))
end

function GameTechView:enterStep13()

	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,0,38)
	self:playerChipsUpdate_Callback(7,0,0,38)
	self:updatePublicPots_Callback(0,0,6,false)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    
    self:showPublicCard_Callback(3,"1_J",false)
    
	local index = {0,1,3,5}
	self:hightLightMyCards(0,index,3)
    
	self:waitForPlayerActioning_Callback(false,2,10,10)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
        cc.CallFunc:create(handler(self, self.step13RaiseCallback))))
end

function GameTechView:step13RaiseCallback()

	self:playerRaise_Callback(true,2,2,0,36)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.changeGameTechText)),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
end

function GameTechView:enterStep14()

	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:updatePublicPots_Callback(0,0,6,false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,2,36)
	self:playerChipsUpdate_Callback(7,0,0,38)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
	self:showPlayerCards_Callback(7,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    
    self:showPublicCard_Callback(3,"1_J",false)
    
    local index = {0,1,3,5}
    self:hightLightMyCards(0,index,3)
    
	self:waitForPlayerActioning_Callback(false,7,10,10)
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
        cc.CallFunc:create(handler(self, self.step14FoldCallback))))
end

function GameTechView:step14FoldCallback()

	self:playerFold_Callback(false,false,7)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.changeGameTechText)),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
end

function GameTechView:enterStep15()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:updatePublicPots_Callback(0,0,6,false)
    
	self:playerChipsUpdate_Callback(0,0,0,38)
	self:playerChipsUpdate_Callback(2,0,2,36)
	self:playerChipsUpdate_Callback(7,0,0,38)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
    self:showPlayerCards_Callback(2,"","",false)
    self:showPlayerCards_Callback(7,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    
    self:showPublicCard_Callback(3,"1_J",false)
    
    local index = {0,1,3,5}
    self:hightLightMyCards(0,index,3)
    
	self:waitForPlayerActioning_Callback(true,0,10,10)
	self:setOperateSliderMark(true)
	self:showFoldCallRaiseOp(2,4,38,2,6,2)
	self:showNewerGuideActionHint(kNGAPocketGoodCallRaise,kOBNGNone)
    
	self.m_operateBoard:setRaiseSliderEnabled(false)
	self.m_operateBoard.m_Fold_FCAR:setButtonEnabled(false)
	self.m_operateBoard.m_Fold_FCAR:setOpacity(125)
	self.m_operateBoard.m_Raise_FCAR:setButtonEnabled(false)
	self.m_operateBoard.m_Raise_FCAR:setOpacity(125)
	--暂时关闭触摸
	self.m_maskLayer:setTouchEnabled(false)
   
end

function GameTechView:enterStep16()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:updatePublicPots_Callback(0,0,10,false)
	self:playerChipsUpdate_Callback(0,0,0,36)
	self:playerChipsUpdate_Callback(2,0,0,36)
	self:playerChipsUpdate_Callback(7,0,0,38)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
	self:showPlayerCards_Callback(2,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    self:showPublicCard_Callback(3,"1_J",false)
    self:showPublicCard_Callback(4,"2_J",false)
    local index = {0,1,3,5,6}
    self:hightLightMyCards(0,index,7)
    
    self.m_questionType = thirdLayer
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.showQuestionLayer))))
end

function GameTechView:enterStep17()

	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:updatePublicPots_Callback(0,0,10,false)
	self:playerChipsUpdate_Callback(0,0,0,36)
	self:playerChipsUpdate_Callback(2,0,0,36)
	self:playerChipsUpdate_Callback(7,0,0,38)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
    self:showPlayerCards_Callback(2,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    self:showPublicCard_Callback(3,"1_J",false)
    self:showPublicCard_Callback(4,"2_J",false)
    
	local index = {0,1,3,5,6}
	self:hightLightMyCards(0,index,7)
    
	self:waitForPlayerActioning_Callback(false,2,10,10)
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),
        cc.CallFunc:create(handler(self, self.Step17CheckCallbak))))
end

function GameTechView:Step17CheckCallbak()

	self:playerAllin_Callback(true,2,36,0,0)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
        cc.CallFunc:create(handler(self, self.changeGameTechText)),
        cc.CallFunc:create(handler(self, self.changeNextBackOption))))
end

function GameTechView:enterStep18()

	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:updatePublicPots_Callback(0,0,46,false)
	self:playerChipsUpdate_Callback(0,0,0,36)
	self:playerChipsUpdate_Callback(2,0,0,36)
	self:playerChipsUpdate_Callback(7,0,0,38)
    
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
    self:showPlayerCards_Callback(2,"","",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    self:showPublicCard_Callback(3,"1_J",false)
    self:showPublicCard_Callback(4,"2_J",false)
    
	local index = {0,1,3,5,6}
	self:hightLightMyCards(0,index,7)
    
	self:waitForPlayerActioning_Callback(true,0,10,10)
	self:showFoldCallAllIn(36)
	self:showNewerGuideActionHint(kNGAFlopGreatRaise,kOBNGNone)
    
	self.m_operateBoard:setRaiseSliderEnabled(false)
	self.m_operateBoard.m_Fold_FCAA:setButtonEnabled(false)
	self.m_operateBoard.m_Fold_FCAA:setOpacity(125)
	self.m_operateBoard.m_Call_FCAA:setButtonEnabled(false)
	self.m_operateBoard.m_Call_FCAA:setOpacity(125)
	--暂时关闭触摸
	self.m_maskLayer:setTouchEnabled(false)
end

function GameTechView:enterStep19()
	self:changeGameTechText()
	self:clearRoomViewAllElement_Callback()
    
	self:playerSit_Callback(true,0,self.m_myName,"",self.m_headUrl,MyInfo.data.userId,0,false)
	self:setPlayerClickable(0,false)
	self:playerSit_Callback(false,2,self.m_momoName,self.m_felalSex,"","1",0,false,true)
	self:setPlayerClickable(2,false)
	self:playerSit_Callback(false,7,self.m_deName,self.m_maleSex,"","2",0,false,true)
	self:setPlayerClickable(7,false)
    
	self:updateDealerPos_Callback(0,false)
    
	self:updatePublicPots_Callback(0,0,82,false)
	self:playerChipsUpdate_Callback(0,0,0,82)
	self:playerChipsUpdate_Callback(2,0,0,0)
	self:playerChipsUpdate_Callback(7,0,0,38)
    
    self:showPlayerCards_Callback(2,"2_Q","1_K",false)
    self:showPlayerCards_Callback(0,"1_Q","0_J",false)
    
    self:showPublicCard_Callback(0,"0_10",false)
    self:showPublicCard_Callback(1,"0_Q",false)
    self:showPublicCard_Callback(2,"1_A",false)
    self:showPublicCard_Callback(3,"1_J",false)
    self:showPublicCard_Callback(4,"2_J",false)
    
	local index = {0,1,3,5,6}
    self:hightLightMyCards(0,index,7)
    
	local maxCard = {}
	maxCard[#maxCard+1] = "1_Q"
	maxCard[#maxCard+1] = "0_J"
	maxCard[#maxCard+1] = "0_Q"
	maxCard[#maxCard+1] = "1_J"
	maxCard[#maxCard+1] = "2_J"
	self:updatePrizePots_Callback(true,0,0,0,10,46,4,maxCard)
    
    local bgcolor = cc.LayerColor:create(cc.c4b(0,0,0,150))
    bgcolor:setPosition(cc.p(0,0))
    bgcolor:setScale(1.5)
    self:addChild(bgcolor)
    
	self:showNewerGuideActionHint(kNGANone,kOBNGNone)
    
    DBHttpRequest:joinActivity(handler(self, self.httpResponse), "204", "4")
    DBHttpRequest:finishFreshGuide(handler(self, self.httpResponse), MyInfo.data.userId)
	self:changeNextBackOption()
end

return GameTechView 