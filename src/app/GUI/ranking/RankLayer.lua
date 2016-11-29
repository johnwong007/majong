--
-- Author: junjie
-- Date: 2015-11-30 16:02:34
--
--- 排行榜视图层，基于CMCommonLayer大厅二级框基类

local MusicPlayer = require("app.Tools.MusicPlayer")
local RankLayer = class("RankLayer",function() 
	return display.newNode()
end)
local CMColorLabel     = require("app.Component.CMColorLabel")
local myInfo = require("app.Model.Login.MyInfo")
local SchedulerPool = require("app.Tools.SchedulerPool")
local QDataRankList = nil
require("app.Network.Http.DBHttpRequest")
require("app.Tools.StringFormat")
local TAG = {
	HEADBG = 100,
	VIP    = 101,
	LEVEL  = 102,

}
local COLOR = {
	[1] = cc.c3b(0,174,255),
	[2] = cc.c3b(255,237,161),
	[3] = cc.c3b(170,78,63),
}
local rankUpPath     ="picdata/rank/point_up.png"
local rankDownPath   ="picdata/rank/point_down.png"
local rankNoChangePath="picdata/rank/rankNoChange.png"
local headBGManPath  = "picdata/rank/headPicBGMan.png"
local headBGWomanPath="picdata/rank/headBGWomen.png"
function RankLayer:ctor(params)
	self:setNodeEventEnabled(true)
	QDataRankList = require("app.Logic.Datas.QDataRankList"):Instance()--QManagerData:getCacheData("QDataRankList")
	self.params = params or {}
	self.params.nType = self.params.nType or 1	--1、牌手分榜、周盈利榜、锦标赛榜
	self.mTableBar = {"LEVEL","PROFIT","POINT"}
	self.mActivitySprite = {}
	self.mListPosY       = 50
	--self.params.size = self.params.size or cc.size(840,520)
	self.mListHeight     = 0
	self.mAllItemHeight  = 0
	self.mRequestNum     = 15
	self.mIsRequest      = false
	self.m_schedulerPool = SchedulerPool.new()
end
function RankLayer:create()
	self:setContentSize(600,500)
    self:setPosition(300,0)
    self.mBg = self
	self:initUI()
end
function RankLayer:relaese()
	QDataRankList:removeMsgData()
	self.mBg 			 = nil
	self.mList           = nil
	self.mActivitySprite = {}
	self.params          = {}
end
function RankLayer:onExit()
	-- QManagerData:removeCacheData("QDataRankList")
	self:removeMemory()
	self:relaese()
end

---
-- 移除排行榜缓存
--
-- @return null
--
function RankLayer:removeMemory()
    local memoryPath = {}
    memoryPath[1] = require("app.GUI.allrespath.RankPath")
    -- dump(memoryPath)
    for j = 1,#memoryPath do 
        for i,v in pairs(memoryPath[j]) do
            display.removeSpriteFrameByImageName(v)
        end
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function RankLayer:initUI()
	self.m_btnShare = CMButton.new({normal = "picdata/personalCenter/btn_6_wx.png",pressed = "picdata/personalCenter/btn_6_wx2.png"},handler(self, self.onShareWechat), {scale9 = false})    
    	:align(display.CENTER, -240, self.mBg:getContentSize().height + 50)
    	:addTo(self.mBg, 2)
    	:hide()

    --self:createButtonGroup() 
    self:createRightList(self.params.nType)
end

function RankLayer:onShareWechat()
	local typeStr = ""
	if self.params.nType == 1 then
		typeStr = "牌手分榜"
	elseif self.params.nType == 2 then
		typeStr = "周盈利榜"
	elseif self.params.nType == 3 then
		typeStr = "锦标赛榜"
	end
	local selfData = QDataRankList:getMsgFirstData(self.params.nType) or {}
	local rankLevel = tonumber(selfData[USER_RANKING] or 1)
	local data = {
		title = string.format(lang_WECHATSHARE_RANK,typeStr,rankLevel) or "德堡德州扑克",
		content = string.format(lang_WECHATSHARE_RANK,typeStr,rankLevel),
		nType = 1,
		url = "http://www.debao.com",
	}
	QManagerPlatform:shareToWeChat(data)
end

--[[
	测试按钮
]]
function RankLayer:createButtonGroup()

	local bg = cc.Sprite:create("picdata/public/btn_1_menu.png")
	bg:setScaleX(1.53)
	bg:setPosition(self.mBg:getContentSize().width/2,440)
	self.mBg:addChild(bg)

	self.menu = cc.Sprite:create("picdata/public/btn_1_menu2.png")
	--self.menu:setPosition(self.mBg:getContentSize().width/2,440)
	self.mBg:addChild(self.menu)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/rank/w_menu_psf2.png",off_pressed = "picdata/rank/w_menu_psf.png", on = "picdata/rank/w_menu_psf.png",}))
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/rank/w_menu_zyl2.png",off_pressed = "picdata/rank/w_menu_zyl.png", on = "picdata/rank/w_menu_zyl.png",}))
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/rank/w_menu_jbs2.png",off_pressed = "picdata/rank/w_menu_jbs.png", on = "picdata/rank/w_menu_jbs.png",}))
   
    :setButtonsLayoutMargin(0, 30, 0, 18)
    :onButtonSelectChanged(function(event)
        local group = self.mGroup:getButtonAtIndex(event.selected)
        self.menu:setPosition(group:getPositionX()+257,group:getPositionY()+620)
        self:updateMySelfData(event.selected)
        self:createRightList( event.selected)
        self.mLastType =  event.selected
        MusicPlayer:getInstance():playButtonSound()
    end)
    :align(display.LEFT_TOP, 257,620)
    :addTo(self.mBg,1)
     self.mGroup = group
    group:getButtonAtIndex(1):setButtonSelected(true)
end

---
-- 检测自身排名
--
-- @param nType 排行类型
-- @return null
--
function RankLayer:checkMyselfRank(nType)
	local selfData = QDataRankList:getMsgFirstData(nType) or {}
	-- dump(selfData)

	local rankLevel = tonumber(selfData[USER_RANKING] or 1) 
	if rankLevel >= 1000 then
		self.m_btnShare:hide()
	else
		self.m_btnShare:show()
	end
	if rankLevel == 1 then
		local minci = cc.Sprite:create("picdata/rank/no1.png")
		minci:setPosition(243,484)
		self.mBg:addChild(minci)

		local btnShare = CMButton.new({normal = "picdata/personalCenter/btn_6_wx.png",pressed = "picdata/personalCenter/btn_6_wx2.png"},function () self:onMenuCallBack() end, {scale9 = false})    
    	:align(display.CENTER, minci:getContentSize().width - 70,minci:getContentSize().height/2)
    	:addTo(minci)

		self.mListHeight = 420
		self.mListPosY = 33
		self.m_btnShare:hide()
	elseif rankLevel <= 15 or rankLevel >=1000 then
		self:createMySelfItem(nType,rankLevel)
		self.mListHeight = 380
		self.mListPosY = 136
	else
		DBHttpRequest:getRankListInfo(handler(self, function(obj,tableData,tag) self:httpResponse(tableData,tag,"MySelf") end),self.mTableBar[nType],5,rankLevel - 3)
		--self:createMyself(nType,rankLevel)
		self.mListHeight = 294
		self.mListPosY = 220
	end
end

--[[
	排名15-1000
]]
function RankLayer:createMyself(nType,tableData)
	table.remove(tableData,1)
	local selfData = QDataRankList:getMsgFirstData(nType) or {}
	
	local bg = cc.Sprite:create("picdata/rank/bg_i_b.png")
	local bgwidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height
	bg:setPosition(243,125)
	self.mBg:addChild(bg)

	local posy = 154
	local text,nameText = ""

	local headPath = headBGManPath
	if selfData[USER_SEX] == "女" then
		headPath = headBGWomanPath
	end
	local headBG = cc.Sprite:create(headPath)
	headBG:setPosition(60,bgHeight/2)
	bg:addChild(headBG)


	local headPath = selfData[USER_PORTRAIT] 
	local headPic = CMCreateHeadBg(headPath,cc.size(65,65))
    headPic:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height/2)
    headBG:addChild(headPic)

	for i= 1 ,#tableData do
		if i > 5 then
			return
		end
		local serData = tableData[i]
		local offy = 28
		local size = 22
		if i == 2 or i == 3 then offy = 32 end
		if i == 3 then
			size = 30
			rankText = string.format("%s#07#%d",serData[USER_RANKING],size)
			nameText = string.format("%s#06#%d",CMStringToString(serData[USER_NAME],22,true),size)

			local pointPath = rankNoChangePath
			if selfData[RANK_DRIFT] == "UP" then 
				pointPath = rankUpPath
			elseif selfData[RANK_DRIFT] == "DOWN" then
				pointPath = rankDownPath
			end
			local point = cc.Sprite:create(pointPath)
			point:setPosition(bgwidth - point:getContentSize().width,posy)
			bg:addChild(point)

		else
			rankText = string.format("%s#01#%d",serData[USER_RANKING],size)
			nameText = string.format("%s#01#%d",CMStringToString(revertPhoneNumber(serData[USER_NAME]),22,true),size)
		end

		local rank = CMColorLabel.new({text = rankText})
		rank:setPosition(130 - rank:getContentWidth()/2,posy)
		bg:addChild(rank,0)

		local name = CMColorLabel.new({text = nameText})
		name:setPosition(200,posy)
		bg:addChild(name,0)

		local score = cc.ui.UILabel.new({
	        text  = StringFormat:FormatDecimals(serData[MONEY_BALANCE] or 0),
	        size  = size,
	        color = COLOR[nType],
	        align = cc.ui.TEXT_ALIGN_RIGHT,
	        --UILabelType = 1,
			font  = "Arail",
	    })
		score:setAnchorPoint(1,0.5)
		score:setPosition(bgwidth - 60,posy)
		bg:addChild(score)


		posy = posy - offy
	end
end
function RankLayer:createMySelfItem(nType,rankLevel)
    local imgNoPath      = "picdata/rank/rank_no_2.png"
    local levelPath      ="picdata/friend/userLevelBg.png"

    local serData = QDataRankList:getMsgFirstData(nType) or {}
	local bg = cc.Sprite:create("picdata/rank/bg_i_s.png")
	local bgwidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height
	bg:setPosition(243,82)
	self.mBg:addChild(bg)

	local headPath = headBGManPath
	if serData[USER_SEX] == "女" then
		headPath = headBGWomanPath
	end
	local headBG = cc.Sprite:create(headPath)
	headBG:setPosition(45,bgHeight/2+3)
	bg:addChild(headBG,0,TAG.HEADBG)

	local headPath = serData[USER_PORTRAIT] 
	local headPic = CMCreateHeadBg(headPath,cc.size(65,65))
    headPic:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height/2)
    headBG:addChild(headPic)


	local score = cc.ui.UILabel.new({
	        text  = StringFormat:FormatDecimals(serData[MONEY_BALANCE] or 0),
	        size  = 32,
	        color = COLOR[nType],
	        align = cc.ui.TEXT_ALIGN_RIGHT,
	        --UILabelType = 1,
    		font  = "Arail",
	    })
	score:setAnchorPoint(1,0.5)
	score:setPosition(bgwidth - 60, bgHeight/2)
	bg:addChild(score)
	if rankLevel < 1000 then
		local otherPlayerData = QDataRankList:getMsgUserData(nType,rankLevel-1) --获取上一个玩家数据
		name = CMColorLabel.new({text = string.format("%s #07#32;还差%s分能前进一名#01#24",rankLevel,tonumber(otherPlayerData[MONEY_BALANCE]) - tonumber(serData[MONEY_BALANCE]))})
	else
		name = CMColorLabel.new({text = string.format("未进榜 #07#32;1000+#01#24")})
	end

	name:setPosition(100,bgHeight/2)
	bg:addChild(name,0)
 	local vipLevel 
    if not serData["VIP"] or tonumber(serData["VIP"]) == 0 then
    	vipLevel = cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",1))
    	vipLevel:setVisible(false)
	else
		vipLevel = cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",serData["VIP"]))
	end
	vipLevel:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height-5)
	headBG:addChild(vipLevel,0,TAG.VIP)
	local levelBg = cc.Sprite:create(levelPath)
	levelBg:setPosition(55,7)
	headBG:addChild(levelBg)
	local level = cc.ui.UILabel.new({
	        text  = serData[USER_LEVEL] or "",
	        size  = 18,
	        color = cc.c3b(0,0,0),
	        --UILabelType = 1,
    		font  = "黑体",
	    })
	level:setPosition(levelBg:getPositionX()-level:getContentSize().width/2,levelBg:getPositionY())
	headBG:addChild(level,0,TAG.LEVEL)

	local pointPath = rankNoChangePath
	if serData[RANK_DRIFT] == "UP" then 
		pointPath = rankUpPath
	elseif serData[RANK_DRIFT] == "DOWN" then
		pointPath = rankDownPath
	end
	local point = cc.Sprite:create(pointPath)
	point:setPosition(bgwidth - point:getContentSize().width,bgHeight/2)
	bg:addChild(point)

end
--[[
	右边排名列表
]]
function RankLayer:createRightList( nType)
	-- if nType == self.mLastType then return end	
	local cfgData = QDataRankList:getMsgData(nType) 
	local nDelayTime = 0
	if nType == 1 then
		nDelayTime = 0.3
	end
  	if not cfgData then 
  		self.m_schedulerPool:delayCall(handler(self, function()
  				DBHttpRequest:getRankListInfo(handler(self, self.httpResponse),self.mTableBar[nType],self.mRequestNum,0)
  			end), nDelayTime)
  		return
  	end 
  	
  	self:checkMyselfRank(nType)
  	self.mLastType = nType
	self.mActivitySprite ={}
	self.mListhHeight    = 0
	if self.mList then self.mList:removeFromParent() self.mList = nil end
	-- body
	self.mListSize = cc.size(595,self.mListHeight) 
	self.mList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(-53, self.mListPosY, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
  	
  

	for i = 1,#cfgData-1 do  
		self:createPageItem(i,cfgData[i+1],nType)		
	end	

	self.mList:reload()	
end
local backPath       = "picdata/rank/bg_list.png"
local bcakPathSmall  = "picdata/rank/bg_list_s.png"
local imgNoPath      = "picdata/rank/rank_no_%d.png"
local imgNoBgPath    = "picdata/rank/rank_no_4.png"
local levelPath      ="picdata/friend/userLevelBg.png"
function RankLayer:createPageItem(i,cfgData,nType)
	local item = self.mList:newItem()		
	local bg = self:createPageNode(i,cfgData,nType)	
	local itemSize = cc.size(bg:getContentSize().width + 200, bg:getContentSize().height+5)
	item:addContent(bg)
	item:setItemSize(self.mListSize.width,itemSize.height)   

	self.mAllItemHeight = self.mAllItemHeight + itemSize.height
	self.mList:addItem(item)
end
function RankLayer:createPageNode(i,cfgData,nType)
 
   local imgPath        = nil
   local scoreColor     = COLOR[nType]
   -- if nType == 2 then
   -- 		imgPath         = "picdata/rank/zyl_icon.png"
   -- elseif nType == 3 then
   -- 		imgPath         = "picdata/rank/jbs_icon.png"
   -- end
    
  
    local serData = cfgData or {}
    local headScale= 1
    local NoPath = ""
    local posx   = 70
    if i < 4 then 
    	NoPath = string.format(imgNoPath,i)
    else
    	NoPath  = imgNoBgPath
    	backPath = bcakPathSmall
    	headScale = 0.8
    	posx     = 65
    end
    local bg = cc.Node:create()
	local sp   = cc.Sprite:create(backPath)
	local bgwidth = sp:getContentSize().width
	local bgHeight= sp:getContentSize().height
	sp:setPosition(bgwidth/2+33,bgHeight/2)
	bg:addChild(sp)

	bg:setContentSize(bgwidth,bgHeight)
	if i < 4 then
        local rankNo = cc.Sprite:create(NoPath)
        rankNo:setPosition(-10,bgHeight/2)
        bg:addChild(rankNo,1)
    else
    	 
    	local rankNo = cc.Sprite:create(imgNoBgPath)
        rankNo:setPosition(-10,bgHeight/2)
        bg:addChild(rankNo)

        local rankNoTxt = cc.ui.UILabel.new({
	        text  = i,
	        size  = 26,
	        color = cc.c3b(199,225,255),
    		font  = "FZZCHJW--GB1-0",
	    })
	    rankNoTxt:setPosition(rankNo:getContentSize().width/2-rankNoTxt:getContentSize().width/2,rankNo:getContentSize().height/2+3)
	    rankNo:addChild(rankNoTxt)
	end
	
	
	local score = cc.ui.UILabel.new({
	        text  = StringFormat:FormatDecimals(serData[MONEY_BALANCE] or 0),
	        size  = 32,
	        color = COLOR[nType],
	        align = cc.ui.TEXT_ALIGN_RIGHT,
	        --UILabelType = 1,
    		font  = "Arail",
	    })
	score:setAnchorPoint(1,0.5)
	score:setPosition(bgwidth - 30, bgHeight/2)
	bg:addChild(score)

	-- if imgPath then
	-- 	local img = cc.Sprite:create(imgPath)
	-- 	img:setPosition(score:getPositionX()+50,bgHeight/2)
	-- 	bg:addChild(img)
	-- end
	local pointPath = rankNoChangePath
	if serData[RANK_DRIFT] == "UP" then 
		pointPath = rankUpPath
	elseif serData[RANK_DRIFT] == "DOWN" then
		pointPath = rankDownPath
	end
	local point = cc.Sprite:create(pointPath)
	point:setPosition(bgwidth ,bgHeight/2)
	bg:addChild(point)

	local name = cc.ui.UILabel.new({
	        text  = CMStringToString(revertPhoneNumber(serData[USER_NAME]),22,true),
	        size  = 24,
	        color = cc.c3b(255,255,255),
	        x     = 130,
	        y     = bgHeight/2,
    		font  = "黑体",
	    })
	name:setAnchorPoint(0,0.5)
	bg:addChild(name)

	local headPath = headBGManPath
	if serData[USER_SEX] == "女" then
		headPath = headBGWomanPath
	end
	local headBG = cc.Sprite:create(headPath)
	headBG:setScale(headScale)
	headBG:setPosition(posx,bgHeight/2)
	bg:addChild(headBG,0,TAG.HEADBG)

	local headPath = serData[USER_PORTRAIT] 
	local headPic = CMCreateHeadBg(headPath,cc.size(65,65))
    headPic:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height/2)
    headBG:addChild(headPic)

    local vipLevel 
    if not serData["VIP"] or tonumber(serData["VIP"]) == 0 then
    	vipLevel = cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",1))
    	vipLevel:setVisible(false)
	else
		vipLevel = cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",serData["VIP"]))
	end
	vipLevel:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height-5)
	headBG:addChild(vipLevel,0,TAG.VIP)


	local levelBg = cc.Sprite:create(levelPath)
	levelBg:setPosition(55,7)
	headBG:addChild(levelBg)
	local level = cc.ui.UILabel.new({
	        text  = serData[USER_LEVEL] or "",
	        size  = 18,
	        color = cc.c3b(0,0,0),
	        --UILabelType = 1,
    		font  = "黑体",
	    })
	level:setPosition(levelBg:getPositionX()-level:getContentSize().width/2,levelBg:getPositionY())
	headBG:addChild(level,0,TAG.LEVEL)

	self.mActivitySprite[#self.mActivitySprite+1] = bg

	return bg
end
function RankLayer:touchRightListener(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos)
	 else
		if name == "began" then
	        self.touchBeganX = x
	        self.touchBeganY = y
	       return true
	    elseif name == "moved" then

	    else
	   		
	    	if event.name == "itemAppearChange" then
	    		self.mLastDisItem = event.itemPos
	    	elseif event.name == "itemDisappear" then
	    		
	    		local offset =  self.mRequestNum - 6--event.itemPos - (self.mLastDisItem or 0)
	    		if event.itemPos >= 9 then
	    			self.mItemChange = 1   --向下
    			else
    				self.mItemChange = -1 
    			end
	    	end
	    	if event.name == "scrollEnd" and self.mItemChange ~= -1 then
	    		local nType = self.params.nType
	    	   local curRankNum = QDataRankList:getMsgLength(nType) or 1
	    	   if curRankNum ~= 0 and curRankNum <= (105 - self.mRequestNum) and (curRankNum%self.mRequestNum) == 0 then
	    	   		if self.mIsRequest then return end
	    	   		local requestNum = self.mRequestNum
	    	   		if curRankNum == 105 - self.mRequestNum then
	    	   			requestNum = 10
	    	   		end
	    	   		self.mIsRequest = true
	    	   		DBHttpRequest:getRankListInfo(handler(self, self.httpResponse),self.mTableBar[nType],requestNum,curRankNum)
	    	   end

		    end
	    end	    
	 end
	
end

function RankLayer:checkTouchInSprite_(x, y,itemPos)	
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then								
			local FriendShowLayer = require("app.GUI.friends.FriendShowLayer").new({nType = self.mLastType,index = i})
			CMOpen(FriendShowLayer,self:getParent(),nil,0)
		else
			--self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
		end
	end	
end

--[[更新自身数据]]
function RankLayer:updateMySelfData(nType)
	local selfData = QDataRankList:getMsgFirstData(nType)
	if not selfData then return end
	local imgPath = nil
	local rankColor

	if nType == 1 then
		scoreColor      = cc.c3b(0,174,255)
   		rankColor       = cc.c3b(31,36,43)
	elseif nType == 2 then
   		imgPath         = "picdata/rank/zyl_icon.png"
   		scoreColor      = cc.c3b(255,237,161)
   		rankColor       = cc.c3b(0,0,0)
   elseif nType == 3 then
   		imgPath         = "picdata/rank/jbs_icon.png"
   		scoreColor      = cc.c3b(255,237,161)
   		rankColor       = cc.c3b(0,255,210)
   end

   local pointPath = rankNoChangePath
	if selfData[RANK_DRIFT] == "UP" then 
		pointPath = rankUpPath
	elseif selfData[RANK_DRIFT] == "DOWN" then
		pointPath = rankDownPath
	end
	self.mMyPoint:setTexture(cc.Sprite:create(pointPath):getTexture())	
   if imgPath then
   		self.mMyIcon:setVisible(true)
   		self.mMyIcon:setTexture(cc.Sprite:create(imgPath):getTexture())
   else
   		self.mMyIcon:setVisible(false)
   end

	self.mMyScore:setString(tonumber(selfData[MONEY_BALANCE]))
	self.mMyScore:setColor(scoreColor)
	if tonumber(selfData[USER_RANKING]) >= 1000 then
		self.mMyRank:setString("暂无排名,加油!")
	else
		self.mMyRank:setString(selfData[USER_RANKING])
	end
	self.mMyRank:setColor(rankColor)
	self.mMyRank:setPositionX(self.mMyRank:getParent():getContentSize().width/2-self.mMyRank:getContentSize().width/2)
end
function RankLayer:onMenuCallBack()
	local data       = {title = lang_WECHATSHARE_TITLE,content = lang_WECHATSHARE_FRIEND,nType = 1,url = "http://www.debao.com"}
	QManagerPlatform:shareToWeChat(data) 
end
--[[
	网络回调
]]
function RankLayer:httpResponse(tableData,tag,nType)
	
	if tag == POST_COMMAND_BALANCERANKLISTINFO or tag == POST_COMMAND_LEVELRANKLISTINFO then	
		self:updateListData(tableData,1,nType)
	elseif tag == POST_COMMAND_PROFITRANKLISTINFO or tag == POST_COMMAND_PROFITRANKLIST then
		self:updateListData(tableData,2,nType)
	elseif tag == POST_COMMAND_POINTRANKLISTINFO or tag == POST_COMMAND_CHAMPIONRANKLIST then 
		self:updateListData(tableData,3,nType)
	elseif tag == POST_COMMAND_GET_VIP_INFO then
		QDataRankList:updateMsgData(tableData,nType,"VIP")
		local serData = QDataRankList:getMsgData(nType)
		for i = 1,#self.mActivitySprite do
			local vipLevel = self.mActivitySprite[i]:getChildByTag(TAG.HEADBG):getChildByTag(TAG.VIP)
			if serData[i+1]["VIP"] and tonumber(serData[i+1]["VIP"]) > 0 then
				vipLevel:setTexture(cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",serData[i+1]["VIP"])):getTexture())
				vipLevel:setVisible(true)
			else
				vipLevel:setVisible(false)
			end
		end
	elseif tag == POST_COMMAND_getUserListLevel then
		QDataRankList:updateMsgData(tableData,nType,USER_LEVEL)
		local serData = QDataRankList:getMsgData(nType)
		for i = 1,#self.mActivitySprite do
			local level = self.mActivitySprite[i]:getChildByTag(TAG.HEADBG):getChildByTag(TAG.LEVEL)
			level:setString(serData[i+1][USER_LEVEL])
			level:setPositionX(55-level:getContentSize().width/2)
		end
	end
	
end
--[[
	添加列表数据
]]
function RankLayer:addListData(tableData,nType)
	--dump(tableData)

	local height = self.mAllItemHeight
	local allRankNum = QDataRankList:getMsgLength(nType) or 1
	local cfgData = QDataRankList:getMsgData(nType)
	local nextRankNum = allRankNum - #tableData + 2
	local addRankNum  =  nextRankNum + #tableData - 2
	for i = nextRankNum,addRankNum  do 
		self:createPageItem(i,cfgData[i+1],nType)		
	end	
	self.mList:reload()
	self.mList:moveItems(1,addRankNum,0,height)
end
--[[
	更新列表数据
]]
function RankLayer:updateListData(tableData,nType,exParams)
	self.mLastType = nType	
	if tableData == -1 then self.mIsRequest = false return end
	if exParams == "MySelf" then self:createMyself(nType,tableData) return end  		--请求前后5名数据
	QDataRankList:Init(tableData,nType) 
	local userList = QDataRankList:getMsgUserList(nType)
	if userList then 
		DBHttpRequest:getVipInfo(handler(self, function(obj,tableData,tag) self:httpResponse(tableData,tag,nType) end),userList)
		DBHttpRequest:getUserListLevel(handler(self, function(obj,tableData,tag) self:httpResponse(tableData,tag,nType) end),userList)
	end
	--self:updateMySelfData(nType)
	
	if self.mIsRequest == true then
		self:addListData(tableData,nType)	
		self.mIsRequest = false	
	else
		self:createRightList(nType)
	end
end

function RankLayer:onCleanup()
	self.m_schedulerPool:clearAll()
end

return RankLayer