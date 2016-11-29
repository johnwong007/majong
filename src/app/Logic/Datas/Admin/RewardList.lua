local RewardInfo = class("RewardInfo")

function RewardInfo:ctor()
	self.userId = ""
	self.activityId = ""
	self.rewardId = ""
	self.isRewarded = ""
	self.limitKey = ""
	self.reMark = ""
	self.tradType = ""
	self.rewardNum = 0.0
end

--------------------------------------------------
local RewardList = class("RewardList")

function RewardList:ctor()
	self.rewardInfoList = {}
end

function RewardList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		local node = RewardInfo:new()
		for i=1,#jsonTable do
			node.activityId = jsonTable[i][ACTIVITY_ID]
			node.isRewarded = jsonTable[i][IS_REWARDED]
			node.limitKey = jsonTable[i][LIMIT_KEY]
			node.reMark = jsonTable[i][REMARK]
			node.rewardId = jsonTable[i][REWARD_ID]
			node.rewardNum = jsonTable[i][REWARD_NUM]
			node.tradType = jsonTable[i][TRADE_TYPE]
			node.userId = jsonTable[i][USER_ID]
			self.rewardInfoList[#self.rewardInfoList] = node
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RewardList