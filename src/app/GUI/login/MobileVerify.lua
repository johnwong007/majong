--
-- Author: junjie
-- Date: 2016-01-28 14:05:21
--
--手机帐户注册
--帐户转正、注册
local MobileVerify = class("MobileVerify",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
require("app.Logic.Config.UserDefaultSetting")
local myInfo = require("app.Model.Login.MyInfo")
require("app.CommonDataDefine.CommonDataDefine")
local EnumMenu = {
	eBtnBind = 1,
	eBtnGet  = 2,
}
function MobileVerify:ctor(params)
	self:setNodeEventEnabled(true)	
    self.params = params or {}
	self.mCurType = 1 --sex
	self.mInputBox = {}
	self.mActivitySprite = {}
end
function MobileVerify:onExit()
	QManagerScheduler:removeLocalScheduler({layer = self}) 
end
function MobileVerify:create()
    self:initUI()
end
function MobileVerify:initUI()
   titleText = "帐户注册"
   btnLabel  = "完成注册"
 
  self.mBg = cc.Sprite:create("picdata/login/loginDialog.png")
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height
  self.mBg:setPosition(display.cx,display.cy)
  self:addChild(self.mBg)

  local btnClose = CMButton.new({normal = "picdata/setting/btn_back.png",pressed = "picdata/setting/btn_back.png"},function () 
  		QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 1})
  		CMClose(self) end)    
    :align(display.CENTER, 65 ,self.mBg:getContentSize().height-72) --设置位置 锚点位置和坐标x,y
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
  self.mBg:addChild(title)

    local details = cc.ui.UILabel.new({
        text  = "为了保障你的账号安全，本次注册需要验证手机",
        size  = 20,
        color = cc.c3b(0,0,0),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
        dimensions = cc.size(328,0)
    })
  details:setPosition(65,title:getPositionY() - 65)
  self.mBg:addChild(details)

  
    local posy  = title:getPositionY() - 145
    local data = {"请输入你的手机号码","6位验证码"}
    local forePath ,foreAlign ,textPath ,foreCallBack = nil 
    for i = 1,2 do 
    	if i == 1 then 
    		forePath = nil
    		forePath = "picdata/login/phoneIcon.png"
    		foreAlign= CMInput.LEFT

    	else
    		forePath = "picdata/login/sendCodeBtn.png"
    		textPath = {text = "获取验证码"}
    		foreAlign= CMInput.RIGHT
    		foreCallBack   = function () self:onMenuCallBack(EnumMenu.eBtnGet) end
    	end
	    local inputBox = CMInput:new({
		    --bgColor = cc.c4b(255, 255, 0, 120),
		    maxLength = 11,
		    place     = data[i],
		    color     = cc.c3b(51,51,51),
		    fontSize  = 30,
		    bgPath    = "picdata/login/textfieldBG.png" ,	    
		    forePath  = forePath,
		    foreAlign = foreAlign,
		    textPath  = textPath,
		    foreCallBack = foreCallBack,
		    --listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		})
		inputBox:setPosition(bgWidth/2,posy)
		self.mBg:addChild(inputBox )

		self.mInputBox[i] = inputBox
		posy = posy - 75
	end

    local btnBind = CMButton.new({normal = "picdata/public/confirmBtn.png"},function () self:onMenuCallBack(EnumMenu.eBtnBind) end) 
    btnBind:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 178),
	    text = btnLabel,
	    size = 30,
	    font = "FZZCHJW--GB1-0",
		}) ) 
	--:setButtonEnabled(false)      
    :align(display.CENTER, bgWidth/2,150 ) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
    self.mBtnBind = btnBind
end


--[[请求签到]]
function MobileVerify:onMenuCallBack(tag)
    if tag == EnumMenu.eBtnBind then
   	    self:onMenuBind()
	elseif tag == EnumMenu.eBtnGet then
		self:onMenuGet()
	end
end

function MobileVerify:onMenuGet()

	local sPhone = self.mInputBox[1]:getText()
	local lens   = string.len(sPhone)
	if sPhone == "" then return end
	if lens ~= 11 or not tonumber(sPhone) then
      local CMToolTipView = require("app.Component.CMToolTipView").new({text = "请输入有效的手机号码",isSuc = false})
      CMOpen(CMToolTipView,self)
      return 
	end 
	local name = self.params.name or UserDefaultSetting:getInstance():getDebaoLoginName()
	DBHttpRequest:sendVerifyMsg(function(tableData,tag) self:httpResponse(tableData,tag) end, "phone",sPhone,name,"DEBAO") 
end

function MobileVerify:onMenuBind()
  local sVerify  = self.mInputBox[2]:getText()
  if sVerify == "" then return end
  DBHttpRequest:verifyPhoneCode(function(tableData,tag) self:httpResponse(tableData,tag) end,sVerify) 
end

function MobileVerify:updateTime()
	self.mTime = self.mTime - 1 
	self.mInputBox[2]:setButtonLabel({text = self.mTime.."s重新发送"})
	if self.mTime <=  0 then
		QManagerScheduler:removeLocalScheduler({layer = self}) 
		self.mInputBox[2]:setTexture("picdata/login/sendCodeBtn.png",false)
		self.mInputBox[2]:setButtonLabel({text = "获取验证码"})
	    
	end
end
--[[
  网络回调
]]
function MobileVerify:httpResponse(tableData,tag) 
    --dump(tableData,tag)
    if tag == POST_COMMAND_sendVerifyMsg then  
	    local returnCode = {
	     ["1"]   = "验证码已成功发送",
	     ["-2"]   = "用户不存在",
	     ["-3"]   = "发送次数过多",
	     ["-4"]   = "邮箱格式错误",
	     ["-5"]   = "邮箱已被占用",
	     ["-6"]   = "用户已激活",
	     ["-7"]   = "绑定邮箱失败",
	     ["-8"]   = "发送激活邮件失败",
	     ["-9"]   = "手机号码错误",
	     ["-10"]  = "手机号码已被占用",
	     ["-11"]  = "发送手机激活信息失败"
		}
		local isSuc = nil
       if tableData == 1 then
       		isSuc = true
       		self.mTime  = 60
       		self.mInputBox[2]:setTexture("picdata/login/sendCodeBtn.png",true)
		   	self.mInputBox[2]:setButtonLabel({text = self.mTime.."s重新发送"})
			self.mBtnBind:setButtonEnabled(true)
		    QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:updateTime() end,interval = 1})
       else 
       		isSuc = false
       end		
   		local CMToolTipView = require("app.Component.CMToolTipView").new({text = returnCode[tostring(tableData)],isSuc = isSuc})
		 CMOpen(CMToolTipView,self)
	elseif tag == POST_COMMAND_verifyPhoneCode then 
		local text = ""
		local tag  = 0
		 if tableData == 1 then
		 	text = "验证成功"
		 	isSuc= true
		 	tag  = 3
		 else
		 	text = "验证码错误"
		 	isSuc= false
		 end
		 QManagerListener:Notify({layerID = eLoginViewLayerID,tag = tag})
		 local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
		 CMOpen(CMToolTipView,self)
    end
    
end
return MobileVerify