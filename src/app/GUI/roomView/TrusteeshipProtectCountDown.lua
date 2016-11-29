--
-- Author: wangj
-- Date: 2016-06-23 12:12:43
--
require("app.Tools.EStringTime")
local scheduler = require("framework.scheduler")
local timeColor = cc.c3b(255,102,0)
local TrusteeshipProtectCountDown = class("TrusteeshipProtectCountDown", function()
	return display.newNode()
	-- return display.newColorLayer(cc.c4b( 0,0,0,0))
end)

--[[
	成员变量说明：
	self.preSetStartTime
	
]]

function TrusteeshipProtectCountDown:ctor(params)
	self.params = params or {}
	self.timeStamp = self.params.timeStamp
	self.preSetStartTime = self.params.preSetStartTime
	if not self.timeStamp and self.preSetStartTime then
		self.timeStamp = EStringTime:getTimeStampFromNow(self.preSetStartTime)
	end
	self.callback = self.params.callback
	self.isMyself = self.params.isMyself or false
	self.timeStamp = self.timeStamp or 600
	self.timeStamp = self.timeStamp - 1
	self.milsecond = 60 
end

function TrusteeshipProtectCountDown:setTimestamp(time)
	self.timeStamp = time
	self.timeStamp = self.timeStamp - 1
	self.milsecond = 60 
end

function TrusteeshipProtectCountDown:create()
	self:initUI()
end

function TrusteeshipProtectCountDown:initUI()
	self.background = cc.ui.UIImage.new("picdata/leaveSitProtect/bg_lz.png")
	self.background:align(display.CENTER, 0, 0)
	self.background:addTo(self)


	local hintBgPosY = 50
	self.hintBg = cc.ui.UIImage.new("picdata/leaveSitProtect/bg_tc_tips.png")
	self.hintBg:align(display.CENTER, 0, hintBgPosY)
	self.hintBg:addTo(self)

	self.hintText = cc.ui.UILabel.new({
        	color = cc.c3b(255, 255, 255),
			text = "为您留座10分钟",
	        size  = 20,
	        font  = "font/FZZCHJW--GB1-0.TTF",
		}):align(display.CENTER, 0, hintBgPosY)
		:addTo(self, 1)

	if not self.isMyself then
		self.hintBg:setVisible(false)
		self.hintText:setVisible(false)
	end

	transition.execute(self.hintBg, cc.DelayTime:create(5),{
		onComplete=function()
			self.hintBg:setVisible(false)
			self.hintText:setVisible(false)
		end
		})

	local timeGap = 41
    local timePosY = 22
    local timeStartPosX = 78
    self.timeLabel1 = cc.ui.UILabel.new({
                text = ""--[[.."20"]],
                -- font = "fonts/digitalNum_w.fnt",
                size = 22,
                color = timeColor,
                align = cc.TEXT_ALIGNMENT_CENTER,
                -- UILabelType = 1,
                }) 
    self.timeLabel1:align(display.CENTER, timeStartPosX, timePosY)
    self.timeLabel1:addTo(self.background)

    self.timeLabel2 = cc.ui.UILabel.new({
                text = ""--[[.."30"]],
                -- font = "fonts/digitalNum_w.fnt",
                size = 22,
                color = timeColor,
                align = cc.TEXT_ALIGNMENT_CENTER,
                -- UILabelType = 1,
                }) 
    self.timeLabel2:align(display.CENTER, timeStartPosX+timeGap, timePosY)
    self.timeLabel2:addTo(self.background)

    -- self.timeLabel3 = cc.ui.UILabel.new({
    --             text = ""--[[.."30"]],
    --             -- font = "fonts/digitalNum_w.fnt",
    --             size = 22,
    --             color = timeColor,
    --             align = cc.TEXT_ALIGNMENT_CENTER,
    --             -- UILabelType = 1,
    --             }) 
    -- self.timeLabel3:align(display.CENTER, timeStartPosX+2*timeGap, timePosY)
    -- self.timeLabel3:addTo(self.background)

    self:setNodeEventEnabled(true)
    self:updateTimeLabel(0)
end

function TrusteeshipProtectCountDown:onEnter()
	self.timeScheduler = scheduler.scheduleGlobal(handler(self, self.updateTimeLabel), 1.0)
end

function TrusteeshipProtectCountDown:onExit()
	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
		self.timeScheduler = nil
	end
end
--[[更新显示时间]]
function TrusteeshipProtectCountDown:updateTimeLabel(dt)
	-- --获取系统时间并转为当地时间
	if not self.timeStamp then
		return
	end
	-- if self.timeStamp==0 and self.milsecond==1 then
	if self.timeStamp<1 then
		if self.callback then
			self.callback()
		end
		return
	end
	-- self.milsecond = self.milsecond-1
	-- if self.milsecond==0 then
	-- 	self.milsecond = 59
	-- 	self.timeStamp = self.timeStamp-1
	-- end
	self.timeStamp = self.timeStamp-1
	local minute = math.floor(self.timeStamp/60) 
	local second = math.floor(self.timeStamp%60)
	if minute<10 then
		self.timeLabel1:setString("0"..minute)
	else
		self.timeLabel1:setString(""..minute)
	end
	if second<10 then
		self.timeLabel2:setString("0"..second)
	else
		self.timeLabel2:setString(""..second)
	end
	-- if self.milsecond<10 then
	-- 	self.timeLabel3:setString("0"..self.milsecond)
	-- else
	-- 	self.timeLabel3:setString(""..self.milsecond)
	-- end
end

return TrusteeshipProtectCountDown