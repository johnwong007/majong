--
-- Author: wangj
-- Date: 2015-01-06 11:43:44
--
local nType = 1
local quick_recharge_money = {6,18,50,198}
local RechargeOptionInDialog = class("RechargeOptionInDialog",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
require("app.Network.Http.DBHttpRequest")
local QDataShopGoldList = nil
local NetCallBack = require("app.Network.Http.NetCallBack")
local myInfo = require("app.Model.Login.MyInfo")
function RechargeOptionInDialog:ctor(params)
	self:setNodeEventEnabled(true)
	self.mRightPic       = {} 								--右边需要刷新的图片
	self.parent = params.parent
	self.isPriTable = isPriTable
	QDataShopGoldList = QManagerData:getCacheData("QDataShopGoldList")
end

--[[payType:"GOLD"(金币)、"POINT"(德堡钻)]]
function RechargeOptionInDialog:setPayType(payType)
	self.payType = payType
 	if self.payType and self.payType=="POINT" then
 		nType = 4
 	else
 		nType = 1
 	end
end

function RechargeOptionInDialog:onEnter()
	QManagerPlatform:onEvent({where = QManagerPlatform.EOnEventWhere.eOnEventShopRecharge , nType = QManagerPlatform.EOnEventActionType.eOnEventActionOpenShop})
end

function RechargeOptionInDialog:GoldInQuickRechargeList(money)
	if self.payType and self.payType == "POINT" then
		return true
	end
	for index=1,#quick_recharge_money do
		if money==quick_recharge_money[index] then
			return true
		end
	end
	return false
end

--[[
	创建右边列表
]]
function RechargeOptionInDialog:createListView()
	local isExistData = QDataShopGoldList:isExistMsgData(nType)

	if not isExistData then
		if self.payType and self.payType=="POINT" then
			self.payType = "POINT"
			DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"UNWO","POINT")
		else
			self.payType = "GOLD"
			if DBChannel == "20210" then
				DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"APPLE","GOLD")
			else
				DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end)
			end
		end
	else
		self:createGoldList()
	end
end
function RechargeOptionInDialog:createGoldList()
	-- body
	self.m_listSize = cc.size(640,433)		
	self.m_listView = cc.ui.UIListView.new {
    	-- bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(display.cx-322, display.cy-212, self.m_listSize.width, self.m_listSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchListener))
    :addTo(self)    
  	local cfgData = QDataShopGoldList:getMsgData(nType)
  	if not cfgData then return end 
  	-- dump(cfgData)
	for i = 1,#cfgData do 
		if self:GoldInQuickRechargeList(cfgData[i][BUYCOINLIST_COIN]+0) then
			local picPath = string.format("picdata/db_gold/jb%d.png",cfgData[i][BUYCOINLIST_COIN])--cfgData[i][BUYCOINLIST_COIN]) 
			if self.payType == "POINT" then
				picPath = "picdata/shop/dbz.png"
			end
			local item = self.m_listView:newItem() 

			local bg   = cc.Sprite:create("scene/picdata/shop_dif/shopCellBg.png")
		
			local bgwidth = bg:getContentSize().width
			local bgHeight= bg:getContentSize().height
			local itemSize = cc.size(bgwidth, 110)
			bg:setPosition(0,0)
			item:addContent(bg)
			item:setItemSize(itemSize.width,itemSize.height)
			self.m_listView:addItem(item)

			if i ~= 1 then
				local head = cc.Sprite:create("scene/picdata/shop_dif/list_one_y.png")
				head:setPosition(itemSize.width/2,itemSize.height-15)
				bg:addChild(head)
			end
			local pic = cc.Sprite:create(picPath)
			if pic == nil then
				pic = cc.Sprite:create("picdata/db_gold/jb18.png")
			end
			pic:setPosition(80,itemSize.height/2)
			bg:addChild(pic)
			self.mRightPic[i] = pic 

			local sNameText = "金币"
			if self.payType == "POINT" then
				sNameText = "德堡钻"
			end
			-- 	local sName =  cc.ui.UILabel.new({
	  --       	text  = CMFormatNum(cfgData[i][MONEY_BALANCE]) .. sNameText,
	  --       	x     = 180,
	  --       	y     = itemSize.height/2 ,
	  --       	align = cc.ui.TEXT_ALIGN_LEFT,
	  --       	font  = "picdata/MainPage/goldNum.fnt",
	  --       	UILabelType = 1,
	  --   	})
   --  		bg:addChild(sName)
   			if not self.payType or self.payType ~= "POINT" then
				local sName =  cc.ui.UILabel.new({
	        	text  = CMFormatNum(cfgData[i][MONEY_BALANCE]) .. sNameText,
	        	x     = 180,
	        	y     = itemSize.height/2 ,
	        	align = cc.ui.TEXT_ALIGN_LEFT,
	        	font  = "picdata/MainPage/goldNum.fnt",
	        	UILabelType = 1,
	    		})
    			bg:addChild(sName)
   			else
		    	local sName =  cc.ui.UILabel.new({
			        color = cc.c3b(255, 219, 154),
			        text  = cfgData[i][GOODS_DESC],
			        size  = 24,
			        font  = "fonts/FZZCHJW--GB1-0.TTF",
			        x     = 170,
			        y     = itemSize.height/2,
			        align = cc.ui.TEXT_ALIGN_LEFT,
			    })
		    	bg:addChild(sName)
		    	-- local size = cc.size(320, 0)
		    	-- if GDIFROOTRES   == "scene1136/" then
		    	-- 	size = cc.size(500, 0)
		    	-- end
		    	-- local sDetail = cc.ui.UILabel.new({
			    --     color = cc.c3b(164, 195, 255),
			    --     text  = cfgData[i][GOODS_DESC] or "",
			    --     size  = 18,
			    --     font  = "黑体",
			    --     x     = 170,
			    --     y     = itemSize.height/2 - 22,
			    --     align = cc.ui.TEXT_ALIGN_LEFT,
			    --     dimensions = size,
			    -- })
		    	-- bg:addChild(sDetail)
   			end

    		local btnPath = "picdata/shop/btn_buy.png"
			local goldPath = "picdata/shop/rakepointIcon.png"
			local fntPath = "picdata/table/callLabel.fnt"
			local isEnable = true
    		--if tonumber(myInfo.data.diamondBalance) < (tonumber(cfgData[i][PAY_NUM])) then 
    		if false  then
    			btnPath = "picdata/shop/btn_buy_no.png"
    			goldPath = "picdata/shop/icon_jf_gray.png"
    			fntPath = "picdata/shop/grayPrice.fnt"
    			isEnable = false
    		end
    		local btnExcharge = CMButton.new({normal = btnPath},function () self:onMenuOpenChannelLayer(cfgData[i]) end,{scale9 = false},{scale = false})
    		btnExcharge:setPosition(itemSize.width - 120,itemSize.height/2)
    		btnExcharge:setButtonEnabled(isEnable)
    		btnExcharge:setTouchSwallowEnabled(false)
    		bg:addChild(btnExcharge)

    		local gold = cc.Sprite:create(goldPath)
    		gold:setPosition(-btnExcharge:getButtonSize().width/2 + 25,3)
    		--btnExcharge:addChild(gold)
	    
    		local sNeedGold = cc.ui.UILabel.new({
	        	text  = CMFormatNum(cfgData[i][BUYCOINLIST_COIN]).."元",
	        	UILabelType = 1,
	        	font  = fntPath,
	        	--x     = btnExcharge:getButtonSize().width/2,
	        	--y     = 0,
	        	--align = cc.ui.TEXT_ALIGNMENT_CENTER,
	    	})
	    	sNeedGold:setPosition( - sNeedGold:getContentSize().width/2,5)
    		btnExcharge:addChild(sNeedGold)

		end	
	end	

	self.m_listView:reload()	
end

function RechargeOptionInDialog:touchListener(event)

end

--[[
	支付界面
]]
function RechargeOptionInDialog:onMenuOpenChannelLayer(params)
	-- local ShopChannelLayer = require("app.GUI.recharge.ShopChannelLayer").new(params)
	-- ShopChannelLayer:create()
 --    ShopChannelLayer:setPosition(display.cx,display.cy)
 --    self.parent:addChild(ShopChannelLayer, 5)

 	local ShopGoldLayer = require("app.GUI.recharge.ShopGoldLayer"):new()
 	ShopGoldLayer:setTouchSwallowEnabled(false)
 	self.parent:addChild(ShopGoldLayer,5)
 	params.sPayType = self.payType
 	ShopGoldLayer:onMenuOpenChannelLayer(params,nType)
end
--[[
	网络回调
]]
function RechargeOptionInDialog:httpResponse(tableData,tag,nType)
	
	if tag == POST_COMMAND_getUserVipInfo then  				--请求vip信息	
		self:initVipNode(tableData)
	elseif tag == POST_COMMAND_GETITEMLIST then 				--请求充值列表
		QDataShopGoldList:Init(tableData,nType)
		self:createListView()
	elseif tag == POST_COMMAND_GETGOODSLIST then 			    --请求道具列表
		QDataShopGoldList:Init(tableData,2)
	end
	
end

return RechargeOptionInDialog