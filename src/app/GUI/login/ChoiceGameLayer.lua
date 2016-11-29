--
-- Author: junjie
-- Date: 2016-06-07 10:13:57
--
--游戏选择UI
local ChoiceGameLayer = class("ChoiceGameLayer",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest") 
local MoreMainLayer = require("app.GUI.setting.MoreMainLayer")
local EnumMenu = {
	eBtnDeZhou = 1,
	eBtnDouDiZhu=2,
	eBtnJZJD	=3,
	eBtnFCM 	=4,
	eBtnSMRZ    =5,
	eBtnAbout   =6,
	eBtnCommit  =7,
}

function ChoiceGameLayer:ctor()

end

function ChoiceGameLayer:create()
	self:initUI()
	self.mInputBox = {}
end

function ChoiceGameLayer:initUI()
	local bg = cc.Sprite:create(GDIFROOTRES.."picdata/loadingscene_dif/bg_1_bg_loading.png")
	local bgWidth = bg:getContentSize().width/2
	local bgHeight= bg:getContentSize().height/2
	bg:setPosition(CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
	self:addChild(bg)

	local title = cc.ui.UILabel.new({
        color = cc.c3b(0, 255, 255),
        text  = "请选择需要进入的游戏:",
        size  = 36,
        font  = "FZZCHJW--GB1-0",
       -- UILabelType = 1,
    })
    title:setPosition(display.cx-title:getContentSize().width/2,display.height-100)
	self:addChild(title)

	local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
			function () self:onMenuCallBack(EnumMenu.eBtnDeZhou) end)
		btnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(156, 255, 0),
	    text = "德州扑克",
	    size = 32,
	    font = "FZZCHJW--GB1-0",
		}) )    
		btnOk:setPosition(display.cx,display.cy+100)
		self:addChild(btnOk,1)

	local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
			function () self:onMenuCallBack(EnumMenu.eBtnDouDiZhu) end)
		btnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(156, 255, 0),
	    text = "斗地主",
	    size = 32,
	    font = "FZZCHJW--GB1-0",
		}) )    
		btnOk:setPosition(display.cx,display.cy-40)
		self:addChild(btnOk,1)

	local tips = cc.ui.UILabel.new({
        color = cc.c3b(0, 255, 255),
        text  = "友情链接:",
        size  = 32,
        font  = "FZZCHJW--GB1-0",
       -- UILabelType = 1,
    })
    tips:setPosition(50,50)
	self:addChild(tips)

	local btnParams = {
		[1] = {text = "家长监督",tag = EnumMenu.eBtnJZJD},
		[2] = {text = "防沉迷",tag = EnumMenu.eBtnFCM},
		[3] = {text = "实名认证",tag = EnumMenu.eBtnSMRZ},
		[4] = {text = "关于",tag = EnumMenu.eBtnAbout},
	}
local offx = 130
local posx = display.cx - #btnParams * offx /2 +60
	for i= 1,#btnParams do

		local btnTips = CMButton.new({},
			function () self:onMenuCallBack(btnParams[i].tag,btnParams[i].text) end)
		btnTips:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 255),
	    text = btnParams[i].text,
	    size = 32,
	    font = "FZZCHJW--GB1-0",
		}) )    
		btnTips:setPosition(posx,50)
		self:addChild(btnTips)
		posx = posx + offx
	end
	
end
function ChoiceGameLayer:onMenuCallBack(tag,titleText)
	if tag == EnumMenu.eBtnDeZhou then	
		CMClose(self)
		QManagerListener:Notify({tag = 5,layerID = eLoginViewLayerID})
		-- QManagerListener:Notify({tag = 3,layerID = eLoginViewLayerID})
		GIOSCHECK = true
	elseif tag == EnumMenu.eBtnDouDiZhu then
		QManagerPlatform:startApp()
	elseif tag == EnumMenu.eBtnClose then

	elseif tag == EnumMenu.eBtnJZJD	 then
		local text = MoreMainLayer:showParentControl()
		local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,titleText = titleText,showLine = 0,scroll = true,showType = 0,callOk = function () self:setVisible(true) end})
		CMOpen(RewardLayer, self)
	elseif tag == EnumMenu.eBtnFCM 	 then
		local text = MoreMainLayer:showAntiAddiction()
		local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,titleText = titleText,showLine = 0,scroll = true,showType = 0,callOk = function () self:setVisible(true) end})
		CMOpen(RewardLayer, self)
	elseif tag == EnumMenu.eBtnSMRZ  then
		local layer = self:createIdentifyUI({titleText=titleText})
		QManagerPlatform:addLayer(layer)
		self:addChild(layer,1)
	elseif tag == EnumMenu.eBtnAbout then
		local text = MoreMainLayer:getContent()
		local RewardLayer = require("app.Component.CMAlertDialog").new({text = text,titleText = titleText,scroll = true,showType = 0,callOk = function () self:setVisible(true) end})
		CMOpen(RewardLayer, self)
	elseif tag == EnumMenu.eBtnCommit then
		local truename = self.mInputBox[1]:getText()
		local idcard  = self.mInputBox[2]:getText()

		if truename == "" or idcard == "" then return end
		if string.len(idcard) < 18 then
			CMShowTip("请输入有效的身份证号")
			return
		end
		DBHttpRequest:updatePerson(function(tableData,tag) self:httpResponse(tableData,tag) end,truename,idcard)
	end
end
function ChoiceGameLayer:createIdentifyUI(params)
	DBHttpRequest:getPerson(function(tableData,tag) self:httpResponse(tableData,tag) end)
	local layer = display.newColorLayer(cc.c4b( 0,0,0,0))
	local size  = cc.size(668,398)
	local bg = cc.ui.UIImage.new("picdata/fightteam/bg_tc.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
 	bgWidth = bg:getContentSize().width
 	bgHeight= bg:getContentSize().height
 	bg:setPosition(display.cx-size.width/2,display.cy-size.height/2)
 	layer:addChild(bg)

 	local title = cc.ui.UILabel.new({
        color = cc.c3b(218, 197, 152),
        text  = params.titleText or "",
        size  = 36,
        font  = "FZZCHJW--GB1-0",
       -- UILabelType = 1,
    })
    title:setPosition(bgWidth/2-title:getContentSize().width/2,bgHeight - 50)
	bg:addChild(title)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(layer) end)
	btnClose:setPosition(bgWidth-20,bgHeight - 20)
	bg:addChild(btnClose,1)
	
	local inputParams = {
	[1] = {text = "真实姓名",place = "请输入真实姓名"},
	[2] = {text = "身份证号码",place ="请输入身份证号码"}
}
	local posx = 50
	local posy = 260
	for i = 1,2 do 
		local name = cc.ui.UILabel.new({
	        color = cc.c3b(218, 197, 152),
	        text  = inputParams[i].text or "",
	        size  = 28,
	        font  = "FZZCHJW--GB1-0",
	       -- UILabelType = 1,
	    })
	    name:setPosition(posx,posy)
		bg:addChild(name)
		local inputBox = CMInput:new({
	        --bgColor = cc.c4b(255, 255, 0, 120),
	        forePath  = "picdata/fightteam/icon_zd.png",
	        maxLength = 18,
	        minLength = 2,
	        place     = inputParams[i].place,
	        color     = cc.c3b(178, 188, 214),
	        fontSize  = 28,
	        bgPath    = "picdata/fightteam/bg_tc2.png" ,  
	        foreAlign = CMInput.LEFT, 
	        scale9    = true,
	        size      = cc.size(350,50) ,         
	        -- listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
	    })
	    inputBox:setPosition(bgWidth/2-100,posy-23)
	    bg:addChild(inputBox )
	    posy = posy - 100
	    self.mInputBox[i] = inputBox
    end

    local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
			function () self:onMenuCallBack(EnumMenu.eBtnCommit) end,nil,{textPath = "picdata/public2/w_btn_qd.png"})   
	btnOk:setPosition(bgWidth/2,60)
	bg:addChild(btnOk,1)

	return layer
end
--[[
	网络回调
]]
function ChoiceGameLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_getPerson then 
		if type(tableData) ~= "table" then return end
		self.mInputBox[1]:setText(tableData["truename"])
		self.mInputBox[2]:setText(tableData["idcard"])
	elseif tag == POST_COMMAND_GET_updatePerson then
		if type(tableData) ~= "table" then return end
		local code = tableData["code"]
		if code == 1 then
			CMShowTip("认证成功")
		else
			CMShowTip(tableData["msg"])
		end
	end

end
return ChoiceGameLayer