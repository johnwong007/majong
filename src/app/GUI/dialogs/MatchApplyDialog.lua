local default_hint = "比赛人数坐满开赛，本场SNG结束关闭房间"

local MatchApplyDialog = class("MatchApplyDialog", function()
	return display.newLayer()
	end)

function MatchApplyDialog:create()

end

function MatchApplyDialog:ctor(params)
	-- self:setNodeEventEnabled(true)
	-- params = {matchName = "SNG赛事局", matchLevel = "500/1000",
	-- 	startChips = 1500, blindTime = 600}
	self.matchName = params.matchName
	self.matchLevel = params.matchLevel
	self.startChips = params.startChips
	self.blindTime = math.floor(params.blindTime/60)
	self.hint = params.hint
	self.m_pCallbackUI = params.callback
	if self.hint==nil then
		self.hint = default_hint
	end

	local bg = cc.ui.UIImage.new("picdata/public/alertBG.png")
	bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, display.cy)
		:addTo(self)

	local bgWidth = bg:getContentSize().width
	local bgHeight = bg:getContentSize().height

	cc.ui.UIPushButton.new({normal="picdata/public/btn_2_close.png", pressed="picdata/public/btn_2_close2.png", disabled="picdata/public/btn_2_close2.png"})
		:align(display.CENTER, bgWidth-10, bgHeight-10)
		:addTo(bg, 1)
		:onButtonClicked(function(event)
			self:removeFromParent(true)

			local event = cc.EventCustom:new("ShowPrivateHallSearch")
    		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			end)

	self.title = cc.ui.UIImage.new("picdata/privateHall/w_smg.png")
		:align(display.CENTER, bgWidth/2, bgHeight-40)
		:addTo(bg)

	local gapY = 45
	local label1 = cc.ui.UILabel.new({
		text = "赛事级别:",
		font = "黑体",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, bgWidth/2, self.title:getPositionY()-gapY)
		:addTo(bg)
	local label2 = cc.ui.UILabel.new({
		text = "起始筹码:",
		font = "黑体",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, label1:getPositionX(), label1:getPositionY()-gapY)
		:addTo(bg)
	local label3 = cc.ui.UILabel.new({
		text = "升盲时间:",
		font = "黑体",
		size = 24,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, label2:getPositionX(), label2:getPositionY()-gapY)
		:addTo(bg)

	local label4 = cc.ui.UILabel.new({
		text = ""..self.matchLevel,
		font = "黑体",
		size = 28,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, bgWidth/2, label1:getPositionY())
		:addTo(bg)	
	local label5 = cc.ui.UILabel.new({
		text = ""..self.startChips,
		font = "黑体",
		size = 28,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, bgWidth/2, label2:getPositionY())
		:addTo(bg)
	local label6 = cc.ui.UILabel.new({
		text = ""..self.blindTime.."分钟",
		font = "黑体",
		size = 28,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, bgWidth/2, label3:getPositionY())
		:addTo(bg)

	local hintLabel = cc.ui.UILabel.new({
		text = self.hint,
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 24,
		color = cc.c3b(0,255,225),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, bgWidth/2, label3:getPositionY()-gapY)
		:addTo(bg, 1)

	--[[分割线]]
	local line = cc.ui.UIImage.new("picdata/privateHall/private_line3.png")
	line:align(display.CENTER, bgWidth/2, hintLabel:getPositionY()-30)
		:addTo(bg, 1)
	line:setScaleX(65)

	local buttonGapX = 140

	self.cancelButton = cc.ui.UIPushButton.new({normal="picdata/public/cancelBtn.png", 
		pressed="picdata/public/cancelBtn2.png", 
		disabled="picdata/public/cancelBtn2.png"})
	self.cancelButton:align(display.CENTER_BOTTOM, bgWidth/2-buttonGapX, 20)
		:addTo(bg, 1)
		:onButtonClicked(function(event)
			CMClose(self, false)
			local event = cc.EventCustom:new("ShowPrivateHallSearch")
    		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			end)
		:setTouchSwallowEnabled(false)

	local buttonLabel1 = cc.ui.UILabel.new({
		text = "取消",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 32,
		color = cc.c3b(130,163,229)
		})
    buttonLabel1:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
	self.cancelButton:setButtonLabel("normal", buttonLabel1)

	self.confirmButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", 
		pressed="picdata/public/btn_green2.png", 
		disabled="picdata/public/btn_green2.png"})
	self.confirmButton:align(display.CENTER_BOTTOM, bgWidth/2+buttonGapX, self.cancelButton:getPositionY())
		:addTo(bg, 1)
		:onButtonClicked(function(event)
			self.m_pCallbackUI(self)
			CMClose(self, false)
			end)
		:setTouchSwallowEnabled(false)

	local buttonLabel2 = cc.ui.UILabel.new({
		text = "入局",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 32,
		color = cc.c3b(156,255,0)
		})
    buttonLabel2:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
	self.confirmButton:setButtonLabel("normal", buttonLabel2)

end

return MatchApplyDialog