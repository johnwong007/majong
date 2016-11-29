local MusicPlayer = require("app.Tools.MusicPlayer")
local PlayerView = class("PlayerView", function(event)
		return display.newNode()
	end)
-- local PlayerView = class("PlayerView")
require("app.GUI.roomView.RoomViewDefine")

function PlayerView:ctor()
	self.m_roomView = nil
	self.m_seatNO   = -1
	self.m_seatNum  = -1
	self.m_poker1   = nil
	self.m_poker2   = nil
	self.m_userCell = nil
	self.m_chatBubble = nil
end

function PlayerView:initWithInfo(roomView, selSafa, seatNum, seatId)
	-- normal_info_log("PlayerView:initWithInfo 玩家视图初始化")
	if roomView and selSafa then
		self.m_roomView = roomView
		self.m_seatNum  = seatNum
		self.m_seatNO   = seatId
		self.m_boolHasSitAnimation = false
		self.m_boolIsMyWin = false
        
		--safa
		-- local normalImage = cc.Sprite:create(s_room_safaN)
		-- local selectedImage = cc.Sprite:create(s_room_safaS)
		-- local pItem = cc.MenuItemImage:create()
		-- pItem:setNormalImage(normalImage)
		-- pItem:setSelectedImage(selectedImage)
		-- pItem:registerScriptTapHandler(selSafa)
		-- pItem:setPosition(cc.p(0,0))
		-- self.m_safaMenu = cc.Menu:create(pItem)

		self.m_safaMenu = cc.ui.UIPushButton.new({normal=s_room_safaN,selected=s_room_safaS,
			disabled=s_room_safaS})
		 self.m_safaMenu:onButtonClicked(function(event)
            selSafa(event.target) 
            end)
		self.m_safaMenu:setTouchSwallowEnabled(false)
		self.m_safaMenu:align(display.CENTER, 0, 0)

		self.m_safaMenu:setPosition(getSafaLocWith(self.m_seatNum,self.m_seatNO))
		self.m_roomView:addChild(self.m_safaMenu,kZOperateBoard,SAFAMENUTAG+self.m_seatNO)
       	self.m_myPokerMask = cc.ui.UIImage.new("picdata/table/myPokerMask.png")
        self.m_myPokerMask:setPosition(cc.p(620+LAYOUT_OFFSET.x,67+24))
        self.m_roomView:addChild(self.m_myPokerMask,kZOperateBoard-1)
        self.m_myPokerMask:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_myPokerMask:setScaleY(0.1)
        self.m_myPokerMask:setVisible(false)
	end
end
--[[辅助接口]]
-------------------------------------------------------
--[[显示沙发(自己坐下时候始终无法显示，当自己站起且别人站起显示沙发)]]
function PlayerView:displayMySafa()
	if not self.m_userCell then
		self.m_safaMenu:setVisible(true)
	end
end
--[[隐藏沙发]]
function PlayerView:hiddenMySafa()
	self.m_safaMenu:setVisible(false) --[[不管有没人在坐]]
end
function PlayerView:getSeatID() 
	return self.m_seatNO
end
function PlayerView:getUserId() 
	return self.m_userId 
end
function PlayerView:hasMyWin()
	return self.m_boolIsMyWin
end
function PlayerView:resetMyWined() 
	self.m_boolIsMyWin=false 
end
function PlayerView:hasUpedPoker(cardV)
	if not self.m_poker1 or not self.m_poker2 then
		return false
	end
	return (self.m_poker1.m_pokerName == cardV or self.m_poker2.m_pokerName == cardV)
end
-------------------------------------------------------
--[[玩家接收的所有操作]]
--坐下
function PlayerView:seat(callback, sex, headPic, name, userId, isMySelf, diamond, needSex)
	--隐藏沙发
	self.m_safaMenu:setVisible(false)
	self.m_userId = userId
    
	self.m_userCell = require("app.GUI.roomView.UserCell"):new() 
	if self.m_userCell then
		self.m_userCell:initWithInfo(self.m_seatNum,self.m_seatNO,sex,headPic,
			name,userId,isMySelf,diamond,needSex)
		self.m_userCell:setCallBack(callback)
		self.m_roomView:addChild(self.m_userCell,kZUserCell)
		self.m_userCell:createViewElements()
	end
end
--站起
function PlayerView:seatOut()
	self:removeTrusteeshipProtectCountDown()
	if self.m_userCell then
		self.m_userCell:seatOutClear()
		self.m_userCell = nil
	end
	if self.m_poker1 then
		self.m_poker1:clearPoker()
		self.m_poker1 = nil
	end
	if self.m_poker2 then
		self.m_poker2:clearPoker()
		self.m_poker2 = nil
	end


	self.m_userId = nil
end
--发牌
function PlayerView:dispatchPoker(isMySelf, index, delay, pokerName, isAnimation)
	if index == 0 then
        -- if isMySelf then
        	if self.m_poker1 ~= nil then
        		self.m_poker1:removeFromParent(true)
        		self.m_poker1=nil
        	end
        	if self.m_poker1 == nil then
        		self.m_poker1 = require("app.GUI.roomView.Poker"):new() 
        	end
            if self.m_poker1 then
				self.m_poker1:initWithInfo(self.m_seatNum,self.m_seatNO,index,pokerName)
            	self.m_roomView:addChild(self.m_poker1,kZDispatchCard)
            	self.m_poker1:createViewElements()
            	self.m_poker1:setVisible(true)
            	self.m_poker1:dispatchPoker(isMySelf,isAnimation,delay,index)
				--Music
				if isMySelf then
                	-- self.m_poker1:switchFrontBack()
                	self.m_poker1.m_isMySelf = true
                    self.m_poker1:setRotation(-8.0)
                end
				MusicPlayer:getInstance():playDispatchCardSound()
			end
	end

	if(index ==1) then
        if self.m_poker2 ~= nil then
        	self.m_poker2:removeFromParent(true)
        	self.m_poker2=nil
        end
		if self.m_poker2 == nil then
            self.m_poker2 = require("app.GUI.roomView.Poker"):new()
		end
        if self.m_poker2 then
                self.m_poker2:initWithInfo(self.m_seatNum,self.m_seatNO,index,pokerName)
                self.m_roomView:addChild(self.m_poker2,kZDispatchCard)
                self.m_poker2:createViewElements()
            	self.m_poker2:setVisible(true)
                self.m_poker2:dispatchPoker(isMySelf,isAnimation,delay,index)
                --Music
                if isMySelf then
                	-- self.m_poker2:switchFrontBack()
                	self.m_poker2.m_isMySelf = true
	                self.m_poker2:setRotation(6.0)
                end
                
                MusicPlayer:getInstance():playDispatchCardSound()
        end
    end

    
    if isMySelf then

    --     if (self.m_poker1 and self.m_poker2) then
    --         -- if (isAnimation) then
				-- self.m_poker1:retain()
    --     		self.m_poker2:retain()
    --             -- if(self.m_myPokerMask) then
    --             --     self.m_myPokerMask:setVisible(false)
    --             -- end
                
    --             local delayTime = cc.DelayTime:create(0.1)
    --             -- local delayRemove = cc.Sequence:create(delayTime,cc.CallFunc:create(handler(self,self.removePoker)))
    --             local removeAndShow = cc.Spawn:create(cc.CallFunc:create(handler(self,self.showMask)),delayRemove)
         
    --             local seqX = cc.Sequence:create(cc.DelayTime:create(delay+0.8),cc.CallFunc:create(handler(self,self.myPokerMove)),
    --             	cc.DelayTime:create(0.2),removeAndShow)
    --             self.m_roomView:runAction(seqX)
    --         -- else
    --             -- if(self.m_tmpPoker1) then
    --             --     self.m_tmpPoker1:clearPoker()
    --             --     self.m_tmpPoker1 = nil
    --             -- end
    --             -- if(self.m_tmpPoker2) then
    --             --     self.m_tmpPoker2:clearPoker()
    --             --     self.m_tmpPoker2 = nil
    --             -- end

    --             -- local clipper = cc.ClippingNode:create()
    --             -- clipper:setTag(233)
    --             -- clipper:setContentSize(  cc.size(200, 200) )
    --             -- clipper:setAnchorPoint(  cc.p(0.5, 0.5) )
    --             -- clipper:setPosition( cc.p(620+LAYOUT_OFFSET.x, 90+100))
    --             -- --    clipper:setRotation(20)
    --             -- --    clipper:runAction(CCRepeatForever:create(CCRotateBy:create(1, 45)))
    --             -- local stencil = cc.DrawNode:create()
    --             -- local rectangle = {}
    --             -- rectangle[1] = cc.p(0, 0)
    --             -- rectangle[2] = cc.p(clipper:getContentSize().width, 0)
    --             -- rectangle[3] = cc.p(clipper:getContentSize().width, clipper:getContentSize().height)
    --             -- rectangle[4] = cc.p(0, clipper:getContentSize().height)
    --             -- -- clipper:getParent():removeChild(clipper, true)
                
    --             -- local white = cc.c4b(255,255,255,255)
    --             -- stencil:drawPolygon(rectangle, white, 4, white)
    --             -- clipper:setStencil(stencil)
    --             -- self.m_roomView:addChild(clipper,kZOperateBoard-1)

    --             -- if self.m_poker1:getParent() then
    --             -- 	self.m_poker1:getParent():removeChild(self.m_poker1, false)
    --             -- end
    --             -- if self.m_poker2:getParent() then
    --             -- 	self.m_poker2:getParent():removeChild(self.m_poker2, false)
    --             -- end

    --             -- self.m_poker1:setPosition(cc.p(65, 20))
    --             -- self.m_poker2:setPosition(cc.p(136, 20))
                -- self.m_poker1:setScale(1.2)
                -- self.m_poker2:setScale(1.2)
                -- self.m_poker1:switchFrontBack()
                -- self.m_poker2:switchFrontBack()

    --             -- clipper:addChild(self.m_poker1,22)
    --             -- clipper:addChild(self.m_poker2,23)
                
    --             -- self.m_myPokerMask:setVisible(true)
    --             -- self.m_myPokerMask:setScale(1.0)
                
    --             -- self.m_roomView:reorderChild(self.m_myPokerMask, kZOperateBoard-1)
    --         -- end
    --     end
    end
    
end

function PlayerView:myPokerMove()
    local pk1MoveBy = cc.MoveBy:create(0.2, cc.p(0, -20))
    local pk2MoveBy = cc.MoveBy:create(0.2, cc.p(0, -20))
    if (self.m_tmpPoker1) then
        self.m_tmpPoker1:runAction(cc.EaseExponentialIn:create(pk1MoveBy))
    end
    if (self.m_tmpPoker2) then
        self.m_tmpPoker2:runAction(cc.EaseExponentialIn:create(pk2MoveBy))
    end
end

function PlayerView:removePoker()
    
    if(self.m_tmpPoker1) then
    	
        self.m_tmpPoker1:clearPoker()
        self.m_tmpPoker1 = nil
    end
    if(self.m_tmpPoker2) then
    
        self.m_tmpPoker2:clearPoker()
        self.m_tmpPoker2 = nil
    end
end

function PlayerView:showMask()
    local clipper = cc.ClippingNode:create()
    clipper:setTag(233)
    clipper:setContentSize(  cc.size(200, 200) )
    clipper:setAnchorPoint(  cc.p(0.5, 0.5) )
    clipper:setPosition( cc.p(620+LAYOUT_OFFSET.x, 90+100))
    local stencil = cc.DrawNode:create()
    local rectangle = {}
    rectangle[1] = cc.p(0, 0)
    rectangle[2] = cc.p(clipper:getContentSize().width, 0)
    rectangle[3] = cc.p(clipper:getContentSize().width, clipper:getContentSize().height)
    rectangle[4] = cc.p(0, clipper:getContentSize().height)
    -- clipper:getParent():removeChild(clipper, true)
    
    local white = cc.c4b(255,255,255,255)
    stencil:drawPolygon(rectangle, white, 4, white)
    clipper:setStencil(stencil)
    self.m_roomView:addChild(clipper,kZOperateBoard-1)
    self.m_poker1:setPosition(cc.p(75, -60))
    self.m_poker2:setPosition(cc.p(126, -60))
    self.m_poker1:setScale(1.2)
    self.m_poker2:setScale(1.2)
    self.m_poker1:switchFrontBack()
    self.m_poker2:switchFrontBack()
    self.m_poker1:setRotation(-3.0)
    self.m_poker2:setRotation(3.0)
    
    if self.m_poker1:getParent() == nil then
    	clipper:addChild(self.m_poker1,22)
    	self.m_poker1:release()
	end
	if self.m_poker2:getParent() == nil then
		clipper:addChild(self.m_poker2,23)
    	self.m_poker2:release()
    end

    self.m_poker1:runAction(cc.RotateTo:create(1.0, -8.0))
    self.m_poker2:runAction(cc.RotateTo:create(1.0, 6.0))
    self.m_poker1:runAction(cc.MoveTo:create(1.0, cc.p(65, 20)))
    self.m_poker2:runAction(cc.MoveTo:create(1.0, cc.p(136, 20)))
    self.m_myPokerMask:setVisible(true)

    self.m_myPokerMask:runAction(cc.ScaleTo:create(1.0, 1.0, 1.0))

    self.m_roomView:reorderChild(self.m_myPokerMask, kZOperateBoard-1)
end

--翻牌
function PlayerView:switchPoker(index, pokerName)
	if(index ==0 and self.m_poker1) then
	
		self.m_poker1:showPoker(pokerName)
		self.m_roomView:reorderChild(self.m_poker1, kZFirstHandCard)  --将poker从cell后面提前
	end
	if(index ==1 and self.m_poker2) then
	
		self.m_poker2:showPoker(pokerName)
		self.m_roomView:reorderChild(self.m_poker2, kZFirstHandCard)  --将poker从cell后面提前
	end
end
--高亮牌
function PlayerView:highLightPoker(index)

	if(index ==0 and self.m_poker1) then
	
		self.m_poker1:highLightPoker()
	end
	if(index ==1 and self.m_poker2) then
	
		self.m_poker2:highLightPoker()
	end
end
--取消高亮牌
function PlayerView:cancelHighLightPoker(index)

	if(index ==0 and self.m_poker1) then
	
		self.m_poker1:cancelHighLightPoker()
	end
	if(index ==1 and self.m_poker2) then
	
		self.m_poker2:cancelHighLightPoker()
	end
end
--赢牌
function PlayerView:winWithType(type)

	if(self.m_userCell) then
	
		self.m_boolIsMyWin = true
		self.m_userCell:winType(type)
	end
end
--上移牌
function PlayerView:winPokerUp(cardV)

	if(self.m_poker1) then
		self.m_poker1:winPokerUp(cardV)
	end
	if(self.m_poker2) then
		self.m_poker2:winPokerUp(cardV)
	end
end
--下移牌
function PlayerView:winPokerDown()

	if(self.m_poker1) then
		self.m_poker1:winPokerDown()
	end
	if(self.m_poker2) then
		self.m_poker2:winPokerDown()
	end
end
--加灰
function PlayerView:winPokerMask()

	if(self.m_poker1) then
		self.m_poker1:winPokerMask()
	end
	if(self.m_poker2) then
		self.m_poker2:winPokerMask()
	end
end
--取消加灰
function PlayerView:winPokerCancelMask()

	if(self.m_poker1) then
		self.m_poker1:winPokerCancelMask()
	end
	if(self.m_poker2) then
		self.m_poker2:winPokerCancelMask()
	end
end
--盖牌(未亮的一张牌)
function PlayerView:showDownUp(index)

	if(index ==0 and self.m_poker1) then
	
		self.m_poker1:showDownUpPoker()
	end
	if(index ==1 and self.m_poker2) then
	
		self.m_poker2:showDownUpPoker()
	end
end
function PlayerView:setVisiable(isVisiable)
	if (self.m_userCell) then
	
		self.m_userCell:setVisible(isVisiable)
	end
end

--清牌
function PlayerView:clearPoker()

	if(self.m_poker1) then
	
		self.m_poker1:clearPoker()
		self.m_poker1 = nil
	end
	if(self.m_poker2) then
	
		self.m_poker2:clearPoker()
		self.m_poker2 = nil
	end

    self.m_myPokerMask:setVisible(false)
end
--移座位
function PlayerView:moveWithOffset(offset)
	if(self.m_userCell) then 
		self.m_userCell:moveWithOffset(offset)
	end
	if(self.m_safaMenu) then
		self:safaMoveWithOffset(offset)
	end

	if self.m_trusteeshipProtectCountDown then
		self:countDownMoveWithOffset(offset)
	end
    
	if(self.m_poker1) then
		self.m_poker1:moveWithOffset(offset)
	end
	if(self.m_poker2) then
		self.m_poker2:moveWithOffset(offset)
	end
    
	self.m_seatNO = self.m_seatNO + offset
    
	if(self.m_seatNO >= self.m_seatNum) then
		self.m_seatNO = self.m_seatNO % self.m_seatNum
	elseif(self.m_seatNO < 0) then
		self.m_seatNO = self.m_seatNO + self.m_seatNum
	end
end
--沙发移动
function PlayerView:safaMoveWithOffset(offset)

	local tmpArray = {}
    
	local tmp = self.m_seatNO
	for i=0,math.abs(offset)-1 do
	
		if(offset>0) then
		
			tmp = tmp + 1
			tmp = tmp % self.m_seatNum
            
			local headMoveTo = cc.MoveTo:create(CELL_MOVE_ACTION_DURATION,getCellLocWith(self.m_seatNum,tmp))
			tmpArray[#tmpArray+1] = headMoveTo
		else
		
			if(tmp == 0) then
				tmp = self.m_seatNum-1
			else 
				tmp = tmp - 1
            end
			local headMoveTo = cc.MoveTo:create(CELL_MOVE_ACTION_DURATION,getCellLocWith(self.m_seatNum,tmp))
			tmpArray[#tmpArray+1] = headMoveTo
		end
	end
    
	local  sequence = cc.Sequence:create(tmpArray)
	local  action = cc.Sequence:create(sequence,cc.CallFunc:create(handler(self,self.mySitAnimations2)))
	self.m_safaMenu:runAction(action)
end
--设置显示筹码
function PlayerView:setChips(chips)

	if(self.m_userCell) then
		self.m_userCell:setChips(chips)
	end
end

function PlayerView:getChips()
    if (self.m_userCell) then
        return self.m_userCell:getChips()
    end
    return 0
end
--轮到小盲
function PlayerView:smallBlind()

	if(self.m_userCell) then
		self.m_userCell:betSmallBlind()
	end
end
--轮到大盲
function PlayerView:bigBlind()

	if(self.m_userCell) then
		self.m_userCell:betBigBlind()
	end
end
--加注
function PlayerView:raise(isMyself, chips, isReRaise)

	if(self.m_userCell) then
		self.m_userCell:raise(chips)
	end
    
    if (not isMyself) then
        
        
        if(self.m_poker1) then
        	self.m_poker1:setScale(0.36)
        	self.m_poker1:movePokerWhileAct(false, 0)
        end
        if(self.m_poker2) then
        	self.m_poker2:setScale(0.36)
        	self.m_poker2:movePokerWhileAct(false, 1)
        end
    end
	--取消抖动
	if(self.m_poker1) then
		self.m_poker1:stopBlink(0)
	end
	if(self.m_poker2) then
		self.m_poker2:stopBlink(0)
    end
	--Music
	if isReRaise then
		MusicPlayer:getInstance():playReRaiseManSound()
	else
		MusicPlayer:getInstance():playRaiseManSound()
	end
	MusicPlayer:getInstance():playCallSound()
end
--跟注
function PlayerView:call(isMyself, chips)

	if(self.m_userCell) then
		self.m_userCell:call(chips)
    end
    if (not isMyself) then
        
        
        if(self.m_poker1) then
        	self.m_poker1:setScale(0.36)
        	self.m_poker1:movePokerWhileAct(false, 0)
        end
        if(self.m_poker2) then
        	self.m_poker2:setScale(0.36)
        	self.m_poker2:movePokerWhileAct(false, 1)
        end
    end
	--取消抖动
	if(self.m_poker1) then
		self.m_poker1:stopBlink(0)
	end
	if(self.m_poker2) then
		self.m_poker2:stopBlink(0)
    end
	--Music
	MusicPlayer:getInstance():playCallManSound()
	MusicPlayer:getInstance():playCallSound()
end
--Allin
function PlayerView:allIn(isMyself)

	if(self.m_userCell) then
		self.m_userCell:allIn()
    end
    if (not isMyself) then
        
        
        if(self.m_poker1) then
        	self.m_poker1:setScale(0.36)
        	self.m_poker1:movePokerWhileAct(false, 0)
        end
        if(self.m_poker2) then
        	self.m_poker2:setScale(0.36)
        	self.m_poker2:movePokerWhileAct(false, 1)
        end
    end
	--取消抖动
	if(self.m_poker1) then
		self.m_poker1:stopBlink(0)
	end
	if(self.m_poker2) then
		self.m_poker2:stopBlink(0)
    end
	--Music
    MusicPlayer:getInstance():playAllInManSound()
	MusicPlayer:getInstance():playCallSound()
end
--看牌
function PlayerView:check(isMyself)

	if(self.m_userCell) then
		self.m_userCell:check()
    end
    if (not isMyself) then
        
        
        if(self.m_poker1) then
        	self.m_poker1:setScale(0.36)
        	self.m_poker1:movePokerWhileAct(false, 0)
        end
        if(self.m_poker2) then
        	self.m_poker2:setScale(0.36)
        	self.m_poker2:movePokerWhileAct(false, 1)
        end
    end
	--取消抖动
	if(self.m_poker1) then
		self.m_poker1:stopBlink(0)
	end
	if(self.m_poker2) then
		self.m_poker2:stopBlink(0)
	end
    
	--Music
	MusicPlayer:getInstance():playCheckManSound()
	MusicPlayer:getInstance():playCheckSound()
end
--弃牌
function PlayerView:fold(isMyself, isTourneyAndTrust)
    if (not isMyself) then
        if(self.m_poker1) then
        	self.m_poker1:setScale(0.36)
        	self.m_poker1:movePokerWhileAct(false, 0)
        end
        if(self.m_poker2) then
        	self.m_poker2:setScale(0.36)
        	self.m_poker2:movePokerWhileAct(false, 1)
        end
    end
	if(self.m_userCell) then
		self.m_userCell:fold()
	end
	if(self.m_poker1) then
	
		self.m_poker1:stopBlink(0)
		self.m_poker1:fold(isMyself,isTourneyAndTrust)
	end
	if(self.m_poker2) then
	
		self.m_poker2:stopBlink(0)
		self.m_poker2:fold(isMyself,isTourneyAndTrust)
	end
	--Music
	MusicPlayer:getInstance():playFoldManSound()
	MusicPlayer:getInstance():playFoldSound()
end
--显示暂离
function PlayerView:timeOutTrustee()

	if(self.m_userCell) then
	
		self.m_userCell:leaveForMoment()
	end
end
--取消托管
function PlayerView:cancelTrustee()

	if(self.m_userCell) then
	
		self.m_userCell:cancelTrustee()
		self:removeTrusteeshipProtectCountDown()
	end
end
--轮到我操作
function PlayerView:waitForMsg(isMyself, remainTime, totalTime)

	if(self.m_userCell) then
		self.m_userCell:waitForMsg(remainTime,totalTime)
    end
	if(isMyself) then
	
	-- dump("====================================PlayerView:waitForMsg是我的Myself=========================================")
		--准备抖动
		if(self.m_poker1) then
			self.m_poker1:waitForBlink(remainTime)
		end
		if(self.m_poker2) then
			self.m_poker2:waitForBlink(remainTime)
        end
		--播放提醒
		MusicPlayer:getInstance():playWaitForSound()
	end
    if (not isMyself) then
        
        
        if(self.m_poker1) then
            self.m_poker1:setScale(0.45)
            self.m_poker1:movePokerWhileAct(true, 0)
        end
        if(self.m_poker2) then
            self.m_poker2:setScale(0.45)
            self.m_poker2:movePokerWhileAct(true, 1)
        end
    end
end

--停止等待操作
function PlayerView:resetWaitForMsg(isMyself, remainTime, totalTime)
	if(self.m_userCell) then
		self.m_userCell:stopWaitAnimation(0)
    end

        if(self.m_poker1) then
            self.m_poker1:stopBlink(0)
        end
        if(self.m_poker2) then
            self.m_poker2:stopBlink(0)
        end
    self:waitForMsg(isMyself, remainTime, totalTime)
end

function PlayerView:showTalkMsg(roomView, duration, isMyself)
	-- if(not UserDefaultSetting:getInstance():getBubbleEnable()) or self.m_userCell==nil then
	-- 	return
	-- end
	local image = cc.Sprite:create("picdata/table/qp_yy.png")
	local dir = getDirectBySeatNoAndSeatNum(self.m_seatNO, self.m_seatNum)
			print("m_seatNum:",self.m_seatNum,"m_seatNO:",self.m_seatNO)
	if dir == cell_left then
		-- image:setPosition(cc.p(-40,20))
		image:setPosition(cc.pAdd(getSafaLocWith(self.m_seatNum,self.m_seatNO),cc.p(-40,80)))
		image:setFlippedX(true)
	else
		-- image:setPosition(cc.p(40,20))
		image:setPosition(cc.pAdd(getSafaLocWith(self.m_seatNum,self.m_seatNO),cc.p(0,80)))
	end
	-- self.m_userCell:addChild(image,kZNewerGuide)
	roomView:addChild(image,kZNewerGuide)
	-- self.talkImage = image
local sequence = transition.sequence({
    cc.DelayTime:create(duration),
    cc.CallFunc:create(function(node)
    	node:removeFromParent(true)
    	end)
})
image:runAction(sequence)
end

--显示留座倒计时
function PlayerView:showTrusteeshipProtectCountDown(roomView, isMyself, remainTime)
	if self.m_trusteeshipProtectCountDown then
		self.m_trusteeshipProtectCountDown:setTimestamp(remainTime)
	else
		self.m_trusteeshipProtectCountDown = require("app.GUI.roomView.TrusteeshipProtectCountDown").new({
			timeStamp = remainTime,
			callback = handler(self,self.removeTrusteeshipProtectCountDown),
			isMyself = isMyself})
		self.m_trusteeshipProtectCountDown:create()
		self.m_trusteeshipProtectCountDown:setPosition(cc.pAdd(getSafaLocWith(self.m_seatNum,self.m_seatNO),cc.p(0,30)))
		self.m_trusteeshipProtectCountDown:addTo(roomView,kZNewerGuide)
	end
end

function PlayerView:removeTrusteeshipProtectCountDown()
	if self.m_trusteeshipProtectCountDown then
		self.m_trusteeshipProtectCountDown:removeFromParent(true)
		self.m_trusteeshipProtectCountDown = nil
	end
end

--倒计时移动
function PlayerView:countDownMoveWithOffset(offset)

	local tmpArray = {}
    
	local tmp = self.m_seatNO
	for i=0,math.abs(offset)-1 do
	
		if(offset>0) then
		
			tmp = tmp + 1
			tmp = tmp % self.m_seatNum
            
			local headMoveTo = cc.MoveTo:create(CELL_MOVE_ACTION_DURATION,cc.pAdd(getSafaLocWith(self.m_seatNum,tmp),cc.p(0,30)))
			tmpArray[#tmpArray+1] = headMoveTo
		else
		
			if(tmp == 0) then
				tmp = self.m_seatNum-1
			else 
				tmp = tmp - 1
            end
			local headMoveTo = cc.MoveTo:create(CELL_MOVE_ACTION_DURATION,cc.pAdd(getSafaLocWith(self.m_seatNum,tmp),cc.p(0,30)))
			tmpArray[#tmpArray+1] = headMoveTo
		end
	end
    
	local  sequence = cc.Sequence:create(tmpArray)
	local  action = sequence
	self.m_trusteeshipProtectCountDown:runAction(action)
end

--显示聊天
function PlayerView:showChatMsg(roomView, isMyself, msg, faceUseChips, bFace)

	if(not UserDefaultSetting:getInstance():getBubbleEnable()) or self.m_userCell==nil then
	
		return
	end
	MusicPlayer:getInstance():playChatBubbleSound()
	self.m_chatBubble = nil
	if(not self.m_chatBubble) then
	
		self.m_chatBubble = require("app.GUI.roomView.ChatBubble"):bubble()
		-- self.m_userCell:addChild(self.m_chatBubble,kZNewerGuide)
		self.m_roomView:addChild(self.m_chatBubble,kZNewerGuide)
	end

	if(msg and string.len(msg)>0 and not bFace) then
		self.m_chatBubble:setPosition(cc.pAdd(getSafaLocWith(self.m_seatNum,self.m_seatNO),cc.p(0,30)))  --聊天
		-- self.m_chatBubble:setPosition(cc.p(0,0))  --聊天
	else
		self.m_chatBubble:setPosition(cc.pAdd(getSafaLocWith(self.m_seatNum,self.m_seatNO),cc.p(0,20)))  --表情
		-- self.m_chatBubble:setPosition(cc.p(0,0))  --表情
    end
	self.m_chatBubble:show(msg,self.m_userCell.m_currentDirection == cell_left and eLeftBubble or eRightBubble,faceUseChips, bFace)
    
	if(faceUseChips>0 and isMyself) then
	
		--显示扣钱
		local chipsF = "-"
		local chipsStr=StringFormat:FormatDecimals(faceUseChips,2)
		chipsF = chipsF..chipsStr
		local faceChips = cc.LabelTTF:create(chipsF,"Arial", 24)
		faceChips:setColor(cc.c3b(255,255,0))
		roomView:addChild(faceChips, 2)
		faceChips:setPosition(cc.pAdd(getSafaLocWith(self.m_seatNum,self.m_seatNO),cc.p(0,-10)))
        
		--fadein
		local fadeOut   = cc.FadeOut:create(1.0)
		local  action2 = cc.Sequence:create(fadeOut,cc.CallFuncN:create(handler(self,self.faceSubChipsFinish)))
		faceChips:runAction(action2)
	end
	-- self:showTalkMsg(roomView, 0.4, true)
end
--自己坐下后的动画效果
function PlayerView:mySitAnimations1()

	self.m_boolHasSitAnimation = true
end
function PlayerView:mySitAnimations2()

	if(self.m_userCell) then
	
		if(self.m_boolHasSitAnimation) then
		
			self.m_boolHasSitAnimation = false
			self.m_userCell:animationForSit()
		end
	end
end

--牌手分
function PlayerView:cardHandPointChange(num)
	if num == 0 then
		return
	end
	local layer = require("app.GUI.roomView.CardHandPoint"):create(num)
	if layer==nil then
		return
	end
	if(self.m_roomView) then
		
		self.m_roomView:addChild(layer,kZFirstHandCard+1)
		layer:setPosition(getSafaLocWith(self.m_seatNum,self.m_seatNO))
		layer:showAndClear()
	end

end

function PlayerView:setClickable(isClickable)

	if(self.m_userCell) then
		self.m_userCell:setClickable(isClickable)
	end
end

--更新显示信息
function PlayerView:updateShowInfo(imageURL, userName)

	if(self.m_userCell) then
		self.m_userCell:updateUserShowInfo(imageURL,userName)
	end
end

function PlayerView:updateVipLevel(userid, viplevel)

    if(self.m_userCell) then
        self.m_userCell:updateUserVipLevel(userid,viplevel)
    end
end

function PlayerView:getUserHeadView()

	if (self.m_userCell) then
	
		return self.m_userCell:getUserHeadView()
	end
	return nil
end

function PlayerView:updateUserSngPKInfo(winTimes)

	if (self.m_userCell) then
	
		self.m_userCell:updateUserSngPKInfo(winTimes)
	end
end

function PlayerView:faceSubChipsFinish(pNode)
	pNode:stopAllActions()
end



return PlayerView