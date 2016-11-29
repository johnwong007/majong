--[[服务器传过来的时间格式为 "2015-10-23 20:30:00"]]
EStringTime = class("EStringTime")

--[[time->string]]
function EStringTime:create(time)
	local p = EStringTime:new()
	p:setTime(time)
	return p
end

function EStringTime:ctor()
	self.year = 0
	self.month = 0
	self.day = 0
	self.hour = 0
	self.minute = 0
	self.second = 0
end

function EStringTime:setTime(time)
	if not time then
		return
	end 
	if string.len(time)<10 then
		return
	end

	self.year = tonumber(string.sub(time,1,4))
	self.month = tonumber(string.sub(time,6,7))
	self.day = tonumber(string.sub(time,9,10))

	if string.len(time)<19 then
		return
	end

	self.hour = tonumber(string.sub(time,12,13))
	self.minute = tonumber(string.sub(time,15,16))
	self.second = tonumber(string.sub(time,18,19))
end

function EStringTime:getTimeStamp()
	local tmp_time = {}
	tmp_time.year = self.year
	tmp_time.month = self.month
	tmp_time.day = self.day
	tmp_time.hour = self.hour
	tmp_time.min = self.minute
	tmp_time.sec = self.second
	tmp_time.isdst=false

    local timestamp = os.time(tmp_time)
    return timestamp
end

--[[获取两时间差]]
function EStringTime:getTimeStampFromNow(time)
	if not time then
		return 10000
	end
	local eStringTime1 = EStringTime:create(time)
	local timestamp = eStringTime1:getTimeStamp()
	if not timestamp and timestamp<0 then
		return 10000
	end

	local time1 = os.date("*t")

	local tmp_time = {}
	tmp_time.year = time1.year
	tmp_time.month = time1.month
	tmp_time.day = time1.day
	tmp_time.hour = time1.hour
	tmp_time.min = time1.min
	tmp_time.sec = time1.sec
	tmp_time.isdst=false
    local timestampNow = os.time(tmp_time)
	local timestampDelta = timestamp - timestampNow
	return tonumber(timestampDelta)
end

--[[获取两时间差]]
function EStringTime:getTimeFromNow(time)
	if not time then
		return "00:00:00"
	end
	local eStringTime1 = EStringTime:create(time)
	local timestamp = eStringTime1:getTimeStamp()
	if not timestamp then
		return "00:00:00"
	end

	local time1 = os.date("*t")

	local tmp_time = {}
	tmp_time.year = time1.year
	tmp_time.month = time1.month
	tmp_time.day = time1.day
	tmp_time.hour = time1.hour
	tmp_time.min = time1.min
	tmp_time.sec = time1.sec
	tmp_time.isdst=false
    local timestampNow = os.time(tmp_time)
	local timestampDelta = timestamp - timestampNow
	if timestampDelta<0 then
		return "00:00:00"
	end

	local hour = math.floor(timestampDelta/3600)
	timestampDelta = timestampDelta%3600
	local min = math.floor(timestampDelta/60)
	local sec = math.floor(timestampDelta%60)
	local result = ""
	if hour<10 then
		result = result.."0"..hour
	else
		result = result..hour
	end
	result = result..":"
	if min<10 then
		result = result.."0"..min
	else
		result = result..min
	end
	result = result..":"
	if sec<10 then
		result = result.."0"..sec
	else
		result = result..sec
	end
	return result
end

function EStringTime:getTwoHoursLaterFromNow()
	local time1 = os.date("*t")
	local tmp_time = {}
	tmp_time.year = time1.year
	tmp_time.month = time1.month
	tmp_time.day = time1.day
	tmp_time.hour = time1.hour
	tmp_time.min = time1.min
	tmp_time.sec = 0
	tmp_time.isdst=false
    local timestamp = os.time(tmp_time)
    local delta = 3600*2
    delta = delta-tmp_time.min%10*60
    timestamp = timestamp+delta

	local t = os.date("*t",timestamp)
	local result = ""..t.year.."-"
	if t.month/10<1 then
		result = result.."0"..t.month
	else
		result = result..t.month
	end
	result = result.."-"
	if t.day/10<1 then
		result = result.."0"..t.day
	else
		result = result..t.day
	end
	result = result.." "
	if t.hour/10<1 then
		result = result.."0"..t.hour
	else
		result = result..t.hour
	end
	result = result..":"
	if t.min/10<1 then
		result = result.."0"..t.min
	else
		result = result..t.min
	end
	result = result..":".."00"
	return result
end

function EStringTime:isBiger(otherTime)
	-- print(""..otherTime.year..otherTime.month..otherTime.day..otherTime.hour..otherTime.minute..otherTime.second)
	-- print(""..self.year..self.month..self.day..self.hour..self.minute..self.second)
	local otherTimeSeconds = otherTime.year*365*24*3600 + otherTime.month*30*24*3600 + 
	otherTime.day*24*3600 + otherTime.hour*3600 + otherTime.minute*60 + otherTime.second
	local thisTimeSeconds = self.year*365*24*3600 + self.month*30*24*3600 + self.day*24*3600 + 
	self.hour*3600 + self.minute*60 + self.second
	return thisTimeSeconds>otherTimeSeconds
end

function EStringTime:getYMDTime()
	return ""..self.year.."-"..self.month.."-"..self.day
end

function EStringTime:get_yymmdd_time()
	return ""..string.sub(self.year,3,4).."/"..self.month.."/"..self.day
end

function EStringTime:get_mmddhh_time()
	return ""..self.month.."/"..self.day.." "..self.hour..":"..self.minute
end

function EStringTime:IntToString(number)
	local res = ""..number
	if (number+0)<10 then
		res = "0"..res
	end
	return res
end

function EStringTime:ItoA2(tag)
	return ""..tag
end

function EStringTime:daysOftimeSpan(time1, time2)
	local m = self.getSubDayOfAThanB(time1,time2)
	return m>0 and m or -1*m
end

function EStringTime:getSubDayOfAThanB(time1, time2)
	local monDays = {31,0,31,30,31,30,31,31,30,31,30,31,}
	local year1 = time1.year
	local year2 = time2.year
	local mon1 = time1.month
	local mon2 = time2.month
	local day1 = time1.day
	local day2 = time2.day
	local days1=0
	local days2=0
	for i=1,mon1-1 do
		days1=days1+monDays[i]
	end
	if (year1%400==0 or (year1%400~=0 and year1%4==0)) and mon1>2 then
		days1=days1+29
	else
		days1=days1+28
	end
	days1=days1+day1


	for i=1,mon2-1 do
		days2=days2+monDays[i]
	end
	if (year1%400==0 or (year1%400~=0 and year1%4==0)) and mon2>2 then
		days2=days2+29
	else
		days2=days2+28
	end
	days2=days2+day2
    
	for i=year1,year2-1 do
		if i%400==0 or (i%400~=0 and i%4==0) then
			days2=days2+366
		else
			days2=days2+365
		end
	end
	for i=year2,year1-1 do
		if i%400==0 or (i%400~=0 and i%4==0) then
			days1=days1+366
		else
			days1=days1+365
		end
	end
	local m = days1 - days2
	return m
end

function EStringTime:getSubHourOfAThanB(time1, time2)
	local subDay = self:getSubDayOfAThanB(time1,time2)
	local subHour = subDay*24+time1.hour - time2.hour
	return subHour
end

--[[今天是不是给定星期几]]
-- function EStringTime:isTheGivenWeekday(params)
-- 	if true then
-- 		return false
-- 	end
-- 	if not params or #params<1 then
-- 		return true
-- 	end
-- 	local bRet = false
-- 	local time = os.date("*t")
-- 	-- time.wday = 1
-- 	for i=1,#params do
-- 		if time.wday == params[i] then
-- 			bRet = true
-- 			break
-- 		end		
-- 	end
-- 	return bRet
-- end


----------------------------------------------------------

ETimeDeal = class("ETimeDeal")


--[[
m_timeStamp为int类型时间，即毫秒数
转换为table格式的时间方法为os.date("*t",1131286710)
{year=2005, month=11, day=6, hour=22,min=18,sec=30}
获取方法tab = os.date("*t")
]]
function ETimeDeal:create(timeStamp)
	local p = ETimeDeal:new()
	p:setTimeStamp(timeStamp)
	return p
end

function ETimeDeal:ctor()

end

function ETimeDeal:setTimeStamp(timeStamp)
	self.m_timeStamp = timeStamp
	local t = os.date("*t",timeStamp)
	self.m_year = t.year
	self.m_month = t.month
	self.m_day = t.day
	self.m_hour = t.hour
	self.m_minute = t.min
	self.m_second = t.sec
end

function ETimeDeal:isFirstTimeToday(lastTime)
	if lastTime==nil then
		return false
	end
	if(lastTime.m_year > self.m_year 
	or lastTime.m_month > self.m_month 
	or lastTime.m_day > self.m_day) then
		return false
	end
    
	local n = self.m_year - lastTime.m_year 
	+ self.m_day - lastTime.m_day 
	+ self.m_month - lastTime.m_month
	return n > 0
end

function ETimeDeal:daysAfterLastTime(lastTime)
	if lastTime==nil then
		return 0
	end
	if(lastTime.m_year > self.m_year 
	or lastTime.m_month > self.m_month 
	or lastTime.m_day > self.m_day) then
		return false
    end
	local n = self.m_timeStamp - lastTime.m_timeStamp
    
	n = n /(3600 * 24)
	return n
end

--[[
const char* timeA, 
const char* timeB
]]
function ETimeDeal:isCurrentBetweenAAndB(timeA, timeB)
	local tempA = timeA
	local hourA = string.sub(tempA, 1, 2)+0
	local minuteA = string.sub(tempA, 4, 4)+0
    
	local tempB = timeB
	local hourB = string.sub(timeB, 1, 2)+0
	local minuteB = string.sub(timeB, 4, 4)+0
    
	if ((self.m_hour > hourA or (self.m_hour == hourA and minuteA < self.m_minute)) and
		(self.m_hour < hourB or (self.m_hour == hourB and minuteB > self.m_minute))) then
		return true
	end
	return false
end

--[[
const char* timeA
]]
function ETimeDeal:secondsAfterTimeA(timeA)
	local tempA = timeA
	local hourA = string.sub(timeA, 1, 2)+0
	local minuteA = string.sub(timeA, 4, 4)+0
    
	return (self.m_hour - hourA) * 3600 + (self.m_minute - minuteA) * 60
end









