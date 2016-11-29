--
-- Author: junjie
-- Date: 2016-04-20 16:16:30
--
--首页节点
local FTFirstPageNode = class("FTFirstPageNode",function () return display.newNode() end)
local myInfo = require("app.Model.Login.MyInfo")
local CMColorLabel     = require("app.Component.CMColorLabel")
require("app.Network.Http.DBHttpRequest")
require("app.Tools.StringFormat") 
local QDataFightTeamList = nil
local VALUE_TAG	         = 101
-- local StateTips = {
-- 	["CREATE"] = "%s#07#22;战队成立",
-- 	["EXAMINE"]= "%s#07#22;被%s批准加入战队",
-- 	["APPOINT"]= "%s#07#22;被%s任命为%s",
-- 	["KICK"]= "%s#07#22;被%s逐出战队",
-- 	["QUIT"]= "%s#07#22;离开了战队",
-- 	["BOARD_PRIZE"]= "%s#07#22;战队收到排行榜奖励的",
-- 	["RECHAGE_PRIZE"]= "%s#07#22;战队收到充值奖励的",
-- 	["UPGRADE"]= "恭喜战队升级为;%s#07#22;级",
-- 	["INVITE"]= "%s#07#22;被%s邀请加入战队",
-- 	["NOTICE"]= "战队当月经验不足,低于最低要求;%s#07#22;，请抓紧时间招募队员完成",
-- }
--[[
	动态状态通知
]]
local StateTips = {
	["CREATE"] = "%s战队成立#07#22",
	["EXAMINE"]= "%s被%s批准加入战队",
	["APPOINT"]= "%s被%s任命为%s",
	["KICK"]= "%s被%s逐出战队",
	["QUIT"]= "%s离开了战队",
	["BOARD_PRIZE"]= "%s战队收到排行榜奖励的#07#22",
	["RECHAGE_PRIZE"]= "%s战队收到充值奖励的#07#22",
	["UPGRADE"]= "恭喜战队升级为%s级#07#22",
	["INVITE"]= "%s被%s邀请加入战队#07#22",
	["NOTICE"]= "战队当月经验不足,低于最低要求%s，请抓紧时间招募队员完成#03#22",
}
local EnumMenu = 
{
	eEditNotice = 1,
	eBtnMember  = 2,
	eBtnChat    = 3,
}
function FTFirstPageNode:ctor()
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	self.mInfoNode     = {}
end

function FTFirstPageNode:create()
	local btnMember = CMButton.new({normal = "picdata/fightteam/btn_meber.png"},function () self:onMenuCallBack(EnumMenu.eBtnMember) end) 
	btnMember:setPosition(720,50)
	self:addChild(btnMember,1)

	local btnChat = CMButton.new({normal = "picdata/fightteam/btn_talk.png"},function () self:onMenuCallBack(EnumMenu.eBtnChat) end)  
	btnChat:setPosition(830,50)
	self:addChild(btnChat,1)


	self.mBtnMember = btnMember
	DBHttpRequest:getMemberInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)
	DBHttpRequest:getClubMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,myInfo.data.userId)
	DBHttpRequest:getClubInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)	
	DBHttpRequest:getClubNotice(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)
	DBHttpRequest:getClubHistory(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,10)
	

	-- test
	-- DBHttpRequest:saveClubNotice(function(tableData,tag) self:httpResponse(tableData,tag) end,174,"test11")
	-- self:createTeamInfo()
	-- self:createNoticeInfo()
	-- self:createStateInfo()
end
--[[
	战队信息
]]
function FTFirstPageNode:createTeamInfo()
	if self.mTeamInfoNode then self.mTeamInfoNode:removeFromParent() self.mTeamInfoNode = nil end
	local data = QDataFightTeamList:getMsgData(1,"ClubInfo") or {}
	local size = cc.size(928,498)
	viewbg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    viewbg:setLayoutSize(size.width,size.height)
	viewbg:setPosition(0,0)
	self:addChild(viewbg)

	local size = cc.size(49,494)
	yinying = cc.ui.UIImage.new("picdata/fightteam/yinying.png", {scale9 = true})
    yinying:setLayoutSize(size.width,size.height)
	yinying:setPosition(300,2)
	self:addChild(yinying)

 	local leftBgWidth = 300

	local probg = cc.Sprite:create("picdata/fightteam/lv.png")
	probg:setPosition(leftBgWidth/2, size.height - 80)
	viewbg:addChild(probg)
	local perNum = (tonumber(data["A106"]) or 0 )/(tonumber(data["A111"]) or 10000) * 100
	local pro = display.newProgressTimer("picdata/fightteam/lv_jdt.png", display.PROGRESS_TIMER_RADIAL)
    pro:setPosition(probg:getContentSize().width/2,probg:getContentSize().height/2)
    pro:setPercentage(perNum)
    probg:addChild(pro)

    local level = tonumber(data["A107"]) or 1
    if level > 6 then level = 6 end
    local level = cc.Sprite:create(string.format("picdata/fightteam/lv_%s.png",level))
    level:setPosition(probg:getContentSize().width/2,probg:getContentSize().height/2+10)
    probg:addChild(level)
	-- self.mTeamInfoNode = cc.Node:create()
	-- self:addChild(self.mTeamInfoNode)
	local nameBg = cc.Sprite:create(string.format("picdata/fightteam/bg_title.png",level))
    nameBg:setPosition(leftBgWidth/2,size.height - 150)
    viewbg:addChild(nameBg)

    local name = cc.ui.UILabel.new({
        text  = data["A101"] or "",
        size  = 30,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
	name:setPosition(nameBg:getContentSize().width/2 - name:getContentSize().width/2,nameBg:getContentSize().height/2-6)
	nameBg:addChild(name) 

	self.mTeamInfoNode = viewbg
	local posx = 40
	local posy = 240
	
	-- local textLabel = {
	-- 	{text = string.format("经验值：%s/%s",data["A106"]or "1",data["A111"]or "2"),size = 20,color = cc.c3b(188, 202, 234)},
	-- 	-- {text = data["A101"] or "1212312",size = 30,color = cc.c3b(255,255,255)},--名字
	-- }
	-- for i = 1,#textLabel do 
	-- 	local name = cc.ui.UILabel.new({
 --            text  = textLabel[i].text,
 --            size  = textLabel[i].size,
 --            color = textLabel[i].color,
 --            align = cc.ui.TEXT_ALIGN_LEFT,
 --            --UILabelType = 1,
 --            font  = "黑体",
 --        })
 --    	name:setPosition(leftBgWidth/2 - name:getContentSize().width/2,posy)
 --    	viewbg:addChild(name)
 --    	posy = posy - 40
	-- end
	-- posy = posy - 20
	if data["A116"] and data["A116"] == "None" then
		data["A116"] = "0"
	end
	local textLabel = {
		{"队长：",data["A103"]or "1"},
		{"成员：",string.format("%s/%s",data["300C"] or "0",data["300B"]or "0")},
		{"经验值：",string.format("%s/%s",data["A106"] or "0",data["A111"]or "0")},
		{"本月经验值：",data["A116"] or "0"},
		-- {"等级",data["A107"]},
		{"战队基金：",data["A108"]or "0","picdata/fightteam/icon_jb_s.png"},
		{"战队积分：",string.format("%s",data["5051"]or "0"),"picdata/fightteam/icon_jf_s.png"},
	}
	for i = 1,#textLabel do 
		local node = self:createLableNode(textLabel[i][1],textLabel[i][2],textLabel[i][3])
		node:setPosition(posx,posy)
		self.mTeamInfoNode:addChild(node)
			-- posx = posx + 250
			-- self.mInfoNode[index] = node
		posy = posy - 40
	end

	
	
end

--[[
	标签信息
]]
function FTFirstPageNode:createLableNode(label,value,path)
	-- local bg = cc.Sprite:create("")
	local bg      = cc.Node:create()
	local bgWidth = 270--bg:getContentSize().width
	local bgHeight= 40--bg:getContentSize().height

	local name = cc.ui.UILabel.new({
            text  = label,
            size  = 22,
            color = cc.c3b(188, 202, 234),
            -- align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
	name:setAnchorPoint(0.5,0.5)
    name:setPosition(5+name:getContentSize().width/2,bgHeight/2)
    bg:addChild(name)

	local posx = 5+name:getContentSize().width
  
    local nameValue = cc.ui.UILabel.new({
            -- text  = StringFormat:FormatDecimals(value or 0,2),
            text  = value,
            size  = 22,
            color = cc.c3b(188, 202, 234),
            -- align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    -- nameValue:setPosition(bgWidth - nameValue:getContentSize().width,bgHeight/2)
    nameValue:setPosition(name:getPositionX()+name:getContentSize().width/2 -10,bgHeight/2)
    bg:addChild(nameValue,0,VALUE_TAG)
    if path then
	    local sp = cc.Sprite:create(path)
	    sp:setPosition(8+name:getContentSize().width, bgHeight/2)
	    bg:addChild(sp)
	    nameValue:setPositionX(sp:getPositionX()+18)
	end
    return bg
end
--[[
	战队公告
]]
function FTFirstPageNode:createNoticeInfo()
	-- local bg = cc.Node:create()
	if self.mNoticeNode then self.mNoticeNode:removeFromParent() self.mNoticeNode = nil end
	local size = cc.size(560,172)
	bg = cc.ui.UIImage.new("picdata/fightteam/bg_gg.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
	bg:setPosition(300,0)
	bg:setPosition(330, 300)
	self:addChild(bg)
	self.mNoticeNode = bg

	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height

	local title = cc.Sprite:create("picdata/fightteam/w_title_zdgg.png")
    title:setPosition(bgWidth/2, bgHeight-28)
    bg:addChild(title)
	local data = QDataFightTeamList:getMsgData(1,"ClubNotice") or {{}}
	local tips = data[1]["NOTICE_CONTENT"] or "暂无公告"
	local color= cc.c3b(255,255,255)
	if data[1]["NOTICE_CONTENT"] == "None" or data[1]["NOTICE_CONTENT"] == "" then
		if myInfo.data.userClubPos == "chairman" then
			tips = "给你们的队友写个公告吧..."
			color= cc.c3b(188,202,234) 
		else
			tips = "暂无公告"
			color= cc.c3b(188,202,234)
		end
	end 

	

	local nameValue = cc.ui.UILabel.new({
            text  = tips,
            size  = 20,
            color = color,
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
            dimensions = cc.size(bgWidth-30,0),
        })
    nameValue:setPosition(20,120-nameValue:getContentSize().height/2)
    -- item:addChild(nameValue)

    local bound = {x = 20, y = 5, width = bgWidth-30, height = 120} 
    local item = cc.ui.UIScrollView.new({
	    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	    viewRect = bound, 
	   -- scrollbarImgH = "scroll/barH.png",
	   -- scrollbarImgV = "scroll/bar.png",
	   -- bgColor = cc.c4b(125,125,125,125)
	})
    :addScrollNode(nameValue)
    :addTo(bg)

    

    local btnChangeNotice = CMButton.new({normal = "picdata/fightteam/btn_bj.png",pressed = "picdata/fightteam/btn_bj2.png"},function () self:onMenuCallBack(EnumMenu.eEditNotice) end)  
	btnChangeNotice:setPosition(bgWidth-40,bgHeight-25)
	bg:addChild(btnChangeNotice)
	
	if myInfo.data.userClubPos == "member" then
		btnChangeNotice:setVisible(false)
	end
	self.mBtnEditNotice = btnChangeNotice
	self.mContentNotice = nameValue
end

--[[
	战队动态
]]
function FTFirstPageNode:createStateInfo()
	local size = cc.size(560,172)
	bg = cc.ui.UIImage.new("picdata/fightteam/bg_gg.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
	bg:setPosition(300,0)
	bg:setPosition(330, 100)
	self:addChild(bg)

	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height

	local title = cc.Sprite:create("picdata/fightteam/w_title_zddt.png")
    title:setPosition(bgWidth/2, bgHeight-28)
    bg:addChild(title)

	local tableData = QDataFightTeamList:getMsgData(1,"ClubHistory") or {}
	-- tableData = self.mCfgData or {"a","234","a","234","a","234","a","234","a","234","a","234","234","a","234","a","234","a","234"}
    self.mListSize = cc.size(555,125  ) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(330, 102, self.mListSize.width, self.mListSize.height),     
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchRightListener))
    :addTo(self,1)    
    if #tableData == 0 then return end
    for i = 1,#tableData do 
        local item = self:createPageItem(i,tableData[i] or  "")
        self.mList:addItem(item)
    end 

    self.mList:reload() 
end

function FTFirstPageNode:createPageItem(idx,serData)
	  -- 1 = {
   --       "5045" = "CREATE"
   --       "5047" = "2016-05-05,kisr"
   --   }
	serData = serData or {}
	local nType = serData["5045"]
	local sContent = string.split(serData["5047"] or "",",") or {}
    local item = self.mList:newItem()  
   
    local node = cc.Node:create() 
   
    
     -- local content = cc.ui.UILabel.new({
     --        text  = (sContent[1] or "").." "..string.format(StateTips[nType] or "",sContent[2] or "",sContent[3] or ""),
     --        size  = 22,
     --        color = cc.c3b(255, 255, 255),
     --        align = cc.ui.TEXT_ALIGN_LEFT,
     --        --UILabelType = 1,
     --        font  = "黑体",
     --        dimensions = cc.size(self.mListSize.width-50,0),
     --    })
	-- local itemSize = cc.size(self.mListSize.width,content:getContentSize().height+8)
	
	local sText =  string.format(StateTips[nType] or "",sContent[2] or "",sContent[3] or "",sContent[4] or "")
	local nTime=  string.format("%s#09#22",sContent[1] or "")
    local content = CMColorLabel.new({text = string.format("%s; %s",nTime,sText)})

    local itemSize = cc.size(self.mListSize.width,30)
	local bgWidth = itemSize.width
    local bgHeight= itemSize.height
    item:addContent(node)
    node:setContentSize(self.mListSize.width,itemSize.height)
    item:setItemSize(self.mListSize.width,itemSize.height)

    content:setPosition(15,bgHeight/2-10)
    node:addChild(content)
    return item
end
--[[
	按钮回调
]]
function FTFirstPageNode:onMenuCallBack(tag)
	if tag == EnumMenu.eEditNotice then
		local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTEditNoticeLayer")
		CMOpen(RewardLayer,self:getParent(),nil,0)
	elseif tag == EnumMenu.eBtnMember then
		-- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTMemberListNode")
		-- CMOpen(RewardLayer,self:getParent(),nil,0)
		local FTManager      = require("app.GUI.fightTeam.FTManager"):Instance()
		local FTMyTeamLayer = FTManager:getMyTeamLayer()
		FTMyTeamLayer:initNodeLabel(2)
	elseif tag == EnumMenu.eBtnChat then
		-- if device.platform ~= "ios" then
		-- 	CMShowTip("暂未开放")
		-- 	return 
		-- end
		local FTManager      = require("app.GUI.fightTeam.FTManager"):Instance()
		local FTMyTeamLayer = FTManager:getMyTeamLayer()
		FTMyTeamLayer:initNodeLabel(3)
	end
end
--[[
	废弃
]]
function FTFirstPageNode:onMenuEditNotice()
	if self.mBtnEditNotice:getButtonLabel("normal"):getString() == "编辑公告" then
		self.mBtnEditNotice:setButtonLabelString("normal", "保 存")
		self.mInputNotice:setVisible(true)
		self.mContentNotice:setVisible(false)		
	else
		self.mBtnEditNotice:setButtonLabelString("normal", "编辑公告")	
		self.mInputNotice:setVisible(false)
		self.mContentNotice:setVisible(true)
		local text = self.mInputNotice:getText()
		if text then
			self.mContentNotice:setString(text)
			DBHttpRequest:saveClubNotice(function(tableData,tag) self:httpResponse(tableData,tag) end,174,text)
		end	
	end
	
end
function FTFirstPageNode:touchRightListener(event)

end
--[[
	更新界面
]]
function FTFirstPageNode:updateUI(tableData)
	-- body
end
--[[
	更新公告内容
]]
function FTFirstPageNode:updateNoticeInfo(tableData)

end
--[[
	创建公告编辑框
]]
function FTFirstPageNode:createNoticeUI()

end
--[[
	更新基金数量
]]
function FTFirstPageNode:updateClubInfo(data)
	DBHttpRequest:getClubInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)	
	-- self.mInfoNode[4]:getChildByTag(VALUE_TAG):setString(data.feedNum)
end
function FTFirstPageNode:updateClubNotice()
	DBHttpRequest:getClubNotice(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)
end
--[[
	更新成员列表红点
]]
function FTFirstPageNode:updateMemberRedDot(num)
	if self.mBtnMember then
		if tonumber(num) > 0 then
			self.mBtnMember:addRedDot()
		else
			self.mBtnMember:removeRedDot()
		end
	end
end
--[[
	网络回调
]]

function FTFirstPageNode:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_getClubInfo then
		QDataFightTeamList:Init(tableData,1,"ClubInfo")
		self:createTeamInfo()
	elseif tag == POST_COMMAND_GET_getClubNotice then 
		QDataFightTeamList:Init(tableData,1,"ClubNotice")
		self:createNoticeInfo()
	elseif tag == POST_COMMAND_GET_getClubHistory then 
		QDataFightTeamList:Init(tableData,1,"ClubHistory")
		self:createStateInfo()
	elseif tag == POST_COMMAND_GET_saveClubNotice then
		if tonumber(tableData) == 10000 then
			CMShowTip("修改成功")
		else
			CMShowTip("修改失败,请重试!")
		end
	elseif tag == POST_COMMAND_GET_getClubMembers then 
		self:updateMemberRedDot(tableData["APPLY_NUM"])
	elseif tag == POST_COMMAND_GET_getMemberInfo then
		myInfo.data.userClubPos = tableData[1]["A10D"]
	end

end
return FTFirstPageNode