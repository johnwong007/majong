local scheduler = require("framework.scheduler")
local DialogBase = require("app.GUI.roomView.DialogBase")

local ETooltipView = class("ETooltipView", function(event)
		return DialogBase:new()
	end)
function ETooltipView:create()

end

function ETooltipView:alertView(parent,  title,  message, succ)
	local view = ETooltipView:new()
	if view and view:initWithButton(parent, title, message,succ) then
		return view
	end
	view = nil
	return nil
end

function ETooltipView:ctor()
    local CMMaskLayer = CMMask.new()
    self:addChild(CMMaskLayer)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				self:hide()
				if self.m_tcBack then
					scheduler.unscheduleGlobal(self.m_tcBack)
				end
			end
		end)
end

function ETooltipView:initWithButton(parent, title, message, succ)
	if succ == nil then
		succ = true
	end
	self:manualLoadxml(message)

	if succ then
		self.success:setVisible(true)
	else
		self.faile:setVisible(true)
	end

	self:setPosition(LAYOUT_OFFSET)
	parent:addChild(self, MAX_ZORDER+1)
	-- CMOpen(self, parent,0,0,MAX_ZORDER+1)
	self.title:setString(""..title)


	self:setVisible(false)

	return true
end

function ETooltipView:manualLoadxml(message)
	self.background = cc.ui.UIImage.new("tooltipBG.png")
	self.background:align(display.CENTER, display.cx, display.cy)
	self.background:addTo(self)


	local width = 490
	local height = 320
	local node = display.newNode()
	node:addTo(self)
	node:setContentSize(self.background:getContentSize())
	node:setPosition(self.background:getPositionX()-width, self.background:getPositionY()-height)

	self.success = cc.ui.UIImage.new("success.png")
	self.success:align(display.CENTER, 480, 373)
	self.success:addTo(node)
	self.success:setVisible(false)

	self.faile = cc.ui.UIImage.new("faild.png")
	self.faile:align(display.CENTER, 480, 373)
	self.faile:addTo(node)
	self.faile:setVisible(false)

	self.title = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 30,
		color = cc.c3b(255,255,255),
		align = cc.ui.TEXT_ALIGN_CENTER,
		})
	self.title:align(display.CENTER, 480, 448)
	self.title:addTo(node)
	
	local messageLabel = cc.ui.UILabel.new({
		text = ""..message,
		font = "",
		size = 30,
		align = cc.ui.TEXT_ALIGN_CENTER,
		color = cc.c3b(255,255,255),
		dimensions = cc.size(400,0),
		}):align(display.CENTER, 480, 240)
		:addTo(node, 20)
end

function ETooltipView:show(args)
	DialogBase.show(self)
	self.m_tcBack = scheduler.scheduleGlobal(handler(self,self.TimerCallBack),args or 2)
end

function ETooltipView:TimerCallBack(delta)
	if self~=nil then
		if self.m_tcBack then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_tcBack)
		self.m_tcBack = nil
				DialogBase.remove(self)
		end
	end
end

function ETooltipView:setTouchHide(bEnable)

end
return ETooltipView