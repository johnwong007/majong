local RoomCashPresenter = require("app.architecture.room.RoomCashPresenter")
local Injection = require("app.architecture.Injection")
local RoomScene = class("RoomScene", function()
	return display.newScene("RoomScene")
	end)

function RoomScene:ctor(params)
	
end

-- function LoginScene:onEnterTransitionFinish()
function RoomScene:onEnter()
    --[[Create the View]]
	local fragment = require("app.architecture.room.RoomFragment"):new()
	fragment:create()
	self:addChild(fragment)

    --[[Create the Presenter]]
    local presenter = RoomCashPresenter:new({
    	repository = Injection.provideRoomDataRepository(),
        view = fragment
        }):start()
end
function RoomScene:onExit()
	self:removeMemory()
end

function RoomScene:removeMemory()
	local memoryPath = require("app.GUI.allrespath.LoginViewPath")
	for i,v in pairs(memoryPath) do
		display.removeSpriteFrameByImageName(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

return RoomScene