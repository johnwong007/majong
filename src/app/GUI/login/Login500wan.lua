--
-- Author: junjie
-- Date: 2016-01-12 15:17:31
--
--帐户转正
local Login500wan = class("Login500wan",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
require("app.Logic.Config.UserDefaultSetting")
local EnumMenu = {
	eBtnBind = 1,
}
function Login500wan:ctor(params)
  params = params or {}
  self.loginSelectDialog = params.loginSelectDialog
  self.m_login = params.m_login
	self:setNodeEventEnabled(true)	
  self.mCurType = UserDefaultSetting:getInstance():getAutoLoginEnable()
	self.mInputBox = {}
	self.mActivitySprite = {}
end
function Login500wan:create()
    self:initUI()
end
function Login500wan:initUI()
	self.mBg = cc.Sprite:create("picdata/login/loginDialog.png")
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height
  self.mBg:setPosition(CONFIG_SCREEN_WIDTH/2,display.cy)
  self:addChild(self.mBg)

 
local title = cc.Sprite:create("picdata/login/500LoginTitle.png")
    title:setPosition(bgWidth/2,bgHeight - 75)
    self.mBg:addChild(title)
  local btnClose = CMButton.new({normal = "picdata/setting/btn_back.png",pressed = "picdata/setting/btn_back.png"},function () self.loginSelectDialog:setVisible(true) CMClose(self) end)    
    :align(display.CENTER, 75 ,self.mBg:getContentSize().height-72) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
    
    local posy  = title:getPositionY() - 85
    local data = {"请输入您的用户名","请输入您的密码"}
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
		inputBox:setFontColor(cc.c3b(0,0,0))
		inputBox:setPosition(35+inputBox:getContentSize().width/2,inputBg:getContentSize().height/2-5)
		inputBg:addChild(inputBox)	
    if i == 2 then
      inputBox:setInputFlag(0)
    end
		self.mInputBox[i] = inputBox
		posy = posy - 75
		--self.mChatBox = inputBox
    end
    local name = UserDefaultSetting:getInstance():get500WANLoginName()
    local password = UserDefaultSetting:getInstance():get500WANLoginPassword()
    if name ~= "" then 
        self.mInputBox[1]:setText(name)
        self.mInputBox[2]:setText(password)
    end
    local bgPosx  = bgWidth/2 - 135
    for i = 1 ,1 do
    	local manPath= "picdata/login/maleIcon.png"
      local bgPath = "picdata/public/checkboxOff.png"
      if self.mCurType  then
          bgPath = "picdata/public/checkboxOn.png"
      end    	
    	-- if i == 2 then
    	-- 	bgPosx = bgPosx + 160
    	-- 	manPath ="picdata/login/femaleIcon.png"
    	-- 	bgPath = "picdata/public/checkboxOff.png"
    	-- end
	    local bg = cc.Sprite:create(bgPath)
	    bg:setPosition(bgPosx,bgHeight/2)
	  	self.mBg:addChild(bg,0,500+i)

	  	bg:setTouchEnabled(true)
    	bg:setLocalZOrder(1)
    	bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event,btn) return self:buttonClick(event,bg) end)

	  	local title = cc.ui.UILabel.new({
            color = cc.c3b(73, 78, 92),
            text  = "下次自动登录",
            size  = 26,
            font  = "FZZCHJW--GB1-0.fnt",
           -- UILabelType = 1,
        })
      title:setPosition(bg:getPositionX()+40,bg:getPositionY())
      self.mBg:addChild(title)

	  	bgPosx = bgPosx + 50

	  	self.mActivitySprite[i] = bg
	 end

   local node = cc.Node:create()
   node:setVisible(false)
   self.mTipNode = node
   node:setPosition(90, bgHeight/2 - 50)
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
    node:addChild(tip)


    local btnBind = CMButton.new({normal = "picdata/login/login.png"},function () self:onMenuCallBack(EnumMenu.eBtnBind) end)     
    :align(display.CENTER, bgWidth/2,190 ) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

end
function Login500wan:buttonClick(event,sender)
    -- @TODO: all sprite click func
    local tag = sender:getTag()
    
    if tag == 501 then
        --todo mBtnClose Sprite Click
        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () self:onMenuCallBack(501) end,scale = false,})
        
        return state
    end
end


function Login500wan:onMenuCallBack(tag)
    -- @TODO: implement this
   if tag == 501 then
   	  if self.mCurType ~= true then
   	  	 self.mCurType = true
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOn.png"):getTexture())
   	  else
   	  	 self.mCurType = false
   	  	 self.mActivitySprite[1]:setTexture(cc.Sprite:create("picdata/public/checkboxOff.png"):getTexture())
   	  end

   elseif tag == EnumMenu.eBtnBind then
   		self:onMenuBind()
   end
end

function Login500wan:onMenuBind()
  local sAccount = self.mInputBox[1]:getText()
  local sPassword  = self.mInputBox[2]:getText()
	if sAccount == "" or sPassword == "" then self.mTipNode:setVisible(true) return end 
  self.m_login:debaoPlatformLoginRequest(sAccount, sPassword, eDebaoPlatform500wan, true, self.mCurType)
  self.loginSelectDialog:setVisible(true)
  self:removeFromParent()
end
-- 输入事件监听方法
function Login500wan:onEdit(event, editbox)
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
function Login500wan:httpResponse(tableData,tag) 
--  dump(tableData,tag)
  	
    if tag == POST_COMMAND_TOURISTTURNDEBAO then  
        UserDefaultSetting:getInstance():setLastLoginName(self.mInputBox[1]:getText())
		    UserDefaultSetting:getInstance():setLastLoginPassword("")
         tableData["CODE"] = tonumber(tableData["CODE"])
         local tips = ""			--请求列表回调
         local callOk 
         if tableData["CODE"] == 1 then
         	tips = "恭喜您成功绑定德堡帐号！为了您的账户安全请重新登录。"
         	callOk = function () 
         		
				-- local scene = require("app.GUI.login.LoginView"):new("enter")
    --     GameSceneManager:switchScene(scene)
        
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
		CMOpen(AlertDialog,self:getParent())
    end
    
end
return Login500wan