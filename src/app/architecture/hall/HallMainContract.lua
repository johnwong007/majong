local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")

local HallMainContract = {
	View = class("View", function()
			return BaseView:new()
		end),
	Presenter = class("Presenter", function()
			return BasePresenter:new()
		end) 
}

return HallMainContract