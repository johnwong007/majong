--
-- Author: junjie
-- Date: 2015-12-15 19:49:08
--
--手机绑定
local MobileBlind = class("MobileBlind",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
local CMButton = require("app.Component.CMButton")
local EditText = require("app.architecture.components.EditText")
require("app.Tools.StringFormat")

local EnumMenu = {
	eBtnBind = 1,
	eBtnGet  = 2,
}
function MobileBlind:ctor(params)
  self.params = params or {}
	self:setNodeEventEnabled(true)	
	self.mInputBox = {}
	self.mTime = 120
end
function MobileBlind:create()
  self:initUI()
end
function MobileBlind:onExit()
	QManagerScheduler:removeLocalScheduler({layer = self}) 
end
function MobileBlind:initUI()
  local sTipText = "提高帐号安全性；用于找回密码、派发实物奖励。"
  if  GIOSCHECK then
       sTipText = "提高帐号安全性；用于找回密码。"
  end
	-- self.mBg = cc.Sprite:create("picdata/setting/blindBG.png")
 --  local bgWidth = self.mBg:getContentSize().width
 --  local bgHeight= self.mBg:getContentSize().height
 --  self.mBg:setPosition(display.cx,display.cy)
 --  self:addChild(self.mBg)

  local filename = "picdata/public_new/bg.png"
  local size = cc.size(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
  self.mBg = display.newScale9Sprite(filename, 0, 0, size)
  self.mBg:align(display.LEFT_BOTTOM, 0, 0)
  self:addChild(self.mBg)
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height

  -- local title = cc.Sprite:create("picdata/setting/mobileBlindTitle.png")
  -- title:setPosition(bgWidth/2,bgHeight - 40)
  -- self.mBg:addChild(title)
  local title = cc.ui.UILabel.new({
        UILabelType = 1,
        text  = self.params.title or "绑定手机",
        font  = "fonts/title.fnt",
        align = cc.ui.TEXT_ALIGN_CENTER,
    })
  title:align(display.CENTER, bgWidth/2,bgHeight - 40)
  self.mBg:addChild(title)

  local backBtn = CMButton.new({normal = "picdata/public_new/btn_back2.png",
    pressed = "picdata/public_new/btn_back2.png"},function () CMClose(self) end)
  backBtn:setPosition(45, CONFIG_SCREEN_HEIGHT-40)
  self:addChild(backBtn)

   local sTip = cc.ui.UILabel.new({
        text  = sTipText,
        size  = 24,
        color = cc.c3b(183,183,204),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
        
    })
    sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2,bgHeight-120)
    self.mBg:addChild(sTip)
   

    local posy  = sTip:getPositionY() - 55 - 30
    local data = {"请输入常用手机号","输入验证码"}
  --   for i = 1,2 do 

  

  --   	local imagePath = "picdata/setting/blindTextBG.png"
  --   	local imageSize = cc.size(426, 46)
  --   	if i == 2 then
  --   		imagePath = "picdata/setting/blindTextBG2.png"
  --   		imageSize = cc.size(266, 46)
  --   	end

  --     local inputBg  = cc.Sprite:create(imagePath)
      
  --     self.mBg:addChild(inputBg)
	 --    local inputBox = cc.ui.UIInput.new({
		--     image = "picdata/public/transBG.png", -- 输入控件的背景
		--     --x = 580,
		--    -- y = 50,	    	
		--     maxLength = 16,
		--     size = imageSize,
		--     listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		-- })

		-- inputBox:setPlaceHolder(data[i])
		-- inputBox:setFont("Arial", 22)
		-- inputBox:setFontSize(24)		
		-- inputBox:setFontColor(cc.c3b(250, 250, 250))
		-- inputBox:setPosition(118 + inputBox:getContentSize().width/2,posy-2)
		-- self.mBg:addChild(inputBox)	

  --   inputBg:setPosition(118 + inputBox:getContentSize().width/2,posy)
		-- self.mInputBox[i] = inputBox
		-- posy = posy - 75
		-- --self.mChatBox = inputBox
  --   end

    self.m_pPhoneTextField = EditText:new({
        forePath = "picdata/public_new/icon_phone.png",
        bgPath = "picdata/public_new/input.png",
        minLength= 0,
        maxLength= 28,
        place     = "请输入常用手机号",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 24,
        size = cc.size(410,38),
        inputOffsetY = -2,
        listener = function(event, editbox) 
            if event=="ended" then
                self:verifyPhoneNumber(editbox:getText()) 
            elseif event=="began" then
                self.m_pPhoneHint:setString("")
                self.m_pInputWarn:setVisible(false)
            end
            if event=="changed" then
                local text = editbox:getText()
                if not text or text=="" then
                    self.m_pSendBtn:setButtonEnabled(false)
                end
            end
        end,
        })
    self.m_pPhoneTextField:align(display.CENTER, bgWidth/2, posy-2)
        :addTo(self)
    self.mInputBox[1] = self.m_pPhoneTextField

    self.m_pInputWarn = cc.ui.UIImage.new("picdata/public_new/input_warn.png")
    self.m_pInputWarn:align(display.CENTER, self.m_pPhoneTextField:getPositionX(),
        self.m_pPhoneTextField:getPositionY())
        :addTo(self, 1)
    self.m_pInputWarn:setVisible(false)

    self.m_pPhoneHint = cc.ui.UILabel.new({
        color = cc.c3b(255, 90, 0),
        text  = "",
        size  = 24,
        font  = "黑体",
        align = cc.ui.TEXT_ALIGN_LEFT,
        })
    self.m_pPhoneHint:align(display.LEFT_CENTER, self.m_pPhoneTextField:getPositionX()+265,
        self.m_pPhoneTextField:getPositionY())
    self:addChild(self.m_pPhoneHint)

    posy = posy - 75

    self.m_pVerifyCodeTextField = EditText:new({
        forePath = "picdata/public_new/icon_message.png",
        bgPath = "picdata/public_new/input.png",
        minLength= 0,
        maxLength= 28,
        place     = "请输入验证码",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 24,
        foreBgSize = cc.size(300,70),
        size = cc.size(410,38),
        inputOffsetY = -2,
        listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
        -- listener = function(event, editbox) 
        --     if event=="ended" then
        --         self.m_pPresenter:verifyCode(editbox:getText()) 
        --     end
        -- end,
        })
    self.m_pVerifyCodeTextField:align(display.CENTER, bgWidth/2-112,posy-2)
        :addTo(self)
    self.mInputBox[2] = self.m_pVerifyCodeTextField

    self.m_pSendBtn = CMButton.new({normal = {"picdata/public_new/btn_purple.png","picdata/loginNew/register/w_hqyzm.png"},
        pressed = {"picdata/public_new/btn_purple_p.png","picdata/loginNew/register/w_hqyzm.png"},
        disabled = {"picdata/public_new/btn_purple_p.png","picdata/loginNew/register/w_hqyzm.png"}},
        function () self:onMenuCallBack(EnumMenu.eBtnGet) end, nil, {changeAlpha = true})
    self.m_pSendBtn:setPosition(bgWidth/2+156, self.m_pVerifyCodeTextField:getPositionY()-2)
    self:addChild(self.m_pSendBtn)
    posy = posy - 75
 	
 	-- local btnGet = CMButton.new({normal = "picdata/setting/mobileGetBtn.png"},function () self:onMenuCallBack(EnumMenu.eBtnGet) end)    
  --   :align(display.CENTER, bgWidth/2 + 140,self.mInputBox[2]:getPositionY() ) --设置位置 锚点位置和坐标x,y
  --   :addTo(self.mBg)


  -- local btnBind = CMButton.new({normal = "picdata/setting/mobileBindBtn.png"},function () self:onMenuCallBack(EnumMenu.eBtnBind) end)    
  --   :align(display.CENTER, bgWidth/2,60) --设置位置 锚点位置和坐标x,y
  --   :addTo(self.mBg)
  --   btnBind:setButtonEnabled(false)

local btnBind = CMButton.new({normal = "picdata/public_new/btn_greenlong.png",pressed = "picdata/public_new/btn_greenlong_p.png"},function () 
      self:onMenuCallBack(EnumMenu.eBtnBind) end, {scale9 = false})    
    :align(display.CENTER, bgWidth/2,posy-40) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
    btnBind:setButtonLabel("normal",cc.ui.UILabel.new({
      color = cc.c3b(255, 255, 255),
      -- color = cc.c3b(255, 255, 155),
      text = "绑定",
      size = 28,
      font = "黑体",
    }))
    btnBind:setButtonEnabled(false)

    if self.params[USER_PHONE_NUMBER] == "None" then
        local tips = cc.Sprite:create("picdata/setting/tips_bdsj.png")
        tips:setPosition(btnBind:getPositionX() + 200,btnBind:getPositionY())
        self.mBg:addChild(tips)

       local sNum = cc.ui.UILabel.new({
      	    text  = "2000",
      	    size  = 26,
      	    color = cc.c3b(0, 255, 225),
      	    align = cc.ui.TEXT_ALIGN_LEFT,
      	    --UILabelType = 1,
      	    font  = "黑体",
      	    
      	})
        sNum:setPosition(5 + sNum:getContentSize().width/2,22)
          tips:addChild(sNum)
       local sGold = cc.ui.UILabel.new({
      	    text  = "金币",
      	    size  = 20,
      	    color = cc.c3b(0, 255, 225),
      	    align = cc.ui.TEXT_ALIGN_LEFT,
      	    --UILabelType = 1,
      	    font  = "黑体",
      	    
      	})
        sGold:setPosition(sNum:getPositionX()+ sNum:getContentSize().width,22)
        tips:addChild(sGold)
  tips:setVisible(false)
    end
  self.mTip    = sTip
  self.mBtnGet = btnGet
  self.mBtnBind= btnBind
  --QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:updateTime() end,interval = 1})
end
-- 输入事件监听方法
function MobileBlind:onEdit(event, editbox)
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
		-- self._sendRoleId = 0
		-- self._chatPlayer:setText("")
  -- 		self._chatName:setString(_trimed or "")
  -- 		self._chatName:setPositionX(self._chatPlayer:getContentSize().width/2 - self._chatName:getContentSize().width/2)
    elseif event == "ended" then
    -- 输入结束
        --print("输入结束")        
    elseif event == "return" then
    	
    	
    -- 从输入框返回
        --print("从输入框返回")       
    end
end
function MobileBlind:onMenuCallBack(tag)
	if tag == EnumMenu.eBtnBind then
    self:onMenuBind()
	elseif tag == EnumMenu.eBtnGet then
		self:onMenuGet()
	end
end
function MobileBlind:onMenuBind()
  local sPhone = self.mInputBox[1]:getText()
  local sVerify  = self.mInputBox[2]:getText()
	if sPhone == "" or sVerify == "" then return end 
  DBHttpRequest:bindMobile(function(tableData,tag) self:httpResponse(tableData,tag) end, sPhone,sVerify) 
end

function MobileBlind:onMenuGet()
	local sPhone = self.mInputBox[1]:getText()
	local lens   = string.len(sPhone)
	if sPhone == "" then return end
	if lens ~= 11 or not tonumber(sPhone) then
      local CMToolTipView = require("app.Component.CMToolTipView").new({text = "请输入有效的手机号码",isSuc = false})
      CMOpen(CMToolTipView,self)
      return 
	end 

	DBHttpRequest:getMobileVerifyCode(function(tableData,tag) self:httpResponse(tableData,tag) end, sPhone) 
	
end
function MobileBlind:updateTime()
	self.mTime = self.mTime - 1 
	self.mTip:setString(self.mTime.."s重新发送")
	if self.mTime <=  0 then
		QManagerScheduler:removeLocalScheduler({layer = self}) 
		self.mTip:setString("提高帐号安全性；用于找回密码、派发实物奖励。")
    self.mTip:setPositionX(self.mBg:getContentSize().width/2-self.mTip:getContentSize().width/2)
    self.mBtnGet:setTexture("picdata/setting/mobileGetBtn.png")
	end
end
--[[
  网络回调
]]
function MobileBlind:httpResponse(tableData,tag,fileName) 
  --dump(tableData,tag)
    if tag == POST_COMMAND_GETMOBILEVERIFYCODE then
        local isSuc = true
        local text  = ""
      if tableData == 1 then 
        text = "验证短信已发送，请注意查收"
        self.mBtnGet:setTexture("picdata/setting/mobileGetBtn.png",true)
        self.mTime  = 120
        self.mTip:setString(self.mTime.."s重新发送")
        self.mTip:setPositionX(self.mBg:getContentSize().width/2-self.mTip:getContentSize().width/2)
        QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:updateTime() end,interval = 1})
        self.mBtnBind:setButtonEnabled(true)
      else
          text = "短信发送失败，请稍后再试。"
          if tableData == -1 then
              text = "手机号码无效"
          elseif tableData == -2 then
              text = "获取验证码太频繁"
          elseif tableData == -3 then
              text = "手机号码已经被占用"
          end
          isSuc = false
      end
      local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
      CMOpen(CMToolTipView,self)  

    elseif tag == POST_COMMAND_BINLDMOBILE then
      local isSuc = true
      local text  = ""
      local posx  
      local parent 
      if tableData == 1 then 
        text = "绑定手机号码成功"       
        CMClose(self)   
        parent = self:getParent()    
        posx   = -parent:getPositionX()
      else
          text = "绑定失败，请稍后再试。"
          if (tableData == -1) then
              text = "手机号码无效"
          elseif(tableData == -2) then
              text = "验证码错误"
          end
          isSuc = false
          parent= self
      end
      local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
      CMOpen(CMToolTipView,parent,posx)  

    end
    
end

function MobileBlind:verifyPhoneNumber(phoneNumber)
    self.m_bPhoneIsOk = false
    local msg = ""
    if not phoneNumber or phoneNumber=="" then
        msg="亲，手机号不能为空"
    elseif not isRightPhoneNumber(phoneNumber) then
        msg="亲，手机号格式不对哦"
    else
        self.m_bPhoneIsOk = true
        self.m_pSendBtn:setButtonEnabled(true)
        return
    end
    self:showPhoneHint(msg)
end

function MobileBlind:showPhoneHint(msg)
    self.m_pPhoneHint:setVisible(true)
    self.m_pPhoneHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pSendBtn:setButtonEnabled(false)
end

return MobileBlind