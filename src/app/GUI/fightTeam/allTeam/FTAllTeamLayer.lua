--
-- Author: junjie
-- Date: 2016-04-20 16:13:27
--
--所有战队列表信息
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTAllTeamLayer = class("FTAllTeamLayer",FightCommonLayer)
local CMGroupButton = require("app.Component.CMGroupButton")
local myInfo = require("app.Model.Login.MyInfo")
local CMColorLabel     = require("app.Component.CMColorLabel")
require("app.Network.Http.DBHttpRequest") 
require("app.CommonDataDefine.CommonDataDefine")
local QDataFightTeamList = nil
local EnumMenu = {
	eBtnTeamName = 1, 		--按队名搜
	eBtnTeamHead = 2,		--按对战搜
	eBtnCreateTeam=3,		--创建战队
	eBtnSelectName=4,		--选择队名
	eBtnSelectHead=5,
	eBtnBack 	  =6,		--返回列表
	eBtnSearch	  =7, 		--搜索
	eBtnFindBack  =8,		--搜索找到返回
	eBtnHelp	  =9,		--帮助
}
local searchNname = {
	[2] = "队名",
	[3] = "队长",
}
function FTAllTeamLayer:ctor()
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	self.mAllAddBtn  = {}
	self.mFindName   = ""	 --查找内容
	self.mSelectType = 3     --默认是队长
	self.mRequestNum     = 15 --每次请求数量
	self.mRequestFinishNum=0 --当前已请求数量
	self.mIsStopRequest   = false --停止请求
	self.mDataType   	= "teamList"
	self.mAllItemHeight = 0
end
function FTAllTeamLayer:onExit()
	self.mAllAddBtn  = {}
	QDataFightTeamList:removeMsgData()
	QManagerListener:Detach(eFTAllTeamLayerID)

end
function FTAllTeamLayer:onEnter()
	QManagerListener:Attach({{layerID = eFTAllTeamLayerID,layer = self}})
end
function FTAllTeamLayer:updateCallBack(data)
	if data.tag == "showInputBox" then
		self.mChatBox:setVisible(true)
	end
end
--[[
	UI创建
]]
function FTAllTeamLayer:create()
	FTAllTeamLayer.super.ctor(self,{bgType = 2,titlePath = "picdata/fightteam/w_t_zd.png",size = cc.size(CONFIG_SCREEN_WIDTH,display.height)}) 
    FTAllTeamLayer.super.initUI(self)
    self:createTitleNode()
    self:onGroupCallBack(1)
    --test
	-- self:createTableViewNode()
	-- self:createButtonNode()
	-- self:createGroupButton()
	-- self:searchNotFind()
end
-- function FTAllTeamLayer:createGroupButton()
-- 	local groupBtn = CMGroupButton.new({callback = handler(self,self.onGroupCallBack),
-- 	name = {"战队列表","搜队名","搜队长","立即申请"},
-- 	size = cc.size(600,60),
-- 	direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,})
-- 	groupBtn:create()
-- 	groupBtn:setPosition(40,self.mBg:getContentSize().height-80)
-- 	groupBtn:setTouchEnabled(false)	
-- 	self.mBg:addChild(groupBtn)
-- 	groupBtn:checkTouchInSprite_(1)
-- 	self.groupBtn = groupBtn
-- end
--[[
	按钮回调
]]
function FTAllTeamLayer:onGroupCallBack(index,data)
	if index == 1 then 		--战队列表
		DBHttpRequest:getClubApplyList(function(tableData,tag) self:httpResponse(tableData,tag) end)	
		DBHttpRequest:getClubList(function(tableData,tag) self:httpResponse(tableData,tag) end,0,self.mRequestNum)
	elseif index == 2 then  --搜队名
		self.mFindName = self.mChatBox:getText()
		if self.mFindName ~= "" then
			-- dump(self.mFindName)
			DBHttpRequest:searchClub(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mFindName,"")
		end
	elseif index == 3 then  --搜队长
		self.mFindName = self.mChatBox:getText()
		if self.mFindName ~= "" then
			DBHttpRequest:searchClub(function(tableData,tag) self:httpResponse(tableData,tag) end,"",self.mFindName)
		end
	elseif index == 4 then  --立即加入
		DBHttpRequest:applyClub(function(tableData,tag,index) self:httpResponse(tableData,tag,data.idx) end,data.clubId)
	end
end
--[[
	战队、队长搜索
]]
function FTAllTeamLayer:createSearchNode(bg)

	local btnTeamSelect = CMButton.new({normal = "picdata/public/transBG.png"},function () self:onMenuCallBack(EnumMenu.eBtnSelect) end,nil,{scale = false})
	btnTeamSelect:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(178, 188, 214),
	    text = "队长",
	    size = 24,
	    font = "FZZCHJW--GB1-0",
	}) )    
	btnTeamSelect:setPosition(100,65)
	bg:addChild(btnTeamSelect)

	local arrow = cc.Sprite:create("picdata/fightteam/btn_px2.png")
	arrow:setPosition(35, 0)
	btnTeamSelect:addChild(arrow)

	local node = cc.Sprite:create("picdata/fightteam/bg.png")
	
	node:setPosition(110, -30)
	bg:addChild(node)
	local btnTeamHead = CMButton.new({normal = "picdata/public/transBG.png"},function () self:onMenuCallBack(EnumMenu.eBtnSelectHead) end,nil,{scale = false})
	btnTeamHead:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(95, 107, 131),
	    text = "队长",
	    size = 28,
	    font = "FZZCHJW--GB1-0",
	}) )    
	btnTeamHead:setPosition(100,40)
	node:addChild(btnTeamHead,0,101)

	local btnTeamName = CMButton.new({normal = "picdata/public/transBG.png"},function () self:onMenuCallBack(EnumMenu.eBtnSelectName) end,nil,{scale = false})
	btnTeamName:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 255),
	    text = "队名",
	    size = 28,
	    font = "FZZCHJW--GB1-0",
	}) )    
	btnTeamName:setPosition(100,110)
	node:addChild(btnTeamName,0,102)

	self.mBtnTeamHead = btnTeamHead
	self.mBtnTeamName = btnTeamName
	self.mBtnTeamSelect=btnTeamSelect
	self.mSelectTypeBg = node
	self.mSelectTypeBg:setVisible(false)
end
--[[
	战队信息标签
]]
function FTAllTeamLayer:createTitleNode()
	-- local infoData = QDataFightTeamList:getMsgData(1,"ClubInfo")
	-- dump(infoData)
	-- local bg = cc.Node:create()
	local size = cc.size(928,498)
	viewbg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    viewbg:setLayoutSize(size.width,size.height)
	viewbg:setPosition(self.mBgWidth/2-size.width/2,self.mBgHeight/2-280)
	self.mBg:addChild(viewbg)

	local size = cc.size(946,112)
	bg = cc.ui.UIImage.new("picdata/fightteam/searchbg.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
	bg:setPosition(self.mBgWidth/2-size.width/2,self.mBgHeight-210)
	self.mBg:addChild(bg,1)
	local searchBg = cc.ui.UIImage.new("picdata/fightteam/bg_seach.png", {scale9 = true})
    searchBg:setLayoutSize(636,58)
	searchBg:setPosition(60,size.height/2-20)
	bg:addChild(searchBg)
	self:createSearchNode(bg)
	local tips = cc.ui.UILabel.new({
            text  = "所有战队信息",
            size  = 20,
            color = cc.c3b(178, 188, 214),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
	tips:setPosition(self.mBgWidth/2-tips:getContentSize().width/2,self.mBgHeight/2+100)
	self.mBg:addChild(tips)


	local labelSize = cc.size(884,48)
	local labelBg = cc.ui.UIImage.new("picdata/fightteam/bg_tag.png", {scale9 = true})
    labelBg:setLayoutSize(labelSize.width,labelSize.height)
	labelBg:setPosition(self.mBgWidth/2-labelSize.width/2,self.mBgHeight/2+30)
	self.mBg:addChild(labelBg)

	local bgWidth = 300
	local bgHeight= 40
	-- local labelText = {
	-- 	{text = "战队名称",posx = 30},{text = "队长名称",posx = 250},{text = "战队等级",posx = 500},
	-- 	{text = "人数",posx = 620},{text = "申请状态",posx = 750},
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
 --    	content:setPosition(labelText[i].posx,labelSize.height/2)
 --   	 	labelBg:addChild(content)
	-- end
	local labelSp = cc.Sprite:create("picdata/fightteam/tag_01.png")
	labelSp:setPosition(labelBg:getContentSize().width/2, labelBg:getContentSize().height/2)
	labelBg:addChild(labelSp)
	local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        forePath  = "picdata/fightteam/btn_seach.png",
        maxLength = 60,
        place     = "",--" 输入名称,友谊小船从此起航"
        color     = cc.c3b(76,198,255),
        fontSize  = 24,
        bgPath    = "picdata/public/transBG.png" ,  
        foreAlign = CMInput.RIGHT, 
        scale9    = true,
        size      = cc.size(535,58) ,    
        -- listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
        foreCallBack = function () self:onMenuCallBack(EnumMenu.eBtnSearch) end
    })
    inputBox:setPosition(100,0)
    searchBg:addChild(inputBox )

	self.mChatBox = inputBox

	local btnCreate = CMButton.new({normal = "picdata/fightteam/btn_bg_green.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnCreateTeam) end,nil,{textPath = "picdata/fightteam/w_cjzd.png"})
	-- btnCreate:setButtonLabel("normal",cc.ui.UILabel.new({
	--     --UILabelType = 1,
	--     color = cc.c3b(156, 255, 0),
	--     text = "创建战队",
	--     size = 28,
	--     font = "FZZCHJW--GB1-0",
	-- }) )    
	btnCreate:setPosition(820,size.height/2+7)
	bg:addChild(btnCreate)

	local btnRule = CMButton.new({normal = "picdata/fightteam/btn_qa.png",pressed = "picdata/fightteam/btn_qa2.png"},function () self:onMenuCallBack(EnumMenu.eBtnHelp) end)
	btnRule:setPosition(890,size.height/2+105)
	bg:addChild(btnRule)

	self.mSearchTips = tips
end

--[[
	战队详细信息
]]
function FTAllTeamLayer:createTableViewNode(data)
		-- body
    -- tableData = {{["content"] = 1},{["content"] = 12}}
    local tableData = data or QDataFightTeamList:getMsgData(self.mDataType) or {}
    -- dump(tableData)
    if self.mList then self.mList:removeFromParent() self.mList = nil end
    self.mListSize = cc.size(884,300  ) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(self.mBgWidth/2-self.mListSize.width/2, 45, self.mListSize.width, self.mListSize.height),       
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
end
function FTAllTeamLayer:createPageItem(idx,serData)
	-- dump(serData)
	serData = serData or {}
	local textValue = {serData["A101"] or "0",serData["A103"]or "0",serData["A107"]or "0",serData["CUR_NUM"]or "0"}
	local clubId    = serData["A100"]
	local isApply   = QDataFightTeamList:checkIsApply(clubId)
    local item = self.mList:newItem()  
   
    local node = cc.Node:create() 
    local itemSize = cc.size(self.mListSize.width,92)
	local bgWidth = itemSize.width
    local bgHeight= itemSize.height
     item:addContent(node)
    node:setContentSize(self.mListSize.width,itemSize.height)
    item:setItemSize(self.mListSize.width,itemSize.height)

    local size = cc.size(bgWidth,bgHeight)
	bg = cc.ui.UIImage.new("picdata/fightteam/bg_list2.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height-8)
	bg:setPosition(0,0)
	node:addChild(bg)

    local posxAdd = {35,235,265,115}
    local posx = 0
    local lens = string.len(self.mFindName)

    for i = 1,4 do 
    	posx = posx + posxAdd[i]
    	local content
    	local index = string.find(textValue[i],self.mFindName)
    	if lens == 0 or not index  then
	      content = cc.ui.UILabel.new({
	            text  = textValue[i] or "",
	            size  = 22,
	            color = cc.c3b(255, 255, 255),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            --UILabelType = 1,
	            font  = "黑体",
	        })
		else
			local str1 = string.sub(textValue[i],1,index-1) or ""
			local str2 = string.sub(textValue[i],index,index+lens-1) or ""
			local str3 = string.sub(textValue[i],index+lens,-1) or ""
			local text = string.format("%s#01#22;%s#08#22;%s#01#22",str1,str2,str3)
			if str1 == "" then
				text = string.format("%s#08#22;%s#01#22",str2,str3)
			end
			content = CMColorLabel.new({text = text})
			-- dump(string.sub(textValue[i],1,lens),string.sub(textValue[i],lens,-1))
	    	-- content = CMColorLabel.new({text = string.format("%s#08#22;%s#01#22",string.sub(textValue[i],1,lens),string.sub(textValue[i],lens,-1))})
	    end
	    content:setPosition(posx ,bgHeight/2-5)
	    node:addChild(content)
	end
	

	local btnAdd = nil
	if isApply then
		btnAdd = cc.ui.UILabel.new({
	            text  = "申请中...",
	            size  = 22,
	            color = cc.c3b(215, 255, 178),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            --UILabelType = 1,
	            font  = "黑体",
	        })
		btnAdd:setPosition(750, bgHeight/2-5)
	else
		btnAdd = CMButton.new({normal = "picdata/fightteam/btn_bg_green3.png"},
			function () 
				self:onGroupCallBack(4,{idx = idx,clubId = clubId})
			 end)
		btnAdd:setButtonLabel("normal",cc.ui.UILabel.new({
		    --UILabelType = 1,
		    color = cc.c3b(215, 255, 178),
		    text = "申请加入",
		    size = 24,
		    font = "FZZCHJW--GB1-0",
		}) )    
		btnAdd:setPosition(790,bgHeight/2-5)
		btnAdd:getButtonLabel("normal"):setLocalZOrder(1)
		btnAdd:setTouchSwallowEnabled(false)
		btnAdd:getButtonLabel("normal"):enableShadow(cc.c4b(0,0,0,153),cc.size(0,-2))
	end
	
	node:addChild(btnAdd)
	self.mAllAddBtn[idx] = btnAdd

	-- if isApply then
	-- 	self:updateApplyTeam(idx)
	-- end
	self.mAllItemHeight = self.mAllItemHeight + itemSize.height
    return item
end
--[[
	更新申请状态
]]
function FTAllTeamLayer:updateApplyTeam(idx)
	-- self.mAllAddBtn[idx]:setTexture("picdata/public/btn_1_110_green.png",true)
	-- self.mAllAddBtn[idx]:setButtonEnabled(false)
	local posy = self.mAllAddBtn[idx]:getPositionY()
	local node = self.mAllAddBtn[idx]:getParent()
	if self.mAllAddBtn[idx] then
		self.mAllAddBtn[idx]:removeFromParent()
	end
	self.mAllAddBtn[idx] = cc.ui.UILabel.new({
        text  = "申请中...",
        size  = 22,
        color = cc.c3b(215, 255, 178),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
    self.mAllAddBtn[idx]:setPosition(750,posy)
	node:addChild(self.mAllAddBtn[idx])
end
--[[
	创建未搜索节点
]]
function FTAllTeamLayer:searchNotFind()
	if self.NoFindNode then self.NoFindNode:removeFromParent() self.NoFindNode = nil end
	self.NoFindNode = cc.Node:create()
	self.mBg:addChild(self.NoFindNode,1)
	local str1 = string.format("你搜索的\“;%s#06#24;\”%s不存在",self.mFindName,searchNname[self.mSelectType])
	local str2 = string.format("尝试使用其它关键词？")
	local name = CMColorLabel.new({text = str1})
	name:setPosition(self.mBgWidth/2-name:getContentWidth()/2,240)
	self.NoFindNode:addChild(name,0)

	local tip2 = cc.ui.UILabel.new({
        text  = str2,
        size  = 22,
        color = cc.c3b(255, 255, 255),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
    tip2:setPosition(self.mBgWidth/2-tip2:getContentSize().width/2,210)
	self.NoFindNode:addChild(tip2)

	btnBack = CMButton.new({normal = "picdata/fightteam/btn_reback.png"},
			function () self:onMenuCallBack(EnumMenu.eBtnBack) end,nil,{textPath = "picdata/fightteam/btn_fhlb.png",offx=10,offy=3})
	-- btnBack:setButtonLabel("normal",cc.ui.UILabel.new({
	--     --UILabelType = 1,
	--     color = cc.c3b(156, 255, 0),
	--     text = "返回列表",
	--     size = 28,
	--     font = "FZZCHJW--GB1-0",
	-- }) )    
	btnBack:setPosition(self.mBgWidth/2 + 450-btnBack:getButtonSize().width/2,80)
	-- btnBack:getButtonLabel("normal"):setLocalZOrder(1) 
	self.NoFindNode:addChild(btnBack)
end
--[[
	添加单条搜寻结果
]]
function FTAllTeamLayer:AddSearchResultCell(tableData)
	self.mSearchTips:setString("搜索信息")
	if #tableData == 0 then 
		if self.mList then self.mList:setVisible(false) end
		self:searchNotFind()
		return 
	else
		self:createTableViewNode(tableData)
		local btnBack = CMButton.new({normal = "picdata/fightteam/btn_reback.png"},
				function () self:onMenuCallBack(EnumMenu.eBtnFindBack) end,nil,{textPath = "picdata/fightteam/btn_fhlb.png",offx=10,offy=3})
		btnBack:setPosition(self.mBgWidth/2 + 450-btnBack:getButtonSize().width/2,80) 
		self.mList:addChild(btnBack)

	end
end
--[[
	更新战队列表
]]
function FTAllTeamLayer:updateTableView()

end
-- 输入事件监听方法
function FTAllTeamLayer:onEdit(event, editbox)
    if event == "began" then
    -- 开始输入
        --print("开始输入")
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
        local _text = editbox:getText()
		local _trimed = string.trim(_text)		
		if _trimed ~= _text then			
		    editbox:setText(_trimed)
		end
    elseif event == "ended" then
    -- 输入结束
        local _text = editbox:getText()
		if _text == "" then
			self.mFindName   = ""
			-- self:createTableViewNode()
		end
        --print("输入结束")        
    elseif event == "return" then
    	
    	
    -- 从输入框返回
        --print("从输入框返回")       
    end

end
--[[
	按钮回调
]]
function FTAllTeamLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnTeamName then 		--old test
	elseif tag == EnumMenu.eBtnTeamHead  then
	elseif tag == EnumMenu.eBtnCreateTeam then
		self.mChatBox:setVisible(false)
		local RewardLayer      = require("app.GUI.fightTeam.allTeam.FTCreateTeamLayer")
		CMOpen(RewardLayer,self) 
	elseif tag == EnumMenu.eBtnSelectName then
		-- self.mBtnTeamName:setPositionY(60)
		-- self.mBtnTeamHead:setPositionY(30)
		-- self.mBtnTeamHead:setVisible(not self.mBtnTeamHead:isVisible())
		self.mSelectTypeBg:getChildByTag(101):getButtonLabel("normal"):setColor(cc.c3b(95,107,131))
		self.mSelectTypeBg:getChildByTag(102):getButtonLabel("normal"):setColor(cc.c3b(255,255,255))
		self.mSelectTypeBg:setVisible(false)
		self.mBtnTeamSelect:getButtonLabel("normal"):setString("队名")
		self.mSelectType = 2
	elseif tag == EnumMenu.eBtnSelectHead then
		-- self.mBtnTeamName:setPositionY(30)
		-- self.mBtnTeamHead:setPositionY(60)
		-- self.mBtnTeamName:setVisible(not self.mBtnTeamName:isVisible())
		self.mSelectTypeBg:getChildByTag(102):getButtonLabel("normal"):setColor(cc.c3b(95,107,131))
		self.mSelectTypeBg:getChildByTag(101):getButtonLabel("normal"):setColor(cc.c3b(255,255,255))
		self.mSelectTypeBg:setVisible(false)
		self.mBtnTeamSelect:getButtonLabel("normal"):setString("队长")
		self.mSelectType = 3
	elseif tag == EnumMenu.eBtnBack then
		self.mChatBox:setText("")
		self.mSearchTips:setString("所有战队信息")
		if self.NoFindNode then self.NoFindNode:removeFromParent() self.NoFindNode = nil end
		if self.mList then  self.mList:setVisible(true) self.mList:reload() end
	elseif tag == EnumMenu.eBtnSearch then
		if self.NoFindNode then self.NoFindNode:removeFromParent() self.NoFindNode = nil end
		self:onGroupCallBack(self.mSelectType)
	elseif tag == EnumMenu.eBtnFindBack then
		self.mChatBox:setText("")
		self.mSearchTips:setString("所有战队信息")
		self:createTableViewNode()
	elseif tag == EnumMenu.eBtnSelect then
		self.mSelectTypeBg:setVisible(not self.mSelectTypeBg:isVisible())
	elseif tag == EnumMenu.eBtnHelp then
		local RewardLayer = require("app.Component.CMAlertDialog")
			CMOpen(RewardLayer, self,{scroll = true,text = "战队新玩法，更有趣的社交功能，寻找志同道合、兴趣相投的小伙伴，可在战队中使用聊天及约局功能哟。\nVIP6以上玩家可创建自己的战队，每天完成战队任务，可获得战队经验值。战队等级会随着经验值的累积而升级。但是如果达不到最低经验值要求，也会有战队降级甚至解散的风险哦。每月达到一定活跃值的战队还会有特别定制战队专属赛奖励哦，其他战队活动不久后也将与广大玩家朋友们见面。届时不仅游戏和比赛形式更为丰富，各类金币、道具、实物奖励也将更为丰厚。",
			showType = 0,showLine = 0,titleText = "战队介绍",showBox = false,
		})
	end
end
--[[
	列表下拉新增新的cell
]]
function FTAllTeamLayer:addListData(tableData,nType)
	--dump(tableData)
	local height = self.mAllItemHeight --保留先前的高度
	local nextRankNum = self.mRequestFinishNum
	local addRankNum  = #tableData
	local allRankNum  = nextRankNum + addRankNum 
	local j = 1
	for i = nextRankNum+1,allRankNum  do 
		-- dump(i,j)
		local item = self:createPageItem(i,tableData[j])
        self.mList:addItem(item)
		j = j+1		
	end	
	self.mList:reload()
	self.mRequestFinishNum = self.mRequestFinishNum + addRankNum

	self.mList:moveItems(1,self.mRequestFinishNum,0,height)

	-- dump(self.mAllItemHeight,self.mRequestFinishNum)
	
end
--[[
	列表下拉到底部检测是否需要请求新数据
]]
function FTAllTeamLayer:touchRightListener(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	-- self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos)
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
	    	   		DBHttpRequest:getClubList(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mRequestFinishNum,self.mRequestNum)
	    	   end

		    end
	    end	    
	 end
	
end
--[[
	网络回调
]]
function FTAllTeamLayer:httpResponse(tableData,tag,idx)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_getClubList then 
		if type(tableData) ~= "table" then return end
		QDataFightTeamList:Init(tableData,self.mDataType )
		local nNum = #tableData
		if nNum < self.mRequestNum then 
			self.mIsStopRequest = true 
			if nNum == 0 then return end
		end
		if not self.mList then
			self:createTableViewNode()
		else
			self:addListData(tableData,self.mDataType )
		end
	elseif tag == POST_COMMAND_GET_searchClub then
		self:AddSearchResultCell(tableData)
	elseif tag == POST_COMMAND_GET_getClubApplyList then
		QDataFightTeamList:Init(tableData,"applyList")
	elseif tag == POST_COMMAND_GET_applyClub then
		if tonumber(tableData) == 10000 then
			self:updateApplyTeam(idx)
			CMShowTip("申请成功,请等待审核")
		else
			CMShowTip("申请加入失败,请重试")
		end
	end

end
return FTAllTeamLayer