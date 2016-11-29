
local LoginView = class("LoginView", function()
	return display.newScene("LoginView")
	end)

function LoginView:ctor(class,params)
	
end
function LoginView:onEnterTransitionFinish()
	local layer = require("app.GUI.login.LoginViewLayer"):new()
	self:addChild(layer)
	if params then
		layer:toDebaoLogin()
	end

end
function LoginView:onExit()
	self:removeMemory()
end
function LoginView:removeMemory()
	local memoryPath = require("app.GUI.allrespath.LoginViewPath")
	for i,v in pairs(memoryPath) do
		display.removeSpriteFrameByImageName(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
return LoginView