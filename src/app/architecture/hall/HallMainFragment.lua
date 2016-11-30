local bgWidth = 0
local bgHeight = 0
local HallMainContract = require("app.architecture.hall.HallMainContract")

local HallMainFragment = class("HallMainFragment", function()
		return HallMainContract.View:new()
	end)

function HallMainFragment:ctor()
    self:setNodeEventEnabled(true)
end

function HallMainFragment:onExit()
    self.m_pPresenter:onExit()
end

function HallMainFragment:onEnterTransitionFinish()
end

function HallMainFragment:create()
	self:initUI()
end

function HallMainFragment:initUI()
    self.m_pBg = cc.ui.UIImage.new("picdata/background/bg2.jpg")
    self.m_pBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self)
    bgWidth = self.m_pBg:getContentSize().width
    bgHeight = self.m_pBg:getContentSize().height

    								--[[创建中间UI]]
	-----------------------------------------------------------------------------------
    local btnWidth = 502*SCALE_FACTOR
    local btnHeight = 398*SCALE_FACTOR
    local imgWidth = 226*SCALE_FACTOR
    local totalWidth = btnWidth*2+imgWidth

    self.m_pBtnCreateRoom = CMButton.new({normal = {"picdata/hall/main/btn_create_room.png"},
        pressed = {"picdata/hall/main/btn_create_room.png"}},
        function () self:createRoom() end, nil, {changeAlpha = true})
    self.m_pBtnCreateRoom:setPosition(bgWidth/2-imgWidth/2, bgHeight/2)
    self.m_pBg:addChild(self.m_pBtnCreateRoom,1)
    self.m_pBtnCreateRoom:setScale(SCALE_FACTOR)

    self.m_pBtnJoinRoom = CMButton.new({normal = {"picdata/hall/main/btn_join_room.png"},
        pressed = {"picdata/hall/main/btn_join_room.png"}},
        function () self:joinRoom() end, nil, {changeAlpha = true})
    self.m_pBtnJoinRoom:setPosition(self.m_pBtnCreateRoom:getPositionX()+btnWidth, 
    	self.m_pBtnCreateRoom:getPositionY()-15)
    self.m_pBg:addChild(self.m_pBtnJoinRoom,1)
    self.m_pBtnJoinRoom:setScale(SCALE_FACTOR)

    local imgAnnounce = cc.ui.UIImage.new("picdata/hall/main/img_announce.png")
    	:align(display.CENTER, self.m_pBtnCreateRoom:getPositionX()-btnWidth/2-imgWidth/2-10, 
    		self.m_pBtnCreateRoom:getPositionY())
    	:addTo(self.m_pBg)
    imgAnnounce:setScale(SCALE_FACTOR)

    self.m_pBtnCreateRoom2 = CMButton.new({normal = {"picdata/hall/main/btn_create_room2.png"},
        pressed = {"picdata/hall/main/btn_create_room2.png"}},
        function () self:createRoom() end, nil, {changeAlpha = true})
    self.m_pBtnCreateRoom2:setPosition(self.m_pBtnCreateRoom:getPositionX(), 
    	self.m_pBtnCreateRoom:getPositionY()-btnHeight/2+20)
    self.m_pBg:addChild(self.m_pBtnCreateRoom2,1)
    self.m_pBtnCreateRoom2:setScale(SCALE_FACTOR)

    self.m_pBtnJoinRoom2 = CMButton.new({normal = {"picdata/hall/main/btn_join_room2.png"},
        pressed = {"picdata/hall/main/btn_join_room2.png"}},
        function () self:joinRoom() end, nil, {changeAlpha = true})
    self.m_pBtnJoinRoom2:setPosition(self.m_pBtnJoinRoom:getPositionX(), 
    	self.m_pBtnJoinRoom:getPositionY()-btnHeight/2+15+20)
    self.m_pBg:addChild(self.m_pBtnJoinRoom2,1)
    self.m_pBtnJoinRoom2:setScale(SCALE_FACTOR)
	-----------------------------------------------------------------------------------
    								--[[创建顶部左侧UI-头像]]
	-----------------------------------------------------------------------------------
	local headImageMask = cc.ui.UIImage.new("picdata/public/img_square4.png")
    headImageMask:align(display.CENTER, headImageMask:getContentSize().width/2+10, 
    	CONFIG_SCREEN_HEIGHT-headImageMask:getContentSize().height/2-10)
    	:addTo(self, 1)
    -- headImageMask:setScale(SCALE_FACTOR)

    if not QDataPlayer then
		require("app.architecture.QDataPlayer")
    end
    if not QDataPlayer.data.userPotraitUri then
		math.randomseed(socket.gettime()*1000)
	    local randomValue = math.random(12)
	    QDataPlayer.data.userPotraitUri = "picdata/portrait/portrait"..randomValue..".png"
	end
	self.m_pHeadImage = cc.ui.UIImage.new(QDataPlayer.data.userPotraitUri)
    	:align(display.CENTER, headImageMask:getPositionX(), headImageMask:getPositionY())
    	:addTo(self)
    self.m_pHeadImage:setScale(90/self.m_pHeadImage:getContentSize().width)

    self.m_pUserName = cc.ui.UILabel.new({
        color = cc.c3b(236, 189, 53),
        text  = QDataPlayer.data.userName or "游客",
        size  = 26,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_LEFT
        })
    self.m_pUserName:align(display.LEFT_CENTER, 
    	headImageMask:getPositionX()+headImageMask:getContentSize().width/2+10, 
    	headImageMask:getPositionY()+headImageMask:getContentSize().height/2-20)
    self:addChild(self.m_pUserName)

    self.m_pUserId = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = QDataPlayer.data.userId and "ID:"..QDataPlayer.data.userId or "ID:1000",
        size  = 20,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_LEFT
        })
    self.m_pUserId:align(display.LEFT_CENTER, 
    	self.m_pUserName:getPositionX(), 
    	self.m_pUserName:getPositionY()-30)
    self:addChild(self.m_pUserId)

    local roomCardBg = cc.ui.UIImage.new("picdata/hall/main/img_room_card_bg.png")
    	:align(display.LEFT_CENTER, self.m_pUserName:getPositionX(),
    	self.m_pUserId:getPositionY()-30)
    	:addTo(self)
    roomCardBg:setScale(SCALE_FACTOR)
    roomCardBg:setScaleX(150/roomCardBg:getContentSize().width)
    local roomCard = cc.ui.UIImage.new("picdata/hall/main/img_room_card.png")
    	:align(display.LEFT_CENTER, roomCardBg:getPositionX()+4,
    		roomCardBg:getPositionY())
    	:addTo(self)
    roomCard:setScale(SCALE_FACTOR)

    self.m_pBtnAddCard = CMButton.new({normal = {"picdata/hall/main/btn_add.png"},
        pressed = {"picdata/hall/main/btn_add.png"}},
        function () self:toAddCard() end, nil, {changeAlpha = true})
    self.m_pBtnAddCard:setPosition(roomCardBg:getPositionX()+roomCardBg:getContentSize().width-112, 
    	roomCardBg:getPositionY())
    self:addChild(self.m_pBtnAddCard)

    self.m_pRoomCard = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = QDataPlayer.data.roomCardNum and tostring(QDataPlayer.data.roomCardNum) or "1000",
        size  = 20,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_RIGHT
        })
    self.m_pRoomCard:align(display.RIGHT_CENTER, 
    	self.m_pBtnAddCard:getPositionX()-28, 
    	roomCardBg:getPositionY())
    self:addChild(self.m_pRoomCard)

	-----------------------------------------------------------------------------------

    								--[[创建顶部右侧UI]]
	-----------------------------------------------------------------------------------
    local title = cc.ui.UIImage.new("picdata/hall/main/title.png")
    	:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT-40)
    	:addTo(self)
    local topBtnPadding = 60
    self.m_pBtnSetting = CMButton.new({normal = {"picdata/hall/main/btn_setting.png"},
        pressed = {"picdata/hall/main/btn_setting.png"}},
        function () self:toSetting() end, nil, {changeAlpha = true})
    self.m_pBtnSetting:setPosition(CONFIG_SCREEN_WIDTH-topBtnPadding, 
    	title:getPositionY())
    self:addChild(self.m_pBtnSetting)
    self.m_pBtnSetting:setScale(SCALE_FACTOR)

    self.m_pBtnHelp = CMButton.new({normal = {"picdata/hall/main/btn_help.png"},
        pressed = {"picdata/hall/main/btn_help.png"}},
        function () self:toHelp() end, nil, {changeAlpha = true})
    self.m_pBtnHelp:setPosition(self.m_pBtnSetting:getPositionX()-topBtnPadding, 
    	self.m_pBtnSetting:getPositionY())
    self:addChild(self.m_pBtnHelp)
    self.m_pBtnHelp:setScale(SCALE_FACTOR)

    self.m_pBtnMessage = CMButton.new({normal = {"picdata/hall/main/btn_message.png"},
        pressed = {"picdata/hall/main/btn_message.png"}},
        function () self:toMessage() end, nil, {changeAlpha = true})
    self.m_pBtnMessage:setPosition(self.m_pBtnHelp:getPositionX()-topBtnPadding, 
    	self.m_pBtnSetting:getPositionY())
    self:addChild(self.m_pBtnMessage)
    self.m_pBtnMessage:setScale(SCALE_FACTOR)
	-----------------------------------------------------------------------------------
    								--[[创建公告UI]]
	-----------------------------------------------------------------------------------
    --[[创建背景]]
    local announceBg = cc.ui.UIImage.new("picdata/hall/main/img_rect2.png")
    	:align(display.CENTER, bgWidth/2, bgHeight-160)
    	:addTo(self.m_pBg)
  
    cc.ui.UIImage.new("picdata/hall/main/img_announce2.png")
    	:align(display.CENTER, announceBg:getPositionX()-announceBg:getContentSize().width/2+10, 
    		announceBg:getPositionY())
    	:addTo(self.m_pBg)


    self.clippingNode = cc.ClippingNode:create()
    -- self.clippingNode:setInverted(true)        --倒置显示，未被裁剪下来的剩余部分
    self.clippingNode:setAlphaThreshold(0.5)  --设置alpha透明度闸值
    self.m_pBg:addChild(self.clippingNode)
    self.clippingNode:setPosition(bgWidth/2, bgHeight-160)
    local stencil = cc.Node:create()
    self.clippingNode:setStencil(stencil)
    local stencilChild = cc.Sprite:create("picdata/hall/main/img_rect3.png")
    stencil:addChild(stencilChild)
    stencil:setAnchorPoint(cc.p(0.5,0.5))

    local announceLabelStartPosX = bgWidth*3/2
    -- local announceLabelEndPosX = 0
    local announceLabel = cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = "今日有不法分子冒充本产品进行销售诈骗，希望大家小心提防，本团队的唯一联系方式386476890@qq.com。本游戏中的美术资源，均来自网络。本品为本团队的测试产品，如需业务合作，请联系qq:386476890",
        size  = 26,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_CENTER
        })
    -- announceLabel:align(display.CENTER, announceLabelStartPosX, bgHeight-130)
    announceLabel:align(display.CENTER, announceLabelStartPosX, 0)
    -- announceLabel:align(display.CENTER, bgWidth/2, bgHeight-130)
    self.clippingNode:addChild(announceLabel)

    transition.execute(announceLabel, cc.RepeatForever:create(
    		cc.Sequence:create({
    				cc.MoveTo:create(30.0, cc.p(-bgWidth*3/2, announceLabel:getPositionY())),
    				cc.CallFunc:create(function() announceLabel:setPositionX(announceLabelStartPosX) end),
    				nil
    			})
    	)) 
	-----------------------------------------------------------------------------------
    								--[[创建底部UI]]
	-----------------------------------------------------------------------------------
	local bottomBtnPadding = 200
	local bottomBg = cc.ui.UIImage.new("picdata/hall/main/img_bottom_bg.png")
    bottomBg:align(display.CENTER_BOTTOM, CONFIG_SCREEN_WIDTH/2, 0)
    	:addTo(self)
    bottomBg:setScale(SCALE_FACTOR)

    self.m_pBtnShare = CMButton.new({normal = {"picdata/hall/main/btn_share.png"},
        pressed = {"picdata/hall/main/btn_share.png"}},
        function () self:toShare() end, nil, {changeAlpha = true})
    self.m_pBtnShare:setPosition(bottomBg:getContentSize().width/2, 
    	bottomBg:getContentSize().height)
    bottomBg:addChild(self.m_pBtnShare)
    self.m_pBtnShare:setScale(SCALE_FACTOR)

    self.m_pBtnRecord = CMButton.new({normal = {"picdata/hall/main/btn_record.png"},
        pressed = {"picdata/hall/main/btn_record.png"}},
        function () self:toRecord() end, nil, {changeAlpha = true})
    self.m_pBtnRecord:setPosition(self.m_pBtnShare:getPositionX()-bottomBtnPadding, 
    	self.m_pBtnShare:getPositionY())
    bottomBg:addChild(self.m_pBtnRecord)
    self.m_pBtnRecord:setScale(SCALE_FACTOR)

    self.m_pBtnFeedback = CMButton.new({normal = {"picdata/hall/main/btn_feedback.png"},
        pressed = {"picdata/hall/main/btn_feedback.png"}},
        function () self:toFeedback() end, nil, {changeAlpha = true})
    self.m_pBtnFeedback:setPosition(self.m_pBtnShare:getPositionX()+bottomBtnPadding, 
    	self.m_pBtnShare:getPositionY())
    bottomBg:addChild(self.m_pBtnFeedback)
    self.m_pBtnFeedback:setScale(SCALE_FACTOR)
	-----------------------------------------------------------------------------------
end

function HallMainFragment:createRoom()
	-- CMOpen(require("app.architecture.components.CommonFragment"), self)
	-- local layer = require("app.architecture.components.CommonFragment"):new()
	-- layer:create()
	-- self:addChild(layer, 10, 10)
end

function HallMainFragment:joinRoom()
	
end

function HallMainFragment:toShare()
	local url = ""
	url = "https://wangjun-jaelyn.github.io/"
	local data       = {title = "麻麻好开心",content = "我在#你麻我麻#游戏中玩的很开心,小伙伴们快来一起玩牌吧~~~",nType = 1,url = url}
	QManagerPlatform:shareToWeChat(data)
end

function HallMainFragment:toRecord()
	CMOpen(require("app.architecture.hall.HallRecordFragment"), self, {
		title = "VIP战绩",
		}, true)
end

function HallMainFragment:toFeedback()
	CMOpen(require("app.architecture.hall.HallFeedbackFragment"), self, {
		title = "反馈",
		}, true)
end

function HallMainFragment:toSetting()
	CMOpen(require("app.architecture.hall.HallSettingFragment"), self, {
		title = "设置",
		viewType = 1
		}, true)
end

function HallMainFragment:toHelp()
	CMOpen(require("app.architecture.hall.HallHelpFragment"), self, {
		title = "帮助",
		}, true)
end

function HallMainFragment:toMessage()
	CMOpen(require("app.architecture.hall.HallMessageFragment"), self, {
		title = "消息",
		}, true)
	
end

function HallMainFragment:toAddCard()
	CMOpen(require("app.architecture.hall.HallAddCardFragment"), self, {
		viewType = 1,
		title = "购买房卡"}, true)
end


return HallMainFragment