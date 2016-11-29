--
-- Author: wangj
-- Date: 2016-07-11 14:18:07
--
require("app.GUI.roomView.PokerDefine")
local PokerBg = class("PokerBg", function()
		return display.newNode()
	end)

function PokerBg:create()
	self:initUI()
end

function PokerBg:ctor(params)
	self.params = params or {}
	self.index = self.params.index or 1
end

function PokerBg:initUI()
	self.m_sprite = cc.ui.UIImage.new("picdata/ApplyCard/check.png")
		:align(display.CENTER, 0, 0)
		:addTo(self)

	if self.index<4 then
		local orbit = cc.OrbitCameraPoker:create(0.1, 1, 0, 100, 80, 0, 0)
		self.m_sprite:setFlippedX(false)
		self.m_sprite:runAction(orbit)
	else
	    local orbit = cc.OrbitCameraPoker:create(0.1, 1, 0, 100, 80, 0, 0)
		self.m_sprite:runAction(orbit)
	    self.m_sprite:setFlippedX(false)
	end

end

return PokerBg