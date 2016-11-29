--
-- Author: junjie
-- Date: 2016-01-28 19:47:31
--
--
-- Author: junjie
-- Date: 2016-01-28 14:05:21
--
--手机帐户注册
--帐户转正、注册
local ForgetPasswordLayer = class("ForgetPasswordLayer",function() 
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
function ForgetPasswordLayer:ctor(params)
	self:setNodeEventEnabled(true)	
    self.params = params or {}
	self.mCurType = 1 --sex
	self.mInputBox = {}
	self.mActivitySprite = {}
end
function ForgetPasswordLayer:onExit()
	QManagerScheduler:removeLocalScheduler({layer = self}) 
end
function ForgetPasswordLayer:create()
    self:initUI()
end
function ForgetPasswordLayer:initUI()
 
   titleText = "帐户注册"
   btnLabel  = "完成注册"
 
  self.mBg = cc.Sprite:create("picdata/login/forgetPasswordBG.png")
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height
  self.mBg:setPosition(display.cx,display.cy)
  self:addChild(self.mBg)

  local btnClose = CMButton.new({normal = "picdata/setting/btn_back.png",pressed = "picdata/setting/btn_back.png"},function () 
  		QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 1})
  		CMClose(self) end)    
    :align(display.CENTER, 45 ,self.mBg:getContentSize().height-52) --设置位置 锚点位置和坐标x,y
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

   

  
    local posy  = title:getPositionY() - 120
    local data = {"用户名","绑定的邮箱/手机"}
    local forePath ,foreAlign ,textPath ,foreCallBack = nil 
    for i = 1,2 do 
    	if i == 1 then 
    		forePath = nil
    		forePath = "picdata/login/usernameIcon.png"
    		foreAlign= CMInput.LEFT

    	else
    		forePath = "picdata/login/emailIcon.png"
    		foreAlign= CMInput.LEFT
    		
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
		posy = posy - 120
	end

	local bgPosx  = bgWidth/2 - 135
	for i = 1 ,2 do
    	local manPath= "picdata/login/maleIcon.png"
    	local bgPath = "picdata/public/checkboxOn.png"
    	local text   = "手机"
    	if i == 2 then
    		bgPosx = bgPosx + 160
    		manPath ="picdata/login/femaleIcon.png"
    		bgPath = "picdata/public/checkboxOff.png"
    		text   = "邮箱"
    	end
	    local bg = cc.Sprite:create(bgPath)
	    bg:setPosition(bgPosx,bgHeight/2 - 105)
	  	self.mBg:addChild(bg,0,500+i)

	  	bg:setTouchEnabled(true)
    	bg:setLocalZOrder(1)
    	bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event,btn) return self:buttonClick(event,bg) end)

	  	local tips = cc.ui.UILabel.new({
        text  = text,
        size  = 24,
        color = cc.c3b(0,0,0),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "FZZCHJW--GB1-0",
        
	    })
	    tips:setPosition(bg:getPositionX() + 40,bg:getPositionY())
	    self.mBg:addChild(tips)

	  	bgPosx = bgPosx + 50

	  	self.mActivitySprite[i] = bg
	 end

	 local node = cc.Node:create()
   node:setVisible(false)
   self.mTipNode = node
   node:setPosition(70, bgHeight/2+33)
   self.mBg:addChild(node)
   local bg = cc.Sprite:create("picdata/public/error.png")
    node:addChild(bg)

    local tip = cc.ui.UILabel.new({
          color = cc.c3b(255, 90, 0),
          text  = "用户名或密码不能为空",
          size  = 26,
          font  = "FZZCHJW--GB1-0.fnt",
         -- UILabelType = 1,
      })
    tip:setPosition(bg:getPositionX()+40,bg:getPositionY())
    node:addChild(tip,0,101)

    local btnBind = CMButton.new({normal = "picdata/login/resetPassword.png"},function () self:onMenuCallBack(EnumMenu.eBtnBind) end) 
    :align(display.CENTER, bgWidth/2,110 ) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
    self.mBtnBind = btnBind
end
function ForgetPasswordLayer:buttonClick(event,sender)
    -- @TODO: all sprite click func
    local tag = sender:getTag()
    
    -- dump(sender)
    if tag == 502 then
        --todo mBtnSign Sprite Click
        local state = CMSpriteButton:new(event,{sprite = sender,callback = function ()  self:onMenuCallBack(502) end,scale = false,})
        return state
    end
    if tag == 501 then
        --todo mBtnClose Sprite Click
        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () self:onMenuCallBack(501) end,scale = false,})
        
        return state
    end
end

--[[请求签到]]
function ForgetPasswordLayer:onMenuCallBack(tag)
	 if tag == 501 then
   	  if self.mCurType ~= 1 then
   	  	 self.mCurType = 1
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOn.png"):getTexture())
   	  	 self.mActivitySprite[2]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  else
   	  	 self.mCurType = 0
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  end
    elseif tag == 502 then
   	  if self.mCurType ~= 2 then
   	  	 self.mCurType = 2
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  	 self.mActivitySprite[2]:setTexture(cc.Sprite:create("picdata/public/checkboxOn.png"):getTexture())
   	  else
   	  	 self.mCurType = 0
   	  	 self.mActivitySprite[2]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  end
    elseif tag == EnumMenu.eBtnBind then
   	    self:onMenuBind()

	end
end


function ForgetPasswordLayer:onMenuBind()
  local userName = self.mInputBox[1]:getText()
  local sMail    = self.mInputBox[2]:getText()
  if userName == "" then 
  	self.mTipNode:getChildByTag(101):setString("请输入用户名")
  	self.mTipNode:setVisible(true)
  	return 
  end
  if sMail == "" then 
  	self.mTipNode:getChildByTag(101):setString("请输入邮箱/手机号")
  	self.mTipNode:setVisible(true)
  	return 
  end
  local nFindType = ""
  if self.mCurType == 0 then 
  	self.mTipNode:getChildByTag(101):setString("请选择寻回方式")
  	self.mTipNode:setVisible(true)
  	return 
  elseif  self.mCurType == 1 then
  	 DBHttpRequest:resetPassword(function(tableData,tag) self:httpResponse(tableData,tag) end,"MOBILE",userName,"",sMail) 
  elseif  self.mCurType == 2 then
  	 DBHttpRequest:resetPassword(function(tableData,tag) self:httpResponse(tableData,tag) end,"EMAIL",userName,sMail,"") 
  end

 
end

function ForgetPasswordLayer:updateTime()
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
function ForgetPasswordLayer:httpResponse(tableData,tag) 
    -- dump(tableData,tag)
    if tag == POST_COMMAND_ResetPassword then  
	    local returnCode = {
			 ["1"]   =  "新密码已成功以信息形式发送到您绑定的邮箱/手机号，请注意查收。若接收有误，可在1分钟后重新尝试重置密码。",
		     ["-1"]   =  "系统参数错误",
		     ["-2"]   =  "用户名错误",
		     ["-3"]   =  "Email错误",
		     ["-4"]   =  "手机号码错误",
		     ["-5"]   =  "短时间内重置次数超过5次",
		     ["-6"]   =  "用户信息不存在",
		     ["-7"]   =  "所用邮箱或手机与用户绑定的信息不符",
		     ["-8"]   =  "发送邮件失败",
		     ["-9"]   =  "发送手机短信失败",
		     ["-10"]  =  "发送手机短信失败,系统错误",
		}
		local isSuc = nil
       if tableData == 1 then
       		isSuc = true
       		
       else 
       		isSuc = false
       end		
       local parent = self:getParent()
       QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 1})
       CMClose(self)
   		local RewardLayer = require("app.Component.CMAlertDialog").new({text = returnCode[tostring(tableData)],showType = 1})
		CMOpen(RewardLayer,parent)
		
    end
    
end
return ForgetPasswordLayer