local bgWidth = 0
local bgHeight = 0
local BaseView = require("app.architecture.BaseView")
require("app.architecture.room.RoomDefine")

local PlayerFragment = class("PlayerFragment", function()
		return BaseView:new()
	end)

function PlayerFragment:ctor(o, params)
	self.params = params or {}
	self.m_seatNum = self.params.seatNum or 4
	self.m_seatNO = self.params.seatId or 1
    self:setNodeEventEnabled(true)
end

function PlayerFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function PlayerFragment:onEnterTransitionFinish()
end

function PlayerFragment:create()
	self:initUI()
end

function PlayerFragment:initUI()
	self.m_pBg = cc.ui.UIImage.new("picdata/room/play_scene/img_rect.png")
    	:align(display.CENTER, 0, 0)
    	:addTo(self)
    self.m_pBg:setPosition(getSafaLocWith(self.m_seatNum, self.m_seatNO))

    self.m_pNameBg = cc.ui.UIImage.new("picdata/room/play_scene/img_rect2.png")
    	:align(display.CENTER, self.m_pBg:getContentSize().width/2, -2)
    	:addTo(self.m_pBg)
    self.m_pNameBg:setScaleY(0.6)
end

--[[玩家接收的所有操作]]
--坐下
function PlayerFragment:seat(params)
	self.sex = params.sex
	self.headPic = params.headPic
	self.name = params.name
	self.userId = params.userId
	self.isMySelf = params.isMySelf
	self.diamond = params.diamond

	if self.headPic then
		self.m_pUserCell = cc.ui.UIImage.new(self.headPic)
			:align(display.CENTER, self.m_pBg:getContentSize().width/2, self.m_pBg:getContentSize().height/2+5)
			:addTo(self.m_pBg)
    	self.m_pUserCell:setScale((self.m_pBg:getContentSize().width-20)/self.m_pUserCell:getContentSize().width)
		cc.ui.UIImage.new("picdata/room/play_scene/img_rect.png")
	    	:align(display.CENTER, self.m_pBg:getContentSize().width/2, self.m_pBg:getContentSize().height/2)
	    	:addTo(self.m_pBg)
	end
	if self.name then
		self.m_pNameLabel = cc.ui.UILabel.new({
	        color = cc.c3b(245, 222, 179),
	        text  = self.name,
	        size  = 20,
	        font  = "font/FZZCHJW--GB1-0.TTF",
	        align = cc.TEXT_ALIGN_LEFT
	        })
	    self.m_pNameLabel:align(display.CENTER, 
	    	self.m_pNameBg:getContentSize().width/2, 
	    	-4)
	    self.m_pBg:addChild(self.m_pNameLabel)
	end
end
return PlayerFragment