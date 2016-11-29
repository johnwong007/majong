local LoginPresenter = require("app.architecture.login.LoginPresenter")
local Injection = require("app.architecture.Injection")
local LoginScene = class("LoginScene", function()
	return display.newScene("LoginScene")
	end)

function LoginScene:ctor(params)
	self.m_bIsAutoShowDebaoLogin = params.m_bIsAutoShowDebaoLogin or false
end

-- function LoginScene:onEnterTransitionFinish()
function LoginScene:onEnter()
    --[[Create the View]]
	local fragment = require("app.architecture.login.LoginFragment"):new()
	fragment:create()
	self:addChild(fragment)

    --[[Create the Presenter]]
    local presenter = LoginPresenter:new({
    	repository = Injection.provideLoginDataRepository(),
        view = fragment
        }):start()
end
function LoginScene:onExit()
	self:removeMemory()
end
function LoginScene:removeMemory()
	local memoryPath = require("app.GUI.allrespath.LoginViewPath")
	for i,v in pairs(memoryPath) do
		display.removeSpriteFrameByImageName(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
return LoginScene