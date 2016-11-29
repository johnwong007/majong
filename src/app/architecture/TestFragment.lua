local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")

local TestPresenter = class("TestPresenter", function()
        return BasePresenter:new()
    end)

function TestPresenter:ctor(o,params)
    self.m_pView = params.view
    self.m_pView:setPresenter(self)
end

function TestPresenter:start()

end

------------------------------------------------------------------------------------------------
local TestFragment = class("TestFragment", function()
		return BaseView:new()
	end)

function TestFragment:create()
	self:initUI()
	if self.m_pPresenter then 
    	self.m_pPresenter:start()
    end
end

function TestFragment:ctor(params)
	self.params = params or {}
    TestPresenter:new({view=self})
    self:setNodeEventEnabled(true)
end

function TestFragment:onEnterTransitionFinish()
 
end

function TestFragment:onExit()
	
end

function TestFragment:initUI()
	local bg = cc.ui.UIImage.new("picdata/public_new/bg.png", {scale9 = true})
    bg:setLayoutSize(bgWidth, bgHeight)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self)
end

return TestFragment