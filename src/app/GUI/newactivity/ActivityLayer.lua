--
-- Author: junjie
-- Date: 2015-12-09 10:07:03
--
--活动
local MusicPlayer = require("app.Tools.MusicPlayer")
local CMCommonLayer = require("app.Component.CMCommonLayer")
local ActivityLayer = class("ActivityLayer",CMCommonLayer)
local CMButton = require("app.Component.CMButton")
local NetCallBack = require("app.Network.Http.NetCallBack")
local GameLayerManager  = require("app.GUI.GameLayerManager")
local myInfo = require("app.Model.Login.MyInfo")
local QDataActivityList = nil
require("app.Network.Http.DBHttpRequest")
local TAG = 
{
	ACTIVITY_NAME   = 101,
	ACTIVITY_SELECT = 102,
}
local EnumMenu = 
{	

}
function ActivityLayer:ctor(params)
	self:setNodeEventEnabled(true)

	QDataActivityList = QManagerData:getCacheData("QDataActivityList")
	self.mLeftSprite = {}
	self.mActivitySprite = {}
	self.mCurFriendIndex = 0
	self.mMaxFriendIndex = 0 
	self.mLastSelect     = 1
end
function ActivityLayer:create()
    ActivityLayer.super.ctor(self,{titlePath = "picdata/activity/titile_hdzx.png"}) 
    ActivityLayer.super.initUI(self)
    self:createUI( )
end
function ActivityLayer:onEnter()
	self.m_bSoundEnabled = true
end
function ActivityLayer:onExit()
	self:removeMemory()
	-- QManagerData:removeCacheData("QDataActivityList")
end
function ActivityLayer:removeMemory()
    local memoryPath = {}
    memoryPath[1] = require("app.GUI.allrespath.ActivityPath")
    -- dump(memoryPath)
    for j = 1,#memoryPath do 
        for i,v in pairs(memoryPath[j]) do
            display.removeSpriteFrameByImageName(v)
        end
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function ActivityLayer:createUI()
	self.m_bSoundEnabled = false
	DBHttpRequest:getActivityListNew(function(tableData,tag) self:httpResponse(tableData,tag) end)
 	local bgWidth = self.mBg:getContentSize().width
    local bgHeight= self.mBg:getContentSize().height

    local activityBg = cc.Sprite:create("picdata/activity/activityBack.png")
    activityBg:setScaleX(584/activityBg:getContentSize().width)
    activityBg:setScaleY(418/activityBg:getContentSize().height)
    activityBg:setPosition(self.mBg:getContentSize().width/2 + 120,bgHeight/2-15)
    self.mBg:addChild(activityBg)

    self.mSecBg = cc.Sprite:create("picdata/activity/activityRightBack.png")
	self.mSecBg :setPosition(140,bgHeight/2-15)
	self.mBg:addChild(self.mSecBg )

	local sTipMessage = QManagerPlatform:getActivityTips()
	local sTips = cc.ui.UILabel.new({
	        text  = sTipMessage,
	        color = cc.c3b(135,154,192),
	        size  = 22,
	    })
	    sTips:setPosition(bgWidth/2-sTips:getContentSize().width/2,45)
    	self.mBg:addChild(sTips)
	--self:createRightList( )
	--self:createLeftNode()
end
function ActivityLayer:createRightList( )
	local cfgData = QDataActivityList:getMsgData()
 	if not cfgData then
 		DBHttpRequest:getActivityListNew(function(tableData,tag) self:httpResponse(tableData,tag) end)
 		return
 	end
 	self.mCfgData = cfgData
 	if self.mList then self.mList:removeFromParent() self.mList = nil end
 	self.mActivitySprite = {}
	local rightSize = cc.size(250,400)	
	self.mList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(15, 90, rightSize.width, rightSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg)    
	
	local backPath  = "picdata/activity/btn_activity.png"
    local selectPath= "picdata/activity/btn_select.png"
    local namePath  = "picdata/activity/btn_first.png"
	for i = 1,#cfgData do
		-- 	cfgData = {}
		-- for i = 1,5 do
		local serData = cfgData[i] or {}
		local isExist = true
		local newPath = nil
		if serData["isLoadLocalImg"] then
			namePath = cfgData[i][ACTIVITY_NAME]
		else
			isExist,newPath = NetCallBack:getCacheImage(serData[ACTIVITY_NAME])
	    	if isExist then
	    		namePath = newPath
	    	else
				NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),serData[ACTIVITY_NAME],"ACTIVITY_NAME",serData[ACTIVITY_NAME],i)
			end	
		end
		local item = self.mList:newItem() 
	
    	local btnActivity = cc.Sprite:create(backPath)
    	local bgWidth = btnActivity:getContentSize().width
    	local bgHeight= btnActivity:getContentSize().height
    	btnActivity:setPosition(bgWidth - 30,bgHeight/2)
    	item:addContent(btnActivity)

		local btnselect = cc.Sprite:create(selectPath)
		btnselect:setScaleX(-1)
		btnselect:setPosition(bgWidth/2+7,bgHeight/2)
		btnselect:setVisible(false)
		btnActivity:addChild(btnselect,0,TAG.ACTIVITY_SELECT)

		
		local tempSp = cc.Sprite:create(namePath)
    	local name = cc.Sprite:create(namePath)
    	name:setScaleX(210/name:getContentSize().width)
    	name:setScaleY(70/name:getContentSize().height)
    	name:setPosition(bgWidth/2,bgHeight/2+2)
    	btnActivity:addChild(name,1,TAG.ACTIVITY_NAME)
		item:setItemSize(bgWidth, bgHeight+12)
	   	self.mList:addItem(item)

	   	if i == 1 then 
			btnselect:setVisible(true)
			self:createLeftNode(1)
		end
	   	self.mActivitySprite[#self.mActivitySprite + 1] = btnActivity
	end  

	self.mList:reload()		
end

function ActivityLayer:createLeftNode(index)
	
	if self.mLeftBg then self.mLeftBg:removeFromParent() self.mLeftBg = nil end
	if self.mBtnWatch then self.mBtnWatch:removeFromParent() self.mBtnWatch = nil end
	local btnPath="picdata/activity/btn_info.png"
    local btnPath1="picdata/activity/btn_info1.png"
    local namePath="picdata/activity/activity_img.png"

    local serData = self.mCfgData[index] or {}
    if serData["isLoadLocalImg"] then
		namePath = serData[ACTIVITY_BG]
	else
   		local isExist,newPath = NetCallBack:getCacheImage(serData[ACTIVITY_BG])
    	if isExist then
    		namePath = newPath
    	else
			NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),serData[ACTIVITY_BG],"ACTIVITY_BG",serData[ACTIVITY_BG],index)
		end	
	end
	local bg = cc.Sprite:create(namePath)
	 local bgWidth = bg:getContentSize().width
    local bgHeight= bg:getContentSize().height
    bg:setScaleX(584/bg:getContentSize().width)
    bg:setScaleY(418/bg:getContentSize().height)
	bg:setPosition(self.mBg:getContentSize().width/2 + 120,self.mBg:getContentSize().height/2- 15)
	self.mBg:addChild(bg,1)

	if serData[ACTIVITY_LABEL] ~= "" then
		local btnWatch = CMButton.new({normal = btnPath,pressed = btnPath1},function ()  self:onMenuCallBack(serData[ACTIVITY_TAG],serData) end)
		btnWatch:setButtonLabel("normal",cc.ui.UILabel.new({
		    --UILabelType = 1,
		    color = cc.c3b(153,255,0),
		    text = serData[ACTIVITY_LABEL],
		    size = 32,
		    font = "FZZCHJW--GB1-0",
			}) )    
		--btnWatch:setPosition(bgWidth/2,60)
		btnWatch:setPosition(bg:getPositionX(),135)
		self.mBg:addChild(btnWatch,2)
		self.mBtnWatch = btnWatch
	end
	self.mLeftBg = bg
end
function ActivityLayer:onMenuCallBack(tag,itemData)
	if tag == "1000" then

	elseif tag == "1001" then     --跳网页
		local url = ""
	     if SERVER_ENVIROMENT == ENVIROMENT_TEST then
	         url = string.format("http://debao.boss.com/index.php?act=activity&mod=do_%s&PHPSESSID=%s",itemData[ACTIVITY_ID],myInfo.data.phpSessionId)
	     else
	     	 url = string.format("http://www.debao.com/index.php?act=activity&mod=do_%s&PHPSESSID=%s",itemData[ACTIVITY_ID],myInfo.data.phpSessionId)    
	     end
	     local data = {}
	     data.url = url
	     QManagerPlatform:jumpToWebView(data)
	elseif tag == "1002" then     --充值商城
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self)
	elseif tag == "1003" then     --积分商城
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.EXCHARGE,self)
	elseif tag == "1004" then 	  --道具商城
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.EXCHARGE,self)
	elseif tag == "1005" then 	  --MTT赛事
		
	elseif tag == "1006" then     --SNG赛事
		 GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)
	elseif tag == "1007" then 	  --现金桌初级场
		GameSceneManager:switchSceneWithType(EGSHall,{nType = 0})
	elseif tag == "1008" then 	  --现金桌中级场
		GameSceneManager:switchSceneWithType(EGSHall,{nType = 1})
	elseif tag == "1009" then 	  --现金桌高级场
		GameSceneManager:switchSceneWithType(EGSHall,{nType = 2})
	elseif tag == "100A" then 	  --个人中心
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.PERSONCENTER,self)
	elseif tag == "100B" then 	  --跳转任务界面
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.DIALYTASK,self)
	elseif tag == "2001" then     --领取活动奖励
	elseif tag == "2002" then     --快速开始
		GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{m_isFromMainPage = true,isQuickStart = true })
	elseif tag == "2003" then     --报名赛事
		 GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)
	elseif tag == "100B" then 	  --跳转任务界面
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.DIALYTASK,self)
	end
	
end


function ActivityLayer:touchRightListener(event)
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
function ActivityLayer:checkTouchInSprite_(x, y,itemPos)	
	local isFind = false
	for i = 1,#self.mActivitySprite do		
		local sp = self.mActivitySprite[i]:getChildByTag(TAG.ACTIVITY_SELECT)
		if sp:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			isFind = true
			if self.mLastSelect == i then return end 											
			sp:setVisible(true)		
			self:createLeftNode(i)
			self.mLastSelect = i
            if self.m_bSoundEnabled then
                MusicPlayer:getInstance():playButtonSound()
            end
		else
			sp:setVisible(false)
		end
	end	
	if not isFind then
		self.mActivitySprite[self.mLastSelect]:getChildByTag(TAG.ACTIVITY_SELECT):setVisible(true)
	end
end

--[[
	网络回调
]]
function ActivityLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_NEWGETACTIVITYLIST then 
		if tableData.CODE == 10000 then
			QDataActivityList:Init(tableData.LIST)
			self:createRightList( )

		end
	end

end
----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function ActivityLayer:onHttpDownloadResponse(tag,progress,fileName)
	if tag == "ACTIVITY_NAME" then
		local isExist,newPath = NetCallBack:getCacheImage(fileName)
		if isExist then
			if self.mActivitySprite and self.mActivitySprite[progress]then
				local sp = self.mActivitySprite[progress]:getChildByTag(TAG.ACTIVITY_NAME)
				sp:setTexture(cc.Sprite:create(newPath):getTexture())
			end
		end
	elseif tag == "ACTIVITY_BG" then
		local isExist,newPath = NetCallBack:getCacheImage(fileName)
		if isExist then
			if self.mLeftBg then
				self.mLeftBg:setTexture(cc.Sprite:create(newPath):getTexture())
			end
		end
	end
	
end
return ActivityLayer