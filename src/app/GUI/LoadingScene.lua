local LoadingScene = class("LoadingScene", function()
	return display.newScene("LoadingScene")
	end)

function LoadingScene:createLoading()
	local p = LoadingScene.new()
	return p
end

function LoadingScene:ctor()
	self.m_layer = require("app.GUI.LoadingSceneLayer"):new() 
	self:addChild(self.m_layer)
end

function LoadingScene:start()
	self.m_layer:start()
end

function LoadingScene:changeRoom()
	-- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
	-- GameSceneManager:switchSceneWithNode(roomViewManager)
	-- roomViewManager.m_isGameType = true
	-- roomViewManager:quickStart()
	
	GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{m_isGameType = true,isQuickStart = true })
end

function LoadingScene:enterTourneyRoom(tableId)
	-- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
	-- GameSceneManager:switchSceneWithNode(roomViewManager)
	-- roomViewManager:enterRoomWithTableId(tableId)
	GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = tableId})
end

function LoadingScene:changeTipsType(tipsType)
	if tipsType == ForChiampion_Loading_Tips then
		self.m_layer.hintLabel:setString("正在进入锦标赛！")
	end
end

return LoadingScene