local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local g_subtitle = "德堡向您保证将保护您资料的隐私"
local CMTextButton = require("app.Component.CMTextButton")
local EditText = require("app.architecture.components.EditText")
local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")
local myInfo = require("app.Model.Login.MyInfo")
local imageUtils = require("app.Tools.ImageUtils")
require("app.Tools.StringFormat")

local RegisterPresenter = class("RegisterPresenter", function()
        return BasePresenter:new()
    end)

function RegisterPresenter:ctor(o,params)
    self.m_pView = params.view
    self.m_pView:setPresenter(self)
    self.m_bUsernameIsOk = false
    self.m_bPasswordIsOk = false
    self.m_bPhoneIsOk = false
end

function RegisterPresenter:start()
    if myInfo.data.phpSessionId and myInfo.data.phpSessionId ~= "" then
        local name = UserDefaultSetting:getInstance():getDebaoLoginName()
        local password = UserDefaultSetting:getInstance():getDebaoLoginPassword()
        self.m_pView:setUsername(name)
        self.m_pView:setPassword(password)
    end
end

function RegisterPresenter:verifyAccount(username)
    self.m_bUsernameIsOk = false
    local msg = ""
    if not username or username=="" then
        msg="亲，用户名不能为空"
    elseif StringFormat:getStringLen(username)<4 then
        msg="亲，用户名太短了"
    elseif StringFormat:getStringLen(username)>16 then
        msg="亲，用户名太长了"
    else
        if not myInfo.data.phpSessionId or myInfo.data.phpSessionId=="" then
            HttpClient:checkPlatformId(handler(self, self.checkPlatformIdCallback), username, "DEBAO")
        else
            self.m_bUsernameIsOk = true
            self:checkIfCanSendVerifyCode()
        end
        return
    end
    self.m_pView:showUsernameHint(msg)
end

function RegisterPresenter:checkPlatformIdCallback(tableData, tag)
    local code = tonumber(tableData)
    if not code or code~=1 then
        self.m_bUsernameIsOk = true
        self:checkIfCanSendVerifyCode()
    else
        self.m_pView:showUsernameHint("用户名已存在")
    end
end

function RegisterPresenter:verifyPassword(password)
    self.m_bPasswordIsOk = false
    local msg = ""
    if not password or password=="" then
        msg="亲，密码不能为空"
    elseif StringFormat:getStringLen(password)<6 then
        msg="亲，密码太短了"
    elseif StringFormat:getStringLen(password)>16 then
        msg="亲，密码太长了"
    elseif string.find(password, " ") then
        msg="亲，密码不能包含空格"
    elseif self:isPureDigit(password) then
        msg="密码不能为纯数字"
    else
        self.m_bPasswordIsOk = true
        self:checkIfCanSendVerifyCode()
        return
    end
    self.m_pView:showPasswordHint(msg)
end

function RegisterPresenter:isPureDigit(password)
    if not password or password=="" then
        return false
    end
    local ret = true 
    for i=1,string.len(password) do
        if not tonumber(string.sub(password, i, i)) then
            ret = false
            break
        end
    end
    return ret
end

function RegisterPresenter:verifyPhoneNumber(phoneNumber)
    self.m_bPhoneIsOk = false
    local msg = ""
    if not phoneNumber or phoneNumber=="" then
        msg="亲，手机号不能为空"
    elseif not isRightPhoneNumber(phoneNumber) then
        msg="亲，手机号格式不对哦"
    else
        self.m_bPhoneIsOk = true
        self:checkIfCanSendVerifyCode()
        return
    end
    self.m_pView:showPhoneHint(msg)
end

function RegisterPresenter:verifyCode(code)
    code = code or ""
    self.m_bCodeIsOk = false
    local flag = true
    for i=1,string.len(code) do
        local num = tonumber(string.sub(code,i,i))
        if not num then
            flag = false
            break
        end
    end
    if code=="" then
        flag = false
    end
    self.m_bCodeIsOk = flag
end

function RegisterPresenter:checkIfCanSendVerifyCode()
    if self.m_bUsernameIsOk and self.m_bPasswordIsOk and self.m_bPhoneIsOk then
        self.m_pView:setSendButtonVisible(true)
    else
        self.m_pView:setSendButtonVisible(false)
    end
end

function RegisterPresenter:sendVerifyMsg()
    if self.m_bPhoneIsOk then
        local username = UserDefaultSetting:getInstance():getDebaoLoginName()
        HttpClient:sendVerifyMsg(function(tableData,tag) self:sendVerifyMsgCallback(tableData,tag) end, "phone",
            self.m_pView:getPhoneNumber(),username,"DEBAO") 
    end
end

function RegisterPresenter:sendVerifyMsgCallback(tableData,tag)
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
        self.m_pView:sendVerifyCode()
    else 
        isSuc = false
    end
    self.m_pView:showToolTips({text = returnCode[tostring(tableData)],isSuc = isSuc})    
end

function RegisterPresenter:verifyPhoneCode()
    if self.m_bCodeIsOk then
        HttpClient:verifyPhoneCode(function(tableData,tag) self:verifyPhoneCodeCallback(tableData,tag) end,self.m_pView:getCode()) 
    else
        -- self.m_pView:showToolTips({text = "请输入验证码",isSuc = false}) 
    end
end

function RegisterPresenter:verifyPhoneCodeCallback(tableData,tag)
    local text = ""
    local tag  = 0
    local isSuc = nil
    if tableData == 1 then
        text = "注册成功"
        isSuc= true
        tag  = 3
    else
        text = "验证码错误"
        isSuc= false
    end
    -- QManagerListener:Notify({layerID = eLoginViewLayerID,tag = tag})
    self.m_pView:showToolTips({text = text,isSuc = isSuc})   
end

function RegisterPresenter:registerPC()
    if not myInfo.data.phpSessionId or myInfo.data.phpSessionId=="" then
        if self.m_bUsernameIsOk and self.m_bPasswordIsOk and self.m_bPhoneIsOk then
            local sAccount = self.m_pView:getUsername()
            local sPassword = self.m_pView:getPassword()
            local sex = "男"
            HttpClient:registerPC(function(tableData,tag) self:registerPCCallBack(tableData,tag) end, sAccount,sPassword,sex,"")   --下一步
        end
    else
        self:sendVerifyMsg()
    end
end

function RegisterPresenter:registerPCCallBack(tableData,tag)
    if type(tableData) ~= "table" then return end
    if tableData["0001"] == 1 then           
        myInfo.data.phpSessionId = tableData["0002"]
        HttpClient:setSession(tableData["0002"])
        UserDefaultSetting:getInstance():setDebaoLoginName(self.m_pView:getUsername())
        UserDefaultSetting:getInstance():setDebaoLoginPassword(self.m_pView:getPassword())
        UserDefaultSetting:getInstance():setRemeberAccountEnable(true)
        UserDefaultSetting:getInstance():setRemeberPasswordEnable(true)
        QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 4})
        self:registerPC()
    else

    end
end

local RegisterFragment = class("RegisterFragment", function()
		return BaseView:new()
	end)

function RegisterFragment:create()
	self:initUI()
    self.m_pPresenter:start()
end

function RegisterFragment:ctor(params)
	self.params = params or {}
	self:setNodeEventEnabled(true)

    RegisterPresenter:new({view=self})
    self:setNodeEventEnabled(true)
end

function RegisterFragment:onEnterTransitionFinish()
    local fixedPriority = 1
    self.m_pShowInputEvt = cc.EventListenerCustom:create("SHOW_INPUT", handler(self, self.showInput))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.m_pShowInputEvt, fixedPriority)
    self.m_pShowInputEvt = cc.EventListenerCustom:create("SHOW_INPUT", handler(self, self.hideInput))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.m_pShowInputEvt, fixedPriority)
end

function RegisterFragment:onExit()
	QManagerScheduler:removeLocalScheduler({layer = self}) 
    if self.m_pShowInputEvt then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_pShowInputEvt)
        self.m_pShowInputEvt = nil
    end
end

function RegisterFragment:initUI()
    
    local filename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/login_dif/bg_login2.png")
    local bg = cc.ui.UIImage.new(filename)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
        :addTo(self)
        
	self.m_pTitle = cc.ui.UIImage.new("picdata/loginNew/register/w_title_zc.png")
    self.m_pTitle:align(display.CENTER, bgWidth/2,bgHeight - 75)
	self:addChild(self.m_pTitle)

   	self.m_pSubTitle = cc.ui.UILabel.new({
        text  = g_subtitle,
        size  = 24,
        color = cc.c3b(183,183,204),
        align = cc.ui.TEXT_ALIGN_CENTER,
        font  = "黑体",
    })
	self.m_pSubTitle:align(display.CENTER, self.m_pTitle:getPositionX(),self.m_pTitle:getPositionY() - 48)
	self:addChild(self.m_pSubTitle)

    local backBtn = CMButton.new({normal = "picdata/public_new/btn_back.png",
        pressed = "picdata/public_new/btn_back_p.png"},function () self:back() end)
    backBtn:setPosition(65, bgHeight-65)
    self:addChild(backBtn)

    self.m_pUsernameTextField = EditText:new({
        forePath = "picdata/public_new/icon_id.png",
        bgPath = "picdata/public_new/input.png",
        -- minLength= 0,
        -- maxLength= 100,
        place     = "用户名(4-16个字母或2-8个汉字)",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 24,
        size = cc.size(410,38),
        inputOffsetY = -2,
        listener = function(event, editbox) 
            if event=="ended" then
                self.m_pPresenter:verifyAccount(editbox:getText()) 
            elseif event=="began" then
                self.m_pUsernameHint:setString("")
                self.m_pInputWarn:setVisible(false)
            end
        end,
        })
    self.m_pUsernameTextField:align(display.CENTER, bgWidth/2, self.m_pSubTitle:getPositionY()-60)
        :addTo(self)
    
    self.m_pInputWarn = cc.ui.UIImage.new("picdata/public_new/input_warn.png")
    self.m_pInputWarn:align(display.CENTER, self.m_pUsernameTextField:getPositionX(),
        self.m_pUsernameTextField:getPositionY())
        :addTo(self, 1)
    self.m_pInputWarn:setVisible(false)

    self.m_pUsernameHint = cc.ui.UILabel.new({
        color = cc.c3b(255, 90, 0),
        text  = "",
        size  = 24,
        font  = "黑体",
        align = cc.ui.TEXT_ALIGN_LEFT,
        })
    self.m_pUsernameHint:align(display.LEFT_CENTER, self.m_pUsernameTextField:getPositionX()+265,
        self.m_pUsernameTextField:getPositionY())
    self:addChild(self.m_pUsernameHint)
   
    self.m_pPasswordTextField = EditText:new({
        forePath = "picdata/public_new/icon_password.png",
        bgPath = "picdata/public_new/input.png",
        -- minLength= 0,
        -- maxLength= 28,
        place     = "密码(6-16个字符,不能包含空格)",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 24,
        size = cc.size(410,38),
        -- inputFlag = 0,
        inputOffsetY = -2,
        listener = function(event, editbox) 
            if event=="ended" then
                self.m_pPresenter:verifyPassword(editbox:getText()) 
            elseif event=="began" then
                self.m_pPasswordHint:setString("")
                self.m_pInputWarn:setVisible(false)
            end
        end,
        })
    self.m_pPasswordTextField:align(display.CENTER, bgWidth/2, self.m_pUsernameTextField:getPositionY()-78)
        :addTo(self)

    self.m_pPasswordHint = cc.ui.UILabel.new({
        color = cc.c3b(255, 90, 0),
        text  = "",
        size  = 24,
        font  = "黑体",
        align = cc.ui.TEXT_ALIGN_LEFT,
        })
    self.m_pPasswordHint:align(display.LEFT_CENTER, self.m_pPasswordTextField:getPositionX()+265,
        self.m_pPasswordTextField:getPositionY())
    self:addChild(self.m_pPasswordHint)

    self.m_pPhoneTextField = EditText:new({
        forePath = "picdata/public_new/icon_phone.png",
        bgPath = "picdata/public_new/input.png",
        minLength= 0,
        maxLength= 28,
        place     = "您的手机号",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 24,
        size = cc.size(410,38),
        inputOffsetY = -2,
        listener = function(event, editbox) 
            if event=="ended" then
                self.m_pPresenter:verifyPhoneNumber(editbox:getText()) 
            elseif event=="began" then
                self.m_pPhoneHint:setString("")
                self.m_pInputWarn:setVisible(false)
            end
            if event=="changed" then
                local text = editbox:getText()
                if not text or text=="" then
                    self.m_pSendBtn:setVisible(false)
                    self.m_pSendDisabledNode:setVisible(true)
                end
            end
        end,
        })
    self.m_pPhoneTextField:align(display.CENTER, bgWidth/2, self.m_pPasswordTextField:getPositionY()-78)
        :addTo(self)

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
        listener = function(event, editbox) 
            if event=="ended" then
                self.m_pPresenter:verifyCode(editbox:getText()) 
            end
        end,
        })
    self.m_pVerifyCodeTextField:align(display.CENTER, bgWidth/2-111, 182+42)
        :addTo(self)

    self.m_pSendBtn = CMButton.new({normal = {"picdata/public_new/btn_purple.png","picdata/loginNew/register/w_hqyzm.png"},
        pressed = {"picdata/public_new/btn_purple_p.png","picdata/loginNew/register/w_hqyzm.png"},
        disabled = {"picdata/public_new/btn_purple_p.png","picdata/loginNew/register/w_hqyzm.png"}},
        function () self.m_pPresenter:registerPC() end, nil, {changeAlpha = true})
    self.m_pSendBtn:setPosition(bgWidth/2+156, self.m_pVerifyCodeTextField:getPositionY()-2)
    self:addChild(self.m_pSendBtn)

    self.m_pSendDisabledNode = display.newNode()
    self.m_pSendDisabledNode:addTo(self)
    self.m_pSendDisabledNode:setVisible(false)
    self.m_pSendDisabledImg = cc.ui.UIImage.new("picdata/public_new/btn_purple_d.png")
    self.m_pSendDisabledImg:align(display.CENTER, self.m_pSendBtn:getPositionX(), self.m_pSendBtn:getPositionY())
        :addTo(self.m_pSendDisabledNode)

    self.m_pSendDisabledHint = cc.ui.UILabel.new({
        color = cc.c3b(0, 255, 255),
        text  = "60s重新发送",
        size  = 28,
        font  = "黑体",
        })
    self.m_pSendDisabledHint:align(display.CENTER, self.m_pSendBtn:getPositionX(), self.m_pSendBtn:getPositionY())
    self.m_pSendDisabledNode:addChild(self.m_pSendDisabledHint)
    self.m_pSendDisabledHint:setVisible(false)

    self.m_pSendDisabledHintImage = cc.ui.UIImage.new("picdata/loginNew/register/w_hqyzm.png")
    self.m_pSendDisabledHintImage:align(display.CENTER, self.m_pSendDisabledHint:getPositionX(), self.m_pSendDisabledHint:getPositionY())
        :addTo(self.m_pSendDisabledNode)

    self.m_pSendBtn:setVisible(false)
    self.m_pSendDisabledNode:setVisible(true)

    self.m_pRegisterBtn = CMButton.new({normal = {"picdata/public_new/btn_greenlong.png","picdata/loginNew/register/w_wczc.png"},
        pressed = {"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/register/w_wczc.png"},
        disabled = {"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/register/w_wczc.png"}},
        function () self:verifyPhoneCode() end, nil, {changeAlpha = true})
    self.m_pRegisterBtn:setPosition(bgWidth/2, 78+50)
    self:addChild(self.m_pRegisterBtn, 1)

    local label = cc.ui.UILabel.new({
        color = cc.c3b(205, 211, 223),
        text  = "注册即同意",
        size  = 24,
        font  = "黑体",
        align = cc.ui.TEXT_ALIGN_RIGHT,
        })
    label:align(display.RIGHT_CENTER, bgWidth/2, 39)
    self:addChild(label)

    self.m_pAgree = CMTextButton:new({
        text  = "德堡协议>>",
        textColorN = cc.c3b(0,255,255),
        callback  = handler(self, self.openAgreement)
    })
    self.m_pAgree:align(display.CENTER, bgWidth/2+80,39)
    self:addChild(self.m_pAgree)
end

function RegisterFragment:getUsername()
    return self.m_pUsernameTextField:getText()
end

function RegisterFragment:getPassword()
    return self.m_pPasswordTextField:getText()
end

function RegisterFragment:setUsername(text)
    return self.m_pUsernameTextField:setText(text)
end

function RegisterFragment:setPassword(text)
    return self.m_pPasswordTextField:setText(text)
end

function RegisterFragment:getPhoneNumber()
    return self.m_pPhoneTextField:getText()
end

function RegisterFragment:getCode()
    return self.m_pVerifyCodeTextField:getText()
end

function RegisterFragment:showUsernameHint(msg)
    self.m_pUsernameHint:setVisible(true)
    self.m_pUsernameHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pInputWarn:setPositionY(self.m_pUsernameTextField:getPositionY())
end

function RegisterFragment:showPasswordHint(msg)
    self.m_pPasswordHint:setVisible(true)
    self.m_pPasswordHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pInputWarn:setPositionY(self.m_pPasswordTextField:getPositionY())
end

function RegisterFragment:showPhoneHint(msg)
    self.m_pPhoneHint:setVisible(true)
    self.m_pPhoneHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pInputWarn:setPositionY(self.m_pPhoneTextField:getPositionY())
    self.m_pSendBtn:setVisible(false)
    self.m_pSendDisabledNode:setVisible(true)
end

function RegisterFragment:back()
    QManagerListener:Notify({layerID = eLoginViewLayerID,tag = 1})
    CMClose(self, true)
end

function RegisterFragment:sendVerifyCode()
    self.mTime  = 60
    self.m_pSendBtn:setVisible(false)
    self.m_pSendDisabledNode:setVisible(true)
    self.m_pSendDisabledHintImage:setVisible(false)
    self.m_pSendDisabledHint:setVisible(true)
    self.m_pRegisterBtn:setButtonEnabled(true)
    QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:updateTime() end,interval = 1})
end

function RegisterFragment:showToolTips(params)
    self:setInputVisible(false)
    CMOpen(require("app.architecture.components.Toast"), self, {titleText="温馨提示", text = params.text}, true)
end

function RegisterFragment:bindPhone()
end

function RegisterFragment:verifyPhoneCode()
    self.m_pPresenter:verifyPhoneCode()
end

function RegisterFragment:openAgreement()
    self:setInputVisible(false)
    CMOpen(require("app.architecture.login.AgreementFragment"),self,{parent=self})
end

function RegisterFragment:showInput()
    self:setInputVisible(true)
end

function RegisterFragment:setInputVisible(isVisible)
    if isVisible then
        self.m_pUsernameTextField:setPositionX(bgWidth/2)
        self.m_pPasswordTextField:setPositionX(bgWidth/2)
        self.m_pPhoneTextField:setPositionX(bgWidth/2)
        self.m_pVerifyCodeTextField:setPositionX(bgWidth/2-111)
    else
        self.m_pUsernameTextField:setPositionX(4000)
        self.m_pPasswordTextField:setPositionX(4000)
        self.m_pPhoneTextField:setPositionX(4000)
        self.m_pVerifyCodeTextField:setPositionX(4000)
    end
end

function RegisterFragment:updateTime()
    self.mTime = self.mTime - 1 
    self.m_pSendDisabledHint:setString(self.mTime.."s重新发送")
    if self.mTime <=  0 then
        QManagerScheduler:removeLocalScheduler({layer = self}) 
        self.m_pSendBtn:setVisible(true)
        self.m_pSendDisabledNode:setVisible(false)
        self.m_pSendDisabledHintImage:setVisible(true)
        self.m_pSendDisabledHint:setVisible(false)
    end
end

function RegisterFragment:setSendButtonVisible(isVisible)
    self.m_pSendBtn:setVisible(isVisible)
    self.m_pSendDisabledNode:setVisible(not isVisible)
end

return RegisterFragment