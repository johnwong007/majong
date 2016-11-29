--
-- Author: junjie
-- Date: 2016-05-31 10:14:12
--
--德堡钻赠送
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local DebaoZuanGiveLayer = class("DebaoZuanGiveLayer",FightCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
local EnumMenu = {
	eBtnSure = 1,
}
function DebaoZuanGiveLayer:ctor(params)
	params = params or {}
	self.mGiveNum = 1
	self.mGoodId  = params[GOODS_GOODS_ID] or "0"
end
function DebaoZuanGiveLayer:onExit()

end
--[[
	UI创建
]]
function DebaoZuanGiveLayer:create()
	DebaoZuanGiveLayer.super.ctor(self,{titlePath = "picdata/shop/w_title_zs.png",
		showType = 2,okText = "确定",isOkClose = 0,callOk = function () self:onMenuCallBack(EnumMenu.eBtnSure) end}) 
    DebaoZuanGiveLayer.super.initSecondUI(self)
	local bg = cc.Node:create()
	-- local bgWidth = 800
	-- local bgHeight= 600
	self:addChild(bg)

 	local tip = cc.ui.UILabel.new({
        text  = "我要赠送给",
        size  = 26,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
	tip:setPosition(60,self.mBgHeight/2+45)
	self.mBg:addChild(tip)

	local tip = cc.ui.UILabel.new({
        text  = "皇家邀请卡",
        size  = 26,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
	tip:setPosition(480,self.mBgHeight/2+45)
	self.mBg:addChild(tip)

	-- local tip = cc.ui.UILabel.new({
 --        text  = "收到邀请卡的玩家将同时获得10000德堡钻",
 --        size  = 20,
 --        color = cc.c3b(135, 154, 192),
 --        align = cc.ui.TEXT_ALIGN_LEFT,
 --        --UILabelType = 1,
 --        font  = "黑体",
 --    })
	-- tip:setPosition(self.mBgWidth/2-tip:getContentSize().width/2,self.mBgHeight/2 - 35)
	-- self.mBg:addChild(tip)

	local bg = cc.ui.UIImage.new("picdata/public2/bg_tc2.png", {scale9 = true})
    bg:setLayoutSize(276,62)
	bg:setPosition(self.mBgWidth/2-138,self.mBgHeight/2+15)
	self.mBg:addChild(bg)

	local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 20,
        place     = "填写他/她的UID",
        color     = cc.c3b(60,207,255),
        fontSize  = 26,
        bgPath    = "picdata/public/transBG.png" ,  
        scale9    = true,
        size      = cc.size(276,32) ,
        inputMode = 2,   
        -- listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setPosition(self.mBgWidth/2-138,self.mBgHeight/2+30)
    self.mBg:addChild(inputBox )

	self.mInputBox = inputBox
end
--[[
	按钮回调
]]
function DebaoZuanGiveLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnSure then
		local accept_uid = self.mInputBox:getText()
		if accept_uid ~= "" then
			if myInfo.data.userId == accept_uid then
				CMShowTip("不能给自己赠送")
				return
			end
			DBHttpRequest:buyAsGift(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,self.mGoodId,accept_uid,self.mGiveNum)
		end
	end
end
--[[
	网络回调
]]
function DebaoZuanGiveLayer:httpResponse(tableData,tag,nType)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_buyAsGift then 			    --请求道具列表	
		tableData = tonumber(tableData or 0)
		if tableData == 1 then
			CMShowTip("赠送成功")
		elseif tableData == -13001 then
			CMShowTip("余额不足")
		else
			CMShowTip("兑换失败,请输入正确的玩家UID")
		end
	end
end
return DebaoZuanGiveLayer