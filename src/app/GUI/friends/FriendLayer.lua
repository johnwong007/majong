 --
-- Author: junjie
-- Date: 2015-12-04 12:17:20
--

--我的好友
local CMCommonLayer = require("app.Component.CMCommonLayer")
local FriendLayer = class("FriendLayer",CMCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
local QDataFriendList = nil
local NetCallBack = require("app.Network.Http.NetCallBack")
require("app.Network.Http.DBHttpRequest")
require("app.CommonDataDefine.CommonDataDefine")
local TAG = {
	HEADBG = 100,
	VIP    = 101,
	LEVEL  = 102,

}
local EnumMenu = 
{	
	eAccept     = 1,
	eRefuse     = 2,
	eDelete     = 3,
	ePageUp     = 4,
	ePageDown   = 5,
	eMsg        = 6,
	eTrack      = 7,
	eApply      = 8,
}
function FriendLayer:ctor(params)
	self:setNodeEventEnabled(true)
	QDataFriendList = QManagerData:getCacheData("QDataFriendList")
	self.mLeftSprite = {}
	self.mActivitySprite = {}
	self.mCurFriendIndex = 0
	self.mMaxFriendIndex = 0 
	self.mRequestNum     = 10
	self.mAllItemHeight  = 0
	self.mIsRequest      = false
end
function FriendLayer:create()
    FriendLayer.super.ctor(self,{titlePath = "picdata/friend/title_wdhy.png",bgType = 2}) 
    FriendLayer.super.initUI(self)
    self:createUI( )
end
function FriendLayer:onExit()
	QManagerData:removeCacheData("QDataFriendList")
	QManagerListener:Detach(eFriendLayerID)
end
function FriendLayer:onEnter()
	QManagerListener:Attach({{layerID = eFriendLayerID,layer = self}})
end
function FriendLayer:updateCallBack(data)
    --self.mInputBox:setVisible(true)
end
function FriendLayer:createUI()

	DBHttpRequest:getFriendsNum(function(tableData,tag) self:httpResponse(tableData,tag) end)
	DBHttpRequest:getFriendsMessage(function(tableData,tag) self:httpResponse(tableData,tag) end,"NOT_READ")
 	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	local btnApply = CMButton.new({normal = "picdata/friend/btn_sq.png",pressed = "picdata/friend/btn_sq2.png"},function () self:onMenuCallBack(EnumMenu.eApply) end, {scale9 = false})    
    :align(display.CENTER, 110,self.mBg:getContentSize().height-48) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

	local bg = cc.ui.UIImage.new("picdata/friend/bg_list.png", {scale9 = true})
	bg:setLayoutSize(800, 84)
	bg:setPosition(bgWidth/2-bg:getContentSize().width/2,bgHeight-150-bg:getContentSize().height/2)
	--self.mBg:addChild(bg )

	local inputBox = CMInput:new({
	    --bgColor = cc.c4b(255, 255, 0, 120),
	    maxLength = 24,
	    place     = "   输入(UID)/昵称/手机号/邮箱,添加好友一起玩",
	    color     = cc.c3b(135,154,192),
	    fontSize  = 22,
	    bgPath    = "picdata/friend/bg_ss.png" ,	    
	    forePath  = "picdata/friend/btn_ss.png",
	    foreAlign = CMInput.RIGHT,
	    foreCallBack = function () end,
	    --listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
	})
	inputBox:setPosition(bgWidth/2,bgHeight-150)
	inputBox:setVisible(false)
	self.mBg:addChild(inputBox )
	self.mInputBox = inputBox
	-- self:createRightList( )

end


function FriendLayer:createRightList( )
 	local cfgData = QDataFriendList:getMsgData("FriendList")
 	if not cfgData then
 		CMDelay(self, 0.3, function ()
 			DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,0,self.mRequestNum)
 		end)
 		return
 	end
 	if self.mList then self.mList:removeFromParent() self.mList = nil end
	-- body
	self.mActivitySprite = {}
	--self.mListSize = cc.size(810,360)	
	self.mListSize = cc.size(810,483)
	self.mList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(30, 32, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg)    
	
	
	for i = 1,#cfgData do
		self:createPageItem(i,cfgData[i],nType)
	end  

	self.mList:reload()		
end
function FriendLayer:createPageItem(i,cfgData,nType)
	local item = self.mList:newItem()		
	local bg = self:createPageNode(i,cfgData,nType)	
	local itemSize = cc.size(bg:getContentSize().width + 200, bg:getContentSize().height)
	item:addContent(bg)
	item:setItemSize(self.mListSize.width,itemSize.height)   

	self.mAllItemHeight = self.mAllItemHeight + itemSize.height
	self.mList:addItem(item)
end
function FriendLayer:createPageNode(i,cfgData,nType)
	local backPath 		= "picdata/friend/bg_list.png";
    local btnMsgPath 	= "picdata/friend/btn_3_email.png";
    local btnMsgPath2 	= "picdata/friend/btn_3_email2.png";
    local btnTrackPath 	= "picdata/friend/btn_3_tracking.png";
    local btnTrackPath2 	= "picdata/friend/btn_3_tracking2.png";
    
    local infoBtnPath 	= "picdata/public/checkboxOff.png";
    local levelPath 	= "picdata/friend/userLevelBg.png";

	local serData = cfgData or {}
	local tableName = ""
	local TrackState   = false
	local TrackOpactity = 100
	if serData[USER_STATUS] == "ONLINE" then
		if serData[TABLE_NAME] == "" then
			tableName = "大厅"
		else
			tableName =  serData[TABLE_TYPE] .. "-" .. serData[TABLE_NAME]
		end
	elseif serData[USER_STATUS] == "OFFLINE" then
		tableName = "离线"
	end
	local itemData = {}

	if serData[USER_STATUS] == "ONLINE" and string.len(serData[TABLE_ID]) > 0  and serData[TABLE_TYPE] == "CASH" then
		TrackState = true
		TrackOpactity = 255
		itemData[TABLE_ID]  = serData[TABLE_ID]
		itemData[TABLE_TYPE]= serData[TABLE_TYPE]
	end

	local bg = cc.ui.UIImage.new(backPath, {scale9 = true})
	bg:setLayoutSize(800, 84)
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height
	

	local btnMsg = CMButton.new({normal = btnMsgPath,pressed = btnMsgPath2},function () self:onMenuCallBack(EnumMenu.eMsg,i)  end)
	btnMsg:setPosition(bgWidth - 40,bgHeight/2)
	btnMsg:setTouchSwallowEnabled(false)
	bg:addChild(btnMsg)

	local btnTrack = CMButton.new({normal = btnTrackPath,pressed = btnTrackPath2},function ()  self:onMenuCallBack(EnumMenu.eTrack,itemData) end)
	btnTrack:setPosition(bgWidth - 130,bgHeight/2)
	btnTrack:setVisible(TrackState)
	-- btnTrack:setTouchSwallowEnabled(false)
	-- btnTrack:setButtonEnabled(TrackState)
	-- btnTrack:setOpacity(TrackOpactity)
	bg:addChild(btnTrack)

	local headBG = CMCreateHeadBg(serData[USER_PORTRAIT],cc.size(70,70))
	headBG:setPosition(37,bgHeight/2)
	bg:addChild(headBG,0,TAG.HEADBG)
	
	local name = cc.ui.UILabel.new({
	        text  = revertPhoneNumber(serData[USER_NAME] or "1111"),
	        size  = 26,
	        color = cc.c3b(255,255,255),
	        x     = 100,
	        y     = bgHeight/2 + 14,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
    		font  = "黑体",
	    })
	name:setOpacity(TrackOpactity)
	bg:addChild(name)

	local tName = cc.ui.UILabel.new({
        text  = tableName or "",
        size  = 22,
        color = cc.c3b(255,232,180),
        x     = 100,
        y     = bgHeight/2 - 14,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
		font  = "黑体",
    })
    tName:setOpacity(TrackOpactity)
	bg:addChild(tName)


	local vipLevel 
    if not serData["VIP"] or tonumber(serData["VIP"]) == 0 then
    	vipLevel = cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",1))
    	--vipLevel:setVisible(false)
	else
		vipLevel = cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",serData["VIP"]))
	end
	vipLevel:setPosition(headBG:getPositionX(),headBG:getPositionY()+30)
	vipLevel:setScale(0.8)
	bg:addChild(vipLevel,0,TAG.VIP)


	local levelBg = cc.Sprite:create(levelPath)
	levelBg:setPosition(62,20)
	bg:addChild(levelBg)
	local level = cc.ui.UILabel.new({
	        text  = serData[USER_LEVEL] or "1",
	        size  = 18,
	        color = cc.c3b(0,0,0),
	        --UILabelType = 1,
    		font  = "黑体",
	    })
	level:setPosition(levelBg:getPositionX()-level:getContentSize().width/2,levelBg:getPositionY())
	bg:addChild(level,0,TAG.LEVEL)

	self.mActivitySprite[#self.mActivitySprite+1] = bg

	return bg
end
function FriendLayer:touchRightListener(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos,event.item)
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
	    		if event.itemPos >= 6 then
	    			self.mItemChange = 1   --向下
    			else
    				self.mItemChange = -1 
    			end
	    	end
	    	--dump(self.mItemChange,event.name)
	    	if event.name == "scrollEnd" and self.mItemChange ~= -1 then
	    		local nType = "FriendList"
	    	   local curRankNum = QDataFriendList:getMsgLength(nType) or 1

	    	   if curRankNum ~= 0 and curRankNum < self.mMaxFriendIndex then
	    	   		if self.mIsRequest then return end
	    	   		self.mIsRequest = true
	    	   		DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,curRankNum,self.mRequestNum)
	    	   end

		    end
	    end	    
	 end
	
end
function FriendLayer:checkTouchInSprite_(x, y,itemPos,item)	
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getChildByTag(TAG.HEADBG):getCascadeBoundingBox():containsPoint(cc.p(x, y)) then	
			self.mInputBox:setVisible(false)
			local FriendShowLayer = require("app.GUI.friends.FriendShowLayer").new({nType = "FriendList",index = i,item = item})
			CMOpen(FriendShowLayer,self,0,0)
		else
			--self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
			
	    end	  
	end	
end
-- function FriendLayer:updatePageBtn()
-- 	if self.mMaxFriendIndex <= 4 then
-- 		self.mLastPage:setButtonEnabled(false)
-- 		self.mNextPage:setButtonEnabled(false)
-- 		return
-- 	end
-- 	if self.mMaxFriendIndex - self.mCurFriendIndex > 0 then
-- 		self.mNextPage:setButtonEnabled(true)
-- 	else
-- 		self.mNextPage:setButtonEnabled(false)	
-- 	end
-- 	if self.mCurFriendIndex > 4 and self.mMaxFriendIndex > 4 then
-- 		self.mLastPage:setButtonEnabled(true)
-- 	else
-- 		self.mLastPage:setButtonEnabled(false)
-- 	end
-- end
function FriendLayer:onMenuCallBack(tag,itemData)
	if tag == EnumMenu.eDelete then
		DBHttpRequest:deleteSomePrivateMessages(function(tableData,tag) self:httpResponse(tableData,tag,"deleteFriend",itemData) end,itemData.messageId)
	-- elseif tag == EnumMenu.ePageUp then
	-- 	if self.mCurFriendIndex > 4 then	
	-- 		self.mCurFriendIndex = self.mCurFriendIndex - 8		
	-- 		DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mCurFriendIndex,4)		
	-- 		self.mCurFriendIndex = self.mCurFriendIndex + 4	
	-- 		-- self:updatePageBtn()
	-- 	end
	-- elseif tag == EnumMenu.ePageDown then
	-- 	if self.mCurFriendIndex < self.mMaxFriendIndex then			
	-- 		DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mCurFriendIndex,4)
	-- 		self.mCurFriendIndex = self.mCurFriendIndex + 4 								
	-- 		-- self:updatePageBtn()
	-- 	end
	elseif tag == EnumMenu.eMsg then
		self.mInputBox:setVisible(false)
		local FriendMsgLayer = require("app.GUI.friends.FriendMsgLayer").new({nType = "FriendList",index = itemData})
		CMOpen(FriendMsgLayer,self)
	elseif tag == EnumMenu.eTrack then
		DBHttpRequest:getTableInfo(function(tableData,tag) self:httpResponse(tableData,tag,"refuseFriend",itemData) end,itemData[TABLE_TYPE],itemData[TABLE_ID])
	elseif tag == EnumMenu.eApply then
		self.mInputBox:setVisible(false)
			local RewardLayer = require("app.Component.CMCommonLayer").new({
			titlePath = "picdata/friend/w_hysq.png",
			titleOffY = -40,
			bgType = 3,
			selectIdx = 1,
			mAtivityName = {"好友申请","我的申请"}})
		CMOpen(RewardLayer,cc.Director:getInstance():getRunningScene(),0,0)
	end
end
function FriendLayer:removeFriend(item)
	
	local idx = self.mList:getItemPos(item)
	if idx then
		table.remove(self.mActivitySprite,idx)
	end
	self.mList:removeItem(item,false)
end
function FriendLayer:showActionResult(tableData,itemData,nType)
	local tips = ""	
	if nType == "deleteFriend" then
		if tableData == 1 then
			tips = ""
			self.mLeftList:removeItem(itemData.item,false)
			QDataFriendList:removeItemData("OTHER_FRIEND",itemData.messageId)
		else
			tips = "删除信息失败，请稍后再试."
		end
	else
		if tableData == -2 then
			tips = "对方已经是好友"
			self.mLeftList:removeItem(itemData.item,false)
			QDataFriendList:removeItemData("APPLY_FRIEND",itemData.messageId)
		elseif tableData == -1 then
			tips = "拒绝好友添加申请失败，请稍后再试"
		else
			tips = "操作成功"
			DBHttpRequest:getFriendsNum(function(tableData,tag) self:httpResponse(tableData,tag) end)
			self.mLeftList:removeItem(itemData.item,false)
			QDataFriendList:removeItemData("APPLY_FRIEND",itemData.messageId)
		end
	end
	if tips ~= "" then
		local AlertDialog = require("app.Component.CMAlertDialog").new({text = tips})
		CMOpen(AlertDialog,self)
	end
end
function FriendLayer:hallEnterRoom(eachInfo)
	if TRUNK_VERSION==DEBAO_TRUNK then
        if eachInfo.password == "YES" and eachInfo.tableOwner~=myInfo.data.userId then
        
            if not self.dialog then
                self.dialog = require("app.GUI.hallview.EnterPasswordDialog"):new()
                self.dialog:addTo(self, 1001)
            end
            self.dialog:show()
        elseif eachInfo.smallBlind == myInfo.data.leastSB and myInfo:getTotalChips()>=eachInfo.buyChipsMin*100 then
            local tmpNum = eachInfo.buyChipsMin*100
            local tmpStr = " 亲爱的高手，您的金币已经超过"..tmpNum..",\n不要再欺负菜鸟了,请前往更高级的牌桌打牌吧!"
            if not self.alertView then
                self.alertView = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
                    tmpStr,Lang_Button_Confirm)
            end
            self.alertView:show()
        else
            if self.m_hall then
                self.m_hall:joinTable(eachInfo.tableId)
            end
        end
    else

    end
end
function FriendLayer:addListData(tableData,nType)
	local height = self.mAllItemHeight
	local allRankNum = QDataFriendList:getMsgLength(nType) or 1
	local cfgData = QDataFriendList:getMsgData(nType)
	local nextRankNum = allRankNum - #tableData+1
	local addRankNum  =  nextRankNum + #tableData - 1
	for i = nextRankNum,addRankNum  do 
		self:createPageItem(i,cfgData[i],nType)		
	end	
	self.mList:reload()
	self.mList:moveItems(1,addRankNum,0,height)
end
--[[
	网络回调
]]
function FriendLayer:httpResponse(tableData,tag,nType,itemData)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GETFRIENDSMESSAGE then			
		QDataFriendList:sortReceiveData(tableData)  					--收件箱
		for i = 1,#tableData do 
			local data = string.split(tableData[i][MESSAGE_CONTENT],":")
			DBHttpRequest:getUserShowInfo(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,data[1])
		end	
		--self:createLeftList("APPLY_FRIEND")
	elseif tag == POST_COMMAND_GETUSERSHOWINFO then
		for i ,v in pairs(self.mLeftSprite) do
			if v:getChildByTag(TAG.LEVEL):getString() == tableData[USER_ID] then
				v:getChildByTag(TAG.HEADBG):changeHead(tableData[USER_PORTRAIT])
			end
		end
	elseif tag == POST_COMMAND_GETFRIENDSNUMS then 						--好友数量 
		self.mMaxFriendIndex = tableData
		if tableData > 0 then
			DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,0,self.mRequestNum)
			--self.mCurFriendIndex = self.mCurFriendIndex + 4
			--self:updatePageBtn()
		end
	elseif tag == POST_COMMAND_GETFRIENDSLISTINFO then
	    if type(tableData) ~= "table" or #tableData == 0 then self.mIsRequest = false return end
		local nType = "FriendList"										--好友列表
		QDataFriendList:Init(tableData,nType)
		local userList = QDataFriendList:getMsgUserList(nType)
		if userList then 
			DBHttpRequest:getVipInfo(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,userList)
			DBHttpRequest:getUserListLevel(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,userList)
		end
		if self.mIsRequest == true then
			self:addListData(tableData,nType)	
			self.mIsRequest = false	
		else
			self:createRightList( )
		end
	elseif tag == POST_COMMAND_GET_VIP_INFO then 						--更新VIP
		QDataFriendList:updateMsgData(tableData,nType,"VIP")
		local serData = QDataFriendList:getMsgData(nType)
		for i = 1,#self.mActivitySprite do
			local vipLevel = self.mActivitySprite[i]:getChildByTag(TAG.VIP)
			if serData[i]["VIP"] and tonumber(serData[i]["VIP"]) > 0 then
				vipLevel:setTexture(cc.Sprite:create(string.format("picdata/public/vip/vip%s.png",serData[i]["VIP"])):getTexture())
				vipLevel:setVisible(true)
			else
				vipLevel:setVisible(false)
			end
		end
	elseif tag == POST_COMMAND_getUserListLevel then 					--更新等级
		QDataFriendList:updateMsgData(tableData,nType,USER_LEVEL)
		local serData = QDataFriendList:getMsgData(nType)
		for i = 1,#self.mActivitySprite do
			local level = self.mActivitySprite[i]:getChildByTag(TAG.LEVEL)
			level:setString(serData[i][USER_LEVEL])
			level:setPositionX(62-level:getContentSize().width/2)
		end
	elseif tag == POST_COMMAND_ADDFRIEND then 							--同意好友添加
		self:showActionResult(tableData,itemData,nType)
	elseif tag == POST_COMMAND_REFUSEFRIEND then 						--拒绝好友添加
		self:showActionResult(tableData,itemData,nType)
	elseif tag == POST_COMMAND_DELETESOMEPRIVATEMESSAGES then 			--删除我的申请消息
		self:showActionResult(tableData,itemData,nType)
	elseif tag == POST_COMMAND_GETTABLEINFO then
		local eachInfo = {}
		eachInfo.password = tableData[PASSWORD]
		eachInfo.buyChipsMin = 200
		eachInfo.tableId = tableData[TABLE_ID]
		eachInfo.tableOwner= tableData[TABLE_OWNER]
		eachInfo.smallBlind= tableData[SMALL_BLIND]
		local HallView = require("app.GUI.HallView"):new()
		--self:addChild(HallView)
		--dump(eachInfo)
		HallView:hallEnterRoom(eachInfo)
	end
	
end

return FriendLayer