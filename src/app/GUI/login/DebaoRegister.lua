--
-- Author: junjie
-- Date: 2015-12-16 14:38:20
--
--帐户转正、注册
local DebaoRegister = class("DebaoRegister",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local EnumMenu = {
	eBtnBind = 1,
}
function DebaoRegister:ctor(params)
	self:setNodeEventEnabled(true)	
  self.params = params or {}
	self.mCurType = 1 --sex
	self.mInputBox = {}
	self.mActivitySprite = {}
end
function DebaoRegister:create()
    self:initUI()
end
function DebaoRegister:initUI()
  local titleText = "账号安全升级"
  local btnLabel  = "升  级"
  if self.params.nType == 1 then
       titleText = "帐户注册"
       btnLabel  = "下一步"
  end
	self.mBg = cc.Sprite:create("picdata/login/loginDialog.png")
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height
  self.mBg:setPosition(display.cx,display.cy)
  self:addChild(self.mBg)

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

  local btnClose = CMButton.new({normal = "picdata/setting/btn_back.png",pressed = "picdata/setting/btn_back.png"},function () 
        if self.params.nType == 1 then
             QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 1})
        end
          CMClose(self)  
    end)    
    :align(display.CENTER, 65 ,self.mBg:getContentSize().height-72) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

    local posy  = title:getPositionY() - 85
    local data = {"用户名(4-16字符)","密码(4-16字符)"}
    for i = 1,2 do 

    	local inputBg  = cc.Sprite:create("picdata/login/textfieldBG.png")
    	inputBg:setPosition(bgWidth/2,posy)
    	self.mBg:addChild(inputBg)
    	local spPath = "picdata/login/usernameIcon.png"
    	if i == 2 then
    		spPath = "picdata/login/passwordIcon.png"
    	end
    	local sp = cc.Sprite:create(spPath)
    	sp:setPosition(20, inputBg:getContentSize().height/2)
    	inputBg:addChild(sp)
    	local imagePath = "picdata/public/transBG.png"
    	local imageSize = cc.size(290, 38)
	    local inputBox = cc.ui.UIInput.new({
		    image = imagePath, -- 输入控件的背景
		    --x = 580,
		   -- y = 50,	   	
		    maxLength = 16,
		    size = imageSize,
		    listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		})

		inputBox:setPlaceHolder(data[i])
		inputBox:setFont("Arial", 22)
		inputBox:setFontSize(24)		
		inputBox:setFontColor(cc.c3b(51, 51, 51))
		inputBox:setPosition(35+inputBox:getContentSize().width/2,inputBg:getContentSize().height/2-5)
		inputBg:addChild(inputBox)	

		self.mInputBox[i] = inputBox
		posy = posy - 75
		--self.mChatBox = inputBox
    end

    local bgPosx  = bgWidth/2 - 135
    for i = 1 ,2 do
    	local manPath= "picdata/login/maleIcon.png"
    	local bgPath = "picdata/public/checkboxOn.png"
    	if i == 2 then
    		bgPosx = bgPosx + 160
    		manPath ="picdata/login/femaleIcon.png"
    		bgPath = "picdata/public/checkboxOff.png"
    	end
	    local bg = cc.Sprite:create(bgPath)
	    bg:setPosition(bgPosx,bgHeight/2 - 45)
	  	self.mBg:addChild(bg,0,500+i)

	  	bg:setTouchEnabled(true)
    	bg:setLocalZOrder(1)
    	bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event,btn) return self:buttonClick(event,bg) end)

	  	local man = cc.Sprite:create(manPath)
	    man:setPosition(bg:getPositionX() + 70,bg:getPositionY())
	  	self.mBg:addChild(man)

	  	bgPosx = bgPosx + 50

	  	self.mActivitySprite[i] = bg
	 end

    local btnBind = CMButton.new({normal = "picdata/public/confirmBtn.png"},function () self:onMenuCallBack(EnumMenu.eBtnBind) end) 
    btnBind:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 178),
	    text = btnLabel,
	    size = 30,
	    font = "FZZCHJW--GB1-0",
		}) )       
    :align(display.CENTER, bgWidth/2,150 ) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
end
function DebaoRegister:buttonClick(event,sender)
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
function DebaoRegister:onMenuCallBack(tag)
    -- @TODO: implement this
   if tag == 501 then
   	  if self.mCurType ~= 1 then
   	  	 self.mCurType = 1
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOn.png"):getTexture())
   	  	 self.mActivitySprite[2]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  else
   	  	 -- self.mCurType = 0
   	  	 -- self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  end
   elseif tag == 502 then
   	  if self.mCurType ~= 2 then
   	  	 self.mCurType = 2
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  	 self.mActivitySprite[2]:setTexture(cc.Sprite:create("picdata/public/checkboxOn.png"):getTexture())
   	  else
   	  	 -- self.mCurType = 0
   	  	 -- self.mActivitySprite[2]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  end

   elseif tag == EnumMenu.eBtnBind then
   		self:onMenuBind()
   end
end

function DebaoRegister:onMenuBind()
  local sAccount = self.mInputBox[1]:getText()
  local sPassword  = self.mInputBox[2]:getText()
	if sAccount == "" or sPassword == "" then return end 
	if self.mCurType == 0 then return end
	local sex = "男"
	if self.mCurType == 2 then sex = "女" end
	--NativeJNI::getAndroidMac()
	local mac = ""
  -- dump(self.params.nType)
   if self.params.nType == 1 then
       DBHttpRequest:registerPC(function(tableData,tag) self:httpResponse(tableData,tag) end, sAccount,sPassword,sex,"")   --下一步
   else
       DBHttpRequest:touristTurnDebao(function(tableData,tag) self:httpResponse(tableData,tag) end, sAccount,sPassword,mac,sex,"")   --升级
   end 
end
-- 输入事件监听方法
function DebaoRegister:onEdit(event, editbox)
    if event == "began" then
    -- 开始输入
        --print("开始输入")
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
        local _text = editbox:getText()
		local _trimed = string.trim(_text)		
		if _trimed ~= _text then			
		    editbox:setText(_trimed)
		end

    elseif event == "ended" then
    -- 输入结束
        --print("输入结束")        
    elseif event == "return" then
    	
    	
    -- 从输入框返回
        --print("从输入框返回")       
    end
end

--[[
  网络回调
]]
function DebaoRegister:httpResponse(tableData,tag) 
  dump(tableData,tag)
    if tag == POST_COMMAND_TOURISTTURNDEBAO then  
        UserDefaultSetting:getInstance():setLastLoginName(self.mInputBox[1]:getText())
		    UserDefaultSetting:getInstance():setLastLoginPassword("")
         tableData["CODE"] = tonumber(tableData["CODE"])
         local tips = ""			--请求列表回调
         local callOk 
         if tableData["CODE"] == 1 then
           	tips = "恭喜您成功绑定德堡帐号！为了您的账户安全请重新登录。"
           	callOk = function ()       
              GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView,{nType = "enter"})
      		  end
    		else
      			tips = "绑定失败，请稍后重试。"
      			if tableData["CODE"] == -12021 then
      				tips = "重复绑定"
      			elseif tableData["CODE"] == -12002 then
      				tips = "用户名被占用"
      			elseif tableData["CODE"] == -12003 then
      				tips = "注册邮箱已存在"
      			end
      			callOk = function () self.mInputBox[1]:setVisible(true) self.mInputBox[2]:setVisible(true) end
      		end
      		self.mInputBox[1]:setVisible(false) 
      		self.mInputBox[2]:setVisible(false)
      		local AlertDialog = require("app.Component.CMAlertDialog").new({text = tips,callOk = callOk })
      		CMOpen(AlertDialog,self:getParent(),self:getPositionX())
   elseif tag == POST_COMMAND_REGISTERPC then
        if type(tableData) ~= "table" then return end
        if tableData["0001"] == 1 then
            local parent = self:getParent()            
            myInfo.data.phpSessionId = tableData["0002"]
            DBHttpRequest:setSession(tableData["0002"])
            UserDefaultSetting:getInstance():setDebaoLoginName(self.mInputBox[1]:getText())
            UserDefaultSetting:getInstance():setDebaoLoginPassword(self.mInputBox[2]:getText())
            QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 4})
            self:setVisible(false)
            CMClose(self)
             local RewardLayer = require("app.GUI.login.MobileVerify").new({nType = 1})
             CMOpen(RewardLayer,parent)
        else
           
        end
         local AlertDialog = require("app.Component.CMAlertDialog").new({text = tableData["600E"]})
          CMOpen(AlertDialog,self)
    end
    
end
return DebaoRegister