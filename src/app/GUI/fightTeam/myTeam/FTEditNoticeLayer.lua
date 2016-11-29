--
-- Author: junjie
-- Date: 2016-05-05 15:29:47
--
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTEditNoticeLayer = class("FTEditNoticeLayer",FightCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
local EnumMenu = {
	eBtnOk = 1
}
function FTEditNoticeLayer:ctor()

end

function FTEditNoticeLayer:create()
	FTEditNoticeLayer.super.ctor(self,{size = cc.size(CONFIG_SCREEN_WIDTH,display.height)}) 
    FTEditNoticeLayer.super.initUI(self)

	local labelSize = cc.size(CONFIG_SCREEN_WIDTH,115)
	local labelBg = cc.ui.UIImage.new("picdata/fightteam/edithead.png", {scale9 = true})
    labelBg:setLayoutSize(labelSize.width,labelSize.height)
	labelBg:setPosition(self.mBgWidth/2-labelSize.width/2,self.mBgHeight-115)
	self.mBg:addChild(labelBg)

	local title = cc.Sprite:create("picdata/fightteam/w_title_bjgg.png")
	title:setPosition(labelSize.width/2,labelSize.height/2+10)
	labelBg:addChild(title)

	
	local inputBox = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        -- forePath  = "picdata/fightteam/icon_zd.png",
        maxLength = 280,
        place     = "最多输入140个中文字符...",
        color     = cc.c3b(178, 188, 214),
        fontSize  = 30,
        bgPath    = "picdata/public/transBG.png" ,  
        foreAlign = CMInput.LEFT, 
        scale9    = true,
        size      = cc.size(800,350) ,         
        listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
        showMaxTip = 0,
        showTipLabel=1,

    })
    inputBox:setPosition(self.mBg:getContentSize().width/2-400,135)
    self.mBg:addChild(inputBox )


	local btnOk = CMButton.new({normal = "picdata/fightteam/btn_bg_green2.png"},function () self:onMenuCallBack(EnumMenu.eBtnOk) end)
	btnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(156, 255, 0),
	    text = "发  布",
	    size = 28,
	    font = "FZZCHJW--GB1-0",
		}) )     
	btnOk:setPosition(self.mBgWidth - 100,65)
	labelBg:addChild(btnOk)

	self.mInputBox = inputBox
	-- self:showTips()
end
function FTEditNoticeLayer:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnOk then
		-- local text = self.mInputBox:getText()
		local isNull = self.mInputBox:checkLabelIsNull()
		if isNull then 
			CMShowTip("公告内容不能为空")
			return 
		end
		local text = self.mInputBox:getTipLabel():getString()
		DBHttpRequest:saveClubNotice(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,text)
	end
end
function FTEditNoticeLayer:showTips()
	if self.mTipNode then self.mTipNode:removeFromParent() self.mTipNode = nil end

	self.mTipNode = cc.Node:create()
	self.mBg:addChild(self.mTipNode)

	local text = "最多输入140个中文字符"
	local sTip = cc.ui.UILabel.new({text = text,
		color = cc.c3b(255,90,0),
		size = 24,
		textAlign = cc.TEXT_ALIGNMENT_LEFT,})	
	sTip:setPosition(self.mBgWidth/2-sTip:getContentSize().width/2,self.mBgHeight-125)
	self.mTipNode:addChild(sTip,0)

	local tipSp = cc.Sprite:create("picdata/fightteam/icon_warning.png")
	tipSp:setPosition(sTip:getPositionX()-30, self.mBgHeight-125)
	self.mTipNode:addChild(tipSp)
end
function FTEditNoticeLayer:onEdit(event,editbox,isOverMaxLength)
	if event == "began" then
    -- 开始输入
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
    elseif event == "ended" then
    	if isOverMaxLength then
    		self:showTips()
    	end
        --print("输入结束")        
    elseif event == "return" then    
    end
end

--[[
	网络回调
]]
function FTEditNoticeLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_saveClubNotice then
		if tonumber(tableData) == 10000 then
			QManagerListener:Notify({tag = "updateClubNotice",layerID = eFTMyTeamLayerID})
			CMShowTip("发布成功")
		elseif tonumber(tableData) == -16001 then
			CMShowTip("没有权限!")
		else
			CMShowTip("发布失败,请重试!")
		end
	end

end
return FTEditNoticeLayer