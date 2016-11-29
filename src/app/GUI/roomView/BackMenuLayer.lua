	ebackNone = 10
	ebackQuickChange = 11
	ebackExitRoom = 12
	ebackShop = 13
	ebackRank = 14
	ebackActivity = 15
    ebackAFK = 16

local BackMenuLayer = class("BackMenuLayer", function()
		return display.newLayer()
	end)

function BackMenuLayer:create(callback, isPrivateRoom,tableId)
	local layer = BackMenuLayer:new()
	layer:setCallBack(callback)
	layer.m_isPrivateRoom = isPrivateRoom
	layer:updateUI()
	layer.tableId = tableId
	return layer
end


function BackMenuLayer:updateUI()
	local posy = {620, 560, 499, 439}
	if self.m_isPrivateRoom then
		self.m_changeTable:setVisible(false)
		self.m_leaveSit:setPositionY(posy[1])
		self.m_exit:setPositionY(posy[2])
		self.m_background:setTexture("picdata/gamescene/menu_bg.png")
	end
end

function BackMenuLayer:ctor()
	self:manualLoadxml()

	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(true) 
	self:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self,self.nodeTouchEvent), 100, -128)
end

function BackMenuLayer:setCallBack(callback)
	self.m_callbackUI = callback
end

function BackMenuLayer:manualLoadxml()
	--[[background]]
	self.m_background = cc.ui.UIImage.new("bg_9_bcak_bg_android.png")
	self.m_background:align(display.LEFT_TOP, 4, 640)
		:addTo(self)

	--[[快速换桌]]
	self.m_changeTable = cc.ui.UIPushButton.new({normal="sta_14_ctable_android.png",
		pressed="sta_14_ctable_down_android.png",disabled="sta_14_ctable_down_android.png"})
	self.m_changeTable:align(display.LEFT_TOP, 24, 620)
		:onButtonClicked(handler(self,self.quickChange))
		:addTo(self,2)
		:setTag(100)

	--[[留座]]
	self.m_leaveSit = cc.ui.UIPushButton.new({normal="sta_17_nom_android.png",
		pressed="sta_17_nom_down_android.png",disabled="sta_17_nom_down_android.png"})
	self.m_leaveSit:align(display.LEFT_TOP, 24, 560)
		:onButtonClicked(handler(self,self.afk))
		:addTo(self,2)
		:setTag(103)

	-- --[[进入商城]]
	-- self.m_enterShop = cc.ui.UIPushButton.new({normal="sta_16_shop_android.png",
	-- 	pressed="sta_16_shop_down_android.png",disabled="sta_16_shop_down_android.png"})
	-- self.m_enterShop:align(display.LEFT_TOP, 24, 499)
	-- 	:onButtonClicked(handler(self,self.enterShop))
	-- 	:addTo(self,2)
	-- 	:setTag(102)

	-- --[[最新活动]]
	-- self.m_enterActivity = cc.ui.UIPushButton.new({normal="sta_18_fun_android.png",
	-- 	pressed="sta_18_fun_down_android.png",disabled="sta_18_fun_down_android.png"})
	-- self.m_enterActivity:align(display.LEFT_TOP, 24, 439)
	-- 	:onButtonClicked(handler(self,self.enterActivity))
	-- 	:addTo(self,2)
	-- 	:setTag(104)

	--[[退出房间]]
	self.m_exit = cc.ui.UIPushButton.new({normal="sta_15_out_android.png",
		pressed="sta_15_out_down_android.png",disabled="sta_15_out_down_android.png"})
	self.m_exit:align(display.LEFT_TOP, 24, 499)
		:onButtonClicked(handler(self,self.exitRoom))
		:addTo(self,2)
		:setTag(101)


end


function BackMenuLayer:getBackAction()
	return self.m_backAction
end

function BackMenuLayer:nodeTouchEvent(event)
	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    -- 多点触摸增加了 added 和 removed 状态
    -- event.points 包含所有触摸点
    -- 按照 events.point[id] = {x = ?, y = ?} 的结构组织
	if event.name == "began" then
		self:getParent():removeChild(self, true)
	end
end

function BackMenuLayer:quickChange()
	self.m_backAction = ebackQuickChange
	self:clickCallback()
end

function BackMenuLayer:exitRoom()
	QManagerPlatform:quitChatRoom({["TargetId"]=self.tableId})
	self.m_backAction = ebackExitRoom
	self:clickCallback()
end

function BackMenuLayer:enterShop()
	self.m_backAction = ebackShop
	self:clickCallback()
end

function BackMenuLayer:enterRank()
	self.m_backAction = ebackRank
	self:clickCallback()
end

function BackMenuLayer:afk()
    self.m_backAction = ebackAFK
    self:clickCallback()
end

function BackMenuLayer:enterActivity()
	self.m_backAction = ebackActivity
	self:clickCallback()
end

function BackMenuLayer:clickCallback()
	if self.m_callbackUI then
		self.m_callbackUI:backCallback(self)
	end
	self:getParent():removeChild(self, true)
end

return BackMenuLayer