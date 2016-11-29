local HallMainContract = require("app.architecture.hall.HallMainContract")

local HallMainPresenter = class("HallMainPresenter", function()
		return HallMainContract.Presenter:new()
	end)

function HallMainPresenter:ctor(o,params)
	self.m_pHallDataRepository = params.repository
	self.m_pHallMainView = params.view
	self.m_pHallMainView:setPresenter(self)
end

function HallMainPresenter:start()
	return self
end

function HallMainPresenter:onExit()
    
end

return HallMainPresenter