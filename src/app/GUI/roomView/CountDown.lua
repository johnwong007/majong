local CountDown = class("CountDown", function()
		return display.newNode()
	end)
function CountDown:create(startCount, endCount, timeSpan, countType, showType)
	local node = CountDown:new()
	node:init(startCount, endCount, timeSpan, countType, showType)
	return node 
end

function CountDown:init(startCount, endCount, timeSpan, countType, showType)
	self.m_type = countType
	self.showType = showType or 0
	if (startCount <= endCount) then
		return
	end
	self.m_startCount = startCount
	self.m_currentCount = startCount
	self.m_endCount = endCount
	self.m_timeSpan = timeSpan
	self.m_bStop = true
	self.m_label:setString(""..self.m_startCount)
	self.m_label:setColor(cc.c3b(213, 213, 213))
end

function CountDown:ctor()
	self.m_startCount = 0
	self.m_endCount = 0
	self.m_timeSpan = 0.0
	self.m_currentCount = 0

	self.m_bStop = true
	self.m_type = eUnknowType

	self.m_label = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 30,
		color = cc.c3b(213, 213, 213)
		})
		:align(display.CENTER, 0, 0)
		:addTo(self)
    self:setNodeEventEnabled(true)
end

function CountDown:onEnter()
end

function CountDown:onExit()
	self:stopCount()
end

function CountDown:startCount()
	if self.m_bStop then
		self.m_updateCountId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
				handler(self, self.updateCount), 1, false)
	end
	self.m_bStop = false
end

function CountDown:stopCount()
	if self.m_bStop then
		return
	end
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_updateCountId)
	self.m_updateCountId = nil
	self.m_bStop = true
end

function CountDown:updateCount(dt)
	if self.m_currentCount - 1 < self.m_endCount then
		self:stopCount()
		if self.m_type == eTourneyTable then
			self.m_label:setString("锦标赛即将开始")
		elseif self.m_type == eSngPKTable then
			self.m_label:setString("PK赛即将开始")
		end
		-- self.m_label:setFontSize(24)
	else
		self.m_currentCount = self.m_currentCount-1
		local hint = ""..self.m_currentCount
		if self.showType and self.showType == 1 then
			hint = "牌局将在"..self.m_currentCount.."s后关闭"
		end
		self.m_label:setString(hint)
		self.m_label:setColor(cc.c3b(255, 100, 100))
		self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2, 1.2),
                                           cc.CallFunc:create(handler(self, self.resetColor)),
                                           cc.ScaleTo:create(0.1, 1.0, 1.0)))
	end
end

function CountDown:resetColor()
	self.m_label:setColor(cc.c3b(213, 213, 213))
end

return CountDown