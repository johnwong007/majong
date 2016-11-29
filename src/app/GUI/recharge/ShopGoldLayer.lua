--
-- Author: junjie
-- Date: 2015-11-27 11:43:44
--

--商城界面
local MusicPlayer = require("app.Tools.MusicPlayer")
local ShopGoldLayer = class("ShopGoldLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
require("app.Network.Http.DBHttpRequest")
require("app.Tools.StringFormat")
local QDataShopGoldList = nil
local NetCallBack = require("app.Network.Http.NetCallBack")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Logic.Config.UserDefaultSetting")
require("app.Logic.UserConfig")

local UNIPAYCODE_THIRD_PARTY={"906140634220140722153848862500018",
	"906140634220140722153848862500011", "906140634220140722153848862500013",
	"906140634220140722153848862500016", "906140634220140722153848862500017",
	"906140634220140722153848862500012", "906140634220140722153848862500014",
	"906140634220140722153848862500015", "906140634220140722153848862500019"};
local UNIPAYCODE = {"140722046416", "140722046404", "140722046405",
	"140722046406", "140722046407", "140722046417", "140722046418", "140722046419", "140722046420"};
local UNIPAYPRICE = {2, 5, 10, 20, 30, 50, 100, 200, 1000};
local sPayType = nil
function ShopGoldLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
	QDataShopGoldList = QManagerData:getCacheData("QDataShopGoldList")
	self.mAtivityName = {
		"金币","月卡","道具","德堡钻",
	}
	self.mType = {1,2,3,4}			--活动所有类型
	self.mLastType = nil 									--最近一次选择的类型
	self.mActivitySprite = {} 								--左边图片
	self.mRightPic       = {} 								--右边需要刷新的图片
	self.mSortType       = self.params.sortType
	self.mJumpType 		 = self.params.nType or 1 
	sPayType 			 = "GOLD"
end
function ShopGoldLayer:create()
	self:initUI()
	self:onMenuSwitch(self.mJumpType)
end
function ShopGoldLayer:onEnter()
	self.m_bSoundEnabled = true
	QManagerPlatform:onEvent({where = QManagerPlatform.EOnEventWhere.eOnEventShopRecharge , nType = QManagerPlatform.EOnEventActionType.eOnEventActionOpenShop})
end
function ShopGoldLayer:onExit()
	QManagerListener:Notify({tag = "showInputBox",layerID = eFTCreateTeamLayerID})
	QManagerListener:Notify({tag = "showInputBox",layerID = ePrivateHallViewID})
	QManagerListener:Notify({tag = "showInputBox",layerID = eDebaoZuanLayerID})
end
--[[
	UI创建
]]
function ShopGoldLayer:initUI()
	self.m_bSoundEnabled = false
	DBHttpRequest:getUserVipInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)
	
		    local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/shop_dif/shopBg.png")
	self.mBg = cc.Sprite:create(tmpFilename)

	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	self.mBg:setPosition(bgWidth/2,bgHeight/2)
	self:addChild(self.mBg)

	local titleBg = cc.Sprite:create("picdata/shop/title_bg.png")
	titleBg:setPosition(150,bgHeight - 37)
	self.mBg:addChild(titleBg,1)

	local title = cc.Sprite:create("picdata/shop/title_shangcheng.png")
	title:setPosition(titleBg:getContentSize().width/2-22,titleBg:getPositionY()+12)
	self.mBg:addChild(title,1)

	local vipBg = cc.Sprite:create(GDIFROOTRES .."picdata/shop_dif/goldShopHeadder.png")
	vipBg:setPosition(bgWidth - vipBg:getContentSize().width/2,bgHeight-vipBg:getContentSize().height/2)
	self.mBg:addChild(vipBg)
	self.mVipBg = vipBg
	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () 
		CMClose(self, nil, self.dispatchEvtClose) end)
	btnClose:setScale(0.7)
	btnClose:setPosition(bgWidth-35,bgHeight - 40)
	self.mBg:addChild(btnClose)

	local golden = cc.Sprite:create("picdata/shop/goldIcon.png")
	golden:setPosition(315,bgHeight - 40)
	self.mBg:addChild(golden)

	self.mGoldenNum = cc.ui.UILabel.new({
        UILabelType = 1,
        --text  = CMFormatNum(myInfo.data.totalChips),
        text  = StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2),
        font  = "picdata/MainPage/goldNum.fnt",
        x     = golden:getPositionX()+25,
        y     = golden:getPositionY()+2,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(self.mGoldenNum)

    self:createLeftList()

end
--[[
	vip信息节点创建
]]
function ShopGoldLayer:initVipNode(data)
	data = data or {}
	local curVipLevel = tonumber(data[USER_LEVEL] or 0)
	local curVipExp   = tonumber(data[VIP_RANK]  or 0)
	local nextVipExp  = tonumber(data[NEXT_VIP_RANK] or 100)
	myInfo.data.vipLevel = curVipLevel
	--  local vipBg = cc.Sprite:create(GDIFROOTRES .."picdata/shop_dif/goldShopHeadder.png")
	local vipBg = self.mVipBg
	 local bgWidth = vipBg:getContentSize().width
	 local bgHeight= vipBg:getContentSize().height - 10
	-- vipBg:setPosition(620,512)
	--self.mBg:addChild(vipBg)


	local vipNum = cc.Sprite:create(string.format("picdata/shop/vip%d.png",curVipLevel))
	vipNum:setPosition(80,bgHeight/2 - 42)
	vipBg:addChild(vipNum)

	 local prebg = display.newSprite("picdata/public/vip_jdt_bg.png")
    prebg:setPosition(210,vipNum:getPositionY())
    vipBg:addChild(prebg)

    local pro = cc.Sprite:create("picdata/shop/vip_jdt.png")
    local progress = cc.ProgressTimer:create(pro)   
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)    
    progress:setBarChangeRate(cc.p(1, 0))      
    progress:setMidpoint(cc.p(0,1)) 
    progress:setPercentage(curVipExp/nextVipExp * 100)      
    progress:setPosition(prebg:getPositionX(),prebg:getPositionY())     
    vipBg:addChild(progress)

	local proNum = cc.ui.UILabel.new({
        text  = string.format("%s/%d",curVipExp,nextVipExp),
        font  = GArail,
        size  = 18,
        x     = prebg:getPositionX(),
        y     = prebg:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    proNum:setPosition(prebg:getPositionX()-proNum:getContentSize().width/2,prebg:getPositionY())  
    vipBg:addChild(proNum)

    local str = string.format("再充值%d元可达到vip%d",nextVipExp-curVipExp,curVipLevel+1)
    if curVipLevel >= 10 then 
    	str = "您已经是尊贵的VIP10用户了"
    end
    local goldenNum = cc.ui.UILabel.new({
        text  = str,
        font  = "黑体",
        size  = 18,
        color = cc.c3b(228,213,180),
        x     = 320,
        y     = vipNum:getPositionY(),
        align = cc.ui.TEXT_ALIGN_LEFT,
    })

    vipBg:addChild(goldenNum)

    local btnCheck = CMButton.new({normal = "picdata/shop/btn_showvip.png"},function () self:onMenuChangePage() end)
	btnCheck:setPosition(bgWidth-90,vipNum:getPositionY())
	vipBg:addChild(btnCheck)
	self.mBtnCheck = btnCheck
end
--[[
	创建左边列表
]]
function ShopGoldLayer:createLeftList( )
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
	  	-- if i ~= 3 then
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
		-- end
	end	
	self.mActivityList:reload()	
end
function ShopGoldLayer:touchListener(event)
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
function ShopGoldLayer:checkTouchInSprite_(x, y,itemPos)	
	local isTouchList = false
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			isTouchList	= true	
			self.mSelectIndex = i
			self:onMenuSwitch(i)
            if self.m_bSoundEnabled then
                MusicPlayer:getInstance():playButtonSound()
            end
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
function ShopGoldLayer:createRightList(nType )
	local isExistData = QDataShopGoldList:isExistMsgData(nType)
	if nType == 1 then
		sPayType = "GOLD"
		if not isExistData then
			if DBChannel == "20210" then
				
				DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"APPLE",sPayType)
			else
				DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end)
				
			end
		else
			self:createGoldList(nType)
		end
	elseif nType == 2 then
		if not isExistData then
			DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"UNWO","CARD")
		else
			self:createGoldList(nType )
		end

	elseif nType == 3 then
		if not isExistData then
			DBHttpRequest:getGoodsList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"FUNCTION")
		else
			self:createPropList(nType )
		end
	elseif nType == 4 then
		sPayType = "POINT"
		if not isExistData then
			DBHttpRequest:getItemList(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,"UNWO",sPayType)
		else
			self:createGoldList(nType )
		end
	end
end
--[[
	金币、月卡、德堡钻列表
]]
function ShopGoldLayer:createGoldList(nType )
	
	self.mLastType = nType
	-- body
	self.mRightListSize = cc.size(self.mBg:getContentSize().width - 255,self.mBg:getContentSize().height - 165)	
	self.mRightList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(255, 0, self.mRightListSize.width, self.mRightListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --:onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
  	
  	local cfgData = QDataShopGoldList:getMsgData(nType)
  	self.mCfgData = cfgData
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
	    -- item:addChild(content) 
	    local picPath = ""
	    
	    if nType == 1 then
	    	picPath = string.format("picdata/db_gold/jb%d.png",cfgData[i][BUYCOINLIST_COIN]) 
	    elseif nType == 4 then
	    	picPath = "picdata/shop/dbz.png"
	    else
	    	picPath = string.format("picdata/db_gold/card%d.png",i) 
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
			head:setPosition(itemSize.width/2,itemSize.height - 16)
			bg:addChild(head)
		end

		local pic = cc.Sprite:create(picPath)
		if pic == nil then
			pic = cc.Sprite:create("picdata/db_gold/jb18.png")
		end
		pic:setPosition(90,itemSize.height/2+5)
		bg:addChild(pic)
		self.mRightPic[i] = pic 
		if nType == 1 then
			local sName =  cc.ui.UILabel.new({
		        text  = CMFormatNum(cfgData[i][MONEY_BALANCE]) .. "金币",
		        size  = 24,
		        x     = 170,
		        y     = itemSize.height/2 + 20,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        font  = "picdata/MainPage/goldNum.fnt",
		        UILabelType = 1,
		    })
	    	bg:addChild(sName)
	    else
	    	local sName =  cc.ui.UILabel.new({
		        color = cc.c3b(255, 219, 154),
		        text  = cfgData[i][ZBF_GOODS_ITEM_NAME] or "",
		        size  = 24,
		        font  = "FZZCHJW--GB1-0",
		        x     = 170,
		        y     = itemSize.height/2 + 25,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		    })
	    	bg:addChild(sName)
	    	local size = cc.size(320, 0)
	    	if GDIFROOTRES   == "scene1136/" then
	    		size = cc.size(500, 0)
	    	end
	    	local sDetail = cc.ui.UILabel.new({
		        color = cc.c3b(164, 195, 255),
		        text  = cfgData[i][GOODS_DESC] or "",
		        size  = 18,
		        font  = "黑体",
		        x     = 170,
		        y     = itemSize.height/2 - 22,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        dimensions = size,
		    })
	    	bg:addChild(sDetail)
	    end

    	local vipLevel = tonumber(myInfo.data.vipLevel) or 0
    	local needVip = 0
    	local descStr  = ""

    	if nType == 1 and (vipLevel >= 5 and vipLevel <= 10) then
    		local num = CMFormatNum(tonumber(cfgData[i][MONEY_BALANCE]) * tonumber(vipLevel)/100)
    		descStr = string.format("(VIP%d加赠%s金币)",vipLevel,num)
    		local sDesc =  cc.ui.UILabel.new({
	        text  = descStr,
	        x     = 170,
	        size  = 18,
	        y     = itemSize.height/2 - 15 ,
	        color = cc.c3b(164, 195, 255),
	        align = cc.ui.TEXT_ALIGN_LEFT,
	       
	    })
    	bg:addChild(sDesc)
    	elseif nType == 2 then
    		needVip = i + 1
    		local num = CMFormatNum(tonumber(cfgData[i][MONEY_BALANCE]) * tonumber(vipLevel)/100)
    		descStr = string.format("(VIP%d以上可以购买)",needVip)
    		local sDesc =  cc.ui.UILabel.new({
	        text  = descStr,
	        size  = 18,
	        x     = 270,
	        y     = itemSize.height/2 + 25 ,
	        color = cc.c3b(164, 195, 255),
	        align = cc.ui.TEXT_ALIGN_LEFT,
	       
	    })
    	bg:addChild(sDesc)
    	end
    	local btnPath = "picdata/shop/btn_buy.png"
		local goldPath = "picdata/shop/rakepointIcon.png"
		local fntPath = "picdata/table/callLabel.fnt"
		local isEnable = true
    	--if tonumber(myInfo.data.diamondBalance) < (tonumber(cfgData[i][PAY_NUM])) then 
    	local isLowerVip = false
    	if nType == 2 and vipLevel < needVip then
    		-- btnPath = "picdata/shop/btn_buy_no.png"
    		-- goldPath = "picdata/shop/icon_jf_gray.png"
    		-- fntPath = "picdata/shop/grayPrice.fnt"
    		-- isEnable = false
    		isLowerVip = needVip
    	end
    	dump("================> ")
    	dump(vipLevel)
    	dump(needVip)
    	dump(isLowerVip)

    	local btnExcharge = CMButton.new({normal = btnPath},function () self:onMenuOpenChannelLayer(cfgData[i],nType,isLowerVip) end,{scale9 = false},{scale = false})
    	btnExcharge:setPosition(itemSize.width - 110,itemSize.height/2)
    	btnExcharge:setButtonEnabled(isEnable)
    	btnExcharge:setTouchSwallowEnabled(false)
    	bg:addChild(btnExcharge)

    	local gold = cc.Sprite:create(goldPath)
    	gold:setPosition(-btnExcharge:getButtonSize().width/2 + 25,3)
    	--btnExcharge:addChild(gold)
	    
    	local sNeedGold = cc.ui.UILabel.new({
	        text  = CMFormatNum(cfgData[i][BUYCOINLIST_COIN] or 0).."元",
	        UILabelType = 1,
	        font  = fntPath,
	        --x     = btnExcharge:getButtonSize().width/2,
	        --y     = 0,
	        --align = cc.ui.TEXT_ALIGNMENT_CENTER,
	    })
	    sNeedGold:setPosition( - sNeedGold:getContentSize().width/2,5)
    	btnExcharge:addChild(sNeedGold)

			
	end	

	self.mRightList:reload()	
end
--[[
	道具列表
]]
function ShopGoldLayer:createPropList(nType )
	
	self.mLastType = nType
	-- body
	self.mRightListSize = cc.size(self.mBg:getContentSize().width - 255,self.mBg:getContentSize().height - 165)	
	self.mRightList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(255, 0, self.mRightListSize.width, self.mRightListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --:onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
  	
  	local cfgData = QDataShopGoldList:getMsgData(nType,self.mSortType)
  	self.mCfgData = cfgData
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
	    -- item:addChild(content) 
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
			head:setPosition(itemSize.width/2,itemSize.height-16)
			bg:addChild(head)
		end

		local pic = cc.Sprite:create(picPath)
		pic:setPosition(90,itemSize.height/2+5)
		bg:addChild(pic)
		self.mRightPic[i] = pic 
		local sName =  cc.ui.UILabel.new({
	        color = cc.c3b(60, 207, 255),
	        text  = cfgData[i][GOODS_GOODS_NAME] or "",
	        size  = 24,
	        font  = "FZZCHJW--GB1-0",
	        x     = 170,
	        y     = itemSize.height/2 + 20,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	    })
    	bg:addChild(sName)

    	local sDetail = cc.ui.UILabel.new({
	        color = cc.c3b(164, 195, 255),
	        text  = cfgData[i][GOODS_DESC] or "",
	        size  = 18,
	        font  = "黑体",
	        x     = 170,
	        y     = itemSize.height/2 - 25,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        dimensions = cc.size(340, 50),
	    })
    	bg:addChild(sDetail)


    	local btnPath = "picdata/shop/btn_buy.png"
		local goldPath = "picdata/shop/goldIcon.png"
		local fntPath = "picdata/table/callLabel.fnt"
		local isEnable = true
    	if tonumber(myInfo.data.totalChips) < (tonumber(cfgData[i][PAY_NUM])) or tonumber(myInfo.data.vipLevel or 0) < (tonumber(cfgData[i][P_VIP_LEVEL] or 0)) then 
    		btnPath = "picdata/shop/btn_buy_no.png"
    		goldPath = "picdata/shop/icon_jb_gray.png"
    		fntPath = "picdata/shop/grayPrice.fnt"
    		isEnable = false
    	end
    	local btnExcharge = CMButton.new({normal = btnPath},function () self:onMenuExcharge(cfgData[i]) end,{scale9 = false},{scale = false})
    	btnExcharge:setPosition(itemSize.width - 110,itemSize.height/2)
    	btnExcharge:setTouchSwallowEnabled(false)
    	btnExcharge:setButtonEnabled(isEnable)
    	bg:addChild(btnExcharge)

    	local gold = cc.Sprite:create(goldPath)
    	gold:setPosition(-btnExcharge:getButtonSize().width/2 + 30,0)
    	btnExcharge:addChild(gold)
	    
    	local sNeedGold = cc.ui.UILabel.new({
	        text  = CMFormatNum(cfgData[i][PAY_NUM]),
	        UILabelType = 1,
	        font  = fntPath,
	        size  = 26,
	        align = cc.ui.TEXT_ALIGNMENT_CENTER,
	    })
	    sNeedGold:setPosition(10-sNeedGold:getContentSize().width/2,3)
    	btnExcharge:addChild(sNeedGold)

    	if tonumber(cfgData[i][P_VIP_LEVEL]) > 0 then

    	end
			
	end	

	self.mRightList:reload()	
end
function ShopGoldLayer:touchRightListener(event)

end

--[[
	界面切换
]]
function ShopGoldLayer:onMenuSwitch(idx)
	-- 这里使用shadow会导致部分手机闪屏
	-- self.mActivitySprite[idx]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
	self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(255,238,204))
	self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
	if self.mLastType == self.mType[idx] then return end

	if self.mRightList then self.mRightList:removeFromParent() self.mRightList = nil end
	self:createRightList(self.mType[idx] )
	if self.mBtnCheck then
		if idx == 1 then 
			sPayType = "GOLD" 
			self.mBtnCheck:setTexture("picdata/shop/btn_showvip.png")
		elseif idx == 2 then
			-- self.mLastType = idx
			self.mBtnCheck:setTexture("picdata/shop/btn_showvip.png")
		elseif idx == 3 then
			self.mBtnCheck:setTexture("picdata/public/btn_cz.png")
		elseif idx == 4 then
			-- self.mLastType = idx
			sPayType = "POINT" 
			self.mBtnCheck:setTexture("picdata/shop/btn_showvip.png")
		end
	end
end

--[[
	兑换
]]
function ShopGoldLayer:onMenuExcharge(params)
	local ShopExchargeLayer = require("app.GUI.recharge.ShopExchargeLayer").new(params)
    ShopExchargeLayer:setPosition(self.mBg:getContentSize().width/2+93,self.mBg:getContentSize().height/2)
    CMOpen(ShopExchargeLayer, self,self.mBg:getContentSize().width/2,0)
end
--[[
	充值、特权切换
]]
function ShopGoldLayer:onMenuChangePage()

	if self.mLastType == 1 or self.mLastType == 2 or self.mLastType == 4 then
		--self.mBtnCheck:setTexture("picdata/shop/btn_showvip.png")
		local parent = self:getParent()
		local MoreVersionLayer = require("app.GUI.setting.MoreVersionLayer")
		CMOpen(MoreVersionLayer, parent)
		CMClose(self, nil, self.dispatchEvtClose)
	elseif self.mLastType == 3 then
		self.mActivitySprite[3]:getChildByTag(101):setVisible(false)
		self.mBtnCheck:setTexture("picdata/public/btn_cz.png")
		self:onMenuSwitch(1)

	end
end
--[[
	支付界面
]]
function ShopGoldLayer:onMenuOpenChannelLayer(params,nType,isLowerVip)
	-- if true then 
	-- 	QManagerPlatform:showPayView({},function () dump("callback") end)
	-- 	return 
	-- end
	-- print( QManagerPlatform.EOnEventWhere.eOnEventShopRecharge ,  QManagerPlatform.EOnEventActionType.eOnEventActionClickItem)
	QManagerPlatform:onEvent({where = QManagerPlatform.EOnEventWhere.eOnEventShopRecharge , nType = QManagerPlatform.EOnEventActionType.eOnEventActionClickItem})
	if params and params.sPayType then
		sPayType = params.sPayType 
	end
	if DBChannel == "20210" then
		if nType == 2 and isLowerVip then
			local RewardLayer = require("app.Component.CMAlertDialog")
			CMOpen(RewardLayer, self,{text = string.format("亲爱的玩家，你的vip等级不足哟，需要VIP%d以上才可享受该优惠月卡哦！",isLowerVip),
				showType = 1,
				okText = "立即提升VIP",
				callOk = function () 
				local idx = 2
				self.mActivitySprite[idx]:getChildByTag(102):disableEffect()
				self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(188,201,229))
				self.mActivitySprite[idx]:getChildByTag(101):setVisible(false)
				self:onMenuSwitch(1) 
				end},1)
			return
		end
		local sChannel = "APPLE"
		local encryStr = CMMD5Charge(myInfo.data.userId..sPayType.."DEBAO"..sChannel..sChannel..params[BUYCOINLIST_ID])
		DBHttpRequest:createChargingOrder(function(tableData,tag) self:rechargeResponse(tableData,tag) end,myInfo.data.userId,sPayType,"DEBAO",sChannel,sChannel,params[BUYCOINLIST_ID],encryStr)
	elseif DBChannel == "10866" then
		local sChannel = "ANQU"
		local encryStr = CMMD5Charge(myInfo.data.userId..sPayType.."DEBAO"..sChannel..sChannel..params[BUYCOINLIST_ID])
		DBHttpRequest:createChargingOrder(function(tableData,tag) self:rechargeResponse(tableData,tag) end,myInfo.data.userId,sPayType,"DEBAO",sChannel,sChannel,params[BUYCOINLIST_ID],encryStr)
	else
		local sChannel       = nil
		if DBChannel == "10116" then
			sChannel = "TENCENT"
		elseif DBChannel == "10837" then
			sChannel = "UNWO"
		elseif DBChannel == "10859" then
			sChannel = "UPAY"
		elseif DBChannel == "10860" then
			sChannel = "NDUO"
		elseif myInfo.data.loginType > 3 then
			 sChannel = MyInfo.data.platform --GAllChannel[myInfo.data.loginType]
		end
		if nType == 2 and isLowerVip then
			local RewardLayer = require("app.Component.CMAlertDialog")
			CMOpen(RewardLayer, self,{text = string.format("亲爱的玩家，你的vip等级不足哟，需要VIP%d以上才可享受该优惠月卡哦！",isLowerVip),
				showType = 1,
				okText = "立即提升VIP",
				callOk = function () 
				local idx = 2
				self.mActivitySprite[idx]:getChildByTag(102):disableEffect()
				self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(188,201,229))
				self.mActivitySprite[idx]:getChildByTag(101):setVisible(false)
				self:onMenuSwitch(1) 
				end},1)
			return
		end
		if sChannel then 
			local encryStr = CMMD5Charge(myInfo.data.userId..sPayType.."DEBAO"..sChannel..sChannel..params[BUYCOINLIST_ID])
			DBHttpRequest:createChargingOrder(function(tableData,tag) self:rechargeResponse(tableData,tag) end,myInfo.data.userId,sPayType,"DEBAO",sChannel,sChannel,params[BUYCOINLIST_ID],encryStr)
		else			
			params.nType = nType
			params.sPayType = sPayType
			-- dump(sPayType)
			local ShopChannelLayer = require("app.GUI.recharge.ShopChannelLayer").new(params)
	   		ShopChannelLayer:setPosition(CONFIG_SCREEN_WIDTH/2,CONFIG_SCREEN_HEIGHT/2)
	    	CMOpen(ShopChannelLayer, self,CONFIG_SCREEN_WIDTH/2,0)
		end
	end
end
--[[
	苹果支付回调
]]
function ShopGoldLayer:ApplePaySuccessCallback(resultData)
	UserDefaultSetting:getInstance():setApplePayData(myInfo.data.userId,myInfo.data.userName,resultData.encodeJson,resultData.orderId,resultData.transactionIdentifier)
	DBHttpRequest:ApplePaySuccessCallback(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,myInfo.data.userName,resultData.encodeJson,resultData.orderId,resultData.transactionIdentifier)
end

function ShopGoldLayer:dealApplePayNotifyServerResp(tableData)
	local tips = ""
	if tableData == 1 then
		self:getParent():refreshInfo()
		local orderId    = cc.UserDefault:getInstance():getStringForKey(s_applePayOrderId)
		QManagerPlatform:onChargeSuccess(orderId)
		UserDefaultSetting:getInstance():setApplePayData()
		tips = "购买成功，您可以到支付记录里查看本次购买记录"
	elseif tableData == -3 then
		local data = UserDefaultSetting:getInstance():getApplePayData()
		if data and data.times < 3 then
			DBHttpRequest:ApplePaySuccessCallback(function(tableData,tag) self:httpResponse(tableData,tag) end,data.userId,data.userName,data.encodeJson,data.orderId,data.transactionIdentifier)
			cc.UserDefault:getInstance():setIntegerForKey(s_applePayTimes,data.times + 1)
		end
		tips = "对不起，购买过程发生错误，将重新请求发货，请稍候"
	else
	    tips = "对不起，购买过程发生错误，请联系客服人员"                    	
	end 
	local AlertDialog = require("app.Component.CMAlertDialog").new({text = tips})
	CMOpen(AlertDialog,self)
end

---
-- 安趣支付通知php回调
--
-- @param tableData [description]
-- @return [description]
--
function ShopGoldLayer:dealAnQuPayNotifyServerResp(tableData)
	dump(tableData, "安趣支付通知php回调结果！！！")
	local tips = ""
	if tableData == 1 then
		self:getParent():refreshInfo()
		local orderId = cc.UserDefault:getInstance():getStringForKey(s_anquPayPcorder)
		QManagerPlatform:onChargeSuccess(orderId)
		UserDefaultSetting:getInstance():setAnQuApplePayData()
		tips = "购买成功，您可以到支付记录里查看本次购买记录"
	elseif tableData == -3 then
		local data = UserDefaultSetting:getInstance():getAnQuApplePayData()
		if data and data.times < 3 then
			DBHttpRequest:anquPaySuccessCallback(
					function(tableData,tag) self:httpResponse(tableData,tag) end,
					data.uid,
					data.cporder,
					data.money,
					data.order)
			cc.UserDefault:getInstance():setIntegerForKey(s_anquPayTimes,data.times + 1)
		else
			UserDefaultSetting:getInstance():setAnQuApplePayData()
		end
		tips = "对不起，购买过程发生错误，将重新请求发货，请稍候"
	else
	    tips = "对不起，购买过程发生错误，请联系客服人员"                    	
	end 
	local AlertDialog = require("app.Component.CMAlertDialog").new({text = tips})
	CMOpen(AlertDialog,self)
end

--[[
	更新金币
]]
function ShopGoldLayer:updateData()
	CMDelay(self.mGoldenNum,1,function () 
		if self.mGoldenNum then self.mGoldenNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2)) end
		end )
end
--[[
	网络回调
]]
function ShopGoldLayer:httpResponse(tableData,tag,nType)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_getUserVipInfo then  				--请求vip信息	
		self:initVipNode(tableData)
	elseif tag == POST_COMMAND_GETITEMLIST then 				--请求充值列表
		QDataShopGoldList:Init(tableData,nType)
		self.mLastType = nil
		self:onMenuSwitch(nType)
	elseif tag == POST_COMMAND_GETGOODSLIST then 			    --请求道具列表
		QDataShopGoldList:Init(tableData,nType)
    	self:onMenuSwitch(nType)
    elseif tag == POST_COMMAND_APPPAYNOTIFYSERVER then        
    	self:dealApplePayNotifyServerResp(tableData)  
    elseif tag == POST_COMMAND_ANQUPAYNOTIFYSERVER then
    	self:dealAnQuPayNotifyServerResp(tableData)
    elseif tag == POST_COMMAND_GETACCOUNTINFO then
    	-- dump(tableData)
    	myInfo.data.totalChips = tableData["5029"] + 0 
    	self.mGoldenNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2))
	end
end

function ShopGoldLayer:refreshMoney(orderId)
	-- dump(orderId)
	-- body
	DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(orderId) self:rechargeResponse(data) end)
end
-- 支付回调(因为特殊处理太多跟网络回调分开)
function ShopGoldLayer:rechargeResponse(tableData,tag,nType)
    dump(tableData,tag)
    
	if not tag or type(tableData) ~= "table" then return end
	if tableData.code ~= 1 and tag ~= POST_COMMAND_GETACCOUNTINFO and tag ~= POST_COMMAND_QUERY_TENCENT_GAMECOIN then
		local AlertDialog = require("app.Component.CMAlertDialog").new({text = json.encode(tableData),scroll = true})
		CMOpen(AlertDialog,self:getParent())
		return
	end

	if tag == POST_COMMAND_getUserVipInfo then  				--请求vip信息	
		self:initVipNode(tableData)
	elseif tag == POST_COMMAND_GETITEMLIST then 				--请求充值列表
		nType = nType or 1
		QDataShopGoldList:Init(tableData,nType)
		self.mLastType = nil
		self:onMenuSwitch(nType)
	elseif tag == POST_COMMAND_GETGOODSLIST then 			    --请求道具列表
		QDataShopGoldList:Init(tableData,3)
    	self:onMenuSwitch(3)
    elseif tag == POST_COMMAND_APPLE_CHARGINGORDER then
    	self.CMMaskLayer = CMMask.new()
		self:addChild(self.CMMaskLayer,1)
    	QManagerPlatform:openUpompPay_JNI(tableData.data.orderId,tableData.data.goodsid,"",
    		function (resultData) 
 				if self.CMMaskLayer then self.CMMaskLayer:removeFromParent() self.CMMaskLayer = nil end
    			if not resultData.isSuccessed then 
    				local AlertDialog = require("app.Component.CMAlertDialog").new({text = "对不起，购买过程发生错误，请稍候重试！"})
					CMOpen(AlertDialog,self)
    			return end
    			self:ApplePaySuccessCallback(resultData)
    		end)
    elseif tag == POST_COMMAND_ANQU_CHARGINGORDER then --安趣支付，获取订单回调
    	dump(tableData, "iccccccccccccc POST_COMMAND_ANQU_CHARGINGORDER")
    	local params = {}
    	params.money = tableData.data.price
    	params.subject = tableData.data.goodName
    	params.body = tableData.data.goodDesc
    	params.outOrderid = tableData.data.orderId
    	params.productid = "com.debao.texaspoker.gold." ..tableData.data.price
    	params.mPext = ""
    	params.rolename = myInfo.data.userName
    	QManagerPlatform:anquPay(params,
    		function (resultData) 
 				if self.CMMaskLayer then self.CMMaskLayer:removeFromParent() self.CMMaskLayer = nil end
 				print(resultData.anquOrderid, resultData.payname, "iccccccccccccc POST_COMMAND_ANQU_CHARGINGORDER 支付验证成功！！！！")
 			-- 	UserDefaultSetting:getInstance():setAnQuApplePayData(myInfo.data.anquUid,tableData.data.orderId,resultData.anquOrderid,resultData.orderId,tableData.data.price)
				-- DBHttpRequest:anquPaySuccessCallback(
				-- 	function(tableData,tag) self:httpResponse(tableData,tag) end,
				-- 	myInfo.data.anquUid,
				-- 	tableData.data.orderId,
				-- 	tableData.data.price,
				-- 	resultData.anquOrderid)
				local params = {
					encodeJson = resultData.applepayResponse,
					orderId = tableData.data.orderId,
					transactionIdentifier = resultData.applepayTransid,
				}
				self:ApplePaySuccessCallback(params)
    		end)
    elseif tag == POST_COMMAND_APPPAYNOTIFYSERVER then        
    	self:dealApplePayNotifyServerResp(tableData)
    elseif tag == POST_COMMAND_ANQUPAYNOTIFYSERVER then
    	self:dealAnQuPayNotifyServerResp(tableData)
    elseif tag == POST_COMMAND_JINLI_CHARGINGORDER then
    	-- dump(tableData)
     elseif tag == POST_COMMAND_PYW_CHARGINGORDER or tag == POST_COMMAND_LT_CHARGINGORDER then
     	dump(payData)
    	local payData = tableData.data or {}
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	local itemId = tableData.data["itemId"]
    	payData.itemId      = tonumber(string.sub(itemId,2,string.len(itemId)))
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)

     elseif tag == POST_COMMAND_UPAY_CHARGINGORDER then --[[酷派]]
    	local payData = tableData.data or {}
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	
    	-- local itemId = tableData.data["itemId"]
    	-- payData.itemId      = tonumber(string.sub(itemId,2,string.len(itemId)))
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)

     elseif tag == POST_COMMAND_NDUO_CHARGINGORDER then --[[N多]]
    	local payData = tableData.data or {}
    	payData.price = payData.price*100
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)
    elseif tag == POST_COMMAND_UUCUN_CHARGINGORDER then --[[悠悠村]]
    	local payData = tableData.data or {}
    	payData.price = payData.price*100
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	-- dump(payData)
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)
    elseif tag == POST_COMMAND_MMY_CHARGINGORDER then --[[木蚂蚁]]
    	local payData = tableData.data or {}
    	payData.price = payData.price
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	-- dump(payData)
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)
    	
    elseif tag == POST_COMMAND_XIAOMI_CHARGINGORDER then
    	local payData = tableData.data or {}
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)
    elseif tag == POST_COMMAND_BAIDU_CHARGINGORDER then  
    	local tmp = tableData.data.price..""
    	QManagerPlatform:showBaiduPayView(tableData.data.orderId,
                                            tableData.data.goodName,
                                            tableData.data.price.."",
                                            tableData.data.asynCallBack,
                                            tableData.data.sign,
                                            function() self:refreshMoney(tableData.data.orderId) end)
    elseif tag == POST_COMMAND_MEIZU_CHARGINGORDER then        
-- 魅族
	QManagerPlatform:showMeizuPayView(tableData.data.orderId,
									  tableData.data.goodName,
									  tableData.data.price.."",
									  tableData.data.asynCallBack,
									  tableData.data.sign,
									  function() self:refreshMoney(tableData.data.orderId) end)
    elseif tag == POST_COMMAND_UNIPAY_CHARGINGORDER then        
--  联通沃商店
		for i=1,10 do
				if UNIPAYPRICE[i] == tableData.data.price then
				QManagerPlatform:showUniPayView(tableData.data.orderId,
                                            UNIPAYCODE[i],
                                            UNIPAYCODE_THIRD_PARTY[i],
                                            tableData.data.asynCallBack,
                                            tableData.data.goodName,
                                            tableData.data.price,
                                            function() self:refreshMoney(tableData.data.orderId) end)
			end
		end	
    elseif tag == POST_COMMAND_TENCENT_UNIPAY then 
-- 	应用宝
		UserConfig.price = tostring(tableData.data.price*10)
		UserConfig.goodsname=tableData.data.goodsName;
		UserConfig.orderId=tableData.data.orderId;
		UserConfig.asynCallBack=tableData.data.asynCallBack;

		if SERVER_ENVIROMENT == ENVIROMENT_TEST then
    		DBHttpRequest:queryTencentGameCoin(function(tableData,tag) self:rechargeResponse(tableData,tag) end, "http://debaopay.boss.com/index.php",
                                                            UserConfig.openid,UserConfig.access_token,
                                                            UserConfig.pf,UserConfig.pfkey,
                                                            UserConfig.pay_token,UserConfig.zoneid,
                                                            MyInfo.data.userId, MyInfo.data.userName);
		else
			-- print(UserConfig.openid,UserConfig.access_token,
   --                                                          UserConfig.pf,UserConfig.pfkey,
   --                                                          UserConfig.pay_token,UserConfig.zoneid,
   --                                                          MyInfo.data.userId, MyInfo.data.userName)
    		DBHttpRequest:queryTencentGameCoin(function(tableData,tag) self:rechargeResponse(tableData,tag) end, "http://pay.debao.com/index.php",
                                                            UserConfig.openid,UserConfig.access_token,
                                                            UserConfig.pf,UserConfig.pfkey,
                                                            UserConfig.pay_token,UserConfig.zoneid,
                                                            MyInfo.data.userId, MyInfo.data.userName);
		end
    elseif tag == POST_COMMAND_GETACCOUNTINFO then
    	-- dump(tableData)
    	myInfo.data.totalChips = tableData["5029"] + 0 
    	self.mGoldenNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2))
    elseif tag == POST_COMMAND_QUERY_TENCENT_GAMECOIN then 
    	self:dealGameCoinQuery(tableData)
	elseif tag == POST_COMMAND_PYW_CHARGINGORDER then
		local payData = tableData.data or {}
		-- dump(payData)
    	payData.balance 	= myInfo.data.totalChips
    	payData.vipLevel  	= myInfo.data.vipLevel
    	payData.userLevel 	= myInfo.data.userLevel
    	payData.userName 	= myInfo.data.userName
    	payData.userId  	= myInfo.data.userId
    	payData.serverName  = tostring(myInfo.data.serverId)
    	local itemId = tableData.data["itemId"]
    	payData.itemId      = tonumber(string.sub(itemId,2,string.len(itemId)))
    	local callBack    = function () 
    		DBHttpRequest:getAccountInfoNew(function(data) QManagerPlatform:onChargeSuccess(tableData.data.orderId) self:rechargeResponse(data) end)
    	end    
    	QManagerPlatform:showPayView(payData,callBack)
	end
	
	if tag then	
		local payType = {
			[POST_COMMAND_MM_CHARGINGORDER]     	= "MM商场",
			[POST_COMMAND_ZBF_CHARGINGORDER]    	= "支付宝",
			[POST_COMMAND_LLPAY_CHARGINGORDER]  	= "连连支付",
			[POST_COMMAND_YDQB_CHARGINGORDER]   	= "移动钱包",
			[POST_COMMAND_UNIPAY_CHARGINGORDER]		= "联通沃商店",
			[POST_COMMAND_UPOMP_CHARGINGORDER]  	= "银联",
			[POST_COMMAND_PPS_CHARGINGORDER    ]	= "PPS平台",
			[POST_COMMAND_DK_CHARGINGORDER     ]	= "百度多酷",
			[POST_COMMAND_ALIPAYOPEN_CHARGINGORDER]	= "",
			[POST_COMMAND_WAP_CHARGINGORDER    ]	= "",
			[POST_COMMAND_TENPAY_CHARGINGORDER    ]	= "",
			[POST_COMMAND_91DPAY_CHARGINGORDER    ]	= "91点金",
			[POST_COMMAND_TENCENT_UNIPAY		]	= "财付通",	
			[POST_COMMAND_APPLE_CHARGINGORDER     ] = "苹果官方",
			[POST_COMMAND_ANQU_CHARGINGORDER     ]  = "安趣支付",
		}
		if payType[tag] ~= nil then 
		QManagerPlatform:onChargeRequest({orderId = tableData.data.orderId,iapId = tableData.data.goodName,currencyAmount = tableData.data.price,virtualCurrencyAmount = 10 * (tableData.data.price),paymentType = payType[tag] or ""})
		end
	end
end
-- 调用腾讯游戏币支付,游戏币不足则直接跳转腾讯支付界面
function ShopGoldLayer:dealGameCoinQuery(args)
	if args.ret == nil then
		local AlertDialog = require("app.Component.CMAlertDialog").new({text = "查询腾讯币余额失败!",scroll = true})
		CMOpen(AlertDialog,self:getParent())
		return
	end
	if args.ret == 0 then
		if args.balance >= tonumber(UserConfig.price) then
			-- 不再写线下环境. (联运包都只能回调到线上服务器地址)
			DBHttpSender:reduceTencentGameCoin(this, "http://pay.debao.com/index.php",
                                                             UserConfig.openid,UserConfig.access_token,
                                                             UserConfig.pf,UserConfig.pfkey,
                                                             UserConfig.pay_token,UserConfig.price, UserConfig.goodsname,UserConfig.zoneid,
                                                             MyInfo.data.userId, MyInfo.data.userName, UserConfig.orderId,UserConfig.asynCallBack);
		else
			-- 调取SDK购买
			QManagerPlatform:tencentUnipay_JNI(UserConfig.price,
                                            function() self:refreshMoney(tableData.data.orderId) end)
		end
	end
end
----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function ShopGoldLayer:onHttpDownloadResponse(tag,progress,fileName)
	if tag ==  self.mLastType then
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
end

return ShopGoldLayer