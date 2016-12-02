local CMTextButton = require("app.Component.CMTextButton")
local bgWidth = 652
local bgHeight= 348
 local Toast = class("Toast", function()
        return display.newLayer()
    end)

function Toast:create()
	self:initUI()
end

function Toast:ctor(params)
	self.params = params or {}
	self.params.text = self.params.text or ""
	self.params.okText = self.params.okText or "点击任意位置关闭按钮"
	self.params.okCallback = self.params.okCallback or nil
	-- 允许 node 接受触摸事件
    self:setTouchEnabled(true)

	-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    	-- event.x, event.y 是触摸点当前位置
    	-- event.prevX, event.prevY 是触摸点之前的位置
    	-- printf("sprite: %s x,y: %0.2f, %0.2f",
     --       event.name, event.x, event.y)

    	-- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
    	-- 则必须返回 true
    	if event.name == "began" then
        	self:close()
    	end
	end)
end

function Toast:initUI()
	local bg = cc.ui.UIImage.new("picdata/public/img_square1.png",{scale9=true})
 	bg:setLayoutSize(652, 348)
	bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
		:addTo(self)

 	local title = cc.ui.UILabel.new({
        color = cc.c3b(0, 255, 225),
        text  = self.params.titleText,
        size  = 36,
        font  = "黑体",
    })
    title:setPosition(bgWidth/2-title:getContentSize().width/2,bgHeight - 50)
	bg:addChild(title)

    local closeButton = CMTextButton:new({
        text  = self.params.okText,
        textColorN = cc.c3b(105,126,174),
        callback  = handler(self, self.close)
    })
    closeButton:align(display.CENTER, bgWidth/2,50)
    bg:addChild(closeButton)

	local index = string.find(self.params.text,"#%d")
	local alignment = cc.TEXT_ALIGNMENT_LEFT
	local sTip
	if index then
		sTip = CMColorLabel.new({text = self.params.text,size = 28 ,dimensions = cc.size(bgWidth - 100, 0)})
		sTip:setPosition(50,215)			
	else
		if string.len(self.params.text)< 36 then
			sTip = cc.ui.UILabel.new({
				text = self.params.text or "",
				color = cc.c3b(125,0,0),
				size = 28,
				-- dimensions = cc.size(bgWidth - 160, 0),
				})
			sTip:align(display.CENTER, bgWidth/2, 180 - sTip:getContentSize().height/2)
		else
			sTip = cc.ui.UILabel.new({
				text = self.params.text or "",
				color = cc.c3b(125,0,0),
				size = 28,
				textAlign = cc.TEXT_ALIGNMENT_LEFT,
				-- align = cc.TEXT_ALIGNMENT_CENTER,
				dimensions = cc.size(bgWidth - 160, 0)})	
			sTip:align(display.CENTER,bgWidth/2,155)
		end
	end
	bg:addChild(sTip,0)
end

function Toast:close()
	if self.params.okCallback then
		self.params.okCallback()
	end
	CMClose(self, nil, "SHOW_INPUT")
end
return Toast