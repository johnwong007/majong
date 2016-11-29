--
-- Author: junjie
-- Date: 2015-11-24 10:35:30
--
local CMBaseLayer = class("CMBaseLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
function CMBaseLayer:ctor(params)
	self.params = params
	self.params.size = self.params.size or cc.size(840,520)
	self:init()
end
function CMBaseLayer:init()
	--self.mBg = cc.Sprite:create("picdata/reward/rewardDialogBG.png")
	local size = self.params.size
	self.mBg = cc.ui.UIImage.new("picdata/reward/rewardDialogBG.png", {scale9 = true})
    self.mBg:setLayoutSize(size.width,size.height)
	self.mBg:setPosition(display.cx-size.width/2,display.cy-size.height/2)
	self:addChild(self.mBg)

	if self.params.titlePath then
		local index = string.find(self.params.titlePath,".png")
		if index then
			local title = cc.Sprite:create(self.params.titlePath)
			title:setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height - title:getContentSize().height/2)
			self.mBg:addChild(title)
		else
			local title = cc.ui.UILabel.new({
		        color = cc.c3b(255, 228, 173),
		        text  = self.params.titlePath,
		        size  = 32,
		        font  = "FZZCHJW--GB1-0",
		       -- UILabelType = 1,
		    })
		    title:setPosition(size.width/2-title:getContentSize().width/2,size.height - 50)
			self.mBg:addChild(title)
		end
	end

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},handler(self, self.onMenuClose), {scale9 = false})    
    :align(display.CENTER, self.mBg:getContentSize().width - 20,self.mBg:getContentSize().height-20) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
end
function CMBaseLayer:onMenuClose(sender, event)
	CMClose(self)
end
return CMBaseLayer