
-----------------------------------------------------------------
--[[
* 推送信息
 * m_type = 1 : 牌桌内显示（腾讯及主站）
 * m_type = 2 : 牌桌内显示，手数活动（任务系统，腾讯及主站）
 * m_type = 3 : 牌桌内显示，Happy Hour活动（腾讯及主站）
 * m_type = 15 : 牌手分（主站）
 * m_type = 29 : 大喇叭
 * m_type = 47 : pk赛未匹配成功
 * m_type = 50 : 滚播消息
 * 其他 ==> 牌桌内消息提示
 * m_simbol = 1 : 结构体
 * m_simbol = 2 : 字符串
]]
PushMessage = class("PushMessage")

function PushMessage:ctor()
	self.m_simbol = 0
	self.m_type = 0
	self.m_message = ""
	self.m_sender = ""
end

function PushMessage:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_simbol = jsonTable["simbol"] or 0
		self.m_type = jsonTable[PUSH_TYPE] or 0
		
		if self.m_simbol==1 then
			self.m_message = jsonTable["PUSH_MESSAGE"] or ""
			self.m_sender = jsonTable["PUSH_SENDER"] or ""
		elseif self.m_simbol==2 then
			self.m_message = jsonTable["PUSH_MESSAGE"] or ""
			self.m_sender = jsonTable["PUSH_SENDER"] or ""
		else
			self.m_message = ""
			self.m_sender = ""
		end
		self.parsResult = BIZ_PARS_JSON_SUCCESS

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end


-----------------------------------------------------------------
--[[牌手分推送消息]]
CardHandPointPushMsg = class("CardHandPointPushMsg")

function CardHandPointPushMsg:ctor()
	self.userId = ""
	self.pointNow = 0
	self.pointOld = 0
	self.levelNow = 0
	self.levelOld = 0
end

function CardHandPointPushMsg:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.userId = jsonTable[USER_ID]..""
		self.pointNow = jsonTable[USER_LADDER_POINT]+0
		self.pointOld = jsonTable[USER_OLD_LADDER_POINT]+0
		self.levelNow = jsonTable[USER_LEVEL]+0
		self.levelOld = jsonTable[USER_OLD_LEVEL]+0
		
		self.parsResult = BIZ_PARS_JSON_SUCCESS

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

-----------------------------------------------------------------
--[[大喇叭推送]]
LoudSpeakerMsg = class("LoudSpeakerMsg")

function LoudSpeakerMsg:ctor()
	self.userId = ""
	self.userName = ""
	self.content = ""
end

function LoudSpeakerMsg:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.userId = jsonTable[USER_ID]..""
		self.userName = revertPhoneNumber(tonumber(jsonTable[USER_NAME]))
		self.content = jsonTable[BOARDCAST_CONTENT]..""
		
		self.parsResult = BIZ_PARS_JSON_SUCCESS

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

-----------------------------------------------------------------
return PushMessage