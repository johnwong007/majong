local MatchBlindInfo = 
{
	gameSpeed = "",
	ante = 0,
	smallBlind = 0.0,
	bigBlind = 0.0,
	blindLevel = 0,
	blindType = "",
	blindDuration = 0,
}

local BlindDSInfo = class("BlindDSInfo")

function BlindDSInfo:ctor()
	self.blindConfig = {}
end

function BlindDSInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "number" then
		self.code = jsonTable+0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "table" then
		
		for i=1,#jsonTable do
			local temp = jsonTable[i]
				local info = clone(MatchBlindInfo)
				info.bigBlind = temp[BIG_BLIND]+0.0
				info.smallBlind = temp[SMALL_BLIND]+0.0
				info.ante = temp[ANTE]+0
				info.blindDuration = temp[BLIND_DURATION]+0
				info.blindLevel = temp[BLIND_LEVEL]+0
				info.blindType = temp[BLIND_TYPE]..""
				info.gameSpeed = temp[GAME_SPEED]..""
				self.blindConfig[#self.blindConfig+1] = info
		end

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return BlindDSInfo