local TABLEVIEWGAPX = 32

local HallTableView = class("HallTableView", function()
		return display.newNode()
	end)

function HallTableView:createWithData(data, leftGameLevel, bShowBullet)
	local sp = HallTableView:new()
	if sp then
		sp:initWith(data, leftGameLevel, bShowBullet)
		return sp
	end
	return display.newLayer()
end

function HallTableView:ctor()
	self.myTableList = {}
	self.tableViewCells={}
end

function HallTableView:initWith(data, leftGameLevel, bShowBullet)

	local tableWidth = 960-TABLEVIEWGAPX*2
	local tableStartX = CONFIG_SCREEN_WIDTH/2-tableWidth/2
	self.myTableList = data
	tmpViewRect = cc.rect(tableStartX,88,960-TABLEVIEWGAPX*2,387)
	if leftGameLevel==Left_Private then
		tmpViewRect = cc.rect(tableStartX,0,960-TABLEVIEWGAPX*2,415)
	end
	self.tableView = cc.ui.UIListView.new{
		viewRect = tmpViewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchListener))
		:addTo(self)
	self.leftGameLevel = leftGameLevel
	if leftGameLevel==Left_PrimaryField then
		self:initTableCells()
	elseif leftGameLevel==Left_IntermediateCourse or leftGameLevel==Left_Senior then
		self:initTableCells()
	elseif leftGameLevel==Left_Private then
		self:initPrivateTableCells()
	end
end

function HallTableView:scrollTo(x, y)
	self.tableView:scrollTo(x, y)
end

function HallTableView:setHallEnterRoomDelegate(delegate)
    self.hallEnterRoom_delegate = delegate
end

function HallTableView:initTableCells()
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.myTableList==nil or #self.myTableList.tableList<=0 then
		return
	end

	for i=1,#self.myTableList.nowIndexList do
		local item = self.tableView:newItem()
		self.tableViewCells[i] = require("app.GUI.hallview.HallTableViewCell"):new(self, self.leftGameLevel)
		item:addContent(self.tableViewCells[i])
		-- item:setItemSize(120,80)
		if self.leftGameLevel==Left_PrimaryField then
			item:setItemSize(882,108)
		elseif self.leftGameLevel==Left_IntermediateCourse or self.leftGameLevel==Left_Senior then
			item:setItemSize(882,80)
		end
		
		self.tableView:addItem(item)
		self.tableViewCells[i]:resetData(self.myTableList.tableList[self.myTableList.nowIndexList[i]])
	end
	self.tableView:reload()
end

function HallTableView:initPrivateTableCells()
	if self.tableViewCells then
		self.tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.myTableList==nil or #self.myTableList.tableList<=0 then
		-- return
	end
	local count = #self.myTableList.nowIndexList
	count = count + 1
	local maxCellNum = math.ceil(count/3)
	for i=1,maxCellNum do
		local jMax = 3
		if i==maxCellNum then
			jMax = count-(i-1)*3
		end
		local item = self.tableView:newItem()
		item:setItemSize(960,240)
		local content = display.newNode()
		for j=1,jMax do
			self.tableViewCells[(i-1)*3+j] = require("app.GUI.hallview.HallTableViewCell"):new(self, self.leftGameLevel, (i-1)*3+j)
				:align(display.CENTER, 300*(j-2), 0)
                :addTo(content)
            if i==1 and j==1 then

            else
				self.tableViewCells[(i-1)*3+j]:resetData(self.myTableList.tableList[self.myTableList.nowIndexList[(i-1)*3+j-1]])
			end
		end
		item:addContent(content)
		self.tableView:addItem(item)
	end
	self.tableView:reload()
end

function HallTableView:touchListener(event)
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

return HallTableView