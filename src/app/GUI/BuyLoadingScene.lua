local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")

--[[
Callbacks:
    

Members:
    self.statusbar CCSprite
]]
local BuyLoadingScene = Oop.class("BuyLoadingScene", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI", "ccb")
    return CCBLoader:load("BuyLoadingScene", owner)
end)

function BuyLoadingScene:ctor()
    -- @TODO: constructor
     local CMMaskLayer = CMMask.new()
    self:addChild(CMMaskLayer)
end

function BuyLoadingScene:createLoading()
	local loading = BuyLoadingScene:new()
	return loading
end

function BuyLoadingScene:start()
	self:setVisible(true)
end

function BuyLoadingScene:stop()
	self:setVisible(false)
end

return BuyLoadingScene