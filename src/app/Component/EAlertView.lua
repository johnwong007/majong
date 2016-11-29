local DialogBase = require("app.GUI.roomView.DialogBase")
local EAlertView = class("EAlertView", function(event)
        return DialogBase:new()
    end)
function EAlertView:create()

end

function EAlertView:alertViewForProfitInfo(parent, delegate, layer, cancelButton, ...)
    local view = EAlertView:new()
    local args = {...}
    if args==nil then
        args = {}
    end
    table.insert(args, 1, cancelButton)
    -- view:initWithButton(parent, delegate, title, message, args)
    CMOpen(view, parent,0,1,MAX_ZORDER+1)
    view.m_layer.m_delegate = delegate
    view:addChild(layer)
    return view
end

function EAlertView:alertView(parent, delegate, title, message, cancelButton, ...)
	local view = EAlertView:new()
	local args = {...}
    if args==nil then
        args = {}
    end
	-- args[#args+1] = cancelButton
    table.insert(args, 1, cancelButton)
	view:initWithButton(parent, delegate, title, message, args)
	return view
end

function EAlertView:ctor()
    local CMMaskLayer = CMMask.new()
    self:addChild(CMMaskLayer)

	self.m_layer = require("app.Component.AlertView"):new()
	self.m_layer:addTo(self)
	self.m_layer:setDialogBaseCallBack(self)
end

function EAlertView:setCloseCallback(callback)
    self.m_layer.m_callback = callback
end

function EAlertView:initWithButton(parent, delegate, title, message, buttonStrings)
    if not parent then
        CMOpen(self, GameSceneManager:getCurScene(),0,0,MAX_ZORDER+1)
    else
        CMOpen(self, parent,0,0,MAX_ZORDER+1)
    end
    self.m_layer.m_delegate = delegate
	self.m_layer.titleLabel:setString(title)
    self.m_layer.hintLabel:setDimensions(400, 300)
	self.m_layer.hintLabel:setString(message)
	self.m_layer.hintLabel.fontSize = 30
    self.m_layer.titleLabel:setVisible(false)
    self.m_layer.hintLabel:setVisible(false)

    local bgWidth = 656
    local bgHeight = 352

    local title = cc.ui.UILabel.new({
        color = cc.c3b(255, 228, 173),
        text  = title,
        size  = 32,
        font  = "font/FZZCHJW--GB1-0.TTF",
        -- align = display.CENTER
       -- UILabelType = 1,
    }):align(display.CENTER, 0, 0)
    title:setPosition(cc.p(bgWidth/2, bgHeight-40))
    self.m_layer.titleLabel:getParent():addChild(title)

    
    local hint = cc.ui.UILabel.new({
        color = cc.c3b(255,255,255),
        text  = message,
        size  = 28,
        dimensions = cc.size(600, 0),
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.TEXT_ALIGNMENT_UP
    }):align(display.LEFT_TOP, 0, 0)
    hint:setPosition(cc.p(32, bgHeight-110))
    self.m_layer.hintLabel:getParent():addChild(hint)


	self.m_buttonStrings = buttonStrings

	self.m_layer.button:setVisible(true)
	self.m_layer.buttonLabel:setVisible(true)
	--[[提示框，警告框，按钮初始化]]
	self:initButtons()
end

function EAlertView:initButtons()
	self.m_layer.button:setVisible(false)
	self.m_layer.buttonLabel:setVisible(false)
	local buttonNum = #self.m_buttonStrings
	local buttonGap = 50
	local centerPosX = self.m_layer.buttonCenter:getPositionX()
	local centerPosY = self.m_layer.buttonCenter:getPositionY()
	local buttonWidth = 234
	local PUSH_BUTTON_IMAGES = {
    normal = "confirmBtn.png",
    pressed = "confirmBtn.png",
    disabled = "confirmBtn.png",}

    local buttonStartPosX = centerPosX
    if buttonNum==1 then
    elseif buttonNum==2 then
    	buttonStartPosX = buttonStartPosX-buttonWidth/2-buttonGap/2
    elseif buttonNum==3 then
    	buttonStartPosX = buttonStartPosX-buttonWidth-buttonGap
    else
    	if buttonNum%2==1 then
    		buttonStartPosX = buttonStartPosX-(buttonNum-1)/2*(buttonWidth+buttonGap)
    	else
    		buttonStartPosX = buttonStartPosX-buttonWidth/2-buttonGap/2
    		buttonStartPosX = buttonStartPosX-(buttonNum-2)*(buttonWidth+buttonGap)
    	end
    end

    for i=1,buttonNum do
		local button = cc.ui.UIPushButton.new(PUSH_BUTTON_IMAGES)
			:setButtonSize(234,74)
        	:align(display.CENTER, buttonStartPosX+(buttonWidth+buttonGap)*(i-1), centerPosY)
            :addTo(self.m_layer.buttonCenter:getParent())
        button:setTouchSwallowEnabled(true)
        button:setTag(i-1)
        if i~=1 then
            button:onButtonClicked(function(event) 
                if self.m_callback then
                    self.m_callback()
                end
                self.m_layer.m_delegate:clickButtonAtIndex(self, event.target:getTag()) 
                CMClose(self)
            end)
        else
            button:onButtonClicked(function(event) 
                if self.m_callback then
                    self.m_callback()
                end
                self.m_layer.m_delegate:clickButtonAtIndex(self, event.target:getTag()) 
                CMClose(self)
            end)
        end
    	cc.ui.UILabel.new({
    		text = self.m_buttonStrings[i],
    		size = LABELFONTSIZE,
    		color = LABELCOLOR,
    		dimensions = LABELSIZE,
    		align = cc.ui.TEXT_ALIGN_CENTER
            })
    		:addTo(self.m_layer.buttonCenter:getParent())
        	:align(display.CENTER, buttonStartPosX+(buttonWidth+buttonGap)*(i-1), centerPosY)
    end
end

return EAlertView