local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")

--[[
Callbacks:
    "pressClose",
    "pressConfirm",

Members:
    self.hint CCLabelTTF
    self.confirmLabel CCLabelTTF
    self.hintLabel CCLabelTTF
]]
local AlertView = Oop.class("AlertView", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.Component", "ccb")
    return CCBLoader:load("AlertView", owner)
end)

function AlertView:ctor()
    -- @TODO: constructor
    self.m_line:setScaleX(656/self.m_line:getContentSize().width)
    self.m_callback = nil
    -- self.m_line:setVisible(false)
end

function AlertView:setDialogBaseCallBack(callback)
    self.m_pCallbackUI = callback
end

function AlertView:pressClose(sender, event)
    self.m_pCallbackUI:hide()
    if self.m_callback ~= nil then
        self.m_callback()
    end
end

function AlertView:pressConfirm(sender, event)
    self.m_pCallbackUI:hide()
end

return AlertView