--
-- Author: junjie
-- Date: 2015-11-26 17:56:51
--
--兑换确认框
local ShopExchargeLayer = class("ShopExchargeLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
local NetCallBack = require("app.Network.Http.NetCallBack")
local myInfo = require("app.Model.Login.MyInfo")
require("app.CommonDataDefine.CommonDataDefine")
require("app.Network.Http.DBHttpRequest")
function ShopExchargeLayer:ctor(params)
	-- dump(params)
	self.params = params or {}	
end
function ShopExchargeLayer:create()
	self:initUI()
end
function ShopExchargeLayer:initUI( ... )
	-- body
	local bg = cc.Sprite:create("picdata/shop/exchangeBg.png")
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height
	self:addChild(bg)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png"},function () CMClose(self) end)
	btnClose:setPosition(bgWidth-30,bgHeight - 30)
	bg:addChild(btnClose)
	local picPath = "picdata/shop/goldImg.png" 
    if self.params[GOODS_GOODS_PIC] ~= "" then
	  	local isExist,newPath = NetCallBack:getCacheImage(self.params[GOODS_GOODS_PIC])  	
    	if isExist then
    		picPath = newPath
		end
	end
	local pic = cc.Sprite:create(picPath)
	pic:setPosition(95,305)
	bg:addChild(pic)

	local sName =  cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = self.params[GOODS_GOODS_NAME] or "",
        size  = 24,
        font  = "黑体",
        x     = 150,
        y     = 330,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
	bg:addChild(sName)

	local sDetail = cc.ui.UILabel.new({
        color = cc.c3b(164, 195, 255),
        text  = self.params[GOODS_DESC] or "",
        size  = 20,
        --UILabelType = 1,
        font  = "黑体",
        -- x     = 150,
        -- y     = 280,
        align = cc.ui.TEXT_ALIGN_LEFT,
        dimensions = cc.size(430, 0),
    })
    sDetail:setPosition(150,sName:getPositionY() - 20 - sDetail:getContentSize().height/2 )
	bg:addChild(sDetail)

	
	local numBg = cc.Sprite:create("picdata/shop/numBack.png")
	numBg:setPosition(160,170)
	bg:addChild(numBg)
	local sBuyNum = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = "1",
        size  = 24,
        font  = "黑体",
    })
    sBuyNum:setPosition(numBg:getPositionX()-sBuyNum:getContentSize().width/2,numBg:getPositionY())
	bg:addChild(sBuyNum)

    local sZhiFu =  cc.ui.UILabel.new({
        color = cc.c3b(153, 146, 128),
        text  = "支付:",
        size  = 32,
        font  = "黑体",
        --UILabelType = 1,
        --font  = "picdata/shop/grayPrice.fnt",
    })
	sZhiFu:setPosition(360,numBg:getPositionY())
	bg:addChild(sZhiFu)
	local sType = "积分"
	if self.params["3026"] == "GOLD" then
		sType = "金币"
	end
	local sZhiFuNum =  cc.ui.UILabel.new({
        color = cc.c3b(153, 146, 128),
        text  = CMFormatNum(self.params[PAY_NUM])  ..sType,
        size  = 32,
        font  = "黑体",
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
	sZhiFuNum:setPosition(sZhiFu:getPositionX()+sZhiFu:getContentSize().width,numBg:getPositionY())
	bg:addChild(sZhiFuNum)


	local btnDown = CMButton.new({normal = "picdata/shop/btn_down.png"},function () self:onMenuChange(-1,self.params[PAY_NUM]) end)
	btnDown:setPosition(numBg:getPositionX() - 100,numBg:getPositionY())
	bg:addChild(btnDown)

	local btnUp = CMButton.new({normal = "picdata/shop/btn_up.png"},function () self:onMenuChange(1,self.params[PAY_NUM]) end)
	btnUp:setPosition(numBg:getPositionX() + 100,numBg:getPositionY())
	bg:addChild(btnUp)

	local btnExcharge = CMButton.new({normal = "picdata/shop/btn_exchange.png"},function () self:onMenuExcharge( self.params[GOODS_GOODS_ID]) end)
	btnExcharge:setPosition(bgWidth/2,70)
	bg:addChild(btnExcharge)

	self.mBuyNum = sBuyNum
	self.mZhiFUNum = sZhiFuNum
end

function ShopExchargeLayer:onMenuChange(num,payNum)
	local curNum = tonumber(self.mBuyNum:getString())
	if curNum == 1 and num < 0 then return end
	--if num > 0 then
	    local finalNum = curNum +num
		self.mBuyNum:setString(finalNum)
		local sType = "积分"
		if self.params["3026"] == "GOLD" then
			sType = "金币"
		end
		self.mZhiFUNum:setString(CMFormatNum(self.params[PAY_NUM] * finalNum)  ..sType)
		if num > 0 then
			if tonumber(myInfo.data.diamondBalance) < (tonumber(self.params[PAY_NUM]) * finalNum) then
				self.mZhiFUNum:setColor(cc.c3b(255,0,0))
			end
		end
	--end
end

--[[
	请求兑换
]]
function ShopExchargeLayer:onMenuExcharge(goodsId)
	local curNum = tonumber(self.mBuyNum:getString())
	DBHttpRequest:buyGoods(function(tableData,tag) self:httpResponse(tableData,tag) end,goodsId,curNum)
end

--[[
	网络回调
]]
function ShopExchargeLayer:httpResponse(tableData,tag)

	-- dump(tableData,tag)
	
	if tag == POST_COMMAND_BUYGOODS then  	
		local tips = "兑换失败"			--请求列表回调	
		if tableData == 1 then
			tips = "兑换成功"

		end
		DBHttpRequest:getAccountInfo(function(tableData,tag) if self.httpResponse then self:httpResponse(tableData,tag) end end,true)
		-- QManagerListener:Notify({layerID = eMainPageViewID})		
		CMShowTip(tips)
	elseif tag == POST_COMMAND_GETACCOUNTINFO then
		myInfo.data.totalChips = tableData[GOLD_BALANCE]
        myInfo.data.diamondBalance = tableData[DIAMOND_BALANCE]
        self:getParent():updateData()
        QManagerListener:Notify({layerID = eToolBarToopID})	
	end
	
end
return ShopExchargeLayer