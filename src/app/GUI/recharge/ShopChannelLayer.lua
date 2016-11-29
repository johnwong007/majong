--
-- Author: junjie
-- Date: 2015-11-30 10:06:53
--
--支付界面
local ShopChannelLayer = class("ShopChannelLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
require("app.Component.CMCommon")

local mChannelPath = {
	 ["ZFB"]  = "picdata/shop/channel_zfb.png" ,   --支付宝
	 ["MM"] = "picdata/shop/channel_yddx.png"  , --移动短信
	 ["CM"] = "picdata/shop/channel_ydqb.png",   --移动钱包
	 ["ZT"] = "picdata/shop/channel_sjczk.png",  --手机充值卡
	 --["UN"] = "picdata/shop/channel_zglt.png",   --中国联通
	 ["UP"] = "picdata/shop/channel_ylzx.png",   --银联支付
	 ["UN"] = "picdata/shop/channel_ltdx.png",   --联通短信
	 ["WPAY"] = "picdata/shop/channel_dxzf.png",   --短信支付
	 ["CFT"] = "picdata/shop/channel_cft.png",    --财付通

 	 ["LLPAY"] =  "picdata/shop/channel_llpay.png",  --练练支付
 	 ["WEIXIN_APP"] = "picdata/shop/channel_wxpay.png", --微信支付
}
local ERechargeType=
{
	eRechargeAliPay = 0,    --支付宝
    eRechargeLLPay  = 1,    --连连支付
	eRechargeSMSPay = 2,	--中移动 话费支付
	eRechargeWallet = 3,	--手机钱包
	eRechargeUniPay = 4,	--联通话费
	eRechargeUpomp  = 5,		--银联支付
	eRechargePPS    = 6,		--pps支付
	eRechargeDKPay  = 7,		--支付宝支付
	eRechargeAliPayOpen =8,--支付宝钱包
	eRechargeWpay   = 9,		--微派
	eRechargeTenPay = 10,     --财付通
	eRecharge91DPay = 11,	--91点金
	eRechargeTencentUnipay = 12,--应用宝支付
    eRechargeApple  = 13,     --苹果商城
}
function ShopChannelLayer:ctor(params)	
	--dump(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
	self.mPayType = {}				
	self.mActivitySprite = {}
	self:sortPayType(params)
	
end
function ShopChannelLayer:create()
	self:initUI()
end
function ShopChannelLayer:onEnter()
	
end
function ShopChannelLayer:onExit()
	self.params = nil
	self.mPayType = nil				
	self.mActivitySprite = nil
end
function ShopChannelLayer:sortPayType(params)
	local allhowType = {"ZFB","LLPAY","MM","CM","ZT","UN","UP","WPAY","CFT","WEIXIN_APP"}
	local serverData = json.decode(params[PAY_TYPE])
	for i,v in pairs(serverData) do 
		for j,k in pairs(allhowType) do
			if v[1] == k then
				table.insert(self.mPayType,v[1])
			end
		end 
	end
	self.mPayType = QManagerPlatform:filterItemList(self.mPayType)
	if params.nType == 2 then 		--月卡不需要手机充值卡
		for i,v in pairs(self.mPayType) do
			if v == "ZT" then
				table.remove(self.mPayType,i)
			end
		end
	end
end
function ShopChannelLayer:initUI( )
	self.mBg = cc.Sprite:create("picdata/public/bg_2_tc_m.png")
	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	--self.mBg:setPosition(bgWidth/2,bgHeight/2)
	self:addChild(self.mBg)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end)
	btnClose:setPosition(bgWidth-30,bgHeight - 30)
	self.mBg:addChild(btnClose)

	local title = cc.Sprite:create("picdata/shop/title_channel.png")
	title:setPosition(bgWidth/2,bgHeight - 55)
	self.mBg:addChild(title)


	local sGouMai = cc.ui.UILabel.new({
        text  = "购买:",
        size  = 26,
        color = cc.c3b(164,195,255),
        x     = 45,
        y     = title:getPositionY() - 45,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(sGouMai)

    local sGouMaiNum = cc.ui.UILabel.new({
        text  = self.params[ZBF_GOODS_ITEM_NAME],
        size  = 26,
        color = cc.c3b(223,213,180),
        x     = 115,
        y     = sGouMai:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(sGouMaiNum)
	-- if (strMoney == "108元") {
 --        sGouMaiNum:setString("一张赛事门票");
 --    }

	local sZhiFu = cc.ui.UILabel.new({
        text  = "支付:",
        size  = 26,
        color = cc.c3b(164,195,255),
        x     = 370,
        y     = sGouMai:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(sZhiFu)

    local sZhiFuNum = cc.ui.UILabel.new({
        text  = self.params[BUYCOINLIST_COIN].."元",
        size  = 26,
        color = cc.c3b(223,213,180),
        x     = 450,
        y     = sGouMai:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(sZhiFuNum)

    self.mShopChannelBg = cc.Sprite:create("picdata/shop/shopChannelBack.png")
	self.mShopChannelBg:setPosition(bgWidth/2,225)
	self.mBg:addChild(self.mShopChannelBg)

	self:createLeftList( )

end
--[[
	创建左边列表
]]
function ShopChannelLayer:createLeftList( )
	-- body
	self.mListSize = cc.size(self.mShopChannelBg:getContentSize().width-10,self.mShopChannelBg:getContentSize().height - 10)	
	self.mList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(5, 5, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchListener))
    :addTo(self.mShopChannelBg)    
  	self.mActivitySprite  = {}
  	local lens = math.ceil(#self.mPayType/3)
	for i = 1,lens do 
		local item = self.mList:newItem() 
		 -- local content     
	  --   content = cc.LayerColor:create(
	  --       cc.c4b(math.random(250),
	  --           math.random(250),
	  --           math.random(250),
	  --           250))
	  --   content:setContentSize(self.mListSize.width, 100)
	  --   content:setTouchEnabled(true)    
	  --   item:addContent(content)
	  
	  --for j = 1,3 do
		
		local node = display.newNode()	
		item:addContent(node) 
		local index = (i-1)*3 

		local pic1 = cc.Sprite:create(mChannelPath[self.mPayType[index+1]])
	    pic1:setPosition(85,pic1:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
	    node:addChild(pic1)   
	    self.mActivitySprite[#self.mActivitySprite + 1] = pic1
	    if self.mPayType[index+2] then
		    local pic2 = cc.Sprite:create(mChannelPath[self.mPayType[index+2]])
		    :align(display.CENTER, 253,pic1:getPositionY()) --设置位置 锚点位置和坐标x,y
		    node:addChild(pic2)
		    self.mActivitySprite[#self.mActivitySprite + 1] = pic2
		end 

		if self.mPayType[index+3] then
		    local pic3 = cc.Sprite:create(mChannelPath[self.mPayType[index+3]])
		    :align(display.CENTER,421,pic1:getPositionY()) --设置位置 锚点位置和坐标x,y
		    node:addChild(pic3) 
		    self.mActivitySprite[#self.mActivitySprite + 1] = pic3
	    end	 
	    if i == lens then 
			self.mSelectSprite = cc.Sprite:create("picdata/shop/channel_select.png")
			self.mSelectSprite:setVisible(false)
			self.mSelectSprite:setPosition(self.mActivitySprite[1]:getPositionX(),self.mActivitySprite[1]:getPositionY())
			node:addChild(self.mSelectSprite ,1,101)
		end
		node:setContentSize(self.mListSize.width, pic1:getContentSize().height+6)
		item:setItemSize(self.mListSize.width, pic1:getContentSize().height+6)
	   	self.mList:addItem(item)
		
	end	
	self.mList:reload()	
end

function ShopChannelLayer:touchListener(event)
	--dump(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos)
	 else
		if name == "began" then
	        self.touchBeganX = x
	        self.touchBeganY = y
	       return true
	    end	    
	 end
	
end

function ShopChannelLayer:checkTouchInSprite_(x, y,itemPos)	
	for i = 1,#self.mActivitySprite do			
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then	
			if 	self.mCurSelectIndex == i then return end
			self.mCurSelectIndex = i					
			self:onMenuSwitch(i)
		else
			--self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
		end
	end	
end

function ShopChannelLayer:onMenuSwitch(idx)
	QManagerPlatform:onEvent({where = QManagerPlatform.EOnEventWhere.eOnEventShopRecharge , nType = QManagerPlatform.EOnEventActionType.eOnEventActionSelectedChannel})
	self.mSelectSprite:setVisible(true)
	self.mSelectSprite:setPosition(self.mActivitySprite[idx]:getPositionX(),self.mActivitySprite[idx]:getPositionY()-(math.ceil(idx/3) - math.ceil(#self.mActivitySprite/3)) *(self.mActivitySprite[1]:getContentSize().height+6))
	local sChannel = self.mPayType[idx]
	if sChannel == "ZT" then
		local parent = self:getParent()
		CMClose(self)
		local RewardLayer = require("app.GUI.recharge.ShopMobileCardLayer")
		CMOpen(RewardLayer, parent,self.params)
	else
		local sPayType = self.params.sPayType or "GOLD"
		local encryStr = CMMD5Charge(myInfo.data.userId..sPayType.."DEBAO"..sChannel..sChannel..self.params[BUYCOINLIST_ID])
		DBHttpRequest:createChargingOrder(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,sPayType,"DEBAO",sChannel,sChannel,self.params[BUYCOINLIST_ID],encryStr)
	end
end

--[[
	网络回调
]]
function ShopChannelLayer:httpResponse(tableData,tag)
	-- dump(tableData)
	if not tag or type(tableData) ~= "table" then return end
	if tableData.code ~= 1 and tag ~= POST_COMMAND_GETACCOUNTINFO then
		local AlertDialog = require("app.Component.CMAlertDialog").new({text = json.encode(tableData),scroll = true})
		CMOpen(AlertDialog,self:getParent())
		return
	end

    if tag == POST_COMMAND_MM_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_MM_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_ZBF_CHARGINGORDER then
    	
    	QManagerPlatform:openAlipayJni(tableData.data.orderId,
                                          tableData.data.asynCallBack,
                                          tableData.data.price,
                                          tableData.data.goodName,
                                          tableData.data.goodDesc,
                                          "",
                                          function() self:refreshMoney(tableData.data.orderId) end)
    elseif tag == POST_COMMAND_LLPAY_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_YDQB_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_UNIPAY_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_UPOMP_CHARGINGORDER then
    	QManagerPlatform:openUpompPay_JNI(tableData.data.tn,
                                            tableData.data.orderTime,
                                            tableData.data.sign,
                                            function() self:refreshMoney(tableData.data.orderId) end)

    elseif tag == POST_COMMAND_PPS_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_DK_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_ALIPAYOPEN_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_WAP_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_TENPAY_CHARGINGORDER then
    	--财付通支付 go to html5 tenpay web
    	local url = "https://wap.tenpay.com/cgi-bin/wappayv2.0/wappay_gate.cgi?"
    				.."token_id="..tableData.data.access_token
    				.."&bank_type=0"
    				.."&paybind=1"
    	local callBackUrl = tableData.data.asynCallBack
    	    				print(url,callBackUrl)
    	QManagerPlatform:callTenPay(url,callBackUrl,function() self:refreshMoney(tableData.data.orderId) end)
				-- std::string token_id = data->rechargeOrderInfos.accessToken;
				-- std::string url;
				-- url.append("https://wap.tenpay.com/cgi-bin/wappayv2.0/wappay_gate.cgi?");
				-- url.append("token_id=");
				-- url.append(token_id);
				-- url.append("&bank_type=0");
				-- url.append("&paybind=1");
				-- NativeJNI::jumpOpenUrl_JNI(url,data->rechargeOrderInfos.asynCallBack);
                
				-- TalkingGameAnalytics::onChargeRequst(
    --                                                  data->rechargeOrderInfos.orderId.c_str(),
    --                                                  data->rechargeOrderInfos.goodsSct.c_str(),
    --                                                  atof(data->rechargeOrderInfos.price.c_str()),
    --                                                  atof(data->rechargeOrderInfos.price.c_str())*10,
    --                                                  IConvConvert_GBKToUTF8("财付通").c_str());
    elseif tag == POST_COMMAND_91DPAY_CHARGINGORDER then
    	--todo
    elseif tag == POST_COMMAND_TENCENT_UNIPAY then
    	--todo
    elseif tag == POST_COMMAND_APPLE_CHARGINGORDER then
    	--todo		
    elseif tag == POST_COMMAND_GETACCOUNTINFO then
    	-- dump(tableData)
    	myInfo.data.totalChips = tableData["5029"] + 0 
    	self:getParent().goldenNum:setString(CMFormatNum(myInfo.data.totalChips))
    elseif tag == POST_COMMAND_WEIXIN_CHARGINGORDER then
    	local reqTable = {
    		["partnerId"] = tableData.data.orderId,
    		["prepayid"] = tableData.data.extension.prepay_id,
    		["noncestr"] = tableData.data.extension.nonce_str,
    		["timestamp"] = tableData.data.extension.timeStamp,
    		["packageStr"] = "Sign=WXPay",
    		["sign"] = tableData.data.extension.sign_1
    	}
    	QManagerPlatform:callWeChatPay(reqTable, function() self:refreshMoney(tableData.data.orderId) end)
    else
    	--todo
    end
	if tag then	
		local payType = {
			[POST_COMMAND_MM_CHARGINGORDER]     = "MM商场",
			[POST_COMMAND_ZBF_CHARGINGORDER]    = "支付宝",
			[POST_COMMAND_LLPAY_CHARGINGORDER]  = "连连支付",
			[POST_COMMAND_YDQB_CHARGINGORDER]   = "移动钱包",
			[POST_COMMAND_UNIPAY_CHARGINGORDER ]= "联通沃商店",
			[POST_COMMAND_UPOMP_CHARGINGORDER]= "银联",
			[POST_COMMAND_PPS_CHARGINGORDER    ]= "PPS平台",
			[POST_COMMAND_DK_CHARGINGORDER     ]= "百度多酷",
			[POST_COMMAND_ALIPAYOPEN_CHARGINGORDER  ]= "",
			[POST_COMMAND_WAP_CHARGINGORDER    ]= "",
			[POST_COMMAND_TENPAY_CHARGINGORDER    ]= "财付通网页",
			[POST_COMMAND_91DPAY_CHARGINGORDER    ]= "91点金",
			[POST_COMMAND_TENCENT_UNIPAY			 ]= "财付通",	
			[POST_COMMAND_APPLE_CHARGINGORDER     ]= "苹果官方",
			[POST_COMMAND_WEIXIN_CHARGINGORDER] = "微信应用支付",
			[POST_COMMAND_ANQU_CHARGINGORDER] = "安趣支付",
		}
		QManagerPlatform:onChargeRequest({orderId = tableData.data.orderId,iapId = tableData.data.goodName,currencyAmount = tableData.data.price,virtualCurrencyAmount = 10 * (tableData.data.price),paymentType = payType[tag] or ""})
	end
end

function ShopChannelLayer:refreshMoney(orderId)
	-- dump(orderId)
	-- body
	DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(orderId) self:httpResponse(data) end)
end

return ShopChannelLayer