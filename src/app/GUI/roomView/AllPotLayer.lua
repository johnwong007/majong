
local n_pAllPotLLoc = {
	{0,0},           --一个池
    {-120,0},{120,0},     --两个池...
    {-120,50},{120,50},{0,0},	 --三个池...
    {-120,50},{120,50},{-120,0},{120,0}
}

local function SETPOTSLOC(num)
	num = num+1
	return cc.p(n_pAllPotLLoc[num][1],n_pAllPotLLoc[num][2])
end

local AllPotLayer = class("AllPotLayer", function()
		return display.newNode()
	end)

function AllPotLayer:ctor()
	self.m_allPotLayers = {}
	self.m_allPotNum = 0
end

--跟发筹码同步的分池延迟派发
function AllPotLayer:delaySubChips(pObj, info)

	local resA = info
	if(not resA or #resA~=2) then
		return
    end

	local tmpPotStr = resA[1]
	local tmpStr    = resA[2]
	local index = tmpPotStr+0
	local delaySubChipsNum = tmpStr+0.0
    
	local tmpPotL = self.m_allPotLayers[index]
	if tmpPotL then
	
		if delaySubChipsNum > 0.0 then
			tmpPotL:setStaticPot(delaySubChipsNum)
		else
		
			tmpPotL:setStaticPot(0.0)
			tmpPotL:getParent():removeChild(tmpPotL, true)
            
			self.m_allPotLayers[index] = nil
            
			self:updatePotsLocation()
		end
	end
end

--[[
 * 奖池规则：最多四个奖池，超过四个的奖池都放入第四个奖池
 * 不存在奖池时创建，存在时直接更新奖池数据
 * 第一个是主奖池
]]
function AllPotLayer:addChipsWithInfo(potIndex, chips)

	if potIndex > 3 then
	
		potIndex = 3
	end

	if potIndex >= #self.m_allPotLayers then
	
		local potL = require("app.GUI.roomView.PotLayer"):create(potIndex == 0)
		potL:setAnchorPoint(cc.p(0.5,0.5))
		potL:setPosition(cc.p(0,0))
		self:addChild(potL)
		self.m_allPotLayers[potIndex+1]=potL
        
		--累加计数 放置位置
		self.m_allPotNum = #self.m_allPotLayers
		self:updatePotsLocation()
		potL:setStaticPot(chips)
	
	else
	
		local potL = self.m_allPotLayers[potIndex+1]
		potL:setPot(chips)
	end
end

function AllPotLayer:subChipsWithInfo(potIndex, chips)
	-- normal_info_log("AllPotLayer:subChipsWithInfo")

	if(potIndex>3) then
		potIndex=3  --最多4个奖池 其他边池都来自3号
    end
	if potIndex < self.m_allPotNum then
	
		local tmpPotL = self.m_allPotLayers[self.m_allPotNum-potIndex]
		if tmpPotL then
			local delaySubChipsNum = tmpPotL:getPot()
			delaySubChipsNum = delaySubChipsNum - chips
			tmpPotL:subChips(chips)
            
			------ 创建与发筹码同步的异步派发
			local infoA = {}
			infoA[#infoA+1] = self.m_allPotNum-potIndex
			infoA[#infoA+1] = delaySubChipsNum+0.0
			------
			-- local delayAc = cc.DelayTime:create(1.1)
			local delayAc = cc.DelayTime:create(0.0)
			local action  = cc.Sequence:create(delayAc,
				cc.CallFunc:create(handler(self,self.delaySubChips), infoA))
			self:runAction(action)
		end
	end
end

--根据奖池数目放置奖池
function AllPotLayer:updatePotsLocation()
	local potCount = #self.m_allPotLayers
	if potCount==1 then
		
			local potL1 = self.m_allPotLayers[1]
			if potL1 then
				potL1:setPosition(SETPOTSLOC(0))
			end

	elseif potCount==2 then
			local potL1 = self.m_allPotLayers[1]
			if potL1 then
				potL1:setPosition(SETPOTSLOC(1))
            end
			local potL2 = self.m_allPotLayers[2]
			if potL2 then
				potL2:setPosition(SETPOTSLOC(2))
			end

	elseif potCount==3 then
		
			local potL1 = self.m_allPotLayers[1]
			if potL1 then
				potL1:setPosition(SETPOTSLOC(3))
            end

			local potL2 = self.m_allPotLayers[2]
			if potL2 then
				potL2:setPosition(SETPOTSLOC(4))
            end

			local potL3 = self.m_allPotLayers[3]
			if potL3 then
				potL3:setPosition(SETPOTSLOC(5))
			end

	elseif potCount==4 then
		
			local potL1 = self.m_allPotLayers[1]
			if potL1 then
				potL1:setPosition(SETPOTSLOC(6))
            end

			local potL2 = self.m_allPotLayers[2]
			if potL2 then
				potL2:setPosition(SETPOTSLOC(7))
            end

			local potL3 = self.m_allPotLayers[3]
			if potL3 then
				potL3:setPosition(SETPOTSLOC(8))
            end

			local potL4 = self.m_allPotLayers[4]
			if potL4 then
				potL4:setPosition(SETPOTSLOC(9))
			end
	end
end

function AllPotLayer:clearPots()

	self:stopAllActions()
    
	self:removeAllChildren()
    
	self.m_allPotLayers=nil
	self.m_allPotLayers={}
	self.m_allPotNum = 0
end

return AllPotLayer