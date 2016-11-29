
TableAnteInfoEach = class("TableAnteInfoEach")

function TableAnteInfoEach:ctor()
	self.seatNo = -1
	self.userId = ""
	self.betChips = 0.0
	self.userChips = 0.0
end

function TableAnteInfoEach:deJson(jsonObj)
	
end

--------------------------------------------------------
--[[14发底注下注消息]]
TableAnteMSGData = class("TableAnteMSGData")

function TableAnteMSGData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rushPlayerId = ""
	self.m_totalPot = 0
	self.m_anteInfo = {}
end


function TableAnteMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_totalPot = jsonTable[TOTAL_POT] or 0
		
		self.m_anteInfo = {}
		local varTable = jsonTable[RAKE_INFO_BF_FLOP]
		if varTable==nil then
			varTable = {}
		end
		for index=1,#varTable do
			local childVar = varTable[index] or {}
			local anteInfo=TableAnteInfoEach:new()
			anteInfo.userId = childVar[USER_ID] or ""
			anteInfo.userChips = childVar[USER_CHIPS] or 0.0
			anteInfo.seatNo = tonumber(childVar[SEAT_NO]) or -1
			anteInfo.betChips = childVar[BET_CHIPS] or 0.0
			self.m_anteInfo[i] = anteInfo
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

return TableAnteMSGData