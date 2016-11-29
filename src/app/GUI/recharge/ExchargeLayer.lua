--
-- Author: junjie
-- Date: 2015-11-25 10:34:18
--
--兑换界面
local MusicPlayer = require("app.Tools.MusicPlayer")
local ExchargeLayer = class("ExchargeLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
local QDataExchargeList =  QManagerData:getCacheData("QDataExchargeList")
local NetCallBack = require("app.Network.Http.NetCallBack")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Tools.StringFormat")
function ExchargeLayer:ctor()
	self:setNodeEventEnabled(true)
	self.mAtivityName = {
		"新品","热门","金币","话费","书籍","数码产品","德堡周边","赛事门票"
	}
	self.mType = {202,201,100,101,102,103,104,105}			--活动所有类型
	self.mLastType = nil 									--最近一次选择的类型
	self.mActivitySprite = {} 								--左边图片
	self.mRightPic       = {} 								--右边需要刷新的图片
	

end
function ExchargeLayer:create()
	self:initUI()
end
function ExchargeLayer:initUI()
	self.m_bSoundEnabled = false
	    local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/shop_dif/shopBg.png")
	self.mBg = cc.Sprite:create(tmpFilename)
	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	self.mBg:setPosition(bgWidth/2,bgHeight/2)
	self:addChild(self.mBg)

	-- local title = cc.Sprite:create("picdata/shop/title_change.png")
	-- title:setPosition(title:getContentSize().width/2,bgHeight - title:getContentSize().height/2)
	-- self.mBg:addChild(title)

	local titleBg = cc.Sprite:create("picdata/shop/title_bg.png")
	titleBg:setPosition(150,bgHeight - 37)
	self.mBg:addChild(titleBg,1)

	local title = cc.Sprite:create("picdata/shop/title_change.png")
	title:setPosition(titleBg:getContentSize().width/2-22,titleBg:getPositionY()+12)
	self.mBg:addChild(title,1)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self,nil,self.dispatchEvtClose) end)
	btnClose:setScale(0.7)
	btnClose:setPosition(bgWidth-35,bgHeight - 40)
	self.mBg:addChild(btnClose)

	local golden = cc.Sprite:create("picdata/shop/rakepointIcon.png")
	golden:setPosition(315,bgHeight - 38)
	self.mBg:addChild(golden)

	local goldenNum = cc.ui.UILabel.new({
        UILabelType = 1,
        -- text  = CMFormatNum(myInfo.data.diamondBalance),
        text  = StringFormat:FormatDecimals(myInfo.data.diamondBalance or 0,2),
        font  = "picdata/shop/grayPrice.fnt",
        x     = golden:getPositionX()+25,
        y     = golden:getPositionY()+2,
        align = cc.ui.TEXT_ALIGN_LEFT,
    })
    self.mBg:addChild(goldenNum)
    local btnHelp = CMButton.new({normal = "picdata/shop/btn_jf_js.png",pressed = "picdata/shop/btn_jf_js2.png"},function () self:onMenuHelp() end)
	btnHelp:setPosition(422,golden:getPositionY())
	self.mBg:addChild(btnHelp)

    self:createLeftList( )
    if QDataExchargeList:isExistMsgData() then
    	self:onMenuSwitch(1)
    else
    	DBHttpRequest:getGoodsList(function(tableData,tag) self:httpResponse(tableData,tag) end,"EXCHANGE")
    end

 	self.mGoldenNum = goldenNum
end
function ExchargeLayer:onEnter()
	self.m_bSoundEnabled = true
end
function ExchargeLayer:onExit()
	--QManagerData:removeCacheData("QDataExchargeList")
end
--[[
	创建左边列表
]]
function ExchargeLayer:createLeftList( )
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
	    :align(display.CENTER, -10,0) --设置位置 锚点位置和坐标x,y
	    item:addContent(btnActivity)   
	    	 
		local selecthSprite = cc.Sprite:create("picdata/shop/shop_btn_1.png")
		selecthSprite:setVisible(false)
		selecthSprite:setPosition(selecthSprite:getContentSize().width/2,selecthSprite:getContentSize().height/2)
		btnActivity:addChild(selecthSprite,0,101)

		local sDetail = cc.ui.UILabel.new({text = self.mAtivityName[i],size = 28,color = cc.c3b(188,201,229),font = GFZZC})	
		sDetail:setPosition(btnActivity:getContentSize().width/2-sDetail:getContentSize().width/2,btnActivity:getContentSize().height/2)
		btnActivity:addChild(sDetail,1,102)

		item:setItemSize(btnActivity:getContentSize().width, btnActivity:getContentSize().height+6)
	   	self.mActivityList:addItem(item)
		self.mActivitySprite[#self.mActivitySprite + 1] = btnActivity
	end	
	self.mActivityList:reload()	
end
function ExchargeLayer:touchListener(event)
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
function ExchargeLayer:checkTouchInSprite_(x, y,itemPos)	
	--dump(data)
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
function ExchargeLayer:createRightList(nType )
	
	self.mLastType = nType
	-- body
	self.mRightListSize = cc.size(self.mBg:getContentSize().width - 255,self.mBg:getContentSize().height - 90)	
	self.mRightList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(255, 0, self.mRightListSize.width, self.mRightListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --:onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
  	
  	local cfgData = QDataExchargeList:getMsgData(nType)
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
	    		--picPath = "http://www.debao.com"..cfgData[i][GOODS_GOODS_PIC]
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
	        color = cc.c3b(60, 207, 255),
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
	        color = cc.c3b(164, 195, 255),
	        text  = cfgData[i][GOODS_DESC] or "",
	        size  = 18,
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
    	if tonumber(myInfo.data.diamondBalance) < (tonumber(cfgData[i][PAY_NUM])) then 
    		btnPath = "picdata/shop/btn_buy_no.png"
    		goldPath = "picdata/shop/icon_jf_gray.png"
    		fntPath = "picdata/shop/grayPrice.fnt"
    		isEnable = false
    	end
    	local btnExcharge = CMButton.new({normal = btnPath},function () self:onMenuExcharge(cfgData[i]) end)
    	btnExcharge:setPosition(itemSize.width - 120,itemSize.height/2)
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
	        align = cc.ui.TEXT_ALIGNMENT_CENTER,
	    })
	    sNeedGold:setPosition(15-sNeedGold:getContentSize().width/2,3)
    	btnExcharge:addChild(sNeedGold)

			
	end	

	self.mRightList:reload()	
end
function ExchargeLayer:touchRightListener(event)

end
function ExchargeLayer:onMenuClose(sender, event)
	self:removeFromParent()
end
function ExchargeLayer:onMenuHelp()
    local spc1 = string.rep(" ", 96)
    local spc2 = string.rep(" ", 82)
    strArr = string.format("[fontColor=fefefe fontSize=28]1、玩家在[/fontColor][fontColor=00ffff fontSize=28]中高级场玩牌[/fontColor][fontColor=fefefe fontSize=28],每局将获得数量不登的积分,[/fontColor][fontColor=00ffff fontSize=28]盲注级别越高,获得积分越多[/fontColor][fontColor=fefefe fontSize=28]。[/fontColor][fontColor=fefefe fontSize=28]%s[/fontColor][fontColor=00ffff fontSize=28]2、VIP[/fontColor][fontColor=fefefe fontSize=28]玩家可获得相应等级的[/fontColor][fontColor=00ffff fontSize=28]积分返还加成[/fontColor][fontColor=fefefe fontSize=28]。%s3、积分可在商城[/fontColor][fontColor=00ffff fontSize=28]兑换各种奖品[/fontColor][fontColor=fefefe fontSize=28]。[/fontColor]",spc1,spc2)

	local RewardLayer = require("app.Component.CMAlertDialog").new({titleText = "积分说明",text = "",showType = 0,titleIcon = "picdata/shop/rakepointIcon.png",colorText = strArr})
	CMOpen(RewardLayer, self)
end
--[[
	界面切换
]]
function ExchargeLayer:onMenuSwitch(idx)
	if self.mLastType == self.mType[idx] then return end
	-- self.mActivitySprite[idx]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
	self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(255,238,204))
	self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
	if self.mRightList then self.mRightList:removeFromParent() self.mRightList = nil end
	self:createRightList(self.mType[idx] )
end
--[[
	兑换
]]
function ExchargeLayer:onMenuExcharge(params)
	local ShopExchargeLayer = require("app.GUI.recharge.ShopExchargeLayer").new(params)
    ShopExchargeLayer:setPosition(self.mBg:getContentSize().width/2+93,self.mBg:getContentSize().height/2)
    CMOpen(ShopExchargeLayer, self,self.mBg:getContentSize().width/2,0)
end
--[[
	更新金币
]]
function ExchargeLayer:updateData()
	if self.mGoldenNum then self.mGoldenNum:setString(StringFormat:FormatDecimals(myInfo.data.diamondBalance or 0,2)) end
end
--[[
	网络回调
]]
function ExchargeLayer:httpResponse(tableData,tag)

	--dump(tableData,tag)
	
	--if tag == POST_COMMAND_GETGOODSLIST then  				--请求列表回调	
		if tableData then
			QDataExchargeList:Init(tableData)
			self:onMenuSwitch(1)
		end
	--end
	
end

----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function ExchargeLayer:onHttpDownloadResponse(tag,progress,fileName)
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

return ExchargeLayer