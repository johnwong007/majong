local TABLEVIEWGAPX = 32

local TourneyHallTableView = class("TourneyHallTableView", function()
		return display.newNode()
	end)

function TourneyHallTableView:create()

end

function TourneyHallTableView:ctor(params)
	self.matchInfo = params.data
    self.m_pCallbackUI = params.callback
    self.listType = params.listType
	self.tableViewCells={}

	self:initUI()
end

function TourneyHallTableView:initUI()

	local tableWidth = 982
	local tableStartX = 982/2-tableWidth/2
	self.myTableList = data
	tmpViewRect = cc.rect(tableStartX,78+7,tableWidth,387+5)
	
	self.tableView = cc.ui.UIListView.new{
		viewRect = tmpViewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchListener))
		:addTo(self)
	self:initTableCells()
end

function TourneyHallTableView:scrollTo(x, y)
	self.tableView:scrollTo(x, y)
end

function TourneyHallTableView:initTableCells()
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	local tmp = cc.ui.UIImage.new("picdata/tourneyNew/bg_list.png")
	local cellHeight = tmp:getContentSize().height+8
	local cellWidth = tmp:getContentSize().width

	if self.listType==eMatchListMyMatch then
		if self.matchInfo==nil or #self.matchInfo<=0 then
			self.matchInfo = {}
			self.matchInfo[1] = {}
			self.matchInfo[1].isEmptyList = true
			cellHeight = 387
		end
	end 

	if self.matchInfo==nil or #self.matchInfo<=0 then
		return
	end
	for i=1,#self.matchInfo do
	-- for i=1,1 do
		self.matchInfo[i].listType = self.listType
		local item = self.tableView:newItem()
		self.tableViewCells[i] = require("app.GUI.Tourney.TourneyHallTableViewCell").new({data=self.matchInfo[i],height=cellHeight,
			width=cellWidth,callback=self.m_pCallbackUI,index=i})
		item:addContent(self.tableViewCells[i])
		item:setItemSize(982,cellHeight)
		self.tableView:addItem(item)
	end
	self.tableView:reload()
end

function TourneyHallTableView:showMobileImage(filename, cellIndex)
	if self.tableViewCells and #self.tableViewCells>=cellIndex then
    	self.tableViewCells[cellIndex]:showMobileImage(filename) 
		self.tableView:reload()
	end
end


function TourneyHallTableView:touchListener(event)
    -- local listView = event.listView
    -- if "began" == event.name then
       
    -- elseif "clicked" == event.name then
    -- 	if not self:isVisible() then
    -- 		return
    -- 	end
    --     self.hallEnterRoom_delegate:hallEnterRoom(event.item:getContent():getEachInfo())
    -- elseif "moved" == event.name then
       
    -- elseif "ended" == event.name then
        
    -- else
        
    -- end
end

return TourneyHallTableView