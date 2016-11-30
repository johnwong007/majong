local CommonFragment = require("app.architecture.components.CommonFragment")

local HallFeedbackFragment = class("HallFeedbackFragment", function()
		return CommonFragment:new()
	end)

function HallFeedbackFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
end

function HallFeedbackFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallFeedbackFragment:onEnterTransitionFinish()
end

function HallFeedbackFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallFeedbackFragment:initUI()
    self.tips:setString("如有任何问题请联系作者386476890@qq.com")
end

return HallFeedbackFragment