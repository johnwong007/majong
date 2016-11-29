local s_qq_group = "194869695"
local s_tel = "0755-86338053"
local s_forum = "http://bbs.debao.com"
local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local BaseView = require("app.architecture.BaseView")
local ServiceFragment = class("ServiceFragment", function()
		return BaseView:new()
	end)

function ServiceFragment:create()
	self:initUI()
end

function ServiceFragment:ctor(params)
	self.params = params or {}
	self:setNodeEventEnabled(true)
end

function ServiceFragment:onExit()
	QManagerScheduler:removeLocalScheduler({layer = self}) 
end

function ServiceFragment:initUI()
	local bg = cc.ui.UIImage.new("picdata/public_new/bg.png", {scale9 = true})
    bg:setLayoutSize(bgWidth, bgHeight)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self)

    local backBtn = CMButton.new({normal = "picdata/public_new/btn_back2.png",
        pressed = "picdata/public_new/btn_back2.png"},function () self:back() end)
	backBtn:setPosition(45, bgHeight-40)
	bg:addChild(backBtn)

	-- self.m_pTitle = cc.ui.UILabel.new({
 --        text  = "联系我们",
 --        size  = 36,
 --        color = cc.c3b(255,255,255),
 --        align = cc.ui.TEXT_ALIGN_CENTER,
 --        font  = "黑体",
 --    })
	-- self.m_pTitle:align(display.CENTER, bgWidth/2,	bgHeight-40)
	-- bg:addChild(self.m_pTitle)
    self.m_pTitle = cc.ui.UIImage.new("picdata/loginNew/service/w_title_lxwm.png")
    self.m_pTitle:align(display.CENTER, bgWidth/2,bgHeight - 40)
    bg:addChild(self.m_pTitle)
	local padding = 20

    local label1 = cc.ui.UILabel.new({
        text  = "德堡客服微信",
        size  = 32,
        color = cc.c3b(255,255,255),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        font  = "黑体",
    })
	label1:align(display.RIGHT_CENTER, bgWidth/2-padding, bgHeight/2+100)
	bg:addChild(label1)

	local recommendIcon = cc.ui.UIImage.new("picdata/loginNew/service/icon_recommend.png")
    	:align(display.CENTER, label1:getPositionX()-label1:getContentSize().width-40, label1:getPositionY())
    	:addTo(bg)

    local label2 = cc.ui.UILabel.new({
        text  = "扫一扫，让我们更好为您服务",
        size  = 20,
        color = cc.c3b(135,154,192),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        font  = "黑体",
    })
	label2:align(display.RIGHT_CENTER, label1:getPositionX(), label1:getPositionY()-40)
	bg:addChild(label2)

	cc.ui.UIImage.new("picdata/loginNew/service/qr_debaokf.png")
    	:align(display.LEFT_CENTER, bgWidth/2+padding, label1:getPositionY())
    	:addTo(bg)


    cc.ui.UIImage.new("picdata/public_new/line2.png")
        :align(display.CENTER, bgWidth/2, bgHeight/2-60)
        :addTo(bg)

    -----------------
    local label3 = cc.ui.UILabel.new({
        text  = "更多联系方式",
        size  = 32,
        color = cc.c3b(255,255,255),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        font  = "黑体",
    })
	label3:align(display.RIGHT_CENTER, label1:getPositionX(), bgHeight/4+20)
	bg:addChild(label3)

    local label4 = cc.ui.UILabel.new({
        text  = "随时交流，及时解决问题",
        size  = 20,
        color = cc.c3b(135,154,192),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        font  = "黑体",
    })
	label4:align(display.RIGHT_CENTER, label1:getPositionX(), bgHeight/4-20)
	bg:addChild(label4)
local s_qq_group = "194869695"
local s_tel = "0755-86338053"
local s_forum = "http://bbs.debao.com"
    local label5 = cc.ui.UILabel.new({
        text  = "Q群："..s_qq_group,
        size  = 28,
        color = cc.c3b(205,211,223),
        align = cc.ui.TEXT_ALIGN_LEFT,
        font  = "Arial",
    })
	label5:align(display.LEFT_CENTER, bgWidth/2+padding, bgHeight/4+40)
	bg:addChild(label5)

    local label6 = cc.ui.UILabel.new({
        text  = "电话："..s_tel,
        size  = 28,
        color = cc.c3b(205,211,223),
        align = cc.ui.TEXT_ALIGN_LEFT,
        font  = "Arial",
    })
	label6:align(display.LEFT_CENTER, bgWidth/2+padding, bgHeight/4)
	bg:addChild(label6)

    local label7 = cc.ui.UILabel.new({
        text  = "论坛："..s_forum,
        size  = 28,
        color = cc.c3b(205,211,223),
        align = cc.ui.TEXT_ALIGN_LEFT,
        font  = "Arial",
    })
	label7:align(display.LEFT_CENTER, bgWidth/2+padding, bgHeight/4-40)
	bg:addChild(label7)
end

function ServiceFragment:back()
    if not self.params or not self.params.noNotify then
        QManagerListener:Notify({layerID = eLoginViewLayerID,tag = self.params.tag or 1})
    end
	CMClose(self, true)
end

return ServiceFragment