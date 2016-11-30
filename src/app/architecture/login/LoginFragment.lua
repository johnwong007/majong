local LoginContract = require("app.architecture.login.LoginContract")
require("app.Component.CMCommon")
local CMButton = require("app.Component.CMButton")
local CMInput = require("app.Component.CMInput")
local CMRadioButton = require("app.Component.CMRadioButton")
local CMTextButton = require("app.Component.CMTextButton")
local MusicPlayer = require("app.Tools.MusicPlayer")

local bgWidth = 0
local bgHeight = 0
local LoginFragment = class("LoginFragment", function()
		return LoginContract.View:new()
	end)

function LoginFragment:ctor()
    self:setNodeEventEnabled(true)
end

function LoginFragment:onExit()
    self.m_pPresenter:onExit()
end

function LoginFragment:onEnterTransitionFinish()
end


function LoginFragment:create()
	self:initUI()
end

function LoginFragment:initUI()
    self.m_pBg = cc.ui.UIImage.new("picdata/background/bg.jpg")
    self.m_pBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self)

    bgWidth = self.m_pBg:getContentSize().width
    bgHeight = self.m_pBg:getContentSize().height

    cc.ui.UILabel.new({
        color = cc.c3b(170, 159, 224),
        text  = "游戏健康忠告:抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。",
        size  = 15,
        font  = "Arial",
        align = cc.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER, CONFIG_SCREEN_WIDTH/2, 30)
        :addTo(self,1,1)

    local btnLogin = CMButton.new({normal = {"picdata/login/btn_weixin.png"},
        pressed = {"picdata/login/btn_weixin.png"}},
        function () self:login() end, nil, {changeAlpha = true})
    btnLogin:setPosition(bgWidth/2, bgHeight/2+60)
    self.m_pBg:addChild(btnLogin,1)

    self.m_pTouristLogin = CMButton.new({normal = {"picdata/login/btn_traveler.png"},
        pressed = {"picdata/login/btn_traveler.png"}},
        function () self:touristLogin() end, nil, {changeAlpha = false})
    self.m_pTouristLogin:setPosition(bgWidth/2, bgHeight/2-60)
    self.m_pBg:addChild(self.m_pTouristLogin,1)

    -- self.m_pTouristLogin = CMTextButton:new({
    --     textColorN = cc.c3b(0, 255, 255),
    --     text  = "游客登陆->",
    --     callback  = handler(self, self.touristLogin)
    -- })
    -- self.m_pTouristLogin:align(display.CENTER, bgWidth/2,120)
    -- self.m_pBg:addChild(self.m_pTouristLogin)    

    self.m_pAgreeProtocol = CMRadioButton:new({
        hint = "同意用户协议",
        hintColorOff = cc.c3b(0,255,255),
        hintColorOn = cc.c3b(125,0,0),
        -- on="picdata/public/btn_radio_s2.png",
        -- off="picdata/public/btn_radio2.png"
        off="picdata/public/btn_radio_s2.png",
        on="picdata/public/btn_radio2.png"
        })
    self.m_pAgreeProtocol:align(display.CENTER, bgWidth/2-120, 80)
    self.m_pAgreeProtocol:addTo(self.m_pBg)
    self.m_pAgreeProtocol.m_pImageButton:setButtonEnabled(false)
end

function LoginFragment:touristLogin()
    self.m_pPresenter:majongLoginRequest({loginType == eDebaoPlatformMainLogin})
end

function LoginFragment:login()
    self.m_pPresenter:majongLoginRequest({loginType == eDebaoPlatformTouristLogin})
end

function LoginFragment:loginTimeOut()
    CMClose(self.m_pLoadingLayer, false)
    self.m_pLoadingLayer = nil
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.HallView)
end

---
-- [function description]
--  self:showLoadingWithTips({tips = "tips", tipsBg = "picdata/public/slice01_01.png", viewRect=cc.size(360,240), scale9=true})
-- @param params like{tips = "tips", tipsBg = "picdata/public/slice01_01.png", viewRect=cc.size(360,240), scale9=true}
-- @return [description]
--
function LoginFragment:showLoadingWithTips(params)
    if self.m_pLoadingLayer == nil then
        self.m_pLoadingLayer = require("app.architecture.loading.LoadingFragment"):new(params)
        CMOpen(self.m_pLoadingLayer, self, nil, true)
    else
        if self.params.tips then
            self.m_pLoadingLayer:setTips(self.params.tips)
        end
    end
end

return LoginFragment