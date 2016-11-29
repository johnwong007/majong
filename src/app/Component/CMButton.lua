
local MusicPlayer = require("app.Tools.MusicPlayer")
local UIButton = import("...framework.cc.ui.UIButton")
local CMButton = class("CMButton", UIButton)
local scheduler         = require("framework.scheduler")
CMButton.NORMAL   = "normal"
CMButton.PRESSED  = "pressed"
CMButton.DISABLED = "disabled"

-- start --

--------------------------------
-- 按钮控件构建函数
-- @function [parent=#CMButton] ctor
-- @param table images 各种状态的图片
-- @param table options 参数表 其中scale9为是否缩放

--[[--

按钮控件构建函数

状态值:
-   normal 正常状态
-   pressed 按下状态
-   disabled 无效状态

]]
-- end --
--[[
_params
    scale :是否缩放
    redDot:是否显示红点  
    _textPath:标题路径
    offx:      偏移量
    redTimes :红点次数
    showLight:亮光

]]
function CMButton:ctor(images,callback,options,params)
    CMButton.super.ctor(self, {
        {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
        {name = "enable",  from = {"disabled"}, to = "normal"},
        {name = "press",   from = "normal",  to = "pressed"},
        {name = "release", from = "pressed", to = "normal"},
    }, "normal", options)
    if type(images) ~= "table" then images = {normal = images} end   
    -- if images.normal == "common/close.png" then
    --     self._effectTag = QManagerSound._effectTag.eClose
    -- else
    --     self._effectTag = QManagerSound._effectTag.eClick
    -- end    
    self._images  = images
    self._callback = callback    
    self._params   = params or {}   
    self._isTouch        = (not self._params.isTouch) or false
    self._params.scale   = self._params.scale and true   
    self._params.redDot  = self._params.redDot and true
    self._params.offx    = self._params.offx   or 0
    self._params.offy    = self._params.offy   or 0

    self:setButtonImage(CMButton.NORMAL, images["normal"], true)
    self:setButtonImage(CMButton.PRESSED, images["pressed"], true)
    self:setButtonImage(CMButton.DISABLED, images["disabled"], true)

end

function CMButton:setButtonImage(state, image, ignoreEmpty)
    assert(state == CMButton.NORMAL
        or state == CMButton.PRESSED
        or state == CMButton.DISABLED,
        string.format("CMButton:setButtonImage() - invalid state %s", tostring(state)))
    CMButton.super.setButtonImage(self, state, image, ignoreEmpty)

    if state == CMButton.NORMAL then
        if not self.images_[CMButton.PRESSED] then
            self.images_[CMButton.PRESSED] = image
        end
        if not self.images_[CMButton.DISABLED] then
            self.images_[CMButton.DISABLED] = image
        end
    end

    if self._params.redDot then
        if not self:getChildByTag(101) then
            local redDot = cc.Sprite:create("picdata/public/dot.png")
            redDot:setPosition(self.sprite_[1]:getPositionX()+self.sprite_[1]:getContentSize().width/2 - redDot:getContentSize().width/2,self.sprite_[1]:getPositionY()+self.sprite_[1]:getContentSize().height/2 - redDot:getContentSize().height)
            self:addChild(redDot,0,101)
        end
        -- self._times = cc.ui.UILabel.new({text = self._params.redTimes,size = 22})

        -- local redDot = cc.ui.UIImage.new("picdata/public/dot.png", {scale9 = true})
        -- redDot:setLayoutSize(self._times:getContentSize().width+20,redDot:getContentSize().height)
        -- redDot:setPosition(self.sprite_[1]:getContentSize().width - redDot:getContentSize().width-5,self.sprite_[1]:getContentSize().height - 15)
        -- self.sprite_[1]:addChild(redDot,0,101)        
        
        -- self._times:setPosition(redDot:getContentSize().width/2-self._times:getContentSize().width/2,redDot:getContentSize().height/2)
        -- redDot:addChild(self._times)
    end
    self:addTextPath()
    -- if self._params.textPath then
    --     if self._params.isGray then
    --         self._textPath = display.newFilteredSprite(self._params.textPath,"GRAY", {0.2, 0.3, 0.5, 0.1}) 
    --     else
    --         self._textPath = cc.Sprite:create(self._params.textPath)
    --     end 
    --     self._textPath:setPosition(self.sprite_[1]:getContentSize().width/2 + self._params.offx,self.sprite_[1]:getContentSize().height/2 + self._params.offy)
    --     self.sprite_[1]:addChild(self._textPath,0,102)
    -- end
    return self
end
--[[
    添加文字图片
]]
function CMButton:addTextPath()
    if self._params.textPath  then
        local textPath =  self.sprite_[1]:getChildByTag(102)
        if textPath then textPath:removeFromParent() end
        if self._params.isGray then
            self._textPath = display.newFilteredSprite(self._params.textPath,"GRAY", {0.2, 0.3, 0.5, 0.1}) 
        else
            self._textPath = cc.Sprite:create(self._params.textPath)
        end 
        self._textPath:setPosition(self.sprite_[1]:getContentSize().width/2 + self._params.offx,self.sprite_[1]:getContentSize().height/2 + self._params.offy)
        self.sprite_[1]:addChild(self._textPath,0,102)
    end
end
function CMButton:onTouch_(event)
   
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        if not self:checkTouchInSprite_(x, y) then return false end
        if  self._images["pressed"] then
            self.fsm_:doEvent("press")  
            self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
            self:addTextPath()
        else
            self.fsm_:doEvent("press")  
            self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
            
            if self._params.scale ~= false then
                if self:getScaleX() < 0 then
                    self:setScale(-0.9)
                else
                    self:setScale(0.9)
                end
            end

            if self._params.showLight then
                self._LightBg = cc.Sprite:create(self._params.showLight)
                self._LightBg:setPosition(self.sprite_[1]:getContentSize().width/2,self.sprite_[1]:getContentSize().height/2)
                self.sprite_[1]:addChild(self._LightBg,-1)
            end
            -- if self._params.touchListener then
            --     self._params.touchListener(event)
            -- end
            self:setButtonEnabled(false)
        end
        return true
    end
    -- if self._params.touchListener then
    --     self._params.touchListener(event)
    -- end
    -- must the begin point and current point in Button Sprite
    local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY)
                        and self:checkTouchInSprite_(x, y)
    if name == "moved" then
        if touchInTarget and self.fsm_:canDoEvent("press") then
            self.fsm_:doEvent("press")
            self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
             self:addTextPath()
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIButton.RELEASE_EVENT, x = x, y = y, touchInTarget = false})
            self:addTextPath()
        end
    else        
        -- scheduler.performWithDelayGlobal(function () 
        --     if self then 
        --         self:setScale(1)
        --         self:setButtonEnabled(true) 
        --     end 
        --     end,0.5)
        if not self._images["pressed"] then
            CMDelay(self,0.15,function () 
                if self then 
                    if self._params.scale ~= false then
                        if self:getScaleX() < 0 then
                            self:setScale(-1)
                        else
                            self:setScale(1)
                        end
                    end
                    if  self._LightBg then
                        self._LightBg:removeFromParent()
                        self._LightBg = nil
                    if self._callback and math.abs(x - self.touchBeganX) < 5 then 
                        MusicPlayer:getInstance():playButtonSound()
                        self._callback()
                    end
                end
                    self:setButtonEnabled(true) 
                end 
                
               end)  
 
        end 
        if self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIButton.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})      
        end

        if name == "ended" and touchInTarget then                           
            self:dispatchEvent({name = UIButton.CLICKED_EVENT, x = x, y = y, touchInTarget = true})
            if self._callback and self._isTouch then
                --QManagerSound:playEffectByTag(self._effectTag)
                MusicPlayer:getInstance():playButtonSound()
                self:_callback()
            end          
        end
        if name == "ended" and self._images and self._images["pressed"] then
            self:addTextPath()
        end
    end
end
--[[
    --_path：修改图片
    --_isGray:灰态
]]
function CMButton:setTexture(_path,_isGray,params)
    params = params or {}
    if _isGray then   
        local parent = self.sprite_[1]:getParent()  
        local posx,posy    = self.sprite_[1]:getPosition()
        self.sprite_[1]:removeFromParent()
        self.sprite_[1] = display.newFilteredSprite(_path,"GRAY", {0.2, 0.3, 0.5, 0.1}) 
        self.sprite_[1]:setPosition(posx,posy)
        parent:addChild(self.sprite_[1]) 
        self._isTouch = false    
        self._params.scale = false  
    else
        local parent = self.sprite_[1]:getParent()  
        local posx,posy    = self.sprite_[1]:getPosition()        
        self.sprite_[1]:removeFromParent()
        self.sprite_[1] = cc.Sprite:create(_path)
        self.sprite_[1]:setPosition(posx,posy)
        parent:addChild(self.sprite_[1]) 
        self._isTouch = true
        --self._params.scale = true
    end

    if params.textPath then      
        self._textPath = cc.Sprite:create(params.textPath)
        self._textPath:setPosition(self.sprite_[1]:getContentSize().width/2 + self._params.offx,self.sprite_[1]:getContentSize().height/2 + self._params.offy)
        self.sprite_[1]:addChild(self._textPath,0,102)       
    end
end
function CMButton:updateTextPath(_path,isGray) 
    -- dump(_path,isGray)
    local textPath=  self.sprite_[1]:getChildByTag(102)
    if textPath then
        --textPath:setTexture(_path)
    end
    self._textPath:removeFromParent()
    if self._textPath then
        self._textPath:removeFromParent()
        self._params.textPath = _path
        if self._params.isGray then
            self._textPath = display.newFilteredSprite(self._params.textPath,"GRAY", {0.2, 0.3, 0.5, 0.1}) 
        else
            self._textPath = cc.Sprite:create(self._params.textPath)
        end 
        self._textPath:setPosition(self.sprite_[1]:getContentSize().width/2 + self._params.offx,self.sprite_[1]:getContentSize().height/2 + self._params.offy)
        --self.sprite_[1]:addChild(self._textPath,0,102)
    end
end
function CMButton:getButtonSize()    
    return self.sprite_[1]:getContentSize()
end
--[[
    移除红点
]]
function CMButton:removeRedDot()
    local redDot = self:getChildByTag(101)
    if redDot then
        self:getChildByTag(101):removeFromParent()
    end
end
--[[
    文字图缩放
]]
function CMButton:setTextPathScale(scalex,scaley)
    scalex = scalex or 1
    scaley = scaley or 1
    if self._textPath then
        self._textPath:setScaleX(scalex)
        self._textPath:setScaleY(scaley)
    end
end
--[[
    添加红点
]]
function CMButton:addRedDot()   
    self:removeRedDot()
   local redDot = cc.Sprite:create("picdata/public/dot.png")
    redDot:setPosition(self.sprite_[1]:getPositionX()+self.sprite_[1]:getContentSize().width/2 - redDot:getContentSize().width/2,self.sprite_[1]:getPositionY()+self.sprite_[1]:getContentSize().height/2 - redDot:getContentSize().height)
    self:addChild(redDot,0,101)
end
function CMButton:changeRedTimes(_times,_showType)
    local redDot
    
    if self:getChildByTag(999) then     --添加到名字上
        redDot = self:getChildByTag(999):getChildByTag(101)
    else
        redDot = self.sprite_[1]:getChildByTag(101)
    end
    if not redDot  then
        if _times == 0 then
            return 
        end
        self._times = cc.ui.UILabel.new({text = _times,size = 22})

        redDot = cc.ui.UIImage.new("common/hongdian.png", {scale9 = true})
        redDot:setLayoutSize(self._times:getContentSize().width+20,redDot:getContentSize().height)
        if self:getChildByTag(999) then
            -- print("buidlName")
            local buildName = self:getChildByTag(999)
            redDot:setPosition(buildName:getContentSize().width-redDot:getContentSize().width/2,buildName:getContentSize().height-redDot:getContentSize().height/2)
            buildName:addChild(redDot,0,101)
        else
            redDot:setPosition(self.sprite_[1]:getContentSize().width-redDot:getContentSize().width-5,self.sprite_[1]:getContentSize().height-redDot:getContentSize().height)
            self.sprite_[1]:addChild(redDot,0,101)
        end
                
        
        self._times:setPosition(redDot:getContentSize().width/2-self._times:getContentSize().width/2,redDot:getContentSize().height/2+2)
        redDot:addChild(self._times)
    else
        local temp = cc.ui.UILabel.new({text = _times,size = 22})
        redDot:setLayoutSize(temp:getContentSize().width+20,redDot:getContentSize().height)
        
         if self:getChildByTag(999) then          
            local buildName = self:getChildByTag(999)
            redDot:setPositionX(buildName:getContentSize().width-redDot:getContentSize().width/2)
        else
            redDot:setPositionX(self.sprite_[1]:getContentSize().width-redDot:getContentSize().width-5)            
        end
        self._times:setString(_times)
        redDot:setVisible(true)
    end
    if _times == 0 then
        redDot:setVisible(false)
    end
    if _showType == 2 then 
        self._times:setVisible(false)
    end
end

function CMButton:updateButtonImage_()
    -- CMButton.super.updateButtonImage_(self)
    -- dump("CMButton:updateButtonImage_")
    -- if self._params.changeAlpha then
    --     local state = self.fsm_:getState()
    --     for i,v in pairs(self.sprite_) do
    --         dump(i)
    --     end
    -- end
    local changeAlpha = self._params.changeAlpha
    local state = self.fsm_:getState()
    local image = self.images_[state]

    if not image then
        for _, s in pairs(self:getDefaultState_()) do
            image = self.images_[s]
            if image then break end
        end
    end
    if image then
        if self.currentImage_ ~= image then
            for i,v in ipairs(self.sprite_) do
                v:removeFromParent(true)
            end
            self.sprite_ = {}
            self.currentImage_ = image

            if "table" == type(image) then
                for i,v in ipairs(image) do
                    if self.scale9_ then
                        self.sprite_[i] = display.newScale9Sprite(v)
                        if not self.scale9Size_ then
                            local size = self.sprite_[i]:getContentSize()
                            self.scale9Size_ = {size.width, size.height}
                        else
                            self.sprite_[i]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                        end
                    else
                        self.sprite_[i] = display.newSprite(v)
                    end
                    
                    if state=="pressed" and changeAlpha then
                        if i==1 then
                            self.sprite_[i]:setScale(0.9)
                        elseif i==2 then
                            self.sprite_[i]:setScale(0.9)
                            self.sprite_[i]:setOpacity(255*0.7)
                        end
                    end
                    self:addChild(self.sprite_[i], UIButton.IMAGE_ZORDER)
                    if self.sprite_[i].setFlippedX then
                        if self.flipX_ then
                            self.sprite_[i]:setFlippedX(self.flipX_ or false)
                        end
                        if self.flipY_ then
                            self.sprite_[i]:setFlippedY(self.flipY_ or false)
                        end
                    end
                end
            else
                if self.scale9_ then
                    self.sprite_[1] = display.newScale9Sprite(image)
                    if not self.scale9Size_ then
                        local size = self.sprite_[1]:getContentSize()
                        self.scale9Size_ = {size.width, size.height}
                    else
                        self.sprite_[1]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                    end
                else
                    self.sprite_[1] = display.newSprite(image)
                end
                if self.sprite_[1].setFlippedX then
                    if self.flipX_ then
                        self.sprite_[1]:setFlippedX(self.flipX_ or false)
                    end
                    if self.flipY_ then
                        self.sprite_[1]:setFlippedY(self.flipY_ or false)
                    end
                end
                self:addChild(self.sprite_[1], UIButton.IMAGE_ZORDER)
            end
        end

        for i,v in ipairs(self.sprite_) do
            v:setAnchorPoint(self:getAnchorPoint())
            v:setPosition(0, 0)
        end
    elseif not self.labels_ then
        printError("UIButton:updateButtonImage_() - not set image for state %s", state)
    end
end

return CMButton
