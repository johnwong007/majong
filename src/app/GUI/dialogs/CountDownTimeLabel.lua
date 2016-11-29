--
-- Author: wangj
-- Date: 2016-05-18 13:43:23
--
local scheduler = require("framework.scheduler")
local CountDownTimeLabel = class("CountDownTimeLabel", function()
		return display.newNode()
	end)

function CountDownTimeLabel:create()
	self:initUI()
end

function CountDownTimeLabel:ctor(params)
	self.params = params or {}
	self.timestamp = params.timestamp or 0
	self.color = params.color or cc.c3b(255,0,0)
	self.separator = params.separator --[[or ":"]]
	self.length = params.length or 3
	self.position = params.position or cc.p(0,0)
	self.padding = params.padding or 0
end

function CountDownTimeLabel:setTimestamp(stamp)
	self.timestamp = stamp
end

function CountDownTimeLabel:separateTime()
	local tmp = self.timestamp
	self.hour = math.floor(tmp/3600)
	tmp = math.floor(tmp%3600)
	self.min = math.floor(tmp/60)
	tmp = math.floor(tmp%60)
	self.sec = tmp
end

function CountDownTimeLabel:updateTime()
	while true do
		if self.sec<10 then
			self.timeLabel[#self.timeLabel]:setString("0"..self.sec)
		else
			self.timeLabel[#self.timeLabel]:setString(""..self.sec)
		end
		if self.length==1 then
			break
		end
		if self.min<10 then
			self.timeLabel[#self.timeLabel-1]:setString("0"..self.min)
		else
			self.timeLabel[#self.timeLabel-1]:setString(""..self.min)
		end
		if self.length==2 then
			break
		end
		if self.hour<10 then
			self.timeLabel[#self.timeLabel-2]:setString("0"..self.hour)
		else
			self.timeLabel[#self.timeLabel-2]:setString(""..self.hour)
		end
		break
	end
end

function CountDownTimeLabel:initUI()
	self.timeLabel = {}
	local posx = self.position.x
	for i=1,self.length do
	    self.timeLabel[i] = cc.ui.UILabel.new({
	                text = "00",
	                font = "Arial",
	                size = 22,
	                color = self.color
	                }) 
	    self.timeLabel[i]:align(display.LEFT_CENTER, posx, self.position.y)
	    self.timeLabel[i]:addTo(self)

	    posx = posx+self.timeLabel[i]:getContentSize().width+self.padding
	    if i~=self.length and self.separator then
	    	local label = cc.ui.UILabel.new({
	                text = ""..self.separator,
	                font = "Arial",
	                size = 22,
	                color = self.color
	                }) 
		   	label:align(display.CENTER, posx, self.position.y)
		    label:addTo(self)
	   	 	posx = posx+label:getContentSize().width+self.padding
	    end
	end
    self:setNodeEventEnabled(true)
end

function CountDownTimeLabel:onEnter()
	self.timeScheduler = scheduler.scheduleGlobal(handler(self, self.updateTimeLabel), 1)
end

function CountDownTimeLabel:onExit()
	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
		self.timeScheduler = nil
	end
end

--[[更新显示时间]]
function CountDownTimeLabel:updateTimeLabel(dt)
	if self.timestamp>0 then 
		self:separateTime()
		self:updateTime()
	end
	self.timestamp = self.timestamp - 1
end

return CountDownTimeLabel