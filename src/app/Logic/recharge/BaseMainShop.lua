
-- local SMSCOUNT = 5
-- local SMSPAYCODE = {"30000281324901", "30000281324902", "30000281324903", "30000281324904", "30000281324905"}
-- local SMSPRICE = {2, 5, 10, 20, 30}
-- local UNIPAYCOUNT = 9
-- local UNIPAYCODE_THIRD_PARTY = {"906140634220140722153848862500018",
-- 	"906140634220140722153848862500011", "906140634220140722153848862500013",
-- 	"906140634220140722153848862500016", "906140634220140722153848862500017",
-- 	"906140634220140722153848862500012", "906140634220140722153848862500014",
-- 	"906140634220140722153848862500015", "906140634220140722153848862500019"}
-- local UNIPAYCODE = {"140722046416", "140722046404", "140722046405",
-- 	"140722046406", "140722046407", "140722046417", "140722046418", "140722046419", "140722046420"}
-- local UNIPAYPRICE = {2, 5, 10, 20, 30, 50, 100, 200, 1000}

-- local s_applePayUserId = "s_applePayUserId"
-- local s_applePayUserName = "s_applePayUserName"
-- local s_applePayEncodeJson = "s_applePayEncodeJson"
-- local s_applePayOrderId = "s_applePayOrderId"
-- local s_applePaytrans = "s_applePaytrans"

-- local WPAYCOUNT = 5
-- local WPAYCODE = {"0001", "0002", "0003", "0004", "0005"}
-- local WPAYPRICE = {2, 5, 10, 20, 30}

-- -- local BaseMainShop = class("BaseMainShop", function()
-- --         return display.newNode()
-- --     end)
-- local BaseMainShop = class("BaseMainShop")

-- function BaseMainShop:ctor()
-- 	self.m_bItemlistReady = false
-- 	self.shopSwitchTag = false
-- 	self.m_pCallbackUI = nil
-- 	self.m_itemList = nil
-- 	self.m_diamondList = nil
--     self.m_AwardList = nil
--     self.m_InfoList = {}

--     self.m_orderId = ""
-- 	self.m_phoneCardOrder = ""

-- 	self.testFlag = false
-- end

-- function BaseMainShop:httpResponse(event)

--     local ok = (event.name == "completed")
--     local request = event.request
 
--     if not ok then
--         -- 请求失败，显示错误代码和错误消息
--         -- print(request:getErrorCode(), request:getErrorMessage())
--         return
--     end
 
--     local code = request:getResponseStatusCode()
--     if code ~= 200 then
--         -- 请求结束，但没有返回 200 响应代码
--         -- print(code)
--         return
--     end
--     -- 请求成功，显示服务端返回的内容
--     local response = request:getResponseString()
-- 	-- self:dealLoginResp(request:getResponseString())
-- 	self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

-- end

-- function BaseMainShop:onHttpResponse(tag, content, state)
-- 	if tag == POST_COMMAND_UserTicketList then
--         self:dealUserTicketListResp(content)
--     elseif tag == POST_COMMAND_PHONECARD then --手机充值返回
--         self:dealPhoneCard(content)
--     elseif tag == POST_COMMAND_ZBF_CHARGINGORDER then --支付宝下单
--         self:dealChargeOrder(eRechargeAliPay, content)
--     elseif tag == POST_COMMAND_LLPAY_CHARGINGORDER then --连连支付下单
--         self:dealChargeOrder(eRechargeLLPay, content)
--     elseif tag == POST_COMMAND_ALIPAYOPEN_CHARGINGORDER then --阿里巴巴开放平台（不同于支付宝）
--         self:dealChargeOrder(eRechargeAliPayOpen, content)
--     elseif tag == POST_COMMAND_YDQB_CHARGINGORDER then
--         self:dealChargeOrder(eRechargeWallet, content)
--     elseif tag == POST_COMMAND_Mself.m_CHARGINGORDER then
--         self:dealChargeOrder(eRechargeSMSPay, content)
--     elseif tag == POST_COMMAND_UNIPAY_CHARGINGORDER then
--         self:dealChargeOrder(eRechargeUniPay, content)
--     elseif tag == POST_COMMAND_UPOMP_CHARGINGORDER then
--         self:dealChargeOrder(eRechargeUpomp, content)
--     elseif tag == POST_COMMAND_PPS_CHARGINGORDER then 
--         self:dealChargeOrder(eRechargePPS, content)
--     elseif tag == POST_COMMAND_DK_CHARGINGORDER then 
--         self:dealChargeOrder(eRechargeDKPay, content)
--     elseif tag == POST_COMMAND_WAP_CHARGINGORDER then 
--         self:dealChargeOrder(eRechargeWpay, content)
--     elseif tag == POST_COMMAND_TENPAY_CHARGINGORDER then --tenpay
--         self:dealChargeOrder(eRechargeTenPay,content)
--     elseif tag == POST_COMMAND_GETITEMLIST then --商品列表
--         self.m_bItemlistReady = true
--         self:dealGoodItemList(content)
--     elseif tag == POST_COMMAND_GETBULLETIN then --公告
--         self:dealGetBulletin(content)
--     elseif tag == POST_COMMAND_GETACCOUNTINFO then --更新账户信息
--         self:dealGetAccountInfo(content)
--     elseif tag == POST_COMMAND_91DPAY_CHARGINGORDER then 
--         self:dealChargeOrder(eRecharge91DPay,content)
--     elseif tag == POST_COMMAND_TENCENT_UNIPAY then 
--         self:dealChargeOrder(eRechargeTencentUnipay,content)
--     elseif tag == POST_COMMAND_REDUCE_TENCENT_GAMECOIN then 
-- 		self:dealGameCoinReduce(content)
-- 	elseif tag == POST_COMMAND_QUERY_TENCENT_GAMECOIN then 
-- 		self:dealGameCoinQuery(content)
-- 	elseif tag == POST_COMMAND_GET_SHOPSWITCH then 
--         self.shopSwitchTag = content
--     elseif tag == POST_COMMAND_GETGOODSLIST then -- 积分 列表
--         self:dealScoreList(content)
-- 	elseif tag == POST_COMMAND_CHAMPIONSHIPLIST then 
            
--     elseif tag == POST_COMMAND_BUYGOODS then -- 积分兑换
-- 		self:dealBuyGoods(content)
-- 	elseif tag == POST_COMMAND_APPLE_CHARGINGORDER then 
--         self:dealChargeOrder(eRechargeApple,content)
--     elseif tag == POST_COMMAND_APPPAYNOTIFYSERVER then 
--         self:dealApplePayNotifyServerResp(content)
--     elseif tag == POST_COMMAND_CheckUserAuth then 
--         self:dealCheckUserAuthResp(content)
--     elseif tag == POST_COMMAND_getUserVipInfo then 
--         self:dealGetUserVipInf(content)
--     end
-- end

-- function BaseMainShop:dealGetUserVipInf(strJson)
-- 	local vipInfo = UserVipInfo:new()
--     if (vipInfo:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS ) then
--         self.m_pCallbackUI:showVipInfo(vipInfo.vipRank, vipInfo.nextVipRank, vipInfo.userLv)
--         MyInfo:shareInstance().vipLevel =vipInfo.userLv
--         MyInfo:shareInstance().vipRank = vipInfo.vipRank
--         MyInfo:shareInstance().nextVipRank = vipInfo.nextVipRank
--     end
--     CC_SAFE_DELETE(vipInfo)
-- end

-- function BaseMainShop:setMainShopCallback(callback)

-- 	self.m_pCallbackUI = callback
-- end

-- function BaseMainShop:getUserVipInfo()
--     self.m_httpRequest:getUserVipInfo(this, MyInfo:shareInstance().userId)
-- end

-- function BaseMainShop:dealGameCoinQuery(strJson)

-- 	if(strJson == nil)
	
-- 		return
-- 	end
    
-- 	GameCoinQueryResponse *data = new GameCoinQueryResponse()
-- 	if( data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS && data.code == "")
	
-- 		if (data.ret==0)
		
			
-- 			if (data.balance>=atoi(UserConfig:shareInstance().price))
			
                
-- 				CCLog("===== data.balance[%d] =====",data.balance)
                
-- #if (CC_TARGET_PLATFORM == CC_PLATFORself.m_ANDROID)
				
-- 				gameCoinPay()
-- #else
                
-- 				DBHttpSender:shareDBHttpSender():reduceTencentGameCoin(this, "http:--pay.debao.com/index.php",
--                                                                          "91FCDC6A90ADF8A444C5FE43944ED5D7","6FB6205ACA34D61AA8875F96ED88B545",
--                                                                          "desktop_self.m_qq-10000144-android-2002-","a55e6bccd1cdbe178ccb8f74aa7ca0da",
--                                                                          "17377E3C281CAF95AA3ACB0A746D5C32",UserConfig:shareInstance().price, UserConfig:shareInstance().goodsname,"1",
--                                                                          MyInfo:shareInstance().userId, MyInfo:shareInstance().userName, UserConfig:shareInstance().orderId,UserConfig:shareInstance().asynCallBack)
                
-- #endif
-- 			else
                
-- 				NativeJNI:tencentUnipay_JNI(UserConfig:shareInstance().price)
-- 			end
            
            
-- 		else
            
-- 			gameCoinTips("查询失败")
-- 		end
-- 	end
-- 	CC_SAFE_DELETE(data)
    
-- end

-- function BaseMainShop:dealApplePayNotifyServerResp(strJson)

--     if(strJson == nil || self.m_pCallbackUI == nil)
    
--         return
--     end
    
--     AppTransactionStatePurchased* data = new AppTransactionStatePurchased()
--     if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS)
    
--         --    TODO data.result=-3,的情况,重新请求一次订单
--         if(data.result == 1)
        
--             CCUserDefault:sharedUserDefault():setStringForKey(s_applePayUserId, "")
--             CCUserDefault:sharedUserDefault():setStringForKey(s_applePayUserName, "")
--             CCUserDefault:sharedUserDefault():setStringForKey(s_applePayEncodeJson, "")
--             CCUserDefault:sharedUserDefault():setStringForKey(s_applePayOrderId, "")
--             CCUserDefault:sharedUserDefault():setStringForKey(s_applePaytrans, "")
--             TalkingGameAnalytics:onChargeSuccess(self.m_orderId)
--             self.m_pCallbackUI:alertDialog("购买成功，您可以到支付记录里查看本次购买记录")
--             cocos2d:CCNotificationCenter:sharedNotificationCenter():postNotification("APPLE_BUY_REFRESH", nil)

        
--         elseif(data.result == -3)
        
--             self.m_httpRequest:ApplePaySuccessCallback(this, CCUserDefault:sharedUserDefault():getStringForKey(s_applePayUserId), CCUserDefault:sharedUserDefault():getStringForKey(s_applePayUserName), CCUserDefault:sharedUserDefault():getStringForKey(s_applePayEncodeJson), CCUserDefault:sharedUserDefault():getStringForKey(s_applePayOrderId), CCUserDefault:sharedUserDefault():getStringForKey(s_applePaytrans))
--             self.m_pCallbackUI:alertDialog("对不起，购买过程发生错误，将重新请求发货，请稍候")
--         else
--             self.m_pCallbackUI:alertDialog("对不起，购买过程发生错误，请联系客服人员")
--         end
--     end
--     CC_SAFE_DELETE(data)
-- end

-- function BaseMainShop:dealCheckUserAuthResp(strJson)

--     if(strJson == nil || self.m_pCallbackUI == nil)
    
--         return
--     end
--     int ret = atoi(strJson)
--     if (ret==1) --成功
    
        
--     elseif(ret==403) --未登录
    
    
--     elseif(ret==-10000) --系统异常
    
        
--     elseif(ret<0) --认证失败
    
    
--     end
    
-- end

-- function BaseMainShop:dealGoodDiamondList(strJson)

    
-- 	CC_SAFE_DELETE(self.m_diamondList)
--     CC_SAFE_DELETE(self.m_AwardList)
    
    
    
-- 	BuyDiamondInfos* data = new BuyDiamondInfos()
-- 	if (data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS)
	
-- 		self.m_diamondList = new BuyDiamondInfos(filterGoodsList(data,0))
--                  if (self.shopSwitchTag==1)
         		
--         self.m_AwardList  = new BuyDiamondInfos(filterGoodsList(data,1))
--          end
-- #if (DEBAO_PHONE_PLATFORM == DEBAO_ANDROID)
--         self.m_AwardList  = new BuyDiamondInfos(filterGoodsList(data,1))
-- #endif
--         if(self.m_pCallbackUI)
-- 			self.m_pCallbackUI:showDiamondList(self.m_diamondList,self.m_AwardList)
-- 	end
-- end


-- function BaseMainShop:dealScoreList(strJson)

    
--     self.m_InfoList.clear()
    
--     BuyDiamondInfos* data = new BuyDiamondInfos()
--     if (data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS)
    
        
--         for(unsigned int i = 0 i < data.diamondInfos.size() i++)
        
--             ShopCellData nodeInfo
            
--             nodeInfo.remainNum     = data.diamondInfos[i].remainNum
--             nodeInfo.initNum = data.diamondInfos[i].initNum
--             nodeInfo.payNum = data.diamondInfos[i].payNum
--             nodeInfo.payType = data.diamondInfos[i].payType
--             nodeInfo.pVipLevel = data.diamondInfos[i].pVipLevel
--             nodeInfo.storeGoodsIsNew = data.diamondInfos[i].storeGoodsIsNew
--             nodeInfo.goodsPic = data.diamondInfos[i].goodsPic
--             nodeInfo.goodsType = data.diamondInfos[i].goodsType
--             nodeInfo.goodsDesc = data.diamondInfos[i].goodsDesc
--             nodeInfo.goodsGroup = data.diamondInfos[i].goodsGroup
--             nodeInfo.propsGoodsName = data.diamondInfos[i].propsGoodsName
--             nodeInfo.propsGoodsID = data.diamondInfos[i].propsGoodsID
            
--             self.m_InfoList.push_back(nodeInfo)
            
--         end
--         if(self.m_pCallbackUI)
        
--             self.m_pCallbackUI:updateShopLayer(self.m_InfoList)
--         end
--     end
-- end


-- BuyDiamondInfos BaseMainShop:filterGoodsList(srcData,type)

-- 	BuyDiamondInfos destData
-- 	for(unsigned int i = 0 i < srcData.diamondInfos.size() i++)
	
-- 		BuyDiamondInfo nodeInfo

--         if (type==0)  
--                 nodeInfo.remainNum     = srcData.diamondInfos[i].remainNum
--                 nodeInfo.initNum = srcData.diamondInfos[i].initNum
--                 nodeInfo.payNum = srcData.diamondInfos[i].payNum
--                 nodeInfo.payType = srcData.diamondInfos[i].payType
--                 nodeInfo.pVipLevel = srcData.diamondInfos[i].pVipLevel
--                 nodeInfo.storeGoodsIsNew = srcData.diamondInfos[i].storeGoodsIsNew
--                 nodeInfo.goodsPic = srcData.diamondInfos[i].goodsPic
--                 nodeInfo.goodsDesc = srcData.diamondInfos[i].goodsDesc
--                 nodeInfo.goodsGroup = srcData.diamondInfos[i].goodsGroup
--                 nodeInfo.propsGoodsName = srcData.diamondInfos[i].propsGoodsName
--                 nodeInfo.propsGoodsID = srcData.diamondInfos[i].propsGoodsID
                
--                 destData.diamondInfos.push_back(nodeInfo)
-- --            end
--         elseif(type==1)
-- --            srcData.diamondInfos[i].goodsGroup=="EXCHANGE"&&
--             if(srcData.diamondInfos[i].propsGoodsName.find("金币")==-1)
            
--                 nodeInfo.remainNum     = srcData.diamondInfos[i].remainNum
--                 nodeInfo.initNum = srcData.diamondInfos[i].initNum
--                 nodeInfo.payNum = srcData.diamondInfos[i].payNum
--                 nodeInfo.payType = srcData.diamondInfos[i].payType
--                 nodeInfo.pVipLevel = srcData.diamondInfos[i].pVipLevel
--                 nodeInfo.storeGoodsIsNew = srcData.diamondInfos[i].storeGoodsIsNew
--                 nodeInfo.goodsPic = srcData.diamondInfos[i].goodsPic
--                 nodeInfo.goodsDesc = srcData.diamondInfos[i].goodsDesc
--                 nodeInfo.goodsGroup = srcData.diamondInfos[i].goodsGroup
--                 nodeInfo.propsGoodsName = srcData.diamondInfos[i].propsGoodsName
--                 nodeInfo.propsGoodsID = srcData.diamondInfos[i].propsGoodsID
                
--                 destData.diamondInfos.push_back(nodeInfo)
--             end
--         end
--     end
    
-- 	CCLog("destData size[%lu]",destData.diamondInfos.size())
-- 	return destData
-- end

-- function BaseMainShop:dealGameCoinReduce(strJson)

-- 	if(strJson == nil)
	
-- 		return
-- 	end
    
-- 	CCLog("======== strJson [%s]",strJson)
-- 	Json:Reader reader
-- 	Json:Value root
-- 	if (reader.parse(strJson, root))  -- reader将Json字符串解析到root，root将包含Json里所有子元素
	
-- 		int ret = root["ret"].asInt()    -- 访问节点，code = 100
        
-- 		CCLog("======== ret [%d]",ret)
        
-- 		if (ret==0)
		
-- 			CCLog("============= tencent reduce successnot  ==============")
-- 			gameCoinTips("购买成功")
            
            
-- 			TalkingGameAnalytics:onEvent(eOnEventUnkowRecharge, eOnEventActionRechargeSuc)
-- 			TalkingGameAnalytics:onChargeSuccess(UserConfig:shareInstance().orderId)
            
-- 		else
-- 			CCLog("============= tencent reduce failednot  ==============")
-- 			gameCoinTips("购买失败")
-- 		end
-- 	end
    
	
-- 	--更新 金币
-- 	DBHttpSender:shareDBHttpSender():getAccountInfo(this)
    
-- end

-- function BaseMainShop:dealGetAccountInfo( strJson)

-- 	if(strJson == nil)
	
-- 		return
-- 	end
    
-- 	AccountInfo *data = new AccountInfo()
-- 	if( data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS && data.code == "")
	
-- 		MyInfo:shareInstance():setTotalChips(atof(data.silverBalance))
-- 		MyInfo:shareInstance().diamondBalance = atof(data.diamondBalance)
        
        
-- 		self.m_pCallbackUI:updatePlayerMoney(MyInfo:shareInstance():getTotalChips())
-- 	end
-- 	CC_SAFE_DELETE(data)
    
-- end

-- function BaseMainShop:dealGetBulletin(strJson)

-- 	if(not self.m_pCallbackUI)
	
-- 		return 
-- 	end
    
-- 	GetBulletin *data = new GetBulletin()
-- 	if( data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS && data.code=="" && data.bulletinStr.length()>0)
	
-- 		self.m_pCallbackUI:showBulletin((char*)data.bulletinStr)
-- 	end
-- 	CC_SAFE_DELETE(data)
-- end
-- function BaseMainShop:dealChargeOrder(type,strJson)

-- 	DebaocCreateChargingOrders data =  DebaocCreateChargingOrders:ctor()
    
-- 	if (data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS)
	
-- 		if(data.rechargeOrderInfos.rescode < 0)
		
-- 			if (self.m_pCallbackUI)
-- 				self.m_pCallbackUI:chargeOrderResult(false, data.rechargeOrderInfos.info)
		
-- 		else
		
--             self.m_orderId = data.rechargeOrderInfos.orderId
			
-- 			if (type == eRechargeAliPay)
			
-- #if(CC_TARGET_PLATFORM==CC_PLATFORself.m_ANDROID)
--                 NativeJNI:openAliPay_JNI(data.rechargeOrderInfos.orderId,
--                                           data.rechargeOrderInfos.asynCallBack,
--                                           data.rechargeOrderInfos.price,
--                                           data.rechargeOrderInfos.goodsname,
--                                           data.rechargeOrderInfos.goodsSct,
--                                           "")
-- #if (TRUNK_VERSION ~= TENCENT_TRUNK)
--                 TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsname,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("支付宝"))
-- #endif
                
-- #elif(CC_TARGET_PLATFORM==CC_PLATFORself.m_IOS)
--                 AlixPayConfig *alipay = AlixPayConfig:shareInstance()
--                 alipay:pay(data.rechargeOrderInfos.orderId,
--                             data.rechargeOrderInfos.goodsname,
--                             data.rechargeOrderInfos.goodsSct,
--                             data.rechargeOrderInfos.price,
--                             data.rechargeOrderInfos.asynCallBack)
--                 TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsname,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("支付宝"))
-- #endif
			
--             elseif(type == eRechargeLLPay) then   --连连支付
            
-- 				if(CC_TARGET_PLATFORM==CC_PLATFORself.m_ANDROID) then--android
                
--                 	NativeJNI:openLLPay_JNI(data.rechargeOrderInfos.orderId,
--                                           data.rechargeOrderInfos.asynCallBack,
--                                           data.rechargeOrderInfos.price,
--                                           data.rechargeOrderInfos.goodsname,
--                                           data.rechargeOrderInfos.goodsSct,
--                                           MyInfo:shareInstance().userId,
--                                           UserDefaultSetting:shareInstance():getLLPayFlag()
--                                          )
            
                
-- 				elseif(CC_TARGET_PLATFORM==CC_PLATFORself.m_IOS) then --ios
--                 	char price[20]
--                 	sprintf(price, "%.2f",atof(data.rechargeOrderInfos.price))
--              	((AppDelegate *)CCApplication:sharedApplication()):llPay(data.rechargeOrderInfos.orderId,price, data.rechargeOrderInfos.orderTime, data.rechargeOrderInfos.goodsname, data.rechargeOrderInfos.asynCallBack)
                
-- 				end
--             	TalkingGameAnalytics:onChargeRequst(
--                                     data.rechargeOrderInfos.orderId,
--                                     data.rechargeOrderInfos.goodsname,
--                                     atof(data.rechargeOrderInfos.price),
--                                     atof(data.rechargeOrderInfos.price)*10,
--                                     IConvConvert_GBKToUTF8("连连支付"))
            
-- 			elseif(type == eRechargeAliPayOpen) then
			
-- 				NativeJNI:openAliPay_JNI(data.rechargeOrderInfos.orderId,
--                                           data.rechargeOrderInfos.asynCallBack,
--                                           data.rechargeOrderInfos.price,
--                                           data.rechargeOrderInfos.goodsname,
--                                           data.rechargeOrderInfos.goodsSct,
--                                           data.rechargeOrderInfos.accessToken)
-- 				TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsname,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("支付宝开放平台"))
			
-- 			elseif (type == eRechargeSMSPay) then
			
-- 				int price = atoi(data.rechargeOrderInfos.price)
-- 				for (int i = 0 i < SMSCOUNT ++i)
				
-- 					if (SMSPRICE[i] == price) then
					
-- 						NativeJNI:openSMSPay_JNI(SMSPAYCODE[i],
--                                                   1,
--                                                   data.rechargeOrderInfos.orderId,
--                                                   data.rechargeOrderInfos.asynCallBack)
-- 						if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 							TalkingGameAnalytics:onChargeRequst(
--                                                              data.rechargeOrderInfos.orderId,
--                                                              data.rechargeOrderInfos.goodsname,
--                                                              atof(data.rechargeOrderInfos.price),
--                                                              atof(data.rechargeOrderInfos.price)*10,
--                                                              IConvConvert_GBKToUTF8("MM商场"))
-- 						end
-- 						break
-- 					end
-- 				end
			
-- 			elseif (type == eRechargeWallet) then
			
-- 				string priceStr = EUtils:ItoA(atoi(data.rechargeOrderInfos.price)*100)
-- 				NativeJNI:openPhonePay_JNI(data.rechargeOrderInfos.orderId,
--                                             data.rechargeOrderInfos.asynCallBack,
--                                             priceStr,
--                                             data.rechargeOrderInfos.goodsname,
--                                             data.rechargeOrderInfos.goodsSct)
-- 				if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 					TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsname,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("移动钱包"))
-- 				end
			
-- 			elseif (type == eRechargeUniPay) then
			
-- 				int price = atoi(data.rechargeOrderInfos.price)
-- 				for (int i = 0 i < UNIPAYCOUNT ++i)
				
-- 					if (UNIPAYPRICE[i] == price) then
					
						
-- 						NativeJNI:openUniPay_JNI(data.rechargeOrderInfos.orderId,
--                                                   UNIPAYCODE[i],UNIPAYCODE_THIRD_PARTY[i],
--                                                   data.rechargeOrderInfos.asynCallBack,
--                                                   data.rechargeOrderInfos.goodsname,
--                                                   price)
-- 						if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 							TalkingGameAnalytics:onChargeRequst(
--                                                              data.rechargeOrderInfos.orderId,
--                                                              data.rechargeOrderInfos.goodsname,
--                                                              atof(data.rechargeOrderInfos.price),
--                                                              atof(data.rechargeOrderInfos.price)*10,
--                                                              "联通沃商店")
-- 						end
-- 						break
-- 					end
-- 				end
			
-- 			elseif (type == eRechargeUpomp) then
			
-- 				NativeJNI:openUpompPay_JNI(data.rechargeOrderInfos.tn,
--                                             data.rechargeOrderInfos.orderTime,
--                                             data.rechargeOrderInfos.sign)
                
-- 				if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 					TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsname,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("银联"))
-- 				end
			
-- 			elseif (type == eRechargePPS) then
			
-- 				NativeJNI:openPPSPay_JNI(data.rechargeOrderInfos.orderId,
--                                           data.rechargeOrderInfos.price,
--                                           data.rechargeOrderInfos.orderTime,
--                                           data.rechargeOrderInfos.sign)
-- 				if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 					TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsname,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("PPS平台"))
-- 				end
			
-- 			elseif (type == eRechargeDKPay) then
			
-- 				NativeJNI:openDKBaiduPay_JNI(data.rechargeOrderInfos.orderId,
--                                               data.rechargeOrderInfos.itemId,
--                                               data.rechargeOrderInfos.goodsSct,
--                                               atoi(data.rechargeOrderInfos.price),
--                                               data.rechargeOrderInfos.asynCallBack)
-- 				if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 					TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsSct,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("百度多酷"))
-- 				end
			
-- 			elseif (type == eRechargeWpay) then
			
-- 				int price = atoi(data.rechargeOrderInfos.price)
-- 				for (int i = 0 i < WPAYCOUNT ++i)
				
-- 					if (WPAYPRICE[i] == price) then
					
-- 						NativeJNI:openWpayPay_JNI(data.rechargeOrderInfos.orderId,
--                                                    MyInfo:shareInstance().userId,
--                                                    MyInfo:shareInstance().userName,
--                                                    WPAYCODE[i])
-- 						TalkingGameAnalytics:onChargeRequst(
--                                                              data.rechargeOrderInfos.orderId,
--                                                              data.rechargeOrderInfos.goodsSct,
--                                                              atof(data.rechargeOrderInfos.price),
--                                                              atof(data.rechargeOrderInfos.price)*10,
--                                                              IConvConvert_GBKToUTF8("微派"))
-- 					end
-- 				end
			
-- 			elseif (type == eRecharge91DPay) then
			
-- 				--CCLog("xxxxxxxxxxxxxx   %s", data.rechargeOrderInfos.orderId)
-- 				NativeJNI:open91DPay_JNI(data.rechargeOrderInfos.orderId,
--                                           data.rechargeOrderInfos.itemId,
--                                           data.rechargeOrderInfos.goodsSct,
--                                           atoi(data.rechargeOrderInfos.price)*10,
--                                           data.rechargeOrderInfos.asynCallBack)
-- 				if (TRUNK_VERSION  ~= TENCENT_TRUNK) then
-- 					TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsSct,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("91点金"))
-- 				end
			
-- 			elseif(type == eRechargeTenPay) then
-- 			--go to html5 tenpay web
-- 				std:string token_id = data.rechargeOrderInfos.accessToken
-- 				std:string url
-- 				url.append("https:--wap.tenpay.com/cgi-bin/wappayv2.0/wappay_gate.cgi?")
-- 				url.append("token_id=")
-- 				url.append(token_id)
-- 				url.append("&bank_type=0")
-- 				url.append("&paybind=1")
-- 				NativeJNI:jumpOpenUrl_JNI(url,data.rechargeOrderInfos.asynCallBack)
                
-- 				TalkingGameAnalytics:onChargeRequst(
--                                                      data.rechargeOrderInfos.orderId,
--                                                      data.rechargeOrderInfos.goodsSct,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("财付通"))
			
-- 			elseif(type == eRechargeTencentUnipay) then
			
                
-- 				--应用宝支付体系
-- 				string s
-- 				stringstream ss(s)
-- 				ss << atoi(data.rechargeOrderInfos.price)*10
                
                
-- 				UserConfig:shareInstance().goodsname=data.rechargeOrderInfos.goodsname
-- 				UserConfig:shareInstance().orderId=data.rechargeOrderInfos.orderId
-- 				UserConfig:shareInstance().asynCallBack=data.rechargeOrderInfos.asynCallBack
-- 				UserConfig:shareInstance().price=ss.str()
                
                
-- 				TalkingGameAnalytics:onChargeRequst(
--                                                      UserConfig:shareInstance().orderId,
--                                                      data.rechargeOrderInfos.goodsSct,
--                                                      atof(data.rechargeOrderInfos.price),
--                                                      atof(data.rechargeOrderInfos.price)*10,
--                                                      IConvConvert_GBKToUTF8("腾讯移动支付"))
                
-- 				if (CC_TARGET_PLATFORM == CC_PLATFORself.m_ANDROID) then
-- 					gameCoinQuery()
-- 				else
-- 					DBHttpSender:shareDBHttpSender():queryTencentGameCoin(this, "http:--pay.debao.com/index.php",
--                                                                         "D99885BA12BA6126CAEF73F8247F7279","158D5940EB49DE96B2307D27C1297ED6",
--                                                                         "desktop_self.m_qq-10000144-android-2002-","372f749d73ee564cda3de902ec434259",
--                                                                         "0638995D71B65A75C2D55CEA3A654378","1",
--                                                                         MyInfo:shareInstance().userId, MyInfo:shareInstance().userName)
-- 				end
--             elseif(type == eRechargeApple) then
            
--                 if (CC_TARGET_PLATFORM == CC_PLATFORself.m_IOS) then

--                             DebaoIAPStore:shareInstance():buy(data.rechargeOrderInfos.goodId, data.rechargeOrderInfos.orderId)
                            
--                             TalkingGameAnalytics:onChargeRequst(
--                                                                  data.rechargeOrderInfos.orderId,
--                                                                  data.rechargeOrderInfos.goodsSct,
--                                                                  atof(data.rechargeOrderInfos.price),
--                                                                  atof(data.rechargeOrderInfos.price)*10,
--                                                                  IConvConvert_GBKToUTF8("苹果官方"))

                
--                 end
--             end
			
-- 			if (self.m_pCallbackUI) then
-- 				self.m_pCallbackUI:chargeOrderResult(true, data.rechargeOrderInfos.info)
-- 			end
-- 		end
-- 	end
    
-- 	data = nil
-- end

-- function BaseMainShop:gameCoinQuery()
-- 	if(SERVER_ENVIROMENT == ENVIROMENT_TEST) then
--     	DBHttpSender:shareDBHttpSender():queryTencentGameCoin(this, "http:--debaopay.boss.com/index.php",
--                                                             UserConfig:shareInstance().openid,UserConfig:shareInstance().access_token,
--                                                             UserConfig:shareInstance().pf,UserConfig:shareInstance().pfkey,
--                                                             UserConfig:shareInstance().pay_token,UserConfig:shareInstance().zoneid,
--                                                             MyInfo:shareInstance().userId, MyInfo:shareInstance().userName)
-- 	else
--     	DBHttpSender:shareDBHttpSender():queryTencentGameCoin(this, "http:--pay.debao.com/index.php",
--                                                             UserConfig:shareInstance().openid,UserConfig:shareInstance().access_token,
--                                                             UserConfig:shareInstance().pf,UserConfig:shareInstance().pfkey,
--                                                             UserConfig:shareInstance().pay_token,UserConfig:shareInstance().zoneid,
--                                                             MyInfo:shareInstance().userId, MyInfo:shareInstance().userName)
-- 	end

-- end

-- function BaseMainShop:gameCoinPay()
-- 	if(SERVER_ENVIROMENT == ENVIROMENT_TEST) then
--     	DBHttpSender:shareDBHttpSender():reduceTencentGameCoin(this, "http:--debaopay.boss.com/index.php",
--                                                              UserConfig:shareInstance().openid,UserConfig:shareInstance().access_token,
--                                                              UserConfig:shareInstance().pf,UserConfig:shareInstance().pfkey,
--                                                              UserConfig:shareInstance().pay_token,UserConfig:shareInstance().price, UserConfig:shareInstance().goodsname,UserConfig:shareInstance().zoneid,
--                                                              MyInfo:shareInstance().userId, MyInfo:shareInstance().userName, UserConfig:shareInstance().orderId,UserConfig:shareInstance().asynCallBack)
-- 	else
--     	DBHttpSender:shareDBHttpSender():reduceTencentGameCoin(this, "http:--pay.debao.com/index.php",
--                                                              UserConfig:shareInstance().openid,UserConfig:shareInstance().access_token,
--                                                              UserConfig:shareInstance().pf,UserConfig:shareInstance().pfkey,
--                                                              UserConfig:shareInstance().pay_token,UserConfig:shareInstance().price, UserConfig:shareInstance().goodsname,UserConfig:shareInstance().zoneid,
--                                                              MyInfo:shareInstance().userId, MyInfo:shareInstance().userName, UserConfig:shareInstance().orderId,UserConfig:shareInstance().asynCallBack)
--     end

-- end

-- function BaseMainShop:gameCoinTips( tip)
    
-- 	CCScene *current = CCDirector:sharedDirector():getRunningScene()
-- 	EAlertView *alertView = EAlertView:alertView(
--                                                   current,
--                                                   nil,
--                                                   Lang_Title_Prompt,
--                                                   tip,
--                                                   Lang_Button_Confirm,
--                                                   nil)
-- 	alertView:setTag(12345)
-- 	alertView:alertShow()
-- end
-- function BaseMainShop:IAPPaySuccessed_Callback(bool isSuccessed, std:string encodeJson, std:string transactionIdentifier, std:string orderId)

--     if(self.m_pCallbackUI) then
    
--         self.m_pCallbackUI:IAPPayResult()
--     end
--     if(isSuccessed) then
    
--         CCUserDefault:sharedUserDefault():setStringForKey(s_applePayUserId, MyInfo:shareInstance().userId)
--         CCUserDefault:sharedUserDefault():setStringForKey(s_applePayUserName, MyInfo:shareInstance().userName)
--         CCUserDefault:sharedUserDefault():setStringForKey(s_applePayEncodeJson, encodeJson)
--         CCUserDefault:sharedUserDefault():setStringForKey(s_applePayOrderId, orderId)
--         CCUserDefault:sharedUserDefault():setStringForKey(s_applePaytrans, transactionIdentifier)
        
--         self.m_httpRequest:ApplePaySuccessCallback(this, MyInfo:shareInstance().userId, MyInfo:shareInstance().userName, encodeJson, orderId, transactionIdentifier)
--         self.m_orderId = orderId
--     end
-- end
-- function BaseMainShop:JailbreakPaySuccessed_Callback(  orderID,  callbackURL)

--     if(self.m_pCallbackUI) then
    
--         self.m_pCallbackUI:IAPPayResult()
--     end
--     self.m_httpRequest:jailbreakChargeSuccessRequestGoodsCallback(this, callbackURL,  MyInfo:shareInstance().userId, MyInfo:shareInstance().userName, orderID)
--     TalkingGameAnalytics:onChargeSuccess(orderID)
-- end

-- function BaseMainShop:talkingGameChargesuccess()
--     TalkingGameAnalytics:onEvent(eOnEventUnkowRecharge, eOnEventActionRechargeSuc)
--     TalkingGameAnalytics:onChargeSuccess(self.m_orderId)
-- end

-- function BaseMainShop:dealGoodItemList(const string& strJson)

-- 	CC_SAFE_DELETE(self.m_itemList)
-- 	BuyDebaoBIInfos* data = new BuyDebaoBIInfos()
-- 	if (data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
-- 		self.m_itemList = new BuyDebaoBIInfos(filterItemList(data))
-- 		if(self.m_pCallbackUI) then
-- 			self.m_pCallbackUI:showItemList(self.m_itemList)
-- 		end
-- 	end
-- end

-- function BaseMainShop:phoneCardResultCode(int code)

-- 	local result
-- 	if code == 1 then
--         result = "下单成功，金币到帐会稍有延迟，请耐心等待，如有问题请联系客服！"
--     elseif code == -1 then
--         result = "对不起，帐号或密码错误，请注意区分大小写！-1"
--     elseif code == -2 then
--         result = "对不起，帐号或密码错误，请注意区分大小写！-2"
--     elseif code == -3 then
--         result = "对不起，帐号或密码错误，请注意区分大小写！-3"
--     elseif code == -4 then
--         result = "对不起，帐号或密码错误，请注意区分大小写！-4"
--     elseif code == -5 then
--         result = "对不起，系统正在维护请稍候再试！-5"
--     elseif code == -6 then
--         result = "对不起，系统正在维护请稍候再试！-6"		
--     else
--         result = "对不起，支付出错，请联系德堡客服！"
-- 	end
-- 	return result
-- end

-- function BaseMainShop:filterItemList(srcData)

-- 	BuyDebaoBIInfos destData
-- 	for(unsigned int i = 0 i < srcData.buyInfos.size() i++)
	
-- 		BuyDebaoBIInfo nodeInfo
-- 		for(unsigned int j = 0 j < srcData.buyInfos[i].payType.size() j++)
		
-- 			if(BRANCHES_VERSION == CHINAMOBILEMM) then
-- 				if(srcData.buyInfos[i].payType[j].method ~= "CM" && srcData.buyInfos[i].payType[j].method ~= "UN")
-- 					nodeInfo.payType.push_back(srcData.buyInfos[i].payType[j])
-- 				end
-- 			elseif(BRANCHES_VERSION == CHINAUNICOM) then
            
-- 				if(srcData.buyInfos[i].payType[j].method == "UNWO")
			
-- 					nodeInfo.payType.push_back(srcData.buyInfos[i].payType[j])
-- 				end
-- 			elseif(BRANCHES_VERSION == TENCENT_WITH_PAY) then
-- 				if(srcData.buyInfos[i].payType[j].method == "TENCENT") then
			
-- 					nodeInfo.payType.push_back(srcData.buyInfos[i].payType[j])
-- 				end
            
-- 			elseif(BRANCHES_VERSION == ALIPAYOPEN) then
-- 				if(srcData.buyInfos[i].payType[j].method == "ALIPAY") then
			
-- 					nodeInfo.payType.push_back(srcData.buyInfos[i].payType[j])
-- 				end
-- 			else
-- 				if(srcData.buyInfos[i].payType[j].method ~= "MM" && srcData.buyInfos[i].payType[j].method ~= "UN") then
-- 					nodeInfo.payType.push_back(srcData.buyInfos[i].payType[j])
-- 				end
-- 			end
-- 		end
-- 		if(nodeInfo.payType.size() > 0) then
		
-- 			nodeInfo.awardNum = srcData.buyInfos[i].awardNum
-- 			nodeInfo.buyCoinId = srcData.buyInfos[i].buyCoinId
-- 			nodeInfo.buyCoinInfo = srcData.buyInfos[i].buyCoinInfo
-- 			nodeInfo.buyCoinNum = srcData.buyInfos[i].buyCoinNum
-- 			nodeInfo.buyCoinpicUrl = srcData.buyInfos[i].buyCoinpicUrl
-- 			nodeInfo.goodDesc = srcData.buyInfos[i].goodDesc
-- 			nodeInfo.moneyBalance = srcData.buyInfos[i].moneyBalance
--             nodeInfo.goodId = srcData.buyInfos[i].goodId
-- 			destData.buyInfos.push_back(nodeInfo)
-- 		end
-- 	end
    
-- 	return destData
-- end


-- function BaseMainShop:dealPhoneCard(const string &strJson)

-- 	bool suc = false
-- 	DebaoRechargePhoneCardInfos* data = new DebaoRechargePhoneCardInfos()
-- 	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
-- 		if(data.rechargeInfos.code == 1) then
		
-- 			suc = true
-- 			if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 				TalkingGameAnalytics:onEvent(eOnEventUnkowRecharge, eOnEventActionRechargeSuc)
-- 				TalkingGameAnalytics:onChargeSuccess(self.m_phoneCardOrder)
-- 			end
-- 		end
-- 	end
-- 	if (self.m_pCallbackUI) then
-- 		self.m_pCallbackUI:phoneCardChargeResult(suc, phoneCardResultCode(data.rechargeInfos.code))
-- 	end
-- 	data = nil
-- end

-- function BaseMainShop:getBulletin()

-- 	self.m_httpRequest:getBulletin(this, "S")
-- end

-- function BaseMainShop:getItemBuyList()

-- 	if (DEBAO_PHONE_PLATFORM == DEBAO_IOS) then
-- 		if (isJailbreak ==1) then
--     		self.m_httpRequest:getItemList(this)
-- 		else
-- 			if (SKIN_VERSION == SKIN2) then
--     			self.m_httpRequest:getItemList(this,"APPLE","GOLD")
-- 			elseif (SKIN_VERSION == SKIN1) then
--     			self.m_httpRequest:getItemList(this,"APPLE","GOLD")
--     		end
--     	end
--     else
--     	self.m_httpRequest:getItemList(this)
--     end
-- end

-- function BaseMainShop:getAccountInfo()

-- 	self.m_httpRequest:getAccountInfo(this)
-- end

-- function BaseMainShop:getGoodsList(string type)

-- 	self.m_httpRequest:getGoodsList(this,type)
-- end

-- function BaseMainShop:getUserTicketList()
--     self.m_httpRequest:getUserTicketList(this)
-- end

-- function BaseMainShop:getGoodsSwitch()
-- 	self.m_httpRequest:getShopSwitch(this)
-- end

-- function BaseMainShop:reqChargingOrder(ERechargeType type, BuyDebaoBIInfo* info)

    
-- 	string channel
-- 	if (type == eRechargeAliPay) then
-- 		channel = "ZFB"
--     if (type == eRechargeLLPay) then
--         channel = "LLPAY"
-- 	elseif (type == eRechargeSMSPay) then
-- 		channel = "MM"
-- 	elseif(type == eRechargeWallet) then
-- 		channel = "CM"
-- 	elseif (type == eRechargeUniPay) then
-- 		--channel = "UN"
-- 		channel = "UNWO"
-- 	elseif(type == eRechargeUpomp) then
-- 		channel = "UP"
-- 	elseif (type == eRechargePPS) then
-- 		channel = "PPS"
-- 	elseif (type == eRechargeDKPay) then
-- 		channel = "DUOKU"
-- 	elseif (type == eRechargeAliPayOpen) then
-- 		channel = "ALIPAY"
-- 	elseif (type == eRechargeWpay) then
-- 		channel = "WPAY"
-- 	elseif(type == eRechargeTenPay) then
-- 		channel = "CFT"
-- 	elseif (type == eRecharge91DPay) then
-- 		channel = "DPAY"
-- 	elseif (type == eRechargeTencentUnipay) then
-- 		channel = "TENCENT"
--     elseif (type == eRechargeApple) then
--         channel = "APPLE"
--     end
-- 	string tmpStr = ""
-- 	tmpStr += MyInfo:shareInstance().userId	
-- 	tmpStr += "GOLD"
-- 	tmpStr += "DEBAO"
-- 	tmpStr += channel
-- 	tmpStr += channel
-- 	string goodId = info.buyCoinId
-- 	tmpStr += goodId
    
-- 	self.m_httpRequest:createChargingOrder(this, MyInfo:shareInstance().userId, "GOLD","DEBAO", channel, channel, goodId, MD5Charge(tmpStr))
-- end

-- BuyDebaoBIInfo*	BaseMainShop:reqBuyInfoWithIndex(int index)

-- 	if (not self.m_itemList) then
-- 		return nil
-- 	end
-- 	if(index < 0 || self.m_itemList.buyInfos.size() <= index) then
-- 		return nil
-- 	end
-- 	return &(self.m_itemList.buyInfos[index])
-- end
-- BuyDebaoBIInfo*	BaseMainShop:reqBuyInfoWithValue(int value)

-- 	if(value <= 0 ) then
-- 		return nil
-- 	end
-- 	for (int i = 0 i < self.m_itemList.buyInfos.size() ++i)
	
-- 		if (self.m_itemList.buyInfos[i].moneyBalance == value) then
		
-- 			return &self.m_itemList.buyInfos[i]
-- 		end
-- 	end
-- 	return nil
-- end

-- function BaseMainShop:reqPhoneCardCharge(int nCardType, int nValue, string &strID, string &strPS)

-- 	string strUserId = MyInfo:shareInstance().userId
-- 	string strSign = MD5Charge(strUserId + ItoA(nCardType) + ItoA(nValue) + strID + strPS + "GOLD")
-- 	self.m_httpRequest:phoneCardCharge(this,
--                                    strUserId,	nCardType,	nValue,
--                                    strID,	strPS,	"GOLD",
--                                    strSign, MyInfo:shareInstance().phpSessionId
--                                    )	
-- 	time_t now = time(nil)
-- 	self.m_phoneCardOrder = strUserId
-- 	char time[15]
-- 	sprintf(time, "%d", now)
-- 	self.m_phoneCardOrder += time
-- 	string payType
-- 	if (nCardType == 1) then
-- 		payType = "移动充值卡"
-- 	elseif(nCardType == 3) then
-- 		payType = "电信充值卡"
-- 	elseif(nCardType == 2) then
-- 		payType = "联通充值卡"
--     end
    
-- 	for (int i = 0 i < self.m_itemList.buyInfos.size() ++i)
	
-- 		if (nValue == self.m_itemList.buyInfos[i].buyCoinNum) then
		
-- 			if (TRUNK_VERSION ~= TENCENT_TRUNK) then
-- 			TalkingGameAnalytics:onChargeRequst(
--                                                  self.m_phoneCardOrder,
--                                                  self.m_itemList.buyInfos[i].goodDesc,
--                                                  nValue,
--                                                  nValue*10,
--                                                  payType)
-- 			end
-- 			return
-- 		end
-- 	end
    
	
-- end

-- function BaseMainShop:diamondExchage(int goodsID,int num)

-- 	self.m_httpRequest:buyGoods(this, goodsID, num)
-- end

-- function BaseMainShop:getCheckUserAuth(string realName,string idcardNo)

--     self.m_httpRequest:getcheckUserAuth(this, realName, idcardNo)
-- end

-- function BaseMainShop:dealBuyGoods(const char* strJson)

-- 	if(strJson == nil) then
	
-- 		return
-- 	end
--     getAccountInfo()

-- 	int ret=atoi(strJson)
-- 	if (ret==1) then  --兑换成功
	
-- 		self.m_pCallbackUI:alertDialog("兑换成功")
--     else  --兑换失败
-- 		self.m_pCallbackUI:alertDialog("兑换失败")
-- 	end
-- --	self.m_pCallbackUI:updatePlayerMoney(MyInfo:shareInstance():getTotalChips())
-- end

-- return BaseMainShop