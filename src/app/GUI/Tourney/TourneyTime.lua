local scheduler = require("framework.scheduler")

local timeHintColorN = cc.c3b(204,204,204)
local timeHintColorS = cc.c3b(24,255,0)
local timeColorN = cc.c3b(255,255,255)
local timeColorS = cc.c3b(255,102,0)

local TourneyTime = class("TourneyTime", function()
		return display.newNode()
	end)

function TourneyTime:create()

end

function TourneyTime:ctor(params)
    self:setNodeEventEnabled(true)

     -- params.startTime = "2016-04-15 15:56:00"
     -- params.delayTime = 600

	self.preSetStartTime = params.startTime
	self.regDelayTime = params.delayTime
	-- dump(params)

    self.timeBg = cc.ui.UIImage.new("picdata/tourneyNew/bg_time.png")
        :align(display.CENTER, 0, 0)
        :addTo(self)
    self.timeHint = cc.ui.UILabel.new({
                text = ""--[[.."延迟登记"]],
                font = "黑体",
                size = 20,
                color = timeHintColorS,
                align = cc.TEXT_ALIGNMENT_CENTER
                })
    self.timeHint:align(display.CENTER, self.timeBg:getContentSize().width/2, 
    	self.timeBg:getContentSize().height-15)
    self.timeHint:addTo(self.timeBg)

    -- self.timeLine = cc.ui.UIImage.new("picdata/tourneyNew/bg_time_line.png")
    --     :align(display.CENTER, self.timeBg:getContentSize().width/2, timePosY)
    --     :addTo(self.timeBg, 1)

    local timeGap = 22
    local timePosY = 28
    self.timeLabel1 = cc.ui.UILabel.new({
                text = ""--[[.."20"]],
                font = "fonts/digitalNum_w.fnt",
                size = 22,
                color = timeColorS,
                align = cc.TEXT_ALIGNMENT_CENTER,
                UILabelType = 1,
                }) 
    self.timeLabel1:align(display.CENTER, self.timeBg:getContentSize().width/2-timeGap, 
    	timePosY)
    self.timeLabel1:addTo(self.timeBg)

    self.timeLabel2 = cc.ui.UILabel.new({
                text = ""--[[.."30"]],
                font = "fonts/digitalNum_w.fnt",
                size = 22,
                color = timeColorS,
                align = cc.TEXT_ALIGNMENT_CENTER,
                UILabelType = 1,
                }) 
    self.timeLabel2:align(display.CENTER, self.timeBg:getContentSize().width/2+timeGap+1, 
    	timePosY)
    self.timeLabel2:addTo(self.timeBg)
    self:updateTimeLabel(0)
end

function TourneyTime:onEnter()
	self.timeScheduler = scheduler.scheduleGlobal(handler(self, self.updateTimeLabel), 1)
end

function TourneyTime:onExit()
	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
		self.timeScheduler = nil
	end
end
--[[更新显示时间]]
function TourneyTime:updateTimeLabel(dt)
	-- --获取系统时间并转为当地时间
	-- -- local date=os.date("%Y-%m-%d %H:%M:%S")
	-- local currDate = os.date("%H:%M:%S")
	-- -- dump(currDate)
	-- if self.m_tTimeLabel then
	-- 	self.m_tTimeLabel:setString("系统时间:"..currDate)
	-- end
	-- -- dump(self.destroyTime)
	-- -- self.destroyTime = "2016-04-08 13:52:40"
	-- if self.destroyTime and self.m_tTimeRemainLabel then
	-- 	local remainTime = EStringTime:getTimeFromNow(self.destroyTime)
	-- 	self.m_tTimeRemainLabel:setString("剩余时间:"..remainTime)
	-- end

	-- local timestampDelta = EStringTime:getTimeStampFromNow(self.destroyTime)
	-- if timestampDelta<26 and timestampDelta>24 then
 --    	self:showCountDown(true, 25, 0, 1, 1)
	-- end 

    local timeStamp = EStringTime:getTimeStampFromNow(self.preSetStartTime)
    if timeStamp>0 then 
        local time = EStringTime:create(self.preSetStartTime)
        local value1 = tonumber(time.hour)
        local value2 = tonumber(time.minute)
        if value1<0 then
            value1 = 0
        end
        if value2<0 then
            value2 = 0
        end
        if value1<10 then
            self.timeLabel1:setString("0"..value1)
        else
            self.timeLabel1:setString(""..value1)
        end
        if value2<10 then
            self.timeLabel2:setString("0"..value2)
        else
            self.timeLabel2:setString(""..value2)
        end
        self.timeLabel1:setColor(timeColorN)
        self.timeLabel2:setColor(timeColorN)

        if timeStamp<30*60+1 then
            local min = math.floor(timeStamp/60)
            if min>0 then
                self.timeHint:setString(min.."分钟开赛")
                self.timeHint:setColor(timeHintColorS)
            else
                if timeStamp < 0 then
                    timeStamp = 0
                end
                self.timeHint:setString(timeStamp.."秒后开赛")
                self.timeHint:setColor(timeHintColorS)
            end
        else
            local timeOs = os.date("*t")
            local tmp_time = EStringTime.new()
            tmp_time.year = timeOs.year
            tmp_time.month = timeOs.month
            tmp_time.day = timeOs.day
            tmp_time.hour = timeOs.hour
            tmp_time.minute = timeOs.min
            tmp_time.second = timeOs.sec
            local days = EStringTime:getSubDayOfAThanB(time, tmp_time)
            local str = ""
            if days==0 then
                str = "今天"
            elseif days==1 then
                str = "明天"
            else
                str = time.year.."/"..time.month.."/"..time.day
            end
            self.timeHint:setString(str)
            self.timeHint:setColor(timeHintColorN)
        end
    else
        timeStamp = -timeStamp
        if timeStamp < tonumber(self.regDelayTime) then
            local min = math.floor(timeStamp/60)
            local sec = timeStamp%60
            self.timeHint:setString("延迟登记")
            self.timeHint:setColor(timeHintColorN)
            self.timeLabel1:setColor(timeColorS)
            self.timeLabel2:setColor(timeColorS)

            if min<1 then
                min = 0
            end
            if sec<1 then
                sec = 0
            end
            if min<10 then
                self.timeLabel1:setString("0"..min)
            else
                self.timeLabel1:setString(""..min)
            end
            if sec<10 then
                self.timeLabel2:setString("0"..sec)
            else
                self.timeLabel2:setString(""..sec)
            end
        else
            local time = EStringTime:create(self.preSetStartTime)
            local value1 = tonumber(time.hour)
            local value2 = tonumber(time.minute)
            if value1<0 then
                value1 = 0
            end
            if value2<0 then
                value2 = 0
            end
            if value1<10 then
                self.timeLabel1:setString("0"..value1)
            else
                self.timeLabel1:setString(""..value1)
            end
            if value2<10 then
                self.timeLabel2:setString("0"..value2)
            else
                self.timeLabel2:setString(""..value2)
            end
        
            self.timeHint:setString("进行中")
            self.timeHint:setColor(timeHintColorN)
            self.timeLabel1:setColor(timeColorN)
            self.timeLabel2:setColor(timeColorN)
        end
    end
end

return TourneyTime