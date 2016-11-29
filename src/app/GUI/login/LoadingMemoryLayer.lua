--
-- Author: junjie
-- Date: 2016-05-13 10:02:27
--
local LoadingMemoryLayer = class("LoadingMemoryLayer",function() 
	return display.newColorLayer(cc.c4b( 155,150,155,150))
end)
local LoadingResPath = require("app.GUI.allrespath.LoadingResPath")
function LoadingMemoryLayer:ctor()
	self:setNodeEventEnabled(true)
	self:scheduleUpdate()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT,function (dt) self:update(dt) end)
	
	self.testLoadDir = LoadingResPath:getResPath("MainPagePath")
	self.mTotalNum = #self.testLoadDir
	self.mCurNum    = 0
	
end
function LoadingMemoryLayer:create()
	self:newProgressTimer("picdata/public/probg.png","picdata/public/pro.png" )
	self.mDownLoadLabel = display.newTTFLabel({text = string.format("当前加载进度%s,请稍候..",0), 
		size = 22, align = cc.TEXT_ALIGN_CENTER, color = cc.c3b(125,125,0)}):pos(display.cx,60):addTo(self,1)

end
--【【更新进度条】】
function LoadingMemoryLayer:newProgressTimer( bgBarImg,progressBarImg ) 
    local prebg = display.newSprite(bgBarImg)
    prebg:setPosition(cc.p(display.cx,100))
    self:addChild(prebg)

    local pro = cc.Sprite:create(progressBarImg)
    local progress = cc.ProgressTimer:create(pro)   
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)    
    progress:setBarChangeRate(cc.p(1, 0))      
    progress:setMidpoint(cc.p(0,1)) 
    progress:setPercentage(0)      
    progress:setPosition(display.cx,100)     
    self:addChild(progress) 
    self.progressTimer = progress


    -- self.progressTimer:runAction(cca.repeatForever(cca.progressFromTo(3,0,100)))
    -- self.progressTimer:stopAllActions()
end
function LoadingMemoryLayer:update(dt)
	while self.mCurNum > self.mTotalNum do
		self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
		return
	end
	cc.Director:getInstance():getTextureCache():addImage(self.testLoadDir[self.mCurNum])
	local percent = 100 * self.mCurNum/self.mTotalNum
	percent = math.ceil(percent)
	self.progressTimer:setPercentage(percent)
	self.mDownLoadLabel:setString(string.format("当前加载进度%s,请稍候..",percent))
	self.mCurNum = self.mCurNum + 1
end
function LoadingMemoryLayer:loadImage()
	cc.Director:getInstance():getTextureCache():addImageAsync("DartBlood.png",imageLoaded)  
	local texture0 = cc.Director:getInstance():getTextureCache():addImage( "Images/grossini_dance_atlas.png")  
	  
	function LoadingScene.imageLoaded( pObj)  
	    -- body  
	end  
	  
	cc.Director:getInstance():getTextureCache():removeTextureForKey("Images/grossinis_sister1-testalpha.png")  
	cc.Director:getInstance():getTextureCache():removeAllTextures()  
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()  
	  
	local cache = cc.SpriteFrameCache:getInstance()  
	cache:addSpriteFrames("animations/grossini_gray.plist", "animations/grossini_gray.png")  
	SpriteFrameTest.m_pSprite1 = cc.Sprite:createWithSpriteFrameName("grossini_dance_01.png")
end


return LoadingMemoryLayer