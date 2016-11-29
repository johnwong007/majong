--
-- Author: junjie
-- Date: 2016-01-14 14:02:11
--
--大厅二级框基类

--[[isFullScreen是否全屏]]
local CMCommonLayer = class("CMCommonLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
function CMCommonLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
	self.mAtivityName = self.params.mAtivityName or {
		-- "金币","月卡","道具",
	}
	self.mActivitySprite = {}
	self.mAllSelectNode =  {}
	self.params.size    = self.params.size or cc.size(874,606)	
	self.params.bgType  = self.params.bgType
	self.params.selectIdx = self.params.selectIdx
	self.params.isFullScreen = self.params.isFullScreen
	if self.params.isFullScreen then
		self.params.size = cc.size(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
	end
end
function CMCommonLayer:create()
	self:initUI()
    self:createLeftUI()
    if self.params.selectIdx then
   	 	self:onSelectBtn(self.params.selectIdx)
   	end
end
function CMCommonLayer:initUI()
	local size = self.params.size
	local filename
	if self.params.isFullScreen then
		filename = "picdata/public_new/bg.png"
		local bg = display.newScale9Sprite(filename, 0, 0, size)
		bg:pos(display.cx, display.cy)
		self:addChild(bg)
		self.mBg = display.newNode()
		self.mBg:setContentSize(cc.size(874,606))
		self.mBg:pos(display.cx-874/2, display.cy-606/2)
		self:addChild(self.mBg)
	else
		filename = "picdata/public/tc1_bg.png"
		self.mBg = display.newScale9Sprite(filename, 0, 0, size)
		self.mBg:pos(display.cx, display.cy)
		self:addChild(self.mBg)
	end
	if self.params.titlePath then
		local index = string.find(self.params.titlePath,".png")
		if index then
			local title = cc.Sprite:create(self.params.titlePath)
			title:setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height - title:getContentSize().height/2 + 10 + (self.params.titleOffY or 0))
			self.mBg:addChild(title)
		else
			if string.find(self.params.titleFont, ".fnt") then
				local title = cc.ui.UILabel.new({
			        UILabelType = 1,
			        text  = self.params.titlePath,
			        font  = self.params.titleFont,
			        align = cc.ui.TEXT_ALIGN_CENTER,
			    })
	            title:setAnchorPoint(cc.p(0.5, 0.5))
	            title:setPosition(cc.p(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height-23))
				self.mBg:addChild(title)
			else
				local title = cc.ui.UILabel.new({
			        color = cc.c3b(0, 255, 255),
			        text  = self.params.titlePath,
			        size  = 32,
			        font  = self.params.titleFont or "FZZCHJW--GB1-0.fnt",
			       -- UILabelType = 1,
			    })
			    title:align(display.CENTER,self.mBg:getContentSize().width/2,self.mBg:getContentSize().height-25)
				self.mBg:addChild(title)
			end
		end
	end
	if self.params.bgType then
		local bgPath = string.format("picdata/public/tc1_bg%d.png",self.params.bgType or 3)
		local bg = cc.Sprite:create(bgPath)
		bg:setPosition(self.mBg:getContentSize().width/2, self.mBg:getContentSize().height/2-30)
		self.mBg:addChild(bg)
		self.mSecBg = bg
	else
		self.mSecBg = display.newNode()
		self.mSecBg:setPosition(40, 0)
		self.mSecBg:setContentSize(cc.size(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT-100))
		self.mBg:addChild(self.mSecBg)
	end

	if self.params.isFullScreen then
		local backBtn = CMButton.new({normal = "picdata/public_new/btn_back2.png",
	        pressed = "picdata/public_new/btn_back2.png"},function () self:onMenuClose() end)
	    backBtn:setPosition(45, CONFIG_SCREEN_HEIGHT-40)
	    self:addChild(backBtn)

	    local sprite = cc.ui.UIImage.new("picdata/public_new/mask_foot.png", {scale9=true})
	    sprite:setLayoutSize(CONFIG_SCREEN_WIDTH, 40)
	    sprite:align(display.LEFT_BOTTOM, 0, 0)
	    	:addTo(self)
	else
		local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},handler(self, self.onMenuClose), {scale9 = false})    
	    :align(display.CENTER, self.mBg:getContentSize().width - 30,self.mBg:getContentSize().height-30) --设置位置 锚点位置和坐标x,y
	    :addTo(self.mBg)
	end
end
--[[
	添加左边按钮列表
]]
function CMCommonLayer:createLeftUI()
	-- self.mAtivityName = {
	-- -- -- "帐户信息","修改头像",
	-- -- -- "门票","道具","月卡",
	-- -- -- "自由场","锦标赛","数据分析",
	-- -- -- "牌手分榜","周盈利榜","锦标赛榜",
	-- -- -- "好友申请","我的申请",
	-- "个人日志","系统消息","充值记录","买入申请"}
	local bg = self.mSecBg
	local rectX = 5
	local rectY = 5
	self.mListSize = cc.size(210,bg:getContentSize().height-15)	
	if self.params.activityNameFont then
		rectX = -74
		rectY = -10+5
		self.mListSize = cc.size(290,bg:getContentSize().height-15)	
	end
	self.mActivityList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(rectX, rectY, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchListener))
    :addTo(bg,1)    
  	
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
		local btnImage1 = "picdata/public/btn_tap.png"
		local btnImage2 = "picdata/public/btn_tap2.png"
		if self.params.activityNameFont then
			btnImage1 = "picdata/public_new/tap.png"
			btnImage2 = "picdata/public_new/tap_p.png"
		end
		local btnActivity = cc.Sprite:create(btnImage1)
	    :align(display.CENTER, 0,0) --设置位置 锚点位置和坐标x,y
	    item:addContent(btnActivity)   
	    	 
		local selecthSprite = cc.Sprite:create(btnImage2)
		selecthSprite:setVisible(false)
		selecthSprite:setPosition(selecthSprite:getContentSize().width/2,selecthSprite:getContentSize().height/2)
		btnActivity:addChild(selecthSprite,0,101)

		if self.params.activityNameFont then
			local sDetail = cc.ui.UILabel.new({
			        UILabelType = 1,
			        text  = self.mAtivityName[i],
			        font  = "fonts/tab.fnt",
			        size  = 30,
			        align = cc.ui.TEXT_ALIGN_CENTER,
			    })
            sDetail:setAnchorPoint(cc.p(0.5, 0.5))
            sDetail:setPosition(cc.p(btnActivity:getContentSize().width/2-10,btnActivity:getContentSize().height/2))
			btnActivity:addChild(sDetail,1,102)
			local sDetail1 = cc.ui.UILabel.new({
			        UILabelType = 1,
			        text  = self.mAtivityName[i],
			        font  = "fonts/tab_p.fnt",
			        size  = 30,
			        align = cc.ui.TEXT_ALIGN_CENTER,
			    })
            sDetail1:setAnchorPoint(cc.p(0.5, 0.5))
            sDetail1:setPosition(cc.p(btnActivity:getContentSize().width/2-10,btnActivity:getContentSize().height/2))
			btnActivity:addChild(sDetail1,1,103)
			sDetail1:setVisible(false)
			item:setItemSize(selecthSprite:getContentSize().width, selecthSprite:getContentSize().height)
		else
			local sDetail = cc.ui.UILabel.new({text = self.mAtivityName[i],size = 28,color = cc.c3b(188,201,229),font = GFZZC})	
			sDetail:setPosition(btnActivity:getContentSize().width/2-sDetail:getContentSize().width/2,btnActivity:getContentSize().height/2)
			btnActivity:addChild(sDetail,1,102)
			item:setItemSize(selecthSprite:getContentSize().width, selecthSprite:getContentSize().height+8)
		end		

	   	self.mActivityList:addItem(item)
		self.mActivitySprite[#self.mActivitySprite + 1] = btnActivity

	end	
	self.mActivityList:reload()


	

end
--[[
	listview:触摸事件，回调
]]
function CMCommonLayer:touchListener(event)
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
function CMCommonLayer:checkTouchInSprite_(x, y,itemPos)
	local isTouchList = false	
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then	
			isTouchList = true
			if self.mSelectIndex == i then 
				return 
			end
			self:changeSecBg(i)
			if self.mAllSelectNode[self.mSelectIndex] then 
				self.mAllSelectNode[self.mSelectIndex]:setVisible(false) 
			end
			self.mSelectIndex = i
			if self.mAllSelectNode[self.mSelectIndex] then 
				self.mAllSelectNode[self.mSelectIndex]:setVisible(true) 
			else	
				self:onMenuSwitch(i)
			end
			
		else
			if self.params.activityNameFont then
				self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
				self.mActivitySprite[i]:getChildByTag(103):setVisible(false)
				self.mActivitySprite[i]:getChildByTag(102):setVisible(true)
			else
				self.mActivitySprite[i]:getChildByTag(102):disableEffect()
				self.mActivitySprite[i]:getChildByTag(102):setColor(cc.c3b(188,201,229))
				self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
			end
		end
	end	
	
	if not isTouchList then
		if self.params.activityNameFont then
			self.mActivitySprite[self.mSelectIndex]:getChildByTag(101):setVisible(true)
			self.mActivitySprite[self.mSelectIndex]:getChildByTag(103):setVisible(true)
			self.mActivitySprite[self.mSelectIndex]:getChildByTag(102):setVisible(false)
		else
			self.mActivitySprite[self.mSelectIndex]:getChildByTag(102):setColor(cc.c3b(255,238,204))
			self.mActivitySprite[self.mSelectIndex]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
			self.mActivitySprite[self.mSelectIndex]:getChildByTag(101):setVisible(true)
		end
	end
end
--[[
	初始化切换到哪一个按钮选项
]]
function CMCommonLayer:onSelectBtn(i)
	self.mSelectIndex = i
	self:changeSecBg(i)
	
	local RewardLayer,params = self:onMenuSwitch(i)
	
	if RewardLayer then 
		local RewardLayer = RewardLayer.new(params)
		self.mAllSelectNode[i] = RewardLayer
		RewardLayer:create()
		self.mBg:addChild(RewardLayer)
	end
end
--[[
	添加5张卡牌信息
]]
function CMCommonLayer:addCard(cardData)
	local node = cc.Node:create()
    local data = string.split(cardData,",")
    if #data < 5 then return node end
    
	local colorStr = {[0] = "s",[1] = "h",[2] = "c",[3] = "d"}
	--local str = "8s"
	local posx = 0
	for i = 1,#data do
		local num   = string.sub(data[i],1,1)
		local color = string.sub(data[i],2,2)
		local path = ""
		for i,v in pairs(colorStr) do 
			if v == color then
				if num == "T" then num = 10 end
				path = string.format("picdata/db_poker/%s_%s.png",i,num)
				break
			end
		end
		local card = cc.Sprite:create(path)
		card:setScale(0.5)
		card:setPosition(posx,0)
		node:addChild(card)
		posx = posx + card:getBoundingBox().width + 2
	end
	return node
end
function CMCommonLayer:onMenuClose(sender, event)
	CMClose(self)
end
--[[
	按照功能按钮更改背景
]]
function CMCommonLayer:changeSecBg(idx)	
	if self.params.activityNameFont then
		self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
		self.mActivitySprite[idx]:getChildByTag(103):setVisible(true)
		self.mActivitySprite[idx]:getChildByTag(102):setVisible(false)
	else
		self.mActivitySprite[idx]:getChildByTag(102):setColor(cc.c3b(255,238,204))
		-- self.mActivitySprite[idx]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
		self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
	end
	local bgType = nil
	if self.mAtivityName[idx] == "门票" then
		-- bgType = 3
	elseif self.mAtivityName[idx] == "道具" then
		-- bgType = 5
	elseif self.mAtivityName[idx] == "月卡" then
		-- bgType = 3
	elseif self.mAtivityName[idx] == "帐户信息" then
		-- bgType = 3
		self.mSecBg:setVisible(false)
	elseif self.mAtivityName[idx] == "修改头像" then
		bgType = 4
		self.mSecBg:setVisible(false)
	end
	if bgType then
		local bgPath = string.format("picdata/public/tc1_bg%d.png",bgType or 3)
		self.mSecBg:setTexture(bgPath)
	end
end
--[[
	按钮切换回调
]]
function CMCommonLayer:onMenuSwitch(idx)	
	local layerPopup = nil
	local params      = {}
	if self.mAtivityName[idx] == "帐户信息" then
		layerPopup = require("app.GUI.personCenter.AccountEditLayer")	
	elseif self.mAtivityName[idx] == "修改头像" then
		layerPopup = require("app.GUI.personCenter.HeadEditLayer")
	elseif self.mAtivityName[idx] == "道具" then
		layerPopup = require("app.GUI.personCenter.MyPacketLayer")
		params.nType= 2
	elseif self.mAtivityName[idx] == "门票" then	
		layerPopup = require("app.GUI.personCenter.MyPacketLayer")
		params.nType= 1
	elseif self.mAtivityName[idx] == "月卡" then
		layerPopup = require("app.GUI.personCenter.MyPacketLayer")
		params.nType= 3
	elseif self.mAtivityName[idx] == "自由场" then
		layerPopup = require("app.GUI.personCenter.PersonDataLayer")
		params.nType = 1
	elseif self.mAtivityName[idx] == "锦标赛" then
		layerPopup = require("app.GUI.personCenter.PersonDataLayer")
		params.nType = 2
	elseif self.mAtivityName[idx] == "数据分析" then
		layerPopup = require("app.GUI.personCenter.PersonDataLayer")
		params.nType = 3
	elseif self.mAtivityName[idx] == "盲注级别明细" then
		layerPopup = require("app.GUI.personCenter.PersonDataLayer")
		params.nType = 4
	elseif self.mAtivityName[idx] == "牌手分榜" then
		layerPopup = require("app.GUI.ranking.RankLayer")
		params.nType = 1
	elseif self.mAtivityName[idx] == "周盈利榜" then
		layerPopup = require("app.GUI.ranking.RankLayer")
		params.nType = 2
	elseif self.mAtivityName[idx] == "锦标赛榜" then
		layerPopup = require("app.GUI.ranking.RankLayer")
		params.nType = 3
	elseif self.mAtivityName[idx] == "好友申请" then
		layerPopup = require("app.GUI.friends.FriendApplyLayer")
		params.nType= "APPLY_FRIEND"
	elseif self.mAtivityName[idx] == "我的申请" then
		params.nType= "OTHER_FRIEND"
		layerPopup = require("app.GUI.friends.FriendApplyLayer")
		params.nType= 2
	elseif self.mAtivityName[idx] == "个人日志" then
		layerPopup = require("app.GUI.notice.NoticeLayer")
		params.nType= 2
	elseif self.mAtivityName[idx] == "系统消息" then
		layerPopup = require("app.GUI.notice.NoticeLayer")
		params.nType= 1
	elseif self.mAtivityName[idx] == "充值记录" then
		layerPopup = require("app.GUI.notice.NoticeLayer")
		params.nType= 3
	elseif self.mAtivityName[idx] == "买入申请" then
		layerPopup = require("app.GUI.notice.NoticeLayer")
		params.nType= 4		
	elseif self.mAtivityName[idx] == "VP" then	
		layerPopup = require("app.GUI.personCenter.DataExplainLayer")
	elseif self.mAtivityName[idx] == "PFR" then	
		layerPopup = require("app.GUI.personCenter.DataExplainLayer")
	elseif self.mAtivityName[idx] == "AF" then	
		layerPopup = require("app.GUI.personCenter.DataExplainLayer")
	end
	if not layerPopup then return end
	params.isNotAdd = true
	self.mAllSelectNode[idx] = CMOpen(layerPopup, self.mBg, params, 0)
	return layerPopup,params
end
return CMCommonLayer