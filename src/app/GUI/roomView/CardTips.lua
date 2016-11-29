
local DialogBase = require("app.GUI.roomView.DialogBase")
local CardTips = class("CardTips", function()
		return DialogBase:new()
	end)

function CardTips:create(tableType)
	local dialog = CardTips:new()
	dialog:initWithTableType(tableType)
	return dialog
end

function CardTips:ctor()
	self.m_step = {}
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) 
		if event.name == "began" then
			self:removeFromParent(true)
			return true
		end
	end)
end

function CardTips:initWithTableType(tableType)
	self:manualLoadxml()
end

function CardTips:manualLoadxml()
	self.background = cc.ui.UIImage.new("cardTypeBG.png")
		:align(display.LEFT_BOTTOM, 10, 0)
		:addTo(self)

	self.cards = cc.ui.UIImage.new("cardType.png")
		:align(display.LEFT_TOP, 37, 522)
		:addTo(self, 1)
		
	self.highLight = cc.ui.UIImage.new("cardWinHighLight.png")
		:align(display.LEFT_CENTER, 25, 528)
		:addTo(self)
	self.highLight:setVisible(false)

	self.m_step[10] = cc.ui.UILabel.new({
		text = "皇家同花顺",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 500)
		:addTo(self)

	self.m_step[9] = cc.ui.UILabel.new({
		text = "同花顺",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 450)
		:addTo(self)

	self.m_step[8] = cc.ui.UILabel.new({
		text = "四条",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 400)
		:addTo(self)

	self.m_step[7] = cc.ui.UILabel.new({
		text = "葫芦",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 350)
		:addTo(self)

	self.m_step[6] = cc.ui.UILabel.new({
		text = "同花",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 300)
		:addTo(self)

	self.m_step[5] = cc.ui.UILabel.new({
		text = "顺子",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 250)
		:addTo(self)

	self.m_step[4] = cc.ui.UILabel.new({
		text = "三条",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 200)
		:addTo(self)

	self.m_step[3] = cc.ui.UILabel.new({
		text = "两对",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 150)
		:addTo(self)

	self.m_step[2] = cc.ui.UILabel.new({
		text = "一对",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 100)
		:addTo(self)

	self.m_step[1] = cc.ui.UILabel.new({
		text = "高牌",
		font = "Arial",
		size = 24,
		align = cc.TEXT_ALIGNMENT_LEFT,
		color = cc.c3b(255,255,255),
		})
		:align(display.LEFT_CENTER, 225, 50)
		:addTo(self)
end

function CardTips:highLightType(lightType)
	if lightType >= 0 and lightType<=9 then
		local pic = self.highLight
		if pic then
			pic:setVisible(true)
			pic:setPositionY(49+lightType*50)
		end
        
		local label = self.m_step[lightType+1]
		if label then
			label:setColor(cc.c3b(1,250,251))
		end
	end
end

return CardTips