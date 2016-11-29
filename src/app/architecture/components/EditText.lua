local EditText = class("EditText",function () 
	return display.newNode() 
end)

function EditText:ctor(o,params)
	self:setNodeEventEnabled(true)
	setmetatable(EditText, {__index = cc.Node})
	EditText.super = cc.Node
	self.params = params or {}
	self.params.forePath = self.params.forePath or "picdata/public_new/icon_id.png"
	self.params.forePadding = self.params.forePadding or 0
	self.params.foreAlign= self.params.foreAlign or EditText.LEFT
	self.params.bgPath = self.params.bgPath or "picdata/public/transBG.png"
	self.params.size   = self.params.size
	self.params.minLength= self.params.minLength
	self.params.maxLength= self.params.maxLength
	self.params.color    = self.params.color or cc.c3b(0, 0, 0)
	self.params.placeColor = self.params.placeColor or cc.c3b(133,133,133)
	self.params.place    = self.params.place or ""
	self.params.fontSize = self.params.fontSize or 28
	self.params.listener = self.params.listener 
	self.params.inputFlag= self.params.inputFlag or 1
	self.params.inputMode = self.params.inputMode or 0
	self.params.scale9   = self.params.scale9 or false
	self.params.showMaxTip = self.params.showMaxTip or 1
	self.params.showTipLabel=self.params.showTipLabel or 0
	self.params.inputOffsetY = self.params.inputOffsetY or 0
	self.params.foreBgSize = self.params.foreBgSize
	self.mForeLength     = 0
	self.mForeHeight     = 0
	self.mInputBox       = nil
	self.mForePosx       = 5
	self.mIsNullString = true

	self:initUI()
end
function  EditText:onExit()
	-- body
	self.params = {}
end
function EditText:initUI()--[[帐号输入框]]
    local accountBg = cc.ui.UIImage.new(self.params.bgPath)
    accountBg:align(display.CENTER, 0, 0)
        :addTo(self)
    local originSize = accountBg:getContentSize()
    if self.params.foreBgSize then
    	accountBg:setScale(self.params.foreBgSize.width/originSize.width, self.params.foreBgSize.height/originSize.height)
    	originSize = self.params.foreBgSize
    	self.params.size.width = originSize.width-110
    end

    self.mInputBox = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = self.params.maxLength,
        minLength = self.params.minLength,
        place     = self.params.place ,
        placeColor = self.params.placeColor,
        color     = self.params.color,
        fontSize  = self.params.fontSize,
        size = self.params.size,
        inputOffsetY = self.params.inputOffsetY,
        inputFlag = self.params.inputFlag,
        listener = handler(self, self.onEdit)
    })
    self.mInputBox:setPosition(accountBg:getPositionX()+10,accountBg:getPositionY())
    self:addChild(self.mInputBox)

    cc.ui.UIImage.new(self.params.forePath)
        :align(display.CENTER, accountBg:getPositionX()-originSize.width/2+35, accountBg:getPositionY())
        :addTo(self)

    self.m_pClearAccountBtn = CMButton.new({normal = "picdata/public_new/input_btn_close.png",
        pressed = "picdata/public_new/input_btn_close_p.png"},function () 
        	self.mInputBox:setText("") 
    		self.m_pClearAccountBtn:setVisible(false)
        end)
    self.m_pClearAccountBtn:setPosition(accountBg:getPositionX()+originSize.width/2-30, accountBg:getPositionY())
    self:addChild(self.m_pClearAccountBtn) 	
    self.m_pClearAccountBtn:setVisible(false)
end

function EditText:setText(text)
	self.mInputBox:setText(text)
	if text and text~="" then
		self.m_pClearAccountBtn:setVisible(true)
	else
		self.m_pClearAccountBtn:setVisible(false)
	end
end

function EditText:getText()
	return self.mInputBox:getText()
end

-- 输入事件监听方法
function EditText:onEdit(event, editbox)
	local text = editbox:getText()
	if text and text~="" then
		self.m_pClearAccountBtn:setVisible(true)
	else
		self.m_pClearAccountBtn:setVisible(false)
	end
	if self.params.listener then
		self.params.listener(event, editbox)
	end
end

return EditText