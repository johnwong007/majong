--
-- Author: JJ
-- Date: 2016-01-17 16:04:11
--
--输入框控件
local CMInput = class("CMInput",function () 
	return display.newNode() 
end)
CMInput.LEFT = -1
CMInput.RIGHT= 1
CMInput.TAG = {
	FORBG = 101,
}
--[[
	默认1:显示 0:不显示
	forePath	:前置图片
	foreCallBack:前置回调
	forePadding:前置图片间隔
	foreAlign   :对齐方式
	bgPath    	:背景图
	size 		:输入区域
	maxLength	:可输入长度
	listener	:输入回调
	color 		:内容颜色
	place 		:空白显示内容
	fontSize    :字体大小
	showMaxTip  :是否显示超出提示
	showTipLabel:将输入框内容转成文本显示
	inputOffsetY:输入框偏移量
]]
function CMInput:ctor(o,params)
	self:setNodeEventEnabled(true)
	setmetatable(CMInput, {__index = cc.Node})
	CMInput.super = cc.Node
	self.params = params or {}
	self.params.forePath = self.params.forePath
	self.params.forePadding = self.params.forePadding or 0
	self.params.foreAlign= self.params.foreAlign or CMInput.LEFT
	self.params.bgPath = self.params.bgPath or "picdata/public/transBG.png"
	self.params.size   = self.params.size
	self.params.minLength= self.params.minLength or 0
	self.params.maxLength= self.params.maxLength or 30
	self.params.color    = self.params.color or cc.c3b(135, 154, 192)
	self.params.place    = self.params.place or ""
	self.params.fontSize = self.params.fontSize or 20
	self.params.listener = self.params.listener 
	self.params.inputFlag= self.params.inputFlag or 1
	self.params.inputMode = self.params.inputMode or 0
	self.params.scale9   = self.params.scale9 or false
	self.params.placeColor = self.params.placeColor or cc.c3b(135, 154, 192)
	self.params.showMaxTip = self.params.showMaxTip or 1
	self.params.showTipLabel=self.params.showTipLabel or 0
	self.params.inputOffsetY = self.params.inputOffsetY or 0 
	self.mForeLength     = 0
	self.mForeHeight     = 0
	self.mInputBox       = nil
	self.mForePosx       = 5
	self.mIsNullString = true
	self:initUI()
end
function  CMInput:onExit()
	-- body
	self.params = {}
end
function CMInput:initUI()
    local inputBg  = nil
    if self.params.scale9 then
    	inputBg  = cc.ui.UIImage.new(self.params.bgPath, {scale9 = true})
    	if self.params.size then
	   		 inputBg:setLayoutSize(self.params.size.width,self.params.size.height)
	   	end
    else
    	inputBg  = cc.Sprite:create(self.params.bgPath)
    end
    
    self:addChild(inputBg)
    self.mForeHeight = inputBg:getContentSize().height 
    if not self.params.size then
    	self.params.size = cc.size(inputBg:getContentSize().width,inputBg:getContentSize().height-20)
   	end
    self:addForeBgIf()
    self:addBgColorIf()
	local inputBox = cc.ui.UIInput.new({
		    image = "picdata/public/transBG.png", -- 输入控件的背景
		    --x = 580,
		   -- y = 50,	    	
		    maxLength = self.params.maxLength,
		    size = self.params.size,
		    listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		})
		inputBox:setPlaceholderFontColor(self.params.placeColor)
		inputBox:setPlaceHolder(self.params.place)
		inputBox:setFont("黑体", self.params.fontSize)
		inputBox:setFontSize(self.params.fontSize)
		if self.params.scale9 then
			inputBox:setPosition(-self.params.foreAlign*self.mForeLength/2+inputBg:getContentSize().width/2,inputBg:getContentSize().height/2)		
		else
			inputBox:setPosition(-self.params.foreAlign*self.mForeLength/2,self.params.inputOffsetY)		
		end
		inputBox:setFontColor(self.params.color)
		
		inputBox:setInputFlag(self.params.inputFlag)
		inputBox:setInputMode(self.params.inputMode)
	self:addChild(inputBox)

	self.mInputBox = inputBox	

	self:addSwitchLabel()
end
--[[
	添加前置图
]]
function CMInput:addForeBgIf()
	if not self.params.forePath then return end
	
	local foreWidth = 0
	local foreBg = nil	
	if self.params.foreCallBack then
		local textPath = nil
		local textData = nil 
		if  self.params.textPath then		
			if type(self.params.textPath) ~= "table" then
				local index = string.find(self.params.textPath,".png")
				if index then
					textPath = self.params.textPath
				else
					textData = {}
					textData.text = self.params.textPath
				end
			else
				textData = self.params.textPath
			end			
		end

		foreBg = CMButton.new({normal = self.params.forePath},function () self.params.foreCallBack() end,{scale9 = false},{textPath = textPath})
		if textData then
			foreBg:setButtonLabel("normal",cc.ui.UILabel.new({
		    color = textData.color or cc.c3b(255, 255, 255),
		    text = textData.text or "",
		    size = textData.size or 24,
		    font = textData.font or "FZZCHJW--GB1-0",
			}) ) 

			self.mBtnForeBg        = foreBg
		end      
		foreWidth = foreBg:getButtonSize().width
	else
		foreBg  = cc.Sprite:create(self.params.forePath)
		foreWidth = foreBg:getContentSize().width
	end	
	local padding = 10
	foreBg:setPosition(self.params.foreAlign*self.params.size.width/2-self.params.foreAlign*foreWidth/2-self.params.foreAlign*self.params.forePadding,0)
	self:addChild(foreBg,1,CMInput.TAG.FORBG)

	foreWidth=foreWidth+self.params.forePadding*2

	self.mForeLength       = foreWidth
	self.params.size.width = self.params.size.width - foreWidth
	self.params.size.height= self.mForeHeight - 20
	if self.params.scale9 then
		if self.params.foreAlign == CMInput.LEFT then
			foreBg:setPosition(foreWidth/2,self.mForeHeight/2)
		else
			foreBg:setPosition(self.params.size.width+foreWidth/2,self.mForeHeight/2)
		end
	end
	
end
--[[
	输入区域颜色
	]]
function CMInput:addBgColorIf()
	if not self.params.bgColor then
		return
	end

	cc.LayerColor:create(self.params.bgColor)
		:size(self.params.size.width, self.params.size.height)
		:pos(-self.params.size.width/2 - self.params.foreAlign*self.mForeLength/2,-self.params.size.height/2)
		:addTo(self)
		:setTouchEnabled(false)
end
--[[
	设置输入内容
]]
function CMInput:setText(text)
	self.mInputBox:setText(text)
end
function CMInput:getText()
	return self.mInputBox:getText()
end
--[[
	设置前置按钮文字
]]
function CMInput:setButtonLabel(textData)
	if not self.mBtnForeBg then return end

	self.mBtnForeBg:setButtonLabel("normal",cc.ui.UILabel.new({
		    color = textData.color or cc.c3b(255, 255, 255),
		    text = textData.text or "",
		    size = textData.size or 24,
		    font = textData.font or "FZZCHJW--GB1-0",
			}) ) 
end
--[[
	设置前置按钮图片
]]
function CMInput:setTexture(_path,_isGray,params)
	if not self.mBtnForeBg then return end
	self.mBtnForeBg:setTexture(_path,_isGray,params)
end
--[[
	设置前置按钮是否可见
]]
function CMInput:setForBgVisible(visible)
	if self:getChildByTag(CMInput.TAG.FORBG) then
		self:getChildByTag(CMInput.TAG.FORBG):setVisible(visible)
	end
end
--[[
	设置前置按钮偏移量
]]
function CMInput:setForBgOff(offx,offy)
	local foreBg = self:getChildByTag(CMInput.TAG.FORBG)
	if not foreBg then return end
	local posx = foreBg:getPositionX()
	local posy = foreBg:getPositionY()
	foreBg:setPosition(posx+offx,posy+offy)
end
--[[
	设置输入框是否可见
]]
function CMInput:setVisible(visible)
	CMInput.super.setVisible(self,visible)
	self.mInputBox:setVisible(visible)
end


---------------------	将输入框文本切换成Label --start------------------------
--[[
	添加切换文本
]]
function CMInput:addSwitchLabel()
	if self.params.showTipLabel == 0 then return end
	self.mInputBox:setPlaceHolder("")
	self.mTipLabel = cc.ui.UILabel.new({
        text  = self.params.place,
        size  = self.params.fontSize,
        color = self.params.placeColor,
        align = cc.ui.TEXT_ALIGN_LEFT,
        dimensions = cc.size(self.params.size.width, self.params.size.height),
        --UILabelType = 1,
        font  = "黑体",
    })
	self.mTipLabel:setPosition(self:getPositionX(),self.mInputBox:getPositionY())
	self.mInputBox:addChild(self.mTipLabel)
end
function CMInput:getTipLabel()
	return self.mTipLabel
end
--[[
	文本触摸开始回调
]]
function CMInput:touchLabelBegin()
	if not self.mTipLabel then return end
	self.mTipLabel:setVisible(false)
    self.mInputBox:setText(self.mTipLabel:getString())
end
--[[
	文本触摸结束回调
]]
function CMInput:touchLabelReturn()
	if not self.mTipLabel then return end
	local text = self.mInputBox:getText()
	self.mTipLabel:setString(text)
	self.mTipLabel:setColor(self.params.color)
	self.mTipLabel:setVisible(true)
	self.mIsNullString = false
	if self.mTipLabel:getString() == "" then
		self.mTipLabel:setString(self.params.place)
		self.mTipLabel:setColor(self.params.placeColor)
		self.mIsNullString = true
	end
	self.mInputBox:setText("")
end
--[[
	检测文本是否为空字符串
]]
function CMInput:checkLabelIsNull()
	return self.mIsNullString
end
--------------------将输入框文本切换成Label end-------------------------

-- 输入事件监听方法
function CMInput:onEdit(event, editbox)
	local isOverMaxLength = nil
    if event == "began" then
    -- 开始输入
    	self:touchLabelBegin()
        --print("开始输入")
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
        local _text = editbox:getText()
		local _trimed = string.trim(_text)		
		if _trimed ~= _text then			
		    editbox:setText(_trimed)
		end
    elseif event == "ended" then
    -- 输入结束
    	editbox:setText(FilterWords:filterWord(editbox:getText()))
     	local _text,len = CMGetStringLen(editbox:getText(),self.params.maxLength)
     	if len < self.params.minLength or len > self.params.maxLength then	
     		if self.params.showMaxTip == 1 then
     			CMShowTip(string.format("请输入%d-%d位以内的字符",self.params.minLength,self.params.maxLength))
     		end
     		if len < self.params.minLength then
     			editbox:setText("")
     		else
     			editbox:setText(_text)
     		end
     		isOverMaxLength = true
     	end
        --print("输入结束")        
    elseif event == "return" then
    -- 从输入框返回
        --print("从输入框返回")  
        self:touchLabelReturn()     
    end
    if self.params.listener  then 
		self.params.listener(event, editbox,isOverMaxLength)
	end
end
return CMInput