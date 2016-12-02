local RoomBasePresenter = require("app.architecture.room.RoomBasePresenter")

local RoomCashPresenter = class("RoomCashPresenter", function()
		return RoomBasePresenter:new()
	end)

function RoomCashPresenter:ctor(o,params)
	self.m_pDataRepository = params.repository
	self.m_pView = params.view
	self.m_pView:setPresenter(self)
end

-- function RoomCashPresenter:start()
-- 	RoomBasePresenter.start(self)
-- 	return self
-- end

function RoomCashPresenter:onExit()
    
end

return RoomCashPresenter