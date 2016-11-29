--
-- Author: junjie
-- Date: 2015-12-03 14:23:59
--
--VIP特权
--
local MoreVersionLayer = class("MoreVersionLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")

local mMaxScrollPage = 10
local EnumMenu = 
{
	eLeftBtn = 1,
	eRightBtn= 2,
	eShopBtn = 3,
}
function MoreVersionLayer:ctor()
	
end
function MoreVersionLayer:create()
	self:initUI()
end
function MoreVersionLayer:initUI()
	DBHttpRequest:getUserVipInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)

	local size = cc.size(874,600)
	self.mBg = display.newScale9Sprite("picdata/public/bg_2_tc_l.png", 0, 0, size)
    local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	self.mBg:setPosition(display.cx,display.cy)
	self:addChild(self.mBg)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end)    
    :align(display.CENTER, self.mBg:getContentSize().width - 20,self.mBg:getContentSize().height-30) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

    self:createPageView()

    self.mLeftBtn = CMButton.new("picdata/setting/btn_back.png",function () self:onMenuCallBack(EnumMenu.eLeftBtn) end, {scale9 = false})        
    self.mLeftBtn:setPosition(50, bgHeight/2 - 85)
    self.mLeftBtn:setVisible(false)
    self.mBg:addChild(self.mLeftBtn,1)

    self.mRightBtn = CMButton.new("picdata/setting/btn_next.png",function () self:onMenuCallBack(EnumMenu.eRightBtn) end, {scale9 = false})        
    self.mRightBtn:setPosition(bgWidth - 50, self.mLeftBtn:getPositionY())
    self.mBg:addChild(self.mRightBtn,1)
end

function MoreVersionLayer:initVipNode(data)
	data = data or {}
	local curVipLevel = tonumber(data[USER_LEVEL] or 0)
	local curVipExp   = tonumber(data[VIP_RANK]  or 0)
	local nextVipExp  = tonumber(data[NEXT_VIP_RANK] or 100)
	myInfo.data.vipLevel = curVipLevel
	 local vipBg = cc.Sprite:create("picdata/setting/vipinfoBg.png")
	 local bgWidth = vipBg:getContentSize().width
	 local bgHeight= vipBg:getContentSize().height - 10
	vipBg:setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height/2)
	self.mBg:addChild(vipBg)

	local node = cc.Node:create()
	node:setPosition(60,255)
	vipBg:addChild(node)

	local vipNum = cc.Sprite:create(string.format("picdata/shop/vip%d.png",curVipLevel))
	vipNum:setPosition(50,bgHeight/2)
	node:addChild(vipNum)

	 local prebg = display.newSprite("picdata/public/vip_jdt_bg.png")
    prebg:setPosition(190,bgHeight/2)
    node:addChild(prebg)

    local pro = cc.Sprite:create("picdata/shop/vip_jdt.png")
    local progress = cc.ProgressTimer:create(pro)   
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)    
    progress:setBarChangeRate(cc.p(1, 0))      
    progress:setMidpoint(cc.p(0,1)) 
    progress:setPercentage(curVipExp/nextVipExp * 100)      
    progress:setPosition(prebg:getPositionX(),prebg:getPositionY())     
    node:addChild(progress)

	local proNum = cc.ui.UILabel.new({
        text  = string.format("%s/%d",curVipExp,nextVipExp),
        --font  = "picdata/MainPage/goldNum.fnt",
        size  = 18,
        x     = prebg:getPositionX(),
        y     = prebg:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    proNum:setPosition(prebg:getPositionX()-proNum:getContentSize().width/2,prebg:getPositionY())  
    node:addChild(proNum)

    local str = string.format("再充值%d元可达到vip%d",nextVipExp-curVipExp,curVipLevel+1)
    if curVipLevel >= 10 then 
    	str = "您已经是尊贵的VIP10用户了"
    end
    local goldenNum = cc.ui.UILabel.new({
        text  = str,
        --font  = "picdata/MainPage/goldNum.fnt",
        size  = 18,
        color = cc.c3b(228,213,180),
        x     = 300,
        y     = bgHeight/2,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })

    node:addChild(goldenNum)

    local btnCheck = CMButton.new({normal = "picdata/public/btn_cz.png"},function () self:onMenuCallBack(EnumMenu.eShopBtn) end)
	btnCheck:setPosition(bgWidth-190,bgHeight/2)
	node:addChild(btnCheck)
	self.mBtnCheck = btnCheck
end
--创建TableView
function MoreVersionLayer:createPageView()
	local scrollBg = cc.Sprite:create(string.format("picdata/walcome/vip%d.png",10))
	scrollBg:setPosition(display.cx,display.cy)	
	
	local width = scrollBg:getContentSize().width
	local height = scrollBg:getContentSize().height
	
	local x = self.mBg:getContentSize().width/2 - width/2
	local y = display.cy - height/2 -50

    self.mPageview = cc.ui.UIPageView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        viewRect = cc.rect(x, y, width, height),
        column = 1, row = 1,
        padding = {left = 0, right = 0, top = 0, bottom = 0},
        columnSpace = 0, rowSpace = 0}
        :onTouch(handler(self, self.touchListener))        
        :addTo(self.mBg,1)    
    
   	self:createPageItem()
    self.mPageview:reload()
end
--[[
	scrollview内容
]]
function MoreVersionLayer:createPageItem()	

	for i = 1,mMaxScrollPage do 
		local item = self.mPageview:newItem()
		self.mPageview:addItem(item)  
		local sp = cc.Sprite:create(string.format("picdata/walcome/vip%d.png",i))
		--sp:setAnchorPoint(0,0.5)
		sp:setPosition(sp:getContentSize().width/2,440-sp:getContentSize().height/2)
		item:addChild(sp)

	end
end
function MoreVersionLayer:touchListener(event)
    if 1 > event.pageIdx then    	
   		self.mPageview:gotoPage(1)    	
    elseif mMaxScrollPage < event.pageIdx then    	  	
   		self.mPageview:gotoPage(mMaxScrollPage)
    end
    self:updateBtn()
end
function MoreVersionLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eLeftBtn then
		local curPage = self.mPageview:getCurPageIdx() - 1
		self.mPageview:gotoPage(curPage,false)
		self:updateBtn()
	elseif tag == EnumMenu.eRightBtn then
		local curPage = self.mPageview:getCurPageIdx() + 1
		self.mPageview:gotoPage(curPage,false)
		self:updateBtn()
	elseif tag == EnumMenu.eShopBtn then
		local ShopGoldLayer = require("app.GUI.recharge.ShopGoldLayer")
		CMOpen(ShopGoldLayer, self:getParent())
		CMClose(self)
	end
end
function MoreVersionLayer:updateBtn()
	local curPage = self.mPageview:getCurPageIdx()
	if curPage == 1 then
		self.mLeftBtn:setVisible(false)
	else
		self.mLeftBtn:setVisible(true)
	end

	if mMaxScrollPage == curPage then
		self.mRightBtn:setVisible(false)
	else
		self.mRightBtn:setVisible(true)
	end

end
--[[
	网络回调
]]
function MoreVersionLayer:httpResponse(tableData,tag)
	--dump(tableData,tag)
	
	if tag == POST_COMMAND_getUserVipInfo then  				--请求vip信息	
		self:initVipNode(tableData)
	end
	
end


return MoreVersionLayer