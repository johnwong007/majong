--
-- Author: wangj
-- Date: 2016-84-17 17:56:28
--
local CMButton = require("app.Component.CMButton")
local CMRadioButton = class("CMRadioButton", function()
    return display.newNode()
end)

function CMRadioButton:ctor(o,params)
	self.params = params or {}
	self.m_pImageOn = self.params.on or "picdata/public/checkboxOn.png"
	self.m_pImageOff = self.params.off or "picdata/public/checkboxOff.png"
	self.m_bIsSelected = self.params.isSelected or false
	self.m_pHint = self.params.hint
	self.m_pHintColorOff = self.params.hintColorOff or cc.c3b(255,255,255)
	self.m_pHintColorOn = self.params.hintColorOn or cc.c3b(255,255,255)
	self.m_pCallback = self.params.callback
	self:initUI()
end

function CMRadioButton:initUI()
	local tmpSprite = cc.ui.UIImage.new(self.m_pImageOn)
	local size = tmpSprite:getContentSize()
	local btnImg = {}
	if self.m_bIsSelected then
		btnImg.normal = self.m_pImageOn
		btnImg.pressed = self.m_pImageOn
	else
		btnImg.normal = self.m_pImageOff
		btnImg.pressed = self.m_pImageOff
	end
	self.m_pImageButton = CMButton.new(btnImg,function () self:onMenuCallBack() end,{Scale9 = false},{scale = true})
	self.m_pImageButton:align(display.LEFT_CENTER, 0, size.height/2)
	self.m_pImageButton:addTo(self)

	if self.m_pHint then
		self.m_pHintLabel = cc.ui.UILabel.new({
	        text  = self.m_pHint,
	        size  = 28,
	        color = self.m_pHintColorOff,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        font  = "FZZCHJW--GB1-0",
    	})
		self.m_pHintLabel:align(display.LEFT_CENTER, self.m_pImageButton:getPositionX()+size.width,
			self.m_pImageButton:getPositionY())
		self:addChild(self.m_pHintLabel)
	end
end

function CMRadioButton:onMenuCallBack()
	if self.m_bIsSelected then
    	self.m_pImageButton:setButtonImage(CMButton.NORMAL, self.m_pImageOff, true)
    	self.m_pImageButton:setButtonImage(CMButton.PRESSED, self.m_pImageOff, true)
    	if self.m_pHintLabel then
    		self.m_pHintLabel:setColor(self.m_pHintColorOff)
    	end
	else
    	self.m_pImageButton:setButtonImage(CMButton.NORMAL, self.m_pImageOn, true)
    	self.m_pImageButton:setButtonImage(CMButton.PRESSED, self.m_pImageOn, true)
    	if self.m_pHintLabel then
    		self.m_pHintLabel:setColor(self.m_pHintColorOn)
    	end
	end
	self.m_bIsSelected = not self.m_bIsSelected
	if self.m_pCallback then
		self.m_pCallback(self.m_bIsSelected)
	end
end

function CMRadioButton:isSelected()
	return self.m_bIsSelected
end

function CMRadioButton:setButtonSelected(selected)
	if selected then
    	self.m_pImageButton:setButtonImage(CMButton.NORMAL, self.m_pImageOn, true)
    	self.m_pImageButton:setButtonImage(CMButton.PRESSED, self.m_pImageOn, true)
    	if self.m_pHintLabel then
    		self.m_pHintLabel:setColor(self.m_pHintColorOn)
    	end
	else
    	self.m_pImageButton:setButtonImage(CMButton.NORMAL, self.m_pImageOff, true)
    	self.m_pImageButton:setButtonImage(CMButton.PRESSED, self.m_pImageOff, true)
    	if self.m_pHintLabel then
    		self.m_pHintLabel:setColor(self.m_pHintColorOff)
    	end
	end
	self.m_bIsSelected = selected
end

return CMRadioButton