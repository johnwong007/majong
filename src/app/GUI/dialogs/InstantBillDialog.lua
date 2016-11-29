require("app.Network.Http.DBHttpRequest") 
local myInfo = require("app.Model.Login.MyInfo")
local StringFormat = require("app.Tools.StringFormat")

local dialogStartPos = cc.p(0,0)
local bgWidth = 0
local bgHeight = 0
--------------------------------------------------------------------------------------------------------------
local InstantBillDialogLogic = class("InstantBillDialogLogic", function()
	return display.newNode()
end)

function InstantBillDialogLogic:ctor(params)
	self.m_callbackUI = params.m_callbackUI
	self.m_tableId = params.m_tableId
	DBHttpRequest:getPriTableUserList(function(tableData,tag) self:httpResponse(tableData,tag) end,self.m_tableId,0,30)

end

--[[
  网络回调
]]
function InstantBillDialogLogic:httpResponse(tableData,tag) 
    -- dump(tableData,tag)
    if tag == POST_COMMAND_GET_PRITABLE_USER_LIST then
    	if not tableData or not tableData["MSG"] == "success!" then return end
    	local info = require("app.Logic.Datas.Props.PriTableUserList"):new()
    	if info:parseJson(tableData) == BIZ_PARS_JSON_SUCCESS then
    		self.m_callbackUI:updateTable(info)
    	end
    end
    
end
--------------------------------------------------------------------------------------------------------------
local InstantBillDialog = class("InstantBillDialog", function()
	return display.newLayer()
end)

function InstantBillDialog:create()

end

function InstantBillDialog:ctor(params)
	--[[数据初始化]]
	----------------------------------------
	self.m_tableId = params.m_tableId
	-- dump(params)
	self.destroyTime = params.m_destroyTime or nil
	self.onlineListData = nil
	self.audienceListData = nil

	self.onlineListData = {}
	-- self.onlineListData[1] = {}
	-- self.onlineListData[1]["name"] = "yoyo"
	-- self.onlineListData[1]["chips"] = "600万"
	-- self.onlineListData[1]["profit"] = "3200"
	-- self.onlineListData[2] = {}
	-- self.onlineListData[2]["name"] = "jaelyn"
	-- self.onlineListData[2]["chips"] = "200万"
	-- self.onlineListData[2]["profit"] = "-100"

	-- self.audienceListData = {"张三","李四","王五","赵六","国龙"}
	-- dump(self.onlineListData)
	-- dump(self.audienceListData)
	----------------------------------------
	self:initUI()

	-- 允许 node 接受触摸事件
    self:setTouchEnabled(true)

	-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    	-- event.x, event.y 是触摸点当前位置
    	-- event.prevX, event.prevY 是触摸点之前的位置
    	-- printf("sprite: %s x,y: %0.2f, %0.2f",
     --       event.name, event.x, event.y)

    	-- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
    	-- 则必须返回 true
    	if event.name == "began" then
        	return self:ccTouchBegan(event)
    	end
	end)

	self.m_logic = InstantBillDialogLogic.new({m_callbackUI = self, m_tableId = self.m_tableId})
	self.m_logic:addTo(self)
end

function InstantBillDialog:updateTable(data)
	self.onlineListData = data.userList
	self:initOnlineListCells()
end

function InstantBillDialog:ccTouchBegan(event)
    local pos  = cc.p(event.x, event.y)
    local rect = cc.rect(dialogStartPos.x, dialogStartPos.y, bgWidth, bgHeight)
    if not cc.rectContainsPoint(rect, pos) then
        -- CMClose(self, true)
        self:removeFromParent(true)
    end
    return true
end

function InstantBillDialog:initUI()
	self.m_dialogBg = cc.ui.UIImage.new("picdata/instantBill/bg.png")
	self.m_dialogBg:align(display.LEFT_BOTTOM, 0, 0)
		:addTo(self)

	bgWidth = self.m_dialogBg:getContentSize().width
	bgHeight = self.m_dialogBg:getContentSize().height

	cc.ui.UIImage.new("picdata/instantBill/w_title_sszk.png")
		:align(display.CENTER, bgWidth/2, bgHeight-40-30)
		:addTo(self.m_dialogBg)


	-- self.onlineButton = cc.ui.UIPushButton.new({normal="picdata/instantBill/btn_zz.png", 
	-- 	pressed={"picdata/tourney/infoSliderBtn.png", "picdata/instantBill/btn_zz2.png"}, 
	-- 	disabled={"picdata/tourney/infoSliderBtn.png", "picdata/instantBill/btn_zz2.png"}})
	-- self.onlineButton:align(display.RIGHT_CENTER, bgWidth/2, bgHeight-80)
	-- 	:addTo(self.m_dialogBg, 1)
	-- 	:onButtonClicked(function(event)
	-- 		-- self:pressSeatButton3()
	-- 		end)
	-- 	:setTouchSwallowEnabled(false)


	self.listBg = cc.ui.UIImage.new("picdata/instantBill/bg2.png")
		:align(display.CENTER_BOTTOM, bgWidth/2-6, 10+20)
		:addTo(self.m_dialogBg)
------------------------------------------------------------
	self.onlineListView = display.newNode()
	self.onlineListView:addTo(self.listBg)
	--[[昵称]]
	self.hint1 = cc.ui.UILabel.new({
		text = "昵称",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 20, self.listBg:getContentSize().height-18)
		:addTo(self.onlineListView)

	--[[带入]]
	self.hint2 = cc.ui.UILabel.new({
		text = "带入",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.listBg:getContentSize().width/2-40, self.hint1:getPositionY())
		:addTo(self.onlineListView)

	--[[盈亏]]
	self.hint3 = cc.ui.UILabel.new({
		text = "盈亏",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.hint2:getPositionX()+140, self.hint1:getPositionY())
		:addTo(self.onlineListView)
------------------------------------------------------------
	self.audienceListView = display.newNode()
	self.audienceListView:addTo(self.listBg)
	--[[观众]]
	self.hint4 = cc.ui.UILabel.new({
		text = "观众",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 20, self.listBg:getContentSize().height-18)
		:addTo(self.audienceListView)

------------------------------------------------------------

	self.tableViewWidth = self.listBg:getContentSize().width
	self.tableViewRect = cc.rect(0,10, self.tableViewWidth, self.listBg:getContentSize().height-40)
	self:initOnlineList()
	self:initAudienceList()

	self.onlineListView:setVisible(true)
	self.audienceListView:setVisible(false)
	-- self:createButtonGroup()

	local moveByParams = {x = 495, y = 0, time = 0.5}
	transition.moveBy(self, moveByParams)



    local timeBg = cc.ui.UIImage.new("picdata/instantBill/bg_sysj.png")
		:align(display.LEFT_CENTER, 10, bgHeight-70)
		:addTo(self.m_dialogBg)
    local timeBg1 = cc.ui.UIImage.new("picdata/instantBill/bg_sysj_time.png")
	timeBg1:align(display.CENTER, timeBg:getContentSize().width/2, timeBg:getContentSize().height/2)
		:addTo(timeBg)
	local timeData = {timestamp=0,color=cc.c3b(255,102,0),padding=16, length=3,
		position = cc.p(3,timeBg1:getContentSize().height/2)}	
	self.timeLabel = require("app.GUI.dialogs.CountDownTimeLabel").new(timeData)
	self.timeLabel:addTo(timeBg1,1)
	self.timeLabel:create()

	self.timeLabel:setTimestamp(EStringTime:getTimeStampFromNow(self.destroyTime))
end

function InstantBillDialog:initOnlineList()
	self.onlineList = cc.ui.UIListView.new{
		viewRect = self.tableViewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchOnlineListCell))
		:addTo(self.onlineListView)

	self:initOnlineListCells()
end

function InstantBillDialog:initAudienceList()
	self.audienceList = cc.ui.UIListView.new{
		viewRect = self.tableViewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchAudienceListCell))
		:addTo(self.audienceListView)

	self:initAudienceListCells()
end

function InstantBillDialog:initOnlineListCells()
	if self.onlineListCells then
		self.onlineList:removeAllItems()
	end
	self.onlineListCells=nil
	self.onlineListCells={}
	if self.onlineListData==nil or #self.onlineListData<=0 then
		return
	end

	for i=1,#self.onlineListData do
		local item = self.onlineList:newItem()
		self.onlineListCells[i] = display.newNode()

	local colorName = cc.c3b(255,255,255)
	local colorChips = cc.c3b(255,255,255)
	local colorProfit = cc.c3b(255,255,255)
	if self.onlineListData[i]["userId"] == myInfo.data.userId then
		colorName = cc.c3b(60,207,255)
	 	colorChips = cc.c3b(60,207,255)
	 	cc.ui.UIImage.new("picdata/instantBill/bg_i.png")
			:align(display.CENTER, 0, 0)
			:addTo(self.onlineListCells[i])
	end
	if self.onlineListData[i]["profit"]>0 then
		colorProfit = cc.c3b(0,255,225)
	elseif self.onlineListData[i]["profit"]<0 then
		colorProfit = cc.c3b(255,0,0)
	end
	self.onlineListData[i]["chips"] = StringFormat:GetPreciseDecimal(self.onlineListData[i]["chips"], 1)
	self.onlineListData[i]["profit"] = StringFormat:GetPreciseDecimal(self.onlineListData[i]["profit"], 1)
	if self.onlineListData[i]["chips"]-math.floor(self.onlineListData[i]["chips"])<0.01 then
		self.onlineListData[i]["chips"] = math.floor(self.onlineListData[i]["chips"])
	end
	if self.onlineListData[i]["profit"] - math.floor(self.onlineListData[i]["profit"])<0.01 then
		self.onlineListData[i]["profit"] = math.floor(self.onlineListData[i]["profit"])
	end
		--[[昵称]]
	local label1 = cc.ui.UILabel.new({
		text = revertPhoneNumber(self.onlineListData[i]["name"]),
		font = "黑体",
		size = 24,
		-- color = cc.c3b(255,255,255),
		color = colorName,
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 18-self.tableViewWidth/2, 0)
		:addTo(self.onlineListCells[i])

	--[[带入]]
	local label2 = cc.ui.UILabel.new({
		text = self.onlineListData[i]["chips"],
		font = "黑体",
		size = 24,
		-- color = cc.c3b(60,207,255),
		color = colorChips,
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.listBg:getContentSize().width/2-44-self.tableViewWidth/2, label1:getPositionY())
		:addTo(self.onlineListCells[i])

	--[[盈亏]]
	local label3 = cc.ui.UILabel.new({
		text = self.onlineListData[i]["profit"],
		font = "黑体",
		size = 24,
		-- color = cc.c3b(0,255,225),
		color = colorProfit,
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label2:getPositionX()+140, label1:getPositionY())
		:addTo(self.onlineListCells[i])



		item:addContent(self.onlineListCells[i])
		item:setItemSize(self.listBg:getContentSize().width,40)
		self.onlineList:addItem(item)
	end
	self.onlineList:reload()
end

function InstantBillDialog:initAudienceListCells()
	if self.audienceListCells then
		self.audienceList:removeAllItems()
	end
	self.audienceListCells=nil
	self.audienceListCells={}
	if self.audienceListData==nil or #self.audienceListData<=0 then
		return
	end
	for i=1,#self.audienceListData do
		local item = self.audienceList:newItem()
		self.audienceListCells[i] = display.newNode()

		--[[昵称]]
	local label1 = cc.ui.UILabel.new({
		text = self.audienceListData[i],
		font = "黑体",
		size = 24,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 18-self.tableViewWidth/2, 0)
		:addTo(self.audienceListCells[i])

		item:addContent(self.audienceListCells[i])
		item:setItemSize(self.listBg:getContentSize().width,60)
		self.audienceList:addItem(item)
	end
	self.audienceList:reload()
end

function InstantBillDialog:touchOnlineListCell()

end

function InstantBillDialog:touchAudienceListCell()

end

--[[tabbar按钮]]
function InstantBillDialog:createButtonGroup()

  local bg = cc.Sprite:create("picdata/public/btn_1_menu.png")
  bg:setScaleX(1.0)
  bg:setPosition(bgWidth/2, bgHeight-100)
  self.m_dialogBg:addChild(bg)

  self.menu = cc.Sprite:create("picdata/public/btn_1_menu2.png")
  self.m_dialogBg:addChild(self.menu)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/instantBill/btn_zz.png",off_pressed = "picdata/instantBill/btn_zz2.png", on = "picdata/instantBill/btn_zz2.png",}))
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/instantBill/btn_gz.png",off_pressed = "picdata/instantBill/btn_gz2.png", on = "picdata/instantBill/btn_gz2.png",}))
   
    :setButtonsLayoutMargin(0, -25, 0, 0)
    :onButtonSelectChanged(function(event)
        local group = self.mGroup:getButtonAtIndex(event.selected)
        self.menu:setPosition(group:getPositionX()+bgWidth/2-132,group:getPositionY()+bgHeight-124)
        self:onChangeSwitch(event.selected)
       
    end)
    :align(display.LEFT_TOP, bgWidth/2-132, bgHeight-124)
    :addTo(self.m_dialogBg,1)
     self.mGroup = group
    group:getButtonAtIndex(1):setButtonSelected(true)
end

function InstantBillDialog:onChangeSwitch(idx)

  if idx == 1 then
	self.onlineListView:setVisible(true)
	self.audienceListView:setVisible(false)
  else
	self.onlineListView:setVisible(false)
	self.audienceListView:setVisible(true)
  end
end

return InstantBillDialog