local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")
local UIInput = require("framework.cc.ui.UIInput")
local ui = require("framework.ui")

--[[
Callbacks:
    "pressClose",
    "pressEnter",

Members:
    self.hint CCLabelTTF
    self.wrong_password CCLabelTTF
]]
local EnterPassword = Oop.class("EnterPassword", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI.hallview", "ccb")
    return CCBLoader:load("EnterPassword", owner)
end)

function EnterPassword:ctor()
    -- @TODO: constructor
    -- local CMMaskLayer = CMMask.new()
    -- self:addChild(CMMaskLayer)
    local passwordHint = self.passwordHint

    self.passwordTextField = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 8,
        -- minLength = 6,
        place     = "请输入您的密码",
        color     = cc.c3b(234, 234, 2),
        fontSize  = 24,
        size = cc.size(336,32),
        -- bgPath    = "picdata/privateHall/private_input.png",
        -- inputFlag = 0
    })
    self.passwordTextField:setPosition(passwordHint:getPositionX()+160, passwordHint:getPositionY())
    passwordHint:getParent():addChild(self.passwordTextField)

    self.wrong_password:setVisible(false)
    self.error_icon:setVisible(false)
    self.hint:setString("请输入房间密码")

    self.enterMenu:setTouchEnabled(false)
    self.enterMenu:setVisible(false)
    self.confirmButton1 = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", 
        pressed="picdata/public/btn_green2.png", 
        disabled="picdata/public/btn_green2.png"})
    self.confirmButton1:align(display.CENTER, self.enterMenu:getPositionX(), self.enterMenu:getPositionY())
        :addTo(self.enterMenu:getParent(), 1)
        :onButtonClicked(function(event)
            self:pressEnter()
            end)
        :setTouchSwallowEnabled(true)

    local label1 = cc.ui.UILabel.new({
        text = "确定",
        font = "黑体",
        size = 26,
        color = cc.c3b(215,255,178)
        })
    label1:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
    self.confirmButton1:setButtonLabel("normal", label1)
end

function EnterPassword:setDialogBaseCallBack(callback)
    self.m_pCallbackUI = callback
end

function EnterPassword:pressClose(sender, event)
    self:getParent():remove()
end

function EnterPassword:pressEnter(sender, event)
    self.m_pCallbackUI({passsword = self.passwordTextField:getText()})    
    self:getParent():remove() 
end

return EnterPassword