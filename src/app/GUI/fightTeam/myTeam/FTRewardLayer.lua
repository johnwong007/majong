--
-- Author: junjie
-- Date: 2016-04-28 11:35:55
--
--申请列表
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTRewardLayer = class("FTRewardLayer",FightCommonLayer)
local CMColorLabel     = require("app.Component.CMColorLabel")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
local QDataFightTeamList = nil
local EnumMenu = {
	eBtnSure 		 = 1,--同意
	eBtnCancel		 = 2,--拒绝

} 
function FTRewardLayer:ctor(params)
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	local data = QDataFightTeamList:getMsgData(1,"ClubInfo") or {}
	self.params 	   = params or {}
	self.mUserId 	   = self.params.userId or "0"
	self.mUserName     = self.params.userName or "0"
	self.mInputBox     = {}
	self.mTips         = {}
	self.mTotalNum     = {}
	self.mTotalNum[1]  = tonumber(data["A108"] or 0)
	self.mTotalNum[2]  = tonumber(data["5051"] or 0)
end
function FTRewardLayer:onExit()
	
end
--[[
	UI创建
]]
function FTRewardLayer:create()
	FTRewardLayer.super.ctor(self,{titlePath = "picdata/fightteam/t_fffl.png",
		showType = 2,isOkClose = 0,callOk = function () self:onMenuCallBack(EnumMenu.eBtnSure) end}) 
    FTRewardLayer.super.initSecondUI(self)
    self:createTitleNode()
	self:createButtonGroup()
end
--[[
	成员标签信息
]]
function FTRewardLayer:createTitleNode()
	local bg = cc.Node:create()
	bg:setPosition(120,500)
	self.mBg:addChild(bg)
	local bgWidth = 300
	local bgHeight= 40

	local labelText = {
		{text = string.format("战队基金：%s",self.mTotalNum[1])},
		{text = string.format("战队积分：%s",self.mTotalNum[2])},
		{text = string.format("发放福利给玩家：;%s#08#24;",self.mUserName )},
	}
	local posy = 280
	for i = 1,#labelText do 
		local name = CMColorLabel.new({text = labelText[i].text,size = 24})
		name:setPosition(50,posy)
		self.mBg:addChild(name)

   	 	if i == 2 then
   	 		posy = posy - 35
   	 	end
   	 	self.mTips[i] = name
	end

	local size = cc.size(346,60)
	bg = cc.ui.UIImage.new("picdata/fightteam/bg_tag.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
	bg:setPosition(self.mBgWidth/2 - 100,self.mBgHeight/2 - 40)
	self.mBg:addChild(bg,1)

	local sTip = cc.ui.UILabel.new({text = "金币",
		size = 26,
		textAlign = cc.TEXT_ALIGNMENT_LEFT,})	
	sTip:setPosition(20,size.height/2)
	bg:addChild(sTip,0)

	local shutiao = cc.ui.UIImage.new("picdata/fightteam/shutiao.png", {scale9 = true})
	shutiao:setLayoutSize(4,40)
	shutiao:setPosition(80,10)
	bg:addChild(shutiao,0)

	local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 12,
        place     = "0",
        placeColor= cc.c3b(255,255,255),
        color     = cc.c3b(255, 255, 255),
        fontSize  = 30,
        bgPath    = "picdata/public/transBG.png" ,  
        foreAlign = CMInput.LEFT, 
        scale9    = true,
        size      = cc.size(380,40) ,  
        inputMode = 2,       
        listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setPosition(100,size.height/2-20)
    bg:addChild(inputBox )
    inputBox:setText("0")

	self.mInputBox = inputBox
	self.mTips["tips"] = sTip
	-- self:showTips()
end
--[[
	按钮切换，刷新提示
]]
function FTRewardLayer:updateTips(nType)
	self.mTips[nType]:removeFromParent()

	local labelText = {
		{text = string.format("战队基金：%s",self.mTotalNum[1])},
		{text = string.format("战队积分：%s",self.mTotalNum[2])},
	}
	local posy = 280
	
	local name = CMColorLabel.new({text = labelText[nType].text,size = 24})
	name:setPosition(50,posy)
	self.mBg:addChild(name)
	self.mTips[nType] = name
end
--[[
	显示提示语
]]
function FTRewardLayer:showTips(nType)
	if self.mTipNode then self.mTipNode:removeFromParent() self.mTipNode = nil end

	self.mTipNode = cc.Node:create()
	self.mBg:addChild(self.mTipNode)

	local text = "发放奖励不能为空"
	if nType == 2 then
		if self.mSelectType == 1 then
			text = "奖励超过基金余额"
		else
			text = "奖励超过积分余额"
		end

	end
	local sTip = cc.ui.UILabel.new({text = text,
		color = cc.c3b(255,90,0),
		size = 24,
		textAlign = cc.TEXT_ALIGNMENT_LEFT,})	
	sTip:setPosition(self.mBgWidth/2-sTip:getContentSize().width/2,self.mBgHeight/2-65)
	self.mTipNode:addChild(sTip,0)

	local tipSp = cc.Sprite:create("picdata/fightteam/icon_warning.png")
	tipSp:setPosition(sTip:getPositionX()-30, self.mBgHeight/2-65)
	self.mTipNode:addChild(tipSp)
end
	
--[[
	tabbar按钮
	]]
function FTRewardLayer:createButtonGroup()

    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/fightteam/btn_jl.png",on = "picdata/fightteam/btn_jl2.png",}))
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/fightteam/btn_jl.png",on = "picdata/fightteam/btn_jl2.png",}))
   
    :setButtonsLayoutMargin(0, 10, 0, 0)
    :onButtonSelectChanged(function(event)
        local group = self.mGroup:getButtonAtIndex(event.selected)
        if event.selected == 1 then
        	self.mGroup:getButtonAtIndex(1):setOpacity(255)
        	self.mGroup:getButtonAtIndex(2):setOpacity(255*0.8)
        	self.mTips["tips"]:setString("金币")
        	self.mTips[1]:setVisible(true)
        	self.mTips[2]:setVisible(false)
        	self.mSelectType = event.selected
        elseif event.selected == 2 then
        	self.mGroup:getButtonAtIndex(2):setOpacity(255)
        	self.mGroup:getButtonAtIndex(1):setOpacity(255*0.8)
        	self.mTips["tips"]:setString("积分")
        	self.mTips[2]:setVisible(true)
        	self.mTips[1]:setVisible(false)
        	self.mSelectType = event.selected
        end
       
    end)
    :align(display.LEFT_TOP, 40,150)
    :addTo(self.mBg)
     self.mGroup = group
    
    local jb = cc.Sprite:create("picdata/fightteam/icon_jb.png")
    jb:setPosition(-1, -2)
    group:getButtonAtIndex(1):addChild(jb,0,101)

    local jf = cc.Sprite:create("picdata/fightteam/icon_jf.png")
    jf:setPosition(-1, -2)
    group:getButtonAtIndex(2):addChild(jf,0,102)

    group:getButtonAtIndex(1):setButtonSelected(true)
end
function FTRewardLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnSure then
		if self.mInputBox:getText() == "" then self:showTips(1) return end
		-- self.mAwardNum = tonumber(self.mInputBox:getText())
		-- if self.mAwardNum > tonumber(self.mFundNum) then
		-- 	-- CMShowTip("派发的奖励超过战队的基金数量")
		-- 	self:showTips(2)
		-- 	return
		-- end
		local isOver,num = self:checkIsOverTotal()
		if num == 0 then 
			CMShowTip("最小单位不能为0")
			return 
		end
		self.mAwardNum = num
		if isOver then
			self:showTips(2)
			return 
		end
		local nType = {"GOLD","RAKEPOINT"}
		DBHttpRequest:sentMoneyToMember(function(tableData,tag,nType) self:httpResponse(tableData,tag,nType) end,self.mUserId,self.mAwardNum,myInfo.data.userClubId,nType[self.mSelectType])
	elseif tag == EnumMenu.eBtnCancel then
		CMClose(self)
	end
end
--[[
	判断是否超出战队金额
]]
function FTRewardLayer:checkIsOverTotal()

	local num = tonumber(self.mInputBox:getText())
	if num > self.mTotalNum[self.mSelectType] then
		return true,num
	end
	return false,num
end
-- 输入事件监听方法
function FTRewardLayer:onEdit(event, editbox)
    if event == "began" then
    -- 开始输入
        --print("开始输入")
    elseif event == "changed" then
    -- 输入框内容发生变化

    elseif event == "ended" then
    -- 输入结束
          
    elseif event == "return" then	 
  	 	if self:checkIsOverTotal() then
    		editbox:setFontColor(cc.c3b(255,0,0))
    	else
    		if self.mTipNode then self.mTipNode:removeFromParent() self.mTipNode = nil end
    		editbox:setFontColor(cc.c3b(255,255,255))
    	end  
    end
    
end
function FTRewardLayer:httpResponse(tableData,tag,nType)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_sentMoneyToMember then
		if tonumber(tableData) == 10000 then
			nType = nType or self.mSelectType
			self.mTotalNum[nType] = self.mTotalNum[nType] - self.mAwardNum 
			self:updateTips(nType)
			if nType == 1 then
				QDataFightTeamList:updateMsgFundData(self.mTotalNum[nType])
			else
				QDataFightTeamList:updateMsgJiFenData(self.mTotalNum[nType])
			end
			QManagerListener:Notify({tag = "updateClubInfo",layerID = eFTMyTeamLayerID})
			CMShowTip("奖励派送成功")
		else
			CMShowTip("奖励派送失败,请重试")
		end
	end
end
return FTRewardLayer