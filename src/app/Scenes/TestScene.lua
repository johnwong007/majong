require("app.EConfig")

local TestScene = class("TestScene", function()
	return display.newScene("TestScene")
	end)

function TestScene.create()
	local scene = TestScene.new()
	print("123222")
    scene:addChild(require("GUI.ccb.MainLayer1"):new())
    return scene
end

function TestScene:ctor()
    self:addChild(require("GUI.ccb.TestLayer1"):new())
end

return TestScene