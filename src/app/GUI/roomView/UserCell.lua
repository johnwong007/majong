require("app.GUI.roomView.UserCellDefine")
require("app.Tools.StringFormat")
require("app.GUI.roomView.RoomViewDefine")
--修改显示属性

		kOpFont = 0 --操作状态
		kWinFont = 1 --赢牌提示
		kNormalFont = 2 --正常
		kOutFont = 3 --不在牌局中
--        二次添加
        kNormalCall = 4
        kNormalAllIn = 5

local UserCell = class("UserCell",function()
		return display.newLayer()
	end)

function UserCell:ctor()

	self.m_headPicStr = ""   --玩家头像地址
	self.m_nDiamond = -1     --钻石等级 -1:无钻 1:黄钻 2：红钻 3：蓝钻
	self.m_sex = ""          --性别
	self.m_needSex = false
	self. m_currentDirection = 0 --头像方向

	self.m_seatNum = 0    --6/9人桌
	self.m_seatNO = 0     --当前所在座位（眼睛在界面看到的物理座位非逻辑座位）
	self.m_wholeName = ""  --名字全称
	self.m_showName = ""   --显示名称
	self.m_chipsNum = 0   --界面显示的筹码
	
    self.m_vipLevel = 0
	self.m_userId = ""     --用户Id
	self.m_bIsMySelf = false  --是否是登录用户
	self.m_bIsTrustee = false --当前状态暂离
	self.m_remainTime = 0--剩余操作时间
    
    self.m_percent = 0
    
    self:setNodeEventEnabled(true)
end

function UserCell:onExit()
		self:stopWaitAnimation(0)
		self:stopAllActions()
		-- cc.Director:getInstance():getScheduler():unscheduleAllSelectors()

    	if self.m_beginBA then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBA)
			self.m_beginBA = nil
		end
		if self.m_stopWA then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_stopWA)
			self.m_stopWA = nil
		end

		if self.m_changeRTB then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_changeRTB)
			self.m_changeRTB = nil
		end

		if self.m_nameLR then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_nameLR)
			self.m_nameLR = nil
		end
end

----------------------------------------------------------------------------
function UserCell:getSeatNum()
	return self.m_seatNO
end
function UserCell:getUserName()
	return self.m_wholeName
end
function UserCell:getUserId()
	return self.m_userId
end
function UserCell:seatOutClear()
	self:stopWaitAnimation(0)
	self:stopAllActions()
	-- self:unscheduleAllSelectors()

    if self.m_beginBA then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBA)
		self.m_beginBA = nil
	end
	if self.m_stopWA then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_stopWA)
		self.m_stopWA = nil
	end

	if self.m_changeRTB then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_changeRTB)
		self.m_changeRTB = nil
	end

	if self.m_nameLR then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_nameLR)
		self.m_nameLR = nil
	end
    self:getParent():removeChild(self, true)
end
----------------------------------------------------------------------------


--初始化
function UserCell:initWithInfo(seatNum, seatNo, sex, headPic, name, userId, isMySelf, diamond, needSex)
	if not self:init() then
		return false
	end
	self.m_seatNum    = seatNum
	self.m_seatNO     = seatNo
	self.m_sex        = sex
	self.m_headPicStr = headPic
	self.m_wholeName  = name
	self.m_bIsMySelf  = isMySelf
	self.m_nDiamond   = diamond
	self.m_needSex = needSex


	self.m_showName   = StringFormat:formatName(name,20)

	if self:isPhoneNo(name) then
		self.m_showName   = StringFormat:formatName(name,8)
	end

	self.m_userId     = userId
	self.m_bIsTrustee = false
	self.m_currentDirection = getDirectBySeatNoAndSeatNum(self.m_seatNO,self.m_seatNum)
    assert((self.m_seatNum == 2 or self.m_seatNum == 6 or self.m_seatNum == 9) and (self.m_seatNO >= 0 and self.m_seatNO <=8))
    return true
end

function UserCell:isPhoneNo(text)
	local len = string.len(text)
	local ret = true
	for i=1,len do
		local bt = string.byte(text,i,i)
		if bt<48 or bt>57 then
			ret = false 
			break
		end
	end
	if len~=11 then
		ret = true
	end
	return ret
end

--设置按钮响应事件
function UserCell:setCallBack(callback)
	self.m_callbackUI = callback
end

function UserCell:init()
	return true
end

function UserCell:setClickable(isClickable) 
	if(self.m_menuItem) then
		self.m_menuItem:setButtonEnabled(isClickable)
		self.m_menuItem:setTouchSwallowEnabled(isClickable)
	end
end


function UserCell:createViewElements()
	if(self.m_bIsMySelf) then
		self.m_menuItem = cc.ui.UIPushButton.new({normal=s_pMenuNormalSelf,
			pressed=s_pMenuSelected,disabled=s_pMenuNormalSelf})
		self.m_menuItem:onButtonClicked(handler(self, self.menuCallback))
		self.m_menuItem:align(display.CENTER, 0, 0)
		self.m_menuItem:setTouchSwallowEnabled(false)
	else

		self.m_menuItem = cc.ui.UIPushButton.new({normal=s_pMenuNormal,
			pressed=s_pMenuSelected,disabled=s_pMenuNormal})
		self.m_menuItem:onButtonClicked(handler(self, self.menuCallback))
		self.m_menuItem:align(display.CENTER, 0, 0)
        self.m_menuItem:setScale(0.73)
		self.m_menuItem:setTouchSwallowEnabled(false)
	end
	self:addChild(self.m_menuItem, 2)


	self:setContentSize(cc.size(150,150))

    --Head
    self.m_headSprite = require("app.GUI.HeadImage"):createWithImageUrl(HEADIMAGECACHEDIR,self.m_headPicStr,cc.size(142,142),
    	self.m_nDiamond,cc.size(23,17),self.m_sex,self.m_needSex)

    -- self.m_headSprite = cc.ui.UIImage.new("head1.png")
   
    self.m_headSprite:setPosition(cc.p(0,0))
    self.m_menuItem:addChild(self.m_headSprite,2)

    self.m_statusMask = cc.Sprite:create("maskCall.png")
    self.m_statusMask:setPosition(cc.p(0, 0))
    self.m_menuItem:addChild(self.m_statusMask,3)
    -- self:addChild(self.m_statusMask,3)
    self.m_statusMask:setVisible(false)
    --vip信息
    if ((self.m_vipLevel+0)>0) then
    	local tempChar = "picdata/public/vip/vip"..self.m_vipLevel..".png"
        
        self.m_vipIcon=cc.Sprite:create(tempChar)
        self.m_vipIcon:setAnchorPoint(cc.p(0,1))
        if(self.m_bIsMySelf) then
			self.m_vipIcon:setPosition(cc.pSub(C_UC_VIP_IS_SELF, cc.p(75, 75)))
        else
			self.m_vipIcon:setPosition(cc.pSub(C_UC_VIP_NOT_SELF, cc.p(75, 75)))
        end
        -- self.m_menuItem:addChild(self.m_vipIcon,20)
    end
    
	--Chips
	-- self.m_chipsLabel = cc.LabelTTF:create(""..self.m_chipsNum, "黑体", 24)
    self.m_chipsLabel = cc.LabelBMFont:create(""..self.m_chipsNum,"picdata/MainPage/goldNum.fnt")
    local chipBG = cc.Sprite:create("picdata/table/chipsBG.png")
    chipBG:setPosition(cc.pSub(C_UC_CHIP_LEFT_POS, cc.p(75, 55)))
    self.m_menuItem:addChild(chipBG,4)
    -- self:addChild(chipBG,4)
	self:setChips(self.m_chipsNum)
	if(self.m_currentDirection  == cell_left) then
		self.m_chipsLabel:setPosition(cc.pSub(C_UC_CHIP_LEFT_POS, cc.p(75, 55)))
	else
		self.m_chipsLabel:setPosition(cc.pSub(C_UC_CHIP_RIGHT_POS, cc.p(75, 55)))
	end
	self.m_menuItem:addChild(self.m_chipsLabel,4)
	-- self:addChild(self.m_chipsLabel,4)
    
    if(self.m_bIsMySelf) then
        chipBG:setPositionY(chipBG:getPositionY()+30)
        self.m_chipsLabel:setPositionY(self.m_chipsLabel:getPositionY()+30)
    end
    
    
    --Name
    -- self.m_nameLabel = cc.ui.UILabel.new({
    -- 	text = self.m_showName,
    -- 	font = TEXT_FONT,
    -- 	size = 26,
    -- 	align = cc.TEXT_ALIGNMENT_CENTER
    -- 	})

    self.m_nameLabel = cc.LabelTTF:create(self.m_showName, TEXT_FONT, 26)
    self.m_nameLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    self.m_nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
	if(self.m_currentDirection  == cell_left) then
		self.m_nameLabel:setPosition(cc.pSub(C_UC_NAME_LEFT_POS, cc.p(75, 70)))
	else
		self.m_nameLabel:setPosition(cc.pSub(C_UC_NAME_RIGHT_POS, cc.p(75, 70)))
	end
	self.m_menuItem:addChild(self.m_nameLabel, 4)
	-- self:addChild(self.m_nameLabel, 4)
    -- self.m_nameLabel:setColor(cc.c3b(0, 243, 255))
    self.m_nameLabel:setColor(cc.c3b(255, 255, 255))
    if(self.m_bIsMySelf) then
        self.m_nameLabel:setVisible(false)
    end
    
	--win type
	self.m_winTypeLabel = cc.LabelTTF:create("","fonts/FZZCHJW--GB1-0.TTF",32)
	self.m_winTypeLabel:setColor(cc.c3b(255,222,222))
	if(self.m_currentDirection == cell_left) then
	
		self.m_winTypeSprite = cc.Sprite:create(s_winCardBackgroundLeft)
		self.m_winTypeLabel:setPosition(cc.pSub(C_WIN_TYPE_LEFT_POS, cc.p(75, 75)))
	else
	
		self.m_winTypeSprite = cc.Sprite:create(s_winCardBackgroundRight)
		self.m_winTypeLabel:setPosition(cc.pSub(C_WIN_TYPE_RIGHT_POS, cc.p(75, 75)))
	end
    
	self.m_winTypeSprite:setAnchorPoint(cc.p(0.5,0.5))
	self.m_winTypeSprite:setPosition(cc.p(0,0))
    if (self.m_bIsMySelf) then
        self.m_winTypeSprite:setScale(1.2)
    end
    
	self:addChild(self.m_winTypeSprite,999)
	self:addChild(self.m_winTypeLabel,999)
    

	--聊天表情弹窗
	self.m_chatBubble = require("app.GUI.roomView.ChatBubble"):bubble()
	self:addChild(self.m_chatBubble,12)
    
	--UserCell所在的位置
	self:setPosition(getCellLocWith(self.m_seatNum,self.m_seatNO))
    
	self:changeShowFont(kNormalFont)
end

function UserCell:menuCallback(pSender)
	-- if self.m_callbackUI then
	-- 	self.m_callbackUI:userCellClick_Callback(self)
	-- end

	local clickedCell = self
	local userdata = {}
	userdata[USER_ID] = clickedCell:getUserId()
	userdata[USER_NAME] = clickedCell:getUserName()
	userdata[USER_PORTRAIT] = clickedCell.m_headPicStr
	userdata[USER_SEX] = clickedCell.m_sex
	userdata["VIP"] = clickedCell.m_vipLevel
	local FriendShowLayer = require("app.GUI.friends.FriendShowLayer")
	local layer = CMOpen(FriendShowLayer, self:getParent():getParent(),{nType = "PlayerInfo",userdata = userdata},0,kZOperateBoard)
end

function UserCell:onNodeEvent(tag)
	if tag == "exit" then
		self:onExit()
	end
end

function UserCell:changeShowFont(fontType)
	if fontType==kOpFont then
            self.m_statusMask:setOpacity(255)
            self.m_headSprite:setOpacity(0.2*255)
            self.m_menuItem:setOpacity(255)
    elseif fontType==kOutFont then
            self.m_statusMask:setOpacity(0.6*255)
            self.m_headSprite:setOpacity(0.6*255)
            self.m_menuItem:setOpacity(0.6*255)
    elseif fontType==kWinFont then
            self.m_statusMask:setOpacity(255)
            self.m_headSprite:setOpacity(255)
            self.m_menuItem:setOpacity(255)
    elseif fontType==kNormalFont then
            self.m_statusMask:setOpacity(255)
            self.m_headSprite:setOpacity(255)
            self.m_menuItem:setOpacity(255)
    elseif fontType==kNormalCall then
            self.m_statusMask:setOpacity(255)
            self.m_headSprite:setOpacity(0.2*255)
            self.m_menuItem:setOpacity(255)
    elseif fontType==kNormalAllIn then
           	self. m_statusMask:setOpacity(255)
            self.m_headSprite:setOpacity(0.2*255)
            self.m_menuItem:setOpacity(255)
	end
    
	self.m_winTypeLabel:setVisible(fontType == kWinFont)
	self.m_winTypeSprite:setVisible(fontType == kWinFont)
    self:reorderChild(self.m_winTypeSprite, 999)
    self:reorderChild(self.m_winTypeLabel, 999)

    if (not self.m_bIsMySelf) then 
        self.m_nameLabel:setVisible(not (fontType == kWinFont))
    end
end

--改变图像方向动画
function UserCell:changeDirection(dir)
	if(dir == self.m_currentDirection) then 
		return
    end

	if(dir == cell_left) then
	
		self.m_currentDirection = cell_left
        
		local headMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_UC_PHOTO_LEFT_POS ,C_UC_PHOTO_RIGHT_POS))
		local nameMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_UC_NAME_LEFT_POS ,C_UC_NAME_RIGHT_POS))
		local chipMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_UC_CHIP_LEFT_POS ,C_UC_CHIP_RIGHT_POS))
		local typeMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_WIN_TYPE_LEFT_POS,C_WIN_TYPE_RIGHT_POS))
        
		self.m_headSprite:runAction(headMoveBy)
		self.m_nameLabel:runAction(nameMoveBy)
		self.m_chipsLabel:runAction(chipMoveBy)
		self.m_winTypeLabel:runAction(typeMoveBy)
		self.m_winTypeSprite:setTexture(cc.Sprite:create(s_winCardBackgroundLeft):getTexture())
		self.m_winTypeSprite:setAnchorPoint(cc.p(0.5,0.5))
		self.m_winTypeSprite:setPosition(cc.p(0, 0))
	else
	
		self.m_currentDirection = cell_right
        
		local headMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_UC_PHOTO_RIGHT_POS ,C_UC_PHOTO_LEFT_POS))
		local nameMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_UC_NAME_RIGHT_POS ,C_UC_NAME_LEFT_POS))
		local chipMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_UC_CHIP_RIGHT_POS ,C_UC_CHIP_LEFT_POS))
		local typeMoveBy = cc.MoveBy:create(CELL_ACTION_DURATION,cc.pSub(C_WIN_TYPE_RIGHT_POS,C_WIN_TYPE_LEFT_POS))
        
		self.m_headSprite:runAction(headMoveBy)
		self.m_nameLabel:runAction(nameMoveBy)
		self.m_chipsLabel:runAction(chipMoveBy)
		self.m_winTypeLabel:runAction(typeMoveBy)
		self.m_winTypeSprite:setTexture(cc.Sprite:create(s_winCardBackgroundRight):getTexture())
		self.m_winTypeSprite:setAnchorPoint(cc.p(0.5,0.5))
		self.m_winTypeSprite:setPosition(cc.p(0, 0))
	end
end

--设置玩家显示的筹码
function UserCell:setChips(chips)

	self:stopWaitAnimation(0)
    
	self.m_chipsNum = chips
	local str=StringFormat:FormatDecimals(self.m_chipsNum,2)
	self.m_chipsLabel:setString(str)
end
function UserCell:getChips()
    return self.m_chipsNum
end
--小盲
function UserCell:betSmallBlind()
    self.m_statusMask:setTexture(cc.Sprite:create("maskSB.png"):getTexture())
    self.m_statusMask:setVisible(true)
	self:changeShowFont(kOpFont)
end

--大盲
function UserCell:betBigBlind()
    self.m_statusMask:setTexture(cc.Sprite:create("maskBB.png"):getTexture())
    self.m_statusMask:setVisible(true)
	self:changeShowFont(kOpFont)
end

--跟注
function UserCell:call(chips)

	self:stopWaitAnimation(0)
    self.m_statusMask:setTexture(cc.Sprite:create("maskCall.png"):getTexture())
    self.m_statusMask:setVisible(true)
    self:changeShowFont(kNormalCall)
end
--加注
function UserCell:raise(chips)

	self:stopWaitAnimation(0)
    self.m_statusMask:setTexture(cc.Sprite:create("maskRaise.png"):getTexture())
    self.m_statusMask:setVisible(true)
	self:changeShowFont(kNormalCall)
end
--Allin
function UserCell:allIn()

	self:stopWaitAnimation(0)
    self.m_statusMask:setTexture(cc.Sprite:create("maskAllin.png"):getTexture())
    self.m_statusMask:setVisible(true)
	self:changeShowFont(kNormalAllIn)
end
--弃牌
function UserCell:fold()

	self:stopWaitAnimation(0)
    
	if(not self.m_bIsTrustee) then
        self.m_statusMask:setTexture(cc.Sprite:create("maskFold.png"):getTexture())
        self.m_statusMask:setVisible(true)
		self:changeShowFont(kOutFont)
	end
end
--看牌
function UserCell:check()

	self:stopWaitAnimation(0)
    
	if(not self.m_bIsTrustee) then
        self.m_statusMask:setTexture(cc.Sprite:create("maskCheck.png"):getTexture())
        self.m_statusMask:setVisible(true)
		self:changeShowFont(kOpFont)
	end
end
--Win
function UserCell:winType(_type)

	self:stopWaitAnimation(0)
    
	--未赢玩家重置姓名
	if(_type == 10) then
	
		if(not self.m_bIsTrustee) then
		
			-- self.m_menuItem:unselected()
			-- self.m_menuItem:setButtonSelected(false)
			self.m_nameLabel:setString(self.m_showName)
			self:changeShowFont(kNormalFont)
            self.m_statusMask:setVisible(false)
		end
		return
	end
    
	local tmp = ""
	if _type == 0 then
            tmp = "高牌赢"
    elseif _type == 1 then
            tmp = "对子赢"
    elseif _type == 2 then
            tmp = "两对赢"
    elseif _type == 3 then
            tmp = "三条赢"
    elseif _type == 4 then
            tmp = "顺子赢"
    elseif _type == 5 then
            tmp = "同花赢"
    elseif _type == 6 then
            tmp = "葫芦赢"
    elseif _type == 7 then
            tmp = "四条赢"
    elseif _type == 8 then
            tmp = "同花顺赢"
    elseif _type == 9 then
            tmp = "皇家同花顺赢"
    else
            tmp = "赢牌"
	end
    
	-- self.m_menuItem.state = "selected"
	self.m_winTypeLabel:setString(tmp)
	self:changeShowFont(kWinFont)

	self.m_nameLR = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		handler(self, self.nameLabelReset), CELL_NAMELABEL_CHANGE_DURATION, false)
end
--暂离
function UserCell:leaveForMoment()

	self:stopWaitAnimation(0)
    
	self.m_bIsTrustee = true
    self.m_statusMask:setTexture(cc.Sprite:create("maskAFK.png"):getTexture())
    self.m_statusMask:setVisible(true)
	self:changeShowFont(kOutFont)
end

--取消托管
function UserCell:cancelTrustee()

	self:stopWaitAnimation(0)
    
	self.m_bIsTrustee = false
    self.m_statusMask:setVisible(false)
	self:changeShowFont(kNormalFont)
end

--移动到哪个座位的偏移
function UserCell:moveWithOffset(offset)
	local tmpArray = {}
   
	local tmp = self.m_seatNO
	dump(self.m_seatNO)
	for i=0,math.abs(offset)-1 do
	
		if(offset>0) then
		
			tmp = tmp+1
	 		tmp = tmp % self.m_seatNum
            
			local headMoveTo = cc.MoveTo:create(CELL_MOVE_ACTION_DURATION,getCellLocWith(self.m_seatNum,tmp))
			tmpArray[#tmpArray+1] = headMoveTo
            
			--改变cell方向
			self:changeDirection(getDirectBySeatNoAndSeatNum(tmp,self.m_seatNum))
		else
		
			if(tmp == 0) then 
				tmp = self.m_seatNum-1
	 		else 
	 			tmp = tmp-1
            end

			local headMoveTo = cc.MoveTo:create(CELL_MOVE_ACTION_DURATION,getCellLocWith(self.m_seatNum,tmp))
			tmpArray[#tmpArray+1] = headMoveTo
            
			--改变cell方向
			self:changeDirection(getDirectBySeatNoAndSeatNum(tmp,self.m_seatNum))
		end
	end
    
	local action = cc.Sequence:create(tmpArray)
	self:runAction(action)
    
	self.m_seatNO = tmp
end

--延迟以后nameLabel恢复显示姓名
function UserCell:nameLabelReset(dt)

	-- self.m_menuItem:unselected()
	-- self.m_menuItem:setButtonSelected(false)
	if(self.m_bIsTrustee) then
	
        self.m_statusMask:setTexture(cc.Sprite:create("maskFold.png"):getTexture())
        self.m_statusMask:setVisible(true)
		self:changeShowFont(kOutFont)
	else
	
		self.m_nameLabel:setString(self.m_showName)
		self:changeShowFont(kNormalFont)
	end
	if self.m_nameLR then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_nameLR)
		self.m_nameLR = nil
	end
end

--显示聊天气泡
function UserCell:showChatMsg(isMyself, msg, faceUseChips)

	if(self.m_chatBubble) then
	
		if(msg and string.len(msg)>0 and string.sub(msg,1,1) ~= '/') then
			self.m_chatBubble:setPosition(cc.p(0,30))  --聊天
		else
			self.m_chatBubble:setPosition(cc.p(0,20))  --表情
        end
		self.m_chatBubble:show(msg,self.m_currentDirection == cell_left and eLeftBubble or eRightBubble)
        
		if(faceUseChips>0 and isMyself) then
		
			--显示扣钱
			local chipsF = "-"
			local chipsStr=StringFormat:FormatDecimals(faceUseChips,2)
			chipsF=chipsF..chipsStr
			local faceChips = cc.LabelTTF:create(chipsF,"Arial", 24)
			faceChips:setColor(cc.c3b(255,255,0))
			self:addChild(faceChips, 2)
			faceChips:setPosition(cc.p(0,-10))
            
			--fadein
			local  fadeOut   = cc.FadeOut:create(1.0)
			local  action2 = cc.Sequence:create(fadeOut,cc.CallFuncN:create(handler(self,self.faceSubChipsFinish)))
			faceChips:runAction(action2)
		end
	end
end

--显示表情扣筹码动画
function UserCell:faceSubChipsFinish(pObj)

	pObj:stopAllActions()
	pObj:getParent():removeChild(pObj, true)
end

------------------------------------------------------------------------
							--[[坐下动画]]
------------------------------------------------------------------------

SITANIMATIONTIME =0.4
SCALEANIMSIT     =0.8
SCALEANIMFADE    =0.3
SCALETONUM       =0.02

function UserCell:animationForSit()

	if(not self.sitAnimSp1 and not self.sitAnimSp2) then
	
		self.sitAnimSp1 = cc.Sprite:create(s_pSpSitAnim1)
		self.sitAnimSp1:setPosition((self.m_seatNum == 6) and C_UC_PHOTO_RIGHT_POS or C_UC_PHOTO_LEFT_POS)
		self:addChild(self.sitAnimSp1,2)
        
		self.sitAnimSp2 = cc.Sprite:create(s_pSpSitAnim2)
		self.sitAnimSp2:setPosition((self.m_seatNum == 6) and C_UC_PHOTO_RIGHT_POS or C_UC_PHOTO_LEFT_POS)
		self:addChild(self.sitAnimSp2,2)
        --------------------------------------------
		local  scale     = cc.ScaleBy:create(SITANIMATIONTIME, SCALEANIMSIT)
		local  scaleRev  = scale:reverse()
		local seq1     = cc.Sequence:create(scale, scaleRev)
		local repeatRev1 = cc.Repeat:create(seq1,3)
        
		local  action1 = cc.Sequence:create(repeatRev1,cc.CallFunc:create(handler(self,self.animationSitCallback1)))
		self.sitAnimSp1:runAction(action1)
        --------------------------------------------
		--1
		local  fadeOut    = cc.FadeOut:create(SITANIMATIONTIME)
		local  fadeOutRev = fadeOut:reverse()
		local seq2      = cc.Sequence:create(fadeOut, fadeOutRev)
		local repeatRev2  = cc.Repeat:create(seq2,3)
        
		--2
		local  scale2     = cc.ScaleBy:create(SCALEANIMFADE, SCALETONUM)
		local  fadeOut2   = cc.FadeOut:create(SCALEANIMFADE)
		local  scale_and_fadeOut  = cc.Spawn:create(scale2,fadeOut2)
        
		local  action2 = cc.Sequence:create(repeatRev2,scale_and_fadeOut,cc.CallFunc:create(handler(self,self.animationSitCallback2)))
		self.sitAnimSp2:runAction(action2)
	end
end

function UserCell:animationSitCallback1()

	self.sitAnimSp1:stopAllActions()
	self.sitAnimSp1:getParent():removeChild(self.sitAnimSp1, true)
    
	self.sitAnimSp1     = nil
end

function UserCell:animationSitCallback2()

	self.sitAnimSp2:stopAllActions()
	self.sitAnimSp2:getParent():removeChild(self.sitAnimSp2, true)
    
	self.sitAnimSp2     = nil
end

------------------------------------------------------------------------
						--[[绘制倒计时有关操作]]
------------------------------------------------------------------------

BLINK_BEGIN_TIME =5  --剩余多少时间时候开始跳动

--停止动画
function UserCell:stopWaitAnimation(dt)

	if(self.m_sprite or self.m_waitAnimationSp) then
	
		self.m_waitAnimationSp:stopAllActions()
		self.m_waitAnimationSp:getParent():removeChild(self.m_waitAnimationSp, true)
		self.m_waitAnimationSp = nil
        self.m_sprite = nil
        if self.m_beginBA then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_beginBA)
			self.m_beginBA = nil
		end
		if self.m_stopWA then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_stopWA)
			self.m_stopWA = nil
		end
	end
end

--开始跳动
function UserCell:beginBlinkAnimation(dt)
    if(self.m_sprite) then
    
        local  action1 = cc.Blink:create(BLINK_BEGIN_TIME, 10)
        self.m_sprite:runAction( action1)
    end
end

--轮到自己操作剩余时间
function UserCell:waitForMsg(remainTime, totalTime)
    self.m_statusMask:setVisible(false)
	if(not self.m_sprite and not self.m_waitAnimationSp) then
	
		--轮到自己显示姓名
		self.m_nameLabel:setString(self.m_showName)
		self:changeShowFont(kNormalFont)
        
		self.m_waitRedBG = cc.Sprite:create(s_pSpWaitBG_Green)
        if (not self.m_bIsMySelf) then
            self.m_waitRedBG:setScale(0.73)
        end
		self.m_waitRedBG:setPosition(cc.p(0,0))
        
		remainTime=remainTime+1.0   --服务器延时补充1.0秒
		local tmpPercentf = (remainTime+0.0)/(totalTime+0.0)
		local tmpPercenti = tmpPercentf*100
        self.m_sprite = cc.Sprite:create(s_pSpWaitBG_Green)
		self.m_waitAnimationSp = cc.ProgressTimer:create(self.m_sprite)
        if (not self.m_bIsMySelf) then
            self.m_waitAnimationSp:setScale(0.73)
        end
		self.m_waitAnimationSp:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
		self.m_waitAnimationSp:setReverseDirection(true)
        self.m_waitAnimationSp:setPosition(cc.p(0,0))
--        self.m_waitAnimationSp:setSkewX(-1)
        self.m_waitAnimationSp:setPercentage(100)---tmpPercenti
		self:addChild(self.m_waitAnimationSp,3)

--		self.m_waitAnimationSp:runAction( cc.progressTo:create(remainTime, 100))
        self.m_waitAnimationSp:runAction(cc.ProgressFromTo:create(remainTime, 100, 0))

		--什么时候开始闪动
		if(remainTime <= BLINK_BEGIN_TIME ) then
		
			self:beginBlinkAnimation(0.0)
		else
		self.m_beginBA = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
			handler(self, self.beginBlinkAnimation), remainTime-BLINK_BEGIN_TIME, false)
		end
		self.m_remainTime = remainTime

		self.m_changeRTB = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
			handler(self, self.changeRemainTimeBackground), 0, false)

		--超时时候自动停止动画
		self.m_stopWA = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
			handler(self, self.stopWaitAnimation), remainTime, false)
	end
end

function UserCell:changeRemainTimeBackground(dt)
	if self==nil or self.m_sprite== nil then
		if self.m_changeRTB then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_changeRTB)
			self.m_changeRTB = nil
		end
		return
	end

    if(self.m_remainTime <= 4) then
	
		if(self.m_sprite) then
		
			self.m_sprite:setTexture(cc.Sprite:create(s_pSpWaitBG_Red):getTexture())
--            self.m_sprite:setColor(cc.c3b(11,92,100))
		end
	elseif(self.m_remainTime <= 8) then
	
		if(self.m_sprite) then
		
			self.m_sprite:setTexture(cc.Sprite:create(s_pSpWaitBG_Yellow):getTexture())
--            self.m_sprite:setColor(cc.c3b(255,252,20))
			if self.m_changeRTB then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_changeRTB)
			end
			self.m_changeRTB = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
				handler(self, self.changeRemainTimeBackground), self.m_remainTime - 4, false)
			self.m_remainTime = 4
		end
	else
	
		if(self.m_sprite) then
		
			self.m_sprite:setTexture(cc.Sprite:create(s_pSpWaitBG_Green):getTexture())
--            self.m_sprite:setColor(cc.c3b(114,255,20))
			if self.m_changeRTB then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_changeRTB)
			end
			self.m_changeRTB = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
				handler(self, self.changeRemainTimeBackground), self.m_remainTime - 8, false)
			self.m_remainTime = 8
		end
		
	end
    
end

--更新显示信息
function UserCell:updateUserShowInfo(imageURL, userName)

	if(self.m_headSprite) then
	
		self.m_headPicStr = imageURL
		self.m_headSprite:changeHead(imageURL)
	end
    
	if(self.m_nameLabel) then
	
		local strLastName = self.m_showName
		self.m_wholeName = userName
		self.m_showName  = StringFormat:formatName(userName,20)
		if(self.m_nameLabel:getString() == strLastName) then
		
			self.m_nameLabel:setString(self.m_showName)
		end		
	end
end

function UserCell:updateUserVipLevel(userid, viplevel)
	if true then
		return
	end 
    self.m_vipLevel=viplevel
    
    if(0+viplevel>0) then
    
        if (self.m_vipIcon) then
        	self.m_vipIcon:getParent():removeChild(self.m_vipIcon, true)
        end
        local tempChar = "picdata/public/vip/vip"..viplevel..".png"
        
        self.m_vipIcon=cc.Sprite:create(tempChar)
        self.m_vipIcon:setAnchorPoint(cc.p(0,1))
        if(self.m_bIsMySelf) then
        
            self.m_vipIcon:setPosition(C_UC_VIP_IS_SELF)
        else
        
            self.m_vipIcon:setPosition(C_UC_VIP_NOT_SELF)
        end
        -- self:addChild(self.m_vipIcon,20)
    end
    
    
end

function UserCell:updateUserSngPKInfo(winTimes)

	if (not self.m_SngInfo) then
        
		self.m_SngInfo = cc.LabelTTF:create("", "黑体", 16,
                                       cc.size(0,0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		if(self.m_currentDirection == cell_left) then
			self.m_SngInfo:setPosition(C_UC_SNG_INFO_LEFT_POS)
		else
			self.m_SngInfo:setPosition(C_UC_SNG_INFO_RIGHT_POS)
		end
		addChild(self.m_SngInfo, 1)
	end
	self.m_SngInfo:setString(""..winTimes)
end

function UserCell:getUserHeadView()

	local head = require("app.GUI.HeadImage"):createWithImageUrl(HEADIMAGECACHEDIR,self.m_headPicStr,
		cc.size(50.0,50.5),self.m_nDiamond,cc.size(23,17),self.m_sex,self.m_needSex)
	-- local headBG = CMCreateHeadBg("",cc.size(50.0,50.5))

	return headBG
end







----------------------------------------------------------------------------
return UserCell