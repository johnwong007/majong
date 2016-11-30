local CommonFragment = require("app.architecture.components.CommonFragment")

local HallAddCardFragment = class("HallAddCardFragment", function()
		return CommonFragment:new()
	end)

function HallAddCardFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
end

function HallAddCardFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallAddCardFragment:onEnterTransitionFinish()
end

function HallAddCardFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallAddCardFragment:initUI()
    self.tips:setString("业务合作请联系386476890@qq.com")
end

return HallAddCardFragment