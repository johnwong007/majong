pHeitao = 0
pHongtao = 1
pMeihua = 2
pFangpian = 3

pk2 = 0
pk3 = 1
pk4 = 2 
pk5 = 3
pk6 = 4
pk7 = 5
pk8 = 6
pk9 = 7
pk10 = 8
pkJ = 9
pkQ = 10
pkK = 11
pkA = 12

--self.playType 1为6+ 其余为普通玩法

local poker = class("poker")

function poker:ctor()
	self.color = 0 --[[花色]]
	self.num = 0 --[[数字]]
	self.loc = 0 --[[位置]]
	self.playType = nil
end

GaoPai = 1
DuiZi = 2
LiangDui = 3
SanTiao = 4
ShunZi = 5
TongHua = 6
HuLu = 7
SiTiao = 8
TongHuaShun = 9
HuangJia = 10


local CalcPoker = class("CalcPoker", cc.Ref)

function CalcPoker:ctor()
	self.m_isA2345 = false
	self.m_allCards = {} --[[接收到的可能的最多7张牌]]
	self.m_maxCards = {} --[[查询结果的最大5张牌]]
end

function CalcPoker:readPokerType(card, index)
	if card == nil or card=="" then
		card = "0_2"
	end
	local str_color = string.sub(card,1,1)
	local str_num = string.sub(card,3)

	local tmp = poker:new()
	tmp.loc   = index
	tmp.color = str_color+0

	if str_num == "A" then
	
		tmp.num = pkA
	elseif str_num == "2" then
	
		tmp.num = pk2
	elseif str_num == "3" then
	
		tmp.num = pk3
	elseif str_num == "4" then
	
		tmp.num = pk4
	elseif str_num == "5" then
	
		tmp.num = pk5
	elseif str_num == "6" then
	
		tmp.num = pk6
	elseif str_num == "7" then
	
		tmp.num = pk7
	elseif str_num == "8" then
	
		tmp.num = pk8
	elseif str_num == "9" then
	
		tmp.num = pk9
	elseif str_num == "10" then
	
		tmp.num = pk10
	elseif str_num == "J" then
	
		tmp.num = pkJ
	elseif str_num == "Q" then
	
		tmp.num = pkQ
	elseif str_num == "K" then
	
		tmp.num = pkK
	end
	assert(tmp.color <= pFangpian  and  tmp.color >= pHeitao)
	assert(tmp.loc <= 6  and  tmp.loc>=0)
	assert(tmp.num <= pkA  and  tmp.num>= pk2)
    
	return tmp
end

function CalcPoker:showHandCards(card1, card2)
	self.m_allCards[1]=self:readPokerType(card1,0)
	self.m_allCards[2]=self:readPokerType(card2,1)
end

function CalcPoker:showFlopCards(card1, card2, card3)

	self.m_allCards[3]=self:readPokerType(card1,2)
	self.m_allCards[4]=self:readPokerType(card2,3)
	self.m_allCards[5]=self:readPokerType(card3,4)
end

function CalcPoker:showTurnCards(card1)

	self.m_allCards[6]=self:readPokerType(card1,5)
end

function CalcPoker:showRiverCards(card1)

	self.m_allCards[7]=self:readPokerType(card1,6)
end

--排序后5张牌是顺子不
function CalcPoker:isShunZi(cards, saveOrNot)

	--6,5,4,3,2
	local res = false
	if( cards[1].num - cards[2].num == 1  and 
       cards[2].num - cards[3].num == 1  and 
       cards[3].num - cards[4].num == 1  and 
       cards[4].num - cards[5].num == 1) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			for i=1,5 do
				self.m_maxCards[i]=cards[i]
			end
		elseif(self.m_isA2345) then
		
			self.m_isA2345 = false
			--保存结果
			for i=1,5 do
				self.m_maxCards[i]=cards[i]
			end
		end
	  --A 5432
	elseif not self.playType then
		if(cards[1].num == pkA  and  cards[2].num == pk5  and 
            cards[2].num - cards[3].num == 1  and 
            cards[3].num - cards[4].num == 1  and 
            cards[4].num - cards[5].num == 1) then
	
			res=true
	        
			if(saveOrNot) then
			
				self.m_isA2345 = true
	            
				--保存结果
				for i=1,5 do
					self.m_maxCards[i]=cards[i]
				end
			end
		end
	  --A 6789
	elseif self.playType and self.playType==1 then
		if(cards[1].num == pkA  and  cards[2].num == pk9  and 
            cards[2].num - cards[3].num == 1  and 
            cards[3].num - cards[4].num == 1  and 
            cards[4].num - cards[5].num == 1) then
	
			res=true
	        
			if(saveOrNot) then
			
				self.m_isA2345 = true
	            
				--保存结果
				for i=1,5 do
					self.m_maxCards[i]=cards[i]
				end
			end
		end
	end
    
	return res
end
--排序后5张牌是同花不
function CalcPoker:isTongHua(cards, saveOrNot)

	local res = false
	if( cards[1].color == cards[2].color  and 
       cards[2].color == cards[3].color  and 
       cards[3].color == cards[4].color  and 
       cards[4].color == cards[5].color ) then
	
		res=true
        
		if(saveOrNot) then
		
			for i=1,5 do
				self.m_maxCards[i]=cards[i]
			end
		end
	end
    
	return res
end
--排序后5张牌是葫芦不
function CalcPoker:isHuLu(cards, saveOrNot)

	local res = false
    
	--8,8,8,3,3
	if( cards[1].num == cards[2].num  and 
       cards[2].num == cards[3].num  and 
       cards[3].num ~= cards[4].num  and 
       cards[4].num == cards[5].num ) then
	
		res=true
	--8,8,3,3,3
	elseif(cards[1].num == cards[2].num  and 
            cards[2].num ~= cards[3].num  and 
            cards[3].num == cards[4].num  and 
            cards[4].num == cards[5].num) then
	
		res=true
	end
    
	if(res  and  saveOrNot) then
	
		--保存结果
		for i=1,5 do
			self.m_maxCards[i]=cards[i]
		end
	end
    
	return res
end
--排序后5张牌是四条不
function CalcPoker:isSiTiao(cards, saveOrNot)

	local res = false
    
	--4,4,4,4,2
	if( cards[1].num == cards[2].num  and 
       cards[2].num == cards[3].num  and 
       cards[3].num == cards[4].num
       ) then
	
		res=true
		
		if(saveOrNot) then
		
			--保存结果
			for i=1,4 do
				self.m_maxCards[i]=cards[i]
			end
		end
	--9,5,5,5,5
	elseif(cards[2].num == cards[3].num  and 
			cards[3].num == cards[4].num  and 
			cards[4].num == cards[5].num) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			for i=1,4 do
				self.m_maxCards[i]=cards[i+1]
			end
		end
	end
    
	return res
end
--排序后5张牌是三条不
function CalcPoker:isSanTiao(cards, saveOrNot)

	local res = false
    
	--8,4,4,4,3
	if( cards[1].num ~= cards[2].num  and 
       cards[2].num == cards[3].num  and 
       cards[3].num == cards[4].num  and 
       cards[4].num ~= cards[5].num ) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[2]
			self.m_maxCards[2]=cards[3]
			self.m_maxCards[3]=cards[4]
		end
	--9,5,3,3,3
	elseif(cards[1].num ~= cards[2].num  and 
			cards[2].num ~= cards[3].num  and 
			cards[3].num == cards[4].num  and 
			cards[4].num == cards[5].num) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[3]
			self.m_maxCards[2]=cards[4]
			self.m_maxCards[3]=cards[5]
		end
	--9,9,9,7,3
	elseif(cards[1].num == cards[2].num  and 
			cards[2].num == cards[3].num  and 
			cards[3].num ~= cards[4].num  and 
			cards[4].num ~= cards[5].num) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[1]
			self.m_maxCards[2]=cards[2]
			self.m_maxCards[3]=cards[3]
		end
	end
    
	return res
end
--排序后5张牌是两对不
function CalcPoker:isLiangDui(cards, saveOrNot)

	local res = false
	--这里不需要再多判断，有更好的牌会被上面拦截
	--8,8,4,4,3
	if( cards[1].num == cards[2].num  and 
       cards[3].num == cards[4].num ) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			for i=1,4 do
				self.m_maxCards[i]=cards[i]
			end
		end
	--9,9,5,3,3
	elseif(cards[1].num == cards[2].num  and 
			cards[4].num == cards[5].num) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[1]
			self.m_maxCards[2]=cards[2]
			self.m_maxCards[3]=cards[4]
			self.m_maxCards[4]=cards[5]
		end
	--9,7,7,3,3
	elseif(cards[2].num == cards[3].num  and 
			cards[4].num == cards[5].num) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[2]
			self.m_maxCards[2]=cards[3]
			self.m_maxCards[3]=cards[4]
			self.m_maxCards[4]=cards[5]
		end
	end
    
	return res
end
--排序后5张牌是对子不
function CalcPoker:isDuiZi(cards, saveOrNot)

	local res = false
	--这里不需要再多判断，有更好的牌会被上面拦截
	--8,8,7,6,3
	if( cards[1].num == cards[2].num) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[1]
			self.m_maxCards[2]=cards[2]
		end
	elseif(cards[2].num == cards[3].num) then
	
		res = true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[2]
			self.m_maxCards[2]=cards[3]
		end
	elseif(cards[3].num == cards[4].num) then
	
		res = true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[3]
			self.m_maxCards[2]=cards[4]
		end
	elseif(cards[4].num == cards[5].num) then
	
		res = true
        
		if(saveOrNot) then
		
			--保存结果
			self.m_maxCards[1]=cards[4]
			self.m_maxCards[2]=cards[5]
		end
	end
    
	return res
end
--5张牌是同花顺不
function CalcPoker:isTongHuaShun(cards, saveOrNot)

	local res = false
    
	if(self:isTongHua(cards,saveOrNot)  and self:isShunZi(cards,saveOrNot)) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			for i=1,5 do
				self.m_maxCards[i]=cards[i]
			end
		end
	end
    
	return res
end
--5张牌是皇家同花顺不
function CalcPoker:isHuangJia(cards, saveOrNot)

	local res = false
    
	if(self:isTongHuaShun(cards,saveOrNot) and cards[1].num == pkA and cards[2].num == pkK) then
	
		res=true
        
		if(saveOrNot) then
		
			--保存结果
			for i=1,5 do
				self.m_maxCards[i]=cards[i]
			end
		end
	end
    
	return res
end

function CalcPoker:calc5CardsPiv(cards, saveOrNot)

	local tmp = GaoPai
    
	if(self:isHuangJia(cards,saveOrNot)) then
		tmp=HuangJia
	elseif(self:isTongHuaShun(cards,saveOrNot)) then
		tmp=TongHuaShun
	elseif(self:isSiTiao(cards,saveOrNot)) then
		tmp=SiTiao
	elseif(self:isHuLu(cards,saveOrNot)) then
		tmp=HuLu
	elseif(self:isTongHua(cards,saveOrNot)) then
		tmp=TongHua
	elseif(self:isShunZi(cards,saveOrNot)) then
		tmp=ShunZi
	elseif(self:isSanTiao(cards,saveOrNot)) then
		tmp=SanTiao
	elseif(self:isLiangDui(cards,saveOrNot)) then
		tmp=LiangDui
	elseif(self:isDuiZi(cards,saveOrNot)) then
		tmp=DuiZi
	else
		tmp=GaoPai
    end
	return tmp
end

function CalcPoker:calc2Cards()

	local tmpRes = GaoPai

	if(self.m_allCards[1].num == self.m_allCards[2].num) then
	
		self.m_maxCards[1] = self.m_allCards[1]
		self.m_maxCards[2] = self.m_allCards[2]
        
		tmpRes = DuiZi
	end
    
	return tmpRes
end

function CalcPoker:calc5Cards()

	--先将5张牌 大小排序
	self:sortAllCards(5)
    
	local tmpRes = GaoPai
    
	--5张牌一次比较即可得出结果故保存
	tmpRes = self:calc5CardsPiv(self.m_allCards,true)
    
	return tmpRes
end

function CalcPoker:calc6Cards()

	--先将6张牌 大小排序
	self:sortAllCards(6)
    
	local tmpRes = GaoPai
    
	--[[
	将大小排序好的牌中一次从小的开始抽取掉一张牌
     组合成5张排序好的牌比较
	]]
	for i=6,1,-1 do
	
		local tmpCards = {}          --一次取出来的5张牌
		-- for i=1,5 do
		-- 	tmpCards = poker:new()
		-- end
		local tmpCount=1
        
		--[[从原来的6张牌中取5张]]
		for j=1,6 do
		
			if(j ~= i) then
			
				tmpCards[tmpCount]=self.m_allCards[j]
				tmpCount = tmpCount+1
			end
		end
        
        local resOne = self:calc5CardsPiv(tmpCards,false)
		--[[替换成最好的5张 保存]]
		if(resOne > tmpRes) then
		
			tmpRes = resOne
			self:calc5CardsPiv(tmpCards,true)
		end
	end
    
	return tmpRes
end

function CalcPoker:calc7Cards()

	--先将7张牌 大小排序
	self:sortAllCards(7)
    
	local tmpRes = GaoPai
    
	--[[
	将大小排序好的牌中一次从小的开始抽取掉一张牌
     组合成5张排序好的牌比较
	]]
	for i=7,1,-1 do
		for j=i-1,1,-1 do
            local tmpCards = {}         --一次取出来的5张牌
            local tmpCount=1
            
           --[[从原来的6张牌中取5张]]
            for k=1,7 do
                if(k ~= i  and  k ~= j) then  --从后面小的开始一次踢出两张
                
                    tmpCards[tmpCount]=self.m_allCards[k]
                    tmpCount = tmpCount+1
                end
            end
            
        	local resOne = self:calc5CardsPiv(tmpCards,false)
            --[[替换成最好的5张 保存]]
            if(resOne > tmpRes) then
            
                tmpRes = resOne
                self:calc5CardsPiv(tmpCards,true)
            end
        end
    end
    
	return tmpRes
end
--按照牌数字排序
function CalcPoker:sortAllCards(cardsNum)

	--从大到小冒泡排序
	for i=1,cardsNum do
		for j=i+1,cardsNum do
			if(self.m_allCards[j].num>self.m_allCards[i].num) then
				local tmp     = self.m_allCards[i]
				self.m_allCards[i] = self.m_allCards[j]
				self.m_allCards[j] = tmp
			end
		end
	end
	-- dump(self.m_allCards)
end
--测试用输出比牌结果 和最大牌型
function CalcPoker:resultDisplay(cardsNum)

	assert(cardsNum == 2  or cardsNum == 5  or cardsNum == 6  or cardsNum == 7 )
	
	local res = GaoPai
	if(cardsNum == 2) then
		res=self:calc2Cards()
	elseif(cardsNum == 5) then
		res=self:calc5Cards()
	elseif(cardsNum == 6) then
		res=self:calc6Cards() 
	elseif(cardsNum == 7) then
		res=self:calc7Cards()
	end
    
	if(res == HuangJia) then
		print("result----HuangJia\n\n\n")
	elseif(res == TongHuaShun) then
		print("result----TongHuaShun\n\n\n")
	elseif(res == SiTiao) then
		print("result----SiTiao\n\n\n")
	elseif(res == HuLu) then
		print("result----HuLu\n\n\n")
	elseif(res == TongHua) then
		print("result----TongHua\n\n\n")
	elseif(res == ShunZi) then
		print("result----ShunZi\n\n\n")
	elseif(res == SanTiao) then
		print("result----SanTiao\n\n\n")
	elseif(res == LiangDui) then
		print("result----LiangDui\n\n\n")
	elseif(res == DuiZi) then
		print("result----DuiZi\n\n\n")
	else
		print("result----GaoPai\n\n\n")
	end
    
	if(res == HuLu  or  res == TongHuaShun  or res == HuLu  or res == TongHua  or res == ShunZi) then
	
		print("loc-%d:%d_%d\nloc-%d:%d_%d\nloc-%d:%d_%d\nloc-%d:%d_%d\nloc-%d:%d_%d\n",
			self.m_maxCards[1].loc+1,self.m_maxCards[1].color,self.m_maxCards[1].num+2,
               self.m_maxCards[2].loc+1,self.m_maxCards[2].color,self.m_maxCards[2].num+2,
               self.m_maxCards[3].loc+1,self.m_maxCards[3].color,self.m_maxCards[3].num+2,
               self.m_maxCards[4].loc+1,self.m_maxCards[4].color,self.m_maxCards[4].num+2,
               self.m_maxCards[5].loc+1,self.m_maxCards[5].color,self.m_maxCards[5].num+2)
	elseif(res == SiTiao  or  res == LiangDui) then
	
		print("loc-%d:%d_%d\nloc-%d:%d_%d\nloc-%d:%d_%d\nloc-%d:%d_%d\n",self.m_maxCards[1].loc+1,
			self.m_maxCards[1].color,self.m_maxCards[1].num+2,
               self.m_maxCards[2].loc+1,self.m_maxCards[2].color,self.m_maxCards[2].num+2,
               self.m_maxCards[3].loc+1,self.m_maxCards[3].color,self.m_maxCards[3].num+2,
               self.m_maxCards[4].loc+1,self.m_maxCards[4].color,self.m_maxCards[4].num+2)
	elseif(res == SanTiao) then
	
		print("loc-%d:%d_%d\nloc-%d:%d_%d\nloc-%d:%d_%d\n",self.m_maxCards[1].loc+1,self.m_maxCards[1].color,self.m_maxCards[1].num+2,
               self.m_maxCards[2].loc+1,self.m_maxCards[2].color,self.m_maxCards[2].num+2,
               self.m_maxCards[3].loc+1,self.m_maxCards[3].color,self.m_maxCards[3].num+2)
	elseif(res == DuiZi) then
	
		print("loc-%d:%d_%d\nloc-%d:%d_%d\n",self.m_maxCards[1].loc+1,self.m_maxCards[1].color,self.m_maxCards[1].num+2,
               self.m_maxCards[2].loc+1,self.m_maxCards[2].color,self.m_maxCards[2].num+2)
	end
end

function CalcPoker:getResult(res)
	local info = {}
    
	if(res == HuLu  or  res == TongHuaShun  or res == HuangJia  or res == TongHua  or res == ShunZi) then
	
		for i=1,5 do
		
			info[#info+1] = self.m_maxCards[i].loc
		end
	elseif(res == SiTiao  or  res == LiangDui) then
	
		for i=1,4 do
		
			info[#info+1] = self.m_maxCards[i].loc
		end
	elseif(res == SanTiao) then
	
		for i=1,3 do
		
			info[#info+1] = self.m_maxCards[i].loc
		end
	elseif(res == DuiZi) then
	
		for i=1,2 do
		
			info[#info+1] = self.m_maxCards[i].loc
		end
	end
    
	return info
end



return CalcPoker