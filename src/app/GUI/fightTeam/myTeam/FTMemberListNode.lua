--
-- Author: junjie
-- Date: 2016-04-20 16:17:07
--
--成员列表
-- local FTMemberListNode = class("FTMemberListNode",function () return display.newNode() end)
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTMemberListNode = class("FTMemberListNode",FightCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
local QDataFightTeamList = nil
local EnumMenu = {
	eBtnAward 		 = 1,--奖励派送
	eBtnDissolveTeam = 2,--解散队伍	
	eBtnmMoveOut     = 3,--逐出
	eBtnAppointMent  = 4,--委派
	eBtnApplyList 	 = 5,--申请列表
	eBtnQuitTeam	 = 6,--退出战队
	eBtnAddFriend    = 7,--添加战队成员
	eBtnBack 	 	 = 8,--返回

} 
local clubPositon = {
	["chairman"] = "队长",
	["member"] 	 = "成员",
	["vice_chairman"] = "副队长", 
}
function FTMemberListNode:ctor()
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	self.mActivitySprite  = {}
	self.mApplyNum        = 0
	self.mBtnGroup        = {}
	self.mLastTag 		  = EnumMenu.eBtnQuitTeam --默认是退出战队

	self.mRequestNum      = 15 --每次请求数量
	self.mRequestFinishNum=0 --当前已请求数量
	self.mIsStopRequest   = false --停止请求
	self.mAllItemHeight   = 0
end

function FTMemberListNode:create()
	FTMemberListNode.super.ctor(self,{bgType = 2,showClose = 0,titlePath = "picdata/fightteam/w_t_zd.png",size = cc.size(CONFIG_SCREEN_WIDTH,display.height)}) 
    FTMemberListNode.super.initUI(self)
	self:createTitleNode()
	self:createButtonList()	
	DBHttpRequest:getClubMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,myInfo.data.userId,0,self.mRequestNum)
	
	-- test UI
	-- self:createTableViewNode()
end
--[[
	成员标签信息
]]
function FTMemberListNode:createTitleNode()

	local btnClose = CMButton.new({normal = "picdata/fightteam/btn_back.png",pressed = "picdata/fightteam/btn_back2.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnBack) end, {scale9 = false})    
    :align(display.CENTER, CONFIG_SCREEN_WIDTH/2-430,self.mBg:getContentSize().height-50) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg,2)

	local size = cc.size(928,428)
	viewbg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    viewbg:setLayoutSize(size.width,size.height)
	-- viewbg:setPosition(0,0)
	viewbg:setPosition(self.mBgWidth/2-464,self.mBgHeight/2-219)
	self:addChild(viewbg)
	self.mBgWidth = size.width
	self.mBgHeight= size.height
	self.mBg      = viewbg
	local title = cc.Sprite:create("picdata/fightteam/w_title_zdcy.png")
	title:setPosition(self.mBgWidth/2, self.mBgHeight-40)
	viewbg:addChild(title)

	local labelSize = cc.size(844,48)
	local labelBg = cc.ui.UIImage.new("picdata/fightteam/bg_tag.png", {scale9 = true})
    labelBg:setLayoutSize(labelSize.width,labelSize.height)
	labelBg:setPosition(self.mBgWidth/2-labelSize.width/2,self.mBgHeight-110)
	viewbg:addChild(labelBg)

	local labelSp = cc.Sprite:create("picdata/fightteam/tag_cylb.png")
	labelSp:setPosition(labelBg:getContentSize().width/2-30, labelBg:getContentSize().height/2)
	labelBg:addChild(labelSp)

	-- local bg = cc.Node:create()
	-- bg:setPosition(100,500)
	-- self:addChild(bg)
	-- local bgWidth = 300
	-- local bgHeight= 40

	-- local labelText = {
	-- 	{text = "成员名称",posx = 100},{text = "职位",posx = 200},{text = "牌手分",posx = 300},
	-- 	{text = "本期经验",posx = 400},{text = "上期经验",posx = 500},{text = "离线时间",posx = 600},
	-- }
	-- for i = 1,#labelText do 
	-- 	local content = cc.ui.UILabel.new({
 --            text  = labelText[i].text,
 --            size  = 20,
 --            color = cc.c3b(255, 255, 255),
 --            align = cc.ui.TEXT_ALIGN_LEFT,
 --            --UILabelType = 1,
 --            font  = "黑体",
 --        })
 --    	content:setPosition(labelText[i].posx,0)
 --   	 	bg:addChild(content)
	-- end
end
--[[
	成员列表
]]
function FTMemberListNode:createTableViewNode(tableData)
	-- body
	local tableData = QDataFightTeamList:getMsgData(2) or {}
	self.mApplyNum = tonumber(tableData["APPLY_NUM"])
	tableData = tableData["MEMBER"] or {}
	-- local tableData = {{},{},{},{},{},{},{},{}}
	if #tableData == 0 then return end
	if self.mList then self.mList:removeFromParent() self.mList = nil end
    self.mListSize = cc.size(884,300  ) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(20, 10, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
    if #tableData == 0 then return end
    self.mRequestFinishNum = #tableData
    for i = 1,#tableData do
        local item = self:createPageItem(i,tableData[i])
        self.mList:addItem(item)
    end 
    self.mList:reload() 
    self:checkTouchInSprite_(1)
end
function FTMemberListNode:createPageItem(idx,serData)
	serData = serData or {}
	local nTime = ""
    local item = self.mList:newItem()  
    if serData["4026"] == "-" then
    	nTime = "在线"
    else
    	nTime = string.gsub(serData["4026"] or "","-","/")
    	nTime = string.sub(nTime,1,string.len(nTime)-3)
    end
    
	local labelText = {
		{text = serData["2004"],posx = 120},{text = clubPositon[serData["A10D"]],posx = 340},{text = tonumber(serData["4055"] or 0),posx = 435},
		{text = serData["A112"],posx = 555},{text = serData["A113"],posx = 660},{text = nTime,posx = 743},
	}
    local node = cc.Node:create() 
    local itemSize = cc.size(self.mListSize.width-50,60)
	local bgWidth = itemSize.width
    local bgHeight= itemSize.height
     item:addContent(node)
    node:setContentSize(self.mListSize.width,itemSize.height)
    item:setItemSize(self.mListSize.width,itemSize.height)

    local size = cc.size(bgWidth,50)
	bg = cc.ui.UIImage.new("picdata/fightteam/bg_list.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
	bg:setPosition(25,0)
	node:addChild(bg)
	local color = cc.c3b(255,255,255)
	if serData["2003"] == myInfo.data.userId then
		color = cc.c3b(0,255,255)
	end
    for i = 1,#labelText do
	     local content = cc.ui.UILabel.new({
	            text  = labelText[i].text  or "123",
	            size  = 22,
	            color = color,
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            --UILabelType = 1,
	            font  = "黑体",
	        })
	    content:setPosition(labelText[i].posx-80,bgHeight/2-5)
	    node:addChild(content)
	    if i == #labelText then
	    	content:setPosition(755 -content:getContentSize().width/2 ,bgHeight/2-5)
	    end
	 end
	 local selecthSprite = cc.ui.UIImage.new("picdata/fightteam/bg_list_xz.png", {scale9 = true})
	 selecthSprite:setLayoutSize(size.width,size.height)
	selecthSprite:setVisible(false)
	selecthSprite:setPosition(bg:getPositionX(),0)
	node:addChild(selecthSprite,0,101)
	self.mActivitySprite[idx] = node

	self.mAllItemHeight = self.mAllItemHeight + itemSize.height
    return item
end
-- function FTMemberListNode:touchRightListener(event)
-- 	local name, x, y = event.name, event.x, event.y	
-- 	 if name == "clicked" then
-- 	 	self:checkTouchInSprite_(event.itemPos)
-- 	 else
-- 		if name == "began" then
-- 	        self.touchBeganX = x
-- 	        self.touchBeganY = y
-- 	       return true
-- 	    end	    
-- 	 end
	
-- end
--[[
	列表下拉到底请求刷新
]]
function FTMemberListNode:touchRightListener(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	self:checkTouchInSprite_(event.itemPos)
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
	    		if event.itemPos >= self.mRequestNum then
	    			self.mItemChange = 1   --向下
    			else
    				self.mItemChange = -1 
    			end
	    	end
	    	if event.name == "scrollEnd" and self.mItemChange ~= -1 then
	    	   if self.mIsStopRequest then
	    	   		return 
	    	   else
	    	   		DBHttpRequest:getClubMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,myInfo.data.userId,self.mRequestFinishNum,self.mRequestNum)
	    	   end

		    end
	    end	    
	 end
	
end
--[[
	列表新增数据添加
]]
function FTMemberListNode:addListData(tableData)
	--dump(tableData)
	local height = self.mAllItemHeight --保留先前的高度
	local nextRankNum = self.mRequestFinishNum
	local addRankNum  = #tableData
	local allRankNum  = nextRankNum + addRankNum 
	local j = 1
	for i = nextRankNum+1,allRankNum  do 
		local item = self:createPageItem(i,tableData[j])
        self.mList:addItem(item)
		j = j+1		
	end	
	local y = height-self.mAllItemHeight
	if addRankNum>4 then
		y = y + 240
	else
		y = y + addRankNum*60
	end
	self.mList:reload()
	self.mList:scrollTo(0, y)
	self.mRequestFinishNum = self.mRequestFinishNum + addRankNum

	-- self.mList:moveItems(1,self.mRequestFinishNum,0,height)

	-- dump(self.mAllItemHeight,self.mRequestFinishNum)
	
end
--[[
	列表点击cell
]]
function FTMemberListNode:checkTouchInSprite_(index)
	if not index then return end
	if self.mLastIndex == index then 
		return 
	end	
	if self.mLastIndex and self.mActivitySprite[self.mLastIndex] then 
		self.mActivitySprite[self.mLastIndex]:getChildByTag(101):setVisible(false) 		--隐藏上一个节点
	end
	self.mLastIndex = index
	
	if self.mActivitySprite[self.mLastIndex] then 
		self.mActivitySprite[self.mLastIndex]:getChildByTag(101):setVisible(true) 		--显示已创建节点
	end
	
end
--[[
	更新成员列表
]]
function FTMemberListNode:updateMemberList()
	QDataFightTeamList:updateMsgMemberData(2,nil)
	if self.mList then self.mList:removeFromParent() self.mList = nil end
	self.mLastIndex = nil
	DBHttpRequest:getClubMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,myInfo.data.userId,0,self.mRequestNum)
	self:createButtonList()
end

--[[
	按钮列表
]]
function FTMemberListNode:createButtonList()
	if self.mButtonNode then self.mButtonNode:removeFromParent() self.mButtonNode = nil end
	local node = cc.Node:create()
	node:setPosition(80,-45)
	self.mBg:addChild(node)
	self.mButtonNode = node
	local tableData = QDataFightTeamList:getMsgData(2) or {}
	

	local labelText = {
		
		{textPath = "picdata/fightteam/w_btn_tczd.png",text = "退出战队",tag = EnumMenu.eBtnQuitTeam ,posx = 1},
		-- {textPath = textPath1,text = text1,tag = tag1 ,posx = 0},
		{textPath = "picdata/fightteam/w_btn_zc.png",text = "逐出",tag = EnumMenu.eBtnmMoveOut ,posx = 192},	
		{textPath = "picdata/fightteam/w_btn_sqlb.png",text = "申请列表",tag = EnumMenu.eBtnApplyList ,posx = 383,redDot = redNum},
		{textPath = "picdata/fightteam/w_btn_rm.png",text = "任命",tag = EnumMenu.eBtnAppointMent ,posx = 574},
		{textPath = "picdata/fightteam/w_btn_jlps.png",text = "奖励派送",tag = EnumMenu.eBtnAward ,posx = 765},
	}
	local sortText = {}
	if myInfo.data.userClubPos == "member" then
		sortText = {labelText[1],}
	elseif myInfo.data.userClubPos == "vice_chairman" then
		sortText = {labelText[1],labelText[2],labelText[3]}
	else
		sortText = labelText
	end
	self.mBtnGroup = {}
	local normatpath = "picdata/fightteam/btn_red.png"
	for i = 1,#sortText do
		if i ~= 1 then 
			normatpath = "picdata/fightteam/btn_grey.png"
		end
		local btnChangeNotice = CMButton.new({normal = normatpath},
			function () self:onMenuCallBack(sortText[i].tag) end,nil,{textPath = sortText[i].textPath})
		-- btnChangeNotice:setButtonLabel("normal",cc.ui.UILabel.new({
		--     --UILabelType = 1,
		--     color = cc.c3b(156, 255, 0),
		--     text = labelText[i].text,
		--     size = 28,
		--     font = "FZZCHJW--GB1-0",
		-- }) )    
		btnChangeNotice:setPosition(sortText[i].posx,0)
		node:addChild(btnChangeNotice)

		self.mBtnGroup[sortText[i].tag] = btnChangeNotice
	end


end
--[[
	更新按钮状态－－对应职位
]]
function FTMemberListNode:updateButtonPath(num)

	local textPath = "picdata/fightteam/w_btn_tczd.png"
	local tag      = EnumMenu.eBtnQuitTeam
	local text     = "退出战队"

	if myInfo.data.userClubPos == "chairman" and num <= 1 then
		textPath = "picdata/fightteam/w_btn_jszd.png"
		tag      = EnumMenu.eBtnDissolveTeam
		text     = "解散战队"
	end

	if self.mBtnGroup[self.mLastTag] then
		local node = self.mBtnGroup[self.mLastTag]:getParent()
		self.mBtnGroup[self.mLastTag]:removeFromParent()
		self.mBtnGroup[self.mLastTag] = nil
		local btnChangeNotice = CMButton.new({normal = "picdata/fightteam/btn_red.png"},
			function () self:onMenuCallBack(tag) end,nil,{textPath = textPath})
		btnChangeNotice:setPosition(0,0)
		node:addChild(btnChangeNotice)

		self.mBtnGroup[tag] = btnChangeNotice
		self.mLastTag = tag
	end
end
--[[
	按钮回调
]]
function FTMemberListNode:onMenuCallBack(tag)
	-- dump(tag)
	if tag == EnumMenu.eBtnAward then
		local userData = QDataFightTeamList:getMsgItemData(2,self.mLastIndex) or {}
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTRewardLayer")
		CMOpen(RewardLayer,self:getParent(),{userId = userData["2003"],userName = userData["2004"]})
		--DBHttpRequest:sentMoneyToMember(function(tableData,tag) self:httpResponse(tableData,tag) end,userId,100,myInfo.data.userClubId,"GOLD")
	elseif tag == EnumMenu.eBtnDissolveTeam then
		local data = {}
		data.title = "解散战队？"
		data.text  = "真的要解散你的战队？"
		data.showType = 2
		data.callOk   = function () DBHttpRequest:dissolveClub(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId) end
		self:showTipBox(data)
	elseif tag == EnumMenu.eBtnQuitTeam then
		if myInfo.data.userClubPos == "chairman" then
			local RewardLayer = require("app.Component.CMAlertDialog")
			local params = {
			okText = "我知道了",
			text = "你需要先任命新的队长，才可以\"退出战队\"，如果是需要\"解散战队\"，则需要先\"逐出\"所有成员。",
			showType = 1}
			CMOpen(RewardLayer, self:getParent(),params)
		end
		local data = {}
		data.title = "退出战队？"
		data.text  = "真的要退出战队？"
		data.showType = 2
		data.callOk   = function () DBHttpRequest:quitClub(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId) end
		self:showTipBox(data)
	elseif tag == EnumMenu.eBtnmMoveOut then
		local userData = QDataFightTeamList:getMsgItemData(2,self.mLastIndex) or {}
		-- dump(userData)
		if userData["2003"] == myInfo.data.userId then CMShowTip("无法逐出自己") return end
		if myInfo.data.userClubPos ~= "chairman" and userData["A10D"] ~= "member" then CMShowTip("暂无权限") return end
		local data = {}
		data.title = "逐出？"
		data.text  = string.format("确定将玩家;%s#06#22;逐出战队？",userData["2004"] or "")
		data.showType = 2
		data.callOk   = function () DBHttpRequest:kickOutMember(function(tableData,tag) self:httpResponse(tableData,tag) end,userData["2003"] or "",myInfo.data.userClubId) end
		self:showTipBox(data)
	elseif tag == EnumMenu.eBtnAppointMent then
		local userData = QDataFightTeamList:getMsgItemData(2,self.mLastIndex) or {}
		-- dump(userData)
		if myInfo.data.userClubPos == "chairman" and userData["2003"] == myInfo.data.userId then CMShowTip("无法任命自己") return end
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTAppointLayer")
		CMOpen(RewardLayer, self:getParent(),{userId = userData["2003"],userName = userData["2004"],userPos = userData["A10D"]})
	elseif tag == EnumMenu.eBtnApplyList then
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTApplyLayer")
		CMOpen(RewardLayer, self:getParent())
	elseif tag == EnumMenu.eBtnBack then
		local FTManager      = require("app.GUI.fightTeam.FTManager"):Instance()
		local FTMyTeamLayer = FTManager:getMyTeamLayer()
		FTMyTeamLayer:initNodeLabel(1)
	end
end
--[[
	显示提示框
]]
function FTMemberListNode:showTipBox(data)
	local RewardLayer = require("app.Component.CMAlertDialog")
	local params = {
	text = data.text,
	titleText = data.title,showType = data.showType,callOk = data.callOk}
	CMOpen(RewardLayer, self:getParent(),params)
end
--[[
	网络回调
]]
function FTMemberListNode:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_getClubMembers then 
		-- QDataFightTeamList:Init(tableData,2)
		-- if self.mBtnGroup[EnumMenu.eBtnApplyList] then
		-- 	if tonumber(tableData["APPLY_NUM"]) > 0 then
		-- 		self.mBtnGroup[EnumMenu.eBtnApplyList]:addRedDot()
		-- 	else
		-- 		self.mBtnGroup[EnumMenu.eBtnApplyList]:removeRedDot()
		-- 	end
		-- end
		-- QManagerListener:Notify({tag = "updateMemberRedDot",layerID = eFTMyTeamLayerID,num = tableData["APPLY_NUM"]})
		-- self:updateButtonPath(#tableData["MEMBER"])
		-- self:createTableViewNode()

		QDataFightTeamList:Init(tableData,2)
		local nNum = #tableData["MEMBER"]
		if nNum < self.mRequestNum then 
			self.mIsStopRequest = true 
			if nNum == 0 then return end
		end
		if not self.mList then
			if self.mBtnGroup[EnumMenu.eBtnApplyList] then
				if tonumber(tableData["APPLY_NUM"]) > 0 then
					self.mBtnGroup[EnumMenu.eBtnApplyList]:addRedDot()
				else
					self.mBtnGroup[EnumMenu.eBtnApplyList]:removeRedDot()
				end
			end
			QManagerListener:Notify({tag = "updateMemberRedDot",layerID = eFTMyTeamLayerID,num = tableData["APPLY_NUM"]})
			self:updateButtonPath(#tableData["MEMBER"])
			self:createTableViewNode()
		else
			self:addListData(tableData["MEMBER"])
		end

	elseif tag == POST_COMMAND_GET_dissolveClub then	
		GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
		CMDelay(GameSceneManager:getCurScene(),0.5,function () CMShowTip("解散成功") end)
	elseif tag == POST_COMMAND_GET_quitClub then
		if tonumber(tableData) == 10000 then
			CMShowTip("退队成功")
			CMDelay(GameSceneManager:getCurScene(),0.5,function () GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView) end)
		elseif tonumber(tableData) == -16001 then
			CMShowTip("队长不能退出")
		end
	elseif tag == POST_COMMAND_GET_kickOutMember then
		if tonumber(tableData) == 10000 then
			self:updateMemberList()
			QManagerListener:Notify({tag = "updateClubInfo",layerID = eFTMyTeamLayerID})
			CMShowTip("逐出成功")
		elseif tonumber(tableData) == -16001 then
			CMShowTip("队长不能逐出")
		end
	elseif tag == POST_COMMAND_GET_appointMember then
		if tonumber(tableData) == 10000 then
			self:updateMemberList()
			CMShowTip("任命成功")
		end
	end

end
return FTMemberListNode