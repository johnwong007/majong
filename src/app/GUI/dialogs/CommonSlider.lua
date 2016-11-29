--
-- Author: wangj
-- Date: 2016-05-20 11:14:44
--
local startPos = cc.p(0, 17)
local CommonSlider = class("CommonSlider", function()
		return display.newNode()
	end)

---
-- [function description]
--
-- @param params
	--[[
		sliderCurrentValue:当前值（可选值，默认为0）
		position:进度条的位置（以标题为参考点）
		hintValue:进度条的显示值（table类型）
		bgFile:background filename
		progressFile:a progress filename
     	thumbFile:thumb image filename
     	sliderDotNum:进度条刻度的个数
		]]
-- @return [description]
--
function CommonSlider:ctor(params)
	self.params = params
end

function CommonSlider:create()
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
			if self.params and self.params.valueChangedCallback then
				self.params.valueChangedCallback(value)
			end
    	end
    end)
end

function CommonSlider:initUI()
	local tmpSprite = cc.ui.UIImage.new("picdata/privateHall/private_line.png")
	sliderWidth = tmpSprite:getContentSize().width

	local sprite1 = cc.Sprite:create(self.params.bgFile)
	local sprite2 = cc.Sprite:create(self.params.progressFile)
	local sprite3 = cc.Sprite:create(self.params.thumbFile)

	local pSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	pSlider:registerControlEventHandler(handler(self,self.onValueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	pSlider:setMaximumValue(self.params.sliderDotNum-1)
	pSlider:setMinimumValue(0)
	pSlider:setValue(self.params.sliderCurrentValue or 0)
	pSlider:setPosition(self.params.position.x,self.params.position.y)
	self:addChild(pSlider, 1)
	self.m_slider = pSlider
end

function CommonSlider:updateHintValue(value)
	-- if self.params.hintTitle then
	-- 	for i=1,#self.params.hintTitle do
	-- 		self.sliderHint[i]:setString(self.params.hintValue[i][value+1])
	-- 	end
	-- end
end

function CommonSlider:onValueChanged(event)

end

function CommonSlider:getValue()
	local value = math.round(self.m_slider:getValue())
	return value
end

function CommonSlider:setValue(value)
	self.m_slider:setValue(value)
end


function CommonSlider:getSliderValue()
	local value = math.round(self.m_slider:getValue())
	return value
end

function CommonSlider:setEnabled(enabled)
	self.m_slider:setEnabled(enabled)
end

function CommonSlider:setTouchEnabled(enabled)
	self.m_slider:setTouchEnabled(enabled)
end
return CommonSlider