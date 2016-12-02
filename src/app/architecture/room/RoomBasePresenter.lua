local BasePresenter = require("app.architecture.BasePresenter")
local MusicPlayer = require("app.Tools.MusicPlayer")

local RoomBasePresenter = class("RoomBasePresenter", function()
		return BasePresenter:new()
	end)

function RoomBasePresenter:ctor(o,params)
end

function RoomBasePresenter:start()
	-- MusicPlayer:getInstance():stopBackgroundMusic()
	-- MusicPlayer:getInstance():playBackgroundMusic(2)
	return self
end

function RoomBasePresenter:onExit()
    
end

return RoomBasePresenter