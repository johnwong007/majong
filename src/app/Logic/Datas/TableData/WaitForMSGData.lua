WAIT_FOR_MSG_OPTIONAL_ACTIONS = class("WAIT_FOR_MSG_OPTIONAL_ACTIONS")
function WAIT_FOR_MSG_OPTIONAL_ACTIONS:ctor()
	self.m_call = 0.0	--[[当前叫住玩家需要的跟著数 若为零就看牌 要判断0 是0就看牌 不是零 跟著X]]
	self.m_raise = {}	--[[最小加注到的筹码数，最大筹码数 最大是-1 忽略]]
end

WaitForMSGData = class("WaitForMSGData")

function WaitForMSGData:ctor()
	self.m_tableId = ""
	self.m_rushPlayerId= ""
	self.m_waitForNo = 0
	self.m_remainTime = 0
	self.m_sequence = 0
	self.m_optionAction = WAIT_FOR_MSG_OPTIONAL_ACTIONS:new()
end

function WaitForMSGData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_tableId = jsonTable[TABLE_ID]..""
		self.m_waitForNo = jsonTable[WAIT_FOR_NO]+0
		self.m_remainTime = jsonTable[REMAIN_TIME]+0
		self.m_sequence = jsonTable[SEQUENCE]+0
		local optionalAction1 = jsonTable[OPTIONAL_ACTIONS]
		self.m_optionAction.m_call = optionalAction1[CALL]+0.0
		local raiseRange = optionalAction1[RAISE]
		for index=1,#raiseRange do
			local num = raiseRange[index]+0.0
			self.m_optionAction.m_raise[#self.m_optionAction.m_raise+1] = num
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

return WaitForMSGData