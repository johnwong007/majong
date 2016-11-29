--
-- Author: junjie
-- Date: 2016-04-20 16:15:38
--
--创建战队界面
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTCreateTeamLayer = class("FTCreateTeamLayer",FightCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
local EnumMenu = {
	eBtnCreate = 1,
	eBtnCancle = 2,
}
local ErrorCode = {
	eNotVip 	= 1,
	eTooLength  = 2,
}
function FTCreateTeamLayer:ctor()
	self:setNodeEventEnabled(true)
	self.mNeedLens = 16
	self.mInputBox = nil
end
function FTCreateTeamLayer:onExit()
	QManagerListener:Notify({tag = "showInputBox",layerID = eFTAllTeamLayerID})
	QManagerListener:Detach(eFTCreateTeamLayerID)
end
function FTCreateTeamLayer:onEnter()
	QManagerListener:Attach({{layerID = eFTCreateTeamLayerID,layer = self}})
end
--[[
	异步回调：QManagerListener
]]
function FTCreateTeamLayer:updateCallBack(data)
	if data.tag == "showInputBox" then
		self.mInputBox:setVisible(true)
	end
end
--[[
	UI创建
]]
function FTCreateTeamLayer:create()
	FTCreateTeamLayer.super.ctor(self,{titlePath = "picdata/fightteam/w_title_cjzd.png",
		showType = 2,okPath = "picdata/public2/w_btn_cj.png",isOkClose = 0,callOk = function () self:onMenuCallBack(EnumMenu.eBtnCreate) end}) 
    FTCreateTeamLayer.super.initSecondUI(self)
	-- local bg = cc.Node:create()
	-- local bgWidth = 800
	-- local bgHeight= 600
	-- self:addChild(bg)


 	local name = cc.ui.UILabel.new({
        text  = "VIP6及以上玩家可创建战队",
        size  = 20,
        color = cc.c3b(178, 188, 214),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
	name:setPosition(self.mBgWidth/2-name:getContentSize().width/2,self.mBgHeight-90)
	self.mBg:addChild(name)

	local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        forePath  = "picdata/fightteam/icon_zd.png",
        maxLength = 16,
        minLength = 4,
        place     = "战队名称（4-16）个字符",
        color     = cc.c3b(178, 188, 214),
        fontSize  = 30,
        bgPath    = "picdata/fightteam/bg_tc2.png" ,  
        foreAlign = CMInput.LEFT, 
        scale9    = true,
        size      = cc.size(500,60) ,         
        -- listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setPosition(self.mBgWidth/2-250,self.mBgHeight/2-10)
    self.mBg:addChild(inputBox )

	self.mInputBox = inputBox

end
--[[
	错误提示
]]
function FTCreateTeamLayer:showTips(nType)
	if self.mTipNode then self.mTipNode:removeFromParent() self.mTipNode = nil end

	self.mTipNode = cc.Node:create()
	self.mBg:addChild(self.mTipNode)

	local text = "战队名过长"
	if nType == 2 then
		text = "战队名有敏感词"

	end
	local sTip = cc.ui.UILabel.new({text = text,
		color = cc.c3b(135,154,192),
		size = 26,
		textAlign = cc.TEXT_ALIGNMENT_LEFT,})	
	sTip:setPosition(self.mBgWidth/2-sTip:getContentSize().width/2,self.mBgHeight/2-60)
	self.mTipNode:addChild(sTip,0)

	local tipSp = cc.Sprite:create("picdata/fightteam/icon_warning.png")
	tipSp:setPosition(sTip:getPositionX()-30, self.mBgHeight/2-60)
	self.mTipNode:addChild(tipSp)
end
--[[
	检查条件、VIP等级/文字长度
]]
function FTCreateTeamLayer:checkState(text)
	if tonumber(myInfo.data.vipLevel) < 6 then
		return ErrorCode.eNotVip
	end

	local _,curLens = CMGetStringLen(text)
	if curLens > self.mNeedLens then

		return ErrorCode.eTooLength
	end

	return 0
end
--[[
	显示提示框
]]
function FTCreateTeamLayer:showMessageBox()

end
function FTCreateTeamLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnCreate then
		local text = self.mInputBox:getText()
		-- DBHttpRequest:createClub(function(tableData,tag) self:httpResponse(tableData,tag) end,text,"TEAM")
		if text == "" then return end
		local ret = self:checkState(text)
		-- dump(ret)
		if ret == ErrorCode.eNotVip then 
			-- CMShowTip("VIP等级不足")
			self.mInputBox:setVisible(false)
			local RewardLayer = require("app.Component.CMAlertDialog")
			CMOpen(RewardLayer, self,{text = "VIP等级达到6级及以上就可以创建战队啦!\n(VIP6累计充值金额满3000元)",showType = 2,okText = "充值",titleText = "温馨提示",showBox = false,
			callOk = function (isSelect) 
			local GameLayerManager  = require("app.GUI.GameLayerManager") 
			GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self) end,
			callCancle = function ()
				self.mInputBox:setVisible(true)
			end
			})
		elseif ret == ErrorCode.eTooLength then
			-- CMShowTip("超出长度限制")
			self:showTips(1)
		else
			DBHttpRequest:createClub(function(tableData,tag) self:httpResponse(tableData,tag) end,text,"CLUB")
		end
	elseif tag == EnumMenu.eBtnCancle then
		CMClose(self)
	end
end
--[[
	网络回调
]]
function FTCreateTeamLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_createClub then 
		if tonumber(tableData) > 0 then
			CMShowTip("创建成功")		
			CMDelay(GameSceneManager:getCurScene(), 0.5, function ()
				self:getParent():removeFromParent()
				local RewardLayer      = require("app.GUI.fightTeam.FTManager"):Instance()
			 	RewardLayer:onEnter()
			end)
		else
			if tonumber(tableData) ==  -16004 then
				self:showTips(2)
			end
			CMShowTip("创建失败,请重试")
		end
	end

end
return FTCreateTeamLayer