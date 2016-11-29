--
-- Author: wangj
-- Date: 2016-05-23 11:14:49
--
local match_detail_field = {
	"总奖池：",
	"报名费：",
	"起始筹码：",
	"单桌人数：",
	"总人数：",
	"开赛时间：",
	-- "升盲时间：",
	"重购费用：",
	"重购筹码：",
	"重购时间限制：",
	"重购次数限制：",
	"重购条件：",
	"加码费用：",
	"加码筹码：",
	"加码次数：",
	"加码条件："
}

local table_change_line = {
	2,
	2,
	2,
	1,
	2,
	1,
	1,
	2,
	1,
	1,
	1
}


local match_detail_field_sng = {
	"报名费：",
	"起始筹码：",
	"单桌人数：",
	"总人数：",
	"开赛时间：",
	"升盲时间："
}

local MatchWaitDetail = class("MatchWaitDetail", function()
	return display.newNode()
end)

function MatchWaitDetail:create()
	self:initUI()
end

function MatchWaitDetail:ctor(params)
	self.params = params or {}
	self.params.viewRect = self.params.viewRect or cc.rect(0,0,CONFIG_SCREEN_WIDTH,CONFIG_SCREEN_HEIGHT)
end

function MatchWaitDetail:initUI()
	self.tableView = cc.ui.UIListView.new{
		viewRect = self.params.viewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		-- :onTouch(handler(self, self.touchListener))
		:addTo(self)
	if self.params.roomType == "MTT" then
		self:initTableCells()
	else
		self:initSngTableCells()
	end
end

function MatchWaitDetail:initSngTableCells()
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.params.matchInfo==nil then
		return
	end

	self.matchDetailInfo = {}
	self.matchDetailInfo[#self.matchDetailInfo+1] = "免费"
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.initChips)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.seatNum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.curUnum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = "坐满开赛"
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.upSeconds)

	local posx1 = -self.params.viewRect.width/2+160
	local posx2 = 20
	local currentIndex=1
	while true do
		local item = self.tableView:newItem()
		
		local node = display.newNode()
		local label = cc.ui.UILabel.new({
			text = match_detail_field_sng[currentIndex],
			font = "黑体",
			size = 26,
			color = cc.c3b(164,195,255),
			align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, posx1, 0)
		:addTo(node)
		
		local label1 = cc.ui.UILabel.new({
			text = self.matchDetailInfo[currentIndex],
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label:getPositionX()+label:getContentSize().width+5, label:getPositionY())
		:addTo(node)

		currentIndex = currentIndex+1
		local label3 = cc.ui.UILabel.new({
			text = match_detail_field_sng[currentIndex],
			font = "黑体",
			size = 26,
			color = cc.c3b(164,195,255),
			align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, posx2, 0)
		:addTo(node)

		local label4 = cc.ui.UILabel.new({
			text = self.matchDetailInfo[currentIndex],
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label3:getPositionX()+label3:getContentSize().width+5, label3:getPositionY())
		:addTo(node)

		item:addContent(node)
		item:setItemSize(self.params.viewRect.width,80)
		self.tableView:addItem(item)

		currentIndex = currentIndex+1
		if currentIndex>=#match_detail_field_sng then
			break
		end
	end
	self.tableView:reload()
end

function MatchWaitDetail:initTableCells()
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.params.matchInfo==nil then
		return
	end

	local payNum = tonumber(self.params.matchInfo.payNum)
	local serviceNum = self.params.matchInfo.serviceCharge
	local entryFee = payNum+serviceNum
	self.matchDetailInfo = {}
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.curUnum*payNum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(""..payNum.."+"..serviceNum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.initChips)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.seatNum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.curUnum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = string.sub(self.params.matchInfo.presetStartTime, 1, 16)
	-- self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(180)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(""..payNum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.initChips)
	self.matchDetailInfo[#self.matchDetailInfo+1] = "15 分钟内"
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(100)
	self.matchDetailInfo[#self.matchDetailInfo+1] =	"玩家筹码小于或等于初始筹码"
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(""..payNum)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(self.params.matchInfo.initChips*2)
	self.matchDetailInfo[#self.matchDetailInfo+1] = tostring(1)
	self.matchDetailInfo[#self.matchDetailInfo+1] = "重购筹码时段结束后，玩家可进行1次最终加码"


	local posx1 = -self.params.viewRect.width/2+160
	local posx2 = 20
	local curLineItemNumIndex = 1
	local currentIndex=1
	local totalNum = #match_detail_field
	while true do
		local item = self.tableView:newItem()
		
		local node = display.newNode()
		local label = cc.ui.UILabel.new({
			text = match_detail_field[currentIndex],
			font = "黑体",
			size = 26,
			color = cc.c3b(164,195,255),
			align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, posx1, 0)
		:addTo(node)
		
		local label1 = cc.ui.UILabel.new({
			text = self.matchDetailInfo[currentIndex],
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label:getPositionX()+label:getContentSize().width+5, label:getPositionY())
		:addTo(node)

		if table_change_line[curLineItemNumIndex] and table_change_line[curLineItemNumIndex]>1 then
			currentIndex = currentIndex+1
			local label3 = cc.ui.UILabel.new({
				text = match_detail_field[currentIndex],
				font = "黑体",
				size = 26,
				color = cc.c3b(164,195,255),
				align = cc.TEXT_ALIGNMENT_LEFT
			})
			:align(display.LEFT_CENTER, posx2, 0)
			:addTo(node)

			local label4 = cc.ui.UILabel.new({
				text = self.matchDetailInfo[currentIndex],
				font = "黑体",
				size = 24,
				color = cc.c3b(255,255,255),
				align = cc.TEXT_ALIGNMENT_LEFT
			})
			:align(display.LEFT_CENTER, label3:getPositionX()+label3:getContentSize().width+5, label3:getPositionY())
			:addTo(node)
		end
		item:addContent(node)
		item:setItemSize(self.params.viewRect.width,80)
		self.tableView:addItem(item)

		curLineItemNumIndex = curLineItemNumIndex+1
		currentIndex = currentIndex+1
		if curLineItemNumIndex==#table_change_line then
			break
		end
		if self.params.matchInfo.rebuyLimitCount<=0 and currentIndex>5 then
			break
		end
	end
	self.tableView:reload()
end

return MatchWaitDetail