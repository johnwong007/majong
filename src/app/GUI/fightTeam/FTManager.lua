--
-- Author: junjie
-- Date: 2016-04-20 16:12:09
--
local FTManager = {}
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
function FTManager:new()
	 o = o or {}
    setmetatable(o,self)
    self.__index = self     
    return o
end

function FTManager:onEnter(params)
	params = params or {}
	self.parent = params.parent or GameSceneManager:getCurScene()
	self.mMaskLayer = CMMask.new()
    self.parent:addChild(self.mMaskLayer)
    if myInfo.data.userClubId ~= "" then
    	self:createUI()
    else
    	self:request()
    end
end

function FTManager:onExit()

end
function FTManager:Instance()
	if self.instance == nil then 
        self.instance = self:new()
    end
    return self.instance
end
function FTManager:request()
	DBHttpRequest:getUserShowInfo(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,myInfo.data.userId)
end

function FTManager:httpResponse(tableData,tag)
	dump(tableData,tag)
	if tag == POST_COMMAND_GETUSERSHOWINFO then
		myInfo.data.userClubId = tonumber(tableData["A100"])
		self:createUI()
	end
end

--[[
	根据是否加入战队，选择跳转位置
]]
function FTManager:createUI()
	if myInfo.data.userClubId == 0 then
		local RewardLayer      = require("app.GUI.fightTeam.allTeam.FTAllTeamLayer")
		CMOpen(RewardLayer, self.parent, {easing=false})
	else
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTMyTeamLayer")
		local FTMyTeamLayer = CMOpen(RewardLayer, self.parent, {easing=false})
		if FTMyTeamLayer then
			self.FTMyTeamLayer = FTMyTeamLayer
		end
	end
	if self.mMaskLayer then self.mMaskLayer:removeFromParent() self.mMaskLayer = nil end
end

function FTManager:getMyTeamLayer()
	return self.FTMyTeamLayer
end
return FTManager