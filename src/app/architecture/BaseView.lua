local BaseView = class("BaseView", function()
		return display.newLayer()
	end)

function BaseView:ctor()end

function BaseView:setPresenter(presenter)
	self.m_pPresenter = presenter
end

return BaseView