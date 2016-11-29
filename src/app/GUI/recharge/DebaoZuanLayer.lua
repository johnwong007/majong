--
-- Author: junjie
-- Date: 2016-05-30 15:24:53
--
--德堡钻界面
local DebaoZuanLayer = class("DebaoZuanLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local NetCallBack = require("app.Network.Http.NetCallBack")
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local EnumMenu = {
	eBtnSure = 1,	--确定兑换
	eBtnGive = 2,   --赠送

}
function DebaoZuanLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
	QDataShopGoldList = QManagerData:getCacheData("QDataShopGoldList")
	self.mAtivityName = {
		"赠送","兑换",
	}
	self.mType = {101,102}			--活动所有类型
	self.mLastType = nil 									--最近一次选择的类型
	self.mActivitySprite = {} 								--左边图片
	self.mRightPic       = {} 								--右边需要刷新的图片
	self.mSortType       = self.params.sortType
	self.mJumpType 		 = self.params.nType or 1 
end
function DebaoZuanLayer:create()
	self:initUI()
	self:onMenuSwitch(self.mJumpType)
end
function DebaoZuanLayer:onEnter()
	QManagerListener:Attach({{layerID = eFTCreateTeamLayerID,layer = self}})
end
function DebaoZuanLayer:onExit()
	QManagerListener:Detach(eDebaoZuanLayerID)
	QManagerListener:Notify({tag = "showInputBox",layerID = ePrivateHallViewID})
end
function DebaoZuanLayer:updateCallBack(data)
	if data.tag == "showInputBox" then
		self.mInputBox:setVisible(true)
	end
end
function DebaoZuanLayer:initUI()
	
	local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/shop_dif/shopBg.png")
	self.mBg = cc.Sprite:create(tmpFilename)

	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	self.mBgWidth = bgWidth
	self.mBgHeight = bgHeight
	self.mBg:setPosition(bgWidth/2,bgHeight/2)
	self:addChild(self.mBg)

	local titleBg = cc.Sprite:create("picdata/shop/title_bg.png")
	titleBg:setPosition(150,bgHeight - 37)
	self.mBg:addChild(titleBg,1)

	local title = cc.Sprite:create("picdata/shop/title_dbz.png")
	title:setPosition(titleBg:getContentSize().width/2-22,titleBg:getPositionY()+12)
	self.mBg:addChild(title,1)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () 
		CMClose(self, nil, self.dispatchEvtClose) end)
	btnClose:setScale(0.7)
	btnClose:setPosition(bgWidth-35,bgHeight - 40)
	self.mBg:addChild(btnClose)

	local golden = cc.Sprite:create("picdata/public2/icon_dbz.png")
	golden:setScale(0.75)
	golden:setPosition(315,bgHeight - 40)
	self.mBg:addChild(golden)

	self.mGoldenNum = cc.ui.UILabel.new({
        UILabelType = 1,
        --text  = CMFormatNum(myInfo.data.totalChips),
        -- text  = StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2),
        text  = tonumber(myInfo.data.userDebaoDiamond or "0"),
        font  = "picdata/MainPage/w_dbz.fnt",
        x     = golden:getPositionX()+25,
        y     = golden:getPositionY()+2,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(self.mGoldenNum)

 --    local btnHZJL = CMButton.new({normal = "picdata/public2/btn_h50_blue.png",pressed = "picdata/public2/btn_h50_blue2.png"},function () 
	-- 	CMClose(self, nil, self.dispatchEvtClose) end,nil,{textPath = "picdata/shop/w_btn_hzjl.png"})
	-- btnHZJL:setPosition(605,bgHeight - 40)
	-- self.mBg:addChild(btnHZJL)

    self:createLeftList()
    -- self:createGiveList()
    -- self:createChargeList()
end

--[[
	创建左边列表
]]
function DebaoZuanLayer:createLeftList( )
	-- body
	self.mListSize = cc.size(245,self.mBg:getContentSize().height - 100)	
	self.mActivityList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(5, 0, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchListener))
    :addTo(self.mBg,1)    
  	
	for i = 1,#self.mAtivityName do 
		 
	   	-- local content     
	    -- content = cc.LayerColor:create(
	    --     cc.c4b(math.random(250),
	    --         math.random(250),
	    --         math.random(250),
	    --         250))
	    -- content:setContentSize(self.mListSize.width-20, 100)
	    -- content:setTouchEnabled(true)    
	    -- item:addChild(content) 
	  
		local item = self.mActivityList:newItem() 
		local btnActivity = cc.Sprite:create("picdata/shop/shop_btn_2.png")
	    :align(display.CENTER, 0,0) --设置位置 锚点位置和坐标x,y
	    item:addContent(btnActivity)   
	    	 
		local selecthSprite = cc.Sprite:create("picdata/shop/shop_btn_1.png")
		selecthSprite:setVisible(false)
		selecthSprite:setPosition(selecthSprite:getContentSize().width/2,selecthSprite:getContentSize().height/2)
		btnActivity:addChild(selecthSprite,0,101)

		local sDetail = cc.ui.UILabel.new({text = self.mAtivityName[i],size = 28,color = cc.c3b(188,201,229),font = GFZZC})	
		sDetail:setPosition(btnActivity:getContentSize().width/2-sDetail:getContentSize().width/2,btnActivity:getContentSize().height/2)
		btnActivity:addChild(sDetail,1,102)

		item:setItemSize(selecthSprite:getContentSize().width, selecthSprite:getContentSize().height+6)
	   	self.mActivityList:addItem(item)
		self.mActivitySprite[#self.mActivitySprite + 1] = btnActivity
	end	
	self.mActivityList:reload()	
end
function DebaoZuanLayer:touchListener(event)
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
function DebaoZuanLayer:checkTouchInSprite_(x, y,itemPos)	
	local isTouchList = false
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			isTouchList	= true	
			self.mSelectIndex = i
			self:onMenuSwitch(i)
		else
			self.mActivitySprite[i]:getChildByTag(102):disableEffect()
			self.mActivitySprite[i]:getChildByTag(102):setColor(cc.c3b(188,201,229))
			self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
		end
	end	
	if not isTouchList then
		local idx = self.mSelectIndex or 1
		self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(255,238,204))
		self.mActivitySprite[idx]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
		self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
	end
end
--[[
	创建右边列表
]]
function DebaoZuanLayer:createRightList(nType )
	local isExistData = QDataShopGoldList:isExistMsgData(nType)
	if nType == 101 then
		if self.mChargeList then 
			self.mChargeList:setVisible(false)
			self.mInputBox:setVisible(false)
		end
		if not isExistData then
			DBHttpRequest:getGoodsList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"GIFT")
		else
			self:createGiveList(nType )
		end
	elseif nType == 102 then
		if self.mChargeList then 
			self.mChargeList:setVisible(true)
			self.mInputBox:setVisible(true)
		else
    		self:createChargeList()
    	end
	end
end
function DebaoZuanLayer:createGiveList(nType)
	-- body
	self.mRightListSize = cc.size(self.mBg:getContentSize().width - 255,self.mBg:getContentSize().height - 90)	
	self.mRightList = cc.ui.UIListView.new {
    	-- bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(255, 0, self.mRightListSize.width, self.mRightListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --:onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
  	
  	local cfgData = QDataShopGoldList:getMsgData(nType)
  	-- local cfgData  = {{GOODS_GOODS_PIC = "",PAY_NUM = 0}}
  	if not cfgData then return end 
	for i = 1,#cfgData do 
		 
	   	-- local content     
	    -- content = cc.LayerColor:create(
	    --     cc.c4b(math.random(250),
	    --         math.random(250),
	    --         math.random(250),
	    --         250))
	    -- content:setContentSize(self.mListSize.width-20, 100)
	    -- content:setTouchEnabled(true)    
	 --    -- item:addChild(content) 
	    local picPath = "picdata/shop/localGoldImg.png" 
	    if cfgData[i][GOODS_GOODS_PIC] ~= "" then
		  	local isExist,newPath = NetCallBack:getCacheImage(cfgData[i][GOODS_GOODS_PIC])
		  	
	    	if isExist then
	    		picPath = newPath
	    	else
				NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..cfgData[i][GOODS_GOODS_PIC],nType,cfgData[i][GOODS_GOODS_PIC],i)
			end
		end
		local item = self.mActivityList:newItem() 

		local bg   = cc.Sprite:create(GDIFROOTRES .."picdata/shop_dif/shopCellBg.png")
		local bgwidth = bg:getContentSize().width
		local bgHeight= bg:getContentSize().height
		local itemSize = cc.size(bg:getContentSize().width, 120)
		bg:setPosition(0,0)
		item:addContent(bg)
		item:setItemSize(itemSize.width,itemSize.height)
		self.mRightList:addItem(item)

		if i ~= 1 then
			local head = cc.Sprite:create(GDIFROOTRES .."picdata/shop_dif/list_one_y.png")
			head:setPosition(itemSize.width/2,itemSize.height-15)
			bg:addChild(head)
		end

		local pic = cc.Sprite:create(picPath)
		pic:setPosition(80,itemSize.height/2)
		bg:addChild(pic)
		self.mRightPic[i] = pic 
		local sName =  cc.ui.UILabel.new({
	        color = cc.c3b(255, 238, 153),
	        text  = cfgData[i][GOODS_GOODS_NAME] or "",
	        size  = 24,
	        font  = "黑体",
	        x     = 160,
	        y     = itemSize.height/2 + 25,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	    })
    	bg:addChild(sName)
    	local size = cc.size(320, 0)
    	if GDIFROOTRES   == "scene1136/" then
    		size = cc.size(500, 0)
    	end
    	local sDetail = cc.ui.UILabel.new({
	        color = cc.c3b(188, 201, 229),
	        text  = cfgData[i][GOODS_DESC] or "",
	        size  = 20,
	        font  = "黑体",
	        x     = 160,
	        y     = itemSize.height/2 - 22,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        dimensions = size,
	    })
    	bg:addChild(sDetail)


    	local btnPath = "picdata/shop/btn_buy.png"
		local goldPath = "picdata/shop/rakepointIcon.png"
		local fntPath = "picdata/table/callLabel.fnt"
		local isEnable = true
    	-- if tonumber(myInfo.data.diamondBalance or 0) < (tonumber(cfgData[i][PAY_NUM] or 0)) then 
    	-- 	btnPath = "picdata/shop/btn_buy_no.png"
    	-- 	goldPath = "picdata/shop/icon_jf_gray.png"
    	-- 	fntPath = "picdata/shop/grayPrice.fnt"
    	-- 	isEnable = false
    	-- end
    	local btnExcharge = CMButton.new({normal = btnPath},function () self:onMenuCallBack(EnumMenu.eBtnGive,cfgData[i]) end,nil,{textPath = "picdata/shop/w_btn_zs.png"})
    	btnExcharge:setPosition(itemSize.width - 120,itemSize.height/2)
    	btnExcharge:setTouchSwallowEnabled(false)
    	btnExcharge:setButtonEnabled(isEnable)
    	bg:addChild(btnExcharge)

			
	end	

	self.mRightList:reload()	
end
--[[
	创建兑换列表
]]
function DebaoZuanLayer:createChargeList()
	local node = cc.Node:create()
	self.mChargeList = node
	self.mBg:addChild(node,1)

	local posx = 420
	if GDIFROOTRES   == "scene1136/" then
		posx = 495
	end
	local posy = self.mBgHeight-130
	local hbdh = cc.Sprite:create("picdata/shop/w_dhhb.png")
	hbdh:setPosition(posx,posy)
	node:addChild(hbdh)

	local sDetail = cc.ui.UILabel.new({
        -- color = cc.c3b(188, 201, 229),
        text  = "1德堡钻 ＝ 100金币",
        size  = 30,
        font  = "黑体",
        x     = posx - 60,
        y     = posy - 50,
        align = cc.ui.TEXT_ALIGN_LEFT,
        dimensions = size,
    })
	node:addChild(sDetail)

	local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        forePath  = "picdata/public2/icon_dbz.png",
        maxLength = 20,
        place     = "请以100为单位输入兑换的德堡钻",
        color     = cc.c3b(255,255,255),
        fontSize  = 26,
        bgPath    = "picdata/public2/bg_tc2.png" ,  
        foreAlign = CMInput.LEFT, 
        scale9    = true,
        size      = cc.size(526,62) , 
        inputMode = 2,   
        listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setPosition(posx - 60,posy - 160)
    node:addChild(inputBox )

	self.mInputBox = inputBox

	local sDetail = cc.ui.UILabel.new({
        -- color = cc.c3b(188, 201, 229),
        text  = "兑换成：",
        size  = 30,
        font  = "黑体",
        x     = posx - 60,
        y     = posy - 220,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
	node:addChild(sDetail)
	local gold = cc.Sprite:create("picdata/shop/goldIcon.png")
	gold:setPosition(posx+70,sDetail:getPositionY())
	node:addChild(gold)

	local sNum = cc.ui.UILabel.new({
        -- color = cc.c3b(188, 201, 229),
        UILabelType = 1,
        font  = "picdata/MainPage/goldNum.fnt",
        text  = "0",
        size  = 30,
        x     = posx + 95,
        y     = sDetail:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
	node:addChild(sNum)


	local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
			function () self:onMenuCallBack(EnumMenu.eBtnSure) end,{scale9 = true},{textPath = "picdata/public2/w_btn_qd.png"})
	btnOk:setButtonSize(534, 74)   
	btnOk:addTextPath()
	btnOk:setPosition(posx+200,posy - 340)
	node:addChild(btnOk)

	local sWarn = cc.ui.UILabel.new({
        color = cc.c3b(255, 90, 0),
        text  = "注意:金币不可以兑换德堡钻",
        size  = 24,
        font  = "黑体",
        x     = posx+60,
        y     = posy - 420,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
	node:addChild(sWarn)

	self.mRechargeNum = sNum
	-- self:showTips(true)
end
--[[
	显示输入结果提示
]]
function DebaoZuanLayer:showTips(isShow)
	if self.mTipNode then self.mTipNode:removeFromParent() self.mTipNode = nil end
	if not isShow then return end
	self.mTipNode = cc.Node:create()
	self.mTipNode:setPosition(170, 235)
	self.mChargeList:addChild(self.mTipNode)

	local text = "请输入100的整数倍"
	local sTip = cc.ui.UILabel.new({text = text,
		color = cc.c3b(255,90,0),
		size = 24,
		textAlign = cc.TEXT_ALIGNMENT_LEFT,})	
	sTip:setPosition(self.mBgWidth/2-sTip:getContentSize().width/2,0)
	self.mTipNode:addChild(sTip,0)

	local tipSp = cc.Sprite:create("picdata/fightteam/icon_warning.png")
	tipSp:setPosition(sTip:getPositionX()-30, 0)
	self.mTipNode:addChild(tipSp)
end
--[[
	界面切换
]]
function DebaoZuanLayer:onMenuSwitch(idx)
	self.mActivitySprite[idx]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
	self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(255,238,204))
	self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
	
	if self.mLastType == self.mType[idx] then return end
	if self.mRightList then self.mRightList:removeFromParent() self.mRightList = nil end
	self:createRightList(self.mType[idx] )
end
function DebaoZuanLayer:onEdit(event,editbox,isOverMaxLength)
	if event == "began" then
    -- 开始输入
    	editbox:setFontSize(30)
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
    elseif event == "ended" then
    	local text = tonumber(self.mInputBox:getText())
    	if not text or text%100 ~= 0 then
    		self:showTips(true)
    		return
    	else
    		self.mRechargeNum:setString(100*text)
    		self:showTips(false)
    	end
        --print("输入结束")        
    elseif event == "return" then    

    end
end
--[[

]]
function DebaoZuanLayer:onMenuCallBack(tag,data)
	-- dump(self.mParams.userPos,clubPositon[self.mSelectType])
	if tag == EnumMenu.eBtnSure then
		local text = tonumber(self.mInputBox:getText())
    	if not text or text%100 ~= 0 then
    		return 
    	else
    		if  tonumber(myInfo.data.userDebaoDiamond or 0)  < text then
	    		self.mInputBox:setVisible(false)
				local text = "您的德堡钻余额不足以购买100邀请卡，前往商城轻松买钻吧"
				local GameLayerManager  = require("app.GUI.GameLayerManager")
				local RewardLayer = require("app.Component.CMAlertDialog") 
				CMOpen(RewardLayer, self,{text = text,showType = 2,okText = "买钻",titleText = "德堡钻不足",showBox = false,
					callOk = function (isSelect) GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self,{nType = 3}) end,
					callCancle = function(isSelect) self.mInputBox:setVisible(true) end
				})
	    	else
	    		DBHttpRequest:exchangePoint(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,text)
	    	end
    	end
    elseif tag == EnumMenu.eBtnGive then
    	local RewardLayer      = require("app.GUI.recharge.DebaoZuanGiveLayer")
    	CMOpen(RewardLayer, self,data)
	end
end
--[[
	网络回调
]]
function DebaoZuanLayer:httpResponse(tableData,tag,nType)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GETGOODSLIST then 			    --请求道具列表
		QDataShopGoldList:Init(tableData,nType)
    	self:onMenuSwitch(1)
    elseif tag == POST_COMMAND_GET_exchangePoint then
    	if tableData and tableData["CODE"] and tableData["CODE"] == 1 then
    		local userDebaoDiamond = tableData["INFO"]["502B"] or 0
    		local addGoldNum 	   = tableData["INFO"]["5016"] or 0
    		local allGoldNum 	   = tableData["INFO"]["5008"]	
    		myInfo.data.totalChips 		 = allGoldNum
        	myInfo.data.userDebaoDiamond = userDebaoDiamond

       	 	QManagerListener:Notify({layerID = eToolBarToopID})
       	 	self.mGoldenNum:setString(userDebaoDiamond)
       	 	CMShowTip(string.format("兑换成功,增加金币%s金币",addGoldNum))	
    	else
    		CMShowTip("兑换失败,请重试")
    	end
	end
end

----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function DebaoZuanLayer:onHttpDownloadResponse(tag,progress,fileName)
	if self.mRightPic[progress] then
		local parent = self.mRightPic[progress]:getParent()
		local posx   = self.mRightPic[progress]:getPositionX()
		local posy   = self.mRightPic[progress]:getPositionY()
		self.mRightPic[progress]:removeFromParent()
		self.mRightPic[progress] = cc.Sprite:create(fileName)
		self.mRightPic[progress]:setPosition(posx,posy)
		parent:addChild(self.mRightPic[progress])
	end	
end
return DebaoZuanLayer