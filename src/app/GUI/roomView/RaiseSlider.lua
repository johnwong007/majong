
SLIDER_ADD_BUTTON_UP ="picdata/table/add.png"--加注按钮常态
SLIDER_ADD_BUTTON_DOWN ="picdata/table/add1.png"--加注按钮按下
SLIDER_SUB_BUTTON_UP ="picdata/table/sub.png"--减少按钮常态
SLIDER_SUB_BUTTON_DOWN ="picdata/table/sub1.png"--减少按钮按下

SLIDER_THUMB_ICON ="picdata/table/thumbBtn.png"--滑动条thumb
SLIDER_NOT_PROGRESSED ="picdata/table/sliderProgress.png"--滑动条已完成进度
SLIDER_PROGRESSED ="picdata/table/sliderProgressed.png"--滑动条未完成进度
SLIDER_BACKGROUND ="picdata/table/progBack.png"--控件背景
SLIDER_PROGRESS_BACK ="picdata/table/sliderBG.png"--滑动背景
SLIDER_VALUE_BG ="picdata/table/sliderValueBG.png"--滑动条数值显示背景

require("app.Tools.StringFormat")
local MusicPlayer = require("app.Tools.MusicPlayer")

local RaiseSlider = class("RaiseSlider", function()
		return display.newLayer()
	end)

function RaiseSlider:create(operateBoard)
	local p = RaiseSlider:new()
	p.m_operateBoard = operateBoard
	return p
end

function RaiseSlider:ctor()
	self.m_operateBoard = nil
	self.m_max = 100
	self.m_min = 0
	self.m_moveValue = 0
	local pBackground = cc.ui.UIImage.new(SLIDER_BACKGROUND)
	local size = pBackground:getContentSize()
	pBackground:align(display.RIGHT_BOTTOM,display.width-10,60)
		:addTo(self)

    local barHeight = 360
    local barWidth = 64
    local barPosX = size.width/2+40
	local node = display.newNode()
	node:addTo(pBackground)
	node:setPosition(barPosX,size.height/2-40)
	local progressBg = cc.ui.UIImage.new(SLIDER_PROGRESS_BACK)
	progressBg:addTo(node)
		:align(display.CENTER,0,0)
		-- :align(display.CENTER,barPosX,size.height/2)

	-- local SLIDER_IMAGES = {bar = SLIDER_PROGRESSED, button = SLIDER_THUMB_ICON}
	-- self.m_slider = cc.ui.UISlider.new(display.BOTTOM_TO_TOP, SLIDER_IMAGES)
	-- self.m_slider:onSliderValueChanged(handler(self, self.onValueChanged))
	-- :setSliderSize(barWidth, barHeight)
	-- :setSliderValue(0)
	-- :align(display.CENTER,barPosX,size.height/2)
	-- :addTo(pBackground, 1)

	-- local backgroundSprite = cc.ui.UIImage.new(SLIDER_NOT_PROGRESSED)
	-- :align(display.CENTER,barPosX,size.height/2)
	-- backgroundSprite:addTo(pBackground)
	-- local backgroundSprite1 = cc.ui.UIImage.new(SLIDER_PROGRESSED)
	-- :align(display.CENTER,barPosX,size.height/2)
	-- backgroundSprite1:addTo(pBackground)
	-- self.m_sliderProgressSize = backgroundSprite:getContentSize()


	local pSlider = cc.ControlSlider:create(SLIDER_NOT_PROGRESSED, SLIDER_PROGRESSED, SLIDER_THUMB_ICON)
	pSlider:registerControlEventHandler(handler(self,self.onValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(100)
	pSlider:setMinimumValue(0)
	pSlider:setValue(0)
	-- pSlider:setPosition(barPosX,size.height/2)
	-- pSlider:setEnabled(false)
	pSlider:setPosition(0,0)
	node:addChild(pSlider, 1)

	local sprite = cc.ui.UIImage.new(SLIDER_NOT_PROGRESSED)
	self.m_sliderProgressSize = sprite:getContentSize()

	self.m_slider = pSlider

	node:setRotation(-90)
	
	local subPosX = barPosX
	local subPosY = 75-40
	local addPosY = size.height-subPosY-80
	--[[add ,sub button]]
	self.m_pSub = cc.ui.UIPushButton.new({normal=SLIDER_SUB_BUTTON_UP,pressed=SLIDER_SUB_BUTTON_DOWN,disabled=SLIDER_SUB_BUTTON_DOWN})
	self.m_pSub:align(display.CENTER,subPosX, subPosY)
		:addTo(pBackground)
		:onButtonClicked(handler(self, self.onClickSub))
		:setTouchSwallowEnabled(false)

	self.m_pAdd = cc.ui.UIPushButton.new({normal=SLIDER_ADD_BUTTON_UP,pressed=SLIDER_ADD_BUTTON_DOWN,disabled=SLIDER_ADD_BUTTON_DOWN})
	self.m_pAdd:align(display.CENTER,subPosX,addPosY)
		:addTo(pBackground)
		:onButtonClicked(handler(self, self.onClickAdd))
		:setTouchSwallowEnabled(false)

	--[[slider value]]
	self.m_sliderValueBg = cc.ui.UIImage.new(SLIDER_VALUE_BG)
	self.m_sliderValueBg:align(display.CENTER_BOTTOM,size.width/2-self.m_sliderProgressSize.width/2,
		size.height/2+self.m_sliderProgressSize.height/2+12)
		:addTo(pBackground)
	self.m_sliderValueLabel = cc.ui.UILabel.new({
		text = "2323",
		font = "黑体",
		size = 30,
		align = cc.ui.TEXT_ALIGNMENT_CENTER,
		color = cc.c3b(255,255,255)
		})
	self.m_sliderValueLabel:align(display.CENTER,self.m_sliderValueBg:getContentSize().width/2,
		self.m_sliderValueBg:getContentSize().height/2+9)
		:addTo(self.m_sliderValueBg)
	self.m_sliderValueBg:setVisible(false)

	-- 允许 node 接受触摸事件
    self:setTouchEnabled(true)

    self.m_bSoundEnabled = true
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
    		self.m_bSoundEnabled = true
        	return self:ccTouchBegan(event)
    	elseif event.name == "ended" then
    		self.m_bSoundEnabled = false
    	end
	end)
end

function RaiseSlider:ccTouchBegan(event)
    local pos  = cc.p(event.x, event.y)
    local rect = cc.rect(display.width-240, 0, 240, display.height)
    if not cc.rectContainsPoint(rect, pos) then
       self.m_operateBoard:switchType(self.m_operateBoard.m_eCurrent)
    end
    return false
end

function RaiseSlider:onValueChanged(event)
	if self.m_bSoundEnabled then
    	self.m_bSoundEnabled = false
		MusicPlayer:getInstance():playBetSliderBeepSound()
		transition.execute(self, cc.DelayTime:create(0.45), {
			    onComplete = function()
    				self.m_bSoundEnabled = true
			    end,
			})
	end
	self.m_currentValue = self.m_min+ (self.m_max-self.m_min)/100*event:getValue()
	-- self.m_currentValue = StringFormat:FormatDecimals(self.m_currentValue)+0.0
	if event:getValue()>99.5 then
		self.m_sliderValueLabel:setString("全下")
		self.m_currentValue = self.m_max
	end
	if self.m_callback then
		self.m_callback(self)
	end
end

function RaiseSlider:onClickSub(pSender)
	-- if not self.m_slider:isTouchEnabled() then
	-- 	return
	-- end

	local fCurLocation = self.m_slider:getValue()
	fCurLocation = fCurLocation-1
	if fCurLocation<0 then
		fCurLocation = 0
	end
	self.m_slider:setValue(fCurLocation)
end

function RaiseSlider:onClickAdd(pSender)
	-- if not self.m_slider:isTouchEnabled() then
	-- 	return
	-- end

	local fCurLocation = self.m_slider:getValue()
	fCurLocation = fCurLocation+1
	if fCurLocation>100 then
		fCurLocation = 100
	end
	self.m_slider:setValue(fCurLocation)
end

function RaiseSlider:setCallback(target, callback)
	self.m_bHasCallback = true
	self.m_target       = target
	self.m_callback     = callback
end

function RaiseSlider:setMinimumValue(min)
	self.m_min = min
end

function RaiseSlider:setMaximumValue(max)
	self.m_max = max
end

function RaiseSlider:getMinimumValue()
	return self.m_min
end

function RaiseSlider:getMaximumValue()
	return self.m_max
end

function RaiseSlider:setMoveValue(moveValue)
	self.m_moveValue = moveValue
end

function RaiseSlider:setValue(value)
	if self.m_moveValue ~= 0 then
	end
	self.m_currentValue = value
end

function RaiseSlider:getValue()
    local tmp = self.m_currentValue/self.m_moveValue
    tmp = math.floor(tmp)
    if self.m_currentValue%self.m_moveValue>self.m_moveValue/2 then
    	tmp = tmp+1
    end
    local ret = self.m_moveValue*tmp
    if ret>self.m_max then
    	ret = self.m_max
    end
	return ret
end

function RaiseSlider:setChangeAsValue()
	local tmpValue = self.m_currentValue*100/(self.m_max-self.m_min)
	if tmpValue > 100 then
		tmpValue = 100
	elseif tmpValue < 0 then
		tmpValue = 0
	end	
	self.m_slider:setValue(tmpValue)
end

function RaiseSlider:setEnabled(enabled)
	self:setVisible(enabled)
	self.m_slider:setEnabled(enabled)
end

return RaiseSlider