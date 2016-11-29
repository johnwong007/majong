local CardHandPoint = class("CardHandPoint", function()
		return display.newLayer()
	end)

function CardHandPoint:create(num)
	local p = CardHandPoint:new()
	p:initWithNum(num)
	return p
end

function CardHandPoint:ctor()
	self.m_isPositive = true
	self.m_numList = {}
end

function CardHandPoint:initWithNum(num)
	if(num == 0) then
		return false
	end
    
	self.m_isPositive = (num > 0)
    
	local n = num>0 and num or -num
	while(n ~= 0) do
		self.m_numList[#self.m_numList+1]= n % 10
		-- n /= 10
		n = n/10
	end
end

function CardHandPoint:numToSpriteID(num, isPositive)

	local SpriteID
	if(isPositive) then
	
		SpriteID = "p_"..num
	else
	
		SpriteID = "n_"..num
	end
    
	return SpriteID
end

function CardHandPoint:initChild()
	local hint = NULL
	local sign = NULL
    
	if(self.m_isPositive) then
	
		hint = cc.Sprite:create("p_w.png")
		sign = cc.Sprite:create("p_add.png")
	else
	
		hint = cc.Sprite:create("n_w.png")
		sign = cc.Sprite:create("n_sub.png")
	end
	local size = cc.size(0,0)
	size.width = hint:getContentSize().width
	size.height = hint:getContentSize().height + sign:getContentSize().height
	self:setContentSize(size)
    
	hint:setAnchorPoint(cc.p(0.5,0.5))
	hint:setPosition(cc.p(hint:getContentSize().width / 2,size.height - hint:getContentSize().height / 2))
	self:addChild(hint)
    
	local numberLayer = cc.Layer:create()
	numberLayer:ignoreAnchorPointForPosition(false)
	numberLayer:setContentSize(cc.size(sign:getContentSize().width * (#self.m_numList + 1),sign:getContentSize().height))
	numberLayer:setAnchorPoint(cc.p(0.5,0.5))
	numberLayer:setPosition(cc.p(hint:getContentSize().width / 2,sign:getContentSize().height / 2 + 7))
	self:addChild(numberLayer)
    
	local fWidth = sign:getContentSize().width
	local fHeight = sign:getContentSize().height
	sign:setAnchorPoint(cc.p(0,0.5))
	sign:setPosition(cc.p(0,fHeight / 2))
	numberLayer:addChild(sign)
    
	for i=1,#self.m_numList do
	
		local numLabel = cc.Sprite:create(self:numToSpriteID(self.m_numList[#self.m_numList - 1 - i],
			self.m_isPositive))
		numLabel:setAnchorPoint(cc.p(0,0.5))
		numLabel:setPosition(cc.p(fWidth,fHeight / 2))
		fWidth = fWidth+numLabel:getContentSize().width
		numberLayer:addChild(numLabel)
	end
end

function CardHandPoint:initAction()

	local actionList = {}
    
	local moveBy = cc.MoveBy:create(1.0,cc.p(0,45))
	actionList[#actionList+1] = moveBy
    
	local delay = cc.DelayTime:create(0.5)
	actionList[#actionList+1] = delay
    
	local func = cc.CallFunc:create(handler(self,self.removeSelf))
	actionList[#actionList+1] = func
    
	return cc.Sequence:create(actionList)
end

function CardHandPoint:showAndClear()

	self:initChild()
	local action = self:initAction()
	if(action) then
	
		self:runAction(action)
	end
end

function CardHandPoint:removeSelf()

	self:stopAllActions()
	self:removeAllChildrenWithCleanup(true)
	self:getParent():removeChild(self, true)	
end


return CardHandPoint