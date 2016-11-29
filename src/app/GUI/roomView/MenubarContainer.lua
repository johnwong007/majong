MENU_BAR_BACK_PATH = "picdata/table/menuBarBG.png"
MENU_BAR_UP_BUTTON_PATH = "picdata/table/menuBarBtn1.png"
MENU_BAR_DOWN_BUTTON_PATH = "picdata/table/menuBarBtn2.png"

local MenubarContainer = class("MenubarContainer", function()
		return display.newNode()
	end)

--[[创建菜单栏]]
function MenubarContainer:create(itemList)
	local menubar = MenubarContainer:new()
	if menubar then
		menubar:updateItemList(itemList)
		menubar:clickCallback()
		return menubar
	end
	return nil
end

function MenubarContainer:ctor()
	self.m_normalCount = 3
	self.m_isMore = false
	self.m_minItemNum = 1
	self.m_maxItemNum = 3
	self.m_actionDuration = 0.1
	self.m_itemWidth = 74
	self.m_menuItem = nil
	self.m_background = nil
	self.m_lightSprite = nil

	self.bgWidth = cc.ui.UIImage.new(MENU_BAR_BACK_PATH):getContentSize().width
	self.bgHeight = 66

	self.m_background = cc.ui.UIImage.new(MENU_BAR_BACK_PATH, {scale9 = false})
        :setLayoutSize(self.bgWidth, 66)
	self.m_background:align(display.TOP_RIGHT, CONFIG_SCREEN_WIDTH-5,display.height-5)
	self.m_background:addTo(self, 1)

	self.m_menuItem = cc.ui.UIPushButton.new({normal=MENU_BAR_DOWN_BUTTON_PATH,pressed=MENU_BAR_DOWN_BUTTON_PATH,disabled=MENU_BAR_DOWN_BUTTON_PATH})
	self.m_menuItem:onButtonClicked(handler(self, self.clickCallback))
	self.m_menuItem:align(display.CENTER, 20, self.bgHeight/2)
	self.m_menuItem:addTo(self.m_background, 2)

	self.m_lightSprite = cc.ui.UIImage.new(MENU_BAR_UP_BUTTON_PATH)
	self.m_lightSprite:align(display.CENTER, 0, 0)
	self.m_lightSprite:addTo(self.m_background, 3)
	self.m_lightSprite:setVisible(false)
end

function MenubarContainer:clickCallback(pObject)
	if(self.m_menuItem and self.m_background and self.m_lightSprite) then
		self.m_background:stopAllActions()
		self.m_menuItem:stopAllActions()
        
		self.m_isMore = not self.m_isMore
		self:updateMenuBar(true)
		self:switchItemStatus()
	end
end

function MenubarContainer:updateMenuBar(needAnimation)	
	if self.m_background and self.m_menuItem and self.m_lightSprite then
		local sx = self:calScaleX()
		local mx = self:calMoveX(sx)

--        m_background->runAction(CCScaleTo::create(m_actionDuration,sx,1.0f))
        if (sx>0.4) then
            self.m_background:setOpacity(255)
        else
            self.m_background:setOpacity(100)
        end
        -- self.m_background:setLayoutSize(cc.size(self.bgWidth*sx, self.m_background:getContentSize().height))
        self.m_background:setContentSize(cc.size(self.bgWidth*sx, self.m_background:getContentSize().height))
        -- self.m_background:setScaleX(sx)
		local posY = self.m_background:getContentSize().height / 2

        -- local spawn = cc.Spawn::create(cc.RotateTo:create(self.m_actionDuration,self.m_isMore and 180 or 0),
        --     cc.MoveTo:create(self.m_actionDuration,cc.p(mx,posY)),nil)
        
		if(self.m_minItemNum < self.m_maxItemNum and self.m_maxItemNum > 1) then
			--have arrow
			self.m_menuItem:setVisible(true)
			self.m_menuItem:setRotation(self.m_isMore and 180 or 0)
			-- self.m_menuItem:setPosition(cc.p(mx,posY))
			self:switchIconStatus()
			-- self.m_menuItem:runAction(cc.Sequence:create(spawn,cc.CallFunc:create(self,callfunc_selector(MenubarContainer::switchIconStatus)),NULL))
		else
			self.m_menuItem:setVisible(false)
			self.m_lightSprite:setVisible(false)
		end
	end
end

function MenubarContainer:switchIconStatus()
	if(self.m_menuItem and self.m_lightSprite) then
		self.m_lightSprite:setPosition(self.m_menuItem:getPosition())
		-- self.m_lightSprite:setVisible(self.m_isMore and self.m_minItemNum < self.m_maxItemNum)
	end
end

function MenubarContainer:messageBlink()	
	if(self.m_menuItem) then
		self.m_menuItem:runAction(cc.RepeatForever:create(cc.Blink:create(self.m_actionDuration,1)))
	end
end

function MenubarContainer:updateItemList(itemList)
	-- self:removeAllChildren()
	self:removeItemList()

	self:addItemList(itemList)
	self:updateMenuBar(true)
	self:switchItemStatus()
end

function MenubarContainer:calScaleX()
	local offsetX = self.m_menuItem:getContentSize().width+40
	local width = self.bgWidth
	if(self.m_minItemNum < self.m_maxItemNum and self.m_maxItemNum > 1) then
		--have arrow
		local sx = 1.0
		if(self.m_isMore) then
			local tmp = self.m_maxItemNum * self.m_itemWidth + offsetX
			sx = tmp / width
		else
			local tmp = self.m_minItemNum * self.m_itemWidth + offsetX
			sx = tmp / width
		end
		return sx
	else
		--no arrow
		local tmp = self.m_maxItemNum * self.m_itemWidth
		local sx = tmp / width
		return sx
	end	
end

function MenubarContainer:calMoveX(ratio)	
	local endX = self.bgWidth
	local width = self.bgWidth * ratio
	return endX - width + self.m_menuItem:getContentSize().width / 2
end

function MenubarContainer:addItemList(itemList)
	if not self.m_background then
		return 
	end
	self.m_itemList = itemList
	self.m_maxItemNum = #itemList
	self.m_minItemNum = (#itemList > self.m_minItemNum) and self.m_minItemNum or #itemList

	for i=1,#itemList do
		local pChildNode = itemList[i]
		pChildNode:setTouchEnabled(true)
		pChildNode:setTouchSwallowEnabled(true)
		pChildNode:setPosition(cc.p(self.m_background:getPositionX() - self.m_itemWidth / 2 * (2*i - 1), self.m_background:getPositionY()-self.bgHeight/2))
		pChildNode:setVisible(i-1<self.m_minItemNum or self.m_isMore)
		self:addChild(pChildNode, 10)
	end	
end

function MenubarContainer:removeItemList()
	if not self.m_itemList then
		return
	end
	for i=1,#self.m_itemList do
		local pChildNode = self.m_itemList[i]
		pChildNode:retain()
		self:removeChild(pChildNode, false)
	end	
end

function MenubarContainer:getItemList()	
	return self.m_itemList
end

function MenubarContainer:switchItemStatus()	
	local pChildNode = nil
	for i=self.m_minItemNum+1,#self.m_itemList do
		pChildNode = self.m_itemList[i]
		local action = nil
		local show = false
		if(self.m_isMore) then
			-- action = CCSequence::create(
   --                                      CCDelayTime::create(m_actionDuration * (i - m_minItemNum + 1)),
   --                                      CCShow::create(),
   --                                      CCFadeIn::create(m_actionDuration),
   --                                      NULL)
			-- action->retain()
			show = true
		else
			-- action = CCSequence::create(CCFadeOut::create(m_actionDuration * (m_itemList.size() - i)),CCHide::create(),NULL)
		end
		-- pChildNode:runAction(action)
		pChildNode:setVisible(show)
	end
end

return MenubarContainer