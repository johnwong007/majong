local kMenuPicNormal = {"picdata/gamescene/notShow.png","","","picdata/gamescene/allShow.png", 
	"picdata/gamescene/chooseShow.png"}
local kMenuPicsSelect = {"picdata/gamescene/notShow1.png","","","picdata/gamescene/allShow1.png",
 	"picdata/gamescene/chooseShow1.png"}

local c_showdown_1 = "不亮"
local c_showdown_2 = "亮一张"
local c_showdown_3 = "全亮"

local menu_image1 ="picdata/table/foldBtn.png"--按钮正常状态
local menu_image2 ="picdata/table/foldBtn1.png"--按钮按下状态

--[[玩家亮牌类型]]
SHOW_DOWN_NOT         =0           -- 不亮牌
SHOW_DOWN_FIRST       =1           -- 亮第一张
SHOW_DOWN_SECOND      =2           -- 亮第二张
SHOW_DOWN_ALL         =3           -- 亮所有的
SHOW_DOWN_CHOOSE      =4           -- 亮选择的
POKER_MENU_1          =450
POKER_MENU_2          =452

local ShowDownMenu = class("ShowDownMenu", function()
		return display.newNode()
	end)

function ShowDownMenu:create(target, SEL, card1, card2)
	local sDownMenu = ShowDownMenu:new()
	sDownMenu:initWithCard(target, SEL, card1, card2)
	return sDownMenu
end

function ShowDownMenu:ctor()
	self.m_btnActionTag = -1
	self.m_selectorTarget = nil
	self.m_selector       = nil
	self.m_pokerName1     = ""
	self.m_pokerName2     = ""

	self:addNodeEventListener(cc.NODE_EVENT, function(event)
			if event.name == "enter" then
				self:onEnter()
			end
		end)
end

function ShowDownMenu:initWithCard(target, SEL, card1, card2)
	self.m_selectorTarget = target
	self.m_selector       = SEL
	self.m_btnActionTag   = -1
	self.m_pokerName1     = card1
	self.m_pokerName2     = card2
end

function ShowDownMenu:getSelectedIndex()
	return self.m_btnActionTag
end

function ShowDownMenu:createLabelMenu(menuTag, loc)
	local pMenu = cc.ui.UIPushButton.new({normal=kMenuPicNormal[menuTag+1],
		pressed=kMenuPicsSelect[menuTag+1],disabled=kMenuPicNormal[menuTag+1]})
	pMenu:setTag(menuTag)
	pMenu:align(display.LEFT_BOTTOM, loc.x, loc.y)
	pMenu:onButtonClicked(handler(self,self.menuCallback))
	return pMenu
end	

function ShowDownMenu:onEnter()
	local offset = cc.p(0,0)
	if LAYOUT_OFFSET.x > 0 then
		offset.x = 20
	end

	-- --[[不亮]]
	-- local menu1 = self:createLabelMenu(SHOW_DOWN_NOT,cc.pAdd(cc.p(display.width-260-86,10), offset))
	-- self:addChild(menu1)

	-- --[[亮一张]]
	-- local menu2 = self:createLabelMenu(SHOW_DOWN_CHOOSE,cc.pAdd(cc.p(display.width-260+10,10), offset))
	-- self:addChild(menu2)

	-- --[[全亮]]
	-- local menu3 = self:createLabelMenu(SHOW_DOWN_ALL,cc.pAdd(cc.p(display.width-260+100,10), offset))
	-- self:addChild(menu3)

	local SPACEC_WIDTH = 164
	local RADIO_BUTTON_IMAGES = {
    off = "btn_pre.png",
    off_pressed = "btn_pre2.png",
    off_disabled = "btn_pre.png",
    on = "btn_pre2.png",
    on_pressed = "btn_pre.png",
    on_disabled = "btn_pre2.png",}

    local tempPosX = display.width
    --[[不亮]]
	local menu1 = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text=c_showdown_1,font="font/FZZCHJW--GB1-0.TTF",size=26}))
	menu1:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-190-190-120+tempPosX,29)
			:onButtonStateChanged(handler(self,self.menuCallback))
			:addTo(self,4)
		menu1:setTag(SHOW_DOWN_NOT)
	--[[亮一张]]
	local menu2 = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text=c_showdown_2,font="font/FZZCHJW--GB1-0.TTF",size=26}))
	menu2:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-190-120+tempPosX,29)
			:onButtonStateChanged(handler(self,self.menuCallback))
			:addTo(self,4)
		menu2:setTag(SHOW_DOWN_CHOOSE)
	--[[全亮]]
	local menu3 = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text=c_showdown_3,font="font/FZZCHJW--GB1-0.TTF",size=26}))
	menu3:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-120+tempPosX,29)
			:onButtonStateChanged(handler(self,self.menuCallback))
			:addTo(self,4)
		menu3:setTag(SHOW_DOWN_ALL)
end

function ShowDownMenu:menuCallback(event)
	self.m_btnActionTag = event.target:getTag()
	--亮一张时候再次选择亮哪张牌
	if self.m_btnActionTag == SHOW_DOWN_CHOOSE then
		--当牌值不对或者扑克已经出现
		if self.m_pokerName1 == "" or self.m_pokerName2 == "" or
           self:getChildByTag(POKER_MENU_1) or
           self:getChildByTag(POKER_MENU_2) then
			return
        end

		local rootPath = "picdata/db_poker/"
		--poker1
		local picPath1 = rootPath..self.m_pokerName1..".png"
		
		local pokerSpUp1 = cc.Sprite:create(picPath1)
		local pokerSpDown1 = cc.Sprite:create(picPath1)

		local pokerBg = cc.ui.UIImage.new("picdata/table/bg_pre_tips.png")
			:align(display.CENTER, display.width-260+106-156, 120)
			:addTo(self, 0)

		local title = cc.ui.UILabel.new({
			text = "亮哪一张牌",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 18,
			color = cc.c3b(0,255,255),
			align = cc.TEXT_ALIGNMENT_CENTER
			})
			:align(display.CENTER, pokerBg:getContentSize().width/2, pokerBg:getContentSize().height-22)
			:addTo(pokerBg)

		--menu1
		if pokerSpUp1 and pokerSpDown1 then
			local poker1Item = cc.MenuItemImage:create()
			poker1Item:setNormalSpriteFrame(pokerSpUp1:getSpriteFrame())
			poker1Item:setSelectedSpriteFrame(pokerSpDown1:getSpriteFrame())
			poker1Item:registerScriptTapHandler(handler(self,self.showDownCallback1))
			poker1Item:setPosition(cc.p(0,0))
			poker1Item:setTag(SHOW_DOWN_FIRST)
            
			local pokerMenu1 = cc.Menu:create(poker1Item)
			pokerMenu1:setTag(POKER_MENU_1)
			self:addChild(pokerMenu1,1)
			pokerMenu1:setPosition(cc.p(display.width-260+106-185,135))

			-- local pokerMenu1 = cc.ui.UIPushButton.new({normal=picPath1,pressed=picPath1,disabled=picPath1})
			-- pokerMenu1:onButtonClicked(handler(self,self.showDownCallback12))
			-- pokerMenu1:setTag(POKER_MENU_1)
			-- self:addChild(pokerMenu1,1)
			-- pokerMenu1:setPosition(cc.p(106,-126))
		end
		--poker2
		local picPath2 = rootPath..self.m_pokerName2..".png"
		
		local pokerSpUp2 = cc.Sprite:create(picPath2)
		local pokerSpDown2 = cc.Sprite:create(picPath2)
		--menu2
		if pokerSpUp2 and pokerSpDown2 then
			local poker2Item = cc.MenuItemImage:create()
			poker2Item:setNormalSpriteFrame(pokerSpUp2:getSpriteFrame())
			poker2Item:setSelectedSpriteFrame(pokerSpDown2:getSpriteFrame())
			poker2Item:registerScriptTapHandler(handler(self,self.showDownCallback2))
			poker2Item:setPosition(cc.p(0,0))
			poker2Item:setTag(SHOW_DOWN_SECOND)
            
			local pokerMenu2 = cc.Menu:create(poker2Item)
			pokerMenu2:setTag(POKER_MENU_2)
			self:addChild(pokerMenu2,1)
			pokerMenu2:setPosition(cc.p(display.width-260+168-185-2,135))

			-- local pokerMenu2 = cc.ui.UIPushButton.new({normal=picPath2,pressed=picPath2,disabled=picPath2})
			-- pokerMenu2:onButtonClicked(handler(self,self.showDownCallback12))
			-- pokerMenu2:setTag(POKER_MENU_2)
			-- self:addChild(pokerMenu2,1)
			-- pokerMenu2:setPosition(cc.p(168,-126))
		end
	elseif(self.m_selector and self.m_selectorTarget) then --不亮和全亮
		self.m_selector(self)
	end
end

function ShowDownMenu:showDownCallback1(event)
	self.m_btnActionTag = SHOW_DOWN_FIRST
    
	if self.m_selector and self.m_selectorTarget then --亮一张
		self.m_selector(self)
	end
end

function ShowDownMenu:showDownCallback2(event)
	self.m_btnActionTag = SHOW_DOWN_SECOND
    
	if self.m_selector and self.m_selectorTarget then --亮一张
		self.m_selector(self)
	end
end



return ShowDownMenu