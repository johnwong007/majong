require("app.Logic.Datas.Props.UserPropsList")
require("app.Tools.EStringTime")
local myInfo = require("app.Model.Login.MyInfo")
local GameLayerManager  = require("app.GUI.GameLayerManager")

local debao_private_room_name = {
	"雨夜缠绵",
	"逆转轮回",
	"挥笔青春",
	"紫色回忆",
	"永恒记忆",
	"遗忘角落",
	"等你等你",
	"爱笑de你",
	"执著de",
	"美丽魅力",
	"嗳媞唏望",
	"执著旳爱",
	"郁金香",
	"幽冥星辰",
	"午后戈壁",
	"金色牧场",
	"罗马假日",
	"兰桂飘香",
	"情愫蓝桥",
	"夏日抹茶",
	"秋日私语",
	"翠提春晓",
	"沧海明月",
	"维多利亚",
}

local card_name = {
	"标准牌局卡",
	"免服务费体验卡",
	"自定义筹码牌局卡",
	-- "单桌SNG牌局卡(暂未开放)"}
	"单桌SNG牌局卡",
	"MTT锦标赛卡",
	"6+大牌扑克牌局卡",
	}

if NEED_SNG==false then
	card_name[4] = "单桌SNG牌局卡(暂未开放)"
end

if NEED_PRI_MTT == false then
	card_name[5] = "MTT锦标赛卡(暂未开放)"
end

local room_hint = {
	"买入同时需支付（5%买入金币）作为账单服务费",
	"免服务费",
	"无服务费",
	"比赛人数坐满开赛，本场SNG结束关闭房间",
	"",
	"买入同时需支付（5%买入金币）作为账单服务费",
}

local string_value1 = "(拥有"
local string_value2 = "张)"

local bgWidth = 0
local bgHeight = 0
local startPos = cc.p(0, 17)

local hintDotGap = 60
-- local normal_card_blind = {"5000/10000", "10000/20000", "20000/40000", "50000/100000"}
-- local normal_card_time = {"1小时", "2小时", "4小时", "6小时"}
-- local free_card_blind = {"1/2", "5/10", "10/20"}
-- local free_card_time = {"30分钟", "1小时"}
-- local diy_card_blind = {"25/50", "50/100", "100/200", "500/1000"}
-- local diy_card_time = {"2小时", "6小时", "12小时"}
-- local room_time = {
-- 	{3600, 3600*2, 3600*4, 3600*6},
-- 	{1800, 3600},
-- 	{3600*2, 3600*6, 3600*12},
-- 	{180, 300},
-- 	{180, 300, 480, 600},
-- }

local normal_card_blind = {"1/2", "2/4", "5/10", "10/20", "25/50", "50/100", "100/200", "500/1000", "1000/2000"}
local normal_card_time = {"30分钟", "1小时", "2小时", "3小时", "4小时", "5小时", "6小时"}
local free_card_blind = {"1/2", "2/4", "5/10", "10/20", "25/50", "50/100", "100/200", "500/1000", "1000/2000"}
local free_card_time = {"30分钟", "1小时", "2小时", "3小时", "4小时", "5小时", "6小时"}
local diy_card_blind = {"1/2", "2/4", "5/10", "10/20", "25/50", "50/100", "100/200", "500/1000", "1000/2000"}
local diy_card_time = {"30分钟", "1小时", "2小时", "3小时", "4小时", "5小时", "6小时"}
local plus6_card_blind = {"1000/2000","2000/4000","5000/10000"}
local plus6_card_time = {"1小时","2小时","4小时","6小时","12小时","24小时"}
local room_time = {
	{1800, 3600, 3600*2, 3600*3, 3600*4, 3600*5, 3600*6},
	{1800, 3600, 3600*2, 3600*3, 3600*4, 3600*5, 3600*6},
	{1800, 3600, 3600*2, 3600*3, 3600*4, 3600*5, 3600*6},
	{180, 300},
	{180, 300, 600},
	{3600, 3600*2, 3600*4, 3600*6, 3600*12, 3600*24},
}

local sng_start_chips = {"1500", "3000", "5000"}
local sng_card_time = {"3分钟", "5分钟"}
local seat_slider_hint = {"2", "6", "9"}
local seat_slider_hint2 = {"6", "9"}
local mtt_start_chips = {"600","1000","1500","2000","4000","10000"}
local mtt_pay_money = {100,200,300,400,500,1000,2000}

local dialogStartPos = cc.p(0,0)
local confirmButtonGap = 150

local mtt_total_num = {
    ["2"] = {2,4,6,8,12,18,32,64,100,200,500,1000,2000},
    ["6"] = {6,12,18,24,30,48,60,90,120,600,1200,1800},
    ["9"] = {9,18,27,36,45,90,180,540,1080,1980},
}

local seat_num = {2,6,9}

local ControlSliderEx = class("ControlSliderEx", function(event)
	return display.newLayer()
	end)

function ControlSliderEx:create(backgroundSprite, progressSprite, thumbSprite, position)
	local obj = ControlSliderEx:new()
	obj:initWithFile(backgroundSprite, progressSprite, thumbSprite, position)
	return obj
end

function ControlSliderEx:ctor()
	self.touchEnded = false

    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.touchEvent))
end

function ControlSliderEx:initWithFile(backgroundSprite, progressSprite, thumbSprite, position)
	local pSlider = cc.ControlSlider:create(backgroundSprite, progressSprite, thumbSprite)
	pSlider:registerControlEventHandler(handler(self,self.onValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
	pSlider:setMaximumValue(100)
	pSlider:setMinimumValue(0)
	pSlider:setValue(0)
	pSlider:setPosition(position)
	self:addChild(pSlider)
end

function ControlSliderEx:touchEvent(event)
	dump(event)
end

function ControlSliderEx:onValueChanged(event)
	-- dump(event)
end

---------------------------------------------------------------------------------------------------------
local CreateDebaoRoomLogic = class("CreateDebaoRoomDialog", function()
	return display.newNode()
end)

function CreateDebaoRoomLogic:ctor(params)
	self:setNodeEventEnabled(true)
	self.m_callbackUI = params.m_callbackUI
    -- DBHttpRequest:getUserPropsList(handler(self, self.httpResponse), "FUNCTION", 6230)
    
end

function CreateDebaoRoomLogic:createPrivateRoom(params)
    local cardType = params.cardType or 1
    local key = {CREATE_ROOM_STANDARD, CREATE_ROOM_NO_FEE, CREATE_ROOM_DIY, CREATE_MATCH_DIY_SNG, CREATE_MATCH_DIY_MTT, CREATE_ROOM_6Plus}
    local pid = self.m_userPropsList.m_propsList["FUNCTION"][key[params.cardType]]["pid"]
    local roomName = params.roomName or ""
    local password = params.password or ""
    local seatNum = params.seatNum or 0
    -- dump(params)
    if cardType == 1 or cardType == 2 or cardType == 3 or cardType == 6 then
    	local blind = params.blind or ""
    	local upseconds = params.upseconds or ""
    	DBHttpRequest:useRoomCard(handler(self, self.onHttpResponse), pid, roomName, password, seatNum, blind, upseconds)
	elseif cardType == 4 then
		local startChips = params.startChips or ""
    	local upseconds = params.upseconds or ""
    	DBHttpRequest:useMatchCard(handler(self, self.onHttpResponse), pid, roomName, password, seatNum, startChips, upseconds)
	elseif cardType == 5 then 
		local startChips = params.startChips or ""
    	local upseconds = params.upseconds or ""
    	local roomType = "MTT"
    	local payMoney = params.payMoney or 0
    	local totalNum = params.totalNum or 0
    	local isRebuy = params.isRebuy or false
    	local isAddon = params.isAddon or false
    	local planStartTime = EStringTime:getTwoHoursLaterFromNow()
    	DBHttpRequest:useMatchCard(handler(self, self.onHttpResponse),pid,roomName,password,seatNum,startChips,upseconds,roomType,"","",
    		planStartTime,"POINT",payMoney,payMoney*0.5,seatNum,totalNum,"",isRebuy,isAddon)
	end
end
--[[http请求返回]]
----------------------------------------------------------
function CreateDebaoRoomLogic:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- pr(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- pr(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    -- self:dealLoginResp(request:getResponse())
    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end
function CreateDebaoRoomLogic:onEnterTransitionFinish()
	DBHttpRequest:getUserPropsList(handler(self, self.httpResponse), "FUNCTION", myInfo.data.userId)
end
function CreateDebaoRoomLogic:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_GETUSERPROPSLIST then --[[获取开房卡信息]]
		local userPropsList = UserPropsList:getInstance()
		userPropsList:updatePropsList(content)
		-- dump(json.decode(content))
		dump(userPropsList.m_propsList)

		local cardNum1 = userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_STANDARD] and userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_STANDARD]["num"] or 0
		local cardNum2 = userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_NO_FEE] and userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_NO_FEE]["num"] or 0
		local cardNum3 = userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_DIY] and userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_DIY]["num"] or 0
		local cardNum4 = userPropsList.m_propsList["FUNCTION"][CREATE_MATCH_DIY_SNG] and userPropsList.m_propsList["FUNCTION"][CREATE_MATCH_DIY_SNG]["num"] or 0
		local cardNum5 = userPropsList.m_propsList["FUNCTION"][CREATE_MATCH_DIY_MTT] and userPropsList.m_propsList["FUNCTION"][CREATE_MATCH_DIY_MTT]["num"] or 0
		local cardNum6 = userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_6Plus] and userPropsList.m_propsList["FUNCTION"][CREATE_ROOM_6Plus]["num"] or 0
		self.m_callbackUI:updateCardNum({
		tonumber(cardNum1),
		tonumber(cardNum2),
		tonumber(cardNum3),
		tonumber(cardNum4),
		tonumber(cardNum5),
		tonumber(cardNum6)})
		self.m_userPropsList = userPropsList
	-- elseif tag == POST_COMMAND_USE_ROOMCARD then
	-- 	dump(content)
	-- elseif tag == POST_COMMAND_USE_MATCHCARD then
	-- 	dump(content)
	end
end
---------------------------------------------------------------------------------------------------------
local CreateDebaoRoomDialog = class("CreateDebaoRoomDialog", function()
	return display.newLayer()
end)

function CreateDebaoRoomDialog:create()

end

function CreateDebaoRoomDialog:ctor()
	-- self:setVisible(false)
	--[[数据初始化]]
	self.cardNum = {0,0,0,0,0,0}
	self.currentStep = 1
	self.cardButtons = {}
	self:setNodeEventEnabled(true)

    self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	if event.name == "began" then
        	return true
    	end
	end)
	local size = cc.size(774,640)
	-- self.m_dialogBg = cc.ui.UIImage.new("picdata/privateHall/createDebaoRoomBG.png")
	self.m_dialogBg = cc.ui.UIImage.new("picdata/public/bg_tc_3.png", {scale9 = true})
	self.m_dialogBg:setLayoutSize(size.width,size.height)
	self.m_dialogBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2-8)
		:addTo(self)

	bgWidth = self.m_dialogBg:getContentSize().width
	bgHeight = self.m_dialogBg:getContentSize().height

	self.cancel = cc.ui.UIPushButton.new({normal="picdata/public/btn_2_close.png", pressed="picdata/public/btn_2_close2.png", 
		disabled="picdata/public/btn_2_close2.png"})
		:align(display.CENTER, bgWidth-20, bgHeight-25)
		:addTo(self.m_dialogBg, 1)
		:onButtonClicked(function(event)
			self:pressBack()
			end)

	self.title = cc.ui.UIImage.new("picdata/privateHall/createDebaoRoomTitle.png")
		:align(display.CENTER, bgWidth/2, bgHeight-60)
		:addTo(self.m_dialogBg)
	
	self.currentSeatNum = 2
	self:initFirstStep()
	self.sliderDot = {}
	self.sliderDot2 = {}
	self.sliderDot3 = {}
	self.sliderDot4 = {}
	self.sliderDot5 = {}
	self.sliderDot6 = {}
	self.sliderDot7 = {}
	self.sliderDot8 = {}
	self.sliderDot9 = {}
	self.sliderDot10 = {}
	self.sliderDot15 = {}
	self.sliderDot16 = {}

	self.sliderSeatDot = {}
	self.sliderSeatDot2 = {}

	self:initSecondStepNormal()
	self:initSecondStepFree()
	self:initSecondStepDiy()
	self:initSecondStep6Plus()
	self:initSecondStepSNG()
	-- self:initFinalStep()
	self:initSeatButtons()
	self:initSecondStepMTT()
	self:initThirdStepMTT()

	self.firstStep:setVisible(true)
	self:setSecondStepVisible(false)
	self:setSecondStepFreeVisible(false)
	self:setSecondStepDiyVisible(false)
	self:setSecondStep6PlusVisible(false)
	self:setSecondStepSNGVisible(false)
	self:setSecondStepMTTVisible(false)
	self:setThirdStepMTTVisible(false)
	-- self:setFinalStepVisible(false)
	-- 注册事件
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    	if not self.m_slider1:isSelected() then
			local value = math.round(self.m_slider1:getValue())
			self.m_slider1:setValue(value)

			self.m_sliderHint1:setString(normal_card_blind[value+1])
			-- self.m_sliderHint1:setPositionX(self.sliderDot[value+1]:getPositionX()-10)
			for i=1,#self.sliderDot do
				if i>value then
					self.sliderDot[i]:setVisible(false)
				else
					self.sliderDot[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider2:isSelected() then
			local value = math.round(self.m_slider2:getValue())
			self.m_slider2:setValue(value)

			self.m_sliderHint2:setString(normal_card_time[value+1].."")
			-- self.m_sliderHint2:setPositionX(self.sliderDot2[value+1]:getPositionX())
			for i=1,#self.sliderDot2 do
				if i>value then
					self.sliderDot2[i]:setVisible(false)
				else
					self.sliderDot2[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider3:isSelected() then
			local value = math.round(self.m_slider3:getValue())
			self.m_slider3:setValue(value)

			self.m_sliderHint3:setString(free_card_blind[value+1].."")
			-- self.m_sliderHint3:setPositionX(self.sliderDot3[value+1]:getPositionX())
			for i=1,#self.sliderDot3 do
				if i>value then
					self.sliderDot3[i]:setVisible(false)
				else
					self.sliderDot3[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider4:isSelected() then
    		local value = math.round(self.m_slider4:getValue())
			self.m_slider4:setValue(value)

			self.m_sliderHint4:setString(free_card_time[value+1].."")
			-- self.m_sliderHint4:setPositionX(self.sliderDot4[value+1]:getPositionX())
			for i=1,#self.sliderDot4 do
				if i>value then
					self.sliderDot4[i]:setVisible(false)
				else
					self.sliderDot4[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider5:isSelected() then
    		local value = math.round(self.m_slider5:getValue())
			self.m_slider5:setValue(value)

			self.m_sliderHint5:setString(diy_card_blind[value+1].."")
			-- self.m_sliderHint5:setPositionX(self.sliderDot5[value+1]:getPositionX())
			for i=1,#self.sliderDot5 do
				if i>value then
					self.sliderDot5[i]:setVisible(false)
				else
					self.sliderDot5[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider6:isSelected() then
    		local value = math.round(self.m_slider6:getValue())
			self.m_slider6:setValue(value)

			self.m_sliderHint6:setString(diy_card_time[value+1].."")
			-- self.m_sliderHint6:setPositionX(self.sliderDot6[value+1]:getPositionX())
			for i=1,#self.sliderDot6 do
				if i>value then
					self.sliderDot6[i]:setVisible(false)
				else
					self.sliderDot6[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider15:isSelected() then
    		local value = math.round(self.m_slider15:getValue())
			self.m_slider15:setValue(value)

			self.m_sliderHint15:setString(plus6_card_blind[value+1].."")
			-- self.m_sliderHint5:setPositionX(self.sliderDot5[value+1]:getPositionX())
			for i=1,#self.sliderDot15 do
				if i>value then
					self.sliderDot15[i]:setVisible(false)
				else
					self.sliderDot15[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider16:isSelected() then
    		local value = math.round(self.m_slider16:getValue())
			self.m_slider16:setValue(value)

			self.m_sliderHint16:setString(plus6_card_time[value+1].."")
			-- self.m_sliderHint6:setPositionX(self.sliderDot6[value+1]:getPositionX())
			for i=1,#self.sliderDot16 do
				if i>value then
					self.sliderDot16[i]:setVisible(false)
				else
					self.sliderDot16[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider7:isSelected() then
    		local value = math.round(self.m_slider7:getValue())
			self.m_slider7:setValue(value)

			self.m_sliderHint7:setString(sng_start_chips[value+1].."")
			-- self.m_sliderHint7:setPositionX(self.sliderDot7[value+1]:getPositionX())
			for i=1,#self.sliderDot7 do
				if i>value then
					self.sliderDot7[i]:setVisible(false)
				else
					self.sliderDot7[i]:setVisible(true)
				end
			end
    	end
    	if not self.m_slider8:isSelected() then
    		local value = math.round(self.m_slider8:getValue())
			self.m_slider8:setValue(value)

			self.m_sliderHint8:setString(sng_card_time[value+1].."")
			-- self.m_sliderHint8:setPositionX(self.sliderDot8[value+1]:getPositionX())
			for i=1,#self.sliderDot8 do
				if i>value then
					self.sliderDot8[i]:setVisible(false)
				else
					self.sliderDot8[i]:setVisible(true)
				end
			end
    	end
		
    	if self.m_showSeatSlider and not self.m_seatSlider:isSelected() then
    		local value = math.round(self.m_seatSlider:getValue())
			self.m_seatSlider:setValue(value)

			if seat_num[value+1]~=self.currentSeatNum then
				self.currentSeatNum = seat_num[value+1]
				self.m_seatSliderHint:setString(seat_slider_hint[value+1].."")
				for i=1,#self.sliderSeatDot do
					if i>value then
						self.sliderSeatDot[i]:setVisible(false)
					else
						self.sliderSeatDot[i]:setVisible(true)
					end
				end

				if self.currentCardButton and self.currentCardButton:getTag() == 5 then
					self:updateTotalNumMTT(seat_num[value+1])
				end
			end
    	end
    	if self.m_showSeatSlider2 and not self.m_seatSlider2:isSelected() then
    		local value = math.round(self.m_seatSlider2:getValue())
			self.m_seatSlider2:setValue(value)

			if seat_num[value+2]~=self.currentSeatNum then
				self.currentSeatNum = seat_num[value+2]
				self.m_seatSliderHint2:setString(seat_slider_hint2[value+1].."")
				for i=1,#self.sliderSeatDot2 do
					if i>value then
						self.sliderSeatDot2[i]:setVisible(false)
					else
						self.sliderSeatDot2[i]:setVisible(true)
					end
				end

				if self.currentCardButton and self.currentCardButton:getTag() == 5 then
					self:updateTotalNumMTT(seat_num[value+2])
				end
			end
    	end
   --  	if not self.m_slider9:isSelected() then
   --  		local value = math.round(self.m_slider9:getValue())
			-- self.m_slider9:setValue(value)
   --  	end
	end)
	-- 启用帧事件
	self:scheduleUpdate()

	self.m_logic = CreateDebaoRoomLogic.new({m_callbackUI = self})
	self.m_logic:addTo(self)

	-- 允许 node 接受触摸事件
    self:setTouchEnabled(true)

	-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
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
	
	local event = cc.EventCustom:new("HidePrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    self.m_dialogBg:setVisible(false)
	self.roomNameInput:setVisible(false)
    self.passwordTextField:setVisible(false)
end

function CreateDebaoRoomDialog:ccTouchBegan(event)
    local pos  = cc.p(event.x, event.y)
    local rect = cc.rect(dialogStartPos.x, dialogStartPos.y-55, 280, 332+55)
    if not cc.rectContainsPoint(rect, pos) then
		if self.firstStepBG:isVisible() then
    		self.confirmButton:setVisible(true)
			self.firstStepBG:setVisible(false)
			self.roomNameInput:setVisible(true)
    		self.passwordTextField:setVisible(true)
    	end
	end
    return true
end

function CreateDebaoRoomDialog:updateCardNum(params)
	params = params or {0,0,0,0,0,0}
	self.cardNum = nil
	self.cardNum = params

	if self.cardButtons and #self.cardButtons>0 then
		for i=1,#self.cardButtons do
			local buttonTitle = card_name[i]..string_value1..self.cardNum[i]..string_value2
			if i==4 then
				buttonTitle = "SNG功能暂未开放"
			end
			self.cardButtons[i]:setButtonLabelString("normal", buttonTitle)
			self.cardButtons[i]:setButtonLabelString("pressed", buttonTitle)
			self.cardButtons[i]:setButtonLabelString("disabled", buttonTitle)
		end
	end
	local totalNum = 0
	local tmpNum = #self.cardNum
	for i=1,tmpNum do
		totalNum = totalNum+self.cardNum[i]
	end

	if NEED_SNG==false then
		totalNum = totalNum-self.cardNum[4]
	end

	if NEED_PRI_MTT==false then
		totalNum = totalNum-self.cardNum[5]
	end

	if totalNum<=0 then
		self:setVisible(false)
		self.roomNameInput:setVisible(false)
    	self.passwordTextField:setVisible(false)
		local text = "您的开局卡数量为0，是否前往商店进行购买"
		local parent = self:getParent()
		local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,showType = 2,okText = "前往商城",titleText = "温馨提示",showBox = false,
			callOk = function (isSelect) GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,parent,{sortType = "DIYTABLE",nType = 3}) end,
			callCancle = function(isSelect) 
				local event = cc.EventCustom:new("ShowPrivateHallSearch")
    			cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			end}) 

		CMOpen(RewardLayer, parent, 0, 1, 1)
		-- CMClose(self, 0)
	else
		self:setVisible(true)
		self.m_dialogBg:setVisible(true)
		self.roomNameInput:setVisible(true)
    	self.passwordTextField:setVisible(true)
		self:initCardButtons(self.firstStepBG:getContentSize().width, 250)
	end
end

function CreateDebaoRoomDialog:addSliderDot(container, parent, sliderWidth, startPos, dotNum, zOrder, image)
	zOrder = zOrder or 0
	image = image or "picdata/privateHall/private_dot.png"
	if dotNum<2 then
		return
	end
	local gap = sliderWidth/(dotNum-1)
	for i=1,dotNum do
		local tmp = cc.ui.UIImage.new(image)
		tmp:align(display.CENTER, startPos.x+gap*(i-1), startPos.y)
			:addTo(parent, zOrder)
		if container then
			container[i] = tmp
			tmp:setVisible(false)
		end
	end
end

function CreateDebaoRoomDialog:onTouch_(event)
	
end

function CreateDebaoRoomDialog:onBlindValueChanged(event)
	-- dump("onValueChanged event")
end

function CreateDebaoRoomDialog:onTimeValueChanged(event)
	-- dump("onValueChanged event")
end

function CreateDebaoRoomDialog:onStartChipValueChanged(event)
	-- dump("onValueChanged event")
end

function CreateDebaoRoomDialog:onBlindTimeValueChanged(event)
	-- dump("onValueChanged event")
end

function CreateDebaoRoomDialog:initFirstStep()
--[[创建牌局第一步]]
	--------------------------------------------------------------------------------------------
	self.firstStep = display.newNode()
	self.firstStep:addTo(self.m_dialogBg)
	self.cardLabel = cc.ui.UILabel.new({
		text = "开局卡",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 125, self.title:getPositionY()-60)
		:addTo(self.firstStep, 1)

	local label2 = cc.ui.UILabel.new({
		text = "牌局名称",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), self.cardLabel:getPositionY()-120)
		:addTo(self.firstStep, 1)

	local gapX = 18
	local seatNumGap = 18

	-- self.firstStepBG = cc.ui.UIImage.new("picdata/privateHall/createDebaoRoomBG1.png")
	-- self.firstStepBG:align(display.LEFT_TOP, self.cardLabel:getPositionX()+gapX-11, self.cardLabel:getPositionY()+40)
	-- 	:addTo(self.firstStep, 2)
	-- self.firstStepBG:setVisible(false)

	self.firstStepBG = display.newNode()
	self.firstStepBG:align(display.CENTER_TOP, bgWidth/2, self.cardLabel:getPositionY()-10)
		:addTo(self.firstStep, 2)
	self.firstStepBG:setVisible(false)
	self.firstStepBG:setContentSize(cc.size(578,332))

	local xlTop = cc.ui.UIImage.new("picdata/privateHall/bg_xl_top.png", {scale9 = true})
		:align(display.LEFT_TOP, 11, 328)
		:addTo(self.firstStepBG)
    xlTop:setLayoutSize(556,60)

	dialogStartPos = cc.p(self.firstStepBG:getPositionX(), 
		self.firstStepBG:getPositionY()-self.firstStepBG:getContentSize().height)
	dialogStartPos = self.firstStep:convertToWorldSpace(dialogStartPos)
	--[[房间类型背景]]
	local cardTypeBG = cc.ui.UIImage.new("picdata/privateHall/private_input.png")
	-- cardTypeBG:align(display.CENTER, self.m_dialogBg:getContentSize().width/2, self.cardLabel:getPositionY())
	-- 	:addTo(self.firstStep, 1)

	--[[下拉菜单]]
	--------------------------
	local xlButton = cc.ui.UIPushButton.new({normal="picdata/privateHall/private_input.png", pressed="picdata/privateHall/private_input.png", 
		disabled="picdata/privateHall/private_input.png"})
	xlButton:align(display.CENTER, bgWidth/2, self.cardLabel:getPositionY()-45)
		:addTo(self.firstStep, 1)
		:onButtonClicked(function(event)
			self:pressSelectCardButton()
			end)
		:setTouchSwallowEnabled(false)

	cc.ui.UIPushButton.new({normal="picdata/privateHall/private_xl.png", pressed="picdata/privateHall/private_xl2.png", 
		disabled="picdata/privateHall/private_xl2.png"})
		:align(display.RIGHT_CENTER, xlButton:getPositionX()+556/2, 
			xlButton:getPositionY())
		:addTo(self.firstStep, 4)
		:onButtonClicked(function(event)
			self:pressSelectCardButton()
			end)
		:setTouchSwallowEnabled(true)
	--------------------------
	--[[房间名背景]]
	local roomNameBG = cc.ui.UIImage.new("picdata/privateHall/private_input.png")
	roomNameBG:align(display.CENTER, xlButton:getPositionX(), label2:getPositionY()-45)
		:addTo(self.firstStep, 1)

	--[[随机菜单]]
	cc.ui.UIPushButton.new({normal="picdata/privateHall/btn_sj.png", pressed="picdata/privateHall/btn_sj2.png", 
		disabled="picdata/privateHall/btn_sj2.png"})
		:align(display.RIGHT_CENTER, roomNameBG:getPositionX()+roomNameBG:getContentSize().width/2, 
			roomNameBG:getPositionY())
		:addTo(self.firstStep, 1)
		:onButtonClicked(function(event)
			self:randomRoomName()
			end)
		:setTouchSwallowEnabled(false)

	--[[房间类型]]
	self.cardTypeLabel = cc.ui.UILabel.new({
		text = "标准牌局卡",
		font = "Arial",
		size = 28,
		color = cc.c3b(255,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), xlButton:getPositionY())
		:addTo(self.firstStep, 4)

	--[[房间名字]]
	self.roomNameLabel = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 28,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), roomNameBG:getPositionY())
		:addTo(self.firstStep, 1)
	self.lastRoomNameIndex = -1
	self.roomNameLabel:setVisible(false)

	self.roomNameInput = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 8,
        -- minLength = 6,
        place     = "房间名字",
        color     = cc.c3b(255, 255, 255),
        fontSize  = 24,
        size = cc.size(460,32),
        -- bgPath    = "picdata/privateHall/private_input.png",
        -- inputFlag = 0
    })
    self.roomNameInput:setPosition(xlButton:getPositionX()-32, roomNameBG:getPositionY())
    self.roomNameInput:setAnchorPoint(cc.p(0,0.5))
    self.firstStep:addChild(self.roomNameInput)
		self.roomNameInput:setVisible(true)

	self:randomRoomName()

---------------------------------------------------------------
	local passwordPosX = self.cardLabel:getPositionX()
	local passwordPosY = label2:getPositionY()-120
	cc.ui.UILabel.new({
		text = "牌局密码",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 26,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, passwordPosX, passwordPosY)
		:addTo(self.firstStep)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
	:align(display.CENTER, xlButton:getPositionX(),passwordPosY-45)
	:addTo(self.firstStep)
    self.passwordTextField = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 8,
        -- minLength = 6,
        place     = "最多输入8位数字或字母",
        color     = cc.c3b(255, 255, 255),
        fontSize  = 24,
        size = cc.size(556,32),
        -- bgPath    = "picdata/privateHall/private_input.png",
        -- inputFlag = 0
    })
    self.passwordTextField:setPosition(xlButton:getPositionX()+10,passwordPosY-45)
    self.passwordTextField:setAnchorPoint(cc.p(0.5,0.5))
    self.firstStep:addChild(self.passwordTextField)
    -- self.passwordTextField:setVisible(false)
---------------------------------------------------------------


	--[[开房服务费提示]]
	self.hintLabel = cc.ui.UILabel.new({
		text = "买入同时支付（5%买入金币）作为账单服务费",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, bgWidth/2, self.passwordTextField:getPositionY()-65)
		:addTo(self.firstStep, 1)
	
	--------------------------------------------------------------------------------------------

	--[[分割线]]
	local line = cc.ui.UIImage.new("picdata/privateHall/private_line3.png")
	line:align(display.CENTER, bgWidth/2, self.hintLabel:getPositionY()-36)
		:addTo(self.m_dialogBg, 1)
	line:setScaleX(74)

	self.confirmButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", 
		pressed="picdata/public/btn_green2.png", 
		disabled="picdata/public/btn_green2.png"})
	self.confirmButton:align(display.CENTER, bgWidth/2, line:getPositionY()-50)
		:addTo(self.m_dialogBg, 0)
		:onButtonClicked(function(event)
			self:pressNext(event)
			end)
		:setTouchSwallowEnabled(false)

	local label = cc.ui.UILabel.new({
		text = "下一步",
		font = "黑体",
		size = 26,
		color = cc.c3b(215,255,178)
		})
    label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
	self.confirmButton:setButtonLabel("normal", label)

	self.confirmButton1 = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", 
		pressed="picdata/public/btn_green2.png", 
		disabled="picdata/public/btn_green2.png"})
	self.confirmButton1:align(display.CENTER, bgWidth/2-confirmButtonGap, line:getPositionY()-50)
		:addTo(self.m_dialogBg, 0)
		:onButtonClicked(function(event)
			self:pressFront(event)
			end)
		:setTouchSwallowEnabled(false)

	local label1 = cc.ui.UILabel.new({
		text = "上一步",
		font = "黑体",
		size = 26,
		color = cc.c3b(215,255,178)
		})
    label1:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
	self.confirmButton1:setButtonLabel("normal", label1)
	self.confirmButton1:setVisible(false)
end

function CreateDebaoRoomDialog:showSeatButtons(params)
	if params[1] == true then
		self.haveTwoSeatNode:setVisible(true)
		self.dontHaveTwoSeatNode:setVisible(false)
		self.m_showSeatSlider = true
		self.m_showSeatSlider2 = false
	else
		self.haveTwoSeatNode:setVisible(false)
		self.dontHaveTwoSeatNode:setVisible(true)
		self.m_showSeatSlider = false
		self.m_showSeatSlider2 = true
	end
	-- local gapX = 18
	-- local seatNumGap = 18
	-- local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/btn_renshu2.png")
	-- local buttonWidth = tmpSprite:getContentSize().width
	-- local startX = self.seatLabel:getPositionX()+gapX
	-- local flag = false
	-- if self.selectedSeatButton then
	-- 	self.selectedSeatButton:setButtonEnabled(true)
	-- 	self.selectedSeatButton = nil
	-- end
	-- for i=1,3 do
	-- 	if params[i] then
	-- 		self.seatBtns[i]:setVisible(true)
	-- 		self.seatBtns[i]:setPositionX(startX)
	-- 		startX = startX+buttonWidth+seatNumGap
	-- 		if flag==false then
	-- 			flag=true
	-- 			self.seatBtns[i]:setButtonEnabled(false)
	-- 			self.selectedSeatButton = self.seatBtns[i]
	-- 		end
	-- 	else
	-- 		self.seatBtns[i]:setVisible(false)
	-- 	end
	-- end
end

function CreateDebaoRoomDialog:initSeatButtons()

	local gapX = 18
	local seatNumGap = 18
	self.seatButtons = display.newNode()
	self.seatButtons:addTo(self.m_dialogBg)

	--[[人数选择菜单]]
	--------------------------
	local label3 = cc.ui.UILabel.new({
		text = "单桌人数:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER,  self.cardLabel:getPositionX(), self.cardLabel:getPositionY())
		:addTo(self.seatButtons)
	self.seatLabel = label3

	self.haveTwoSeatNode = display.newNode()
	self.haveTwoSeatNode:addTo(self.seatButtons)

	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width
	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create("picdata/privateHall/btn_player.png")
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, 3, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderSeatDot, sprite2, sliderWidth, startPos, 3, 2, "picdata/privateHall/private_dot2.png")

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(2)
	pSlider:setMinimumValue(0)
	pSlider:setValue(1)
	pSlider:setPosition(label3:getPositionX()+8+pSlider:getContentSize().width/2,
		label3:getPositionY()-45)
	self.haveTwoSeatNode:addChild(pSlider, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
		:addTo(self.haveTwoSeatNode, 0)

	self.dontHaveTwoSeatNode = display.newNode()
	self.dontHaveTwoSeatNode:addTo(self.seatButtons)

	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width
	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create("picdata/privateHall/btn_player.png")
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, 2, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderSeatDot2, sprite2, sliderWidth, startPos, 2, 2, "picdata/privateHall/private_dot2.png")

	local pSlider2 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider2:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider2:setMaximumValue(1)
	pSlider2:setMinimumValue(0)
	pSlider2:setValue(0)
	pSlider2:setPosition(pSlider:getPositionX(),
		pSlider:getPositionY())
	self.dontHaveTwoSeatNode:addChild(pSlider2, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider2:getPositionX(), pSlider2:getPositionY())
		:addTo(self.dontHaveTwoSeatNode, 0)
	self.m_seatSlider = pSlider
	self.m_seatSlider2 = pSlider2

	self.m_seatSliderHint = cc.ui.UILabel.new({
		text = seat_slider_hint[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label3:getPositionX()+110, label3:getPositionY()+1)
		:addTo(self.haveTwoSeatNode, 1)

	self.m_seatSliderHint2 = cc.ui.UILabel.new({
		text = seat_slider_hint2[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.m_seatSliderHint:getPositionX(), self.m_seatSliderHint:getPositionY())
		:addTo(self.dontHaveTwoSeatNode, 1)

	self:showSeatButtons({true,false,false})
	self:setSeatButtonVisible(false)

	-- local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/btn_renshu2.png")
	-- local buttonWidth = tmpSprite:getContentSize().width
	-- self.seatbutton1 = cc.ui.UIPushButton.new({normal="picdata/privateHall/btn_renshu2.png", 
	-- 	pressed={"picdata/privateHall/private_renshu.png", "picdata/privateHall/btn_renshu2.png"}, 
	-- 	disabled={"picdata/privateHall/private_renshu.png", "picdata/privateHall/btn_renshu2.png"}})
	-- self.seatbutton1:align(display.LEFT_CENTER, label3:getPositionX()+gapX, label3:getPositionY())
	-- 	:addTo(self.seatButtons, 1)
	-- 	:onButtonClicked(function(event)
	-- 		self:pressSeatButton1()
	-- 		end)
	-- 	:setTouchSwallowEnabled(false)
	-- self.seatbutton1:setTag(2)

	-- self.seatbutton2 = cc.ui.UIPushButton.new({normal="picdata/privateHall/btn_renshu2_6.png", 
	-- 	pressed={"picdata/privateHall/private_renshu.png", "picdata/privateHall/btn_renshu2_6.png"}, 
	-- 	disabled={"picdata/privateHall/private_renshu.png", "picdata/privateHall/btn_renshu2_6.png"}})
	-- self.seatbutton2:align(display.LEFT_CENTER, self.seatbutton1:getPositionX()+buttonWidth+seatNumGap, label3:getPositionY())
	-- 	:addTo(self.seatButtons, 1)
	-- 	:onButtonClicked(function(event)
	-- 		self:pressSeatButton2()
	-- 		end)
	-- 	:setTouchSwallowEnabled(false)
	-- self.seatbutton2:setTag(6)

	-- self.seatbutton3 = cc.ui.UIPushButton.new({normal="picdata/privateHall/btn_renshu2_9.png", 
	-- 	pressed={"picdata/privateHall/private_renshu.png", "picdata/privateHall/btn_renshu2_9.png"}, 
	-- 	disabled={"picdata/privateHall/private_renshu.png", "picdata/privateHall/btn_renshu2_9.png"}})
	-- self.seatbutton3:align(display.LEFT_CENTER, self.seatbutton2:getPositionX()+buttonWidth+seatNumGap, label3:getPositionY())
	-- 	:addTo(self.seatButtons, 1)
	-- 	:onButtonClicked(function(event)
	-- 		self:pressSeatButton3()
	-- 		end)
	-- 	:setTouchSwallowEnabled(false)
	-- self.seatbutton3:setTag(9)


	-- self.seatbutton1:setButtonLabel("normal", cc.ui.UILabel.new({
	-- 	text = "2",
	-- 	font = "黑体",
	-- 	size = 26,
	-- 	color = cc.c3b(255,255,255)
	-- 	}))
	-- self.seatbutton2:setButtonLabel("normal", cc.ui.UILabel.new({
	-- 	text = "6",
	-- 	font = "黑体",
	-- 	size = 26,
	-- 	color = cc.c3b(255,255,255)
	-- 	}))
	-- self.seatbutton3:setButtonLabel("normal", cc.ui.UILabel.new({
	-- 	text = "9",
	-- 	font = "黑体",
	-- 	size = 26,
	-- 	color = cc.c3b(255,255,255)
	-- 	}))
	-- self.seatBtns = {self.seatbutton1,self.seatbutton2,self.seatbutton3}

	-- self.selectedSeatButton = self.seatbutton1
	-- self.selectedSeatButton:setButtonEnabled(false)
	-- --------------------------
end

function CreateDebaoRoomDialog:initSecondStepNormal()
	--[[创建牌局第二步]]
	--------------------------------------------------------------------------------------------
	self.secondStep = display.newNode()
	self.secondStep:addTo(self.m_dialogBg)
	-- self.secondStep:setPositionY(-120)

	local label4 = cc.ui.UILabel.new({
		text = "盲注级别:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), self.cardLabel:getPositionY()-120)
		:addTo(self.secondStep, 1)

	local label5 = cc.ui.UILabel.new({
		text = "牌局时间:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label4:getPositionX(), label4:getPositionY()-120)
		:addTo(self.secondStep, 1)

	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width

	-- local pSlider = cc.ControlSlider:create("picdata/privateHall/private_line.png", 
	-- 	"picdata/privateHall/private_line2.png", "picdata/privateHall/private_blinds.png")
	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create("picdata/privateHall/private_blinds.png")
	-- local startPos = cc.p(pSlider:getPositionX()-sliderWidth/2, pSlider:getPositionY())
	-- self:addSliderDot(self.sliderDot, pSlider, sliderWidth, startPos, 4)
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #normal_card_blind, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot, sprite2, sliderWidth, startPos, #normal_card_blind, 2, "picdata/privateHall/private_dot2.png")

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(#normal_card_blind-1)
	pSlider:setMinimumValue(0)
	pSlider:setValue(3)
	pSlider:setPosition(label4:getPositionX()+8+pSlider:getContentSize().width/2,
		label4:getPositionY()-45)
	self.secondStep:addChild(pSlider, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
		:addTo(self.secondStep, 0)

	sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	sprite3 = cc.Sprite:create("picdata/privateHall/private_time.png")
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #normal_card_time, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot2, sprite2, sliderWidth, startPos, #normal_card_time, 2, "picdata/privateHall/private_dot2.png")
	local pSlider2 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	-- local pSlider2 = cc.ControlSlider:create("picdata/privateHall/private_line.png", 
	-- 	"picdata/privateHall/private_line2.png", "picdata/privateHall/private_time.png")
	pSlider2:registerControlEventHandler(handler(self,self.onTimeValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider2:setMaximumValue(#normal_card_time-1)
	pSlider2:setMinimumValue(0)
	pSlider2:setValue(1)
	pSlider2:setPosition(pSlider:getPositionX(),
		label5:getPositionY()-45)
	self.secondStep:addChild(pSlider2, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider2:getPositionX(), pSlider2:getPositionY())
		:addTo(self.secondStep, 0)

	self.m_slider1 = pSlider
	self.m_slider2 = pSlider2

	self.m_sliderHint1 = cc.ui.UILabel.new({
		text = normal_card_blind[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot[1]:getPositionX()+105, self.sliderDot[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot[1]:getParent(), 1)

	self.m_sliderHint2 = cc.ui.UILabel.new({
		text = normal_card_time[1].."",
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot2[1]:getPositionX()+105, self.sliderDot2[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot2[1]:getParent(), 1)
end

function CreateDebaoRoomDialog:initSecondStepFree()
	self.secondStepFree = display.newNode()
	self.secondStepFree:addTo(self.m_dialogBg)
	-- self.secondStepFree:setPositionY(-120)

	local label4 = cc.ui.UILabel.new({
		text = "盲注级别:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), self.cardLabel:getPositionY()-120)
		:addTo(self.secondStepFree, 1)

	local label5 = cc.ui.UILabel.new({
		text = "牌局时间:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label4:getPositionX(), label4:getPositionY()-120)
		:addTo(self.secondStepFree, 1)

	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width

	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create("picdata/privateHall/private_blinds.png")
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #free_card_blind, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot3, sprite2, sliderWidth, startPos, #free_card_blind, 2, "picdata/privateHall/private_dot2.png")

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(#free_card_blind-1)
	pSlider:setMinimumValue(0)
	pSlider:setValue(3)
	pSlider:setPosition(label4:getPositionX()+8+pSlider:getContentSize().width/2,
		label4:getPositionY()-45)
	self.secondStepFree:addChild(pSlider, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
		:addTo(self.secondStepFree, 0)

	sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	sprite3 = cc.Sprite:create("picdata/privateHall/private_time.png")
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #free_card_time, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot4, sprite2, sliderWidth, startPos, #free_card_time, 2, "picdata/privateHall/private_dot2.png")
	local pSlider2 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider2:registerControlEventHandler(handler(self,self.onTimeValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider2:setMaximumValue(#free_card_time-1)
	pSlider2:setMinimumValue(0)
	pSlider2:setValue(1)
	pSlider2:setPosition(pSlider:getPositionX(),
		label5:getPositionY()-45)
	self.secondStepFree:addChild(pSlider2, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider2:getPositionX(), pSlider2:getPositionY())
		:addTo(self.secondStepFree, 0)

	self.m_slider3 = pSlider
	self.m_slider4 = pSlider2

	self.m_sliderHint3 = cc.ui.UILabel.new({
		text = free_card_blind[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot3[1]:getPositionX()+100, self.sliderDot3[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot3[1]:getParent(), 1)

	self.m_sliderHint4 = cc.ui.UILabel.new({
		text = free_card_time[1].."",
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot4[1]:getPositionX()+100, self.sliderDot4[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot4[1]:getParent(), 1)
end

function CreateDebaoRoomDialog:initSecondStepDiy()
	self.secondStepDiy = display.newNode()
	self.secondStepDiy:addTo(self.m_dialogBg)
	-- self.secondStepDiy:setPositionY(-120)

	local label4 = cc.ui.UILabel.new({
		text = "盲注级别:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), self.cardLabel:getPositionY()-120)
		:addTo(self.secondStepDiy, 1)

	local label5 = cc.ui.UILabel.new({
		text = "牌局时间:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label4:getPositionX(), label4:getPositionY()-120)
		:addTo(self.secondStepDiy, 1)

	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width

	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create("picdata/privateHall/private_blinds.png")
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #diy_card_blind, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot5, sprite2, sliderWidth, startPos, #diy_card_blind, 2, "picdata/privateHall/private_dot2.png")

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(#diy_card_blind-1)
	pSlider:setMinimumValue(0)
	pSlider:setValue(3)
	pSlider:setPosition(label4:getPositionX()+8+pSlider:getContentSize().width/2,
		label4:getPositionY()-45)
	self.secondStepDiy:addChild(pSlider, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
		:addTo(self.secondStepDiy, 0)

	sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	sprite3 = cc.Sprite:create("picdata/privateHall/private_time.png")
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #diy_card_time, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot6, sprite2, sliderWidth, startPos, #diy_card_time, 2, "picdata/privateHall/private_dot2.png")
	local pSlider2 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider2:registerControlEventHandler(handler(self,self.onTimeValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider2:setMaximumValue(#diy_card_time-1)
	pSlider2:setMinimumValue(0)
	pSlider2:setValue(1)
	pSlider2:setPosition(pSlider:getPositionX(),
		label5:getPositionY()-45)
	self.secondStepDiy:addChild(pSlider2, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider2:getPositionX(), pSlider2:getPositionY())
		:addTo(self.secondStepDiy, 0)

	self.m_slider5 = pSlider
	self.m_slider6 = pSlider2

	self.m_sliderHint5 = cc.ui.UILabel.new({
		text = diy_card_blind[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot5[1]:getPositionX()+100, self.sliderDot5[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot5[1]:getParent(), 1)

	self.m_sliderHint6 = cc.ui.UILabel.new({
		text = diy_card_time[1].."",
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot6[1]:getPositionX()+100, self.sliderDot6[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot6[1]:getParent(), 1)
end

function CreateDebaoRoomDialog:initSecondStep6Plus()
	self.secondStep6Plus = display.newNode()
	self.secondStep6Plus:addTo(self.m_dialogBg)

	local label4 = cc.ui.UILabel.new({
		text = "盲注级别:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), self.cardLabel:getPositionY()-120)
		:addTo(self.secondStep6Plus, 1)

	local label5 = cc.ui.UILabel.new({
		text = "牌局时间:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label4:getPositionX(), label4:getPositionY()-120)
		:addTo(self.secondStep6Plus, 1)

	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width

	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create("picdata/privateHall/private_blinds.png")
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #plus6_card_blind, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot15, sprite2, sliderWidth, startPos, #plus6_card_blind, 2, "picdata/privateHall/private_dot2.png")

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(#plus6_card_blind-1)
	pSlider:setMinimumValue(0)
	pSlider:setValue(3)
	pSlider:setPosition(label4:getPositionX()+8+pSlider:getContentSize().width/2,
		label4:getPositionY()-45)
	self.secondStep6Plus:addChild(pSlider, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
		:addTo(self.secondStep6Plus, 0)

	sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	sprite3 = cc.Sprite:create("picdata/privateHall/private_time.png")
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, #plus6_card_time, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot16, sprite2, sliderWidth, startPos, #plus6_card_time, 2, "picdata/privateHall/private_dot2.png")
	local pSlider2 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider2:registerControlEventHandler(handler(self,self.onTimeValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider2:setMaximumValue(#plus6_card_time-1)
	pSlider2:setMinimumValue(0)
	pSlider2:setValue(1)
	pSlider2:setPosition(pSlider:getPositionX(),
		label5:getPositionY()-45)
	self.secondStep6Plus:addChild(pSlider2, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider2:getPositionX(), pSlider2:getPositionY())
		:addTo(self.secondStep6Plus, 0)

	self.m_slider15 = pSlider
	self.m_slider16 = pSlider2

	self.m_sliderHint15 = cc.ui.UILabel.new({
		text = plus6_card_blind[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot15[1]:getPositionX()+100, self.sliderDot15[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot15[1]:getParent(), 1)

	self.m_sliderHint16 = cc.ui.UILabel.new({
		text = plus6_card_time[1].."",
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot16[1]:getPositionX()+100, self.sliderDot16[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot16[1]:getParent(), 1)
end

function CreateDebaoRoomDialog:initSecondStepSNG()
--------------------------------------------------------------------------------------------
	self.secondStepSNG = display.newNode()
	self.secondStepSNG:addTo(self.m_dialogBg)
	-- self.secondStepSNG:setPositionY(-120)

	-- local label6 = cc.ui.UILabel.new({
	-- 	text = "盲注级别",
	-- 	font = "fonts/FZZCHJW--GB1-0.TTF",
	-- 	size = 24,
	-- 	color = cc.c3b(135,154,192),
	-- 	align = cc.TEXT_ALIGNMENT_RIGHT
	-- 	})
	-- 	:align(display.RIGHT_CENTER, 140, self.title:getPositionY()-120)
	-- 	:addTo(self.secondStepSNG, 1)

	local label7 = cc.ui.UILabel.new({
		text = "起始筹码:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.cardLabel:getPositionX(), self.cardLabel:getPositionY()-120)
		:addTo(self.secondStepSNG, 1)

	local label8 = cc.ui.UILabel.new({
		text = "升盲时间:",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label7:getPositionX(), label7:getPositionY()-120)
		:addTo(self.secondStepSNG, 1)

	-- sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	-- sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	-- sprite3 = cc.Sprite:create("picdata/privateHall/private_blinds.png")
	-- self:addSliderDot(nil, sprite1, sliderWidth, startPos, 4, 2, "picdata/privateHall/private_dot.png")
	-- self:addSliderDot(self.sliderDot7, sprite2, sliderWidth, startPos, 4, 2, "picdata/privateHall/private_dot2.png")
	-- local pSlider3 = cc.ControlSlider:create(sprite1, 
	-- 	sprite2, sprite3)
	-- pSlider3:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	-- pSlider3:setMaximumValue(3)
	-- pSlider3:setMinimumValue(0)
	-- pSlider3:setValue(0)
	-- pSlider3:setPosition(label6:getPositionX()+30+self.m_slider1:getContentSize().width/2,
	-- 	label6:getPositionY())
	-- self.secondStepSNG:addChild(pSlider3, 1)

	sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	sprite3 = cc.Sprite:create("picdata/privateHall/private_chip.png")
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, 3, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot7, sprite2, sliderWidth, startPos, 3, 2, "picdata/privateHall/private_dot2.png")
	local pSlider4 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider4:registerControlEventHandler(handler(self,self.onStartChipValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider4:setMaximumValue(2)
	pSlider4:setMinimumValue(0)
	pSlider4:setValue(0)
	pSlider4:setPosition(label7:getPositionX()+8+pSlider4:getContentSize().width/2,
		label7:getPositionY()-45)
	self.secondStepSNG:addChild(pSlider4, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider4:getPositionX(), pSlider4:getPositionY())
		:addTo(self.secondStepSNG, 0)

	sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	sprite3 = cc.Sprite:create("picdata/privateHall/private_time.png")
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, 2, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot8, sprite2, sliderWidth, startPos, 2, 2, "picdata/privateHall/private_dot2.png")
	local pSlider5 = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider5:registerControlEventHandler(handler(self,self.onBlindTimeValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider5:setMaximumValue(1)
	pSlider5:setMinimumValue(0)
    -- pSlider5:setMinimumAllowedValue(20) --设置允许滑动的最小值
    -- pSlider5:setMaximumAllowedValue(80) --设置允许滑动的最大值
	pSlider5:setValue(0)
	pSlider5:setPosition(pSlider4:getPositionX(),
		label8:getPositionY()-45)
	self.secondStepSNG:addChild(pSlider5, 1)

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider5:getPositionX(), pSlider5:getPositionY())
		:addTo(self.secondStepSNG, 0)

 --    pSlider5:setTouchSwallowEnabled(false)
	-- pSlider5 = self
 --    pSlider5:setTouchEnabled(true)
 --    pSlider5:setTouchSwallowEnabled(true)
	-- pSlider5:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) 
	-- 	dump(event.name)
	-- 	end)

	    -- node : 执行回调的按钮对象
    -- type : 按钮事件的类型
    local function btnCallback(node, type)
    	-- print(type)
        -- if type == cc.CONTROL_EVENTTYPE_TOUCH_DOWN then
        --     print("touch down")
        -- elseif type == cc.CONTROL_EVENTTYPE_DRAG_INSIDE then
        --     print("drag inside")
        -- elseif type == cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE then
        --     print("touch up inside")
        -- end
    end
    -- 按钮事件回调
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_DRAG_INSIDE)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_DRAG_ENTER)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_DRAG_EXIT)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_TOUCH_UP_OUTSIDE)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_TOUCH_CANCEL)
    -- pSlider5:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
	--------------------------------------------------------------------------------------------
	self.m_slider7 = pSlider4
	self.m_slider8 = pSlider5

	self.m_sliderHint7 = cc.ui.UILabel.new({
		text = sng_start_chips[1],
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot7[1]:getPositionX()+100, self.sliderDot7[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot7[1]:getParent(), 1)

	self.m_sliderHint8 = cc.ui.UILabel.new({
		text = sng_card_time[1].."",
		font = "黑体",
		size = 28,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.sliderDot8[1]:getPositionX()+100, self.sliderDot8[1]:getPositionY()+hintDotGap-13)
		:addTo(self.sliderDot8[1]:getParent(), 1)
end

function CreateDebaoRoomDialog:updateTotalNumMTT(value)
	local mttTotalNum = mtt_total_num[value..""]
	if self.m_slider9 then
		self.m_slider9:removeFromParent(true)
		self.m_slider9 = nil
	end

    self.m_slider9 = require("app.GUI.dialogs.CreateDebaoRoomSlider").new({
        sliderDotNum = #mttTotalNum,
        sliderCurrentValue = 0,
        position = cc.p(self.cardLabel:getPositionX(),self.cardLabel:getPositionY()-120),
        sliderBtn = "picdata/privateHall/btn_player.png",
        hintTitle = {"总人数:"},
        hintValue = {mttTotalNum}
        })
    self.m_slider9:create()
    self.secondStepMTT:addChild(self.m_slider9, 1)

	self.currentSeatNum = value
end

function CreateDebaoRoomDialog:initSecondStepMTT()
	self.secondStepMTT = display.newNode()
	self.secondStepMTT:addTo(self.m_dialogBg)

	self:updateTotalNumMTT(2)

    self.m_slider10 = require("app.GUI.dialogs.CreateDebaoRoomSlider").new({
        sliderDotNum = 7,
        sliderCurrentValue = 0,
        position = cc.p(self.cardLabel:getPositionX(),self.cardLabel:getPositionY()-240),
        sliderBtn = "picdata/privateHall/private_chip.png",
        hintTitle = {"报名费:", "服务费:"},
        hintValue = {
            mtt_pay_money,
            {50,100,150,200,250,500,1000}
        }
        })
    self.m_slider10:create()
    self.secondStepMTT:addChild(self.m_slider10, 1)

	-- local label5 = cc.ui.UILabel.new({
	-- 	text = "报名费:",
	-- 	font = "fonts/FZZCHJW--GB1-0.TTF",
	-- 	size = 24,
	-- 	color = cc.c3b(135,154,192),
	-- 	align = cc.TEXT_ALIGNMENT_LEFT
	-- 	})
	-- 	:align(display.LEFT_CENTER, label4:getPositionX(), label4:getPositionY()-120)
	-- 	:addTo(self.secondStepMTT, 1)

	-- local label6 = cc.ui.UILabel.new({
	-- 	text = "服务费:",
	-- 	font = "fonts/FZZCHJW--GB1-0.TTF",
	-- 	size = 24,
	-- 	color = cc.c3b(135,154,192),
	-- 	align = cc.TEXT_ALIGNMENT_LEFT
	-- 	})
	-- 	:align(display.LEFT_CENTER, label5:getPositionX()+200, label5:getPositionY())
	-- 	:addTo(self.secondStepMTT, 1)

	-- local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	-- sliderWidth = tmpSprite:getContentSize().width

	-- local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	-- local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	-- local sprite3 = cc.Sprite:create("picdata/privateHall/btn_player.png")
	
	-- self:addSliderDot(nil, sprite1, sliderWidth, startPos, 4, 2, "picdata/privateHall/private_dot.png")
	-- self:addSliderDot(self.sliderDot9, sprite2, sliderWidth, startPos, 4, 2, "picdata/privateHall/private_dot2.png")

	-- local pSlider = cc.ControlSlider:create(sprite1, 
	-- 	sprite2, sprite3)
	-- pSlider:registerControlEventHandler(handler(self,self.onBlindValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	-- pSlider:setMaximumValue(3)
	-- pSlider:setMinimumValue(0)
	-- pSlider:setValue(0)
	-- pSlider:setPosition(label4:getPositionX()+8+pSlider:getContentSize().width/2,
	-- 	label4:getPositionY()-45)
	-- self.secondStepMTT:addChild(pSlider, 1)

	-- cc.ui.UIImage.new("picdata/privateHall/private_input.png")
	-- 	:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
	-- 	:addTo(self.secondStepMTT, 0)

	-- sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	-- sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	-- sprite3 = cc.Sprite:create("picdata/privateHall/private_chip.png")
	-- self:addSliderDot(nil, sprite1, sliderWidth, startPos, 3, 2, "picdata/privateHall/private_dot.png")
	-- self:addSliderDot(self.sliderDot10, sprite2, sliderWidth, startPos, 3, 2, "picdata/privateHall/private_dot2.png")
	-- local pSlider2 = cc.ControlSlider:create(sprite1, 
	-- 	sprite2, sprite3)
	-- pSlider2:registerControlEventHandler(handler(self,self.onTimeValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	-- pSlider2:setMaximumValue(2)
	-- pSlider2:setMinimumValue(0)
	-- pSlider2:setValue(0)
	-- pSlider2:setPosition(pSlider:getPositionX(),
	-- 	label5:getPositionY()-45)
	-- self.secondStepMTT:addChild(pSlider2, 1)

	-- cc.ui.UIImage.new("picdata/privateHall/private_input.png")
	-- 	:align(display.CENTER, pSlider2:getPositionX(), pSlider2:getPositionY())
	-- 	:addTo(self.secondStepMTT, 0)

	-- self.m_slider9 = pSlider
	-- self.m_slider10 = pSlider2

	-- self.m_sliderHint9 = cc.ui.UILabel.new({
	-- 	text = diy_card_blind[1],
	-- 	font = "黑体",
	-- 	size = 28,
	-- 	color = cc.c3b(0,255,225),
	-- 	align = cc.TEXT_ALIGNMENT_CENTER
	-- 	})
	-- 	:align(display.CENTER, self.sliderDot5[1]:getPositionX()+138, self.sliderDot5[1]:getPositionY()+hintDotGap-13)
	-- 	:addTo(self.sliderDot5[1]:getParent(), 1)

	-- self.m_sliderHint10 = cc.ui.UILabel.new({
	-- 	text = diy_card_time[1].."",
	-- 	font = "黑体",
	-- 	size = 28,
	-- 	color = cc.c3b(0,255,225),
	-- 	align = cc.TEXT_ALIGNMENT_CENTER
	-- 	})
	-- 	:align(display.CENTER, self.sliderDot6[1]:getPositionX()+140, self.sliderDot6[1]:getPositionY()+hintDotGap-13)
	-- 	:addTo(self.sliderDot6[1]:getParent(), 1)
end

function CreateDebaoRoomDialog:initThirdStepMTT()
	self.thirdStepMTT = display.newNode()
	self.thirdStepMTT:addTo(self.m_dialogBg)

	local tmpPos = cc.p(self.cardLabel:getPositionX(),self.cardLabel:getPositionY()+20)
	local tmpGapY = 110
    self.m_slider11 = require("app.GUI.dialogs.CreateDebaoRoomSlider").new({
        sliderDotNum = 3,
        sliderCurrentValue = 0,
        position = cc.p(tmpPos.x,tmpPos.y),
        sliderBtn = "picdata/privateHall/private_time.png",
        hintTitle = {"升盲时间:"},
        hintValue = {
            {"3分钟","5分钟",--[["8分钟",]]"10分钟"},
        }
        })
    self.m_slider11:create()
    self.thirdStepMTT:addChild(self.m_slider11, 1)

    self.m_slider12 = require("app.GUI.dialogs.CreateDebaoRoomSlider").new({
        sliderDotNum = 6,
        sliderCurrentValue = 0,
        position = cc.p(tmpPos.x,tmpPos.y-tmpGapY),
        sliderBtn = "picdata/privateHall/private_chip.png",
        hintTitle = {"起始筹码:"},
        hintValue = {
            mtt_start_chips
        }
        })
    self.m_slider12:create()
    self.thirdStepMTT:addChild(self.m_slider12, 1)
    
    self.m_slider13 = require("app.GUI.dialogs.CreateDebaoRoomSlider").new({
        sliderDotNum = 2,
        sliderCurrentValue = 0,
        position = cc.p(tmpPos.x,tmpPos.y-tmpGapY*2),
        sliderBtn = "picdata/privateHall/private_chip.png",
        hintTitle = {"是否重购:"},
        hintValue = {
            {"是","否"},
        },
        valueChangedCallback = function()
        	if self.m_slider13:getValue()==1 then 
        		self.m_slider14:setValue(1)
        	end
        end,
        })
    self.m_slider13:create()
    self.thirdStepMTT:addChild(self.m_slider13, 1)
    
    self.m_slider14 = require("app.GUI.dialogs.CreateDebaoRoomSlider").new({
        sliderDotNum = 2,
        sliderCurrentValue = 0,
        position = cc.p(tmpPos.x,tmpPos.y-tmpGapY*3),
        sliderBtn = "picdata/privateHall/private_chip.png",
        hintTitle = {"是否加码:"},
        hintValue = {
            {"是","否"},
        }
        })
    self.m_slider14:create()
    self.thirdStepMTT:addChild(self.m_slider14, 1)
end

function CreateDebaoRoomDialog:initFinalStep()
	self.finalStep = display.newNode()
	self.finalStep:addTo(self.m_dialogBg)

	local successImagePosX = 240
	local successImagePosY= bgHeight-130
	local successImage1 = cc.ui.UIImage.new("picdata/privateHall/private_success.png")
	successImage1:align(display.RIGHT_CENTER, successImagePosX, successImagePosY)
		:addTo(self.finalStep)

	local successImage2 = cc.ui.UIImage.new("picdata/privateHall/private_hint.png")
	successImage2:align(display.LEFT_CENTER, successImagePosX+20, successImagePosY)
		:addTo(self.finalStep)

	local passwordPosX = 140
	local passwordPosY = bgHeight/2
	cc.ui.UILabel.new({
		text = "牌局密码",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 26,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, passwordPosX, passwordPosY+3)
		:addTo(self.finalStep)

    self.passwordTextField = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 8,
        -- minLength = 6,
        place     = "最多输入8位数字或字母",
        color     = cc.c3b(255, 255, 255),
        fontSize  = 24,
        size = cc.size(556,32),
        bgPath    = "picdata/privateHall/private_input.png",
        -- inputFlag = 0
    })
    self.passwordTextField:setPosition(passwordPosX+285,passwordPosY)
    self.passwordTextField:setAnchorPoint(cc.p(0,0.5))
    self.finalStep:addChild(self.passwordTextField)



	self.cancelPasswordButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_1_156_green.png", 
		pressed="picdata/public/btn_1_156_green2.png", 
		disabled="picdata/public/btn_1_156_green2.png"})
	self.cancelPasswordButton:align(display.CENTER, bgWidth/2-120, self.confirmButton:getPositionY())
		-- :addTo(self.m_dialogBg, 1)
		:onButtonClicked(function(event)
			self:pressCancelPassword(event)
			end)
		:setTouchSwallowEnabled(false)
	self.cancelPasswordButton:setButtonLabel("normal", cc.ui.UILabel.new({
		text = "不设密码",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255)
		}))

	self.setPasswordButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_1_156_green.png", 
		pressed="picdata/public/btn_1_156_green.png", 
		disabled="picdata/public/btn_1_156_green.png"})
	-- self.setPasswordButton:align(display.CENTER, bgWidth/2+120, self.confirmButton:getPositionY())
	self.setPasswordButton:align(display.CENTER, self.confirmButton:getPositionX(), self.confirmButton:getPositionY())
		:addTo(self.m_dialogBg, 1)
		:onButtonClicked(function(event)
			self:pressSetPassword(event)
			end)
		:setTouchSwallowEnabled(false)
	self.setPasswordButton:setButtonLabel("normal", cc.ui.UILabel.new({
		text = "设置密码",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255)
		}))
end

function CreateDebaoRoomDialog:initCardButtons(tableWidth, tableHeight)
	self.currentCardButton = nil
	local colorNormal = cc.c3b(135,154,192)
	local colorSelected = cc.c3b(255,255,255)
	local colorNotHave = cc.c3b(31,34,41)
	local size = cc.size(556,62)
	for i=1,#card_name do
		dump(self.cardNum[i])
		local buttonTitle = card_name[i]..string_value1..self.cardNum[i]..string_value2
		local button = nil
		if self.cardNum[i]<1 then
			-- button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_x.png", 
			-- 	pressed="picdata/privateHall/bg_x.png", 
			-- 	disabled="picdata/privateHall/bg_x.png"})
			if i==#card_name then
				button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_xl_foot.png", 
					pressed="picdata/privateHall/bg_xl_foot.png", 
					disabled="picdata/privateHall/bg_xl_foot.png"},{scale9=true})
			else
				button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_xl_one.png", 
					pressed="picdata/privateHall/bg_xl_one.png", 
					disabled="picdata/privateHall/bg_xl_one.png"},{scale9=true})
			end
		else
			-- if i==#card_name then
			-- 	button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_x.png", 
			-- 		pressed="picdata/privateHall/private_xz2.png", 
			-- 		disabled="picdata/privateHall/private_xz2.png"})
			-- else
			-- 	button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_x.png", 
			-- 		pressed="picdata/privateHall/private_xz.png", 
			-- 		disabled="picdata/privateHall/private_xz.png"})
			-- end
			if i==#card_name then
				button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_xl_foot.png", 
					pressed="picdata/privateHall/bg_xl_foot2.png", 
					disabled="picdata/privateHall/bg_xl_foot2.png"},{scale9=true})
			else
				button = cc.ui.UIPushButton.new({normal="picdata/privateHall/bg_xl_one.png", 
					pressed="picdata/privateHall/bg_xl_one2.png", 
					disabled="picdata/privateHall/bg_xl_one2.png"},{scale9=true})
			end
		end

		button:setButtonSize(size.width,size.height)
		button:setTouchSwallowEnabled(true)

		local tmpColorN = colorNormal
		local tmpColorS = colorSelected

		if self.cardNum[i]>0 and self.currentCardButton == nil then
			self.currentCardButton = button
			button:setButtonEnabled(false)
			self.cardTypeLabel:setString(card_name[i])
			self.hintLabel:setString(room_hint[i])

			if i==4 or i==5 then
				self:showSeatButtons({false,true,true})
			end
		end
		
		--[[禁用SNG选项卡]]
		if self.cardNum[i]<1 or (NEED_SNG==false and i==4) or (NEED_PRI_MTT==false and i==5) then
			tmpColorN = colorNotHave
			tmpColorS = colorNotHave
			button:setButtonEnabled(false)
		end

		button:setTag(i)
		button:align(display.CENTER, tableWidth/2, tableHeight/4*(4-i)+18+tableHeight/8)
			:addTo(self.firstStepBG, 1)
			:onButtonClicked(function(event)
				self:pressCardButton(event)
			end)
		local normalLabel = cc.ui.UILabel.new({
			text = buttonTitle,
			font = "黑体",
			size = 28,
			color = tmpColorN,
			align = cc.TEXT_ALIGNMENT_LEFT
			}):align(display.LEFT_CENTER, 0, 0)
		local pressedLabel = cc.ui.UILabel.new({
			text = buttonTitle,
			font = "黑体",
			size = 28,
			color = tmpColorS,
			align = cc.TEXT_ALIGNMENT_LEFT
			}):align(display.LEFT_CENTER, 0, 0)
		local disabledLabel = cc.ui.UILabel.new({
			text = buttonTitle,
			font = "黑体",
			size = 28,
			color = tmpColorS,
			align = cc.TEXT_ALIGNMENT_LEFT
			}):align(display.LEFT_CENTER, 0, 0)
		button:setButtonLabel("normal", normalLabel)
		button:setButtonLabel("pressed", pressedLabel)
		button:setButtonLabel("disabled", disabledLabel)
		button:setButtonLabelOffset(-256, 0)
        button:setButtonLabelAlignment(display.LEFT_CENTER)
		-- if i~=4 then
		-- 	local line = cc.ui.UIImage.new("picdata/privateHall/private_line3.png")
		-- 	line:align(display.CENTER, tableWidth/2, tableHeight/4*(4-i)+18)
		-- 		:addTo(self.firstStepBG)
		-- 	line:setScaleX(55)
		-- end
		self.cardButtons[i] = button
	end
	self.currentCardButton:setButtonEnabled(false)
end

function CreateDebaoRoomDialog:initCardChoosingTable(tableWidth, tableHeight)
	self.tableView = cc.ui.UIListView.new{
		viewRect = cc.rect(0,18,tableWidth,tableHeight),
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		-- :onTouch(handler(self, self.touchListener))
		:addTo(self.firstStepBG)
	self:initTableCells(tableWidth,tableHeight)
end

function CreateDebaoRoomDialog:initTableCells(tableWidth,tableHeight)
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}

	for i=1,4 do
		local item = self.tableView:newItem()
		
		local content = display.newNode()
		-- if i==4 then
		-- 	local bg = cc.ui.UIImage.new("picdata/privateHall/private_xz2.png")
		-- 	bg:align(display.CENTER, 0, 0)
		-- 	:addTo(content)
		-- else
		-- 	local bg = cc.ui.UIImage.new("picdata/privateHall/private_xz.png")
		-- 	bg:align(display.CENTER, 0, 0)
		-- 	:addTo(content)
		-- end

		if i~=4 then
			local line = cc.ui.UIImage.new("picdata/privateHall/private_line3.png")
			line:align(display.CENTER, 0, -tableHeight/8)
				:addTo(content)
			line:setScaleX(55)
		end

		item:addContent(content)
		item:setItemSize(tableWidth, tableHeight/4)
		
		self.tableView:addItem(item)
	end
	self.tableView:setTouchEnabled(false)
	self.tableView:reload()
end

function CreateDebaoRoomDialog:randomRoomName()
	local num = #debao_private_room_name
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
 	local index = math.random(1, num)
 	while index==self.lastRoomNameIndex do
 		index = math.random(1, num)
 	end
 	self.lastRoomNameIndex = index
 	self.roomNameLabel:setString(debao_private_room_name[index])
 	self.roomNameInput:setText(debao_private_room_name[index])
 	return debao_private_room_name[index]
end 

function CreateDebaoRoomDialog:onExit()

end

function CreateDebaoRoomDialog:onEnter()
	
end

function CreateDebaoRoomDialog:pressBack(event)
	CMClose(self, true)
	local event = cc.EventCustom:new("ShowPrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function CreateDebaoRoomDialog:pressSeatButton1(event)
	self.selectedSeatButton:setButtonEnabled(true)
	self.selectedSeatButton = self.seatbutton1
	self.selectedSeatButton:setButtonEnabled(false)
end

function CreateDebaoRoomDialog:pressSeatButton2(event)
	self.selectedSeatButton:setButtonEnabled(true)
	self.selectedSeatButton = self.seatbutton2
	self.selectedSeatButton:setButtonEnabled(false)
end

function CreateDebaoRoomDialog:pressSeatButton3(event)
	self.selectedSeatButton:setButtonEnabled(true)
	self.selectedSeatButton = self.seatbutton3
	self.selectedSeatButton:setButtonEnabled(false)
end

function CreateDebaoRoomDialog:pressCardButton(event)
	local button = event.target
	self.currentCardButton:setButtonEnabled(true)
	self.currentCardButton = button
	self.currentCardButton:setButtonEnabled(false)

	self.cardTypeLabel:setString(card_name[button:getTag()])
	self.hintLabel:setString(room_hint[button:getTag()])
	self:pressSelectCardButton()

	if button:getTag()==4 or button:getTag()==5 then
		self:showSeatButtons({false,true,true})
	else
		self:showSeatButtons({true,true,true})
	end
end

function CreateDebaoRoomDialog:pressSelectCardButton(event)
	if self.firstStepBG:isVisible() then
		self.firstStepBG:setVisible(false)
		self.roomNameInput:setVisible(true)
    	self.passwordTextField:setVisible(true)
    	self.confirmButton:setVisible(true)
	else
		self.firstStepBG:setVisible(true)
		self.roomNameInput:setVisible(false)
    	self.passwordTextField:setVisible(false)
    	self.confirmButton:setVisible(false)
	end
end

function CreateDebaoRoomDialog:pressFront(event)
	self.currentStep = self.currentStep-1
    self.confirmButton:setButtonLabel("normal", cc.ui.UILabel.new({
		text = "下一步",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255)
		}))
	self:setThirdStepMTTVisible(false)

	if self.currentStep == 1 then
	    self.confirmButton1:setVisible(false)
	    self.confirmButton:setPositionX(bgWidth/2)
		self.firstStep:setVisible(true)
		self.roomNameInput:setVisible(true)
	    self.passwordTextField:setVisible(true)

		self:setSeatButtonVisible(false)
		self:setSecondStepVisible(false)
		self:setSecondStepFreeVisible(false)
		self:setSecondStepDiyVisible(false)
		self:setSecondStep6PlusVisible(false)
		self:setSecondStepSNGVisible(false)
		self:setSecondStepMTTVisible(false)
	elseif self.currentStep == 2 then
		self:setSeatButtonVisible(true)
		self:setSecondStepMTTVisible(true)
	end
end

function CreateDebaoRoomDialog:pressNext(event)
	
	if self.currentStep == 1 then

		local passStr = self.passwordTextField:getText()
		if passStr=="" then
			local text = "密码不能为空"
			local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = true})
 			CMOpen(CMToolTipView,self)
			return
		end
    	self.confirmButton1:setVisible(true)
    	self.confirmButton:setPositionX(bgWidth/2+confirmButtonGap)
		local index = self.currentCardButton:getTag()
		self:goToSecond(index)
	elseif self.currentStep == 2 then
		self.firstStep:setVisible(false)
		self:setSecondStepVisible(false)
		self:setSecondStepFreeVisible(false)
		self:setSecondStepDiyVisible(false)
		self:setSecondStep6PlusVisible(false)
		self:setSecondStepSNGVisible(false)
		self:setSecondStepMTTVisible(false)
		self:setSeatButtonVisible(false)

		if self.currentCardButton and self.currentCardButton:getTag() ~= 5 then
			self:pressSetPassword()
			CMClose(self, false)
			CMOpen(require("app.GUI.dialogs.CreateRoomResult"), cc.Director:getInstance():getRunningScene(), 0, true)
			return
		else
			self:setThirdStepMTTVisible(true)
	    	self.confirmButton:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "现在开局",
			font = "黑体",
			size = 26,
			color = cc.c3b(255,255,255)
			}))
		end
	elseif self.currentStep == 3 then
		self:pressSetPassword()
		CMClose(self, false)
		CMOpen(require("app.GUI.dialogs.CreateRoomResult"), cc.Director:getInstance():getRunningScene(), 0, true)
		return
	end
	self.currentStep = self.currentStep+1
end

function CreateDebaoRoomDialog:goToSecond(index)
	self.firstStep:setVisible(false)
	self.roomNameInput:setVisible(false)
    self.passwordTextField:setVisible(false)
	self:setSeatButtonVisible(true)
	if index~=5 then
	    self.confirmButton:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "现在开局",
			font = "黑体",
			size = 26,
			color = cc.c3b(255,255,255)
			}))
	end

	if index == 1 then
		self:setSecondStepVisible(true)
	elseif index == 2 then
		self:setSecondStepFreeVisible(true)
	elseif index == 3 then
		self:setSecondStepDiyVisible(true)
	elseif index == 4 then
		self:setSecondStepSNGVisible(true)
	elseif index == 5 then
		self:setSecondStepMTTVisible(true)
	elseif index == 6 then
		self:setSecondStep6PlusVisible(true)
	end
end

function CreateDebaoRoomDialog:setSeatButtonVisible(isVisible)
	self.seatButtons:setVisible(isVisible)
	if isVisible then
		self.m_seatSlider:setEnabled(self.m_showSeatSlider)
		self.m_seatSlider2:setEnabled(self.m_showSeatSlider2)
		if self.m_showSeatSlider == true then
			self.currentSeatNum = seat_num[self.m_seatSlider:getValue()+1]
		else
			self.currentSeatNum = seat_num[self.m_seatSlider2:getValue()+2]
		end
	else
		self.m_seatSlider:setEnabled(isVisible)
		self.m_seatSlider2:setEnabled(isVisible)
	end
end

function CreateDebaoRoomDialog:setSecondStepVisible(isVisible)
	self.secondStep:setVisible(isVisible)
	self.m_slider1:setEnabled(isVisible)
	self.m_slider2:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setSecondStepFreeVisible(isVisible)
	self.secondStepFree:setVisible(isVisible)
	self.m_slider3:setEnabled(isVisible)
	self.m_slider4:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setSecondStepDiyVisible(isVisible)
	self.secondStepDiy:setVisible(isVisible)
	self.m_slider5:setEnabled(isVisible)
	self.m_slider6:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setSecondStep6PlusVisible(isVisible)
	self.secondStep6Plus:setVisible(isVisible)
	self.m_slider15:setEnabled(isVisible)
	self.m_slider16:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setSecondStepSNGVisible(isVisible)
	self.secondStepSNG:setVisible(isVisible)
	self.m_slider7:setEnabled(isVisible)
	self.m_slider8:setEnabled(isVisible)
	-- self.m_slider9:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setSecondStepMTTVisible(isVisible)
	self.secondStepMTT:setVisible(isVisible)
	self.m_slider9:setEnabled(isVisible)
	self.m_slider10:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setThirdStepMTTVisible(isVisible)
	self.thirdStepMTT:setVisible(isVisible)
	self.m_slider11:setEnabled(isVisible)
	self.m_slider12:setEnabled(isVisible)
	self.m_slider13:setEnabled(isVisible)
	self.m_slider14:setEnabled(isVisible)
end

function CreateDebaoRoomDialog:setFinalStepVisible(isVisible)
	self.finalStep:setVisible(isVisible)
	-- self.cancelPasswordButton:setVisible(isVisible)
	self.setPasswordButton:setVisible(isVisible)
	self.passwordTextField:setVisible(isVisible)
	self.title:setVisible(not isVisible)
	self.confirmButton:setVisible(not isVisible)
end

function CreateDebaoRoomDialog:pressCancelPassword(event)
	self:createPrivateRoom("")
end

function CreateDebaoRoomDialog:pressSetPassword(event)
	local passStr = self.passwordTextField:getText()
	if passStr=="" then
		local text = "密码不能为空"
		local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = true})
 		CMOpen(CMToolTipView,self)
		return
	end
	self:createPrivateRoom(self.passwordTextField:getText())
end

function CreateDebaoRoomDialog:createPrivateRoom(password)
	local params = {}
	local cardType = self.currentCardButton:getTag()
	params.cardType = cardType
    params.roomName = self.roomNameInput:getText()
    params.password = password

	if self.m_showSeatSlider == true then
		params.seatNum = seat_num[self.m_seatSlider:getValue()+1]
	else
		params.seatNum = seat_num[self.m_seatSlider2:getValue()+2]
	end
	if cardType == 1 then
		params.blind = self.m_sliderHint1:getString()
		params.upseconds = room_time[1][self.m_slider2:getValue()+1]
	elseif cardType == 2 then
		params.blind = self.m_sliderHint3:getString()
		params.upseconds = room_time[2][self.m_slider4:getValue()+1]
	elseif cardType == 3 then
		params.blind = self.m_sliderHint5:getString()
		params.upseconds = room_time[3][self.m_slider6:getValue()+1]
	elseif cardType == 4 then
		params.startChips = self.m_sliderHint7:getString() 
		params.upseconds = room_time[4][self.m_slider8:getValue()+1]
	elseif cardType == 5 then
		params.startChips = mtt_start_chips[self.m_slider12:getValue()+1] 
		params.upseconds = room_time[5][self.m_slider11:getValue()+1]
		params.totalNum = mtt_total_num[params.seatNum..""][self.m_slider9:getValue()+1]
		params.payMoney = mtt_pay_money[self.m_slider10:getValue()+1]
		params.isRebuy = self.m_slider13:getValue()==0 and "YES" or "NO"
		params.isAddon = self.m_slider14:getValue()==0 and "YES" or "NO"
	elseif cardType == 6 then
		params.blind = self.m_sliderHint15:getString()
		params.upseconds = room_time[3][self.m_slider16:getValue()+1]
	end
	self.m_logic:createPrivateRoom(params)
end

return CreateDebaoRoomDialog