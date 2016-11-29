--
-- Author: junjie
-- Date: 2015-08-18 11:21:41
--
--as:"字符创;字符串#颜色#大小;字符串#颜色;#字符串"
--		"远界;科技#02#22;咨询#03;有限公司"
local CMColorLabel = class("CMColorLabel",function() 
    return display.newNode() 
end)
CMColorLabel._color = {}
CMColorLabel._color[1] = cc.c3b(255,255,255)
CMColorLabel._color[2] = cc.c3b(0,0,0)
CMColorLabel._color[3] = cc.c3b(255,0,0)
CMColorLabel._color[4] = cc.c3b(0,255,0)
CMColorLabel._color[5] = cc.c3b(0,0,255)
CMColorLabel._color[6] = cc.c3b(135,154,192)
CMColorLabel._color[7] = cc.c3b(0,255,255)
CMColorLabel._color[8] = cc.c3b(76,198,255)
CMColorLabel._color[9] = cc.c3b(161,178,210)
function CMColorLabel:ctor(params)    
    self._params = params   
    self._width  = 0
    self._size   = self._params.size or 22 
    self:initUI()
end

function CMColorLabel:initUI()
	self._splitText = string.split(self._params.text,";")	 
    for i = 1,#self._splitText do 
    	self._splitText[i] = string.split(self._splitText[i],"#")
    end
    --dump(self._splitText)
    local posx = 0
    local color = nil
    local size  = 22
    for i = 1,#self._splitText do
        color = CMColorLabel._color[tonumber(self._splitText[i][2] or 1)]
        size  = tonumber(self._splitText[i][3] or self._size)
    	local text = cc.ui.UILabel.new({text = self._splitText[i][1],size = size,color = color,font  = "黑体"})
		text:setAnchorPoint(cc.p(0,0.5))	
		text:setPosition(posx,0)
		self:addChild(text,0)
        self._width = self._width + text:getContentSize().width
		posx = posx + text:getContentSize().width
    end
end

function CMColorLabel:getContentWidth()
    return self._width
end
return CMColorLabel