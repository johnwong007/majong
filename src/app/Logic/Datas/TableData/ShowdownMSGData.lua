local SHOWDOWN_MSG_CARD_LIST = {
	m_userId = "",
	m_seatNo = -1,
	m_pocketCards = {},
	m_showDownType = 0,
}


-----------------------------------------------------------------

CardListeach = class("CardListeach")

function CardListeach:clone()
	local cloneSelf = CardListeach:new()
	cloneSelf.userId = self.userId
	cloneSelf.seatNo = self.seatNo
	cloneSelf.pocketCards = self.pocketCards
	cloneSelf.showDownType = self.showDownType
	return cloneSelf
end

function CardListeach:ctor()
	self.userId = ""
	self.seatNo = -1
	self.pocketCards = {}
	self.showDownType = 0
end

function CardListeach:deJson(jsonObj)
	if jsonObj == nil then
		return 
	end
    self.userId = jsonObj[USER_ID] or ""
	self.seatNo = jsonObj[SEAT_NO] or 0
    self.showDownType = jsonObj[SHOWDOWN_TYPE] or 0
    
    local pocketCardJson = jsonObj[POCKET_CARDS] or {}
    
    for i=1,#pocketCardJson do
    	self.pocketCards[i] = pocketCardJson[i]
    end
end

-----------------------------------------------------------------
ShowdownMSGData = class("ShowdownMSGData")

function ShowdownMSGData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_showDownOptional = false
	self.m_cardList = {}
end

function ShowdownMSGData:getClone()
	local cloneSelf = ShowdownMSGData:new()
	cloneSelf.m_code = self.m_code
	cloneSelf.m_tableId = self.m_tableId
	cloneSelf.m_rushPlayerId = self.m_rushPlayerId
	cloneSelf.m_showDownOptional = self.m_showDownOptional
	cloneSelf.m_cardList = self.m_cardList
	return cloneSelf
end


function ShowdownMSGData:setData(srcObj)
	self.m_code = srcObj.m_code
	self.m_tableId = srcObj.m_tableId
	self.m_rushPlayerId = srcObj.m_rushPlayerId
	self.m_showDownOptional = srcObj.m_showDownOptional
	self.m_cardList = nil
	self.m_cardList = srcObj.m_cardList
end


function ShowdownMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_showDownOptional = jsonTable[SHOWDOWN_OPTIONAL] or false
		
		if jsonTable[RUSH_PLAYER_ID] then
			self.m_rushPlayerId = jsonTable[RUSH_PLAYER_ID]
		end
		if self.m_rushPlayerId and string.len(self.m_rushPlayerId)>1 then
			self.m_tableId = self.m_rushPlayerId
		end

		local cardListJson = jsonTable[CARD_LIST] or {}
		for index=1,#cardListJson do
			local eachOne = CardListeach:new()
			eachOne:deJson(cardListJson[index])
			self.m_cardList[#self.m_cardList+1] = eachOne
		end

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return ShowdownMSGData