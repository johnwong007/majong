local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local MoreRuleScenePath = require("app.GUI.allrespath.MoreRuleScenePath")

--日常签到
--[[
Callbacks:
    "onMenuCallBack",
    "onMenuClose",

Members:
    self.mDayBg CCSprite
    self.mDay1 CCSprite
    self.mDay2 CCSprite
    self.mDay3 CCSprite
    self.mDay4 CCSprite
    self.mDay5 CCSprite
    self.mDay6 CCSprite
    self.mDay7 CCSprite
    self.btnSign CCMenuItemImage
]]
local RewardLayer = Oop.class("RewardLayer", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI.reward", "ccb")
    return CCBLoader:load("RewardLayer", owner)
end)

function RewardLayer:ctor()
    --self:getEventDispatcher():setPriority(,-1)
    -- @TODO: constructor

    -- local CMMaskLayer = CMMask.new()
    -- self:addChild(CMMaskLayer)
    self:initUI()
end

function RewardLayer:initUI()
    self:setPosition(display.cx-480,display.cy-320)
    self.mDay = {self.mDay1,self.mDay2,self.mDay3,self.mDay4,self.mDay5,self.mDay6,self.mDay7}
    if myInfo.data.isSigned then
        self.btnSign:setEnabled(false)
        for i = 1,myInfo.data.signTimes do
            self:changeDailyState(i)
        end
    else
        DBHttpRequest:getLoginSignInfo(function(tableData,tag) self:httpResponse(tableData,tag) end)
    end

end
--[[请求签到]]
function RewardLayer:onMenuCallBack(sender, event)
    -- @TODO: implement this
    DBHttpRequest:loginSign(function(tableData,tag) self:httpResponse(tableData,tag) end)
end

function RewardLayer:onMenuClose(sender, event)
    -- @TODO: implement this
    CMClose(self)
end
function RewardLayer:httpResponse(tableData,tag) 
    if tag == POST_COMMAND_getLoginSignInfo then   
        local curTime = CMFormatTimeStyle(myInfo.data.serverTime)
        if curTime == tableData[FINAL_SIGNIN_DATE] then
            myInfo.data.isSigned = true
            self.btnSign:setEnabled(false)
        end
        myInfo.data.signTimes = tableData[SIGNIN_TIMES]
        for i = 1,tableData[SIGNIN_TIMES] do
            self:changeDailyState(i)
        end
    elseif tag == POST_COMMAND_loginSign then
        myInfo.data.signTimes = myInfo.data.signTimes + 1
        self.btnSign:setEnabled(false)
        self:playAction()
    end
    
end

function RewardLayer:changeDailyState(iDay)
	if iDay > 7 then return end

	local node = cc.Node:create()
    node:setPosition(self.mDay[iDay]:getPositionX(),self.mDay[iDay]:getPositionY())
    self.mDayBg:addChild(node)

    local tipPath = MoreRuleScenePath.RewadrLayer.tips1
    if iDay == 7 then
    	tipPath = MoreRuleScenePath.RewadrLayer.tips2
    end
	local tipsBg = cc.Sprite:create(tipPath) 
	node:addChild(tipsBg)

	local alreadySign = cc.Sprite:create(MoreRuleScenePath.RewadrLayer.alreadySignIn)
	node:addChild(alreadySign)
end

function RewardLayer:playAction()
    local iDay = myInfo.data.signTimes 
    local signLight = cc.Sprite:create(MoreRuleScenePath.RewadrLayer.signLight )
    signLight:setPosition(self.mDay[iDay]:getPositionX(),self.mDay[iDay]:getPositionY())
    signLight:setScale(0.8)
    

    local tipPath = MoreRuleScenePath.RewadrLayer.tips1
    if iDay == 7 then
        tipPath = MoreRuleScenePath.RewadrLayer.tips2
    end

    local lastSignTip = cc.Sprite:create(tipPath) 
    lastSignTip:setPosition(self.mDay[iDay]:getPositionX(),self.mDay[iDay]:getPositionY())
    self.mDayBg:addChild(lastSignTip)

    local signTipFadeOut = cc.FadeIn:create(0.5)
    lastSignTip:runAction(signTipFadeOut)

    local signLightScale  = cc.ScaleTo:create(0.3, 1.2)
    local signLightFadeIn = cc.FadeOut:create(0.1)
    local delayAction     = cc.DelayTime:create(0.45)
    local funcAction      = cc.CallFunc:create(function () 
    local alreadySign = cc.Sprite:create(MoreRuleScenePath.RewadrLayer.alreadySignIn)
        alreadySign:setPosition(self.mDay[iDay]:getPositionX(),self.mDay[iDay]:getPositionY())
        self.mDayBg:addChild(alreadySign)  end)      
    signLight:runAction(cc.Sequence:create(signLightScale, signLightFadeIn,delayAction,funcAction))
    self.mDayBg:addChild(signLight)
end

return RewardLayer