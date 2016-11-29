--[[
    添加遮罩层
]]
local CMMask = class("CMMask",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)

function CMMask:ctor()
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
end
function CMMask:onTouch_(event)
    
	--printError("UIButton:onTouch_() - must override in inherited class")	
    local name, x, y = event.name, event.x, event.y

    if name == "began" then
        --self.touchBeganX = x
        --self.touchBeganY = y
        --if not self:checkTouchInSprite_(x, y) then return false end
        --print("began")
        return true
    end
    -- must the begin point and current point in Button Sprite
    -- local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY)
    --                     and self:checkTouchInSprite_(x, y)
    if name == "moved" then    	
        -- if touchInTarget  then           
             
        -- elseif not touchInTarget  then         
          
        -- end
         --rint("moved")
    else    	
    	
        if name == "ended" then
        	--print("ended")
        end
        
    end
end
return CMMask