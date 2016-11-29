--
-- Author: junjie
-- Date: 2016-04-19 09:42:46
--
local RechargeAwardLayer = class("RechargeAwardLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)

function RechargeAwardLayer:ctor(params)
	-- dump(self.params)
	self.params = params or {}
end
function RechargeAwardLayer:create()
	local bg = cc.Sprite:create("picdata/public/tc_hj.png")
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height
	bg:setPosition(display.cx, display.cy)
	self:addChild(bg)

	local awardsp = cc.Sprite:create("picdata/activity/jl2.png")
	awardsp:setPosition(bgWidth/2, bgHeight/2+60)
	bg:addChild(awardsp)

	local tipsbg = cc.Sprite:create("picdata/public/tc_srk.png")
	tipsbg:setPosition(bgWidth/2, bgHeight/2-80)
	bg:addChild(tipsbg)
	local tips = cc.ui.UILabel.new({
        text  = string.format("%s金币＋赛事门票",self.params["3051"] or 0),
        size  = 30,
   		color = cc.c3b(255,228,173),
    })
    tips:setPosition(tipsbg:getContentSize().width/2-tips:getContentSize().width/2,tipsbg:getContentSize().height/2)  
    tipsbg:addChild(tips)

    local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end, {scale9 = false})    
    :align(display.CENTER, bgWidth - 40,bgHeight-40) --设置位置 锚点位置和坐标x,y
    :addTo(bg)
end

return RechargeAwardLayer