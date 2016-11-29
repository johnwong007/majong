--
-- Author: junjie
-- Date: 2015-12-15 14:33:16
--
--账户信息
local AccountEditLayer = class("AccountEditLayer",function() 
  return display.newNode()
end)
require("app.Network.Http.DBHttpRequest")
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")

local EnumMenu =
{ 
    eBtnSure = 1,  --确认
    eBtnAgain= 2,  --重新上传
}
function AccountEditLayer:ctor(params)
  self.params = params or {}
  self.mPersonData = {}
  self.mAllType = {"JD","ZDY",} 
end
function AccountEditLayer:create()
    self:initUI()
end
function AccountEditLayer:initUI()
  DBHttpRequest:getExpressInfo(function(tableData,tag) self:dealGetExpressInfoResp(tableData,tag) end, myInfo.data.userId)  
  
end
function AccountEditLayer:CreateContent(tableData)
	tableData = tableData or {}

    self:setContentSize(960,CONFIG_SCREEN_HEIGHT-140)
    self:setPosition(440, 0)
    msgBg = self

	local posx = self:getContentSize().width/2
    local posy = self:getContentSize().height-30

    local loginTypeStr={
        [eDebaoPlatformQQLogin]      = "QQ帐号",
        [eDebaoPlatformMainLogin]    = "德堡帐号",
        [eDebaoPlatformTouristLogin] = "游客帐号",   
        [eDebaoPlatform500wan]       = "500万帐号",

        [eDebaoPlatformUNWOLogin]    = "联通帐号",
        [eDebaoPlatformTENCENTLogin] = "应用宝帐号",

        [eDebaoPlatformBaiduLogin]   = "百度帐号",
        [eDebaoPlatformMeizuLogin]   = "魅族帐号",
        [eDebaoPlatformJinLiLogin]   = "金立帐号",
        [eDebaoPlatformXiaoMiLogin]  = "小米帐号",
        [eDebaoPlatformPengYouWanLogin]  = "朋友网帐号",
        [eDebaoPlatformNduoLogin]  = "N多帐号",
        [eDebaoPlatformUUCunLogin]  = "悠悠村帐号",
        [eDebaoPlatformMuMaYiLogin]  = "木蚂蚁帐号",
        [eDebaoPlatformAnQuLogin]  = "安趣帐号",
        [eDebaoPlatformLiTianLogin]  = "力天帐号",
    }
    local data = {}
    data[1] = {
    	text = string.format("(%s %s)",loginTypeStr[myInfo.data.loginType] or loginTypeStr[4],revertPhoneNumber(tostring(tableData[USER_NAME])) or ""),
    	color 	= cc.c3b(0,255,225),
    	size 	= 24,
    	showBtn = true,
    	path 	= "w_list_dqzh.png",
        iconPath = "icon_id.png",
        titleText = "当前帐号",
     }
    data[2] = {
    	text 	= "",
    	color 	= cc.c3b(1,250,221),
    	size 	= 24,showBtn = true,
    	path 	= "w_xgmm.png",
        iconPath = "icon_password.png",
        titleText = "修改密码",
    }
    data[3] = {
    	text 	= "(用于找回密码,加强联系)",
    	color 	= cc.c3b(135,154,192),
    	size 	= 20,
    	showBtn = true,
    	path 	= "w_bdsjh.png",
        iconPath = "icon_phone.png",
        titleText = "绑定手机",
    }
    data[4] = {
    	text 	= "(绑定你的邮箱)",
    	color 	= cc.c3b(1,250,221),
    	size 	= 24,
    	showBtn = true,
    	path 	= "w_bdyx.png",
        iconPath = "icon_message.png",
        titleText = "绑定邮箱",
    }
    local sTipText = "(仅用于派发购彩红包)"
    if GIOSCHECK then 
        sTipText = ""
    end
    data[5] = {
    	text 	= sTipText,
    	color 	= cc.c3b(135,154,192),
    	size 	= 22,
    	showBtn = true,
    	path 	= "w_bd500.png",
        iconPath = "icon_500.png",
        titleText = "绑定500帐户",
    }

    if myInfo.data.loginType == eDebaoPlatformTouristLogin then
    	data[1].showBtn = true--false
        data[1].isBind  = true
    else 
    	data[1].isBind  = true
        data[1].showBtn = false
    end

    if myInfo.data.loginType == eDebaoPlatformMainLogin then
        data[2].showBtn = true
        data[2].color = cc.c3b(0,255,225)
        data[2].size = 24
    else
        data[2].showBtn = false
        data[2].color = cc.c3b(89,109,147)
        data[2].size = 24
    end

    if tableData[USER_PHONE_NUMBER] == "None" then
    	data[3].isBind = true
        data[3].color = cc.c3b(0,255,225)
        data[3].size = 24
    else
    	data[3].text = tableData[USER_PHONE_NUMBER] or ""
        if data[3].text~= "" then
            data[3].text = "(已绑定"..data[3].text..")"
        end
        data[3].color = cc.c3b(89,109,147)
        data[3].size = 24
    end

    if tableData[USER_EMAIL] == "None" then
    	data[4].isBind = true
        data[4].color = cc.c3b(0,255,225)
        data[4].size = 24
    else
    	data[4].text = tableData[USER_EMAIL] or ""
        if data[4].text~= "" then
            data[4].text = "(已绑定"..data[4].text..")"
        end
        data[4].color = cc.c3b(89,109,147)
        data[4].size = 24
    end
    if tableData["4060"] == "None" or tableData["4060"] == "" then
    	data[5].isBind = true
        data[5].color = cc.c3b(0,255,225)
        data[5].size = 24
    else
    	data[5].text = tableData["4060"] or ""
        if data[5].text~= "" then
            data[5].text = "(已绑定"..data[5].text..")"
        end
        data[5].color = cc.c3b(89,109,147)
        data[5].size = 24
    end
    local ignoreIndex = 1
    if myInfo.data.loginType ~= eDebaoPlatformMainLogin then
        ignoreIndex = 2
    end
    for i = 1 ,5 do
        if ignoreIndex ~= i then
            local node = self:createList(data[i],i)
            node:align(display.CENTER,0,posy)
            msgBg:addChild(node)

            posy = posy - 121
        end
	end
end
function AccountEditLayer:createList(data,idx)
    -- local size = cc.size(886,116)
    local size = cc.size(914,116)
    local bg = cc.ui.UIImage.new("picdata/public_new/bg_list.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
    
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height

    local titlePadding = 0
    if data.iconPath then
        local icon = cc.Sprite:create("picdata/personCenterNew/securityCenter/".. data.iconPath)
        icon:setPosition(20+icon:getContentSize().width/2,bgHeight/2)
        bg:addChild(icon)
        titlePadding = icon:getContentSize().width+10
    end
	-- local title = cc.Sprite:create("picdata/personCenterNew/securityCenter/".. data.path)
	-- title:setPosition(20+title:getContentSize().width/2+titlePadding,bgHeight/2)
	-- bg:addChild(title)
    local title = cc.ui.UILabel.new({
        text  = data.titleText,
        size  = 28,
        color = cc.c3b(255,255,255),
        align = cc.ui.TEXT_ALIGN_CENTER,
        --UILabelType = 1,
        font  = "黑体",
        
    })
    title:align(display.CENTER,20+title:getContentSize().width/2+titlePadding,bgHeight/2)
        :addTo(bg)
	local sTip = cc.ui.UILabel.new({
        text  = data.text or "",
        size  = data.size,
        color = data.color,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
        
    })
    sTip:setPosition(title:getPositionX()+title:getContentSize().width/2+10,bgHeight/2)
    bg:addChild(sTip)
    if data.showBtn then

	    local changePath1= "picdata/public_new/btn_blue.png"
        local changePath2= "picdata/public_new/btn_blue_p.png"
	    local textPath  = "picdata/personCenterNew/securityCenter/w_xg.png"
	    if data.isBind then
	   	  	changePath1= "picdata/public_new/btn_green2.png"
            changePath2= "picdata/public_new/btn_green2_p.png"
	   	  	if idx == 1 then
	   	  		textPath =  "picdata/personCenterNew/securityCenter/w_ykzz.png" 
	   	  	else
	      		textPath   = "picdata/personCenterNew/securityCenter/w_bd.png" 
	      	end
	    end

	    local btnBind = CMButton.new({normal = changePath1,pressed=changePath2},function () self:onMenuCallBack(idx) end,{scale9 = false},{textPath = textPath})    
	    :align(display.CENTER, bgWidth - 125,bgHeight/2) --设置位置 锚点位置和坐标x,y
	    :addTo(bg) 
	end

    return bg
end
function AccountEditLayer:onMenuCallBack(tag)
    local posx = -self:getPositionX() 
    if tag == 1 then
        -- local RewardLayer = require("app.GUI.login.DebaoRegister")
        -- CMOpen(RewardLayer, self,{posx = posx})
        CMOpen(require("app.architecture.login.RegisterFragment"),GameSceneManager:getCurScene(),{nType = 1},nil,0)
    elseif tag == 2 then
        local RewardLayer = require("app.GUI.setting.PasswordSetting")
        CMOpen(RewardLayer, GameSceneManager:getCurScene(),nil,0)
    elseif tag == 3 then
        local RewardLayer = require("app.GUI.setting.MobileBlind")
        if self.mPersonData and self.mPersonData[USER_PHONE_NUMBER]~="None" then
            CMOpen(RewardLayer, GameSceneManager:getCurScene(),{title = "修改手机"},0)
        else
            CMOpen(RewardLayer, GameSceneManager:getCurScene(),{title = "绑定手机"},0)
        end
        -- CMOpen(RewardLayer, self,posx)
    elseif tag == 4 then
        local RewardLayer = require("app.GUI.setting.EmailBlind")
        if self.mPersonData and self.mPersonData[USER_EMAIL]~="None" then
            CMOpen(RewardLayer, GameSceneManager:getCurScene(),{title = "修改邮箱"},0)
        else
            CMOpen(RewardLayer, GameSceneManager:getCurScene(),{title = "绑定邮箱"},0)
        end
        -- CMOpen(RewardLayer, self,posx)
    elseif tag == 5 then
        local RewardLayer = require("app.GUI.setting.EsunBind")
        if self.mPersonData and self.mPersonData["4060"]~="None" and self.mPersonData["4060"]~="" then
            CMOpen(RewardLayer, GameSceneManager:getCurScene(),{title = "修改500帐号"},0)
        else
            CMOpen(RewardLayer, GameSceneManager:getCurScene(),{title = "绑定500帐号"},0)
        end
        -- CMOpen(RewardLayer, self,posx)
    end
end
--[[
  网络回调
]]
function AccountEditLayer:dealGetExpressInfoResp(tableData,tag)  
    self.mPersonData = tableData
    self:CreateContent(tableData)
end
return AccountEditLayer