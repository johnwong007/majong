
BlindInfoEach = class("BlindInfoEach")

function BlindInfoEach:ctor()
	self.sBlindNo = 0
	self.smallBlind = 0.0
	self.userChips = 0.0
end

function BlindInfoEach:deJson(jsonObj, i)
	if i == 0 then
		self.sBlindNo = jsonObj[SBLIND_NO] or 0
		self.smallBlind = jsonObj[SMALL_BLIND] or 0.0
	else
		self.sBlindNo = jsonObj[BBLIND_NO] or 0
		self.smallBlind = jsonObj[BIG_BLIND] or 0.0
	end
	self.userChips = jsonObj[USER_CHIPS] or 0.0
end

--------------------------------------------------------
NewBlindInfoEach = class("NewBlindInfoEach")

function NewBlindInfoEach:ctor()
	self.seatNo = -1
	self.newBlindChips = 0.0
	self.userId = ""
	self.userChips = 0.0
end

function NewBlindInfoEach:deJson(jsonObj)
	if jsonObj~=nil then
		self.seatNo = tonumber(jsonObj[SEAT_NO]) or -1
		self.newBlindChips = jsonObj[NEW_BLIND_CHIPS] or 0.0
		self.userId = jsonObj[USER_ID] or ""
		self.userChips = jsonObj[USER_CHIPS] or 0.0
	else
		self.seatNo = -1
		self.newBlindChips = 0.0
	end
end

--------------------------------------------------------
--[[14发底注下注消息]]
TableBlindMsgInfo = class("TableBlindMsgInfo")

function TableBlindMsgInfo:ctor()
	self.m_code = 0
	self.tableId = ""
	self.m_rushPlayerId = ""
	self.totalPot = 0
	self.blindInfo = {}
	self.newBlindInfo = {}
end


function TableBlindMsgInfo:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.tableId = jsonTable[TABLE_ID] or ""
		self.totalPot = jsonTable[TOTAL_POT] or 0.0

		if jsonTable[RUSH_PLAYER_ID] then
			self.m_rushPlayerId = jsonTable[RUSH_PLAYER_ID]..""
		end
		if self.m_rushPlayerId and string.len(self.m_rushPlayerId)>1 then
			self.m_tableId = self.m_rushPlayerId
		end
		
		self.blindInfo={}
		local blindInfoJson = jsonTable[BLIND_INFO] or {}
		for i=1,#blindInfoJson do
			local eachOne = BlindInfoEach:new()
			eachOne:deJson(blindInfoJson[i],i-1)
			self.blindInfo[i] = eachOne
		end
		
		local newBlindInfoJson = jsonTable[NEW_BLIND_INFO] or {}
		for i=1,#newBlindInfoJson do
			local eachOne = NewBlindInfoEach:new()
			 eachOne:deJson(newBlindInfoJson[i])
			 self.newBlindInfo[i] = eachOne
		end

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableBlindMsgInfo