local StringFormat = require("app.Tools.StringFormat")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
--------------------------------------------------------------------------------------------------------------
local FinalStaticsDialogLogic = class("FinalStaticsDialogLogic", function()
	return display.newNode()
end)

function FinalStaticsDialogLogic:ctor(params)
	self.m_callbackUI = params.m_callbackUI
	self.m_tableId = params.m_tableId
	DBHttpRequest:getPriTableUserList(function(tableData,tag) self:httpResponse(tableData,tag) end,self.m_tableId,0,30)
 	DBHttpRequest:getPriTableList(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,0,30)
end

--[[
  网络回调
]]
function FinalStaticsDialogLogic:httpResponse(tableData,tag) 
	-- dump(tableData,tag)
    if tag == POST_COMMAND_GET_PRITABLE_LIST then  
    	if not tableData or not tableData["MSG"] == "success!" then return end
    	local info = require("app.Logic.Datas.Props.PriTableList"):new()
    	if info:parseJson(tableData) == BIZ_PARS_JSON_SUCCESS then
    		self.m_callbackUI:updateTableList(info)
    	end
    elseif tag == POST_COMMAND_GET_PRITABLE_USER_LIST then
    	if not tableData or not tableData["MSG"] == "success!" then return end
    	local info = require("app.Logic.Datas.Props.PriTableUserList"):new()
    	if info:parseJson(tableData) == BIZ_PARS_JSON_SUCCESS then
    		self.m_callbackUI:updateTable(info)
    	end
    end
    
end
--------------------------------------------------------------------------------------------------------------
local FinalStaticsDialog = class("FinalStaticsDialog", function()
	return display.newLayer()
end)

function FinalStaticsDialog:create()

end

function FinalStaticsDialog:ctor(params)
	--[[数据初始化]]
	----------------------------------------
	self.m_tableId = params.m_tableId
	self.totalHand = 0
	self.maxPot = 0
	self.totalBuyinChips = 0
	self.tableViewBg = nil
	self.onlineListData = nil

	self.onlineListData = {}
	-- self.onlineListData[1] = {}
	-- self.onlineListData[1]["name"] = "yoyo"
	-- self.onlineListData[1]["chips"] = "600万"
	-- self.onlineListData[1]["profit"] = "3200"
	-- self.onlineListData[2] = {}
	-- self.onlineListData[2]["name"] = "jaelyn"
	-- self.onlineListData[2]["chips"] = "200万"
	-- self.onlineListData[2]["profit"] = "-100"
	----------------------------------------
	self:initUI()

	self.m_logic = FinalStaticsDialogLogic.new({m_callbackUI = self, m_tableId = self.m_tableId})
	self.m_logic:addTo(self)
end

function FinalStaticsDialog:updateTable(data)
	self.onlineListData = data.userList
	self:initOnlineListCells()
end

function FinalStaticsDialog:updateTableList(data)
	-- dump(data.tableList)
	if data.tableList and #data.tableList>0 then
		for i=1,#data.tableList do
			if data.tableList[i]["tableId"] and self.m_tableId==data.tableList[i]["tableId"] then
				-- dump(data.tableList[i])
				if data.tableList[i]["totalBuyin"] then
					self.totalBuyinChipsLabel:setString(data.tableList[i]["totalBuyin"])
				end

				if data.tableList[i]["totalHands"] then
					self.totalHandLabel:setString(data.tableList[i]["totalHands"])
				end

				if data.tableList[i]["winCount"] then
					self.myProfitLabel:setString(data.tableList[i]["winCount"])
				end
			end
		end
	end
end

function FinalStaticsDialog:initUI()
	self.m_dialogBg = cc.ui.UIImage.new("picdata/bill/bg.png")
	self.m_dialogBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
		:addTo(self)

	bgWidth = self.m_dialogBg:getContentSize().width
	bgHeight = self.m_dialogBg:getContentSize().height

	cc.ui.UIPushButton.new({normal="picdata/public/btn_2_close.png", pressed="picdata/public/btn_2_close2.png", disabled="picdata/public/btn_2_close2.png"})
		:align(display.CENTER, bgWidth-15, bgHeight-15)
		:addTo(self.m_dialogBg, 1)
		:onButtonClicked(function(event)
			-- CMClose(self, true)
			self:removeFromParent(true)
			local event = cc.EventCustom:new("ShowPrivateHallSearch")
    		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			end)

	local bg2 = cc.ui.UIImage.new("picdata/bill/bg2.png")
		:align(display.CENTER_BOTTOM, bgWidth/2, 35)
		:addTo(self.m_dialogBg)

	local bg3 = cc.ui.UIImage.new("picdata/bill/bg3.png")
		:align(display.CENTER_BOTTOM, bg2:getPositionX(), bg2:getPositionY())
		:addTo(self.m_dialogBg)

	cc.ui.UIImage.new("picdata/bill/w_pjtj.png")
		:align(display.CENTER, bgWidth/2, bgHeight-60)
		:addTo(self.m_dialogBg)

	cc.ui.UIImage.new("picdata/bill/icon_grzj.png")
		:align(display.LEFT_TOP, 20, bg3:getContentSize().height)
		:addTo(bg3)

	local label = cc.ui.UILabel.new({
		text = "盈利金币",
		font = "黑体",
		size = 30,
		color = cc.c3b(228,213,180),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, 320, bg3:getContentSize().height-38)
		:addTo(bg3)	

	local jbIcon = cc.ui.UIImage.new("picdata/public/icon_jb.png")
		:align(display.CENTER, label:getPositionX()+20, label:getPositionY())
		:addTo(bg3)

	self.myProfitLabel = cc.ui.UILabel.new({
		text = "0",
		font = "黑体",
		size = 30,
		color = cc.c3b(228,213,180),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.LEFT_CENTER, jbIcon:getPositionX()+20, label:getPositionY())
		:addTo(bg3)	

	local tmp = 200

	local label1 = cc.ui.UILabel.new({
		text = "本局最大pot",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, bg3:getContentSize().width/2, bg3:getContentSize().height-105)
		:addTo(bg3)

	local label2 = cc.ui.UILabel.new({
		text = "本局总手数",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, label1:getPositionX()-tmp, label1:getPositionY())
		:addTo(bg3)		

	local label3 = cc.ui.UILabel.new({
		text = "本局总带入",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, label1:getPositionX()+tmp, label1:getPositionY())
		:addTo(bg3)	

	self.totalHandLabel = cc.ui.UILabel.new({
		text = StringFormat:FormatDecimals(self.totalHand).."手",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, label2:getPositionX(), bg3:getContentSize().height-155)
		:addTo(bg3)	 

	self.maxPotLabel = cc.ui.UILabel.new({
		text = StringFormat:FormatDecimals(self.maxPot).."",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, label1:getPositionX(), self.totalHandLabel:getPositionY())
		:addTo(bg3)	

	self.totalBuyinChipsLabel = cc.ui.UILabel.new({
		text = StringFormat:FormatDecimals(self.totalBuyinChips).."",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, label3:getPositionX(), self.totalHandLabel:getPositionY())
		:addTo(bg3)	

	local label4 = cc.ui.UILabel.new({
		text = "昵称",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, label2:getPositionX()-15, bg3:getContentSize().height-215)
		:addTo(bg3)

	local label5 = cc.ui.UILabel.new({
		text = "带入",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, label1:getPositionX(), label4:getPositionY())
		:addTo(bg3)		

	local label6 = cc.ui.UILabel.new({
		text = "盈亏",
		font = "黑体",
		size = 20,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, label3:getPositionX(), label4:getPositionY())
		:addTo(bg3)	 

	self.listBg = bg3
	self.tableViewWidth = bg3:getContentSize().width
	self.tableViewRect = cc.rect(0,10,self.tableViewWidth,200)
	self:initOnlineList()
end

--[[牌局统计表]]
function FinalStaticsDialog:initOnlineList()
	self.onlineList = cc.ui.UIListView.new{
		viewRect = self.tableViewRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchOnlineListCell))
		:addTo(self.listBg)

	self:initOnlineListCells()
end

function FinalStaticsDialog:initOnlineListCells()
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
			:align(display.CENTER, -50, 0)
			:addTo(self.onlineListCells[i])
	end
	if self.onlineListData[i]["profit"]>0 then
		colorProfit = cc.c3b(0,255,225)
	elseif self.onlineListData[i]["profit"]<0 then
		colorProfit = cc.c3b(255,0,0)
	end
	if self.onlineListData[i]["chips"]-math.floor(self.onlineListData[i]["chips"])<0.01 then
		self.onlineListData[i]["chips"] = math.floor(self.onlineListData[i]["chips"])
	end
	if self.onlineListData[i]["profit"] - math.floor(self.onlineListData[i]["profit"])<0.01 then
		self.onlineListData[i]["profit"] = math.floor(self.onlineListData[i]["profit"])
	end

		--[[昵称]]
	local label1 = cc.ui.UILabel.new({
		text = self.onlineListData[i]["name"],
		font = "黑体",
		size = 24,
		color = colorName,
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, -260, 0)
		:addTo(self.onlineListCells[i])

	--[[带入]]
	local label2 = cc.ui.UILabel.new({
		text = self.onlineListData[i]["chips"],
		font = "黑体",
		size = 24,
		color = colorChips,
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, -20, label1:getPositionY())
		:addTo(self.onlineListCells[i])

	--[[盈亏]]
	local label3 = cc.ui.UILabel.new({
		text = self.onlineListData[i]["profit"],
		font = "黑体",
		size = 24,
		color = colorProfit,
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, label2:getPositionX()+170, label1:getPositionY())
		:addTo(self.onlineListCells[i])

		item:addContent(self.onlineListCells[i])
		item:setItemSize(self.listBg:getContentSize().width,40)
		self.onlineList:addItem(item)
	end
	self.onlineList:reload()
end

function FinalStaticsDialog:touchOnlineListCell()

end

return FinalStaticsDialog