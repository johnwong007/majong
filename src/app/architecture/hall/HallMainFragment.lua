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

    local title = cc.ui.UIImage.new("picdata/hall/main/title.png")
    	:align(display.CENTER, bgWidth/2, bgHeight-80)
    	:addTo(self.m_pBg)

    local announce
end

function HallMainFragment:createRoom()
	
end

function HallMainFragment:joinRoom()
	
end

return HallMainFragment