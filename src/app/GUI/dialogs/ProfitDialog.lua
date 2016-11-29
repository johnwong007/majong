local ProfitDialog = class("ProfitDialog", function()
	return display.newLayer()
end)

function ProfitDialog:create()
	local dialog = ProfitDialog:new()
	return dialog
end

function ProfitDialog:ctor()
	self.title = cc.ui.UIImage.new("picdata/gamescene/profitInfoBG.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	local bgWidth = self.title:getContentSize().width
	local bgHeight = self.title:getContentSize().height
	cc.ui.UIImage.new("picdata/gamescene/profitInfoTitle.png")
		:align(display.CENTER, bgWidth/2, bgHeight/2+150)
		:addTo(self.title)

	cc.ui.UILabel.new({
		text = "盈亏报告",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 32,
		color = cc.c3b(26,26,26),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, bgWidth/2, bgHeight/2+160)
		:addTo(self.title)

	self.happy = cc.ui.UIImage.new("picdata/gamescene/happy.png")
		:align(display.CENTER, bgWidth/2, bgHeight/2+50)
		:addTo(self.title)
	self.happy:setVisible(false)

	self.sad = cc.ui.UIImage.new("picdata/gamescene/sad.png")
		:align(display.CENTER, bgWidth/2, bgHeight/2+50)
		:addTo(self.title)
	self.sad:setVisible(false)

	self.up = cc.ui.UIImage.new("picdata/gamescene/add.png")
		:align(display.CENTER, bgWidth/2-159, bgHeight/2-67)
		:addTo(self.title)
	self.up:setVisible(false)

	self.down = cc.ui.UIImage.new("picdata/gamescene/sub.png")
		:align(display.CENTER, bgWidth/2-159, bgHeight/2-67)
		:addTo(self.title)
	self.down:setVisible(false)

	self.profit = cc.ui.UILabel.new({
		text = "199",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 35,
		color = cc.c3b(235,235,255),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, bgWidth/2, bgHeight/2-67)
		:addTo(self.title)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},handler(self, self.onMenuClose), {scale9 = false})    
    :align(display.CENTER, self.title:getContentSize().width - 30,self.title:getContentSize().height-30) --设置位置 锚点位置和坐标x,y
    :addTo(self.title, 2)

    local btnShare = CMButton.new({normal = "picdata/public/btn_1_156_green2.png",pressed = "picdata/public/btn_1_156_green.png"},handler(self, self.shareToWechat), {scale9 = false})    
    btnShare:pos(self.title:getContentSize().width/2 - btnShare:getContentSize().width/2, btnShare:getContentSize().height + 50)
  		:addTo(self.title, 3)
  		:setButtonLabel(cc.ui.UILabel.new({
			text = "分享",
			font = "黑体",
			size = 26,
			color = cc.c3b(255,235,255),
		}))
end

function ProfitDialog:onMenuClose()
	CMClose(self)
end

function ProfitDialog:shareToWechat()
	local temp = ""
	if self.m_profitCoin > 0 then
		temp = lang_WECHATSHARE_PROFIT_WIN1 .. StringFormat:FormatDecimals(self.m_profitCoin, 2) .. lang_WECHATSHARE_PROFIT_WIN2
	else
		temp = lang_WECHATSHARE_PROFIT_FAILT1 .. StringFormat:FormatDecimals(-self.m_profitCoin, 2) .. lang_WECHATSHARE_PROFIT_FAILT2
	end
	local data = {
		title = temp,
		content = temp,
		nType = 1,
		url = "http://www.debao.com"}
	QManagerPlatform:shareToWeChat(data) 
end

return ProfitDialog