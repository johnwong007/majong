--
-- Author: junjie
-- Date: 2015-12-11 11:13:59
--
--我的物品
local MyPacketLayer = class("MyPacketLayer",function() 
	return display.newNode()
end)
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local QDataMyPacketList = nil
local NetCallBack = require("app.Network.Http.NetCallBack")
local GameLayerManager  = require("app.GUI.GameLayerManager")
function MyPacketLayer:ctor(params)
    QDataMyPacketList = QManagerData:getCacheData("QDataMyPacketList")
	self.params = params or {}
    self.params.nType = self.params.nType or 1
	self.mAllType = {"TICKET","PROPS","CARD"}

    self.mCardFetchNode = {}
    self.mCardHasFetchNode = {}	
end
local EnumMenu = {
    eShop = 1,
    eUse  = 2,
    ePYJ  = 3,
    eFetch = 4,
}
function MyPacketLayer:create()
    self:initUI()
end
function MyPacketLayer:getTimecardUsingLogCallback(tableData, tag)
    dump(tableData)
    if tableData and type(tableData)=="table" and tableData[self.m_pDateToday] and 
        type(tableData[self.m_pDateToday])=="table" then
        for k,v in pairs(tableData[self.m_pDateToday]) do
            if k~="TOTAL" then
                if v=="YES" then
                    if self.mCardHasFetchNode and self.mCardHasFetchNode[k] then
                        self.mCardHasFetchNode[k]:setVisible(true)
                    end 
                else
                    if self.mCardFetchNode and self.mCardFetchNode[k] then
                        self.mCardFetchNode[k]:setVisible(true)
                    end 
                end
            end
        end
    else
        if self.mCardFetchNode then
            for k,v in pairs(self.mCardFetchNode) do
                v:setVisible(true)
            end
        end
    end
end
function MyPacketLayer:initUI()
    self:setContentSize(600,500)
    self:setPosition(-45, -20)
    self.mBg = self

    local line1 = cc.ui.UIImage.new("picdata/public_new/line2.png")
    line1:align(display.CENTER, 330, 300)
        :addTo(self.mBg)
    line1:setRotation(-90)
    line1:setScaleX(0.7)

    --self:createButtonGroup()
    local isExist = QDataMyPacketList:isExistMsgData()
    if isExist then
        self:createRightList(self.params.nType)
    else 
        DBHttpRequest:getKnapSack(function(tableData,tag) self:httpResponse(tableData,tag,self.params.nType) end)
    end

end

-- --[[tabbar按钮]]
-- function MyPacketLayer:createButtonGroup()

-- 	local bg = cc.Sprite:create("picdata/personalCenter/menu_packet_bg.png")
-- 	bg:setPosition(self.mBg:getContentSize().width/2,430)
-- 	self.mBg:addChild(bg)

-- 	self.menu = cc.Sprite:create("picdata/public/btn_1_menu2.png")
-- 	self.mBg:addChild(self.menu)
--     local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
--     :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/personalCenter/w_mune_mp2.png",off_pressed = "picdata/personalCenter/w_mune_mp.png", on = "picdata/personalCenter/w_mune_mp.png",}))
--     :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/personalCenter/w_mune_dj2.png",off_pressed = "picdata/personalCenter/w_mune_dj.png", on = "picdata/personalCenter/w_mune_dj.png",}))
--     :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/personalCenter/w_mune_zyk2.png",off_pressed = "picdata/personalCenter/w_mune_zyk.png", on = "picdata/personalCenter/w_mune_zyk.png",}))
   
--     :setButtonsLayoutMargin(0, 62, 0, 0)
--     :onButtonSelectChanged(function(event)
--         local group = self.mGroup:getButtonAtIndex(event.selected)
--         self.menu:setPosition(group:getPositionX()+142,group:getPositionY()+417)
--         self:createRightList( event.selected)
--         self.mLastType =  event.selected
--     end)
--     :align(display.LEFT_TOP, 142,417)
--     :addTo(self.mBg,1)
--      self.mGroup = group
--     group:getButtonAtIndex(1):setButtonSelected(true)

-- end
function MyPacketLayer:createRightList(idx)
    if idx == 1 then
        if self.mTipKuang then self.mTipKuang:removeFromParent() self.mTipKuang = nil end
        self:createTicketList(self.mAllType[idx])
    elseif idx == 2 then
        self:createPropList(self.mAllType[idx])
    elseif idx == 3 then
        self:createCardsList(self.mAllType[idx])
        self.m_pDateToday = os.date("%Y-%m-%d",os.time())
        HttpClient:getTimecardUsingLog(handler(self, self.getTimecardUsingLogCallback), myInfo.data.userId,self.m_pDateToday,self.m_pDateToday)
    end
end
function MyPacketLayer:TransitionTime(sTime)
     -- local str = "2012-24-23 03:39:36"    
    local pattern = " "
    local fpos ,lpos =  string.find(sTime,pattern)
    sTime = string.sub(sTime,1,lpos-1)
    sTime = string.gsub(sTime,"-","/")
    return sTime
end

function MyPacketLayer:TransitionTitle(sTitle)
    local path = {
    "picdata/notice/news-huodong.png",
    "picdata/notice/news-jbs.png",
    "picdata/notice/news-libao.png",
    "picdata/notice/news-qiandao.png",
    "picdata/notice/news-shousheng.png",
    "picdata/notice/news-shoushu.png",
    "picdata/notice/news-tf.png",
    "picdata/notice/news-vip.png",
    "picdata/notice/news-zhangdui.png",
    "picdata/notice/news.png",
}

    local allIconTip = {"活动","锦标赛","礼包","签到","首胜","手数","提示","vip","战队"}
    --sTitle = "每周签到"
    for i,v in pairs(allIconTip) do 
        local pattern = v 
        local fPos,lPos = string.find(sTitle,v)
        if fPos then
           return path[i]
        end
    end
    return path[10]
end
function MyPacketLayer:createTicketList(nType)
    local cfgData = QDataMyPacketList:getMsgData(nType)
    if self.mList then self.mList:removeFromParent() self.mList = nil end
    if not cfgData or #cfgData == 0 then 
    	self.mList = cc.Sprite:create("picdata/personalCenter/ticket_none.png")
    	self.mList:setPosition(600,300)
    	self.mBg:addChild(self.mList)

        return 
    end 
	
    -- body
    self.mListSize = cc.size(635+14,CONFIG_SCREEN_HEIGHT-100) 
    self.mList = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(310, 70-70, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
    self.mTickSprite = {}
   local backPath = "picdata/personCenterNew/myPacket/bg.png";
   local imagePath = "picdata/personalCenter/transBG.png";
   local imgBgPath="picdata/personalCenter/bg_3_list_thing.png";
   local txtBgPath="picdata/personalCenter/bg_4_list_input.png";
    
   local btnPath="picdata/public_new/btn_mini_green.png"
   local btnPath2="picdata/public_new/btn_mini_green.png"

    for i = 1,#cfgData do      

        local item = self.mList:newItem() 
     
        local serData = cfgData[i] or {}
       
       
        local bg   = cc.Sprite:create(backPath)
        local bgWidth = bg:getContentSize().width
        local bgHeight= bg:getContentSize().height
        local itemSize = cc.size(self.mListSize.width,bgHeight+5+4)
        bg:setPosition(bgWidth/2,itemSize.height - bgHeight)
        item:addContent(bg)

        
        item:setItemSize(self.mListSize.width,itemSize.height)
        self.mList:addItem(item)

        -- local content     
        -- content = cc.LayerColor:create(
        --     cc.c4b(math.random(250),
        --         math.random(250),
        --         math.random(250),
        --         250))
        -- content:setContentSize(itemSize.width, itemSize.height)
        -- content:setTouchEnabled(true)    
        -- item:addChild(content) 
        --local imagePath
        if serData[MYGOODS_GOODS_PROPS_PIC] then
            local isExist,newPath = NetCallBack:getCacheImage(serData[MYGOODS_GOODS_PROPS_PIC])
            if isExist then
                imagePath = newPath
            else
                NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..serData[MYGOODS_GOODS_PROPS_PIC],nType,serData[MYGOODS_GOODS_PROPS_PIC],i)
            end
        end
        -- local iconbg   = cc.Sprite:create(imgBgPath)
        local iconbg   = display.newNode()
        iconbg:align(display.CENTER, 0, 0)
        bg:addChild(iconbg)
        if imagePath then
            local image   = cc.Sprite:create(imagePath)
            local scalex = 144/(image:getContentSize().width)
            local scaley = 94/(image:getContentSize().height)
            image:setScaleX(scalex)
            image:setScaleY(scaley)
            image:setPosition(80, bgHeight/2+2)
            iconbg:addChild(image)

             self.mTickSprite[i] = image
        end
        local name = cc.ui.UILabel.new({
                text  = serData[MYGOODS_PROPS_PROPS_NAME] or "dasd",--self:TransitionTime(serData[NOTICE_DATE]),
                size  = 28,
                color = cc.c3b(255,255,255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        name:setPosition(172,bgHeight/2 + 28)
        bg:addChild(name)

         local valid = cc.ui.UILabel.new({
                text  = (serData[MYGOODS_PROPS_DEADLINE] or "11"),
                size  = 22,
                color = cc.c3b(180,192,220),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        valid:setPosition(name:getPositionX(),bgHeight/2-25)
        bg:addChild(valid)

     --    local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eUse,itemData) end,{scale9 = false})
    	-- btnTime:setPosition(bgWidth - 70,bgHeight/2-27)
    	-- btnTime:setTouchSwallowEnabled(false)
    	-- bg:addChild(btnTime)
        local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eUse,itemData) end,{scale9 = true})
        btnTime:setButtonSize(114, 56)
        btnTime:setButtonLabel("normal", cc.ui.UILabel.new({
            text  = "使用",
            size  = 26,
            color = cc.c3b(255,255,255),
            align = cc.ui.TEXT_ALIGN_CENTER,
            font  = "黑体",
        }))
        btnTime:align(display.CENTER,bgWidth - 52 - 16,valid:getPositionY())
        btnTime:setTouchSwallowEnabled(false)
        bg:addChild(btnTime)
       
    end 

    self.mList:reload() 
end
function MyPacketLayer:createDetailNode()
     --[[ 说明节点   ]]
    local node = cc.Node:create()
    self.mBg:addChild(node)
    node:setVisible(false)

    local pic = cc.Sprite:create("picdata/personalCenter/transBG.png")
    pic:setPosition(350,105)
    node:addChild(pic,0,100)
    local sName =  cc.ui.UILabel.new({
                text  = "",
                size  = 28,
                color = cc.c3b(255,255,255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                
            })
    sName:setPosition(420,140)
    node:addChild(sName,0,101)

    local sDetail =  cc.ui.UILabel.new({
                text  = "",
                size  = 24,
                color = cc.c3b(135,154,192),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                dimensions = cc.size(470,0),
            })
    sDetail:setPosition(420,90)
    node:addChild(sDetail,0,102)
    self.mPropDetail = node
end
--[[
    我的物品－－道具
    ]]
function MyPacketLayer:createPropList(nType)
     if self.mList then self.mList:removeFromParent() self.mList = nil end

    local cfgData = QDataMyPacketList:getMsgData(nType)
    if not cfgData or #cfgData == 0 then 
        -- local node = cc.Node:create()
        -- self.mList:addChild(node)
        self.mList = cc.Node:create()
        self.mBg:addChild(self.mList)

        local tips = cc.Sprite:create("picdata/personalCenter/props_none_txt.png")
        tips:setPosition(600,380)
        self.mList:addChild(tips)

        local btnPath = "picdata/personalCenter/btn_5_shop.png"
        local btnPath2 = "picdata/personalCenter/btn_5_shop.png"
        local btnShop = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eShop,itemData) end)
        btnShop:setPosition(tips:getPositionX(),tips:getPositionY() - 80)
        self.mList:addChild(btnShop)
        return
    end 

	self.mCfgData = cfgData
   
    self.mActivitySprite = {}
    -- body
    -- self.mListSize = cc.size(635,480) 
    -- self.mList = cc.ui.UIListView.new {
    --     --bgColor = cc.c4b(200, 200, 200, 120),
    --     viewRect = cc.rect(310, 50, self.mListSize.width, self.mListSize.height),       
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchPropListener))
    -- :addTo(self.mBg,1)   

    self.mListSize = cc.size(635+14,CONFIG_SCREEN_HEIGHT-100) 
    self.mList = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(310, 70-70, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1) 

    local btnPath = "picdata/personalCenter/btn_7_tool.png"
    local btnPath2 = "picdata/personalCenter/btn_7_tool2.png"
    local imagePath = "picdata/personalCenter/transBG.png"
   local backPath = "picdata/personCenterNew/myPacket/bg.png"
   local imgBgPath="picdata/personalCenter/bg_3_list_thing.png"
   local txtBgPath="picdata/personalCenter/bg_4_list_input.png"
    
   local btnPath="picdata/public_new/btn_mini_green.png"
   local btnPath2="picdata/public_new/btn_mini_green.png"

  for i = 1,#cfgData do 
 
        local item = self.mList:newItem() 
     
        local serData = cfgData[i] or {}
       
       
        local bg   = cc.Sprite:create(backPath)
        local bgWidth = bg:getContentSize().width
        local bgHeight= bg:getContentSize().height
        local itemSize = cc.size(self.mListSize.width,bgHeight+5+4)
        bg:setPosition(bgWidth/2,itemSize.height - bgHeight)
        item:addContent(bg)

        item:setItemSize(self.mListSize.width,itemSize.height)
        self.mList:addItem(item)

        if serData[MYGOODS_GOODS_PROPS_PIC] ~= "" then
            local isExist,newPath = NetCallBack:getCacheImage(serData[MYGOODS_GOODS_PROPS_PIC])
            if isExist then
                imagePath = newPath
            else
                NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..serData[MYGOODS_GOODS_PROPS_PIC],nType,serData[MYGOODS_GOODS_PROPS_PIC],curIndex)
            end
        end
        -- local iconbg   = cc.Sprite:create(imgBgPath)
        local iconbg   = display.newNode()
        iconbg:align(display.CENTER, 0, 0)
        bg:addChild(iconbg)
        if imagePath then
            local image   = cc.Sprite:create(imagePath)
            local scalex = 144/(image:getContentSize().width)
            local scaley = 94/(image:getContentSize().height)
            image:setScaleX(scalex)
            image:setScaleY(scaley)
            image:setPosition(80, bgHeight/2)
            iconbg:addChild(image)

            self.mActivitySprite[#self.mActivitySprite + 1] = image

            local sNum =  cc.ui.UILabel.new({
                text  = serData[MYGOODS_GOODS_PROPS_NUM] or "1",
                size  = 24,
                color = cc.c3b(0,255,255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "Arial",
                
            })
            sNum:align(display.LEFT_CENTER,15,bgHeight-30+4)
            iconbg:addChild(sNum,1)
        end
     
        local name = cc.ui.UILabel.new({
                text  = serData[MYGOODS_PROPS_PROPS_NAME] or "",
                size  = 28,
                color = cc.c3b(255,255,255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        name:setPosition(172,bgHeight/2 + 28)
        bg:addChild(name)

        local description = cc.ui.UILabel.new({
                text  = (serData[MYGOODS_PROPS_PROPS_DESC] or ""),
                size  = 22,
                color = cc.c3b(180,192,220),
                align = cc.ui.TEXT_ALIGN_LEFT,
                dimensions = cc.size(420,0),
                font  = "黑体",
            })
        description:setPosition(name:getPositionX(),bgHeight/2-25)
        bg:addChild(description)

        local card_name={
            "标准牌局卡",
            "MTT开局卡",
            -- "6+大牌扑克牌局卡",

            "自定义筹码牌局卡",

            "单桌SNG牌局卡",

            "6+",
            "免服务费体验卡",
            "免服务费",
            "牌局卡",
            "体验卡",
            "开局卡",


        }
        local haveButton = false 
        for i=1,#card_name do
            if string.find(serData[MYGOODS_PROPS_PROPS_NAME], card_name[i]) then
                haveButton = true
                break
            end
        end
        if haveButton then
            local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.ePYJ,itemData) end,{scale9 = true})
            btnTime:setButtonSize(114, 56)
            btnTime:setButtonLabel("normal", cc.ui.UILabel.new({
                text  = "使用",
                size  = 26,
                color = cc.c3b(255,255,255),
                align = cc.ui.TEXT_ALIGN_CENTER,
                font  = "黑体",
            }))
            btnTime:align(display.CENTER,bgWidth - 68,bgHeight/2-27)
            btnTime:setTouchSwallowEnabled(false)
            bg:addChild(btnTime)
        end

		-- local pic1
  --       local curIndex
		-- local posx = 60
		-- for j = 1,5 do
  --           curIndex = index + j
  --           local serData = cfgData[curIndex]
  --           if not serData then break end
          
  --           if serData[MYGOODS_GOODS_PROPS_PIC] ~= "" then
  --               local isExist,newPath = NetCallBack:getCacheImage(serData[MYGOODS_GOODS_PROPS_PIC])
  --               if isExist then
  --                   imagePath = newPath
  --               else
  --                   NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..serData[MYGOODS_GOODS_PROPS_PIC],nType,serData[MYGOODS_GOODS_PROPS_PIC],curIndex)
  --               end
  --           end
		-- 	pic1 = cc.Sprite:create(btnPath)
		--     pic1:setPosition(posx,pic1:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
		--     node:addChild(pic1)   
		--     self.mActivitySprite[#self.mActivitySprite + 1] = pic1
		--     posx = posx + pic1:getContentSize().width + 18
	           
  --           local sNum =  cc.ui.UILabel.new({
  --               text  = serData[MYGOODS_GOODS_PROPS_NUM] or "1",
  --               size  = 20,
  --               color = cc.c3b(1,250,221),
  --               align = cc.ui.TEXT_ALIGN_LEFT,
  --               --UILabelType = 1,
  --               font  = "黑体",
                
  --           })
  --           sNum:setPosition(pic1:getContentSize().width - sNum:getContentSize().width/2-22,20)
  --           pic1:addChild(sNum,1)

  --           local image = cc.Sprite:create(imagePath)
  --           image:setPosition(pic1:getContentSize().width/2,pic1:getContentSize().height/2)
  --           pic1:addChild(image,1,101)
	 --    end

	 --    if i == 1 then 
  --           self.mSelectSprite = nil
		-- 	self:onMenuSwitch(1)
		-- end
		-- node:setContentSize(self.mListSize.width, pic1:getContentSize().height+16)
		-- item:setItemSize(self.mListSize.width, pic1:getContentSize().height+16)
	 --   	self.mList:addItem(item)
        
    end 

    self.mList:reload() 
end
function MyPacketLayer:touchPropListener(event)
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

function MyPacketLayer:checkTouchInSprite_(x, y,itemPos)	
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then								
			self:onMenuSwitch(i)
		else
			--self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
		end
	end	
end

function MyPacketLayer:onMenuSwitch(idx)
    if not self.mPropDetail then self:createDetailNode() end
    if self.mSelectSprite then self.mSelectSprite:removeFromParent() self.mSelectSprite  = nil end
    local width = self.mActivitySprite[idx]:getContentSize().width
    local height = self.mActivitySprite[idx]:getContentSize().height
    self.mSelectSprite = cc.Sprite:create("picdata/personalCenter/btn_7_tool2.png")
    self.mSelectSprite:setPosition(width/2,height/2)
    self.mActivitySprite[idx]:addChild(self.mSelectSprite)
    self.mSelectSprite:setVisible(false)
    if self.mCfgData[idx][MYGOODS_GOODS_PROPS_PIC] ~= "" then
         local isExist,newPath = NetCallBack:getCacheImage(self.mCfgData[idx][MYGOODS_GOODS_PROPS_PIC])
        if isExist then    
            self.mPropDetail:getChildByTag(100):setTexture(newPath)
        end
    end
     self.mPropDetail:getChildByTag(101):setString(self.mCfgData[idx][MYGOODS_PROPS_PROPS_NAME])
    local sDetail = self.mPropDetail:getChildByTag(102)
    sDetail:setString(self.mCfgData[idx][MYGOODS_PROPS_PROPS_DESC])
    sDetail:setPositionY(125-sDetail:getContentSize().height/2)

end
function MyPacketLayer:createCardsList(nType)
    if self.mList then self.mList:removeFromParent() self.mList = nil end
    local cfgData = QDataMyPacketList:getMsgData(nType)
    if not cfgData or #cfgData == 0 then 
        self.mList = cc.Node:create()
        self.mBg:addChild(self.mList)

        local tips = cc.Sprite:create("picdata/personalCenter/props_none_txt.png")
        tips:setPosition(600,380)
        self.mList:addChild(tips)

        local btnPath = "picdata/personalCenter/btn_5_shop.png"
        local btnPath2 = "picdata/personalCenter/btn_5_shop.png"
        local btnShop = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eShop,itemData) end)
        btnShop:setPosition(tips:getPositionX(),tips:getPositionY() - 80)
        self.mList:addChild(btnShop)
        return
    end 

    -- body
    self.mListSize = cc.size(635+14,CONFIG_SCREEN_HEIGHT-100)  
    self.mList = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(310, 70-70, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    



    local btnPath = "picdata/personalCenter/btn_7_tool.png"
    local btnPath2 = "picdata/personalCenter/btn_7_tool2.png"
    local imagePath = "picdata/personalCenter/transBG.png"
   local backPath = "picdata/personCenterNew/myPacket/bg.png"
   local imgBgPath="picdata/personalCenter/bg_3_list_thing.png"
   local txtBgPath="picdata/personalCenter/bg_4_list_input.png"
    
   local btnPath="picdata/public_new/btn_mini_green.png"
   local btnPath2="picdata/public_new/btn_mini_green.png"


   -- local backPath = "picdata/personalCenter/bg_yk.png";
   -- local imagePath = "picdata/personalCenter/transBG.png";
   -- local imgBgPath="picdata/personalCenter/bg_3_list_thing.png";
   -- local txtBgPath="picdata/personalCenter/bg_4_list_input.png";
    
   -- -- local btnPath="picdata/personalCenter/btn_sy.png"
   -- -- local btnPath2="picdata/personalCenter/btn_sy2.png"
   -- local btnPath="picdata/public_new/btn_mini_green.png"
   -- local btnPath2="picdata/public_new/btn_mini_green.png"
   local imagePath = ""
    for i = 1,#cfgData do      

        local item = self.mList:newItem() 
     
        local serData = cfgData[i] or {}
       
       
        local bg   = cc.Sprite:create(backPath)
        local bgWidth = bg:getContentSize().width
        local bgHeight= bg:getContentSize().height
        local itemSize = cc.size(self.mListSize.width,bgHeight+8)
        bg:setPosition(bgWidth/2,itemSize.height - bgHeight)
        item:addContent(bg)

        
        item:setItemSize(self.mListSize.width,itemSize.height)
        self.mList:addItem(item)

        -- local content     
        -- content = cc.LayerColor:create(
        --     cc.c4b(math.random(250),
        --         math.random(250),
        --         math.random(250),
        --         250))
        -- content:setContentSize(itemSize.width, itemSize.height)
        -- content:setTouchEnabled(true)    
        -- item:addChild(content) 
        -- if serData[MYGOODS_GOODS_PROPS_PIC] then
        --     local isExist,newPath = NetCallBack:getCacheImage(serData[MYGOODS_GOODS_PROPS_PIC])
        --     if isExist then
        --         imagePath = newPath
        --     else
        --         NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..serData[MYGOODS_GOODS_PROPS_PIC],nType,serData[MYGOODS_GOODS_PROPS_PIC],i)
        --     end
        -- end

        local cardLevel = 1
        local hintText = nil
        if serData[MYGOODS_PROPS_PROPS_NAME] == "普通月卡" then
            cardLevel = 1
            hintText = "每天可领8000金币,剩余"..serData[MYGOODS_GOODS_PROPS_NUM].."次"
        elseif serData[MYGOODS_PROPS_PROPS_NAME] == "白银月卡" then
            cardLevel = 2
            hintText = "每天可领2万金币,剩余"..serData[MYGOODS_GOODS_PROPS_NUM].."次"
        elseif serData[MYGOODS_PROPS_PROPS_NAME] == "黄金月卡" then
            cardLevel = 3
            hintText = "每天可领5万金币,剩余"..serData[MYGOODS_GOODS_PROPS_NUM].."次"
        else
            cardLevel = 4
            hintText = "每天可领20万金币,剩余"..serData[MYGOODS_GOODS_PROPS_NUM].."次"
        end
        local newPath = string.format("picdata/db_gold/card%d.png",cardLevel)
        -- local iconbg   = cc.Sprite:create(imgBgPath)
        -- iconbg:setPosition(10 + iconbg:getContentSize().width/2, bgHeight/2)
        -- bg:addChild(iconbg)

        local icon = cc.Sprite:create(newPath)
        local scalex = 144/(icon:getContentSize().width)
        local scaley = 94/(icon:getContentSize().height)
        icon:setScaleX(scalex)
        icon:setScaleY(scaley)
        icon:setPosition(80, bgHeight/2)
        bg:addChild(icon)

        local name = cc.ui.UILabel.new({
                text  = serData[MYGOODS_PROPS_PROPS_NAME] or "asfd",--self:TransitionTime(serData[NOTICE_DATE]),
                size  = 28,
                color = cc.c3b(255,255,255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        name:setPosition(172,bgHeight/2 + 28)
        bg:addChild(name)

         local valid = cc.ui.UILabel.new({
                text  = (serData[MYGOODS_GOODS_PROPS_NUM] or "asdf"),
                size  = 26,
                color = cc.c3b(1,250,221),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        valid:setPosition(name:getPositionX(),95)
        -- bg:addChild(valid)

         local sDetail = cc.ui.UILabel.new({
                text  = hintText or "",
                size  = 22,
                color = cc.c3b(180,192,220),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                -- dimensions =cc.size(bgWidth - 20,0)
            })
        sDetail:setPosition(180,bgHeight/2-25)
        bg:addChild(sDetail)
        -- local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eUse,itemData) end,{scale9 = false})
        -- btnTime:setPosition(bgWidth - 70,bgHeight/2-27)
        -- btnTime:setTouchSwallowEnabled(false)
        -- bg:addChild(btnTime)
        
            local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eFetch,itemData) end,{scale9 = true})
            btnTime:setButtonSize(114, 56)
            btnTime:setButtonLabel("normal", cc.ui.UILabel.new({
                text  = "领取",
                size  = 26,
                color = cc.c3b(255,255,255),
                align = cc.ui.TEXT_ALIGN_CENTER,
                font  = "黑体",
            }))
            btnTime:align(display.CENTER,bgWidth - 52,bgHeight/2-25)
            btnTime:setTouchSwallowEnabled(false)
            bg:addChild(btnTime)
    btnTime:setVisible(false)

    local image = cc.ui.UIImage.new("picdata/personCenterNew/myPacket/icon_jryl.png")
    image:align(display.CENTER,bgWidth - 52,bgHeight/2)
    bg:addChild(image)
    image:setVisible(false)
    self.mCardFetchNode[serData[MYGOODS_PROPS_PROPS_NAME]] = btnTime
    self.mCardHasFetchNode[serData[MYGOODS_PROPS_PROPS_NAME]] =  image
    end 

    self.mList:reload() 



end
-- function MyPacketLayer:createCardsList(nType)
--    local cfgData = QDataMyPacketList:getMsgData(nType)
--     if self.mList then self.mList:removeFromParent() self.mList = nil end
--     if not cfgData or #cfgData == 0 then 
--         return 
--     end 
    
--     -- body
--     self.mListSize = cc.size(635+14,530) 
--     self.mList = cc.ui.UIListView.new {
--         --bgColor = cc.c4b(200, 200, 200, 120),
--         viewRect = cc.rect(310, 70-70, self.mListSize.width, self.mListSize.height),       
--         direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
--     :onTouch(handler(self, self.touchRightListener))
--     :addTo(self.mBg,1)    

--    local backPath = "picdata/personalCenter/bg_yk.png";
--    local imagePath = "picdata/personalCenter/transBG.png";
--    local imgBgPath="picdata/personalCenter/bg_3_list_thing.png";
--    local txtBgPath="picdata/personalCenter/bg_4_list_input.png";
    
--    -- local btnPath="picdata/personalCenter/btn_sy.png"
--    -- local btnPath2="picdata/personalCenter/btn_sy2.png"
--    local btnPath="picdata/public_new/btn_mini_green.png"
--    local btnPath2="picdata/public_new/btn_mini_green.png"
--    local imagePath = ""
--     for i = 1,#cfgData do      

--         local item = self.mList:newItem() 
     
--         local serData = cfgData[i] or {}
       
       
--         local bg   = cc.Sprite:create(backPath)
--         local bgWidth = bg:getContentSize().width
--         local bgHeight= bg:getContentSize().height
--         local itemSize = cc.size(self.mListSize.width,bgHeight+5)
--         bg:setPosition(bgWidth/2,itemSize.height - bgHeight)
--         item:addContent(bg)

        
--         item:setItemSize(self.mListSize.width,itemSize.height)
--         self.mList:addItem(item)

--         -- local content     
--         -- content = cc.LayerColor:create(
--         --     cc.c4b(math.random(250),
--         --         math.random(250),
--         --         math.random(250),
--         --         250))
--         -- content:setContentSize(itemSize.width, itemSize.height)
--         -- content:setTouchEnabled(true)    
--         -- item:addChild(content) 
--         -- if serData[MYGOODS_GOODS_PROPS_PIC] then
--         --     local isExist,newPath = NetCallBack:getCacheImage(serData[MYGOODS_GOODS_PROPS_PIC])
--         --     if isExist then
--         --         imagePath = newPath
--         --     else
--         --         NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..serData[MYGOODS_GOODS_PROPS_PIC],nType,serData[MYGOODS_GOODS_PROPS_PIC],i)
--         --     end
--         -- end

--         local cardLevel = 1
--         if serData[MYGOODS_PROPS_PROPS_NAME] == "普通月卡" then
--             cardLevel = 1
--         elseif serData[MYGOODS_PROPS_PROPS_NAME] == "白银月卡" then
--             cardLevel = 2
--         elseif serData[MYGOODS_PROPS_PROPS_NAME] == "黄金月卡" then
--             cardLevel = 3
--         else
--             cardLevel = 4
--         end
--         local newPath = string.format("picdata/db_gold/card%d.png",cardLevel)
--         -- local iconbg   = cc.Sprite:create(imgBgPath)
--         -- iconbg:setPosition(10 + iconbg:getContentSize().width/2, bgHeight/2)
--         -- bg:addChild(iconbg)

--         local icon = cc.Sprite:create(newPath)
--         icon:setScale(0.75)
--         icon:setRotation(30)
--         icon:setPosition(56, 125)
--         bg:addChild(icon)

--         local name = cc.ui.UILabel.new({
--                 text  = serData[MYGOODS_PROPS_PROPS_NAME] or "asfd",--self:TransitionTime(serData[NOTICE_DATE]),
--                 size  = 28,
--                 color = cc.c3b(255,255,255),
--                 align = cc.ui.TEXT_ALIGN_LEFT,
--                 --UILabelType = 1,
--                 font  = "黑体",
--             })
--         name:setPosition(130,bgHeight/2 + 60)
--         bg:addChild(name)

--          local valid = cc.ui.UILabel.new({
--                 text  = (serData[MYGOODS_GOODS_PROPS_NUM] or "asdf"),
--                 size  = 26,
--                 color = cc.c3b(1,250,221),
--                 align = cc.ui.TEXT_ALIGN_LEFT,
--                 --UILabelType = 1,
--                 font  = "黑体",
--             })
--         valid:setPosition(150,95)
--         bg:addChild(valid)

--          local sDetail = cc.ui.UILabel.new({
--                 text  = serData[MYGOODS_PROPS_PROPS_DESC] or "",
--                 size  = 24,
--                 color = cc.c3b(135,154,192),
--                 align = cc.ui.TEXT_ALIGN_LEFT,
--                 --UILabelType = 1,
--                 font  = "黑体",
--                 dimensions =cc.size(bgWidth - 20,0)
--             })
--         sDetail:setPosition(10,30)
--         bg:addChild(sDetail)
--         -- local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eUse,itemData) end,{scale9 = false})
--         -- btnTime:setPosition(bgWidth - 70,bgHeight/2-27)
--         -- btnTime:setTouchSwallowEnabled(false)
--         -- bg:addChild(btnTime)
        
--             local btnTime = CMButton.new({normal = btnPath,pressed = btnPath2},function ()  self:onMenuCallBack(EnumMenu.eFetch,itemData) end,{scale9 = true})
--             btnTime:setButtonSize(84, 42)
--             btnTime:setButtonLabel("normal", cc.ui.UILabel.new({
--                 text  = "领取",
--                 size  = 26,
--                 color = cc.c3b(255,255,255),
--                 align = cc.ui.TEXT_ALIGN_CENTER,
--                 font  = "黑体",
--             }))
--             btnTime:align(display.CENTER,bgWidth - 52,bgHeight/2)
--             btnTime:setTouchSwallowEnabled(false)
--             bg:addChild(btnTime)
--     end 

--     self.mList:reload() 



-- end
function MyPacketLayer:touchRightListener(event)
	
end
function MyPacketLayer:onMenuCallBack(tag,itemData)
    if tag == EnumMenu.eShop then
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self:getParent():getParent())
    elseif tag == EnumMenu.eUse then
        GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList,{nType = eMatchListGold})
    elseif tag == EnumMenu.ePYJ then
        CMOpen(require("app.GUI.hallview.PrivateHallView"), GameSceneManager:getCurScene(), nil, true, 10)
    elseif tag == EnumMenu.eFetch then
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.DIALYTASK,GameSceneManager:getCurScene(), 0,0)
    end
end
--[[
	网络回调
]]
function MyPacketLayer:httpResponse(tableData,tag,nType)
    --dump(tableData)
    if tag == POST_COMMAND_GetKnapSack then
        self.mLastType = nil
        QDataMyPacketList:Init(tableData,tonumber(nType)) 
        self:createRightList(nType)
    end
end

----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function MyPacketLayer:onHttpDownloadResponse(tag,progress,fileName)
    --print(tag.."=="..progress.."=="..fileName)
    if tag == self.mAllType[2] then
        if self.mActivitySprite[progress] then
            -- self.mActivitySprite[progress]:getChildByTag(101):setTexture(cc.Sprite:create(fileName):getTexture())
            -- if progress == 1 then
            --     self.mPropDetail:getChildByTag(100):setTexture(fileName)
            -- end


            self.mActivitySprite[progress]:setTexture(cc.Sprite:create(fileName):getTexture())
        end
    elseif tag == self.mAllType[1] then
         self.mTickSprite[progress]:setTexture(cc.Sprite:create(fileName):getTexture())
    end
end
return MyPacketLayer