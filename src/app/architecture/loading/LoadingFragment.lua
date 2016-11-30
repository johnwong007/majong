local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")
local bgWidth = 0
local bgHeight = 0

local LoadingFragment = class("LoadingFragment", function()
		return BaseView:new()
	end)

function LoadingFragment:create()
	self:initUI()
    if self.m_pPresenter then
        self.m_pPresenter:start()
    end
end

function LoadingFragment:ctor(o,params)
	self.params = params or {}
    -- dump(self.params)
    self.tips = self.params.tips or ""
    self.tipsBg = self.params.tipsBg or nil
    self.viewRect = self.params.viewRect or cc.size(360,240)
    self.scale9 = self.params.scale9 or true
    self.showTimes = self.params.showTimes or nil
    self.timeOutCallback = self.params.timeOutCallback or nil
	self:setNodeEventEnabled(true)
end

function LoadingFragment:onEnterTransitionFinish()
    
end

function LoadingFragment:onExit()
    self:stopLoading()
end

function LoadingFragment:stopLoading()
    self.loadingImage:stopAllActions()
    self.loadingImage1:stopAllActions()
    self:stopAllActions()
end

function LoadingFragment:initUI()
    bgWidth = self.viewRect.width
    bgHeight = self.viewRect.height
    if self.tipsBg then
        local filename = "picdata/public/img_square1.png"
        self.m_pBg = cc.ui.UIImage.new(filename, {scale9 = self.scale9})
        self.m_pBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
            :addTo(self)
        if self.scale9 then
            self.m_pBg:setLayoutSize(bgWidth, bgHeight)
        else
            bgWidth = self.m_pBg:getContentSize().width
            bgWidth = self.m_pBg:getContentSize().height
        end
    else
        self.m_pBg = display.newNode()
            :align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
            :addTo(self)
        self.m_pBg:setContentSize(bgWidth, bgHeight)
    end

    self.tipsLabel = cc.ui.UILabel.new({
        color = cc.c3b(125, 0, 0),
        text  = self.tips,
        size  = 24,
        font  = "黑体",
        align = cc.TEXT_ALIGN_CENTER
        })
    :align(display.CENTER, bgWidth/2, bgHeight/2+75)
    self.m_pBg:addChild(self.tipsLabel)

    self.loadingImage = cc.ui.UIImage.new("picdata/loading/loading_image.png")
        :align(display.CENTER, bgWidth/2, bgHeight/2)
        :addTo(self.m_pBg)
    self.loadingImage1 = cc.ui.UIImage.new("picdata/loading/slice09_09.png")
        :align(display.CENTER, self.loadingImage:getPositionX(), self.loadingImage:getPositionY())
        :addTo(self.m_pBg)

    -- self.loadingImage:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.0, 360)))
    transition.execute(self.loadingImage, cc.RepeatForever:create(cc.RotateBy:create(2.0, 360)))
    transition.execute(self.loadingImage1, cc.RepeatForever:create(cc.RotateBy:create(2.0, 360)))
    if self.showTimes then
        transition.execute(self.loadingImage1, cc.DelayTime:create(tonumber(self.showTimes)),{onComplete=function()
                if self.timeOutCallback then
                    self.timeOutCallback()
                end
            end})
    end
end

function LoadingFragment:setTips(tips)
    self.tipsLabel:setString(tips)
end

return LoadingFragment