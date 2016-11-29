local HallMainPresenter = require("app.architecture.hall.HallMainPresenter")
local Injection = require("app.architecture.Injection")
local HallScene = class("HallScene", function()
	return display.newScene("HallScene")
	end)

function HallScene:ctor(params)
	
end

-- function LoginScene:onEnterTransitionFinish()
function HallScene:onEnter()
    --[[Create the View]]
	local fragment = require("app.architecture.hall.HallMainFragment"):new()
	fragment:create()
	self:addChild(fragment)

    --[[Create the Presenter]]
    local presenter = HallMainPresenter:new({
    	repository = Injection.provideHallDataRepository(),
        view = fragment
        }):start()
end
function HallScene:onExit()
	self:removeMemory()
end

function HallScene:removeMemory()
	local memoryPath = require("app.GUI.allrespath.LoginViewPath")
	for i,v in pairs(memoryPath) do
		display.removeSpriteFrameByImageName(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

return HallScene