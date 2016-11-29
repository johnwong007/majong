--
-- Author: junjie
-- Date: 2016-01-04 15:57:44
--
local CMBaseLayer = require("app.Component.CMBaseLayer")
local ShopMobileCardLayer = class("ShopMobileCardLayer",CMBaseLayer)
require("app.Network.Http.DBHttpRequest")
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")
local EnumMenu = {
	eBtnZGYD = 1,
	eBtnZGDX = 2,
	eBtnZGLT = 3,
	eBTNCZ   = 4,

}
function ShopMobileCardLayer:ctor(params)	
	self.params = params or {}
	self.params.size = cc.size(664,500)
	self.params.titlePath = "选择运营商"
	self:setNodeEventEnabled(true)
	self.mInputBox = {}
	self.size = cc.size(664,500)	
end
function ShopMobileCardLayer:create()
	ShopMobileCardLayer.super.ctor(self,self.params)
	self:initUI()
end
function ShopMobileCardLayer:initUI()
	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	local btnPath = {
		"picdata/shop/statusbar_23_zgyd_chognzhi.png",
		"picdata/shop/statusbar_24_zgdx_chongzhi.png",
		"picdata/shop/statusbar_23_zglt_chognzhi.png",

	} 
	local posx = 150
	for i = 1,3 do 
		local btnChannel = CMButton.new({normal = btnPath[i]},function () self:onMenuCallBack(i) end, {scale9 = false},{scale = false})    
	    :align(display.CENTER, posx,self.mBg:getContentSize().height-120) --设置位置 锚点位置和坐标x,y
	    :addTo(self.mBg)

	    if i== 1 then
	    	local btnselect = cc.Sprite:create("picdata/shop/channel_select.png")
	    	btnselect:setScaleY(0.8)
  			btnselect:setPosition(posx, btnChannel:getPositionY())
  			self.mBg:addChild(btnselect)

  			self.mBtnSelect = btnselect
  		end
	    posx = posx + 185
	end

  	local posy = 280
  	local data = {"请输入充值卡号","请输入密码"}
    for i = 1,2 do 
    	local imagePath = "picdata/setting/blindTextBG.png"
    	local imageSize = cc.size(426, 46)
       local inputBg  = cc.Sprite:create(imagePath)
       self.mBg:addChild(inputBg)
	    local inputBox = cc.ui.UIInput.new({
		    image = "picdata/public/transBG.png", -- 输入控件的背景
		    --x = 580,
		   -- y = 50,	    	
		    maxLength = 16,
		    size = imageSize,
		    listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		})

		inputBox:setPlaceHolder(data[i])
		inputBox:setFont("Arial", 22)
		inputBox:setFontSize(24)		
		inputBox:setFontColor(cc.c3b(250, 250, 250))
		inputBox:setPosition(118 + inputBox:getContentSize().width/2,posy-2)
		self.mBg:addChild(inputBox)	

   		inputBg:setPosition(118 + inputBox:getContentSize().width/2,posy)
		self.mInputBox[i] = inputBox
		posy = posy - 75
		--self.mChatBox = inputBox
    end

    local sNum = cc.ui.UILabel.new({
      	    text  = "到账金币：",
      	    size  = 24,
      	    color = cc.c3b(255, 90, 0),
      	    align = cc.ui.TEXT_ALIGN_LEFT,
      	    --UILabelType = 1,
      	    font  = "黑体",
      	    
      	})
    sNum:setPosition(165 + sNum:getContentSize().width/2,140)
    self.mBg:addChild(sNum)
   local sGold = cc.ui.UILabel.new({
  	    text  = self.params[ZBF_GOODS_ITEM_NAME],
  	    size  = 24,
  	    color = cc.c3b(0, 255, 225),
  	    align = cc.ui.TEXT_ALIGN_LEFT,
  	    --UILabelType = 1,
  	    font  = "黑体",
  	    
  	})
    sGold:setPosition(sNum:getPositionX()+ sNum:getContentSize().width,140)
    self.mBg:addChild(sGold)

    local btnRecharge = CMButton.new({normal = "picdata/public/confirmBtn.png",},function () self:onMenuCallBack(EnumMenu.eBTNCZ) end, {scale9 = false}) 
    btnRecharge:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255,255),
	    text = "立即充值",
	    size = 28,
	    font = "黑体",
		}) )      
    btnRecharge:setPosition(bgWidth/2, 70)
    btnRecharge:addTo(self.mBg)

end
-- 输入事件监听方法
function ShopMobileCardLayer:onEdit(event, editbox)
    if event == "began" then
    -- 开始输入
        --print("开始输入")
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
        local _text = editbox:getText()
		local _trimed = string.trim(_text)		
		if _trimed ~= _text then			
		    editbox:setText(_trimed)
		end
		-- self._sendRoleId = 0
		-- self._chatPlayer:setText("")
  -- 		self._chatName:setString(_trimed or "")
  -- 		self._chatName:setPositionX(self._chatPlayer:getContentSize().width/2 - self._chatName:getContentSize().width/2)
    elseif event == "ended" then
    -- 输入结束
        --print("输入结束")        
    elseif event == "return" then
    	
    	
    -- 从输入框返回
        --print("从输入框返回")       
    end
end
function ShopMobileCardLayer:onMenuCallBack(tag)
	if tag >= 1 and tag <= 3 then
		self.mSelectTag = tag
		self.mBtnSelect:setPositionX(-35 + 185 * tag)
	elseif tag == EnumMenu.eBTNCZ then
		self:onMenuRecharge(tag)
	end
end
function ShopMobileCardLayer:onMenuRecharge(tag)
    local strID = self.mInputBox[1]:getText()
    local strPS  = self.mInputBox[2]:getText()
    
	if strID == "" or strPS == "" then return end
	self.params[BUYCOINLIST_COIN] = tonumber(self.params[BUYCOINLIST_COIN])
	local nValue = self.params[BUYCOINLIST_COIN]
    local sName  = "GOLD" 
	local userId = myInfo.data.userId
	local phpId  = myInfo.data.phpSessionId
	local strSign= CMMD5Charge(userId..tag..nValue..strID..strPS..sName)
    DBHttpRequest:phoneCardCharge(function(tableData,tag) self:httpResponse(tableData,tag) end,userId,tag,nValue,strID,strPS,sName,strSign,phpId) 

    local payType = {
	    [1] = "移动充值卡",[2]="电信充值卡",[3]="联通充值卡"
	}
	local orderId = userId..CMGetCurrentTime()
	QManagerPlatform:onChargeRequest({orderId = orderId,iapId = self.params[ZBF_GOODS_ITEM_NAME],currencyAmount = nValue,virtualCurrencyAmount = 10 * (nValue),paymentType = payType[self.mSelectTag or 1] or ""})

end

--[[
	网络回调
]]
function ShopMobileCardLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	
	if tag == POST_COMMAND_PHONECARD then  
		local isSuc = true	
		local text = ""	
		local parent = self:getParent()		
		if tableData.code == 1 then
			text = "下单成功，金币到帐会稍有延迟，请耐心等待！"
			QManagerPlatform:onEvent({where = QManagerPlatform.EOnEventWhere.eOnEventUnkowRecharge , nType = QManagerPlatform.EOnEventActionType.eOnEventActionRechargeSuc})
			QManagerPlatform:onChargeSuccess(orderId)
			CMClose(self)
		else
			text = tableData.msg or "对不起，支付出错，请稍后再重试！"
		end		
		CMShowTip(text)

	end
	
end
return ShopMobileCardLayer