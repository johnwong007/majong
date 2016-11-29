--
-- Author: junjie
-- Date: 2016-04-20 16:13:51
--
--我的战队
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTMyTeamLayer = class("FTMyTeamLayer",FightCommonLayer)
local CMGroupButton = require("app.Component.CMGroupButton")
local myInfo = require("app.Model.Login.MyInfo")
local QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
require("app.Network.Http.DBHttpRequest") 
require("app.CommonDataDefine.CommonDataDefine")
local eGroupMenu = {
	eBtnMain 	= 1,
	eBtnMember 	= 2,
	eBtnChat   	= 3,

}

function FTMyTeamLayer:ctor()
	self:setNodeEventEnabled(true)
	self.eGroupTitle = {"首页","成员列表","留言板"}
	self.mGroupBtn   = {}
	self.mAllSelectNode = {}
end
function FTMyTeamLayer:onExit()
	QManagerListener:Detach(eFTMyTeamLayerID)
	QDataFightTeamList:removeMsgData()
end
function FTMyTeamLayer:onEnter()
	QManagerListener:Attach({{layerID = eFTMyTeamLayerID,layer = self}})
end

--[[
	UI创建
]]
function FTMyTeamLayer:create()
	FTMyTeamLayer.super.ctor(self,{bgType = 2,titlePath = "picdata/fightteam/w_t_zd.png",size = cc.size(CONFIG_SCREEN_WIDTH,display.height)}) 
    FTMyTeamLayer.super.initUI(self)
	self:createTitle()
	-- self:createGroupButton()
	self:initNodeLabel(1)
	DBHttpRequest:getMemberInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)
end

--[[
	标题，背景
]]
function FTMyTeamLayer:createTitle()
	-- body
end

--[[
	创建按钮组
]]
function FTMyTeamLayer:createGroupButton()
	local groupBtn = CMGroupButton.new({callback = handler(self,self.onGroupCallBack),
	name = {"战队主页","成员列表","留言板"},
	size = cc.size(600,60),
	direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,})
	groupBtn:create()
	groupBtn:setPosition(40,self.mBg:getContentSize().height-80)
	groupBtn:setTouchEnabled(false)	
	self.mBg:addChild(groupBtn)
	groupBtn:checkTouchInSprite_(1)
	self.groupBtn = groupBtn
end
--[[
	按钮组响应处理
]]
function FTMyTeamLayer:onGroupCallBack(index)
	if index == eGroupMenu.eBtnMain then
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTFirstPageNode")
		self.mFightPageNode    = CMOpen(RewardLayer, self.mBg, {isEnter = true},0)
		self.mFightPageNode:setPosition(self.mBgWidth/2-464,self.mBgHeight/2-289)
		return self.mFightPageNode 
	elseif index == eGroupMenu.eBtnMember then
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTMemberListNode")
		self.mMemberListNode   =  CMOpen(RewardLayer, self.mBg,{isNotAdd = true},0)
		-- self.mMemberListNode:setPosition(self.mBgWidth/2-464,self.mBgHeight/2-289)
		return self.mMemberListNode
	elseif index == eGroupMenu.eBtnChat then
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTChatNode")
		self.mChatNode		   =  CMOpen(RewardLayer, self.mBg,{isNotAdd = true},0)
		return self.mChatNode
	end

end
function FTMyTeamLayer:initNodeLabel(index)
	if not index then return end
	if self.mAllSelectNode[self.mLastIndex] then 
		self.mAllSelectNode[self.mLastIndex]:setVisible(false) 		--隐藏上一个节点
	end
	self.mLastIndex = index
	
	if self.mAllSelectNode[self.mLastIndex] then 
		self.mAllSelectNode[self.mLastIndex]:setVisible(true) 		--显示已创建节点
		self:updateCallBack({tag = "showInputBox",index = index})
	else	
		self.mAllSelectNode[index] = self:onGroupCallBack(index)		--不存在则创建节点
	end
end
function FTMyTeamLayer:updateCallBack(data)
	if data.tag == "updateMemberList" then 							--战队成员列表刷新	
		self.mAllSelectNode[2]:updateMemberList()
	elseif data.tag == "updateClubInfo" then 						--战队信息刷新
		self.mAllSelectNode[1]:updateClubInfo(data)
	elseif data.tag == "updateClubNotice" then 						--战队公告刷新
		self.mAllSelectNode[1]:updateClubNotice(data)
	elseif data.tag == "updateMemberRedDot" then 					--成员列表按钮红点更新
		self.mAllSelectNode[1]:updateMemberRedDot(data.num)
	elseif data.tag == "showInputBox" then 							--通知显示输入框
		if data.index == 3 then
			QManagerListener:Notify({layerID = eFTChatNodeID,tag = "showInputBox"})
		end
	end
end
--[[
	网络回调
]]
function FTMyTeamLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_getMemberInfo then 
		if type(tableData) ~= "table" then return end
		myInfo.data.userClubPos = tableData[1]["A10D"]
	end

end
return FTMyTeamLayer