local bgWidth = 0
local bgHeight = 0
local BaseView = require("app.architecture.BaseView")
local scheduler = require("framework.scheduler")
if not SCALE_FACTOR then 
    require("app.architecture.global.GlobalConfig")
end
if not QDataPlayer then
    require("app.architecture.QDataPlayer")
end

local RoomFragment = class("RoomFragment", function()
		return BaseView:new()
	end)

function RoomFragment:ctor()
    self:setNodeEventEnabled(true)
    self.m_nTotalSeat = 4
end

function RoomFragment:onExit()
    self.m_pPresenter:onExit()
end

function RoomFragment:onEnterTransitionFinish()
end

function RoomFragment:create()
	self:initUI()
end

function RoomFragment:initUI()
    bgWidth = CONFIG_SCREEN_WIDTH
    bgHeight = CONFIG_SCREEN_HEIGHT
	self.m_pTableBg = cc.ui.UIImage.new("picdata/background/mahjong_table.jpg")
    self.m_pTableBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self)
    self.m_pTableBg:setScaleX(bgWidth/self.m_pTableBg:getContentSize().width)
    self.m_pTableBg:setScaleY(bgHeight/self.m_pTableBg:getContentSize().height)

    self.m_pBg = display.newNode()
    self.m_pBg:addTo(self)

    cc.ui.UIImage.new("picdata/room/play_scene/img_direction.png")
    	:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self.m_pBg, kZOrderBackground)

    self.m_pBtnInviteFreind = CMButton.new({normal = {"picdata/room/play_scene/btn_invite.png"},
        pressed = {"picdata/room/play_scene/btn_invite.png"}},
        function () self:inviteFreind() end, nil, {changeAlpha = true})
    self.m_pBtnInviteFreind:setPosition(bgWidth/2, bgHeight/2)
    self.m_pBg:addChild(self.m_pBtnInviteFreind, kZOrderMenu)
    self.m_pBtnInviteFreind:setVisible(false)

    self.m_pWaitMenu = display.newNode()
    self.m_pWaitMenu:addTo(self, kZOrderMenu)
    -- self.m_pWaitMenu:setVisible(false)

    self.m_pBtnDismiss = CMButton.new({normal = {"picdata/room/play_scene/btn_dismiss.png"},
        pressed = {"picdata/room/play_scene/btn_dismiss.png"}},
        function () self:dismiss() end, nil, {changeAlpha = true})
    self.m_pBtnDismiss:setPosition(bgWidth-129, 
    	60)
    self.m_pWaitMenu:addChild(self.m_pBtnDismiss)

    self.m_pBtnBack = CMButton.new({normal = {"picdata/room/play_scene/btn_back.png"},
        pressed = {"picdata/room/play_scene/btn_back.png"}},
        function () self:back() end, nil, {changeAlpha = true})
    self.m_pBtnBack:setPosition(bgWidth-129, 
    	135)
    self.m_pWaitMenu:addChild(self.m_pBtnBack)

    local menuBg = cc.ui.UIImage.new("picdata/room/play_scene/img_slice.png")
    	:align(display.CENTER, bgWidth-53, bgHeight-102)
    	:addTo(self.m_pBg, kZOrderMenu)

    self.m_pBtnSetting = CMButton.new({normal = {"picdata/room/play_scene/btn_setting.png"},
        pressed = {"picdata/room/play_scene/btn_setting.png"}},
        function () self:toSetting() end, nil, {changeAlpha = true})
    self.m_pBtnSetting:setPosition(menuBg:getContentSize().width/2+4, 
    	menuBg:getContentSize().height*3/4)
    menuBg:addChild(self.m_pBtnSetting)
    -- self.m_pBtnSetting:setScale(SCALE_FACTOR)

    self.m_pBtnChat = CMButton.new({normal = {"picdata/room/play_scene/btn_chat.png"},
        pressed = {"picdata/room/play_scene/btn_chat.png"}},
        function () self:toChat() end, nil, {changeAlpha = true})
    self.m_pBtnChat:setPosition(menuBg:getContentSize().width/2+4, 
    	menuBg:getContentSize().height/4)
    menuBg:addChild(self.m_pBtnChat)
    
    self.m_pRoomInfo = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = "4局 6个鸟 自摸",
        size  = 20,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_LEFT
        })
    self.m_pRoomInfo:align(display.LEFT_CENTER, 
    	20, 
    	bgHeight-40)
    self.m_pBg:addChild(self.m_pRoomInfo, kZOrderInfoHint)

	--[[time]]
	self.m_tTimeLabel = cc.Label:createWithSystemFont("17:53", "Arial", 18)
	self.m_tTimeLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_tTimeLabel:setPosition(cc.p(
    	self.m_pRoomInfo:getPositionX(), 
    	self.m_pRoomInfo:getPositionY()-40))
	self.m_tTimeLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.m_tTimeLabel:setColor(cc.c3b(245, 222, 0))
	self.m_pBg:addChild(self.m_tTimeLabel, kZOrderInfoHint)
	self:updateTimeLabel(0.0)
	-- [[定时更新]]
	self.timeScheduler = scheduler.scheduleGlobal(handler(self, self.updateTimeLabel), 1)

	self.m_pRoomId = cc.ui.UILabel.new({
        color = cc.c3b(245, 222, 179),
        text  = "房间ID:233332",
        size  = 20,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_LEFT
        })
    self.m_pRoomId:align(display.LEFT_CENTER, 
    	self.m_tTimeLabel:getPositionX(), 
    	self.m_tTimeLabel:getPositionY()-30)
    self.m_pBg:addChild(self.m_pRoomId, kZOrderInfoHint)

    self.m_pPlayersArray = {}
 	--[[初始化玩家放置沙发]]
 	for i=1,self.m_nTotalSeat,1 do
 		local player = require("app.architecture.room.PlayerFragment"):new({
 			seatNum = self.m_nTotalSeat,
 			seatId = i,})
 		player:create()
 		player:addTo(self.m_pBg,kZOrderPlayer)
 		self.m_pPlayersArray[i] = player
 	end
    self.m_pPlayersArray[1]:seat({
            headPic = QDataPlayer.data.userPotraitUri,
            name = QDataPlayer.data.userName,

        })
 	for i=1,13 do
        local index = i
        if i>9 then
            index = index-9
        end
 		 local mahjong = cc.ui.UIImage.new("picdata/mahjong/mahjong"..index.."S.png")
    	:align(display.LEFT_BOTTOM, i*75*SCALE_FACTOR, table_padding_bottom)
    	:addTo(self.m_pBg, kZOrderMahjong)
        mahjong:setScale(SCALE_FACTOR)
 	end

    for i=1,17 do
         local mahjong = cc.ui.UIImage.new("picdata/mahjong/mahjongH.png")
        :align(display.LEFT_BOTTOM, bgWidth/2+(i-9)*20-18, table_padding_bottom+111*SCALE_FACTOR)
        :addTo(self.m_pBg, kZOrderMahjong)
        mahjong:setScale(20/mahjong:getContentSize().width)
    end
    for i=1,17 do
         local mahjong = cc.ui.UIImage.new("picdata/mahjong/mahjongH.png")
        :align(display.LEFT_BOTTOM, bgWidth/2+(i-9)*20-18, bgHeight-table_padding_bottom-111*SCALE_FACTOR)
        :addTo(self.m_pBg, kZOrderMahjong)
        mahjong:setScale(20/mahjong:getContentSize().width)
    end
    for i=1,17 do
         local mahjong = cc.ui.UIImage.new("picdata/mahjong/mahjongLeft.png")
        :align(display.LEFT_BOTTOM, bgWidth/2-8*36-18, bgHeight/2+(i-9)*20-18)
        :addTo(self.m_pBg, kZOrderMahjong)
        mahjong:setScale(20/mahjong:getContentSize().height)
    end
    for i=1,17 do
         local mahjong = cc.ui.UIImage.new("picdata/mahjong/mahjongLeft.png")
        :align(display.LEFT_BOTTOM, bgWidth/2+8*36-18, bgHeight/2+(i-9)*20-18)
        :addTo(self.m_pBg, kZOrderMahjong)
        mahjong:setScale(20/mahjong:getContentSize().height)
    end
end


--[[更新显示当前时间]]
function RoomFragment:updateTimeLabel(dt)
	--获取系统时间并转为当地时间
	local currDate = os.date("%H:%M:%S")
	if self.m_tTimeLabel then
		self.m_tTimeLabel:setString(""..currDate)
	end

	-- local timestampDelta = EStringTime:getTimeStampFromNow(self.destroyTime)
	-- if timestampDelta<26 and timestampDelta>24 then
 --    	self:showCountDown(true, 25, 0, 1, 1)
	-- end 

	-- local isNetAvaible = network.isInternetConnectionAvailable()
	-- local netType = network.getInternetConnectionStatus()
	-- local netTypeString = "no"
	-- if netType == 1 then
	-- 	netTypeString = "wifi"
	-- elseif netType == 2 then
	-- 	netTypeString = "手机网络"
	-- end

	-- if not network.isInternetConnectionAvailable() then
	-- 	local tcpCommandRequest = TcpCommandRequest:shareInstance()
	-- 	if tcpCommandRequest:isConnect() then
	-- 		print(isNetAvaible, "网络状态判断后，关闭网络")
	-- 		CMPrintToScene("网络状态判断后，关闭网络")
	-- 		tcpCommandRequest:closeConnect(false)
	-- 	end
	-- end
end

function RoomFragment:inviteFreind()

end

function RoomFragment:back()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.HallView)
end

function RoomFragment:dismiss()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.HallView)
end

function RoomFragment:toSetting()
    dump("=====>toSetting")
	CMOpen(require("app.architecture.hall.HallSettingFragment"), self, {
		title = "设置",
		viewType = 1,
		btnType = 1
		}, true)
end

function RoomFragment:toChat()

end


return RoomFragment