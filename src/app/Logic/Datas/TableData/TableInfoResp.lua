require("app.Logic.Datas.TableData.WaitForMSGData")
require("app.Logic.Datas.TableData.BoardInfo")
local myInfo = require("app.Model.Login.MyInfo")

PlayerListEach = class("PlayerListEach")
function PlayerListEach:ctor()
    self.seatNo=0
    self.roundChips=0.0
    self.handChips=0.0
    self.userId=""
    self.isTrustee=false
    self.userName=""
	self.userSex=""
	self.imageURL=""
    self.userChips=0.0
    self.userStatus=0
	self.privilege=0
end

function PlayerListEach:deJson(jsonObj)
	if jsonObj == nil then
		return 
	end
	-- dump(jsonObj)
    self.seatNo = tonumber(jsonObj[SEAT_NO]) or -1
	--self.qqName=jsonObj[QQ_NAME]
    
	if TRUNK_VERSION==DEBAO_TRUNK then
		self.userName = revertPhoneNumber(tostring(jsonObj[USER_NAME]))
		self.userSex = jsonObj[USER_SEX] or ""
	else
		self.userName = jsonObj[QQ_NAME] or ""
		self.userSex = jsonObj[QQ_SEX] or ""
 	end
    
	self.imageURL = jsonObj[HeadPic_URL] or ""
    self.roundChips = jsonObj[ROUND_CHIPS] or 0.0
    self.handChips = jsonObj[HAND_CHIPS] or 0.0
    self.userId = jsonObj[USER_ID] or ""
    self.isTrustee = jsonObj[IS_TRUSTEE] or false
    self.userName = jsonObj[USER_NAME] or ""
    self.userChips = jsonObj[USER_CHIPS] or 0.0
    self.userStatus = jsonObj[PLAYER_STATUS] or 0
	self.privilege = jsonObj[PRIVILEGE] or 0
	self.applyDelayTime = tonumber(jsonObj[APPLY_DELAY_TIMES])
	self.keepSeatSTime = tonumber(jsonObj[KEEP_SEAT_STIME])
end

-----------------------------------------------------
--[[     
	 K.SEAT_NO       : ,
     K.POCKET_CARDS  : ,
     K.BUY_CHIPS_MAX : ,(说明:这2个值，是当玩家留座再次调用，可以知道最大买入
     K.BUY_CHIPS_MIN : , 和最小买入，当不是留座，则2个值为0)
     K.SBLIND_DODGE_NUM : ,
     K.BBLIND_DODGE_NUM : ,
     K.AUTO_BLIND_TYPE  : ,
     K.IS_NEW_PLAYER    : ,
     K.IS_TRUSTEE       : ,(当玩家没有座位的时候有)
]]
PlayerMyInfo = class("PlayerMyInfo")
function PlayerMyInfo:ctor()
	self.seatNo = -1
	self.isTrustee=false
	self.pocketCards = {}
	self.buyChipsMax = 0.0
	self.buyChipsMin = 0.0
	self.rebuyCount = 0
end

function PlayerMyInfo:deJson(jsonObj)
	if jsonObj then
		self.seatNo = jsonObj[SEAT_NO]
		self.buyChipsMax = jsonObj[BUY_CHIPS_MAX]
		self.buyChipsMin = jsonObj[BUY_CHIPS_MIN]
		self.isTrustee = jsonObj[IS_TRUSTEE]
		self.pocketCards = jsonObj[POCKET_CARDS]
		if jsonObj[REBUY_COUNT] then
			self.rebuyCount = jsonObj[REBUY_COUNT]
		end
		self.buyinTimes = tonumber(jsonObj[BUYIN_TIMES])
	else
		self.isTrustee=false
		self.seatNo = -1
	end
end

-----------------------------------------------------

CurrentTableInfo = class("CurrentTableInfo")
function CurrentTableInfo:ctor()
	self.seatNum = 0  --总共有多座位
	self.payType = ""   --支付类型：金币场 银币场
	self.tableType = "" -- 牌桌类型:CASH SITANDGO
	self.playType = ""			--玩牌类型
	self.totalPot = 0.0  --总奖池数
	self.bigBlind = 0.0  --大盲注数
	self.smallBlind = 0.0--小盲注数
	self.buyChipsMax = 0.0--桌子内 买入最大值
	self.buyChipsMin = 0.0--桌子内 买入最小值
	self.sequence = 0   --操作标志位
	self.bBlindNo = 0   --大盲座位号
	self.sBlindNo = 0   --小盲座位号
	self.waitForNo = 0  --等待的人的座位号
	self.gameStatus = 0 --游戏状态
	self.dealerNo = 0   --庄家位置
	self.remainTime = 0--玩家剩余下注时间
	self.handStartRemainTime = 0--（下一手）牌局开始的剩余时间
	self.handId = ""    --牌局ID，牌局回放等用到
	self.ante = 0.0      --底注
	self.gameSpeed = 0	 --游戏速度
	self.tableId = ""   --牌桌id
	self.tableName = "" --牌桌名称
    self.communityCards = {}--公共牌
    self.potInfo = {}       --奖池信息
	self.m_optionAction = WAIT_FOR_MSG_OPTIONAL_ACTIONS:new()
    
    
	--以下字段只有锦标赛中才有
	self.isRebuy = false	--是否是rebuy赛
	self.blindLevel = 0	--当前盲足级别
	self.legalBlindLevel = 0	--合法rebuy盲足级别
	self.rebuyPayMoney = 0.0		--rebuy的花费
	self.rebuyValue = 0.0			--rebuy一次增加的筹码
	self.rebuyLimitCount = 0	--rebuy限制次数
	self.playerInitChips = 0.0	--玩家初始筹码
	self.rebuyCount = 0			--已重购次数
	self.tableInitChips = 0.0		--赛事开始玩家的初始筹码

	self.serviceCharge = 0.0 --服务费
	self.tableOwner = "" --房主id
end

function CurrentTableInfo:deJson(jsonObj)
	if jsonObj == nil then
		return 
	end
	self.isRebuy = false
    self.totalPot = jsonObj[TOTAL_POT]
    self.payType = jsonObj[PAY_TYPE]
   	self.serviceCharge = tonumber(jsonObj[SERVICE_CHARGE])
   	self.tableOwner = jsonObj[TABLE_OWNER]
    self.buyChipsMax = jsonObj[BUY_CHIPS_MAX]
	self.buyChipsMin = jsonObj[BUY_CHIPS_MIN]
	self.sequence = jsonObj[SEQUENCE]
	self.bBlindNo = jsonObj[BBLIND_NO]
	self.sBlindNo = jsonObj[SBLIND_NO]
	self.waitForNo = jsonObj[WAIT_FOR_NO]
	self.gameStatus = jsonObj[GAME_STATUS]
	self.dealerNo = jsonObj[BUTTON_NO]
	self.remainTime = jsonObj[REMAIN_TIME]
	self.handStartRemainTime = jsonObj[HAND_START_REMAIN_TIME]
	self.bigBlind = jsonObj[BIG_BLIND]
	self.smallBlind = jsonObj[SMALL_BLIND]
    self.seatNum = jsonObj[SEAT_NUM]
	self.handId = jsonObj[HAND_ID]
	BoardInfo:getInstance().handID = ""
	BoardInfo:getInstance().handID = self.handId
	self.ante = jsonObj[ANTE]
	self.gameSpeed = jsonObj[GAME_SPEED]
	self.tableType = jsonObj[TABLE_TYPE]
	self.tableId = jsonObj[TABLE_ID]
    self.tableName = jsonObj[TABLE_NAME]
	self.playType = jsonObj[PLAY_TYPE]
	local optionalAction1 = jsonObj[OPTIONAL_ACTIONS]
	self.m_optionAction.m_call=optionalAction1[CALL]
	local raiseRange= optionalAction1[RAISE]
	self.m_optionAction.m_raise = raiseRange
    local communityCardsJson = jsonObj[COMMUNITY_CARDS]
	self.communityCards=communityCardsJson
	self.destroyTime = jsonObj["A009"]
    
	local potInfoJson = jsonObj[POT_INFO]
	self.potInfo = potInfoJson
	
	if jsonObj[IS_REBUYTOURNEY] then
		self.isRebuy = jsonObj[IS_REBUYTOURNEY] == "YES" and true or false
		self.blindLevel = jsonObj[BLIND_LEVEL]
		self.legalBlindLevel = jsonObj[LEGAL_BLIND_LEVEL]
		self.rebuyPayMoney = jsonObj[REBUY_PAY_MONEY]
		self.rebuyValue = jsonObj[REBUY_VALUE]
		self.rebuyLimitCount = jsonObj[REBUY_LIMIT_COUNT]
		self.tableInitChips = jsonObj[TABLE_INIT_CHIPS]
		--self.playerInitChips = jsonObj[PLAYER_INIT_CHIPS]
		local initChip = jsonObj[PLAYER_INIT_CHIPS]
		local selfInit = initChip[myInfo.data.userId]
		if selfInit then
			self.playerInitChips = selfInit[USER_CHIPS]
			self.rebuyCount = selfInit[REBUY_COUNT]
		end
	end
	
end
-----------------------------------------------------

TableInfoResp = class("TableInfoResp")

function TableInfoResp:ctor()
    self.tableId = ""
	self.rushPlayerId = ""
    self.m_code = 0
    self.playerList = {}
    self.playerMyInfo = PlayerMyInfo:new()
    self.currentTableInfo = CurrentTableInfo:new()
end

function TableInfoResp:parseJson(strJson)
	local jsonTable = strJson
	-- dump(jsonTable)
	if type(jsonTable) == "table" then
		if type(jsonTable[CODE]) ~= "number" then
			return BIZ_PARS_JSON_FAILED
		end
		self.m_code = jsonTable[CODE]
		self.tableId = jsonTable[TABLE_ID] or ""
		if jsonTable[RUSH_PLAYER_ID] then
			self.rushPlayerId = jsonTable[RUSH_PLAYER_ID]
		end
		if string.len(self.rushPlayerId)>1 then
			self.tableId = string.rushPlayerId
		end
		local playerListJson = jsonTable[PLAYER_LIST]
		if playerListJson then
			for i=1,#playerListJson,1 do
				local eachOne = PlayerListEach:new()
				eachOne:deJson(playerListJson[i])
				self.playerList[i] = eachOne
			end
		end
		local playerMyInfoJson = jsonTable[PLAYER_MYINFO]
		self.playerMyInfo:deJson(playerMyInfoJson)

		local tableInfoJson = jsonTable[TABLE_INFO]
		self.currentTableInfo:deJson(tableInfoJson)
		return BIZ_PARS_JSON_SUCCESS
	end
end

return TableInfoResp
-----------------------------------------------------
