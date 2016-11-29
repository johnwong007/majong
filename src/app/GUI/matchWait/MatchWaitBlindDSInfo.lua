--
-- Author: wangj
-- Date: 2016-05-25 11:35:10
--
--
-- Author: wangj
-- Date: 2016-05-24 17:24:45
--
local title_content = {
	"级别",
	"小盲/大盲",
	"前注",
	"持续时间"
}

local MatchWaitBlindDSInfo = class("MatchWaitBlindDSInfo", function()
	return display.newNode()
end)

function MatchWaitBlindDSInfo:create()
	self:initUI()
end

function MatchWaitBlindDSInfo:ctor(params)
	self.params = params or {}
	self.m_sourceData = self.params.data
	self.params.viewRect = self.params.viewRect or cc.rect(0,0,CONFIG_SCREEN_WIDTH,CONFIG_SCREEN_HEIGHT)

	self.m_startPosX = 160
	self.m_padding = self.params.viewRect.width/4-32
end

function MatchWaitBlindDSInfo:initUI()
	for i=1,#title_content do
		cc.ui.UILabel.new({
			text = title_content[i],
			font = "Arial",
			size = 20,
			color = cc.c3b(164,195,255)
			})
		:align(display.CENTER, self.m_startPosX+self.m_padding*(i-1), self.params.viewRect.height-30)
		:addTo(self)
	end
	local line = cc.ui.UIImage.new("picdata/public2/bg_tc_line.png", {scale9 = true})
	line:align(display.CENTER, self.params.viewRect.width/2, self.params.viewRect.height-60)
	    :addTo(self)
	line:setLayoutSize(self.params.viewRect.width-20, 4)

	local tableViewRect = self.params.viewRect
	tableViewRect.height = tableViewRect.height - 60
	self.tableView = cc.ui.UIListView.new{
		viewRect = tableViewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		-- :onTouch(handler(self, self.touchListener))
		:addTo(self)
	self:initTableCells()
end

function MatchWaitBlindDSInfo:initTableCells()

	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.params.data==nil then
		return
	end

	local start = -self.params.viewRect.width/2+self.m_startPosX
	local padding = self.m_padding

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
			})
		first:align(display.CENTER, start, 0)
		first:addTo(node)

		local second = cc.ui.UILabel.new({
			text = self.m_sourceData[i].second,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			})
		second:align(display.CENTER, start+padding, 0)
		second:addTo(node)

		local third= cc.ui.UILabel.new({
			text = self.m_sourceData[i].third,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			})
		third:align(display.CENTER, start+padding*2, 0)
		third:addTo(node)

		local forth = cc.ui.UILabel.new({
			text = self.m_sourceData[i].forth,
			font = "黑体",
			size = 24,
			color = cc.c3b(255,255,255),
			})
		forth:align(display.CENTER, start+padding*3, 0)
		forth:addTo(node)

		item:addContent(node)
		item:setItemSize(self.params.viewRect.width,80)
		self.tableView:addItem(item)
	end
	self.tableView:reload()
end

return MatchWaitBlindDSInfo