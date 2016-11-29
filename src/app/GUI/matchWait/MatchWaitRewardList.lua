--
-- Author: wangj
-- Date: 2016-05-24 17:24:45
--
local sng_reward_conent = "朋友局SNG比赛属于德堡德州扑克平台的体验赛事，\n只显示玩家排名不提供奖励"

local MatchWaitRewardList = class("MatchWaitRewardList", function()
	return display.newNode()
end)

function MatchWaitRewardList:create()
	self:initUI()
end

function MatchWaitRewardList:ctor(params)
	self.params = params or {}
	self.m_sourceData = self.params.data
	self.params.viewRect = self.params.viewRect or cc.rect(0,0,CONFIG_SCREEN_WIDTH,CONFIG_SCREEN_HEIGHT)
end

function MatchWaitRewardList:initUI()
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

function MatchWaitRewardList:initTableCells()

	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.params.data==nil then
		return
	end

	local start = -self.params.viewRect.width/2+160
	local padding = self.params.viewRect.width/3-32
	for i=1,#self.params.data do
		local pos = string.find(self.m_sourceData[i].second, "金币")
		if pos then
			self.m_sourceData[i].second = string.sub(self.m_sourceData[i].second,1,pos-1)
		end

		local item = self.tableView:newItem()
		
		local node = display.newNode()

		local first = cc.ui.UILabel.new({
			text = self.m_sourceData[i].first,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT,
			-- valign = cc.TEXT_VALIGNMENT_BOTTOM
			})
		first:align(display.LEFT_CENTER, start, 0)
		first:addTo(node)

		local second = cc.ui.UILabel.new({
			text = self.m_sourceData[i].second,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT,
			-- valign = cc.TEXT_VALIGNMENT_BOTTOM
			})
		second:align(display.LEFT_CENTER, start+padding, 0)
		second:addTo(node)

		local image = cc.ui.UIImage.new("picdata/public2/icon_dbz.png")
			:align(display.RIGHT_CENTER, start+padding*2+20, 0)
			:addTo(node)
		image:setScale(0.5)

		local third= cc.ui.UILabel.new({
			text = self.m_sourceData[i].third,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT,
			-- valign = cc.TEXT_VALIGNMENT_BOTTOM
			})
		third:align(display.LEFT_CENTER, image:getPositionX(), 0)
		third:addTo(node)
		item:addContent(node)
		item:setItemSize(self.params.viewRect.width,80)
		self.tableView:addItem(item)
	end
	self.tableView:reload()
end

function MatchWaitRewardList:initSngTableCells()

	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	for i=1,1 do
		local item = self.tableView:newItem()
			
		local node = display.newNode()

		local first = cc.ui.UILabel.new({
			text = sng_reward_conent,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255)
			})
		first:align(display.CENTER, 0, 0)
		first:addTo(node)

		item:addContent(node)
		item:setItemSize(self.params.viewRect.width,self.params.viewRect.height*0.7)
		self.tableView:addItem(item)
	end
	self.tableView:reload()
end

return MatchWaitRewardList