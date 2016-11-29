--
-- Author: junjie
-- Date: 2015-12-02 15:55:50
--
local CMToolTipView = class("CMToolTipView",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
function CMToolTipView:ctor(params)
	self.params = params
	self.params.size = self.params.size or cc.size(840,520)
	
end
function CMToolTipView:create()
	self:initUI()
end
function CMToolTipView:initUI()
	self.mBg = cc.Sprite:create("picdata/public/tooltipBG.png")
	local bgWidth = self.mBg:getContentSize().width
	local bgHeight= self.mBg:getContentSize().height
	self.mBg:setPosition(display.cx,display.cy)
	self:addChild(self.mBg)

	local title = cc.ui.UILabel.new({
		        text  = self.params.text or "",
		        size  = 30,
		        color = cc.c3b(255,255,255),
		        --UILabelType = 1,
	    		--font  = "Arial",
		    })
	title:setPosition(bgWidth/2-title:getContentSize().width/2,50)
	self.mBg:addChild(title)

	local path = "picdata/public/faild.png"
	if self.params.isSuc then
		path   = "picdata/public/success.png" 
	end
	local sucSp = cc.Sprite:create(path)
	sucSp:setPosition(bgWidth/2,bgHeight/2+30)
	self.mBg:addChild(sucSp)

	self:onMenuClose()
end

function CMToolTipView:onMenuClose(sender, event)
	local ac1 = cc.DelayTime:create(1.3)
	local ac2 = cc.CallFunc:create(function () CMClose(self) end) 
	local seq = cc.Sequence:create(ac1,ac2)
	self:runAction(seq)
end
return CMToolTipView
