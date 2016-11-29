--
-- Author: junjie
-- Date: 2016-01-29 13:48:29
--
local DebaoUniqueUser = class("DebaoUniqueUser",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
require("app.Logic.Config.UserDefaultSetting")
local myInfo = require("app.Model.Login.MyInfo")
local EnumMenu = {
	eBtnBind = 1,
}
function DebaoUniqueUser:ctor(params)
	self:setNodeEventEnabled(true)	
    self.params = params or {}
    self.loginSelectDialog = params.loginSelectDialog
    self.m_login = params.m_login
	self.mInputBox = {}
	self.mActivitySprite = {}
end
function DebaoUniqueUser:onExit()
	
end
function DebaoUniqueUser:create()

    self:initUI()
end
function DebaoUniqueUser:initUI()
 
   titleText = "帐户注册"
   btnLabel  = "绑定"
 
  self.mBg = cc.Sprite:create("picdata/login/uniqueBG.png")
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height
  self.mBg:setPosition(display.cx,display.cy)
  self:addChild(self.mBg)

local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end, {scale9 = false})    
    :align(display.CENTER, self.mBg:getContentSize().width - 30,self.mBg:getContentSize().height-30) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

   local title = cc.ui.UILabel.new({
        text  = titleText,
        size  = 38,
        color = cc.c3b(0,0,0),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "FZZCHJW--GB1-0",
        
    })
  title:setPosition(bgWidth/2-title:getContentSize().width/2,bgHeight - 75)
  --self.mBg:addChild(title)

     
    local posy  = title:getPositionY() - 104
    local data = {"请输入你的昵称"}
    local forePath ,foreAlign ,textPath ,foreCallBack = nil 
    for i = 1,1 do 
    	if i == 1 then 
    		forePath = nil
    	end
	    local inputBox = CMInput:new({
		    --bgColor = cc.c4b(255, 255, 0, 120),
		    size      = cc.size(360,40),
		    maxLength = 16,
        minLength = 4,
		    place     = data[i],
		    color     = cc.c3b(255,255,255),
		    fontSize  = 30,
		    bgPath    = "picdata/public/transBG.png" ,	    
		    forePath  = forePath,
		    foreAlign = foreAlign,
		    textPath  = textPath,
		    foreCallBack = foreCallBack,
		    --listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		})
		inputBox:setPosition(bgWidth/2+25,posy)
		self.mBg:addChild(inputBox )

		self.mInputBox[i] = inputBox
		posy = posy - 75
	end

    local btnBind = CMButton.new({normal = "picdata/setting/mobileBindBtn.png"},function () self:onMenuCallBack(EnumMenu.eBtnBind) end) 
    btnBind:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 178),
	    text = btnLabel,
	    size = 30,
	    font = "FZZCHJW--GB1-0",
		}) )     
    :align(display.CENTER, bgWidth/2,70 ) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
    self.mBtnBind = btnBind

end

--[[请求签到]]
function DebaoUniqueUser:onMenuCallBack(tag)
    if tag == EnumMenu.eBtnBind then
   	    self:onMenuBind()
	end
end
function DebaoUniqueUser:onMenuBind()
  local wanname  = self.mInputBox[1]:getText()
  if wanname == "" then return end
  self.m_login:debaoUniqueUserRequest(wanname)
  self:removeFromParent()

end
--[[
  网络回调
]]
function DebaoUniqueUser:httpResponse(tableData,tag) 
    dump(tableData,tag)
    if tag == POST_COMMAND_LOGIN_FOR_MOBILE_NEW then  
	    
    end
    
end
return DebaoUniqueUser