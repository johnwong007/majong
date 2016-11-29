
--
-- Author: junjie
-- Date: 2015-12-01 17:57:34
--
--好友信息
local FriendShowLayer = class("FriendShowLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
local QDataRankList = nil
local QDataFriendList = nil
local myInfo = require("app.Model.Login.MyInfo")
require("app.Logic.Config.UserDefaultSetting")
require("app.CommonDataDefine.CommonDataDefine")
function FriendShowLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
end
function FriendShowLayer:create()
    self:initUI()
    local func1 = function(tableData,tag) if self.httpResponse then self:httpResponse(tableData,tag) end end
	local func2 = function(tableData,tag) if self.httpResponse then self:httpResponse(tableData,tag) end end
	local func3 = function(tableData,tag) if self.httpResponse then self:httpResponse(tableData,tag) end end
	-- print(tostring(func1).."/"..tostring(func2).."/"..tostring(func3).."/")
	--dump(function(tableData,tag) dump(self.httpResponse) self:httpResponse(tableData,tag) end)
	DBHttpRequest:hudForMobile(func1,self.mSerData[USER_ID])
	DBHttpRequest:getUserMatchData(func2,self.mSerData[USER_ID])
	if tostring(self.mSerData[USER_ID]) ~= tostring(myInfo.data.userId) then
		DBHttpRequest:isFriend(func3,self.mSerData[USER_ID])
	end
end
function FriendShowLayer:onExit()
	QManagerListener:Notify({layerID = eFriendLayerID})
end
function FriendShowLayer:onEnter()

end
function FriendShowLayer:initUI()
	local serData
	if self.params.nType == "FriendList" then 
		QDataFriendList = QManagerData:getCacheData("QDataFriendList")
		serData = QDataFriendList:getMsgUserData(self.params.nType,self.params.index) or {}		
	elseif self.params.nType == "PlayerInfo" then
		serData = self.params.userdata
	else
		QDataRankList = QManagerData:getCacheData("QDataRankList")
		serData = QDataRankList:getMsgUserData(self.params.nType,self.params.index) or {}
	end
	self.mSerData = serData


	
	local bgPath = "picdata/friend/bg_1_common.png"
	if serData["VIP"] and tonumber(serData["VIP"]) > 0 then
		bgPath = "picdata/friend/bg_1_vip.png"
	end

	self.mBg = cc.Sprite:create(bgPath)
    local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	self.mBg:setPosition(display.cx,display.cy)
	self:addChild(self.mBg)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end)    
    :align(display.CENTER, self.mBg:getContentSize().width - 40,self.mBg:getContentSize().height-40) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

	local headBGManPath  = "picdata/public/bg_5_player_man_line.png"
    local headBGWomanPath= "picdata/public/bg_5_player_woman_line.png"
    local headPath = headBGManPath
	if serData[USER_SEX] == "女" then
		headPath = headBGWomanPath
	end

    local headBG = cc.Sprite:create(headPath)
	headBG:setPosition(bgWidth/2,bgHeight/2+160)
	self.mBg:addChild(headBG)

	local foreBg = cc.Sprite:create("picdata/public/man_loop.png")
	foreBg:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height/2)
	headBG:addChild(foreBg, 1)

    local headPic = CMCreateHeadBg(serData[USER_PORTRAIT],cc.size(160,160))
	headPic:setPosition(headBG:getContentSize().width/2,headBG:getContentSize().height/2)
	headBG:addChild(headPic)
	local name = cc.ui.UILabel.new({
	        text  = revertPhoneNumber(serData[USER_NAME] or ""),
	        size  = 28,
	        color = cc.c3b(255,255,255),
	        --UILabelType = 1,
    		font  = "黑体",
	    })
	name:setPosition(bgWidth/2-name:getContentSize().width/2,bgHeight/2+55)
	self.mBg:addChild(name)

	local node = cc.Node:create()
	self.mBg:addChild(node)

	local psData = cc.Sprite:create("picdata/personalCenter/w_title_pssj.png")
	psData:setPosition(230,313)
	node:addChild(psData)

	local text = {"今日局数","总牌局数","锦标赛次数","最佳牌型"} 
	local posx = 200
	local posy = 250
	for i = 1 ,4 do 
		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i]..":",
		        size  = 26,
		        color = cc.c3b(121,138,172),
		        --UILabelType = 1,
		        font  = "FZZCHJW--GB1-0",
	    		
		    })
		sDetail:setPosition(posx-sDetail:getContentSize().width,posy)
		node:addChild(sDetail)

		local perNum = cc.ui.UILabel.new({
		        text  =   "",
		        size  = 24,
		        color = cc.c3b(121,138,172),
		        --UILabelType = 1,
	    		font  = "Arial",
		    })
		perNum:setPosition(posx + 5,posy)
		node:addChild(perNum,0,100+i)

		posy = posy - 40
	end

	local rightBtn =  CMButton.new({normal = "picdata/personalCenter/btn_2_next.png"},function () self.mLeftPage:setVisible(false) self.mRightPage:setVisible(true) end, {scale9 = false})    
    :align(display.CENTER, 350,310) --设置位置 锚点位置和坐标x,y
    :addTo(node)

    local node2 = cc.Node:create()
    self.mBg:addChild(node2)

    local psData = cc.Sprite:create("picdata/personalCenter/w_title_sjfx_2.png")
	psData:setPosition(230,313)
	node2:addChild(psData)

	local text = {"入局率(VPIP)","翻牌前加注率(PFR)","激进度(AF)"} 
	local posx = 300
	local posy = 250
	for i = 1 ,3 do 
		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i]..":",
		        size  = 26,
		        color = cc.c3b(121,138,172),
		        --UILabelType = 1,
		        font  = "FZZCHJW--GB1-0",
	    		
		    })
		sDetail:setPosition(posx-sDetail:getContentSize().width,posy)
		node2:addChild(sDetail)

		local perNum = cc.ui.UILabel.new({
		        text  =   "",
		        size  = 24,
		        color = cc.c3b(121,138,172),
		        --UILabelType = 1,
	    		font  = "Arial",
		    })
		perNum:setPosition(posx + 5,posy)
		node2:addChild(perNum,0,100+i)

		posy = posy - 40
	end

	local leftBtn =  CMButton.new({normal = "picdata/personalCenter/btn_2_next.png"},
		function () self.mLeftPage:setVisible(true) self.mRightPage:setVisible(false) end
		, {scale9 = false})  
    :align(display.CENTER, 100,314) --设置位置 锚点位置和坐标x,y
    :addTo(node2)
    leftBtn:setScale(-1)
    node2:setVisible(false)
    self.mLeftPage = node
    self.mRightPage = node2
    self.mHeadBG    = headBG
    self.mForeBG    = foreBg
end

function FriendShowLayer:updateData(tableData)
	self.mLeftPage:getChildByTag(101):setString(tableData[HANDS_NUM])
	self.mLeftPage:getChildByTag(102):setString(tableData[STAT_KEY_HANDS][STAT_KEY_VALUE])

	self.mRightPage:getChildByTag(101):setString(tableData[STAT_KEY_VPIP][STAT_KEY_VALUE])
	self.mRightPage:getChildByTag(102):setString(tableData[STAT_KEY_PFR][STAT_KEY_VALUE])
	self.mRightPage:getChildByTag(103):setString(tableData[STAT_KEY_AF][STAT_KEY_VALUE])

	if tableData[USER_SEX] == "女" then
		self.mHeadBG:setTexture(cc.Sprite:create("picdata/public/bg_5_player_woman_line.png"):getTexture())
		self.mForeBG:setTexture(cc.Sprite:create("picdata/public/lady_loop.png"):getTexture())
	end
	self:addCard(tableData[MAX_CARD])
end
function FriendShowLayer:addCard(cardData)
	-- dump(cardData)
	if type(cardData) ~= "string" then return end
    local data = string.split(cardData,",")
    if #data < 5 then return end
    local node = cc.Node:create()
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
		card:setScale(0.4)
		card:setPosition(posx,0)
		node:addChild(card)
		posx = posx + card:getBoundingBox().width
	end
	node:setPosition(220,115)
	self.mLeftPage:addChild(node)
end
function FriendShowLayer:updateFriendBtn(bIsFriend)	
	local norPath =  "picdata/friend/btn_2_addf.png"
	local prePath = "picdata/friend/btn_2_addf2.png"
	if bIsFriend then
		norPath = "picdata/friend/btn_2_deletef.png"
		prePath = "picdata/friend/btn_2_deletef2.png"
	end
	local friednBtn =  CMButton.new({normal = norPath,pressed = prePath},function () self:onMenuDealFriend(bIsFriend) end, {scale9 = false})    
    :align(display.CENTER, 360,400) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
end
function FriendShowLayer:onMenuDealFriend(bIsFriend)
	if  bIsFriend then
    	local AlertDialog = require("app.Component.CMAlertDialog").new({
    		text = string.format("你确定删除好友;%s#07;?",revertPhoneNumber(self.mSerData[USER_NAME] or "")),
    		showType = 2,
    		titleText = "删除好友",
    		callOk = function () DBHttpRequest:removeFriend(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mSerData[USER_ID],self.mSerData[USER_NAME] ) end,
    		})
    	CMOpen(AlertDialog,self)
    else
    	local value = UserDefaultSetting:getInstance():getApplyFriend("s_addfriend")
		if value == 0 then
			local text = string.format("添加;%s#07;为好友？",revertPhoneNumber(self.mSerData[USER_NAME]) or "??")
			local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,showType = 2,titleText = "添加好友",showBox = true,
				callOk = function (isSelect) self:onMenuDialog(isSelect) end
				 }) 
			CMOpen(RewardLayer, self:getParent(), 0, 0, self:getLocalZOrder()+1)
		else
			DBHttpRequest:applyFriend(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mSerData[USER_ID],self.mSerData[USER_NAME])
		end
	end
end
function FriendShowLayer:onMenuDialog(value)

	UserDefaultSetting:getInstance():setApplyFriend("s_addfriend",value)
	DBHttpRequest:applyFriend(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mSerData[USER_ID],self.mSerData[USER_NAME])
	
end
function FriendShowLayer:updateAddFriend(isSuc,nType)
	local text 
	if nType == "ADD" then
		if isSuc == 1 then
			text = "请求添加好友成功"
			isSuc = true
		else
			text = "请求添加好友失败,请重试"
			isSuc = false
		end
	elseif nType == "REMOVE" then
		if isSuc == 1 or isSuc == true then
			text = "删除好友成功"
			isSuc = true
			self:removeFriend()
		else
			text = "删除好友失败"
			isSuc = false
		end
	end
	
	 local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
	 CMOpen(CMToolTipView,self)
end
function FriendShowLayer:removeFriend()
	if  self.params.nType == "FriendList" then
		QDataFriendList:removeItemDataByIndex(self.params.nType,self.params.index)
		self:getParent():removeFriend(self.params.item)			
	end
end
--[[
	网络回调
]]
function FriendShowLayer:httpResponse(tableData,tag)
	--dump(tag)
	if tag == POST_COMMAND_HUDFORMOBILE  then
		if type(tableData) ~= "table" then return end
		self:updateData(tableData)
	elseif tag == POST_COMMAND_ISFRIEND then
		self:updateFriendBtn(tableData)	
	elseif tag == POST_COMMAND_getUserMatchData then
		if tableData and tableData["1"] then
			self.mLeftPage:getChildByTag(103):setString(tableData["1"]["1"])
		else
			self.mLeftPage:getChildByTag(103):setString(0)
		end
	elseif tag == POST_COMMAND_APPLYFRIEND then
		self:updateAddFriend(tableData,"ADD")
	elseif tag == POST_COMMAND_REMOVEFRIEND then
		self:updateAddFriend(tableData,"REMOVE")
	end
	
end


return FriendShowLayer 