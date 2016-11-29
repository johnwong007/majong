--
-- Author: junjie
-- Date: 2015-12-11 15:41:01
--
local CMSpriteButton = {}
function CMSpriteButton:new(event,params)
	self._params  = params or {}
	self.mSprite = params.sprite
	self.callback = params.callback
	return self:onTouch(event)
end
function CMSpriteButton:onTouch(event)

    local name, x, y = event.name, event.x, event.y
  
    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        if not self:checkTouchInSprite_(x, y) then return false end
 
        if self._params.scale ~= false then
            if self.mSprite:getScaleX() < 0 then
                self.mSprite:setScale(-0.9)
            else
                self.mSprite:setScale(0.9)
            end
        end
       
        self.mSprite:setTouchEnabled(false)
        return true
    end
    -- must the begin point and current point in Button Sprite
    local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY)
                         and self:checkTouchInSprite_(x, y)
    if name == "moved" then
        
    else        
      
        CMDelay(self.mSprite,0.15,function () 
            if not self.mSprite then return end
            if self._params.scale ~= false then
                if self.mSprite:getScaleX() < 0 then
                    self.mSprite:setScale(-1)
                else
                    self.mSprite:setScale(1)
                end
            end
         
            -- if self._callback and math.abs(x - self.touchBeganX) < 5 then 
            --     self._callback()
            -- end
            self.mSprite:setTouchEnabled(true) 
            
           end)       

        if name == "ended" and touchInTarget then                           
            if self.callback then
                --QManagerSound:playEffectByTag(self._effectTag)
                self:callback()
            end          
        end
    end
end

function CMSpriteButton:checkTouchInSprite_(x, y)
    return self.mSprite and self.mSprite:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end

return CMSpriteButton