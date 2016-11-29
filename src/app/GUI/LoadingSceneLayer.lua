require("app.Tools.EStringTime")
local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")
require("socket")
local scheduler = require("framework.scheduler")
--[[
Callbacks:
    

Members:
    
]]
local kTipMessage = {
	"不要看太多的牌，而是应该盖掉更多的牌",
	"入局率：玩家主动向底池中投入筹码的比率",
	"翻牌前加注率：玩家翻牌前加注的比率",
	"合理的激进度一般介于1.4-4之间",
	"真正的绅士不会谈论离别的女人和错过的底牌",
	"概率学在德堡扑克中尤为重要",
	"忍受不了差牌的寂寞，就无法等到赢牌的荣耀",
	"无论你信不信，打牌都是一门科学",
	"管理好你的资金，才会成长为一个长期的赢家",
	"沉闷的赢钱总比畅快的输钱要好",
	"不要因为已经有了投入就干脆玩到底",
	"适合自己的牌就是最好的牌",
	"起手玩的紧，是你成为赢家的第一步",
	"在德堡扑克中，不要忽略了位置的重要性",
	"别纯粹为了咋唬而咋唬"
}

local LoadingSceneLayer = Oop.class("LoadingSceneLayer", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI", "ccb")
    return CCBLoader:load("LoadingSceneLayer", owner)
end)

local function enterLoginView(dt)
	GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView,{tableId = tableId,passWord = passWord})
	-- local scene = require("app.GUI.login.LoginView"):new()
	-- GameSceneManager:switchScene(scene)

	scheduler.unscheduleGlobal(handler_timer)
end

function LoadingSceneLayer:start()
    handler_timer = scheduler.scheduleGlobal(enterLoginView,2)
end

function LoadingSceneLayer:ctor()
    -- @TODO: constructor
    local hintLabel = self.hintLabel
    math.randomseed(socket.gettime()*1000)
   	local value = math.random(15)
   	hintLabel:removeFromParent(true)
   	self.hintLabel = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = "",
        size  = 22,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = display.CENTER
        })
   	:align(display.CENTER, 0, 0)
   	self.m_loadingBg:addChild(self.hintLabel)
    self.hintLabel:setString(kTipMessage[value])
    self.hintLabel:setPositionX(self.m_loadingBg:getContentSize().width/2)
    self.hintLabel:setPositionY(195)
    self.hintLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER)

	local logo = cc.ui.UIImage.new("sta_2_logo.png")
	logo:align(display.CENTER, display.cx, display.height/2+80)
	:addTo(self)
    self.logo = logo

    -- local imageUtils = require("app.Tools.ImageUtils")
    -- local loadingFilename = imageUtils:getImageFileName(GDIFROOTRES.."picdata/loadingscene_dif/bg_1_bg_loading.png")
    -- self.m_loadingBg:setTexture(loadingFilename)
end

return LoadingSceneLayer