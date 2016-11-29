local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")
local CommonFragment = class("CommonFragment", function()
        return BaseView:new()
    end)

function CommonFragment:ctor(params)
    local bg = cc.ui.UIImage.new("picdata/public_new/bg.png", {scale9 = true})
    bg:setLayoutSize(bgWidth, bgHeight)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
        :addTo(self)

    local backBtn = CMButton.new({normal = "picdata/public_new/btn_back2.png",
        pressed = "picdata/public_new/btn_back2.png"},function () self:back() end)
    backBtn:setPosition(45, bgHeight-40)
    bg:addChild(backBtn)
end

function CommonFragment:back()
    CMClose(self, true)
end

return CommonFragment