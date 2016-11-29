require("app.GUI.roomView.ChipPointDefine")
require("app.GUI.roomView.RoomViewDefine")
local MusicPlayer = require("app.Tools.MusicPlayer")
require("app.GlobalConfig")
local scheduler = require("framework.scheduler")

--[[筹码方向(以筹码图像为参照)]]
kNone = -1
kLeft = 0
kRight = 1

CHIPS_MOVE_ACTION_DURATION          =0.5        --筹码座位移动动画时间间隔
CHIPS_MOVETO_SEAT_ACTION_DURATION   =0.5        --玩家下筹码动画时间间隔
CHIPS_MOVETO_POT_ACTION_DURATION    =1.0        --收筹码到奖池动画时间间隔
if TRUNK_VERSION == DEBAO_TRUNK then
	POT_MOVETO_SEAT_ACTION_DELAY        =1.0        --开始派奖动画前的延迟(等待收筹码完成)
	POT_MOVETO_SEAT_ACTION_DURATION     =1.0        --派奖时间间隔
else
	POT_MOVETO_SEAT_ACTION_DELAY        =0.7        --开始派奖动画前的延迟(等待收筹码完成)
	POT_MOVETO_SEAT_ACTION_DURATION     =0.7        --派奖时间间隔
end

zAnimationChipBg = 1
zAnimationChipImg = 2
zAnimationChipLabel = 3

local AnimationChips = class("AnimationChips", function()
		return display.newNode()
	end)

--[[供外部调用的接口-begin]]
function AnimationChips:create(seatNum, seatNo, chip)
	local p = AnimationChips:new()
	p:initWithNum(seatNum,seatNo,chip)
	-- p:ignoreAnchorPointForPosition(false)
	return p
end

function AnimationChips:ctor()
	self.m_chipImg = nil
	self.m_eDirect = kNone
	self.m_nSeatNo = -1
	self.m_nSeatNum = -1
	self.m_dAddChip = 0
	self.m_dTotalChip = 0
	self.m_pTarget = nil
	self.m_pCallback = nil
	self.m_pParam = nil
	self.m_bHasCallback = false
	
	-- self:setNodeEventEnabled(true)
end

-- function AnimationChips:onExit()

-- end

function AnimationChips:initWithNum(seatNum, seatNo, chip)
	--[[添加布局]]
	self.m_chipImg = cc.Sprite:create(C_CHIP_LABLE_PATH)
	self.m_chiBg = cc.Sprite:create(C_CHIP_BACK_PATH)
	self.m_chipLabel = require("app.GUI.roomView.ChipLabel"):
		create(chip,"picdata/gamescene/chipNumSmall.fnt",-1)
    self.m_seatChip = chip

	self.m_nSeatNo  = seatNo
	self.m_nSeatNum = seatNum
    
    self.m_contentSize = self.m_chipImg:getContentSize()
	self:setContentSize(self.m_chipImg:getContentSize())
	self.m_chipImg:setAnchorPoint(cc.p(0,0))
	self.m_chipImg:setPosition(cc.p(0,0))
	self:addChild(self.m_chipImg,zAnimationChipImg)
    
	self.m_chiBg:setAnchorPoint(cc.p(0,0))
	self.m_chiBg:setPosition(cc.p(0,0))
	self:addChild(self.m_chiBg,zAnimationChipBg)
    
	-- local doMove = cca.moveTo(3, 0.001, 0)
	-- self.m_chipLabel:runAction(doMove)
	self:setDirection(getDirectBySeatNoAndSeatNum(seatNo,seatNum),false)

	self:addChild(self.m_chipLabel,zAnimationChipLabel)

	self:setAnchorPoint(cc.p(0,1))
	self:setPosition(getRoundChipPosWith(seatNum,seatNo))


	return true
end

	--[[设置添加筹码动画筹码数量]]
function AnimationChips:setAddChipNum(addChip)  
	self.m_dAddChip = addChip
end
    
	--[[获取座位号]]
function AnimationChips:getSeatNo() 
	return self.m_nSeatNo
end

function AnimationChips:setDirection(direct, animation)
	if(direct == self.m_eDirect) then
		return
    end
    if self.m_nSeatNo == 0 then
    	direct = 0
    end
	if direct == 1 then
		self.m_eDirect = kRight
		self:setDirectToRight(animation)
	else
		self.m_eDirect = kLeft
		self:setDirectToLeft(animation)
	end
end

function AnimationChips:setDirectToLeft(animation)
	if((self.m_chipLabel == nil) or (self.m_chipImg == nil)) then
		return 
	end
	
    local size = self.m_chipImg:getContentSize()
    self.m_chipLabel:setAnchorPoint(cc.p(0, 0.5))
    self.m_chipLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT)

    self.m_chipLabel:setPosition(cc.p(size.width + 3, size.height / 2))
    
    self.m_chiBg:setAnchorPoint(cc.p(0,0.5))
    self.m_chiBg:setPosition(cc.p(size.width / 2-17, size.height / 2))
end

function AnimationChips:setDirectToRight(animation)

	if((self.m_chipLabel == nil) or (self.m_chipImg == nil)) then
		return
    end
    local size = self.m_chipImg:getContentSize()
    self.m_chipLabel:setAnchorPoint(cc.p(1, 0.5))
    self.m_chipLabel:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self.m_chipLabel:setPosition(cc.p( - 3, size.height / 2))
    
    self.m_chiBg:setAnchorPoint(cc.p(1,0.5))
    self.m_chiBg:setPosition(cc.p(size.width / 2+17,size.height / 2))
end

function AnimationChips:clearFromParent()
	self:getParent():removeChild(self, true)
end

function AnimationChips:hideSelf()

	self:setVisible(false)
end

function AnimationChips:delayDisplayMy()

	self.m_chipImg:setOpacity(255)
	self.m_chipLabel:setOpacity(255)
end

function AnimationChips:changeBgVisible()

	self.m_chiBg:setVisible(true)
end

function AnimationChips:changeBgInvisible()

 --  	self.m_chipLabel:setVisible(true)
	-- self.m_chipLabel:setOpacity(255)
	self.m_chiBg:setVisible(false)
end



function AnimationChips:changChipLableAfterAnimation()

	if(self.m_pCallback and self.m_pParam) then
		self.m_pCallback(self.m_pParam)
	end
end

--延迟后播放派奖声音
function AnimationChips:delayPlaySound()

	MusicPlayer:getInstance():playPrizeChipsSound()
end

--下筹码动画
function AnimationChips:flyToUserRoundChip(chip, disappear, pTarget, pCallback, pParam, hasCallback)

	local startPos = getHandChipPosWith(self.m_nSeatNum,self.m_nSeatNo)
	local endPos   = getRoundChipPosWith(self.m_nSeatNum,self.m_nSeatNo)
    self.m_seatChip = chip
    
	self.m_bHasCallback = hasCallback
	self.m_pTarget = pTarget
	self.m_pCallback = pCallback
	self.m_pParam = pParam
  	
	self:setPosition(startPos)

	local MaxActionCount = 5
    
	local actionArray = {}
	actionArray[#actionArray+1]=cc.CallFunc:create(handler(self,self.changeBgInvisible))
	
	local doMove = cc.MoveTo:create(CHIPS_MOVETO_SEAT_ACTION_DURATION,endPos)
    actionArray[#actionArray+1]=cc.EaseExponentialOut:create(doMove)
    actionArray[#actionArray+1]=cc.CallFunc:create(handler(self,self.changeBgVisible))
	
	if(self.m_bHasCallback) then
		actionArray[#actionArray+1]=cc.CallFunc:create(handler(self,self.hideSelf))
		actionArray[#actionArray+1]=cc.CallFunc:create(handler(self,self.changChipLableAfterAnimation))
	end
	
	if(disappear) then
		actionArray[#actionArray+1]=cc.CallFunc:create(handler(self,self.clearFromParent))
	end

	self:runAction(cc.Sequence:create(actionArray))
end

--收筹码
function AnimationChips:flyToDealerAndDisappear(potIndex)

	local startPos = getRoundChipPosWith(self.m_nSeatNum,self.m_nSeatNo)
    
	self:setPosition(startPos)
	local doMove = cc.MoveTo:create(CHIPS_MOVETO_POT_ACTION_DURATION,getPrizePotPosWith(potIndex))
    
	--add by wang(收筹码时候数目逐渐隐藏)
	local fadeOut = cc.FadeOut:create(CHIPS_MOVETO_POT_ACTION_DURATION-0.4)
	self.m_chipLabel:runAction(fadeOut)
    
	self:runAction(cc.Sequence:create(cc.CallFunc:create(handler(self, self.changeBgInvisible)),
        cc.EaseExponentialOut:create(doMove),cc.CallFunc:create(handler(self,self.clearFromParent))))
end

--派奖
function AnimationChips:flyToWinerAndDisappear(chip, potIndex, toPerson)

	--modify by wang
	self:setPosition(getPrizePotPosWith(potIndex))
	local doMoveTo = cc.MoveTo:create(POT_MOVETO_SEAT_ACTION_DURATION,getHandChipPosWith(self.m_nSeatNum,self.m_nSeatNo))
    
	--add by wang(收筹码时候数目逐渐显示)
	self.m_chipLabel:setOpacity(0)
	local   fadeIn = cc.FadeIn:create(0.1)
	self.m_chipLabel:runAction(cc.Sequence:create(cc.DelayTime:create(POT_MOVETO_SEAT_ACTION_DELAY),fadeIn))
    
	self:runAction(cc.Sequence:create(
                                       cc.CallFunc:create(handler(self,self.changeBgInvisible)),
                                       cc.DelayTime:create(POT_MOVETO_SEAT_ACTION_DELAY),
                                       cc.EaseExponentialOut:create(doMoveTo),
                                       cc.CallFunc:create(handler(self,self.clearFromParent))))
    
	--异步播放派奖声音
	self:runAction( cc.Sequence:create(
                                        cc.DelayTime:create(POT_MOVETO_SEAT_ACTION_DELAY),
                                        cc.CallFunc:create(handler(self,self.delayPlaySound)))
                    )
    
	--add by wang
	if(potIndex == 1) then
	
		self.m_chipImg:setOpacity(0)
		self.m_chipLabel:setOpacity(0)
		--self:scheduleOnce(schedule_selector(AnimationChips:delayDisplayMy),POT_MOVETO_SEAT_ACTION_DELAY)
		self:runAction( cc.Sequence:create(
                                            cc.DelayTime:create(POT_MOVETO_SEAT_ACTION_DELAY),
                                            cc.CallFunc:create(handler(self,self.delayDisplayMy))
                                           )
                        )
	end
end

function AnimationChips:runAddChipAnimation()

	if(self.m_dAddChip > 0) then
	
		self.m_chipLabel:addChips(self.m_dAddChip)
        self.m_seatChip = self.m_chipLabel.m_realChips
		self.m_dTotalChip = self.m_dTotalChip + self.m_dAddChip
	end
end

--移动到哪个座位的偏移
function AnimationChips:moveWithOffset(offset)

	local tmpArray = {}
    
	local tmp = self.m_nSeatNo
	for i=0,math.abs(offset) do
	
		if(offset>0) then
		
			tmp = tmp + 1
			tmp = tmp % self.m_nSeatNum
            
			local headMoveTo = cc.MoveTo:create(CHIPS_MOVE_ACTION_DURATION,getRoundChipPosWith(self.m_nSeatNum,tmp))
			tmpArray[#tmpArray+1] = headMoveTo
			--改变cell方向
			self:setDirection(getDirectBySeatNoAndSeatNum(tmp,self.m_nSeatNum))
		else
		
			if(tmp == 0) then
				tmp = self.m_nSeatNum-1
			else 
				tmp = tmp - 1
            end
			local headMoveTo = cc.MoveTo:create(CHIPS_MOVE_ACTION_DURATION,getRoundChipPosWith(self.m_nSeatNum,tmp))
			tmpArray[#tmpArray+1] = headMoveTo
			
			--改变cell方向
			self:setDirection(getDirectBySeatNoAndSeatNum(tmp,self.m_nSeatNum))
		end
	end
    
	local action = cc.Sequence:create(tmpArray)
	self:runAction(action)
    
	self.m_nSeatNo = tmp
	tmpArray = nil
end

function AnimationChips:moveToSeatNo(toSeatNo)
	self.m_nSeatNo = toSeatNo
end

return AnimationChips	