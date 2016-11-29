	kNGCNone = 0--不显示
	kNGCPocketGreatCallRaise = 1--您的底牌很大哦，可以跟注/加注
	kNGCPocketPairCallRaise = 2--您的底牌为口袋对子，可以跟注/加注
	kNGCPocketCautious = 3--又有人下注了哦！请谨慎下注！
	kNGCPocketGoodCallRaise = 4--您的底牌还不错哦，可以跟注/加注！
	kNGCPocketHigh = 5--您的牌型为高牌，不建议您跟注加注，请谨慎玩牌
	kNGCFlopGreatRaise = 6--哇！您的牌很大哦！赶紧加注吧
	kNGCFlopAllIn = 7--有人ALL IN了哦！请谨慎下注！
	kNGCFlopCautious = 8--您的牌型一般！请谨慎下注！
	kNGCTurnSelf = 9--轮到您自己操作了哦！

	kTechControlNone = 0
	kTechControlEnter = 1
	kTechControlPocket = 2
	kTechControlFlop = 3
	kTechControlTurn = 4
	kTechControlRiver = 5


COLOR_COUNT = 4
NUM_COUNT = 13
----------------------------------------------------------


SimplePoker = class("SimplePoker")

function SimplePoker:ctor()

end

function SimplePoker:getColor()
	return self.m_color
end

function SimplePoker:getNum()
	return self.m_num
end

--[[simple poker for judge]]
function SimplePoker:setSimplePoker(name)
	local pos,_ = string.find(name,"")
	if pos == nil then
		return
	end
	local subLeft = string.sub(name,1,1)
	local subRight = string.sub(name,-(string.len(name)-2))

	local color = self:getColorValue(subLeft)
	local num = self:getNumValue(subRight)
	if color == -1 or num == -1 then
		return
	end

	self.m_color   = color
	self.m_num     = num
	self.m_name    = name
	self.m_correct = true
end

function SimplePoker:getNumValue(num)
	if(num == ("A")) then
		return 14
	elseif(num == ("2")) then
		return 2
	elseif(num == ("3")) then
		return 3
	elseif(num == ("4")) then
		return 4
	elseif(num == ("5")) then
		return 5
	elseif(num == ("6")) then
		return 6
	elseif(num == ("7")) then
		return 7
	elseif(num == ("8")) then
		return 8
	elseif(num == ("9")) then
		return 9
	elseif(num == ("10")) then
		return 10
	elseif(num == ("J")) then
		return 11
	elseif(num == ("Q")) then
		return 12
	elseif(num == ("K")) then
		return 13
	else
		return -1
	end
end

function SimplePoker:getColorValue(color)
	if(string.len(color) ~= 1) then
		return -1
	end
	local n = color-0
    
	if(n >=0 and n < COLOR_COUNT) then
		return n
	else
		return -1
	end
end

function SimplePoker:isLinkCard(obj)
	--[[排除 AK A2]]
	if(m_num == 14 or obj.getNum() == 14) then
		return false
	end
	
	local n = obj:getNum() - self.m_num
	return (n == 1) or (n == -1)
end

function SimplePoker:isSameColor(obj)
	return obj:getColor() == self.m_color
end

function SimplePoker:isSameNum(obj)
	return obj:getNum() == self.m_num
end

----------------------------------------------------------

NewGuidePokerType = class("NewGuidePokerType")

function NewGuidePokerType:ctor()
	self.m_pocketCard = {}
	self.m_flopCard = {} 
	self.m_sortCard = {}
end

function NewGuidePokerType:setGreatThanThree(isGreat) 
	self.m_bIsGreat = isGreat
end

function NewGuidePokerType:isGreatPocketCard()
	if self.m_pocketCard==nil or #self.m_pocketCard~=2 then
		return false
	end
	local num1 = self.m_pocketCard[1]:getNum()
	local num2 = self.m_pocketCard[2]:getNum()
    
	local bRet = (num1 == 14 and num2 == 14) or --AA
    (num1 == 13 and num2 == 13) or --KK
    (num1 == 12 and num2 == 12) or --QQ
    (num1 == 14 and num2 == 13) or --AK
    (num1 == 13 and num2 == 14)   --KA
	
	return bRet
end

function NewGuidePokerType:isSmallPairPocketCard()
	if(not self.m_pocketCard or #self.m_pocketCard ~= 2 or
		not self.m_pocketCard[1]:isSameNum(self.m_pocketCard[2])) then
		return false
    end
	local num = self.m_pocketCard[1]:getNum()
	return (num >= 2) and (num <= 9)
end

function NewGuidePokerType:isMiddlePairPocketCard()
	if(not self.m_pocketCard or #self.m_pocketCard ~= 2 or
	 not self.m_pocketCard[1]:isSameNum(self.m_pocketCard[2])) then
		return false
    end
	local num = self.m_pocketCard[1]:getNum()
	return num >= 10 and num <= 11
end

function NewGuidePokerType:isNotBadPocketCard()
	if not self.m_pocketCard or #self.m_pocketCard ~= 2 then
		return false
	end    
	local poker1 = self.m_pocketCard[1]
	local poker2 = self.m_pocketCard[2]
    
	local num1 = poker1:getNum()
	local num2 = poker2:getNum()
    
	local bRet = (num1 >= 10 and num2 >= 10)--both more than 10
    
	return bRet
end

function NewGuidePokerType:isGreaterThanTwoPairFlopCard()
	return self.m_bIsGreat and true or self:isTwoPairFlopCard()
end

function NewGuidePokerType:isTwoPairFlopCard()
	if not self.m_pocketCard or #self.m_pocketCard ~= 2 then
		return false
	end  
	local count = 0
	for i = 1,#self.m_pocketCard do
		for j=1,#self.m_flopCard do
		
			if(self.m_flopCard[j]:getNum() == self.m_pocketCard[i]:getNum()) then
				count = count+1
			end
			break
		end
	end	
    
	return (count == 2)
end

function NewGuidePokerType:isGreatPairFlopCard()
	if(not self.m_sortCard or #self.m_sortCard ~= 5 
		or not self.m_pocketCard or #self.m_pocketCard ~= 2 
		or not self.m_flopCard or #self.m_flopCard ~= 3) then
		return false
    end
	local maxIndex = -1
	local maxValue = -1
    
	--AA KK QQ JJ
	for i=1,#self.m_sortCard do
	
		if(self.m_sortCard[i]:getNum() == self.m_sortCard[i+1]:getNum()) then
		
			if(self.m_sortCard[i]:getNum() > 7) then
			
				maxIndex = i
				maxValue = self.m_sortCard[i]:getNum()
			end
			break
		end	
	end	
	
    
	--great pair now
	if(maxIndex == -1 or maxValue == -1) then
		return false
    end

	--是否包含手牌
	--card count in flop card
	local count = 0
	for i=1,#self.m_flopCard do
		if(self.m_flopCard[i]:getNum() == self.m_sortCard[maxIndex]:getNum()) then
			count = count+1
		end
	end
	if(count > 1) then
		return false
    end
	if(maxValue >= 11) then
	
		return true
	
	else
	
		--是否是最大对
		for i=1,#self.m_flopCard do
		
			if(self.m_sortCard[maxIndex]:getNum() < self.m_flopCard[i]:getNum()) then
			
				return false
			end
		end
		return true
	end
end

function NewGuidePokerType:isFlushStraightPossible()
	if(not self.m_sortCard or #self.m_sortCard ~= 5) then
		return false
    end
	--get four
	local bFlush    = false
	local bStraight = false
	local fourCard = {}
	for i=1,#self.m_sortCard do
		for j=1,#self.m_sortCard do
			if(i ~= j) then
				fourCard[#fourCard] = self.m_sortCard[j]
			end
		end
		if(not bFlush and self:isFlushPossible(fourCard)) then
			bFlush = true
		end
		if(not bStraight and self:isStraightPossible(fourCard)) then
			bStraight = true
		end
		if(bFlush and bStraight) then
			break
		end
	end
    
	if(bFlush and bStraight) then
		return 1
	end
	if(bFlush or bStraight) then
		return 0
    end
	return -1
end

--[[if flush possible]]
function NewGuidePokerType:isFlushStraightPossible(fourCard)
	if(not fourCard or #fourCard ~= 4) then
		return false
    end
	for i=2,#fourCard do
		if(fourCard[i]:getColor() ~= fourCard[1]:getColor()) then
			return false
		end
	end
    
	return true
end

--[[if straight possible]]
function NewGuidePokerType:isStraightPossible(fourCard)
	if(not fourCard or #fourCard) then
		return false
    end
	for i=2,#fourCard do
		if(fourCard[i].getColor() ~= fourCard[1]:getColor()) then
			return false
		end
    end
	return true
end

--[[get pocket card]]
function NewGuidePokerType:pushPocketCard(pocketCard)
	self.m_pocketCard = pocketCard
end

--[[get flop card]]
function NewGuidePokerType:pushFlopCard(flopCard)
	self.m_flopCard = flopCard
	self:sortCardList()
end

function NewGuidePokerType:clearCard()
	self.m_pocketCard = nil
	self.m_flopCard = nil
	self.m_sortCard = nil
end

function NewGuidePokerType:sortCardList()
	if((not self.m_pocketCard or #self.m_pocketCard ~= 2) 
		or (not self.m_flopCard or #self.m_flopCard ~= 3)) then
		self.m_sortCard=nil
		return false
	end
    
	self.m_sortCard = self.m_pocketCard
	local startIdx = #self.m_pocketCard+1
	local endIdx = #self.m_pocketCard+1+#self.m_flopCard
	for i=startIdx,endIdx do
		self.m_sortCard[i] = self.m_flopCard[i-startIdx+1]
	end
    
	local tmp = nil
	for i=1,#self.m_sortCard do
		for j=i+1,#self.m_sortCard do
			if(self.m_sortCard[j]:getNum() > self.m_sortCard[i]:getNum()) then
				tmp = self.m_sortCard[j]
				self.m_sortCard[j] = self.m_sortCard[i]
				self.m_sortCard[i] = tmp
			end
		end
	end		
	return true
end

----------------------------------------------------------

----------------------------------------------------------
NewerGuideControl = class("NewerGuideControl")

function NewerGuideControl:ctor()
	self.m_currentState = kTechControlNone
	self.m_showType = kNGCNone
	self.m_isFirstRound = true
	self.m_isHaveAllIn = false
	self.m_pokerType = NewGuidePokerType:new()
	self.m_pokerType:setGreatThanThree(false)
end

function NewerGuideControl:pushPocketCard(pocketCard)
	local _pokerCard = {}
	for i=1,#pocketCard do
		local card = SimplePoker:new()
		card:setSimplePoker(pocketCard[i])
		_pokerCard[#_pokerCard+1] = card
	end
	self.m_pokerType:pushPocketCard(_pokerCard)
end

function NewerGuideControl:pushFlopCard(flopCard)
	local _flopCard = {}
	for i=1,#flopCard do
		local card = SimplePoker:new()
		card:setSimplePoker(flopCard[i])
		_flopCard[#_flopCard+1] = card
	end
	self.m_pokerType:pushFlopCard(_flopCard)
end

function NewerGuideControl:clearAllSet()
	self.m_isFirstRound = true
	self.m_isHaveAllIn = false
    
	self.m_pokerType:clearCard()
	self.m_showType = kNGCNone
	self.m_currentState = kTechControlNone
    
	self.m_pokerType:setGreatThanThree(false)
end

function NewerGuideControl:getShowType()
	if self.m_currentState == kTechControlPocket then
        self:pocketLogic()
    elseif self.m_currentState == kTechControlFlop then
        self:flopLogic()
    elseif self.m_currentState == kTechControlTurn then
        self:turnLogic()
    elseif self.m_currentState == kTechControlRiver then
        self:riverLogic()
    else
        self.m_showType = kNGCNone
	end
    
	return self.m_showType
end

function NewerGuideControl:setGreatCard(isGreat)
	self.m_pokerType:setGreatThanThree(isGreat)
end

function NewerGuideControl:pocketLogic()
	if(self.m_pokerType:isGreatPocketCard()) then
		self.m_showType = kNGCPocketGreatCallRaise
	elseif(self.m_pokerType:isSmallPairPocketCard()) then
		self.m_showType = self.m_isFirstRound and kNGCPocketPairCallRaise or kNGCPocketCautious
	elseif(self.m_pokerType:isMiddlePairPocketCard()) then
		self.m_showType = kNGCPocketPairCallRaise
	elseif(self.m_pokerType:isNotBadPocketCard()) then
		self.m_showType = self.m_isFirstRound and kNGCPocketGoodCallRaise or kNGCPocketCautious
	else
		self.m_showType = kNGCPocketHigh
	end
end

function NewerGuideControl:flopLogic()
	if(self.m_pokerType:isGreaterThanTwoPairFlopCard()) then
	
		self.m_showType = kNGCFlopGreatRaise
	
	elseif(self.m_pokerType:isGreatPairFlopCard()) then
	
		self.m_showType = self.m_isHaveAllIn and kNGCFlopAllIn or kNGCFlopGreatRaise
	
	else
		local isPossible = self.m_pokerType:isFlushStraightPossible()
		if isPossible==1 then
            self.m_showType = kNGCFlopGreatRaise
        elseif isPossible==0 then
            self.m_showType = self.m_isHaveAllIn and kNGCFlopAllIn or kNGCFlopGreatRaise
        else
            self.m_showType = kNGCFlopCautious
        end
	end	
	
end

function NewerGuideControl:turnLogic()
	self.m_showType = kNGCTurnSelf
end

function NewerGuideControl:riverLogic()
	self.m_showType = kNGCNone
end







----------------------------------------------------------