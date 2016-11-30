local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")
local CommonFragment = class("CommonFragment", function()
        -- return BaseView:new()
        return display.newLayer()
    end)

function CommonFragment:create()
    self:initUI()
end

function CommonFragment:ctor(params)
    self.params = params or {}
end

function CommonFragment:initUI()
    local bg = cc.ui.UIImage.new("picdata/public/popup/img_bg.png", {scale9 = false})
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
        :addTo(self)
    -- self.params.viewType = 1
    if self.params.viewType then
        bgWidth = CONFIG_SCREEN_WIDTH*0.75
        bgHeight = CONFIG_SCREEN_HEIGHT*0.8
    else
        bgWidth = CONFIG_SCREEN_WIDTH
        bgHeight = CONFIG_SCREEN_HEIGHT
    end
    self.bgWidth = bgWidth
    self.bgHeight = bgHeight
    bg:setScaleX(bgWidth/bg:getContentSize().width)
    bg:setScaleY(bgHeight/bg:getContentSize().height)

    if self.params.viewType then
        local backBtn = CMButton.new({normal = {"picdata/public/btn_close.png"},
            pressed = {"picdata/public/btn_close.png"}},function () self:back() end, nil, {changeAlpha = true})
        backBtn:setPosition(CONFIG_SCREEN_WIDTH/2+bgWidth/2-20, CONFIG_SCREEN_HEIGHT/2+bgHeight/2-60)
        self:addChild(backBtn)
    else
        local backBtn = CMButton.new({normal = {"picdata/public/popup/btn_back.png"},
            pressed = {"picdata/public/popup/btn_back.png"}},function () self:back() end, nil, {changeAlpha = true})
        backBtn:setPosition(45, bgHeight-40)
        self:addChild(backBtn)
    end

    self.title = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 236),
        text  = self.params.title or "温馨提示",
        size  = 32,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_CENTER
        })
    if self.params.viewType then
        self.title:align(display.CENTER, 
            CONFIG_SCREEN_WIDTH/2, 
            CONFIG_SCREEN_HEIGHT/2+bgHeight/2-35)
    else
        self.title:align(display.CENTER, 
            CONFIG_SCREEN_WIDTH/2, 
            CONFIG_SCREEN_HEIGHT/2+bgHeight/2-45)
    end
    self:addChild(self.title)

    self.tips = cc.ui.UILabel.new({
        color = cc.c3b(125, 0, 0),
        text  = self.params.tips or "",
        size  = 32,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_CENTER
        })
        :align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
        :addTo(self)
end

function CommonFragment:back()
    CMClose(self, true)
end
return CommonFragment