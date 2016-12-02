local HallMainContract = require("app.architecture.hall.HallMainContract")
local MusicPlayer = require("app.Tools.MusicPlayer")

local HallMainPresenter = class("HallMainPresenter", function()
		return HallMainContract.Presenter:new()
	end)

function HallMainPresenter:ctor(o,params)
	self.m_pDataRepository = params.repository
	self.m_pView = params.view
	self.m_pView:setPresenter(self)
end

function HallMainPresenter:start()
	-- MusicPlayer:getInstance():stopBackgroundMusic()
	-- MusicPlayer:getInstance():playBackgroundMusic()
	return self
end

function HallMainPresenter:onExit()
    
end

return HallMainPresenter