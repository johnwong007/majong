local CommonFragment = require("app.architecture.components.CommonFragment")

local HallRecordFragment = class("HallRecordFragment", function()
		return CommonFragment:new()
	end)

function HallRecordFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
end

function HallRecordFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallRecordFragment:onEnterTransitionFinish()
end

function HallRecordFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallRecordFragment:initUI()
    self.tips:setString("暂无战绩，快去喊小伙伴一起玩牌吧！")
end

return HallRecordFragment