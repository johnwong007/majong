
tencentValue = require("app.Logic.Config.tencentValue")
require("app.Component.CMCommon")

EGSLogin    = 0
EGSMainPage = 1
EGSRanking  = 2
EGSShop     = 3
EGSActivity = 4
EGSFriend   = 5
EGSGame     = 6
EGSTourney  = 7
EGSHall     = 8
EGSMore     = 9

GameSceneManager = {}
GameSceneManager.mCurSceneType = nil
GameSceneManager.AllScene = {
	LoadingScene = 10,
	MainPageView = 11,
	RoomViewManager = 12,
	LoginView    = 13,
	TourneyList  = 14,
	UpdateScene  = 15 ,
	ReplayView   = 16,
	TestScene    = 999,
	HallView     = 17,
	RoomView     = 18,
}
GameSceneManager.AllLayer = {
	ZIDINGYI  = 102,				--自定义牌局
	SHOP      = 201					--shop

}
function GameSceneManager:switchScene(pScene)
	self.mCurScene = pScene
	self:clearCacheData(pScene)
    display.replaceScene(pScene)
    if #GBroadTips >= 1 then 
    	local BroadCastNode      = require("app.Component.CMNoticeView").new(params)			
		pScene:addChild(BroadCastNode,100)
    end 

    if false then 
    	-- if  GameSceneManager.mCurSceneType ~= GameSceneManager.AllScene.RoomViewManager then
			local myinfo = require("app.Model.Login.MyInfo")
    		-- if myinfo.data.userClubId ~= "" and myinfo.data.userClubId ~= "0" then
    			local clubBtn = CMButton.new({normal = "picdata/public/clubIcon.png"},function () 
    			-- QManagerPlatform:enterClub({['targetId']='DebaoClub'..myInfo.data.userClubId,['clubName']=myInfo.data.userClubName})
    			-- if not GTest then
    			-- 	GTest = true 
	    			-- local RewardLayer      = require("app.GUI.fightTeam.FightDemo")
	    			-- CMOpen(RewardLayer, GameSceneManager:getCurScene())
	    		-- else
	    		-- 	OCCallLuaFunc(data)
	    		-- end
	    		QManagerPlatform:startApp()
    			-- local RewardLayer      = require("app.GUI.fightTeam.FTManager"):Instance({["parent"] = pScene})
   				--  RewardLayer:onEnter()
    			-- device.platform = "android"
    			-- device.platform = "ios"
    			-- QManagerPlatform:onKeyCallBack()
    			-- require("app.Network.Socket.TcpCommandRequest")
    			-- TcpCommandRequest:shareInstance():onClosed()
    			end)
	     		clubBtn:setPosition(30,display.cy)
	     		pScene:addChild(clubBtn,10000)
    		-- end
    	-- end
   end
end
function GameSceneManager:clearCacheData(pScene)
	QManagerPlatform:clearAllLayerID()
	QManagerPlatform:addKeyBackClicked(pScene)
	QManagerListener:clearAllLayerID()    --清除所有以注册的LayerID
	GTip          = {}
	GIsOpen 	  = false
	GIsClose 	  = false 
	GMaskLayer 	  = nil
end
function GameSceneManager:switchSceneWithType(sceneType,data)
	-- dump(sceneType,"sceneType")
	local scene = nil
	data = data or {}
	if sceneType == EGSMainPage then
		local layer = require("app.GUI.mainPage.MainPageView"):new()
		self:switchSceneWithNode(layer)
	elseif sceneType == EGSRanking then
		local layer = require("app.GUI.mainPage.MainPageView"):new("rankLayer")
		self:switchSceneWithNode(layer)
	elseif sceneType == EGSTourney then 
		-- local layer = require("app.GUI.Tourney.TourneyList"):scene(eMatchListRecommend)
		local layer = require("app.GUI.Tourney.TourneyHallView").scene()
		self:switchSceneWithNode(layer)
	elseif sceneType == EGSHall then
		local hall = require("app.GUI.HallView"):new(data.nType)
		self:switchSceneWithNode(hall)
	elseif sceneType == EGSFriend then
		local layer = require("app.GUI.friends.FriendLayer"):new()
		self:switchSceneWithNode(layer)
	elseif sceneType == EGSShop then
		local layer = require("app.GUI.mainPage.MainPageView"):new("hallGold")
		self:switchSceneWithNode(layer)
	elseif sceneType == EGSActivity then
		local layer = require("app.GUI.mainPage.MainPageView"):new("activityLayer")
		self:switchSceneWithNode(layer)
	elseif sceneType == EGSMore then

	elseif sceneType ==  GameSceneManager.AllScene.LoadingScene then
		local LoadingScene = require("app.GUI.LoadingScene")
	    scene = LoadingScene:new()
	elseif sceneType ==  GameSceneManager.AllScene.UpdateScene then
		local UpdateScene = require("app.update.UpdateScene")
	    scene = UpdateScene:new()
	elseif sceneType ==  GameSceneManager.AllScene.MainPageView then
		scene = display.newScene()
	    local m_layer = require("app.GUI.mainPage.MainPageView"):new() 
	    scene:addChild(m_layer)
	    if data.nType == "login" then
	    	m_layer:setFromType("login")
	    end
	elseif sceneType ==  GameSceneManager.AllScene.RoomViewManager then
	    local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager(data.isRush)
	    scene = display.newScene()
	    scene:addChild(roomViewManager)
	    roomViewManager.m_isGameType = data.m_isGameType
	    roomViewManager.m_isFromMainPage = data.m_isFromMainPage	
	    roomViewManager.m_fromWhere = data.from
	    roomViewManager:setEnterClubOrNot(data.enterClubOrNot)

	    local callback = function()
	    	if data.isQuickStart then 
		    	roomViewManager:quickStart()
		    else
		    	if data["random"] then
		    		roomViewManager:enterRoomRandom(data)
		    	else
		    		roomViewManager:enterRoomWithTableId(data.tableId, data.passWord)
		    	end
		    end
		end

	    if data.needRongYun then
	    	roomViewManager:registerRongYun(callback)
	    else
	    	callback()
	    end
	    
		GameSceneManager.mRoomViewManager = roomViewManager
	elseif sceneType ==  GameSceneManager.AllScene.LoginView then
	    scene = require("app.architecture.login.LoginScene"):new()
	elseif sceneType ==  GameSceneManager.AllScene.HallView then
	    scene = require("app.architecture.hall.HallScene"):new()
	elseif sceneType ==  GameSceneManager.AllScene.RoomView then
	    scene = require("app.architecture.room.RoomScene"):new()
	elseif sceneType ==  GameSceneManager.AllScene.TourneyList then
		-- data.nType = data.nType or eMatchListRecommend
		-- scene = require("app.GUI.Tourney.TourneyList"):scene(data.nType)
		scene = require("app.GUI.Tourney.TourneyHallView").scene()
	elseif sceneType ==  GameSceneManager.AllScene.TestScene then
		require("app.EConfig")
		scene = display.newScene()
	    local m_layer = require("app.GUI.setting.MoreRuleScene"):new() 
	    CMOpen(m_layer, scene,0,0)
	elseif sceneType ==  GameSceneManager.AllScene.ReplayView then
		local replayView = require("app.GUI.ReplayView"):create(data.REPLAY_FID)
        replayView:play()
        replayView:setBackView()
        self:switchSceneWithNode(replayView)
	
	end

	GameSceneManager.mCurSceneType = sceneType
	if scene then
		self:switchScene(scene)
	end
	return scene
end

function GameSceneManager:switchSceneWithNode(pNode)
    local scene = display.newScene()
    scene:addChild(pNode)
    self:switchScene(scene)

    --display.replaceScene(scene)
end
--[[要跳转的副本]]
function GameSceneManager:setJumpLayer(tag) 
	if not tag then self.JumpIndex = nil return end
   	for i,v in pairs(GameSceneManager.AllLayer) do 
   		if v == tag then
   			self.JumpIndex = v
   		end
   	end
end
function GameSceneManager:getJumpLayer()
	return self.JumpIndex
end
function GameSceneManager:getCurScene()
	return self.mCurScene
end
return GameSceneManager