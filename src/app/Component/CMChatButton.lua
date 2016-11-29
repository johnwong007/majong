--
-- Author: junjie
-- Date: 2016-04-06 13:41:03
--
--语音聊天按钮专用
--[[
	callBegin:触摸开始
	callMoveIn:移动在按钮内
	callMoveOut:移动在按钮外
	callEndIn:触摸结束内
	callEndOut:触摸结束外

    mInterTime:间隔时间
    mNeddTime:需要多少时间触发
]]
local UIButton = import("...framework.cc.ui.UIButton")
local CMChatButton = class("CMChatButton", UIButton)

CMChatButton.NORMAL   = "normal"
CMChatButton.PRESSED  = "pressed"
CMChatButton.DISABLED = "disabled"

function CMChatButton:ctor(images,params,options)
    CMChatButton.super.ctor(self, {
        {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
        {name = "enable",  from = {"disabled"}, to = "normal"},
        {name = "press",   from = "normal",  to = "pressed"},
        {name = "release", from = "pressed", to = "normal"},
    }, "normal", options)
    if type(images) ~= "table" then images = {normal = images} end   
    self._params  = params or {}
    self.mInterTime = params.mInterTime or 1  
    self.mNeddTime  = params.mNeddTime or 0
    self.mTouchTime = 0
    self:setButtonImage(CMChatButton.NORMAL, images["normal"], true)
    self:setButtonImage(CMChatButton.PRESSED, images["pressed"], true)
    self:setButtonImage(CMChatButton.DISABLED, images["disabled"], true)

end

function CMChatButton:getTouchTime(data)
    return self.mTouchTime
end

function CMChatButton:setButtonImage(state, image, ignoreEmpty)
    assert(state == CMChatButton.NORMAL
        or state == CMChatButton.PRESSED
        or state == CMChatButton.DISABLED,
        string.format("CMChatButton:setButtonImage() - invalid state %s", tostring(state)))
    CMChatButton.super.setButtonImage(self, state, image, ignoreEmpty)

    if state == CMChatButton.NORMAL then
        if not self.images_[CMChatButton.PRESSED] then
            self.images_[CMChatButton.PRESSED] = image
        end
        if not self.images_[CMChatButton.DISABLED] then
            self.images_[CMChatButton.DISABLED] = image
        end
    end
    return self
end


function CMChatButton:onTouch_(event)

    local name, x, y = event.name, event.x, event.y

    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        if not self:checkTouchInSprite_(x, y) then return false end
 
        if self._params.scale ~= false then
            if self:getScaleX() < 0 then
                self:setScale(-0.9)
            else
                self:setScale(0.9)
            end
        end
        if self._params.callBegin then
    		print("callBegin")
    		self._params.callBegin()
    	end
    	if not QManagerScheduler:getListenerLayerID(self) then
    	 	QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:updateTime(self.mInterTime) end,interval = self.mInterTime})
    	end
        self:setTouchEnabled(false)
        return true
    end
    -- must the begin point and current point in Button Sprite
    local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY)
                         and self:checkTouchInSprite_(x, y)
    if name == "moved" then
        if touchInTarget then
        	if not QManagerScheduler:getListenerLayerID(self) then
        	 	QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:updateTime(self.mInterTime) end,interval = self.mInterTime})
        	end
        	if self._params.callMoveIn then
        		print("callMoveIn")
        		self._params.callMoveIn()
        	end
        else
        	self:removeLocalScheduler()
        	if self._params.callMoveOut then
        		print("callMoveOut")
        		self._params.callMoveOut()
        	end
        end
    else            	
        CMDelay(self,0.15,function () 
            if not self then return end
            if self._params.scale ~= false then
                if self:getScaleX() < 0 then
                    self:setScale(-1)
                else
                    self:setScale(1)
                end
            end
            self:setTouchEnabled(true)            
           end)       
       
        if name == "ended" then                           
            if touchInTarget then
	        	if self._params.callEndIn then
	        		print("callEndIn")
                    -- if self.mTouchTime >= self.mNeddTime then
	        		    self._params.callEndIn()
                    -- end
	        	end
	        else
	        	if self._params.callEndOut then
	        		print("callEndOut")
	        		self._params.callEndOut()
	        	end
	        end      
                    self:removeLocalScheduler()   
        end
    end
end
function CMChatButton:removeLocalScheduler()
    self.mTouchTime = 0 
    QManagerScheduler:removeLocalScheduler({layer = self})
end
function CMChatButton:updateTime(dt)
	self.mTouchTime = self.mTouchTime + self.mInterTime
	dump(self.mTouchTime)
end
function CMChatButton:setTexture(_path,_isGray,params)
    if _isGray then   
        local parent = self.sprite_[1]:getParent()  
        local posx,posy    = self.sprite_[1]:getPosition()
        self.sprite_[1]:removeFromParent()
        self.sprite_[1] = display.newFilteredSprite(_path,"GRAY", {0.2, 0.3, 0.5, 0.1}) 
        self.sprite_[1]:setPosition(posx,posy)
        parent:addChild(self.sprite_[1]) 
    else
        local parent = self.sprite_[1]:getParent()  
        local posx,posy    = self.sprite_[1]:getPosition()        
        self.sprite_[1]:removeFromParent()
        self.sprite_[1] = cc.Sprite:create(_path)
        self.sprite_[1]:setPosition(posx,posy)
        parent:addChild(self.sprite_[1]) 
    end
end
function CMChatButton:checkTouchInSprite_(x, y)   
    return self.sprite_[1] and self.sprite_[1]:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end
return CMChatButton