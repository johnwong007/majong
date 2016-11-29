--
-- Author: junjie
-- Date: 2016-05-04 16:17:42
--
--
-- Author: junjie
-- Date: 2016-04-27 20:40:52
--
--战队职位分配
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTAppointLayer = class("FTAppointLayer",FightCommonLayer)
local CMColorLabel     = require("app.Component.CMColorLabel")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest") 
local QDataFightTeamList = nil
local EnumMenu = {
	eBtnAppoint 		 = 1,--同意
	eBtnRefuse		 = 2,--拒绝

} 
local clubName = {
	[1] = "队长",
	[2] = "副队长",
	[3] = "成员",
} 
local clubPositon = {
	[1] = "chairman",
	[2] = "vice_chairman",
	[3] = "member",
}
function FTAppointLayer:ctor(params)
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	self.mCheckBtn = {}
	self.mALlItem  = {}
	self.mParams    = params or {}
	self.mParams.userId = self.mParams.userId or ""
	self.mParams.userName = self.mParams.userName or "123"
	self.mParams.userPos  = self.mParams.userPos or clubPositon[1]
	-- dump(self.mParams)
	for i,v in pairs(clubPositon) do 
		if v == self.mParams.userPos then
			table.remove(clubName,i)
			table.remove(clubPositon,i)
			break
		end 
	end
	self.mSelectType = 1
end
function FTAppointLayer:onExit()

end
--[[
	UI创建
]]
function FTAppointLayer:create()
	FTAppointLayer.super.ctor(self,{titlePath = "picdata/fightteam/w_t_rm.png",
		showType = 2,okText = "确定",isOkClose = 0,callOk = function () self:onMenuCallBack(EnumMenu.eBtnAppoint) end}) 
    FTAppointLayer.super.initSecondUI(self)
	local bg = cc.Node:create()
	-- local bgWidth = 800
	-- local bgHeight= 600
	self:addChild(bg)

 -- 	local tip = cc.ui.UILabel.new({
 --        text  = "VIP6及以上玩家可创建战队",
 --        size  = 20,
 --        color = cc.c3b(178, 188, 214),
 --        align = cc.ui.TEXT_ALIGN_LEFT,
 --        --UILabelType = 1,
 --        font  = "黑体",
 --    })
	-- tip:setPosition(self.mBgWidth/2-tip:getContentSize().width/2,self.mBgHeight-90)
	-- self.mBg:addChild(tip)

	local nameText = string.format("任命玩家#01#26;%s#08#26;为？#01#26",self.mParams.userName)
	local name = CMColorLabel.new({text = nameText,size = 26})
	name:setPosition(50,self.mBgHeight-150)
	self.mBg:addChild(name)

	self:createTitleNode()
end
--[[
	成员标签信息
]]
function FTAppointLayer:createTitleNode()

    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/fightteam/btn_choose.png", on = "picdata/fightteam/btn_choose2.png",}))
    :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/fightteam/btn_choose.png", on = "picdata/fightteam/btn_choose2.png",}))
    -- :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/fightteam/btn_choose.png", on = "picdata/fightteam/btn_choose2.png",}))
   
    :setButtonsLayoutMargin(0, 10, 0, 170)
    :onButtonSelectChanged(function(event)
        self.mSelectType = event.selected
       
    end)
    :align(display.LEFT_TOP, self.mBgWidth/2-450,self.mBgHeight/2-30)
    :addTo(self.mBg,1)
     self.mGroup = group
    group:getButtonAtIndex(1):setButtonSelected(true)
	-- local labelText = {
	-- 	{text = clubName[1],posx = 100},{text = clubName[2],posx = 320},{text = clubName[3],posx = 540},
	-- }
	local labelText = {
		{text = clubName[1]},{text = clubName[2]}
	}
	local posx = 100
	for i = 1,#labelText do 
		local content = cc.ui.UILabel.new({
            text  = labelText[i].text,
            size  = 30,
            color = cc.c3b(255, 255, 255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    	content:setPosition(posx,self.mBgHeight/2-12)
   	 	self.mBg:addChild(content)

   	 	posx = posx + 220
	end
end


--[[
	职位分配
]]
function FTAppointLayer:onMenuCallBack(tag)
	-- dump(self.mParams.userPos,clubPositon[self.mSelectType])
	if self.mParams.userPos == clubPositon[self.mSelectType] then
		CMShowTip("玩家已是"..clubName[self.mSelectType])
	else
		DBHttpRequest:appointMember(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mParams.userId,clubPositon[self.mSelectType],myInfo.data.userClubId)
	end
end


--[[
	网络回调
]]
function FTAppointLayer:httpResponse(tableData,tag,itemData)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_appointMember then
		local retCode = tonumber(tableData)
		local sTips = "任命成功"
		if retCode == 10000 then
			if clubPositon[self.mSelectType] == "chairman" then
				myInfo.data.userClubPos = "member"
			end
			QManagerListener:Notify({tag = "updateMemberList",layerID = eFTMyTeamLayerID})
			CMClose(self)
		elseif retCode == -16000 then
			sTips = "该玩家已退出战队"
		elseif retCode == -16001 then
			sTips = "你没有相关的权限"
		elseif retCode == -16027 then
			sTips = "副队长人数已满"
		elseif retCode == -16025 then
			sTips = "该玩家VIP等级不足VIP6"
		else
			sTips = "网络异常"
		end
		CMShowTip(sTips)
	end
end
return FTAppointLayer