--
-- Author: wangj
-- Date: 2016-05-17 10:09:43
--
local startPos = cc.p(0, 17)
local CreateDebaoRoomSlider = class("CreateDebaoRoomSlider", function()
		return display.newNode()
	end)

---
-- [function description]
--
-- @param params
	--[[
		sliderDotNum:进度条多少个刻度
		sliderCurrentValue:当前值（可选值，默认为0）
		position:进度条的位置（以标题为参考点）
		sliderBtn:进度条按钮图片
		hintTitle:进度条标题（table类型）
		hintValue:进度条的显示值（table类型）
		]]
-- @return [description]
--
function CreateDebaoRoomSlider:ctor(params)
	self.params = params
end

function CreateDebaoRoomSlider:create()
	if not self.params then 
		return
	end
	self:initUI()

	-- 启用帧事件
	self:scheduleUpdate()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    	if not self.m_slider:isSelected() then
			local value = math.round(self.m_slider:getValue())
			self.m_slider:setValue(value)

			if self.params.valueChangedCallback then
				self.params.valueChangedCallback()
			end
			self:updateHintValue(value)
			for i=1,#self.sliderDot do
				if i>value then
					self.sliderDot[i]:setVisible(false)
				else
					self.sliderDot[i]:setVisible(true)
				end
			end
    	end
    end)
end

function CreateDebaoRoomSlider:initUI()
	self.sliderDot = {}
	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width

	local sprite1 = cc.Sprite:create("picdata/privateHall/private_line.png")
	local sprite2 = cc.Sprite:create("picdata/privateHall/private_line2.png")
	local sprite3 = cc.Sprite:create(self.params.sliderBtn or "picdata/privateHall/btn_player.png")
	
	self:addSliderDot(nil, sprite1, sliderWidth, startPos, self.params.sliderDotNum, 2, "picdata/privateHall/private_dot.png")
	self:addSliderDot(self.sliderDot, sprite2, sliderWidth, startPos, self.params.sliderDotNum, 2, "picdata/privateHall/private_dot2.png")

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(self.params.sliderDotNum-1)
	pSlider:setMinimumValue(0)
	pSlider:setValue(self.params.sliderCurrentValue or 0)
	pSlider:setPosition(self.params.position.x+8+pSlider:getContentSize().width/2,
		self.params.position.y-45)
	self:addChild(pSlider, 1)
	self.m_slider = pSlider

	cc.ui.UIImage.new("picdata/privateHall/private_input.png")
		:align(display.CENTER, pSlider:getPositionX(), pSlider:getPositionY())
		:addTo(self, 0)

	if self.params.hintTitle then
		self.sliderHint = {}
		for i=1,#self.params.hintTitle do
			local hintTitle = cc.ui.UILabel.new({
			text = self.params.hintTitle[i],
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 24,
			color = cc.c3b(135,154,192),
			align = cc.TEXT_ALIGNMENT_LEFT
			})
			:align(display.LEFT_CENTER, self.params.position.x+(i-1)*200, self.params.position.y)
			:addTo(self)

			self.sliderHint[i] = cc.ui.UILabel.new({
			text = self.params.hintValue[i][1].."",
			font = "黑体",
			size = 28,
			color = cc.c3b(0,255,225),
			align = cc.TEXT_ALIGNMENT_LEFT
			})
			:align(display.LEFT_CENTER, hintTitle:getPositionX()+hintTitle:getContentSize().width+5, hintTitle:getPositionY()+1.2)
			:addTo(self)
		end
	end
end

function CreateDebaoRoomSlider:updateHintValue(value)
	if self.params.hintTitle then
		for i=1,#self.params.hintTitle do
			self.sliderHint[i]:setString(self.params.hintValue[i][value+1])
		end
	end
end

function CreateDebaoRoomSlider:onValueChanged(event)

end

function CreateDebaoRoomSlider:addSliderDot(container, parent, sliderWidth, startPos, dotNum, zOrder, image)
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

function CreateDebaoRoomSlider:getValue()
	local value = math.round(self.m_slider:getValue())
	return value
end

function CreateDebaoRoomSlider:setValue(value)
	self.m_slider:setValue(value)
	self:updateHintValue(value)
	for i=1,#self.sliderDot do
		if i>value then
			self.sliderDot[i]:setVisible(false)
		else
			self.sliderDot[i]:setVisible(true)
		end
	end
end

function CreateDebaoRoomSlider:getSliderValue()
	local value = math.round(self.m_slider:getValue())
	return value
end

function CreateDebaoRoomSlider:setEnabled(enabled)
	self.m_slider:setEnabled(enabled)
end

return CreateDebaoRoomSlider