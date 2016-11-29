require("app.GUI.roomView.PokerDefine")
local MusicPlayer = require("app.Tools.MusicPlayer")

 BLINK_ACTION_TAG  =360
 MOVES_ACTION_TAG  =370

--[[牌大小变化：公共牌正常显示，手上的牌85%，背牌45%]]
HAND_POKER_SCALE =0.85
BACK_POKER_SCALE =0.45
if SHOW_GIGESET then
    POKER_BACK_NAME ="poker_back2"
else
    POKER_BACK_NAME ="poker_back"
end

local Poker = class("Poker", function()
		return display.newSprite()
	end)

function Poker:ctor()
	self.m_frontSprite     = nil
	self.m_backSprite      = nil
	self.m_highLightSprite = nil
	self.m_maskLayer       = nil
	self.m_pokerName = POKER_BACK_NAME
	self.m_seatNO = -1
	self.m_seatNum = -1
	self.m_pokerIndex = -1
    
	self.m_boolIsRotating  = false
	self.m_boolHasUp       = false
	self.m_isMySelf = false

   -- if self._camera == nil then
   --      self._camera = cc.Camera:createOrthographic(display.width,display.height,0,1)
   --      self._camera:setCameraFlag(cc.CameraFlag.USER4)
   --      self:addChild(self._camera)
   --      self._camera:setPosition3D(cc.vec3(0, 0, 0))
   --  end
   --  self:setCameraMask(5)

    self:setNodeEventEnabled(true)
if SHOW_GIGESET == true then
    POKER_BACK_NAME ="poker_back2"
else
    POKER_BACK_NAME ="poker_back"
end
end

function Poker:onNodeEvent(event)
    if event == "exit" then
    	self:onExit()
    end
end

function Poker:onExit()
	if self.m_beginBlinkAction then
		self:stopAction(self.m_beginBlinkAction)
	end	
	if self.m_stopBlinkAction then
		self:stopAction(self.m_stopBlinkAction)
	end
	self:stopAllActions()
		if self.m_beginBlinkId then
    		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBlinkId)
    		self.m_beginBlinkId = nil
    	end
    	if self.m_stopBlinkId then
    		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_stopBlinkId)
    		self.m_stopBlinkId = nil
		end
end

function Poker:getCamera()

 --    if self._camera == nil then
 --        self._camera = cc.Camera:createOrthographic(display.width,display.height,0,1)
 --        self._camera:setCameraFlag(cc.CameraFlag.USER4)
 --        self:addChild(self._camera)
 --        self._camera:setPosition3D(cc.vec3(0, 0, 0))
 --    	self:setCameraMask(5)
 --    end
	-- return self._camera
end

function Poker:init()

end

function Poker:createViewElements()
	local strFront = ""
	local strBack = ""
    
	strFront = strFront..POKER_RESOURCE_ROOT_PATH
	if(self.m_pokerName == "") then
		strFront = strFront..POKER_BACK_NAME
	else
		strFront = strFront..self.m_pokerName
	end
	strFront = strFront..".png"
	
	strBack = strBack..POKER_RESOURCE_ROOT_PATH
	strBack = strBack..POKER_BACK_NAME
	strBack = strBack..".png"
    
	self.m_frontSprite = cc.ui.UIImage.new(strFront)
	self.m_backSprite = cc.ui.UIImage.new(strBack)

	self.m_frontSprite:align(display.CENTER, 0, 0)
	self.m_backSprite:align(display.CENTER, 0, 0)
    
	self:addChild(self.m_frontSprite,0)
	self:addChild(self.m_backSprite, 1)
    
	self:setScale(BACK_POKER_SCALE)  --开始缩小 动画后*1.25=1.0
	-- self:setVisible(false)
    
	--首先放在庄家位 为了初始动画
	self:setPosition(cc.pAdd(LAYOUT_OFFSET,DEALER_LOC_POKER))
end

function Poker:initWithInfo(seatNum, seatNO, pokerIndex, name)
	self:init()
	self.m_seatNum    = seatNum
	self.m_seatNO     = seatNO
	self.m_pokerIndex = pokerIndex
	self.m_pokerName = name
    self.m_sQuadOri = self.m_sQuad

end

function Poker:rotateY(degree)
	local fRadSeed = 3.14159/180.0
    
--     --创建个旋转矩阵
--     kmMat4 kMat
--     kmMat4Identity(&kMat)
-- --    kmMat4RotationY(&kMat, degree*fRadSeed)
--     kmMat4RotationZ(&kMat, degree*fRadSeed)
    
--     ccVertex3F* v[4] = {&m_sQuad.bl.vertices, &m_sQuad.br.vertices, &m_sQuad.tl.vertices, &m_sQuad.tr.vertices}
--     ccVertex3F* vOri[4] = {&m_sQuadOri.bl.vertices, &m_sQuadOri.br.vertices, &m_sQuadOri.tl.vertices, &m_sQuadOri.tr.vertices}
    
--     --向量矩阵相乘
--     for(int i = 0 i < 4 ++i) {
--         float x = kMat.mat[0]*vOri[i]->x + kMat.mat[4]*vOri[i]->y + kMat.mat[8]*vOri[i]->z + kMat.mat[12]
--         float y = kMat.mat[1]*vOri[i]->x + kMat.mat[5]*vOri[i]->y + kMat.mat[9]*vOri[i]->z + kMat.mat[13]
--         float z = kMat.mat[2]*vOri[i]->x + kMat.mat[6]*vOri[i]->y + kMat.mat[10]*vOri[i]->z + kMat.mat[14]
        
--         v[i]->x = x
--         v[i]->y = y
--         v[i]->z = z
--     }
end

function Poker:delayPlaySound()
	MusicPlayer:getInstance():playDispatchCardSound()
end

function Poker:movePokerWhileAct(isAct, pokerIndex)
	local dispathAction = self:getActionByTag(MOVES_ACTION_TAG)
    if(dispathAction and not dispathAction:isDone()) then
        self:stopAction(dispathAction)
    end
    
    local isBackCard = self.m_pokerName == "" 
    self.m_boolIsMid = isAct
    if (isAct) then
        self:setPosition(getMidPokerLocWith(false,self.m_seatNum,self.m_seatNO,pokerIndex,isBackCard))
    else
        self:setPosition(getPokerLocWith(false,self.m_seatNum,self.m_seatNO,pokerIndex,isBackCard))
    end
end

function Poker:movePoker(dt)
	local isBackCard = (self.m_pokerName == "")
    if (self.m_boolIsMid) then
        self:setPosition(getMidPokerLocWith(false,self.m_seatNum,self.m_seatNO,self.m_pokerIndex,isBackCard))
    else
        self:setPosition(getPokerLocWith(false,self.m_seatNum,self.m_seatNO,self.m_pokerIndex,isBackCard))
    end
end

--[[
 从庄家位发牌
 如果是公牌 直接包含翻牌
 如果是玩家的牌 只发送不翻牌
]]
function Poker:dispatchPoker(isMySelf, isAnimation, delayTime, pokerIndex)
	self.m_isMySelf = isMySelf
	self:setVisible(true)
	local isBackCard = (self.m_pokerName == "")
	-- normal_info_log("Poker:dispatchPoker 发牌动画暂时取消")
	-- isAnimation = false
	if not isAnimation then
		self:setPosition(getPokerLocWith(isMySelf,self.m_seatNum,self.m_seatNO,self.m_pokerIndex,isBackCard))
		if(not isBackCard) then --公共牌和自己手牌
			if(self.m_seatNO == -1) then --community poker
				self:setScale(1.0)
				self:reorderChild(self.m_frontSprite,2)
				
				local orbit   = cc.OrbitCameraPoker:create(0.1,1, 0, 100, 80, 0, 0)
				self.m_frontSprite:setFlippedX(false)
				self:runAction(orbit)
			else--hand poker
                if (isMySelf) then
                    self:setScale(1.0)
                else
                    self:setScale(HAND_POKER_SCALE)
                end
				self:reorderChild(self.m_frontSprite,2)
				self:getParent():reorderChild(self, kZFirstHandCard)--将poker从cell后面提前
            end
		end
	else 	--[[有动画的发牌]]
		--[[先将牌翻到背面后面动画再翻回来]]
		self.m_frontSprite:setFlippedX(true)
        
		local  scale = nil
		if self.m_seatNO ~= -1 then
			if not isBackCard then
				self:getParent():reorderChild(self, kZFirstHandCard)  --将poker从cell后面提前
			end
            if (isMySelf) then
                scale  = cc.ScaleTo:create(POKER_DISP_ACTION_DURATION, 0.68)
            else
                scale  = cc.ScaleTo:create(POKER_DISP_ACTION_DURATION, 
                	isBackCard and BACK_POKER_SCALE or HAND_POKER_SCALE)
            end
		else
			scale = cc.ScaleTo:create(POKER_DISP_ACTION_DURATION,1.0)
			 
			local  move    = cc.MoveBy:create(POKER_DISP_ACTION_DURATION, cc.pSub(getPokerLocWith(self.m_isMySelf,self.m_seatNum,-1,
				self.m_pokerIndex,false),cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_POKER)))

            local  scale   = cc.ScaleTo:create(POKER_DISP_ACTION_DURATION, 1.0)       --公牌变为1.0
            local  orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 0, 100, 0, 0)
            
            local  move_and_scale  = cc.Spawn:create(move,scale)
            local  move_ease_out   = cc.EaseExponentialOut:create(move_and_scale)
            
            --        local  orbit1   = cc.OrbitCamera:create(0.1,1, 0, 0, 100, 0, 0)
            
            local  action = cc.Sequence:create(move_ease_out,orbit,cc.CallFunc:create(handler(self,self.switchFrontBack)))
            
            self:runAction(action)
            return
        end
        
		local  delay   = cc.DelayTime:create(delayTime)
		local  move    = cc.MoveBy:create(POKER_DISP_ACTION_DURATION, cc.pSub(getPokerLocWith(isMySelf,
			self.m_seatNum,self.m_seatNO,self.m_pokerIndex,isBackCard),cc.pAdd(LAYOUT_OFFSET,DEALER_LOC_POKER)))

		local  move_and_scale  = cc.Spawn:create(move,scale)
		local  move_ease_out   = cc.EaseExponentialOut:create(move_and_scale)

		local  action = nil
		if(isBackCard) then
			--座位玩家未明牌
			action = cc.Sequence:create(delay,move_ease_out)
			action:setTag(MOVES_ACTION_TAG)
		else
			--自己或者公牌 包含翻牌
            if (self.m_isMySelf) then
--                ,CCCallFunc:create(self, callfunc_selector(Poker:switchFrontBack))
                -- action = cc.Sequence:create(delay,cc.EaseExponentialOut:create(move_ease_out))
                -- local orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 0, 100, 0, 0)

                action = cc.Sequence:create(delay,move_ease_out,cc.CallFunc:create(handler(self,self.switchFrontBack)))
            else
                local orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 0, 100, 0, 0)
                action = cc.Sequence:create(delay,move_ease_out,orbit,cc.CallFunc:create(handler(self,self.switchFrontBack)))
            end
            
--            action = cc.Sequence:create(delay,move_ease_out)
            
			action:setTag(MOVES_ACTION_TAG)
		end
        
		self:runAction(action)
        
		--异步播放发牌的声音
		self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),
            cc.CallFunc:create(handler(self,self.delayPlaySound))))
                   
	end
end

function Poker:setRect(rect)
	if(self.m_frontSprite) then
		self.m_frontSprite:setTextureRect(rect)     --牌正面
	end
    if(self.m_backSprite) then
    	self.m_backSprite:setTextureRect(rect)      --牌背面
    end
    if(self.m_highLightSprite) then
    	self.m_highLightSprite:setTextureRect(rect) --高亮时候的红色边框
    end
    if(self.m_maskLayer) then
    	self.m_maskLayer:setTextureRect(rect)       --灰色蒙版
    end
end

--[[ 
 从玩家位置翻牌
 牌值
 ]]

function Poker:showPoker(name)
	if(self.m_pokerName ~= "" or not self.m_frontSprite) then
		return  --自己已经有手牌以后就不执行翻转了
    end
	local str = (name == "") and POKER_BACK_NAME or name
	self.m_pokerName = name
    
	self:stopAllActions()
	self.m_frontSprite:getParent():removeChild(self.m_frontSprite, true)  --把默认的背牌删掉先
	
	self.m_frontSprite = nil
    
	local strFront = ""
	strFront=strFront..POKER_RESOURCE_ROOT_PATH
	strFront=strFront..str
	strFront=strFront..".png"
	self.m_frontSprite = cc.Sprite:create(strFront)
	self:addChild(self.m_frontSprite,0)
    
	--先将牌翻到背面后面动画再翻回来
	self.m_frontSprite:setFlippedX(true)
    
    
    
	local   move    = cc.MoveTo:create(0.2, getMidPokerLocWith(self.m_isMySelf,self.m_seatNum,self.m_seatNO,self.m_pokerIndex,false))
	local   orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 0, 100, 0, 0)

	local action  = cc.Sequence:create(move,orbit,cc.CallFunc:create(handler(self,self.switchFrontBack)))
	self:runAction(cc.Spawn:create(action,cc.ScaleTo:create(0.2 +  POKER_SWITCH_ACTION_DURATION*0.5, 0.65)))
end

--[[翻牌动画]]
function Poker:switchFrontBack()
	
    self:reorderChild(self.m_frontSprite, 2)   --旋转了100度的时候将正面提前再执行翻转
    local  orbit = nil
    if(self.m_seatNO ~= -1) then
        orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 100, 80, 0, 0)
    else
        orbit   = cc.OrbitCameraPoker:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 100, 80, 0, 0)
		self.m_frontSprite:setFlippedX(false)
    end
	self:runAction(orbit)

	if (self.m_isMySelf) then
        self:setScale(1.0)
    end
end

--[[移动到哪个座位的偏移]]
function Poker:moveWithOffset(offset)
	--关闭可能在运行的发牌翻牌动作(发牌时候会发生)
	local dispathAction = self:getActionByTag(MOVES_ACTION_TAG)
	if(dispathAction and not dispathAction:isDone()) then
		self:stopAction(dispathAction)
	end
	--停止可能的抖动动画
	self:stopBlink(0)
    
	----------------------------------
	
	self.m_boolIsRotating = true
    
	local tmpArray = {}
    
	local isBackCard = (self.m_pokerName == "") and true or false
    
	local tmp = self.m_seatNO
	for i=0,math.abs(offset)-1 do
		if(offset>0) then
			tmp = tmp + 1
	 		tmp = tmp % self.m_seatNum
            
			local headMoveTo = cc.MoveTo:create(POKER_MOVE_ACTION_DURATION,getPokerLocWith(self.m_isMySelf,self.m_seatNum,tmp,self.m_pokerIndex,isBackCard))
			tmpArray[#tmpArray+1]=headMoveTo
		else
			if(tmp == 0) then
				tmp = self.m_seatNum-1
	 		else 
	 			tmp = tmp - 1
            end
			local headMoveTo = cc.MoveTo:create(POKER_MOVE_ACTION_DURATION,getPokerLocWith(self.m_isMySelf,self.m_seatNum,tmp,self.m_pokerIndex,isBackCard))
			tmpArray[#tmpArray+1]=headMoveTo
		end
	end
    
	local  sequence = cc.Sequence:create(tmpArray)
	local  action = cc.Sequence:create(sequence,cc.CallFunc:create(handler(self,self.rotateHasFinish)))
    
	self:runAction(action)
    
	self.m_seatNO = tmp
end

--[[旋转完成]]
function Poker:rotateHasFinish()
	self.m_boolIsRotating = false
end

--[[高亮牌]]
function Poker:highLightPoker()
	if(self.m_highLightSprite == nil) then
		self.m_highLightSprite = cc.Sprite:create(s_pPokerHighLight)
		self.m_highLightSprite:setPosition(cc.p(0,1))

		self:addChild(self.m_highLightSprite,3) --最高层
	end

end

--[[取消高亮]]
function Poker:cancelHighLightPoker()
	if(self.m_highLightSprite) then
		self.m_highLightSprite:getParent():removeChild(self.m_highLightSprite, true)
		self.m_highLightSprite = nil
	end
end

--[[突出牌]]
function Poker:winPokerUp(cardV)
	if(self.m_pokerName == cardV and not self.m_boolHasUp) then
		self.m_boolHasUp = true
	end
end

function Poker:winPokerDown()
	if(self.m_boolHasUp) then
		self.m_boolHasUp = false
	end
end

function Poker:winPokerMask()
	if(not self.m_boolHasUp) then
		--蒙版
		self.m_maskLayer = cc.Sprite:create(s_pPokerWinMask)
		self.m_maskLayer:setPosition(cc.p(0,0))
		self:addChild(self.m_maskLayer,3)
	end
end

function Poker:winPokerCancelMask()
	if(self.m_maskLayer and not self.m_boolHasUp) then
		self.m_maskLayer:getParent():removeChild(self.m_maskLayer, true)
		self.m_maskLayer = nil
	end
end

--[[
 盖牌
 选择亮牌后的那张不亮的牌行为
 ]]
function Poker:showDownUpPoker()
	if(self.m_frontSprite) then
		self:cancelHighLightPoker()
        
		self.m_frontSprite:getParent():removeChild(self.m_frontSprite, true)
		self.m_frontSprite = nil
	end
end

--[[移除牌]]
function Poker:clearPoker()
	self:stopBlink(0)
	-- self:unscheduleAllSelectors()
	if self.m_beginBlinkId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBlinkId)
    	self.m_beginBlinkId = nil
    end
    if self.m_stopBlinkId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_stopBlinkId)
    	self.m_stopBlinkId = nil
    end
	self:stopAllActions()
	self:getParent():removeChild(self, true)
end

--[[弃牌]]
function Poker:fold(isMyself, isTourneyAndTrust)
	--自己弃牌
	if(isMyself) then
		--关闭可能在运行的发牌翻牌动作(发牌时候会发生)
		local dispathAction = self:getActionByTag(MOVES_ACTION_TAG)
		if(dispathAction and not dispathAction:isDone()) then
			self:stopAction(dispathAction)
			--提前弃牌
			self.m_frontSprite:getParent():removeChild(self.m_frontSprite, true)
			self.m_frontSprite = nil
            
			local str = POKER_RESOURCE_ROOT_PATH .. self.m_pokerName .. ".png"
			self.m_frontSprite = cc.Sprite:create(str)
--            cc.Sprite:createWithSpriteFrameName("2d-4.png")
			if self.m_frontSprite then
				self:addChild(self.m_frontSprite,2)
			end
            
			--放到指定位置
			self:setPosition(getPokerLocWith(self.m_isMySelf,self.m_seatNum,self.m_seatNO,
				self.m_pokerIndex,(self.m_pokerName == "")and true or false))
		end
		--蒙版
        if (not self.m_maskLayer) then
            self.m_maskLayer = cc.Sprite:create(s_pPokerWinMask)
            self.m_maskLayer:setPosition(cc.p(0,0))
--            self.m_maskLayer:setTextureRect(cc.rect(0, 0, self.m_maskLayer:getTextureRect().size.width, self.m_maskLayer:getTextureRect().size.height/3*2))
        end

        if self.m_maskLayer:getParent() == nil then
			self:addChild(self.m_maskLayer,3)
		end
       self:setScale(1.0)
		self:cancelHighLightPoker()
--        self:setRect(cc.rect(0, 0, self.m_frontSprite:getTextureRect().size.width, self.m_frontSprite:getTextureRect().size.height/3*2))
	else
		--是锦标赛且被托管后弃牌时不需要任何动画
		if(isTourneyAndTrust) then
			-- self:clearPoker()
		else
			local   fadeOut = cc.FadeOut:create(POKER_DISP_ACTION_DURATION)
            
			local    moveTo = cc.MoveTo:create(POKER_DISP_ACTION_DURATION,cc.p(DEALER_LOC_POKER.x,DEALER_LOC_POKER.y-30))
			local    scale  = cc.ScaleBy:create(POKER_DISP_ACTION_DURATION, 0.5)
            
			local  move_and_scale = cc.Spawn:create(moveTo,scale)
			local    move_ease_out  = cc.EaseExponentialOut:create(move_and_scale)
            
			self.m_frontSprite:runAction(fadeOut)
			local backfadeOut = cc.FadeOut:create(POKER_DISP_ACTION_DURATION)
			self.m_backSprite:runAction(backfadeOut)
            
			self:runAction(move_ease_out)
		end
	end
end

BLINK_BEGIN_TIME  =5  --剩余多少时间时候开始跳动

function Poker:waitForBlink(remainTime)
	if(self.m_boolIsRotating) then
		return
    end
	remainTime=remainTime+1   --服务器延时补充1秒

    --什么时候开始闪动
	if(remainTime <= BLINK_BEGIN_TIME ) then
		self:beginBlink(0.0)
	else
		-- self.m_beginBlinkId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		-- 	handler(self,self.beginBlink),remainTime-BLINK_BEGIN_TIME,false)
	self.m_beginBlinkAction = transition.execute(self, cc.DelayTime:create(remainTime-BLINK_BEGIN_TIME),{
				onComplete = function()
					self:beginBlink(0.0)
				end
			})
	end
    
	--定时停止动画
	-- self.m_stopBlinkId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
	-- 	handler(self,self.stopBlink),remainTime,false)
	self.m_stopBlinkAction = transition.execute(self, cc.DelayTime:create(remainTime),{
				onComplete = function()
					self:stopBlink(0.0)
				end
			})
end

function Poker:beginBlink(dt)
	-- dump("====================================Poker:beginBlink=========================================")
	MusicPlayer:getInstance():playActionWillTimeout()
    MusicPlayer:getInstance():callVibrate()
    if self.m_beginBlinkId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBlinkId)
		self.m_beginBlinkId = nil
	end
end

function Poker:stopBlink(dt)
	-- dump("====================================Poker:stopBlink=========================================")
	MusicPlayer:getInstance():stopActionWillTimeout()
	-- self:stopAllActions()
	if self.m_beginBlinkAction then
		self:stopAction(self.m_beginBlinkAction)
	end	
	if self.m_stopBlinkAction then
		self:stopAction(self.m_stopBlinkAction)
	end
	if self.m_beginBlinkId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBlinkId)
    	self.m_beginBlinkId = nil
    end
    if self.m_stopBlinkId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_stopBlinkId)
    	self.m_stopBlinkId = nil
	end

	-- if(self:getActionByTag(BLINK_ACTION_TAG)) then
	-- 	self:stopActionByTag(BLINK_ACTION_TAG)
	-- 	self:setPosition(getPokerLocWith(self.m_isMySelf,self.m_seatNum,self.m_seatNO,
	-- 		self.m_pokerIndex,(self.m_pokerName == "") and true or false))
	-- end
end

function Poker:setPokerVertex(pTL, pBL, pTR, pBR)
	-- Top Left
    --
    self.m_sQuadOri.tl.vertices.x = pTL.x
    self.m_sQuadOri.tl.vertices.y = pTL.y
    -- Bottom Left
    --
    self.m_sQuadOri.bl.vertices.x = pBL.x
    self.m_sQuadOri.bl.vertices.y = pBL.y
    -- Top Right
    --
    self.m_sQuadOri.tr.vertices.x = pTR.x
    self.m_sQuadOri.tr.vertices.y = pTR.y
    -- Bottom Right
    --
    self.m_sQuadOri.br.vertices.x = pBR.x
    self.m_sQuadOri.br.vertices.y = pBR.y
    
    self.setContentSize(cc.size(0, pTL.y - pBL.y))
end

--[[
 前三张公共牌的动画
 分三步：1.发到第一张公牌位置 2.在公牌位置转牌 3.从第一张公牌位置平移到自己位置
]]
function Poker:animationWithPublicCard31(isAnimation)
	self:setVisible(true)

	-- normal_info_log("Poker:animationWithPublicCard31 发牌动画暂时取消")
	-- isAnimation = false
	if not isAnimation then
		local pos = getPokerLocWith(self.m_isMySelf,self.m_seatNum,self.m_seatNO,self.m_pokerIndex,false)
		self:setPosition(pos)
		self:setScale(1.0)
		self:reorderChild(self.m_frontSprite, 2)


		local orbit   = cc.OrbitCameraPoker:create(0.1,1, 0, 100, 80, 0, 0)
		self.m_frontSprite:setFlippedX(false)
		self:runAction(orbit)
	else
		self.m_frontSprite:setFlippedX(true)
        
		local  move    = cc.MoveBy:create(POKER_DISP_ACTION_DURATION, cc.pSub(getPokerLocWith(self.m_isMySelf,self.m_seatNum,-1,0,false),cc.pAdd(LAYOUT_OFFSET,DEALER_LOC_POKER)))
		local  scale   = cc.ScaleTo:create(POKER_DISP_ACTION_DURATION, 1.0)       --公牌变为1.0
		local  orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 0, 100, 0, 0)
        
		local  move_and_scale  = cc.Spawn:create(move,scale)
		local   move_ease_out   = cc.EaseExponentialOut:create(move_and_scale)
        
        local  action = cc.Sequence:create(move_ease_out,orbit,cc.CallFunc:create(handler(self,self.animationWithPublicCard32)))
        
		self:runAction(action)
		self:delayPlaySound()
	end
end

function Poker:testEye()

end

function Poker:animationWithPublicCard32()
	self:reorderChild(self.m_frontSprite, 2)   --旋转了100度的时候将正面提前再执行翻转
--        	local  orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 100, 80, 0, 0)

	--翻转后移动
    local  orbit   = cc.OrbitCamera:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 100, 80, 0, 0)

	local  move    = cc.MoveBy:create(POKER_SWITCH_ACTION_DURATION*2,cc.pSub(getPokerLocWith(self.m_isMySelf,self.m_seatNum,-1,self.m_pokerIndex,false),getPokerLocWith(self.m_isMySelf,self.m_seatNum,-1,0,false)))
    
    local  orbit1   = cc.OrbitCameraPoker:create(POKER_SWITCH_ACTION_DURATION*0.5,1, 0, 100, 80, 0, 0)
	local action = cc.Sequence:create(orbit1,move)
	self:runAction(action)
    self.m_frontSprite:setFlippedX(false)
end



return Poker