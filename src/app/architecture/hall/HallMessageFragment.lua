local CommonFragment = require("app.architecture.components.CommonFragment")

local HallMessageFragment = class("HallMessageFragment", function()
		return CommonFragment:new()
	end)

function HallMessageFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
end

function HallMessageFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallMessageFragment:onEnterTransitionFinish()
end

function HallMessageFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallMessageFragment:initUI()
    self.tips:setString("此处用于发布游戏最新消息！")
end

return HallMessageFragment