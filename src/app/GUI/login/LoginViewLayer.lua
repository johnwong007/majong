local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")
require("app.EConfig")
require("app.Logic.Config.UserDefaultSetting")

local myInfo = require("app.Model.Login.MyInfo")
require("app.Logic.UserConfig")

require("app.GUI.GameSceneManager")
require("app.Logic.Login.LoginCallbackUI")
require("app.CommonDataDefine.CommonDataDefine")
QManagerPlatform  = require("app.Tools.QManagerPlatform"):getInstance({})
require("app.Tools.EStringTime")
local MusicPlayer = require("app.Tools.MusicPlayer")

--[[
Callbacks:
    "pressDebaoLogin",
    "pressRemember",
    "pressForgetPass",
    "pressRegister",

Members:
    self.m_rootDoc CCSprite
    self.m_rootDoc CCLabelTTF
    self.m_remember CCMenuItemImage
]]
local LoginViewLayer = Oop.class("LoginViewLayer", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI.login", "ccb")
    return CCBLoader:load("LoginViewLayer", owner)
end)

function LoginViewLayer:initLogin()
    myInfo.data.Global_Token = tencentValue.tencent_token
    myInfo.data.Global_Secret = tencentValue.tencent_secret
    myInfo.data.Global_Openkey = tencentValue.tencent_openkey
    myInfo.data.Global_Token = g_ServerIP
    myInfo.data.Global_ProxyPort = g_ServerPort
end

function LoginViewLayer:buttonClick(event,sender)
    -- @TODO: all sprite click func
    local tag = sender:getTag()
   MusicPlayer:getInstance():playButtonSound()
    if tag == 515 then
        --todo m_debaoLogin Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        
        self:toDebaoLogin()
        return state
    end
    if tag == 516 then
        --todo m_touristLogin Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:toTouristLogin()
        return state
    end
    if tag == 517 then
        --todo m_500Login Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:to500Login()
        return state
    end
    if tag == 518 then
        --todo m_qqLogin Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:toQQLogin()
        return state
    end
    if tag == 510 then
        --todo loginButton Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:pressDebaoLogin()
        return state
    end
    if tag == 511 then
        --todo rememberButton Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:pressRemember()
        return state
    end
    if tag == 512 then
        --todo forgetPassButton Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:pressForgetPass()
        return state
    end
    if tag == 513 then
        --todo registerButton Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:pressRegister()
        return state
    end
    if tag == 514 then
        --todo back Sprite Click
        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})
        self:toBack()
        return state
    end
end

function LoginViewLayer:ctor()
    self:registerScriptHandler(handler(self, self.onNodeEvent))
    -- local CMMaskLayer = CMMask.new()
    -- self:addChild(CMMaskLayer)

    self:initLogin()
        local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/MainPage_dif/mainpageBG.png")
    self.m_loginBg:setTexture(tmpFilename)

    self.m_login = require("app.Logic.Login.DebaoPlatformLogin"):new()
    self.m_login:setLogicCallback(self)
    self.m_login:addTo(self)

    local loginDialog = self.loginDialog
    local loginSelectDialog = self.loginSelectDialog
    loginSelectDialog:setVisible(true)
    loginDialog:setVisible(false)

    self:addChannelButton()

    local usernameHint = self.usernameHint
    local passwordHint = self.passwordHint
    usernameHint:setVisible(false)
    passwordHint:setVisible(false)

    self.usernameTextField = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 16,
        minLength = 4,
        place     = "请输入您的用户名",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 22,
        size = cc.size(280,30),
        bgPath    = "transBG.png"
    })
    self.usernameTextField:setPosition(usernameHint:getPositionX()+135,usernameHint:getPositionY())
    self.usernameTextField:setAnchorPoint(cc.p(0,0.5))
    usernameHint:getParent():addChild(self.usernameTextField)

    self.passwordTextField = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 15,
        minLength = 6,
        place     = "请输入您的密码",
        color     = cc.c3b(0, 0, 0),
        fontSize  = 22,
        size = cc.size(280,30),
        bgPath    = "transBG.png",
        inputFlag = 0
    })
    self.passwordTextField:setPosition(passwordHint:getPositionX()+135,passwordHint:getPositionY())
    self.passwordTextField:setAnchorPoint(cc.p(0,0.5))
    passwordHint:getParent():addChild(self.passwordTextField)


    local lastLoginName = UserDefaultSetting:getInstance():getDebaoLoginName()
    local lastPassword =  UserDefaultSetting:getInstance():getDebaoLoginPassword()

    self.usernameTextField:setText(lastLoginName)
    self.passwordTextField:setText(lastPassword)
    self.usernameTextField:setPositionY(2000)
    self.passwordTextField:setPositionY(2000)
    local rememberFlag = UserDefaultSetting:getInstance():getAutoLoginEnable()
    if rememberFlag then
        local rememberButton = self.rememberButton
        rememberButton:setTexture("checkboxOn.png")
        self.flag = true
    end

    self.m_currentVersion = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = DBVersion,
        size  = 26,
        font  = "font/FZZCHJW--GB1-0.TTF",
        --align = cc.TEXT_ALIGNMENT_RIGHT
        })
    self.m_currentVersion:setPosition(self.m_loginBg:getContentSize().width-self.m_currentVersion:getContentSize().width -20,30)
    self:addChild(self.m_currentVersion)
    self.m_loadingView = require("app.GUI.LoadingSceneLayer"):new()
    self:showLoadingViewCallback(true)
    self:showLoadingViewCallback(false)

    local moveValue = 200
    local value = 534
    local tmp = value/moveValue
    tmp = math.floor(tmp)
    if value%200>=100 then
        tmp = tmp+1
    end
    
        
--Add touch Event -m_debaoLogin
    self.m_debaoLogin:setTouchEnabled(true)
    self.m_debaoLogin:setLocalZOrder(1)
    self.m_debaoLogin:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.m_debaoLogin)end)
    
--Add touch Event -m_touristLogin
    self.m_touristLogin:setTouchEnabled(true)
    self.m_touristLogin:setLocalZOrder(1)
    self.m_touristLogin:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.m_touristLogin)end)
    
--Add touch Event -m_500Login
    self.m_500Login:setTouchEnabled(true)
    self.m_500Login:setLocalZOrder(1)
    self.m_500Login:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.m_500Login)end)
    
--Add touch Event -m_qqLogin
    self.m_qqLogin:setTouchEnabled(true)
    self.m_qqLogin:setLocalZOrder(1)
    self.m_qqLogin:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.m_qqLogin)end)
    
--Add touch Event -loginButton
    self.loginButton:setTouchEnabled(true)
    self.loginButton:setLocalZOrder(1)
    self.loginButton:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.loginButton)end)
    
--Add touch Event -rememberButton
    self.rememberButton:setTouchEnabled(true)
    self.rememberButton:setLocalZOrder(1)
    self.rememberButton:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.rememberButton)end)
    
--Add touch Event -forgetPassButton
    self.forgetPassButton:setTouchEnabled(true)
    self.forgetPassButton:setLocalZOrder(1)
    self.forgetPassButton:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.forgetPassButton)end)
    
--Add touch Event -registerButton
    self.registerButton:setTouchEnabled(true)
    self.registerButton:setLocalZOrder(1)
    self.registerButton:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.registerButton)end)
    
--Add touch Event -back
    self.back:setTouchEnabled(true)
    self.back:setLocalZOrder(1)
    self.back:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.back)end)
    self.m_login:imLogin()

    -- CMOpen(require("app.GUI.matchWait.MatchWaitInfo"), self, nil, true, 1)
    -- CMOpen(require("app.GUI.dialogs.CountDownTimeLabel"), self, {timestamp=600,color=cc.c3b(255,102,0),separator="   ", length=3,position = cc.p(display.cx,display.cy)}, true, 1)
end

function LoginViewLayer:addChannelButton()
    local sAllChannel = {    
    ["10116"] = {btnPath = "login_btn_qq.png",btnPath2 = "login_btn_qq2.png",loginType = eDebaoPlatformQQLogin,
            -- callBack = function(event) 
                -- QManagerPlatform:openQQLogin(function(jObj) 
                -- if jObj.loginResult == "onComplete" then
                --     self.m_login:debaoPlatformLoginRequest(jObj.openid, jObj.access_token, eDebaoPlatformQQLogin, true, true)
                -- else
                --     local AlertDialog = require("app.Component.CMAlertDialog").new({text = "QQ登录失败,请确认是否授权成功并检查网络"})
                --     CMOpen(AlertDialog,self)
                -- end
                callBack = handler(self,self.openQQLogin),
            -- end)
        -- end
        },
     ["10848"] = {btnPath = "login_btn_baidu.png",btnPath2 = "login_btn_baidu2.png",loginType = eDebaoPlatformBaiduLogin, callBack = function(event) 
                QManagerPlatform:callBaiduLogin(function(jObj) 
                if jObj ~= "" then
                    self.m_login:debaoPlatformLoginRequest(jObj, "", eDebaoPlatformBaiduLogin, true, true)
                end
            end)
        end},
     ["10839"] = {btnPath = "login_btn_mz.png",btnPath2 = "login_btn_mz2.png",loginType = eDebaoPlatformMeizuLogin, callBack = function(event) 
                QManagerPlatform:callMeizuLogin(function(jObj) 
                if jObj ~= "" then
                    self.m_login:debaoPlatformLoginRequest(jObj, "", eDebaoPlatformMeizuLogin, true, true)
                end
            end)
        end},
     ["10849"] = {btnPath = "login_btn_mz.png",btnPath2 = "login_btn_mz2.png",loginType = eDebaoPlatformJinLiLogin,},
     ["10850"] = {btnPath = "login_btn_xm.png",btnPath2 = "login_btn_xm2.png",loginType = eDebaoPlatformXiaoMiLogin,},
     ["10858"] = {btnPath = "login_btn_pyw.png",btnPath2 = "login_btn_pyw2.png",loginType = eDebaoPlatformPengYouWanLogin,}, --魅族
     ["10860"] = {btnPath = "login_btn_nd.png",btnPath2 = "login_btn_nd2.png",loginType = eDebaoPlatformNduoLogin,},     --N多
     ["10861"] = {btnPath = "login_btn_uucun.png",btnPath2 = "login_btn_uucun2.png",loginType = eDebaoPlatformUUCunLogin,},     --UU村
     ["10862"] = {btnPath = "login_btn_mmy.png",btnPath2 = "login_btn_mmy2.png",loginType = eDebaoPlatformMuMaYiLogin,},     --木蚂蚁
     ["10863"] = {btnPath = "login_btn_ttyx.png",btnPath2 = "login_btn_ttyx2.png",loginType = eDebaoPlatformLiTianLogin,},     --力天
    }
    for i,v in pairs(sAllChannel) do 
        if i == DBChannel then
            self.normalLogin:setVisible(false)
            self.otherLogin:setVisible(false)
            myInfo.data.loginType = v.loginType
            myInfo.data.platform  = GAllChannel[v.loginType]
             --账户切换自动登录
            local isSwitch,args = QManagerPlatform:getIsSwitchAccount()
            if isSwitch then
                QManagerPlatform:setIsSwitchAccount(nil,nil)
                self.m_login:debaoPlatformLoginRequest(args, "", v.loginType, true, true)
            end
            local btnLogin = cc.ui.UIPushButton.new({normal="picdata/login/"..v.btnPath, pressed="picdata/login/"..v.btnPath2, selected="picdata/login/"..v.btnPath2})
            :align(display.CENTER, CONFIG_SCREEN_WIDTH/2, display.cy)
            :addTo(self)
            local callBack = function(event) 
                QManagerPlatform:callLogin(function (args)
                    print("SDKCALLBACK=="..args)
                    if args ~= "" then
                        self.m_login:debaoPlatformLoginRequest(args, "", v.loginType, true, true)
                    end
                end)
            end
            if DBChannel == "10116" or DBChannel == "10848" or DBChannel == "10839" then
                callBack = v.callBack
            end
            btnLogin:onButtonClicked(
                function(event)
                    -- MusicPlayer:getInstance():playButtonSound()
                    callBack(event)
                end)  
        end
    end

end
function LoginViewLayer:onNodeEvent(event)
    if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    end
end

function LoginViewLayer:onEnter()
    --dump("LoginViewLayer:onEnter()")
    TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
    QManagerListener:Attach({{layerID = eLoginViewLayerID,layer = self}})
end

function LoginViewLayer:onExit()
    --dump("LoginViewLayer:onExit")
    QManagerListener:Detach(eMainPageViewID)
   
end
function LoginViewLayer:updateCallBack(data)
    -- dump("LoginViewLayer:updateCallBack")
    data = data or {}
    if data.tag == 1 then               --返回
        self:setShowSelf(true)
    elseif data.tag == 2 then
        self:toDebaoLogin()
    elseif data.tag == 3 then           --短信验证成功
        self:pressDebaoLogin()
    elseif data.tag == 4 then           --注册成功
        local lastLoginName = UserDefaultSetting:getInstance():getDebaoLoginName()
        local lastPassword =  UserDefaultSetting:getInstance():getDebaoLoginPassword()
        self.usernameTextField:setText(lastLoginName)
        self.passwordTextField:setText(lastPassword)
    elseif data.tag == 5 then
        self.mIsDeZhouLogin = true
        self:setShowSelf(true)
        self:pressDebaoLogin()
    end
end 

function LoginViewLayer:toDebaoLogin(sender, event)
    -- @TODO: implement this
    -- print("sender.type ======= ", sender)
    -- print("LoginViewLayer:pressDebaoLogin")
    local loginDialog = self.loginDialog
    local loginSelectDialog = self.loginSelectDialog
    loginSelectDialog:setVisible(false)
    loginDialog:setVisible(true)
    self:setShowSelf(true)
    self.usernameTextField:setPositionY(self.usernameHint:getPositionY())
    self.passwordTextField:setPositionY(self.passwordHint:getPositionY())
end

function LoginViewLayer:toTouristLogin(sender, event)
    -- @TODO: implement this
    if QManagerPlatform:getUniqueStr() == "" or QManagerPlatform:getUniqueStr() == nil then
        local alertView = require("app.Component.EAlertView"):alertView(self, self,
        "", "您的设备暂时不支持游客一键登录,请使用德堡账号登录游戏", "取消", "确定")
    -- alertView:setTag(100) --[[锦标赛]]
    -- alertView:setUserData(tableId)
    alertView:alertShow()
    return
    end
    self.m_login:debaoPlatformLoginRequest(QManagerPlatform:getUniqueStr(), "", eDebaoPlatformTouristLogin, true, true)
end


-- 通用sdk登录回调,直接作为全局函数提供给luaj调用
function LoginViewLayer:AndroidLogin(args)

    if DBChannel == "10848" then
        -- dump(args)
        self.m_login:debaoPlatformLoginRequest(args, "", eDebaoPlatformBaiduLogin, true, true)
    end
end

function LoginViewLayer:to500Login(sender, event)
    -- @TODO: implement this
     self:setShowSelf(false)
     local RewardLayer = require("app.GUI.login.Login500wan")
     CMOpen(RewardLayer, self,{m_login = self.m_login,loginSelectDialog = self.loginSelectDialog,isNotAdd = true})
end

function LoginViewLayer:toQQLogin(sender, event)
    -- @TODO: implement this
    self:openQQLogin()
end

function LoginViewLayer:openQQLogin()
        QManagerPlatform:openQQLogin(function(jObj) 
            local isTrue = false
             if device.platform == "ios" then
                if jObj.loginResult ~= "0" and  jObj.loginResult ~= "" then
                    isTrue = true
                end
             elseif  device.platform == "android" then
                if jObj.loginResult == "onComplete" then
                    isTrue = true
                end
             end
        if isTrue  then
            UserConfig.openid=jObj.openid;
            UserConfig.access_token=jObj.access_token;
            UserConfig.pf=jObj.pf;
            UserConfig.pfkey=jObj.pfkey;
            UserConfig.pay_token=jObj.pay_token;
            UserConfig.zoneid=jObj.zoneId;
            UserConfig.format=jObj.format;
            UserConfig.appid=jObj.appid;
            self.m_login:debaoPlatformLoginRequest(jObj.openid, jObj.access_token, eDebaoPlatformQQLogin, true, true)
        else
            local AlertDialog = require("app.Component.CMAlertDialog").new({text = "QQ登录失败,请确认是否授权成功并检查网络"})
            CMOpen(AlertDialog,self)
        end
        end)
end

function LoginViewLayer:pressDebaoLogin(sender, event)
    -- @TODO: implement this
    -- local username = self.usernameTextField:getString()
    -- local password = self.passwordTextField:getString()    
    local username = self.usernameTextField:getText()
    local password = self.passwordTextField:getText()
    if not username or username=="" or
        not password or password=="" then
        local text = "帐号或密码不能为空"
        local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = true})
        CMOpen(CMToolTipView,self)
        return
    end
    if self.mIsDeZhouLogin or not self:checkeIsDouDiZhuAccount() then
        self:DebaoLoginActionCallBack(username, password, false, self.flag)
    end
    -- self:setShowSelf(false)
end

function LoginViewLayer:pressRemember(sender, event)
  
    local rememberButton = self.rememberButton
    if self.flag then
        rememberButton:setTexture("checkboxOff.png")
        self.flag = false
        return
    else
        rememberButton:setTexture("checkboxOn.png")
        self.flag = true
    end

    UserDefaultSetting:getInstance():setAutoLoginEnable(self.flag)
end

function LoginViewLayer:pressForgetPass(sender, event)
    -- @TODO: implement this
    self:setShowSelf(false)
    local RewardLayer = require("app.GUI.login.ForgetPasswordLayer")
    CMOpen(RewardLayer,self,{nType = 1})
end
function LoginViewLayer:setShowSelf( visible )
    -- body
    self.loginSelectDialog:setVisible( false )
    self.loginDialog:setVisible(visible)
    self.usernameTextField:setVisible(visible)
    self.passwordTextField:setVisible(visible)
end
function LoginViewLayer:pressRegister(sender, event)
    -- @TODO: implement this
     self:setShowSelf(false)
     
     local RewardLayer = require("app.GUI.login.DebaoRegister")
     CMOpen(RewardLayer,self,{nType = 1})
end

function LoginViewLayer:toBack(sender, event)
    -- @TODO: implement this
    local loginDialog = self.loginDialog
    local loginSelectDialog = self.loginSelectDialog
    loginSelectDialog:setVisible(true)
    loginDialog:setVisible(false)
    self.usernameTextField:setPositionY(2000)
    self.passwordTextField:setPositionY(2000)
end


function LoginViewLayer:DebaoLoginActionCallBack(name, password, bRemeberPassword, bAutoLogin)
    local loginDialog = self.loginDialog
    local loginSelectDialog = self.loginSelectDialog
    -- loginSelectDialog:setVisible(true)
    -- loginDialog:setVisible(false)
    --点击次数上报
    -- m_login->reportBtnClick(REPORT_BTN_CLICK_3)

    -- self:addChild(m_loadingView,MAX_ZORDER)
    self.m_registerName = name
    self.m_registerPw = password
    myInfo.data.loginType = eDebaoPlatformMainLogin
    self.m_login:debaoPlatformLoginRequest(name, password, eDebaoPlatformMainLogin, bRemeberPassword, bAutoLogin)
end

function LoginViewLayer:showLoadingViewCallback(bEable)
    --是否正在显示闪屏
    -- if m_bSplashShowing then
    --     return
    -- end
    
    if bEable then
        if self.m_loadingView and not self.m_loadingView:getParent() then
            self.m_loadingView:addTo(self, MAX_ZORDER)
        end
    else
        if self.m_loadingView and self.m_loadingView:getParent() then
            self:removeChild(self.m_loadingView, false)
        end
    end

end

-- TODO delete, 貌似已弃用
function LoginViewLayer:enterMainPage()
    -- local scene = display.newScene()
    -- self.m_layer = require("app.GUI.mainPage.MainPageView"):new() 
    -- scene:addChild(self.m_layer)
    -- GameSceneManager:switchScene(scene)
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
end

function LoginViewLayer:loginSuccessedCallback()
    -- local scene = display.newScene()
    -- local m_layer = require("app.GUI.mainPage.MainPageView"):new() 
    -- scene:addChild(m_layer)
    -- GameSceneManager:switchScene(scene)
    -- m_layer:setFromType("login")
    -- local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView,{nType = "login"})
    --local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TestScene)

    if NEED_SPECIAL then
        CMDelay(GameSceneManager:getCurScene(), 1, function () GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView,{nType = "login"}) end)
    else 
        local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView,{nType = "login"})
    end
end

function LoginViewLayer:alertEnterTourneyRoomCallback(matchName, tableId)
    local alertView = require("app.Component.EAlertView"):alertView(self, self,
        "", "您报名的"..matchName.."已经开始，是否立即前往？", "弃权", "立即前往")
    alertView:setTag(100) --[[锦标赛]]
    alertView:setUserData(tableId)
    alertView:alertShow()
end

function LoginViewLayer:clickButtonAtIndex(alertView, index)
    local tag = alertView:getTag()
    
    if tag == 100 then --锦标赛
        local strId = alertView:getUserData()
        if index == 0 then
            self.m_login:foldMatch(strId)
            self:loginProgressCallback("")--登录成功正在进入主界面
            self:loginSuccessedCallback()
        else
            self:loginProgressCallback("")--正在进入房间
            self:reconnectSuccessedCallback(trId,myInfo.data.userId)
        end
        strId = nil
    elseif tag == 101 then --登录错误
        if index ~= 0 then
            self:relogin()
        else --quit
            cc.Director:getInstance():stopAnimation()
            cc.Director:getInstance():purgeCachedData()
            cc.Director:getInstance():endToLua()
            if device.platform == "ios" then
                os.exit()
            end
        end
    elseif tag == 102 then --登录token错误
        cc.Director:getInstance():stopAnimation()
        cc.Director:getInstance():purgeCachedData()
        cc.Director:getInstance():endToLua()
        if device.platform == "ios" then
            os.exit()
        end
    elseif tag == 103 then --检查版本更新
        if index==1 then--更新
            if self.m_login then
                self.m_login:upgrade()
            end    
        end     
    elseif tag == 104 then
        -- if BRANCHES_VERSION == ALIPAYOPEN or BRANCHES_VERSION == WIRELESS_91 or BRANCHES_VERSION == PPSPLATFORM then
        --     cc.Director:getInstance():stopAnimation()
        --     cc.Director:getInstance():purgeCachedData()
        --     cc.Director:getInstance():endToLua()
        -- else
        --     self:removeSplashView()
        --     if self.m_loadingView and self.m_loadingView:getParent() then
        --         self:removeChild(self.m_loadingView,true)
        --     end
        --     if myInfo.data.loginType == eDebaoPlatformMainLogin then
        --         self:openDebaoLoginViewWithError()
        --     elseif myInfo.data.loginType == eDebaoPlatform500wan then
        --         self:open500wanLoginViewWithError()
        --     end
        -- end
    elseif tag == 105 then
        if index == 1 then
            UserDefaultSetting:getInstance():setLastLoginTimeStamp(myInfo.data.userId,myInfo.data.serverTime)
            cc.Director:getInstance():stopAnimation()
            cc.Director:getInstance():purgeCachedData()
            cc.Director:getInstance():endToLua()
                
                
            if device.platform == "ios" then
                os.exit()
            elseif device.platform == "android" then
                
            end
        end
    elseif tag == 106 then
        require("app.Component.CMHandleDirectory")
        CMRemoveDirectory(device.writablePath.."update/")
        QManagerPlatform:jumpToUpdate(myInfo.data.downloadUrl)
    elseif tag == 107 then
        if index == 1 then
            local login = self:getChildByTag(kDebaoLoginMainTag)
            if login then
                self:removeChild(login, true)
            end
            myInfo.data.loginType = eDebaoPlatformMainLogin
            local dialog = require("app.GUI.login.DebaoRegister"):dialog(self)
            dialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
            self:addChild(dialog, 10, KDebaoRegisterTag)
            dialog:show()
        end
    elseif tag == 108 then
        --重新弹出注册框
        if self.m_loadingView then
            self:removeChild(self.m_loadingView, false)
        end
            
        local login = self:getChildByTag(kDebaoLoginMainTag)
        if login then
                self:removeChild(login, true)
        end    
        myInfo.data.loginType = eDebaoPlatformMainLogin
            local dialog = require("app.GUI.login.DebaoRegister"):dialog(self)
        rDialog:setPosition(cc.p(LAYOUT_OFFSET.x, 0))
        self:addChild(rDialog, 10, KDebaoRegisterTag)
        rDialog:show()
    end
    
    alertView = nil
end

function LoginViewLayer:loginProgressCallback(msg)
    normal_info_log("LoginViewLayer:loginProgressCallback: "..msg)
    self:setShowSelf(false)
    self.loginSelectDialog:setVisible(true)
end

function LoginViewLayer:reconnectSuccessedCallback(tableId, userId, isRush) --reconnect room
    dump("reconnectSuccessedCallback")
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = tableId,m_isGameType = nil,m_isFromMainPage = true,isRush = isRush})
end

function LoginViewLayer:loginFailedCallback(errorCode, errorMsg)
    if self.m_loadingView and self.m_loadingView:getParent() then
        self:removeChild(self.m_loadingView,true)
    end
    dump(myInfo.data.phpSessionId, "============> ")
    if errorCode  == NEED_VERIFY_ERROR then
         self:setShowSelf(false)
         local RewardLayer = require("app.GUI.login.MobileVerify").new({name = self.usernameTextField:getText()})
         CMOpen(RewardLayer, self)
        return
    end
    
    
    if errorCode == NEED_TO_UPDATE then
        self.m_networkAlertView = require("app.Component.EAlertView"):
        alertView(self,self,Lang_Login_NeedUpdate_Prompt, errorMsg, Lang_Button_Confirm)
                                                
        self.m_networkAlertView:setTag(106)--跳出游戏下载更新包
        self.m_networkAlertView:alertShow()
        return
    end
    if errorCode == REGISTER_ERROR then
        self.m_networkAlertView = require("app.Component.EAlertView"):
        alertView(self,self,Lang_Title_Prompt, errorMsg, Lang_Button_Confirm)
        self.m_networkAlertView:setTag(108)--注册失败
        self.m_networkAlertView:alertShow()
        return
    end

    if TRUNK_VERSION==DEBAO_TRUNK then
        local message = ""
        local tipStr = ""
        if (errorCode == LOGIN_QQ_ONERROR) then
            message = errorMsg
        else
            tipStr = errorMsg
            message = tipStr
        end
        self.m_networkAlertView = require("app.Component.EAlertView"):
            alertView(self, self, Lang_Login_Error_Prompt, errorMsg, Lang_Button_Confirm)
        self.m_networkAlertView:setTag(104)--登录错误
        self.m_networkAlertView:alertShow()
        return
    else
        self.m_networkAlertView = require("app.Component.EAlertView"):
            alertView(self, self, Lang_Login_Error_Prompt, errorMsg, Lang_Button_Quit, Lang_Button_Relogin)
        self.m_networkAlertView:setTag(101)--登录错误
        self.m_networkAlertView:alertShow()
        return
    end

        self.m_networkAlertView = require("app.Component.EAlertView"):
        alertView(self,self,Lang_Login_Error_Prompt, errorMsg, Lang_Button_Confirm)
                                                
        self.m_networkAlertView:alertShow()
end
--[[
    首次登录用户名输入框
]]
function LoginViewLayer:showUniqueUserDialog()
    local RewardLayer = require("app.GUI.login.DebaoUniqueUser").new({m_login = self.m_login,loginSelectDialog = self.loginSelectDialog})
    RewardLayer:create()
    self:addChild(RewardLayer)
    --CMOpen(RewardLayer, self,{m_login = self.m_login,loginSelectDialog = self.loginSelectDialog})
end

function LoginViewLayer:upgradeSuccessShowLoginCallback(loginType)
end
--[[
    检测是否为渠道审核账户
]]
function LoginViewLayer:checkeIsDouDiZhuAccount()
    local isFind = false
    local DouDiZhuAccount = require("app.GUI.login.DouDiZhuAccount")
    local name = self.usernameTextField:getText()
    local password = self.passwordTextField:getText()
    for i,v in pairs(DouDiZhuAccount) do 
        if v.name == name and v.password == password then
            isFind = true 
            break
        end
    end
    if isFind then 
        self:setShowSelf(false)
        local RewardLayer      = require("app.GUI.login.ChoiceGameLayer")
        CMOpen(RewardLayer, self,{isNotAdd = true},0)
    end

    return isFind
end
return LoginViewLayer