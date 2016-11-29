require("app.Tools.StringFormat")

--获取变化的筹码差值
--相差10以内，变化单位为1
--相差10以上，变化单位为差值/10
local function setIncreaseNum(realchips, outChips)

	local num = math.abs(realchips - outChips)
	num = num / 10
	return (num > 1) and num or 1
end

local ChipLabel = class("ChipLabel", function()
		return cc.ui.UILabel:new()
	end)
-- local ChipLabel = class("ChipLabel", function()
-- 		return cc.ui.UILabel.new({
-- 		text="", 
-- 		font = "FZZCHJW--GB1-0", 
-- 		size=30,
-- 		color=cc.c3b(255,241,0)})
-- 	end)

function ChipLabel:create(num, fntFile, width)
	local pRet = ChipLabel:new()
	local str = StringFormat:FormatDecimals(num,2)
	pRet:setString(""..str)
	pRet:setOutlChips(num)
	pRet:setRealChips(num)
	pRet:setStaticChips(num)
	return pRet
end

function ChipLabel:ctor()
	self.m_bHavePoint = false
	self.m_outChips = 0.0
	self.m_realChips = 0.0
	self:setNodeEventEnabled(true)
end

function ChipLabel:onNodeEvent(event)
	if event == "exit" then
		self:onExit()
	end
end

function ChipLabel:onExit()
	if self.m_updateID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_updateID)
		self.m_updateID = nil
	end
end

function ChipLabel:updateLabel(dt)
	local _index = 0
	if self.m_outChips == nil or self.m_realChips == nil then
		if self.m_updateID then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_updateID)
			self.m_updateID = nil
		end
		return
	end
	local i = setIncreaseNum(self.m_outChips,self.m_realChips)
    
	--差值变化在1以为，直接改变
	if math.abs(self.m_realChips-self.m_outChips) < 1.0 then
		self.m_outChips = self.m_realChips
		local str = self:laber_strExchange()
		if str==nil or string.len(str)<1 then
			self:setString("0")
		else
			self:setString(str)
		end
	--显示筹码增加
	elseif(self.m_realChips > self.m_outChips) then
		self.m_outChips = self.m_outChips + i
		local str = self:laber_strExchange()
		if str==nil or string.len(str)<1 then
			self:setString("0")
		else
			self:setString(str)
		end
	elseif (self.m_realChips < self.m_outChips) then
		self.m_outChips = self.m_outChips - i
		local str = self:laber_strExchange()
		if str==nil or string.len(str)<1 then
			self:setString("0")
		else
			self:setString(str)
		end
	end
end


--[[获取真实筹码数量]]
function ChipLabel:getRealChips() 
 	return self.m_realChips
end
    
--[[设置是否显示小数位]]
function ChipLabel:setHasPoint(hasPoint)  
	self.m_bHavePoint = hasPoint
end

--设置真实筹码
function ChipLabel:setRealChips(chips) 
	chips = chips and chips or 0.0
	self.m_realChips = chips
end
    
	--设置显示筹码
function ChipLabel:setOutlChips(chips)
	chips = chips and chips or 0.0
	self.m_outChips = chips
end

function ChipLabel:setChips(chips)
	chips = chips and chips or 0.0
	self.m_realChips = chips
	self.m_updateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateLabel),0.01,false)
end

function ChipLabel:addChips(chips)
	chips = chips and chips or 0.0

	self.m_realChips = self.m_realChips + chips
	self.m_updateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateLabel),0.01,false)
end

function ChipLabel:setStaticChips(chips)
	chips = chips and chips or 0.0

	self.m_realChips = chips
	self.m_outChips  = chips
	local str = self:laber_strExchange()
	self:setString(str)
end


function ChipLabel:laber_strExchange()
	local result = StringFormat:FormatDecimals(self.m_outChips,2)
	return result
end

function ChipLabel:setAlignment(alignment)
	self:setHorizontalAlignment(alignment)
end
return ChipLabel