--
-- Author: wangj
-- Date: 2016-84-17 17:56:28
--
local CMTextButton = class("CMTextButton", function()
    return display.newNode()
end)

function CMTextButton:ctor(o,params)
	self.params = params or {}
	self.m_pText = self.params.text
	self.m_pCallback = self.params.callback
    self.m_pTextColorN = self.params.textColorN or cc.c3b(255,255,255)
    self.m_pTextColorS = self.params.textColorS or cc.c3b(0,255,255)
    self.m_pIncreaseValidRect = self.params.increaseValidRect or 40
	self:initUI()
end

function CMTextButton:initUI()
    self.m_pTextButton = cc.ui.UILabel.new({
        text  = self.m_pText,
        size  = 30,
        color = self.m_pTextColorN,
        align = cc.ui.TEXT_ALIGN_CENTER,
        font  = "FZZCHJW--GB1-0",
    })
    self.m_pTextButton:align(display.CENTER, 0,	0)
    self:addChild(self.m_pTextButton)
    self.m_pTextButton:setScale(0.9)
    self.m_pTextButton:setTouchEnabled(true)
    self.m_pValidRect = cc.rect(-self.m_pIncreaseValidRect,-self.m_pIncreaseValidRect,
        self.m_pTextButton:getContentSize().width+2*self.m_pIncreaseValidRect,
        self.m_pTextButton:getContentSize().height+2*self.m_pIncreaseValidRect)
    self.m_pTextButton:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            self.m_pTextButton:setScale(1.0)
            self.m_pTextButton:setColor(self.m_pTextColorS)
            return true
        elseif event.name == "ended" then
            self.m_pTextButton:setScale(0.9)
            self.m_pTextButton:setColor(self.m_pTextColorN)
            local point = self.m_pTextButton:convertToNodeSpace(cc.p(event.x, event.y))
            if cc.rectContainsPoint(self.m_pValidRect, point) then
                self:onMenuCallBack()
            end  
        end
    end)
end

function CMTextButton:onMenuCallBack()
	if self.m_pCallback then
		self.m_pCallback()
	end
end

return CMTextButton