--
-- Author: junjie
-- Date: 2015-12-10 11:48:06
--
--个人中心

local CMCommonLayer = require("app.Component.CMCommonLayer")
local PersonCenterLayer = class("PersonCenterLayer",CMCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
local GameLayerManager  = require("app.GUI.GameLayerManager")
require("app.Network.Http.DBHttpRequest")
require("app.CommonDataDefine.CommonDataDefine")
local TAG = {


}
local EnumMenu = 
{	
	eBtnHead 	= 1,
	eBtnAccount = 2,
	eBtnLevel   = 3,
	eBtnVip 	= 4,
	eBtnShop 	= 5,
	eBtnPaiJu  	= 6,
	eBtnMyPacket= 7,
	eBtnDataExPlain = 8,
	eBtnExcharge    = 9,
	eBtnShop        = 10,
	eBtnDetail      = 11,
	eBtnDeBaoJu     = 12,
	eBtnSecurity	= 13,
	eBtnSex	= 14,
}
function PersonCenterLayer:ctor(params)	
	self.mPageNode = {}
end

function PersonCenterLayer:create()
	PersonCenterLayer.super.ctor(self,{
		titlePath = "个人中心",
		titleFont = "fonts/title.fnt",
		isFullScreen = true,
		titleOffY = -35}) 
	PersonCenterLayer.super.initUI(self)
	self:initUI()
	self:createLeftUI()
    local node = self:createBottomUI()
    self.mPageNode["bottomNode"] = node
    self.mBg:addChild(node)

    DBHttpRequest:getUserMatchData(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)
	DBHttpRequest:hudForMobile(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)
end
function PersonCenterLayer:onEnter()
	QManagerListener:Attach({{layerID = ePersonLayerID,layer = self}})
end
function PersonCenterLayer:onExit()
	QManagerListener:Detach(eHeadEditLayerID)
	QManagerData:removeCacheData("QDataMyBoardList")
	QManagerData:removeCacheData("QDataMyPacketList")
	QManagerData:removeCacheData("QDataMyMatchList")
end

function PersonCenterLayer:initUI()
    local line1 = cc.ui.UIImage.new("picdata/public_new/line2.png")
    line1:align(display.CENTER, self.mBg:getContentSize().width/3, 282)
        :addTo(self.mBg)
    line1:setRotation(-90)
    line1:setScaleX(0.7)

    local line2 = cc.ui.UIImage.new("picdata/public_new/line.png")
    line2:align(display.LEFT_CENTER, line1:getPositionX(), self.mBg:getContentSize().height-210)
        :addTo(self.mBg)
    line2:setScaleX(0.7)

    local line3 = cc.ui.UIImage.new("picdata/public_new/line.png")
    line3:align(display.LEFT_CENTER, line2:getPositionX(), self.mBg:getContentSize().height-422)
        :addTo(self.mBg)
    line3:setScaleX(0.7)
end

function PersonCenterLayer:createLeftUI()
	
	-- local bg = cc.Sprite:create("picdata/public/tc1_bg6.png")
	-- bg:setPosition(self.mBg:getContentSize().width/2, self.mBg:getContentSize().height/2+20)
	-- self.mBg:addChild(bg)

	local node = cc.Node:create()
	self.mBg:addChild(node)
	
	local headBGManPath  = "picdata/public/bg_5_player_man_line.png"
    local headBGWomanPath= "picdata/public/bg_5_player_woman_line.png"
    local manPath   = "picdata/personCenterNew/personCenter/sex_btn_m.png"
	local womenPath = "picdata/personCenterNew/personCenter/sex_btn_f.png"
    local headPath  = "picdata/public_new/bg_tx.png"--headBGManPath
    local manPath   = manPath
    local serData = {}
	if myInfo.data.userSex == "女" then
		manPath  = womenPath
	end
	local leftUIPosx = (self.mBg:getContentSize().width/2-115)/2-20
	leftUIPosx = self.mBg:getContentSize().width/6-35
    local headBG = cc.Sprite:create(headPath)
	headBG:setPosition(leftUIPosx,self.mBg:getContentSize().height-195)
	node:addChild(headBG)
	local btnSet = CMButton.new({normal = headPath,pressed = headPath},function () self:onMenuCallBack(EnumMenu.eBtnAccount) end)    
    :align(display.CENTER, headBG:getPositionX(), headBG:getPositionY()) --设置位置 锚点位置和坐标x,y
    :addTo(node) 

    local headPic = CMCreateHeadBg(
    	myInfo.data.userPotrait,
    	cc.size(headBG:getContentSize().width,headBG:getContentSize().height),
    	nil,
    	myInfo.data.userPotrait)
    headPic:setPosition(headBG:getPositionX(),headBG:getPositionY())
    headPic:setTouchEnabled(true)
	headPic:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event,btn) return self:buttonClick(event,headPic) end)
    node:addChild(headPic)
    self.mHeadPic = headPic

    local maskPath = "picdata/personCenterNew/personCenter/bg_tx_nomal.png"
    if tonumber(myInfo.data.vipLevel)>0 then
    	maskPath = "picdata/personCenterNew/personCenter/bg_tx_vip.png"
   	end
   	local headMask = cc.Sprite:create(maskPath)
	headMask:setPosition(headBG:getPositionX(),headBG:getPositionY())
	node:addChild(headMask)

    local tip = cc.ui.UILabel.new({
	        text  = "修改头像",
	        size  = 24,
	        color = cc.c3b(89, 109, 147),
	        --UILabelType = 1,
    		font  = "Arial",
	    })
	tip:align(display.CENTER,headMask:getContentSize().width/2,55)
	headMask:addChild(tip)

	-- local userSex = cc.Sprite:create(manPath)
	-- userSex:setPosition(190,375)
	-- node:addChild(userSex)

	self.m_pUserSexBtn = CMButton.new({normal = manPath,
		pressed = manPath},
		function () self:pressUserSexBtn() end,nil,{changeAlpha = true})    
    :align(display.CENTER, headMask:getContentSize().width, 20+3) --设置位置 锚点位置和坐标x,y
    :addTo(headMask) 
    -------------------------------------------------
    self.m_pSexSettingNode = display.newLayer()
    self.m_pSexSettingNode:align(display.LEFT_BOTTOM, 0, 0)
    	:addTo(self.mBg,2)

	self.m_pSexSettingNode:setTouchEnabled(true)
	self.m_pSexSettingNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	if event.name == "began" then
        	self:pressUserSexBtn()
    	end
	end)

    self.m_pSexSettingBg = cc.ui.UIImage.new("picdata/personCenterNew/personCenter/sex_bg.png")
    :align(display.CENTER, headBG:getPositionX()+125, headBG:getPositionY()-30)
    :addTo(self.m_pSexSettingNode)
    self.m_pSexSettingNode:setVisible(false)

    local radioPath = "picdata/personCenterNew/personCenter/sex_btn_radio.png"
    local radioPath1 = "picdata/personCenterNew/personCenter/sex_btn_radio_p.png"
    local sexMaleIcon = "picdata/personCenterNew/personCenter/sex_icon_m.png"
    local sexFemaleIcon = "picdata/personCenterNew/personCenter/sex_icon_f.png"
    local posx1 = self.m_pSexSettingBg:getContentSize().width/2-50
    local posy = self.m_pSexSettingBg:getContentSize().height/2+7.5
    local posx2 = self.m_pSexSettingBg:getContentSize().width/2+50
    self.m_pSexMaleBtn = CMButton.new({normal = {radioPath, sexMaleIcon},
		pressed = {radioPath1, sexMaleIcon},
		disabled = {radioPath1, sexMaleIcon}},
		function () self:pressSexMaleBtn() end,nil,{changeAlpha = true})    
    :align(display.CENTER, posx1, posy) --设置位置 锚点位置和坐标x,y
    :addTo(self.m_pSexSettingBg) 

    self.m_pSexFemaleBtn = CMButton.new({normal = {radioPath, sexFemaleIcon},
		pressed = {radioPath1, sexFemaleIcon},
		disabled = {radioPath1, sexFemaleIcon}},
		function () self:pressSexFemaleBtn() end,nil,{changeAlpha = true})    
    :align(display.CENTER, posx2, posy) --设置位置 锚点位置和坐标x,y
    :addTo(self.m_pSexSettingBg)  
	if myInfo.data.userSex == "女" then
		self.m_pSexFemaleBtn:setButtonEnabled(false)
	else
		self.m_pSexMaleBtn:setButtonEnabled(false)
	end
    -------------------------------------------------

	local name = cc.ui.UILabel.new({
	        text  = myInfo.data.userName or "",
	        size  = 36,
	        color = cc.c3b(255, 255, 255),
	        --UILabelType = 1,
    		font  = "黑体",
	    })
	name:align(display.CENTER,headBG:getPositionX(),headBG:getPositionY()-headBG:getContentSize().width/2-55)
	node:addChild(name)

	-- local btnSet = CMButton.new({normal = "picdata/personalCenter/btn_set.png",pressed = "picdata/personalCenter/btn_set2.png"},function () self:onMenuCallBack(EnumMenu.eBtnAccount) end)    
 --    :align(display.CENTER, 30,270) --设置位置 锚点位置和坐标x,y
 --    :addTo(node) 

	local bgUid = cc.Sprite:create("picdata/personCenterNew/personCenter/bg_uid.png")
	bgUid:setPosition(headMask:getContentSize().width/2,25)
	headMask:addChild(bgUid)
 	
	 local uid = cc.ui.UILabel.new({
	        text  = "UID:"..myInfo.data.userId,
	        size  = 24,
	        color = cc.c3b(89, 109, 147),
	        --UILabelType = 1,
    		font  = "Arial",
	    })
	uid:align(display.CENTER, bgUid:getPositionX(),bgUid:getPositionY())
	headMask:addChild(uid)

	local bgVip = cc.Sprite:create("picdata/personCenterNew/personCenter/bg_list.png")
	bgVip:setPosition(headBG:getPositionX(),name:getPositionY()-60)
	node:addChild(bgVip)

 --    local vip = cc.Sprite:create(string.format("picdata/public/vip/vip%d_pc.png",myInfo.data.vipLevel))
	-- vip:setPosition(44,bgVip:getContentSize().height/2)
	-- bgVip:addChild(vip)

	local vip = cc.ui.UILabel.new({
	        UILabelType = 1,
	        text  = "VIP"..myInfo.data.vipLevel,
	        font  = "fonts/font_vip.fnt",
	        size  = 28,
	        align = cc.ui.TEXT_ALIGN_CENTER,
	    })
    vip:setAnchorPoint(cc.p(0.5, 0.5))
    vip:setPosition(44,bgVip:getContentSize().height/2+4)
	bgVip:addChild(vip,1,102)

	CMButton.new({normal = "picdata/public_new/btn_q.png",
		pressed = "picdata/public_new/btn_q.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnVip) end,nil,{changeAlpha = true})    
    :align(display.CENTER, 204, bgVip:getContentSize().height/2-1) --设置位置 锚点位置和坐标x,y
    :addTo(bgVip) 
	local bgLevel = cc.Sprite:create("picdata/personCenterNew/personCenter/bg_list.png")
	bgLevel:setPosition(headBG:getPositionX(),bgVip:getPositionY()-50)
	node:addChild(bgLevel)

 --    local level = cc.Sprite:create(string.format("picdata/public/level/lv%d.png",myInfo.data.userLevel))
	-- level:setPosition(44,bgVip:getContentSize().height/2)
	-- bgLevel:addChild(level)

	local level = cc.ui.UILabel.new({
	        UILabelType = 1,
	        text  = "Lv."..myInfo.data.userLevel,
	        font  = "fonts/font_lv.fnt",
	        size  = 28,
	        align = cc.ui.TEXT_ALIGN_CENTER,
	    })
    level:setAnchorPoint(cc.p(0.5, 0.5))
    level:setPosition(44,bgVip:getContentSize().height/2+4)
	bgLevel:addChild(level)

	local levelNum = cc.ui.UILabel.new({
        text  = "("..math.floor(myInfo.data.userExp).."分)",
        size  = 20,
        color = cc.c3b(180, 192, 220),
        --UILabelType = 1,
		font  = "黑体",
		align = cc.TEXT_ALIGNMENT_LEFT,
    })
	levelNum:align(display.LEFT_CENTER,72+2,bgVip:getContentSize().height/2+2)
	bgLevel:addChild(levelNum)

	local btnHelp = CMButton.new({normal = "picdata/public_new/btn_q.png",pressed = "picdata/public_new/btn_q.png"},function () self:onMenuCallBack(EnumMenu.eBtnLevel) end,nil,{changeAlpha = true})     
	    :align(display.CENTER, 204, bgVip:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
	    :addTo(bgLevel) 
	if DBChannel ~= "10866" then --部分联运渠道去除登出功能
		local logoutBtn = CMButton.new({
			normal = {"picdata/public_new/btn_blue.png", "picdata/personCenterNew/personCenter/w_qhzh.png"},
	        pressed = {"picdata/public_new/btn_blue_p.png", "picdata/personCenterNew/personCenter/w_qhzh.png"}},
	        function () require("app.GUI.setting.MoreMainLayer"):new():onMenuLogout() end,nil,{changeAlpha = true}) 
	    logoutBtn:setPosition(headBG:getPositionX(), bgVip:getPositionY()-120)
	    node:addChild(logoutBtn)
	end
	local iconPath1   = "picdata/public_new/icon_jb.png"
	local iconPath2   = "picdata/public_new/icon_jf.png"
	local iconPath3   = "picdata/public_new/icon_zs.png"
	local czPath 	= "picdata/personCenterNew/personCenter/btn_buy.png"
	local czPath2 	= "picdata/personCenterNew/personCenter/btn_buy.png"
	local posx = self.mBg:getContentSize().width/3+60-20
	local posy = self.mBg:getContentSize().height-115
	local sGoldNum = myInfo.data.totalChips
	for i = 1,3 do 
		local iconPath = iconPath1
		if i == 2 then
			posy = posy-60
			sGoldNum = myInfo.data.diamondBalance
			iconPath = iconPath2
		elseif i==3 then
			posx = posx+260
			sGoldNum = myInfo.data.userDebaoDiamond
			iconPath = iconPath3
		end
		local icon = cc.Sprite:create(iconPath)
		icon:setPosition(posx,posy)
		node:addChild(icon)

		local num = cc.ui.UILabel.new({
	        text  = math.ceil(sGoldNum),
	        size  = 26,
	        color = cc.c3b(255, 255, 255),
	        --UILabelType = 1,
    		font  = "Arial",
	    })
		num:setPosition(icon:getPositionX()+20,icon:getPositionY())
		node:addChild(num)

		if i==1 then
			local btnJump = CMButton.new({normal = czPath,pressed = czPath2},function () self:onMenuCallBack(EnumMenu.eBtnShop) end,nil,{changeAlpha = true})    
		    :align(display.CENTER, num:getPositionX()+num:getContentSize().width+60,posy) --设置位置 锚点位置和坐标x,y
		    :addTo(node) 
		    if GIOSCHECK then
		    	btnJump:setVisible(false)
		    end
		end

	end
end

function PersonCenterLayer:pressUserSexBtn()
	if self.m_pSexSettingNode:isVisible() then
		self.m_pSexSettingNode:setVisible(false)
		return
	end
	self.m_pSexSettingNode:setVisible(true)
end

function PersonCenterLayer:pressSexFemaleBtn()
	self.m_pSexFemaleBtn:setButtonEnabled(false)
	self.m_pSexMaleBtn:setButtonEnabled(true)
	HttpClient:setUserSex(handler(self, self.setUserSexCallback), "女")
end

function PersonCenterLayer:pressSexMaleBtn()
	self.m_pSexFemaleBtn:setButtonEnabled(true)
	self.m_pSexMaleBtn:setButtonEnabled(false)
	HttpClient:setUserSex(handler(self, self.setUserSexCallback), "男")
end

function PersonCenterLayer:setUserSexCallback(tableData, tag)

	if tableData then
		local sex = myInfo.data.userSex
		myInfo.data.userSex = "女"
		if sex == "女" then
			myInfo.data.userSex = "男"
		end
	end

	local manPath   = "picdata/personCenterNew/personCenter/sex_btn_m.png"
	local womenPath = "picdata/personCenterNew/personCenter/sex_btn_f.png"
    local manPath   = manPath
	if myInfo.data.userSex == "女" then
		manPath  = womenPath
		self.m_pSexFemaleBtn:setButtonEnabled(false)
		self.m_pSexMaleBtn:setButtonEnabled(true)
	else
		self.m_pSexFemaleBtn:setButtonEnabled(true)
		self.m_pSexMaleBtn:setButtonEnabled(false)
	end
	self.m_pUserSexBtn:setButtonImage("normal", manPath)
	self.m_pUserSexBtn:setButtonImage("pressed", manPath)
end

function PersonCenterLayer:createBottomUI()
	local node = cc.Node:create()

	-- local title = cc.Sprite:create("picdata/personalCenter/title_sj_psbg.png")
	-- title:setPosition(self.mBg:getContentSize().width/2,313)
	-- node:addChild(title)

	-- local btnDetail = CMButton.new({normal = "picdata/personalCenter/btn_xx.png",pressed = "picdata/personalCenter/btn_xx2.png"},function () self:onMenuCallBack(EnumMenu.eBtnDetail) end)    
 --    :align(display.CENTER, 785,315) --设置位置 锚点位置和坐标x,y
 --    :addTo(node) 

	local text = {"今日盈利","胜    率","今日局数","总牌局数","最佳牌型"} 
	local posx1 = self.mBg:getContentSize().width/3+45-20
	local posx2 = posx1+260
	local posy1 = self.mBg:getContentSize().height-233-25+15
	local posy2 = posy1-60+6
	local posy3 = posy2-60+6
	local pos  = {
		[1] = cc.p(posx1,posy1),
		[2] = cc.p(posx2,posy1),
		[3] = cc.p(posx1,posy2),
		[4] = cc.p(posx2,posy2),
		[5] = cc.p(posx1,posy3),}
		-- self.mBg:getContentSize().width/2-115+50
	local posx = 0
	local posy = 0
	for i = 1 ,#text do
		posx = pos[i].x
		posy = pos[i].y 
		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i]..":",
		        size  = 26,
		        color = cc.c3b(115,131,163),
		        --UILabelType = 1,
		        font  = "黑体",
	    		
		    })
		sDetail:setPosition(posx,posy)
		node:addChild(sDetail)
		if i ~= #text then
			local perNum = cc.ui.UILabel.new({
			        text  =  "",
			        size  = 26,
			        color = cc.c3b(255,255,255),
			        --UILabelType = 1,
		    		font  = "Arial",
			    })
			perNum:setPosition(posx + sDetail:getContentSize().width +  5,posy)
			node:addChild(perNum,0,100+i)
		end

	end

	local btnWP = "picdata/personCenterNew/personCenter/btn_wdwp.png"
	local btnWP1 = "picdata/personCenterNew/personCenter/btn_wdwp2.png"
	local btnPJ = "picdata/personCenterNew/personCenter/btn_pjsc.png"
	local btnPJ1 = "picdata/personCenterNew/personCenter/btn_pjsc2.png"
	local btnDB = "picdata/personCenterNew/personCenter/icon_tab_pyj.png"
	local btnDB1 = "picdata/personCenterNew/personCenter/icon_tab_pyj.png"

	local textPJSC = "picdata/personalCenter/w_title_pjsc.png"
	local textWDWP = "picdata/personalCenter/w_title_wdwp.png"

	local btn_image = {
		{normal="picdata/personCenterNew/personCenter/icon_tab_pfbg.png", pressed="picdata/personCenterNew/personCenter/icon_tab_pfbg.png"},
		{normal="picdata/personCenterNew/personCenter/icon_tab_wdwp.png", pressed="picdata/personCenterNew/personCenter/icon_tab_wdwp.png"},
		{normal="picdata/personCenterNew/personCenter/icon_tab_pyj.png", pressed="picdata/personCenterNew/personCenter/icon_tab_pyj.png"},
		{normal="picdata/personCenterNew/personCenter/icon_tab_pjsc.png", pressed="picdata/personCenterNew/personCenter/icon_tab_pjsc.png"},
		{normal="picdata/personCenterNew/personCenter/icon_tab_aqzx.png", pressed="picdata/personCenterNew/personCenter/icon_tab_aqzx.png"},
	}

	local btn_text = {
		"牌手报告",
		"我的物品",
		"朋友局",
		"牌局收藏",
		"安全中心",
	}
	local btn_callback_tag = {
		EnumMenu.eBtnDetail,
		EnumMenu.eBtnMyPacket,
		EnumMenu.eBtnDeBaoJu,
		EnumMenu.eBtnPaiJu,
		EnumMenu.eBtnSecurity
	}

	local startX = self.mBg:getContentSize().width/3+72
	local padding = 116
	local posY = 120

	for i=1,#btn_image do
		CMButton.new(btn_image[i],function () self:onMenuCallBack(btn_callback_tag[i]) end,{scale9 = false},{changeAlpha = true})    
			:align(display.CENTER, startX+(i-1)*padding,posY) --设置位置 锚点位置和坐标x,y
			:addTo(self.mBg)

		local btnTitle = cc.ui.UILabel.new({
		        text  =  btn_text[i],
		        size  = 20,
		        color = cc.c3b(180,192,220),
		        --UILabelType = 1,
	    		font  = "黑体",
		    })
		btnTitle:align(display.CENTER,startX+(i-1)*padding,posY-70)
		self.mBg:addChild(btnTitle)
	end
    return node

end

function PersonCenterLayer:addCard(cardData)
	local node = cc.Node:create()
    local data = string.split(cardData,",")
    if #data < 5 then return node end
    
	local colorStr = {[0] = "s",[1] = "h",[2] = "c",[3] = "d"}
	--local str = "8s"
	local posx = 0
	for i = 1,#data do
		local num   = string.sub(data[i],1,1)
		local color = string.sub(data[i],2,2)
		local path = ""
		for i,v in pairs(colorStr) do 
			if v == color then
				if num == "T" then num = 10 end
				path = string.format("picdata/db_poker/%s_%s.png",i,num)
				break
			end
		end
		local card = cc.Sprite:create(path)
		card:setScale(0.5)
		card:setPosition(posx,0)
		node:addChild(card)
		posx = posx + card:getBoundingBox().width + 2
	end
	return node
end
function PersonCenterLayer:updateBottomNodeData(tableData)
	self.mPageNode["bottomNode"]:getChildByTag(101):setString(CMFormatNum(tableData[WIN_CHIPS]))
	self.mPageNode["bottomNode"]:getChildByTag(102):setString(string.format("%s%%",100*tonumber(tableData[STAT_KEY_AF][STAT_KEY_VALUE])))
	self.mPageNode["bottomNode"]:getChildByTag(103):setString(CMFormatNum(tableData[HANDS_NUM]))
	self.mPageNode["bottomNode"]:getChildByTag(104):setString(CMFormatNum(tableData[STAT_KEY_HANDS][STAT_KEY_VALUE]))

	local node = self:addCard(tableData[MAX_CARD])
	node:setPosition(462,225+8)
	self.mPageNode["bottomNode"]:addChild(node)
end


function PersonCenterLayer:buttonClick(event,sender)
    -- @TODO: all sprite click func
    local tag = sender:getTag()
    local state = CMSpriteButton:new(event,{sprite = sender,callback = function ()  self:onMenuCallBack(EnumMenu.eBtnHead) end,scale = false,})
    return state
   
end

function PersonCenterLayer:onMenuCallBack(tag)
	local posx = 168
	if tag == EnumMenu.eBtnHead then
		local selectIdx = 2 
		local RewardLayer = require("app.Component.CMCommonLayer").new({
			-- titlePath = "picdata/personCenterNew/headEdit/w_title_xgtx.png",
			titlePath = "修改头像",
			titleFont = "fonts/title.fnt",
			titleOffY = -40,
			bgType = 3,
			selectIdx = selectIdx,
			mAtivityName = {"帐户信息","修改头像"},
			isFullScreen = true,
			})
		RewardLayer = CMOpen(RewardLayer, self,0,0)
	elseif tag == EnumMenu.eBtnAccount then
		local RewardLayer = require("app.Component.CMCommonLayer").new({
			titlePath = "picdata/personalCenter/w_title_zhxx.png",
			titleOffY = -40,
			bgType = 3,
			selectIdx = selectIdx,
			mAtivityName = {"帐户信息","修改头像"}})
		RewardLayer = CMOpen(RewardLayer, self,0,0)
	elseif tag == EnumMenu.eBtnSecurity then
		local selectIdx = 1 
		local RewardLayer = require("app.Component.CMCommonLayer").new({
			-- titlePath = "picdata/personCenterNew/securityCenter/w_title_aqzx.png",
			titlePath = "安全中心",
			titleFont = "fonts/title.fnt",
			titleOffY = -40,
			-- bgType = 3,
			selectIdx = selectIdx,
			mAtivityName = {"帐户信息"},
			isFullScreen = true,})
		RewardLayer = CMOpen(RewardLayer, self,0,0)
	elseif tag == EnumMenu.eBtnVip  then
		local RewardLayer = require("app.GUI.setting.MoreVersionLayer")
		CMOpen(RewardLayer, self)
	elseif tag == EnumMenu.eBtnLevel then
		local data = {}
		data.url = "http://cache.debao.com/level3.html?"
		QManagerPlatform:jumpToWebView(data)
	elseif tag == EnumMenu.eBtnShop  then
		local RewardLayer = require("app.GUI.recharge.ShopGoldLayer")
		CMOpen(RewardLayer, self)
	elseif tag == EnumMenu.eBtnPaiJu  then
		local RewardLayer = require("app.GUI.personCenter.MyBoardLayer")
		CMOpen(RewardLayer, self,0,0)
	elseif tag == EnumMenu.eBtnMyPacket  then
		--local RewardLayer = require("app.GUI.personCenter.MyPacketLayer")
		local RewardLayer = require("app.Component.CMCommonLayer").new({
			-- titlePath = "picdata/personCenterNew/myPacket/w_title_wdwp.png",
			titlePath = "我的物品",
			titleFont = "fonts/title.fnt",
			activityNameFont = true,
			titleOffY = -40,
			-- bgType = 3,
			selectIdx = 1,
			mAtivityName = {"门票","道具","月卡"},
			isFullScreen = true,
			})
		CMOpen(RewardLayer, self,0,0)
	elseif tag == EnumMenu.eBtnDataExPlain then
		local RewardLayer = require("app.GUI.personCenter.DataExplainLayer")
		CMOpen(RewardLayer, self)
	elseif tag == EnumMenu.eBtnExcharge then
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.EXCHARGE,self)
	elseif tag == EnumMenu.eBtnShop then
		GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self)
	elseif tag == EnumMenu.eBtnDetail then
		local RewardLayer = require("app.Component.CMCommonLayer").new({
			-- titlePath = "picdata/personCenterNew/personData/w_title_psbg.png",
			titlePath = "牌手报告",
			titleFont = "fonts/title.fnt",
			activityNameFont = true, 
			titleOffY = -40,
			-- bgType = 3,
			selectIdx = 1,
			mAtivityName = {
			"自由场",
			"锦标赛",
			-- "数据分析",
			"盲注级别明细"
			},
			isFullScreen = true,})
		CMOpen(RewardLayer, self,0,0)
	elseif tag == EnumMenu.eBtnDeBaoJu then
		local RewardLayer = require("app.GUI.personCenter.MyMatchLayer")
		CMOpen(RewardLayer, self,0,0)
	end
end
function PersonCenterLayer:updateCallBack(data)
  self:updateHeadPic(data)
end
function PersonCenterLayer:updateHeadPic(data)
	self.mHeadPic:changeHead(data.fileName) 
	self:getParent():updateHeadPic(data.fileName)
end
--[[
	网络回调
]]
function PersonCenterLayer:httpResponse(tableData,tag)
	--dump(tableData,tag)
	if tag == POST_COMMAND_HUDFORMOBILE  then
		self:updateBottomNodeData(tableData)
		--self:updateData(tableData)
	elseif tag == POST_COMMAND_getUserMatchData then
		--self:updateMidNodeData(tableData)
	end
	
end
return PersonCenterLayer