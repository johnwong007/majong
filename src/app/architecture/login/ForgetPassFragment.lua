local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local CMTextButton = require("app.Component.CMTextButton")
local EditText = require("app.architecture.components.EditText")
local GafAnimation = require("app.architecture.components.GafAnimation")
local g_subtitle = {"为了您的帐号安全，德堡提供以下方式重置您的密码",
	"您选择手机重置密码，新密码将以短信形式发送到您填写的手机号码",
	"您选择邮箱重置密码，新密码将以邮件形式发送到您填写的邮箱"
}
local g_success_hint={"新密码已成功发送至","请您注意查看手机短信","请您注意查看邮箱"}
local g_reset_title={"重置密码","使用新密码登录游戏"}
        
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

local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")

local ForgetPassPresenter = class("ForgetPassPresenter", function()
        return BasePresenter:new()
    end)

function ForgetPassPresenter:ctor(o,params)
    self.m_pView = params.view
    self.m_pView:setPresenter(self)
    self.m_bUsernameIsOk = false
    self.m_bPhoneIsOk = false
    self.m_bEmailIsOk = false
end

function ForgetPassPresenter:start()

end

function ForgetPassPresenter:verifyAccount(username)
    self.m_bUsernameIsOk = false
    local msg = ""
    if not username or username=="" then
        msg="亲，用户名不能为空"
    elseif string.len(username)<4 then
        msg="亲，用户名太短了"
    elseif string.len(username)>16 then
        msg="亲，用户名太长了"
    else
        HttpClient:checkPlatformId(handler(self, self.checkPlatformIdCallback), username, "DEBAO")
        return
    end
    self.m_pView:showUsernameHint(msg)
end

function ForgetPassPresenter:checkPlatformIdCallback(tableData, tag)
    local code = tonumber(tableData)
    if not code or code~=1 then
        self.m_pView:showUsernameHint("用户名不存在")
    else
        self.m_bUsernameIsOk = true
    end
end

function ForgetPassPresenter:verifyPhoneNumber(phoneNumber)
    self.m_bPhoneIsOk = false
    local msg = ""
    if not phoneNumber or phoneNumber=="" then
        msg="亲，手机号不能为空"
    elseif not isRightPhoneNumber(phoneNumber) then
        msg="亲，手机号格式不对哦"
    else
        self.m_bPhoneIsOk = true
        return
    end
    self.m_pView:showPhoneHint(msg)
end

function ForgetPassPresenter:verifyEmail(email)
    self.m_bEmailIsOk = false
    local msg = ""
    if not email or email=="" then
        msg="亲，邮箱不能为空"
    elseif not isRightEmail(email) then
        msg="亲，邮箱格式不对哦"
    else
        -- HttpClient:checkPlatformId(handler(self, self.checkIsEmailExistCallback), email)
        self.m_bEmailIsOk = true
        return
    end
    self.m_pView:showEmailHint(msg)
end

-- function ForgetPassPresenter:checkIsEmailExistCallback(tableData, tag)

-- end

function ForgetPassPresenter:resetPassword(data)
    self.m_pResetData = data
    if data.nType == 1 then
        if not self.m_bUsernameIsOk or not self.m_bPhoneIsOk then
            return
        end
        DBHttpRequest:resetPassword(handler(self, self.resetPassByPhoneCallback),"MOBILE",data.username,"",data.phoneNumber)
        self.m_pView:switchLayer(self.m_pView.Layer.STEP_PHONE_SEND)
    else
        if not self.m_bUsernameIsOk or not self.m_bEmailIsOk then
            return
        end
        DBHttpRequest:resetPassword(handler(self, self.resetPassByEmailCallback),"EMAIL",data.username,data.email,"") 
        self.m_pView:switchLayer(self.m_pView.Layer.STEP_EMAIL_SEND)
    end 
end

function ForgetPassPresenter:resetPassByPhoneCallback(tableData,tag) 
    local msg = returnCode[tostring(tableData)]
    if tostring(tableData)=="1" then
        msg = g_success_hint[1]..self.m_pResetData.phoneNumber.."\n  "..g_success_hint[2]
        self.m_pView:setResetResult("重置成功")
    else
        self.m_pView:setResetResult("重置失败")
    end
    self.m_pView:showPhoneSuccessHint(msg)
end

function ForgetPassPresenter:resetPassByEmailCallback(tableData,tag) 
    local msg = returnCode[tostring(tableData)] 
    if tostring(tableData)=="1" then
        msg = g_success_hint[1]..self.m_pResetData.email.."\n  "..g_success_hint[3]
        self.m_pView:setResetResult("重置成功")
    else
        self.m_pView:setResetResult("重置失败")
    end
    self.m_pView:showEmailSuccessHint(msg)
end


local ForgetPassFragment = class("ForgetPassFragment", function()
		return BaseView:new()
	end)

ForgetPassFragment.Layer = {
	STEP_SELECT = 1,
	STEP_PHONE_PREPARE = 2,
    STEP_EMAIL_PREPARE = 3,
    STEP_PHONE_SEND = 4,
    STEP_EMAIL_SEND = 5,
    STEP_PHONE_SUCCESS = 6,
    STEP_EMAIL_SUCCESS = 7,
}

function ForgetPassFragment:create()
	self:initUI()
end

function ForgetPassFragment:ctor(params)
	self.params = params or {}
	self:setNodeEventEnabled(true)

    ForgetPassPresenter:new({view=self}):start()
end

function ForgetPassFragment:onExit()
	QManagerScheduler:removeLocalScheduler({layer = self}) 
end

function ForgetPassFragment:initUI()
	self.m_pTitle = cc.ui.UIImage.new("picdata/loginNew/resetpass/w_title_mm.png")
    self.m_pTitle:align(display.CENTER, bgWidth/2,bgHeight - 75)
	self:addChild(self.m_pTitle)

   	self.m_pSubTitle = cc.ui.UILabel.new({
        text  = g_subtitle[1],
        size  = 24,
        color = cc.c3b(183,183,204),
        align = cc.ui.TEXT_ALIGN_CENTER,
        font  = "黑体",
    })
	self.m_pSubTitle:align(display.CENTER, self.m_pTitle:getPositionX(),self.m_pTitle:getPositionY() - 50)
	self:addChild(self.m_pSubTitle)

	self.m_pLine = cc.ui.UIImage.new("picdata/loginNew/login/line_or.png")
    self.m_pLine:align(display.CENTER, bgWidth/2, 139)
        :addTo(self)

    local backBtn = CMButton.new({normal = "picdata/public_new/btn_back.png",
        pressed = "picdata/public_new/btn_back_p.png"},function () self:back() end)
    backBtn:setPosition(65, bgHeight-65)
    self:addChild(backBtn)

    self.m_pUsernameTextField = EditText:new({
        forePath = "picdata/public_new/icon_id.png",
        bgPath = "picdata/public_new/input.png",
        minLength= 0,
        maxLength= 28,
        place     = "请输入您的用户名",
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
    self.m_pUsernameTextField:align(display.CENTER, bgWidth/2, self.m_pSubTitle:getPositionY()-90)
        :addTo(self)
    
    self.m_pInputWarn = cc.ui.UIImage.new("picdata/public_new/input_warn.png")
    self.m_pInputWarn:align(display.CENTER, self.m_pUsernameTextField:getPositionX(),
        self.m_pUsernameTextField:getPositionY())
        :addTo(self, 1)

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

    self.m_pResetBtn = CMButton.new({normal = {"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_czmm.png"},
        pressed = {"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"},
        disabled = {"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"}},
        function () self:resetPass() end, nil, {changeAlpha = true})
    self.m_pResetBtn:setPosition(bgWidth/2, self.m_pLine:getPositionY()+70)
    self:addChild(self.m_pResetBtn)

    local textBtnPosY = self.m_pLine:getPositionY()-59
    self.m_pReTryBtn = CMTextButton:new({
        text  = "不重置,再试一次？",
        callback  = function(event) self:back(true) end
    })
    self.m_pReTryBtn:align(display.CENTER, bgWidth/2-150,textBtnPosY)
    self:addChild(self.m_pReTryBtn)

    self.m_pUseEmail = CMTextButton:new({
        text  = "用邮箱重置",
        callback  = handler(self, self.findByEmail)
    })
    self.m_pUseEmail:align(display.CENTER, bgWidth/2+192,textBtnPosY)
    self:addChild(self.m_pUseEmail)

    self.m_pUsePhone = CMTextButton:new({
        text  = "用手机重置",
        callback  = handler(self, self.findByPhone)
    })
    self.m_pUsePhone:align(display.CENTER, bgWidth/2+192,textBtnPosY)
    self:addChild(self.m_pUsePhone)

    self.m_pSendAgain = CMTextButton:new({
        text  = "没收到，重新发送？",
        callback  = handler(self, self.sendAgain)
    })
    self.m_pSendAgain:align(display.CENTER, bgWidth/2,textBtnPosY)
    self:addChild(self.m_pSendAgain)

	--[[选择找回方式]]
	--------------------------------------------------------------------------------
    self.m_pSelectLayer = display.newNode()
    self.m_pSelectLayer:addTo(self)

	local btnPhone = CMButton.new({normal = {"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_sjzh.png"},
        pressed = {"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_sjzh.png"}},
        function () self:findByPhone() end, nil, {changeAlpha = true})
	btnPhone:setPosition(bgWidth/2, 278+12+100)
	self.m_pSelectLayer:addChild(btnPhone)

	local btnEmail = CMButton.new({normal = {"picdata/public_new/btn_purplelong.png","picdata/loginNew/resetpass/w_yxzh.png"},
        pressed = {"picdata/public_new/btn_purplelong_p.png","picdata/loginNew/resetpass/w_yxzh.png"}},
        function () self:findByEmail() end, nil, {changeAlpha = true})
	btnEmail:setPosition(bgWidth/2, 278)
	self.m_pSelectLayer:addChild(btnEmail)

	--[[手机号找回]]
	--------------------------------------------------------------------------------
    --[[手机号输入框]]

    local phoneEditTextPosY = self.m_pUsernameTextField:getPositionY()-80
    self.m_pPhoneTextField = EditText:new({
        forePath = "picdata/public_new/icon_phone.png",
        bgPath = "picdata/public_new/input.png",
        minLength= 0,
        maxLength= 28,
        place     = "请输入绑定的手机号",
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
        end,
        })
    self.m_pPhoneTextField:align(display.CENTER, bgWidth/2, phoneEditTextPosY)
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

	--------------------------------------------------------------------------------

    --[[邮箱找回]]
    --------------------------------------------------------------------------------
    self.m_pEmailTextField = EditText:new({
        forePath = "picdata/public_new/icon_message.png",
        bgPath = "picdata/public_new/input.png",
        minLength= 0,
        maxLength= 28,
        place     = "请输入绑定的邮箱",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 24,
        size = cc.size(410,38),
        inputOffsetY = -2,
        listener = function(event, editbox) 
            if event=="ended" then
                self.m_pPresenter:verifyEmail(editbox:getText()) 
            elseif event=="began" then
                self.m_pEmailHint:setString("")
                self.m_pInputWarn:setVisible(false)
            end
        end,
        })
    self.m_pEmailTextField:align(display.CENTER, bgWidth/2, phoneEditTextPosY)
        :addTo(self)

    self.m_pEmailHint = cc.ui.UILabel.new({
        color = cc.c3b(255, 90, 0),
        text  = "",
        size  = 24,
        font  = "黑体", 
        align = cc.ui.TEXT_ALIGN_LEFT,
        })
    self.m_pEmailHint:align(display.LEFT_CENTER, self.m_pEmailTextField:getPositionX()+265,
        self.m_pEmailTextField:getPositionY())
    self:addChild(self.m_pEmailHint)

    --------------------------------------------------------------------------------
    --[[正在发送]]
    --------------------------------------------------------------------------------
    self.m_pSendingTips = display.newNode()
    self.m_pSendingTips:addTo(self)

    local animPosY = self.m_pUsernameTextField:getPositionY()
    local data = {['pos']=cc.p(bgWidth/2,animPosY),['parent']=self.m_pSendingTips}
    self.m_pLoadingAnim = GafAnimation:loadAndPlayLoadingGAF(data)

    self.m_pTips = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = "正在发送...",
        size  = 26,
        font  = "黑体",
        })
    self.m_pTips:align(display.CENTER, bgWidth/2, animPosY-80)
    self.m_pSendingTips:addChild(self.m_pTips)

--------------------------------------------------------------------------------
    --[[发送成功]]
    --------------------------------------------------------------------------------
    self.m_pSendSuccess = display.newNode()
    self.m_pSendSuccess:addTo(self)

    self.m_pSuccessLabel1 = cc.ui.UILabel.new({
        color = cc.c3b(0, 255, 255),
        text  = "重置成功",
        size  = 36,
        font  = "黑体",
        })
    self.m_pSuccessLabel1:align(display.CENTER, bgWidth/2, animPosY)
    self.m_pSendSuccess:addChild(self.m_pSuccessLabel1)

    self.m_pSuccessLabel2 = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = g_success_hint[1].."\n  "..g_success_hint[2],
        size  = 28,
        font  = "黑体",
        })
    self.m_pSuccessLabel2:align(display.CENTER, bgWidth/2, animPosY-100)
    self.m_pSendSuccess:addChild(self.m_pSuccessLabel2)
    --------------------------------------------------------------------------------

    self:switchLayer(ForgetPassFragment.Layer.STEP_SELECT)
end

function ForgetPassFragment:setResetResult(msg)
    self.m_pSuccessLabel1:setString(msg)
end

function ForgetPassFragment:showUsernameHint(msg)
    self.m_pUsernameHint:setVisible(true)
    self.m_pUsernameHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pInputWarn:setPositionY(self.m_pUsernameTextField:getPositionY())
end

function ForgetPassFragment:showPhoneHint(msg)
    self.m_pPhoneHint:setVisible(true)
    self.m_pPhoneHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pInputWarn:setPositionY(self.m_pPhoneTextField:getPositionY())
end

function ForgetPassFragment:showEmailHint(msg)
    self.m_pEmailHint:setVisible(true)
    self.m_pEmailHint:setString(msg)
    self.m_pInputWarn:setVisible(true)
    self.m_pInputWarn:setPositionY(self.m_pEmailTextField:getPositionY())
end

function ForgetPassFragment:showPhoneSuccessHint(msg)
    self:switchLayer(ForgetPassFragment.Layer.STEP_PHONE_SUCCESS)
    self.m_pSuccessLabel2:setString(msg)
end

function ForgetPassFragment:showEmailSuccessHint(msg)
    self:switchLayer(ForgetPassFragment.Layer.STEP_EMAIL_SUCCESS)
    self.m_pSuccessLabel2:setString(msg)
end

function ForgetPassFragment:back(isExit)
    if isExit or not self.m_nCurrentLayer or self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_SELECT then
    	QManagerListener:Notify({layerID = eLoginViewLayerID,tag = self.params.tag or 1})
    	CMClose(self, true)
        return
    end
    if self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_PHONE_PREPARE or
        self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_EMAIL_PREPARE then
        self:switchLayer(ForgetPassFragment.Layer.STEP_SELECT)
        return
    end
    if self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_PHONE_SEND or
        self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_PHONE_SUCCESS then
        self:switchLayer(ForgetPassFragment.Layer.STEP_PHONE_PREPARE)
        return
    end
    if self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_EMAIL_SEND or
        self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_EMAIL_SUCCESS then
        self:switchLayer(ForgetPassFragment.Layer.STEP_EMAIL_PREPARE)
        return
    end
end

function ForgetPassFragment:findByPhone()
    self:switchLayer(ForgetPassFragment.Layer.STEP_PHONE_PREPARE)
end

function ForgetPassFragment:findByEmail()
    self:switchLayer(ForgetPassFragment.Layer.STEP_EMAIL_PREPARE)
end

function ForgetPassFragment:sendAgain()
    self:back()
end

function ForgetPassFragment:resetPass()
    if self.m_nCurrentLayer==ForgetPassFragment.Layer.STEP_PHONE_SUCCESS or self.m_nCurrentLayer == ForgetPassFragment.Layer.STEP_EMAIL_SUCCESS  then
        self:back(true)
        return
    end
    local data = {}
    data.username = self.m_pUsernameTextField:getText()
    if self.m_nCurrentLayer==ForgetPassFragment.Layer.STEP_PHONE_PREPARE then
        data.nType = 1
        data.phoneNumber = self.m_pPhoneTextField:getText() 
        self.m_pPresenter:resetPassword(data)
        return
    end

    if self.m_nCurrentLayer==ForgetPassFragment.Layer.STEP_EMAIL_PREPARE then
        data.nType = 2
        data.email = self.m_pEmailTextField:getText() 
        self.m_pPresenter:resetPassword(data)
        return
    end
end

function ForgetPassFragment:switchLayer(tag)
    self:hideAllNode()
	if tag == ForgetPassFragment.Layer.STEP_SELECT then
		self.m_pSubTitle:setString(g_subtitle[1])
		self.m_pSelectLayer:setVisible(true)
        self.m_pReTryBtn:setVisible(true)
	elseif tag == ForgetPassFragment.Layer.STEP_PHONE_PREPARE then
        self.m_pSubTitle:setString(g_subtitle[2]) 
        self.m_pUsernameTextField:setVisible(true)
        self.m_pPhoneTextField:setVisible(true)
        self.m_pUsernameTextField:setPositionX(bgWidth/2)
        self.m_pPhoneTextField:setPositionX(bgWidth/2)
        self.m_pResetBtn:setVisible(true)
        self.m_pResetBtn:setButtonEnabled(true)
        self.m_pResetBtn:setButtonImage("normal",{"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("pressed",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("disabled",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pReTryBtn:setVisible(true)
        self.m_pUseEmail:setVisible(true)
	elseif tag == ForgetPassFragment.Layer.STEP_EMAIL_PREPARE then
        self.m_pSubTitle:setString(g_subtitle[3]) 
        self.m_pUsernameTextField:setVisible(true)
        self.m_pEmailTextField:setVisible(true)
        self.m_pUsernameTextField:setPositionX(bgWidth/2)
        self.m_pEmailTextField:setPositionX(bgWidth/2)
        self.m_pResetBtn:setVisible(true)
        self.m_pResetBtn:setButtonEnabled(true)
        self.m_pResetBtn:setButtonImage("normal",{"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("pressed",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("disabled",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pReTryBtn:setVisible(true)
        self.m_pUsePhone:setVisible(true)
    elseif tag == ForgetPassFragment.Layer.STEP_PHONE_SEND then
        self.m_pSubTitle:setString(g_subtitle[2]) 
        self.m_pSendingTips:setVisible(true)
        self.m_pResetBtn:setVisible(true)
        self.m_pResetBtn:setButtonEnabled(false)
        self.m_pResetBtn:setButtonImage("normal",{"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("pressed",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("disabled",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pReTryBtn:setVisible(true)
        self.m_pUsePhone:setVisible(true)
    elseif tag == ForgetPassFragment.Layer.STEP_EMAIL_SEND then
        self.m_pSubTitle:setString(g_subtitle[3]) 
        self.m_pSendingTips:setVisible(true)
        self.m_pResetBtn:setVisible(true)
        self.m_pResetBtn:setButtonEnabled(false)
        self.m_pResetBtn:setButtonImage("normal",{"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("pressed",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pResetBtn:setButtonImage("disabled",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_czmm.png"})
        self.m_pReTryBtn:setVisible(true)
        self.m_pUsePhone:setVisible(true)
    elseif tag == ForgetPassFragment.Layer.STEP_PHONE_SUCCESS then
        self.m_pSendSuccess:setVisible(true)
        
        self.m_pResetBtn:setVisible(true)
        self.m_pResetBtn:setButtonEnabled(true)

        self.m_pResetBtn:setButtonImage("normal",{"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_syxmmdlyx.png"})
        self.m_pResetBtn:setButtonImage("pressed",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_syxmmdlyx.png"})
        self.m_pResetBtn:setButtonImage("disabled",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_syxmmdlyx.png"})

        self.m_pSendAgain:setVisible(true)
    elseif tag == ForgetPassFragment.Layer.STEP_EMAIL_SUCCESS then
        self.m_pSendSuccess:setVisible(true)
	   
        self.m_pResetBtn:setVisible(true)
        self.m_pResetBtn:setButtonEnabled(true)
        self.m_pResetBtn:setButtonImage("normal",{"picdata/public_new/btn_greenlong.png","picdata/loginNew/resetpass/w_syxmmdlyx.png"})
        self.m_pResetBtn:setButtonImage("pressed",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_syxmmdlyx.png"})
        self.m_pResetBtn:setButtonImage("disabled",{"picdata/public_new/btn_greenlong_p.png","picdata/loginNew/resetpass/w_syxmmdlyx.png"})
        self.m_pSendAgain:setVisible(true)
    else
	end
    self.m_nCurrentLayer = tag
end

function ForgetPassFragment:hideAllNode()
    self.m_pSelectLayer:setVisible(false)
    self.m_pReTryBtn:setVisible(false)
    self.m_pUseEmail:setVisible(false)
    self.m_pUsePhone:setVisible(false)
    self.m_pSendAgain:setVisible(false)
    self.m_pUsernameTextField:setVisible(false)
    self.m_pPhoneTextField:setVisible(false)
    self.m_pEmailTextField:setVisible(false)
    self.m_pUsernameTextField:setPositionX(4000)
    self.m_pPhoneTextField:setPositionX(4000)
    self.m_pEmailTextField:setPositionX(4000)
    self.m_pResetBtn:setVisible(false)
    self.m_pSendingTips:setVisible(false)
    self.m_pSendSuccess:setVisible(false)
    self.m_pInputWarn:setVisible(false)
    self.m_pUsernameHint:setVisible(false)
    self.m_pPhoneHint:setVisible(false)
    self.m_pEmailHint:setVisible(false)
end

return ForgetPassFragment