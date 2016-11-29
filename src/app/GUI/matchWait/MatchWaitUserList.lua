--
-- Author: wangj
-- Date: 2016-05-24 17:24:45
--

local MatchWaitUserList = class("MatchWaitUserList", function()
	return display.newNode()
end)

function MatchWaitUserList:create()
	self:initUI()
end

function MatchWaitUserList:ctor(params)
	self.params = params or {}
	self.m_sourceData = self.params.data
	self.params.viewRect = self.params.viewRect or cc.rect(0,0,CONFIG_SCREEN_WIDTH,CONFIG_SCREEN_HEIGHT)
end

function MatchWaitUserList:initUI()
	self.tableView = cc.ui.UIListView.new{
		viewRect = self.params.viewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		-- :onTouch(handler(self, self.touchListener))
		:addTo(self)
	self:initTableCells()
end

function MatchWaitUserList:initTableCells()
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.params.data==nil then
		return
	end

	local start = -self.params.viewRect.width/2+110
	local padding = self.params.viewRect.width/3-20

	local showKickButton = true
	if not self.params.isOwner or self.params.roomType~="MTT" or self.params.hideKickButton then
		start = -self.params.viewRect.width/2+150
		padding = self.params.viewRect.width/2
		showKickButton = false
	end
	for i=1,#self.params.data do
		local item = self.tableView:newItem()
		
		local node = display.newNode()

		local bg = cc.ui.UIImage.new("picdata/public2/bg_list2.png", {scale9 = true})
	    bg:align(display.CENTER, 0, 0)
	        :addTo(node)
	    bg:setLayoutSize(884, 84)

		-- local first = cc.ui.UILabel.new({
		-- 	text = self.m_sourceData[i].first,
		-- 	font = "Arial",
		-- 	size = 16,
		-- 	color = cc.c3b(185,185,202),
		-- 	align = cc.TEXT_ALIGNMENT_LEFT,
		-- 	-- valign = cc.TEXT_VALIGNMENT_BOTTOM
		-- 	})
		-- first:align(display.LEFT_CENTER, start, 0)
		-- first:addTo(node)

		local second = cc.ui.UILabel.new({
			text = self.m_sourceData[i].second,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT,
			-- valign = cc.TEXT_VALIGNMENT_BOTTOM
			})
		second:align(display.LEFT_CENTER, start, 0)
		second:addTo(node)

		local third= cc.ui.UILabel.new({
			text = "UID:"..self.m_sourceData[i].third,
			font = "Arial",
			size = 24,
			color = cc.c3b(164,195,255),
			align = cc.TEXT_ALIGNMENT_LEFT,
			-- valign = cc.TEXT_VALIGNMENT_BOTTOM
			})
		third:align(display.LEFT_CENTER, start+padding, 0)
		third:addTo(node)

		if showKickButton then
			local button = cc.ui.UIPushButton.new({normal="picdata/public2/btn_h50_blue.png", pressed="picdata/public2/btn_h50_blue2.png", 
				disabled="picdata/public2/btn_h50_blue2.png"})
			button:setTag(i)
			button:align(display.CENTER, start+padding*2+40, 0)
				:addTo(node, 1)
				:onButtonClicked(function(event)
					self:kickUser(event)
					end)
				:setTouchSwallowEnabled(false)

			local label = cc.ui.UILabel.new({
				text = "踢出比赛",
				font = "黑体",
				size = 28,
				color = cc.c3b(161,184,229)
				})
		    label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
			button:setButtonLabel("normal", label)
		end

		item:addContent(node)
		item:setItemSize(self.params.viewRect.width,90)
		self.tableView:addItem(item)
	end
	self.tableView:reload()
end

function MatchWaitUserList:kickUser(event)
	local node = event.target
	local index = node:getTag()
	local userId = self.m_sourceData[index].third
	if self.params.kickUserCallback then
		self.params.kickUserCallback(userId)
	end
end

return MatchWaitUserList