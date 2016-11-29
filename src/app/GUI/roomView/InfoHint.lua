kMOVETOSPANE	= 10
local InfoHint = class("InfoHint", function()
		return display.newNode()
	end)

function InfoHint:create()
	local p = InfoHint:new()
	return p
end

function InfoHint:ctor()
	self.m_messages = {}
	self.m_initPoint = cc.p(0,0)
	local bg = cc.ui.UIImage.new("picdata/table/infoBG.png")
		:align(display.LEFT_TOP, 0, display.height)
		:addTo(self)
	local size = bg:getContentSize()
	bg:setScaleX(display.height/size.height)
	self:setContentSize(size)

	self.m_label = cc.ui.UILabel.new({
		text = "！",
		font = "Arial",
		size = 20,
		color = cc.c3b(235,235,255),
		dimensions = cc.size(590, 51),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
	self.m_label:align(display.CENTER, display.width/2, display.height-35)
		:addTo(self,2,100)
	self:setVisible(false)
end

function InfoHint:setInitPosition(point)
	self.m_initPoint = point
	self:setPosition(point)
end

function InfoHint:addBubble(message, bShowImmediately)
	if bShowImmediately then
		self:stopAllActions()
		self.m_messages = {}
		self.m_messages[1] = message
		self:showInfo(message)
	else
		if #self.m_messages > 0 then
			-- 有动画在展示
			table.insert(self.m_messages,1,message)
		else
			self.m_messages[1] = message
			self:showInfo(message)
		end
	end
end

function InfoHint:showInfo(message)
	self:setVisible(true)
	local label = self:getChildByTag(100)
	label:setString(message)
	self:setOpacity(0)
	self:setPosition(cc.p(self.m_initPoint.x, self.m_initPoint.y + kMOVETOSPANE))
	local fadein = cc.Spawn:create(cc.MoveTo:create(0.5, 
		cc.p(self.m_initPoint.x, self.m_initPoint.y)), cc.FadeIn:create(0.5))
	local time = cc.DelayTime:create(4.0)
	local fadeout = cc.Spawn:create(cc.MoveTo:create(0.5, 
		cc.p(self.m_initPoint.x, self.m_initPoint.y + kMOVETOSPANE)), cc.FadeOut:create(0.5))
	local action = cc.CallFunc:create(handler(self, self.actionDidFinish))
	self:runAction(cc.Sequence:create(fadein, time, fadeout, action))
end

function InfoHint:actionDidFinish()
	self:setVisible(false)
	--[[删除已完成动画的元素]]
	self.m_messages[#self.m_messages] = nil
	if #self.m_messages > 0 then
		local message = self.m_messages[#self.m_messages]
		self:showInfo(message)
	end
end

return InfoHint