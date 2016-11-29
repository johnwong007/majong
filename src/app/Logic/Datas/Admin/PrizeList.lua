local PrizeInfo = {
	prizeBeginRank = 0,
	prizeEndRank = 0,
	prizePool = 0,
	bonusRatio = 0,
	bonusID = "",
	bonusName = "",
}

local PrizeList = class("PrizeList")

function PrizeList:ctor()
	self.prizeInfoList = {}
end

function PrizeList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then

		for i=1,#jsonTable do
			local prize = clone(PrizeInfo)
			prize.prizeBeginRank = jsonTable[i][PRIZE_BEGIN_RANK] + 0
			prize.prizeEndRank = jsonTable[i][PRIZE_END_RANK] + 0
			prize.prizePool = jsonTable[i][PRIZE_POOL] + 0
			prize.bonusRatio = (jsonTable[i][BONUS_RATIO]+0) / 100
			prize.bonusID = jsonTable[i][BONUS_ID]..""
			prize.bonusName = jsonTable[i][BONUS_NAME]..""
			self.prizeInfoList[#self.prizeInfoList+1] = prize
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return PrizeList