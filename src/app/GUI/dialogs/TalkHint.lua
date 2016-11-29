local TalkHint = class("TalkHint", function()
	return display.newColorLayer(cc.c4b(0,0,0,128))
end)

function TalkHint:create()

end

function TalkHint:ctor(params)

	-- 允许 node 接受触摸事件
    self:setTouchEnabled(true)

    cc.ui.UIImage.new("picdata/table/tips.png")
    :align(display.LEFT_BOTTOM, 5, -2)
    :addTo(self)

	-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	if event.name == "began" then
    		CMClose(self, false)
        	return true
    	end
	end)
end

return TalkHint