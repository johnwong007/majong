--
-- Author: junjie
-- Date: 2015-12-15 16:53:16
--
--重置密码
local EditText = require("app.architecture.components.EditText")
local PasswordSetting = class("PasswordSetting",function() 
  return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
require("app.Network.Http.DBHttpRequest")
require("app.Logic.Config.UserDefaultSetting")
local CMButton = require("app.Component.CMButton")

function PasswordSetting:ctor()
	self.mInputBox = {}
end
function PasswordSetting:create()
  self:initUI()
end
function PasswordSetting:initUI()

  local filename = "picdata/public_new/bg.png"
  local size = cc.size(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
  self.mBg = display.newScale9Sprite(filename, 0, 0, size)
  self.mBg:align(display.LEFT_BOTTOM, 0, 0)
  self:addChild(self.mBg)

	-- self.mBg = cc.Sprite:create("picdata/setting/pwSettingBG.png")
  -- self.mBg:setPosition(display.cx,display.cy)
  -- self:addChild(self.mBg)
  local bgWidth = self.mBg:getContentSize().width
  local bgHeight= self.mBg:getContentSize().height

  -- local title = cc.Sprite:create("picdata/setting/pwSettingTitle.png")
  -- title:setPosition(bgWidth/2,bgHeight - 40)
  -- self.mBg:addChild(title)
  local title = cc.ui.UILabel.new({
        UILabelType = 1,
        text  = "修改密码",
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
        -- text  = "密码由6-15个数字加字母组成",
        text  = "建议使用字母加数字组合、混合大小写、特殊符号等提高密码难度",
        size  = 24,
        color = cc.c3b(183,183,204),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
        
    })
    sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2,bgHeight-120)
    self.mBg:addChild(sTip)
    local posy  = sTip:getPositionY() - 55 - 30
    local data = {"当前密码","新密码","确认密码"}
    for i = 1,3 do 
  --   	local inputBg  = cc.Sprite:create("picdata/setting/blindTextBG.png")
  --   	inputBg:setPosition(bgWidth/2,posy)
  --   	self.mBg:addChild(inputBg)

	 --    local inputBox = cc.ui.UIInput.new({
		--     image = "picdata/public/transBG.png", -- 输入控件的背景
		--     --x = 580,
		--    -- y = 50,	    	
		--     maxLength = 16,
		--     size = cc.size(426,46),
		--     listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
		-- })
		-- if i ~= 1 then
		-- 	inputBox:setInputFlag(0)
		-- end
		-- inputBox:setPlaceHolder(data[i])
		-- inputBox:setFont("Arial", 22)
		-- inputBox:setFontSize(24)		
		-- inputBox:setFontColor(cc.c3b(250, 250, 250))
		-- inputBox:setPosition(bgWidth/2+2,posy-4)
		-- self.mBg:addChild(inputBox)	

		--self.mChatBox = inputBox


      local inputBox = EditText:new({
          forePath = "picdata/public_new/icon_password.png",
          bgPath = "picdata/public_new/input.png",
          -- minLength= 0,
          -- maxLength= 100,
          place     = data[i],
          color     = cc.c3b(0, 0, 0),
          fontSize  = 24,
          size = cc.size(410,38),
          inputOffsetY = -2,
          listener = function(event, editbox) 
              if event=="ended" then
                  
              elseif event=="began" then
                  
              end
          end,
          })
      inputBox:align(display.CENTER, bgWidth/2+2, posy-4)
          :addTo(self.mBg)
      self.mInputBox[i] = inputBox
      posy = posy - 75 - 5
    end

     local sTip = cc.ui.UILabel.new({
        text  = "温馨提示：请牢记您的新密码以方便登录。",
        size  = 24,
        color = cc.c3b(255,90,0),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
        
    })
    sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2,posy)
    self.mBg:addChild(sTip)
    self.mTip = sTip

  -- local btnReset = CMButton.new({normal = "picdata/setting/pwResetBtn.png"},function () self:onMenuCallBack(1) end)    
  --   :align(display.CENTER, bgWidth/2,60) --设置位置 锚点位置和坐标x,y
  --   :addTo(self.mBg)


    local btnReset = CMButton.new({normal = "picdata/public_new/btn_greenlong.png",pressed = "picdata/public_new/btn_greenlong_p.png"},function () 
      self:onMenuCallBack(1) end, {scale9 = false})    
    :align(display.CENTER, bgWidth/2, posy-80) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
    btnReset:setButtonLabel("normal",cc.ui.UILabel.new({
      color = cc.c3b(255, 255, 255),
      -- color = cc.c3b(255, 255, 155),
      text = "保存",
      size = 28,
      font = "黑体",
    }))
end
function PasswordSetting:onMenuCallBack(tag)
	local oldpassword = self.mInputBox[1]:getText()
	local passwordone = self.mInputBox[2]:getText()
	local passwordtwo = self.mInputBox[3]:getText()
	if oldpassword == "" and passwordone == "" and passwordtwo == "" then 
		return 
	end
	if passwordone ~= passwordtwo then
		self.mTip:setString("两次输入密码不一致")
		self.mTip:setPositionX(self.mBg:getContentSize().width/2 - self.mTip:getContentSize().width/2)
		return 
	end
	local lens = string.len(passwordone)
	if lens < 6 or lens > 15 then
		self.mTip:setString("请输入6-15位数字与字母组合密码")
		self.mTip:setPositionX(self.mBg:getContentSize().width/2 - self.mTip:getContentSize().width/2)
		self.mInputBox[2]:setText("")
		self.mInputBox[3]:setText("")
		return
	end
	if tonumber(passwordone) then
		self.mTip:setString("密码不能全为数字")
		self.mTip:setPositionX(self.mBg:getContentSize().width/2 - self.mTip:getContentSize().width/2)
		self.mInputBox[2]:setText("")
		self.mInputBox[3]:setText("")
		return
	end
	if self:checkIsSame(passwordone) then
		self.mTip:setString("密码不能完全相同")
		self.mTip:setPositionX(self.mBg:getContentSize().width/2 - self.mTip:getContentSize().width/2)
		self.mInputBox[2]:setText("")
		self.mInputBox[3]:setText("")
		return
	end
	 DBHttpRequest:updatePassword(function(tableData,tag) self:httpResponse(tableData,tag) end, oldpassword,passwordone) 
end
function PasswordSetting:checkIsSame(str)
	if string.len(str) == 0 then return end
	local char = string.sub(str,1,1)
	local pattern = string.gsub("%0ds","d",string.len(str))
	local newStr = string.format(pattern,char)
	newStr =string.gsub(newStr,"0",char)
	if newStr == str then 
		return true
	else
	 	return false
	end 

end
-- 输入事件监听方法
function PasswordSetting:onEdit(event, editbox)
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

--[[
  网络回调
]]
function PasswordSetting:httpResponse(tableData,tag,fileName) 
  --dump(tableData,tag)
    if tag == POST_UPDATE_PASSWORD then
      local isSuc = true
      if tableData["CODE"] == 1 then
      	UserDefaultSetting:getInstance():setDebaoLoginPassword("") 
        local parent = self:getParent() 
        CMClose(self)
        local AlertDialog = require("app.Component.CMAlertDialog").new({text = "您已成功修改密码！为了您的账户安全请重新登录。",showClose = 0,callOk = function ()       
          GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView,{nType = "enter"})
        end })
        CMOpen(AlertDialog,parent,-parent:getPositionX())
        return true
      else
        isSuc = false
      end
      local CMToolTipView = require("app.Component.CMToolTipView").new({text = tableData.info,isSuc = isSuc})
      CMOpen(CMToolTipView,self)      
    end
    
end
return PasswordSetting