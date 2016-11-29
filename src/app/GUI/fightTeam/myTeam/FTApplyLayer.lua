--
-- Author: junjie
-- Date: 2016-04-27 20:40:52
--
--申请列表
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTApplyLayer = class("FTApplyLayer",FightCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
local QDataFightTeamList = nil
local EnumMenu = {
	eBtnAccept 		 = 1,--同意
	eBtnRefuse		 = 2,--拒绝

} 
function FTApplyLayer:ctor()
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	self.mCheckBtn = {}
	self.mALlItem  = {}
	self.mIsNeedUpdate = false --是否需要刷新成员列表
	self.mApplyNum     = 0     --审核数量
end
function FTApplyLayer:onExit()
	if self.mIsNeedUpdate then
		QManagerListener:Notify({tag = "updateMemberList",layerID = eFTMyTeamLayerID})
		QManagerListener:Notify({tag = "updateClubInfo",layerID = eFTMyTeamLayerID})
		self.mIsNeedUpdate = false
	end
	self.mCheckBtn = {}
	self.mALlItem  = {}
	self.mApplyNum     = 0
end
--[[
	UI创建
]]
function FTApplyLayer:create()
	FTApplyLayer.super.ctor(self,{titlePath = "picdata/fightteam/w_title_sqlb.png",
		showType = 0,showLine = 0,size = cc.size(688,488)}) 
    FTApplyLayer.super.initSecondUI(self)
	self:createTitleNode()
	self:createButtonList()
	DBHttpRequest:getReviewClubList(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)	

	-- self:createTableViewNode()
end
--[[
	成员标签信息
]]
function FTApplyLayer:createTitleNode()
	local secBg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    secBg:setLayoutSize(644,290)
	secBg:setPosition(22,105)
	self.mBg:addChild(secBg)

	local labelSize = cc.size(610,46)
	local labelBg = cc.ui.UIImage.new("picdata/fightteam/bg_tag.png", {scale9 = true})
    labelBg:setLayoutSize(labelSize.width,labelSize.height)
	labelBg:setPosition(self.mBgWidth/2-labelSize.width/2,self.mBgHeight-145)
	self.mBg:addChild(labelBg)

	

	local labelSp = cc.Sprite:create("picdata/fightteam/tsg_sq.png")
	labelSp:setPosition(labelBg:getContentSize().width/2+20, labelBg:getContentSize().height/2)
	labelBg:addChild(labelSp)

	-- local bg = cc.Node:create()
	-- bg:setPosition(120,500)
	-- self:addChild(bg)
	-- local bgWidth = 300
	-- local bgHeight= 40

	local checkBoxImages = {off="picdata/fightteam/btn_choose.png",on="picdata/fightteam/btn_choose2.png"}
    local box = cc.ui.UICheckBoxButton.new(checkBoxImages)
    :onButtonStateChanged(handler(self,self.onCheckBtnSelect))
    :align(display.LEFT_TOP, 10,42)
    :addTo(labelBg) 

	-- local labelText = {
	-- 	{text = "玩家名称",posx = 100},{text = "牌手分",posx = 200},{text = "申请时间",posx = 300},
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
function FTApplyLayer:onCheckBtnSelect(event)
	local bCheck = event.target:isButtonSelected() 
	for i,v in pairs(self.mCheckBtn) do 
		v.box:setButtonSelected(bCheck)
	end
end
--[[
	按钮列表
]]
function FTApplyLayer:createButtonList()
	local node = cc.Node:create()
	node:setPosition(self.mBg:getContentSize().width/2,50)
	self.mBg:addChild(node)
	local labelText = {
		{textPath = "picdata/public/w_btn_qd.png",text = "同意",tag = EnumMenu.eBtnAward ,posx = -100},
		{textPath = "picdata/public/w_btn_jj.png",text = "拒绝",tag = EnumMenu.eBtnDissolveTeam ,posx = 100},
	}
	-- for i,v in pairs(labelText) do
	-- 	local btnChangeNotice = CMButton.new({normal = "picdata/public/confirmBtn.png",pressed = "picdata/public/confirmBtn2.png"},
	-- 		function () self:onMenuCallBack(i) end)
	-- 	btnChangeNotice:setButtonLabel("normal",cc.ui.UILabel.new({
	-- 	    --UILabelType = 1,
	-- 	    color = cc.c3b(156, 255, 0),
	-- 	    text = labelText[i].text,
	-- 	    size = 28,
	-- 	    font = "FZZCHJW--GB1-0",
	-- 	}) )    
	-- 	btnChangeNotice:setPosition(labelText[i].posx,0)
	-- 	node:addChild(btnChangeNotice)
	-- end
	local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnAccept) end,nil,{textPath = labelText[1].textPath})
	-- btnOk:setButtonLabel("normal",cc.ui.UILabel.new({
 --    --UILabelType = 1,
 --    color = cc.c3b(156, 255, 0),
 --    text = labelText[1].text,
 --    size = 28,
 --    font = "FZZCHJW--GB1-0",
	-- }) )    
	btnOk:setPosition(self.mBgWidth/2+140,60)
	self.mBg:addChild(btnOk,1)

	local btnCancel = CMButton.new({normal = "picdata/public2/btn_h74_blue.png",pressed = "picdata/public2/btn_h74_blue2.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnRefuse) end,nil,{textPath = labelText[2].textPath})
	-- btnCancel:setButtonLabel("normal",cc.ui.UILabel.new({
 --    --UILabelType = 1,
 --    color = cc.c3b(129, 163, 229),
 --    text = labelText[2].text,
 --    size = 28,
 --    font = "FZZCHJW--GB1-0",
	-- }) )    
	btnCancel:setPosition(self.mBgWidth/2 - 140,60)
	self.mBg:addChild(btnCancel,1)
end
--[[
同意，拒绝申请
]]
function FTApplyLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnAccept or tag == EnumMenu.eBtnRefuse then
		local applyId = ""
		self.mApplyNum  = 0
		for i,v in pairs(self.mCheckBtn) do 
			if v and v.box and v.box.isButtonSelected and v.box:isButtonSelected() then
				if applyId == "" then
					applyId = applyId .. v.applyId
				else
					applyId = applyId ..",".. v.applyId
				end
				self.mApplyNum = self.mApplyNum + 1
			end
		end
		if applyId == "" then return end
		local nType = "REJECT"
		if tag == EnumMenu.eBtnAccept then
			nType = "EXAMINED"			
		end
		DBHttpRequest:ReviewClubList(function(tableData,tag,itemData) self:httpResponse(tableData,tag,applyId) end,myInfo.data.userClubId,applyId,nType)
	end
end
--[[
	成员申请列表
]]
function FTApplyLayer:createTableViewNode()
	-- body
	local tableData = QDataFightTeamList:getMsgData("memberApplyList") or {}
	if self.mList then self.mList:removeFromParent() self.mList = nil end
	 if type(tableData) == "table" and #tableData == 0 then return end
	 -- tableData = {[1]={},[2]={},[3]={}}
    self.mListSize = cc.size(610,230  ) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(40, 108, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg)    
   self.mCheckBtn = {}
    for i = 1,#tableData do
    -- for i = 1,10 do  
        local item = self:createPageItem(i,tableData[i])
        self.mList:addItem(item)
    end 

    self.mList:reload() 
end
function FTApplyLayer:createPageItem(idx,serData)
	serData = serData or {}
	local applyId = serData["501B"] or ""
    local item = self.mList:newItem()  
	local labelText = {
		{text = serData["2004"],posx = 150},{text = serData["4055"],posx = 390},{text = string.gsub(serData["4016"] or "","( ).+",""),posx = 530},
	}
    local node = cc.Node:create() 
    local itemSize = cc.size(self.mListSize.width,60)
	local bgWidth = itemSize.width
    local bgHeight= itemSize.height
     item:addContent(node)
    node:setContentSize(self.mListSize.width,itemSize.height)
    item:setItemSize(self.mListSize.width,itemSize.height)

    local size = cc.size(bgWidth,bgHeight)
	bg = cc.ui.UIImage.new("picdata/fightteam/bg_list.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height-8)
	bg:setPosition(0,0)
	node:addChild(bg)

    local checkBoxImages = {off="picdata/fightteam/btn_choose.png",on="picdata/fightteam/btn_choose2.png"}
    local box = cc.ui.UICheckBoxButton.new(checkBoxImages)
    :onButtonStateChanged(function(event)
    	--local bCheck = event.target:isButtonSelected()       
    end)
    :align(display.LEFT_TOP,10,42)
    :addTo(node,1) 
    box:setScale(0.8)

    for i = 1,#labelText do
	     local content = cc.ui.UILabel.new({
	            text  = labelText[i].text or "123",
	            size  = 22,
	            color = cc.c3b(255, 255, 255),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            --UILabelType = 1,
	            font  = "黑体",
	        })
	    content:setPosition(labelText[i].posx-50,bgHeight/2-4)
	    node:addChild(content)
	 end

	self.mCheckBtn[idx] = {}
	self.mCheckBtn[idx].box 	= box
	self.mCheckBtn[idx].applyId  = applyId
    return item
end

--[[
	网络回调
]]
function FTApplyLayer:httpResponse(tableData,tag,itemData)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_getReviewClubList then 
		QDataFightTeamList:Init(tableData,"memberApplyList")
		self:createTableViewNode()
	elseif tag == POST_COMMAND_GET_ReviewClubList then
		
		if type(tableData) ~= "table" then
			local errorCode = tonumber(tableData)
			if errorCode == -15016 then
				CMShowTip("人数已达上线")
			elseif errorCode == -16001 then
			 	CMShowTip("没有权限")
			end 
			return 
		end
		local sucNum = tonumber(tonumber(tableData[1]["700C"]))
		local tips = "审核通过" .. sucNum .. "个"
		if self.mApplyNum > sucNum then 
			tips = tips .. ",失败" .. (self.mApplyNum-sucNum) .. "个"
		end
		if sucNum > 0 then
			self.mIsNeedUpdate = true
		end
		CMShowTip(tips)
		DBHttpRequest:getReviewClubList(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)

	end

end
return FTApplyLayer