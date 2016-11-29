
potReturnData = class("potReturnData")

function potReturnData:ctor()
	self.uid = ""
	self.chipNum = 0.0
end

-----------------------------------------------------------------
PrizeListEach = class("PrizeListEach")

function PrizeListEach:clone()
	local cloneSelf = PrizeListEach:new()
	cloneSelf.rakeChipsAFFlop = self.rakeChipsAFFlop
	cloneSelf.seatNo = self.seatNo
	cloneSelf.userId = self.userId
	cloneSelf.cardType = self.cardType
	cloneSelf.winChips = self.winChips
	cloneSelf.userChips = self.userChips
	cloneSelf.maxCard = self.maxCard
	return cloneSelf
end

function PrizeListEach:ctor()
	self.rakeChipsAFFlop = 0.0 --[[翻拍后抽水]]
	self.seatNo = 0
	self.userId = ""	--[[unuse]]
	self.cardType = 0 	--[[unuse赢得类型]]
	self.winChips = 0.0 	--[[赢的chips]]
	self.userChips = 0.0 	--[[赢了之后]]
	self.maxCard = {} 	--[[赢的5张牌]]
end

function PrizeListEach:deJson(jsonObj)
	-- normal_info_log("PrizeListEach:deJson")
	-- print(json.encode(jsonObj))
	if jsonObj == nil then
		return 
	end
    self.rakeChipsAFFlop = jsonObj[RAKE_CHIPS_AF_FLOP] or 0
	self.seatNo = tonumber(jsonObj[SEAT_NO]) or 0
    self.userId = jsonObj[USER_ID] or ""
    self.cardType = jsonObj[CARD_TYPE] or 0.0
    self.winChips = jsonObj[WIN_CHIPS] or 0.0
    self.userChips = jsonObj[USER_CHIPS] or 0.0
    
    local maxCardJson = jsonObj[MAX_CARD] or {}
    for i=1,#maxCardJson do
    	self.maxCard[i] = maxCardJson[i]
    end
end

-----------------------------------------------------------------
PrizeMSGData = class("PrizeMSGData")

function PrizeMSGData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.potList = {}
	self.potReturnList = {}
	self.m_prizeList = {}
end

function PrizeMSGData:getClone()
	local cloneSelf = PrizeMSGData:new()
	cloneSelf.m_code = self.m_code
	cloneSelf.m_tableId = self.m_tableId
	cloneSelf.m_rushPlayerId = self.m_rushPlayerId

	cloneSelf.potList = {}
	for i=1,#self.potList do
		local prizeListEach ={}
		for i=1,#self.potList[i] do
			prizeListEach[i] = potList[i][j]
		end
		cloneSelf.potList[i] = prizeListEach
	end
	return cloneSelf
end


function PrizeMSGData:setData(srcObj)
	self.m_code = srcObj.m_code
	self.m_tableId = srcObj.m_tableId
	self.m_rushPlayerId = srcObj.m_rushPlayerId

	self.potList = {}
	for i=1,#srcObj.potList do
		local prizeListEach ={}
		for i=1,#srcObj.potList[i] do
			prizeListEach[i] = potList[i][j]
		end
		self.potList[i] = prizeListEach
	end
end


function PrizeMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		
		self.potList = {}
		local potListJson = jsonTable[PRIZE_LIST] or {}
		
		for i=1,#potListJson do
			local potReturnJson = jsonTable[POT_RETURN] or {}
		
			for uid,chipNum in pairs(potReturnJson) do
				local data = potReturnData:new()
				data.uid = uid
				data.chipNum = chipNum
				if data.chipNum > 0 then
					self.potReturnList[#self.potReturnList+1] = data
				end
			end
			self.m_prizeList = {}
			local playerListJson =potListJson[i] or {}
			for j=1,#playerListJson do
				local eachOne = PrizeListEach:new()
				eachOne:deJson(playerListJson[j])
				self.m_prizeList[j] = eachOne
			end
			self.potList[i] = self.m_prizeList
		end
		
		if jsonTable[RUSH_PLAYER_ID] then
			self.m_rushPlayerId = jsonTable[RUSH_PLAYER_ID]..""
		end
		if self.m_rushPlayerId and string.len(self.m_rushPlayerId)>1 then
			self.m_tableId = self.m_rushPlayerId
		end

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return PrizeMSGData