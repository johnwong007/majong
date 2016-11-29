--
-- Author: JJ
-- Date: 2016-01-17 23:12:18
--
--好友申请
local FriendApplyLayer = class("FriendApplyLayer",function() 
	return display.newNode()
end)
require("app.Network.Http.DBHttpRequest")
local CMColorLabel     = require("app.Component.CMColorLabel")
require("app.Logic.Config.UserDefaultSetting")
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
}
local QDataFriendList = nil
function FriendApplyLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
    self.params.nType = self.params.nType or "APPLY_FRIEND"
    QDataFriendList = QManagerData:getCacheData("QDataFriendList")
end
function FriendApplyLayer:onExit()
	QManagerListener:Notify({layerID = eFriendLayerID})
end
function FriendApplyLayer:create()
	self:initUI()
end
function FriendApplyLayer:initUI()
    self:setContentSize(600,500)
    self:setPosition(390,0)
    self.mBg = self
    self:createLeftList(self.params.nType)
end

--[[
	创建左边列表
]]
function FriendApplyLayer:createLeftList(nType)
	local cfgData = QDataFriendList:getMsgData(nType)
 	if not cfgData then
 		return
 	end
 	if self.mLeftList then self.mLeftList:removeFromParent() self.mLeftList = nil end
 	self.mLeftSprite = {}
	-- body
	self.mListSize = cc.size(595,480)	
	self.mLeftList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(-140, 32, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --:onTouch(handler(self, self.touchListener))
    :addTo(self.mBg)    
  	
  	local backPath 			= "picdata/friend/bg_list.png"
    local btnRefusePath 	= "picdata/friend/btn_1_refuse.png"
    local btnRefusePath2 	= "picdata/friend/btn_1_refuse2.png"
    local btnAgreePath 		= "picdata/friend/btn_1_agree.png"
    local btnAgreePath2 	= "picdata/friend/btn_1_agree2.png"

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
	    cfgData[i] = cfgData[i] or {}
	    local serData = string.split(cfgData[i][MESSAGE_CONTENT] or "",":") or ""
	 
		local item = self.mLeftList:newItem() 
		local bg =  cc.ui.UIImage.new(backPath, {scale9 = true})
		bg:setLayoutSize(580, 84)
		local bgWidth = bg:getContentSize().width
		local bgHeight= bg:getContentSize().height

		item:addContent(bg)
		item:setItemSize(bg:getContentSize().width, bg:getContentSize().height+6)
	   	self.mLeftList:addItem(item)
	   	local itemData = {}
	   	itemData.item   = item
	   	itemData.userId   = serData[1]
	   	itemData.userName = serData[2]
	   	itemData.messageId= cfgData[i][MESSAGE_ID]
		

    	local headPic = CMCreateHeadBg(serData[USER_PORTRAIT],cc.size(75,75))
    	headPic:setPosition(37,bgHeight/2)
    	bg:addChild(headPic,0,TAG.HEADBG)
		
		-- local name = cc.ui.UILabel.new({
		--         text  = serData[2] or "" .."申请成为你的好友",
		--         size  = 22,
		--         color = cc.c3b(255,255,255),
		--         x     = 123,
		--         y     = bgHeight/2,
		--         align = cc.ui.TEXT_ALIGN_LEFT,
		--         --UILabelType = 1,
  --       		font  = "黑体",
		--     })
		-- bg:addChild(name)
		
		
		local nameText = ""
		if nType == "APPLY_FRIEND" then

			nameText = string.format("%s#01#24; %s#06#20",revertPhoneNumber(tostring(serData[2] or "")),"申请成为你的好友")


			local btnAccept = CMButton.new({normal = btnAgreePath,pressed = btnAgreePath2},function () self:onMenuCallBack(EnumMenu.eAccept,itemData)  end)
	    	btnAccept:setPosition(bgWidth - 30,bgHeight/2)
	    	btnAccept:setTouchSwallowEnabled(false)
	    	bg:addChild(btnAccept)

	    	local btnRefuse = CMButton.new({normal = btnRefusePath,pressed = btnRefusePath2},function () self:onMenuCallBack(EnumMenu.eRefuse,itemData)  end)
	    	btnRefuse:setPosition(bgWidth - 130,bgHeight/2)
	    	btnRefuse:setTouchSwallowEnabled(false)
	    	bg:addChild(btnRefuse)
			-- local level = cc.ui.UILabel.new({
		 --        text  = serData[1] or "",
		 --        size  = 22,
		 --        color = cc.c3b(2,185,249),
		 --        x     = 130,
		 --        y     = bgHeight/2 - 12,
		 --        align = cc.ui.TEXT_ALIGN_LEFT,
		 --        --UILabelType = 1,
	  --   		font  = "黑体",
		 --    })
			-- bg:addChild(level,0,TAG.LEVEL)
		else
			nameText = string.format("%s#01#24",serData[2] or "")
			-- local btnDelete = CMButton.new({normal = btnRefusePath},function () self:onMenuCallBack(EnumMenu.eDelete,itemData)  end)
   --  		btnDelete:setPosition(30,bgHeight/2)
   --  		btnDelete:setTouchSwallowEnabled(false)
   --  		bg:addChild(btnDelete)

			local sTip = ""
			--local tag = cfgData[i][MESSAGE_TYPE]
			local tag = "REMOVE_FRIEND"
			if tag == "ADD_FRIEND" then
				sTip = "同意"
				sTip = string.format("%s#06#20;%s#07#20;%s#06#20","对方",sTip,"你的申请")
			elseif tag == "REFUSE_FRIEND" then
				sTip = "拒绝"
				sTip = string.format("%s#06#20;%s#03#20;%s#06#20","对方",sTip,"你的申请")
			elseif tag == "REMOVE_FRIEND" then
				--sTip = "被删除"
				sTip = "等待回复..."
				sTip = string.format("%s#06#20",sTip)
			end

			-- local level = cc.ui.UILabel.new({
		 --        text  = sTip or "",
		 --        size  = 22,
		 --        color = cc.c3b(2,185,249),
		 --        x     = 235,
		 --        y     = bgHeight/2,
		 --        align = cc.ui.TEXT_ALIGN_LEFT,
		 --        --UILabelType = 1,
	  --   		font  = "黑体",
		 --    })
			-- bg:addChild(level,0,TAG.LEVEL)
			local tip = CMColorLabel.new({text = sTip})
			tip:setAnchorPoint(cc.p(1,0.5))
			tip:setPosition(bgWidth-tip:getContentWidth()-10,bgHeight/2)
			bg:addChild(tip,0)
		end
		local name = CMColorLabel.new({text = nameText})
		name:setAnchorPoint(cc.p(0,0.5))
		name:setPosition(90,bgHeight/2)
		bg:addChild(name,0)

		self.mLeftSprite[#self.mLeftSprite+1] = bg
	end	
	self.mLeftList:reload()	
end
function FriendApplyLayer:onMenuCallBack(tag,itemData)
	--dump(itemData)
	if tag == EnumMenu.eRefuse then
		local value = UserDefaultSetting:getInstance():getApplyFriend("s_refuse_apply")
		if value == 0 then
			local text = string.format("拒绝通过#01;%s#07;的好友申请#01",itemData.userName)
			local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,showType = 2,okText = "拒绝",titleText = "拒绝申请",showBox = true,
				callOk = function (isSelect) self:onMenuDialog(EnumMenu.eRefuse,itemData,isSelect) end
				 }) 
			CMOpen(RewardLayer, self:getParent(),-self:getParent():getPositionX())
		else
			DBHttpRequest:refuseFriend(function(tableData,tag) self:httpResponse(tableData,tag,"refuseFriend",itemData) end,itemData.userId,itemData.userName,itemData.messageId)
		end
	elseif tag == EnumMenu.eAccept then
		local value = UserDefaultSetting:getInstance():getApplyFriend("s_agree_apply")
		if value == 0 then
			local text = string.format("同意通过#01;%s#07;的好友申请#01",itemData.userName)
			local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,showType = 2,okText = "同意",titleText = "同意申请",showBox = true,
				callOk = function (isSelect) self:onMenuDialog(EnumMenu.eAccept,itemData,isSelect) end
				}) 
			CMOpen(RewardLayer, self:getParent(),-self:getParent():getPositionX())
		else
			DBHttpRequest:addFriend(function(tableData,tag) self:httpResponse(tableData,tag,"addFriend",itemData) end,itemData.userId,itemData.userName,itemData.messageId)
		end
	elseif tag == EnumMenu.ePageUp then
		if self.mCurFriendIndex > 4 then	
			self.mCurFriendIndex = self.mCurFriendIndex - 8		
			DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mCurFriendIndex,4)		
			self.mCurFriendIndex = self.mCurFriendIndex + 4	
			self:updatePageBtn()
		end
	elseif tag == EnumMenu.ePageDown then
		if self.mCurFriendIndex < self.mMaxFriendIndex then			
			DBHttpRequest:getFriendsListInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mCurFriendIndex,4)
			self.mCurFriendIndex = self.mCurFriendIndex + 4 								
			self:updatePageBtn()
		end
	end
end
function FriendApplyLayer:onMenuDialog(tag,itemData,value)
	if tag == EnumMenu.eRefuse then
		UserDefaultSetting:getInstance():setApplyFriend("s_refuse_apply",value)
		DBHttpRequest:refuseFriend(function(tableData,tag) self:httpResponse(tableData,tag,"refuseFriend",itemData) end,itemData.userId,itemData.userName,itemData.messageId)
	elseif  tag == EnumMenu.eAccept then 
		UserDefaultSetting:getInstance():setApplyFriend("s_agree_apply",value)
		DBHttpRequest:addFriend(function(tableData,tag) self:httpResponse(tableData,tag,"addFriend",itemData) end,itemData.userId,itemData.userName,itemData.messageId)
	end
end

function FriendApplyLayer:showActionResult(tableData,itemData,nType)
	local tips = ""	
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

	if tips ~= "" then
		CMShowTip(tips)
		-- local AlertDialog = require("app.Component.CMAlertDialog").new({text = tips})
		-- CMOpen(AlertDialog,self:getParent(),-self:getParent():getPositionX())
	end
end
--[[
	网络回调
]]
function FriendApplyLayer:httpResponse(tableData,tag,nType,itemData)
	--dump(tableData,tag)
	
	if tag == POST_COMMAND_ADDFRIEND then 							--同意好友添加
		self:showActionResult(tableData,itemData,nType)
	elseif tag == POST_COMMAND_REFUSEFRIEND then 						--拒绝好友添加
		self:showActionResult(tableData,itemData,nType)
	end
	
end
return FriendApplyLayer