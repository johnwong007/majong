local CreateRoomResult = class("CreateRoomResult", function()
	return display.newLayer()
	end)

function CreateRoomResult:create()

end

function CreateRoomResult:ctor()
	-- self:setNodeEventEnabled(true)
	local bg = cc.ui.UIImage.new("picdata/public/alertBG.png")
	bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, display.cy)
		:addTo(self)

	local successImagePosX = 170
	local successImagePosY= bg:getContentSize().height/2

	local successImage1 = cc.ui.UIImage.new("picdata/privateHall/private_success.png")
	successImage1:align(display.RIGHT_CENTER, successImagePosX, successImagePosY)
		:addTo(bg)

	local successImage2 = cc.ui.UIImage.new("picdata/privateHall/private_hint.png")
	successImage2:align(display.LEFT_CENTER, successImagePosX+15, successImagePosY)
		:addTo(bg)

	cc.ui.UIPushButton.new({normal="picdata/public/btn_2_close.png", pressed="picdata/public/btn_2_close2.png", disabled="picdata/public/btn_2_close2.png"})
		:align(display.CENTER, bg:getContentSize().width-10, bg:getContentSize().height-10)
		:addTo(bg, 1)
		:onButtonClicked(function(event)
			self:removeFromParent(true)

			local event = cc.EventCustom:new("ShowPrivateHallSearch")
    		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			end)

	-- local event = cc.EventCustom:new("RefreshPrivateHall")
 --    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    UserDefaultSetting:getInstance():setPrivateRoomMsgHint(true)

    local ac = transition.sequence({cc.DelayTime:create(2),
    	cc.CallFunc:create(handler(self, self.animationEnd))})
    self:runAction(ac)

    self:setNodeEventEnabled(true)
end

function CreateRoomResult:animationEnd()
	if self then
		self:removeFromParent(true)
	end
end

function CreateRoomResult:onExit()
	self:stopAllActions()
end

function CreateRoomResult:onEnter()
	
end

return CreateRoomResult