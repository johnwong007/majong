--
-- Author: junjie
-- Date: 2016-05-30 18:03:00
--
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local DebaoZuanRecordLayer = class("DebaoZuanRecordLayer",FightCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
local EnumMenu = {
	eBtnOk = 1
}
function DebaoZuanRecordLayer:ctor()

end

function DebaoZuanRecordLayer:create()
	DebaoZuanRecordLayer.super.ctor(self,{size = cc.size(CONFIG_SCREEN_WIDTH,display.height),showClose = 0}) 
    DebaoZuanRecordLayer.super.initUI(self)

    local btnClose = CMButton.new({normal = "picdata/fightteam/btn_back.png",pressed = "picdata/fightteam/btn_back2.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnBack) end, {scale9 = false})    
    :align(display.CENTER, CONFIG_SCREEN_WIDTH/2-430,self.mBg:getContentSize().height-50) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg,2)

	local labelSize = cc.size(CONFIG_SCREEN_WIDTH,115)
	local labelBg = cc.ui.UIImage.new("picdata/fightteam/edithead.png", {scale9 = true})
    labelBg:setLayoutSize(labelSize.width,labelSize.height)
	labelBg:setPosition(self.mBgWidth/2-labelSize.width/2,self.mBgHeight-115)
	self.mBg:addChild(labelBg)

	local title = cc.Sprite:create("picdata/shop/w_title_hzjl.png")
	title:setPosition(labelSize.width/2,labelSize.height/2+10)
	labelBg:addChild(title)

	local size = cc.size(928,488)
	viewbg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    viewbg:setLayoutSize(size.width,size.height)
	-- viewbg:setPosition(0,0)
	viewbg:setPosition(self.mBgWidth/2-464,self.mBgHeight/2-289)
	self:addChild(viewbg)
	self.mViewBg = viewbg
	self:createRightUI()
end

function DebaoZuanRecordLayer:createRightUI()
	if self.mRightBg then return end
	local posx = 60
	local titleName = {{text = "赠送人",x = posx},{text = "UID",x = posx + 210},{text = "赠送数量",x = posx + 420},{text = "赠送日期",x = posx + 640}}
	
	for i = 1,#titleName do 
		local title = cc.ui.UILabel.new({
	        text  = titleName[i].text,
	        size  = 22,
	        color = cc.c3b(135,154,192),
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		title:setPosition(titleName[i].x, 460)
		self.mViewBg:addChild(title)
	end

	local size = cc.size(800,4)
	local line = cc.ui.UIImage.new("picdata/public2/bg_tc_line.png", {scale9 = true})
    line:setLayoutSize(size.width,size.height)
	-- viewbg:setPosition(0,0)
	line:setPosition(self.mViewBg:getContentSize().width/2-400,430)
	self.mViewBg:addChild(line)
	self:createRightList()

end
function DebaoZuanRecordLayer:createRightList(idx)
	-- local itemData = QDataMyMatchList:getMsgItemData(idx)
	-- if not itemData then return end
	-- self:updateName(itemData)
	-- local cfgData = itemData["rank"]
	-- if not cfgData then return end

	cfgData = {{},{},{}}
	-- if self.mRightList then self.mRightList:removeFromParent() self.mRightList = nil end

	local rightSize = cc.size(800,410)	
	self.mRightList = cc.ui.UIListView.new {
    	bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(64, 7, rightSize.width, rightSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mViewBg) 

	local bgWidth = rightSize.width
	local bgHeight= 40
	-- local posy = bgHeight-150
	for i = 1,#cfgData do 
		local item = self.mRightList:newItem() 

		local node = display.newNode()	
		item:addContent(node) 
		node:setContentSize(bgWidth,bgHeight)
		item:setItemSize(bgWidth,bgHeight)
	   	self.mRightList:addItem(item)

	   	local posx = 0
		local titleName = {
		{text = i,x = posx},
		{text = i,x = posx + 210,color = cc.c3b(189,211,255)},
		{text = cfgData[i]["WIN_COUNT"] or 0,x =posx + 420},
		{text = cfgData[i]["WIN_COUNT"] or 0,x =posx + 640,color = cc.c3b(189,211,255)},
		}
		for j = 1,#titleName do 
			local title = cc.ui.UILabel.new({
		        text  = titleName[j].text,
		        size  = 24,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        --UILabelType = 1,
				font  = "黑体",
				color = titleName[j].color,
			    })
			title:setPosition(titleName[j].x, bgHeight/2)
			node:addChild(title)

			if j == 3 then
				local sp = cc.Sprite:create("picdata/public2/icon_dbz.png")
				sp:setScale(0.5)
				sp:setPosition(titleName[j].x - 20, bgHeight/2)
				node:addChild(sp)
			end
		end
		-- posy = posy - 30
	end

	self.mRightList:reload()
end
return DebaoZuanRecordLayer