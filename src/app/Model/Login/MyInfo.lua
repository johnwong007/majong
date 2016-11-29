--
-- Author: WuBing
-- Date: 2015-04-07 16:09:14
--
require("app.Network.ParseKeyValue")
require("app.Logic.Datas.Lobby.UserTableList")
	eDebaoPlatformQQLogin=0
	eDebaoPlatformMainLogin=1
	eDebaoPlatformTouristLogin=2
	eDebaoPlatform500wan=3
	eDebaoPlatformPPS=4
	eDebaoPlatformAlipayOpen=5
	eDebaoPlatform91DPay=6
	eDebaoPlatformRegister=7
	eDebaoPlatformBaiduLogin=8
    eDebaoPlatformMeizuLogin=9
	eDebaoPlatformUnknow=10

	eDebaoPlatformJinLiLogin  = 11
	eDebaoPlatformXiaoMiLogin = 12
	eDebaoPlatformUNWOLogin   = 13
	eDebaoPlatformTENCENTLogin= 14
	eDebaoPlatformPengYouWanLogin= 15
	eDebaoPlatformUpayLogin= 16
	eDebaoPlatformNduoLogin = 17
	eDebaoPlatformUUCunLogin = 18
	eDebaoPlatformMuMaYiLogin = 19
	eDebaoPlatformLiTianLogin = 20
	eDebaoPlatformAnQuLogin = 21

GAllChannel = {
	[eDebaoPlatformQQLogin] 	 = "QQ",
	[eDebaoPlatformMainLogin] 	 = "DEBAO",
	[eDebaoPlatformTouristLogin] = "TOURIST",	
	[eDebaoPlatform500wan] 		 = "500WAN",

	[eDebaoPlatformUNWOLogin]  	 = "UNWO",
	[eDebaoPlatformTENCENTLogin] = "TENCENT",

	[eDebaoPlatformBaiduLogin] 	 = "BAIDU",
	[eDebaoPlatformMeizuLogin] 	 = "MEIZU",
	[eDebaoPlatformJinLiLogin] 	 = "JINLI",
	[eDebaoPlatformXiaoMiLogin]  = "XIAOMI",
	[eDebaoPlatformPengYouWanLogin]  = "PYW",
	[eDebaoPlatformUpayLogin]  = "UPAY",
	[eDebaoPlatformNduoLogin]  = "NDUO",
	[eDebaoPlatformUUCunLogin]  = "UUP",
	[eDebaoPlatformMuMaYiLogin]  = "MMY",
	[eDebaoPlatformLiTianLogin]  = "LT",
	[eDebaoPlatformAnQuLogin] = "ANQU"
} 
MyInfo = {}

function MyInfo:getData(jsonTable)
	-- dump(jsonTable)
	if type(jsonTable)=="number" then
		MyInfo.data.code = tostring(jsonTable)
	elseif type(jsonTable)=="table" then
		MyInfo.data.code = ""
		if jsonTable[CODE] then
			MyInfo.data.responseCode = tostring(jsonTable[CODE])
		end
		MyInfo.data.downloadUrl = jsonTable[UPDATE_URL]
		MyInfo.data.dscription = jsonTable[DSCRIPTION]
		MyInfo.data.newVersion = jsonTable[VERSION]
		if jsonTable[PRIVILEGE] then
			MyInfo.data.privilege = jsonTable[PRIVILEGE]
		end
		MyInfo.data.userId = jsonTable[USER_ID]
		MyInfo.data.userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		MyInfo.data.userSession = jsonTable[SESSION_ID]
		-- dump(jsonTable[SESSION_ID])
		MyInfo.data.phpSessionId = jsonTable[PHPSESSID]
		MyInfo.data.serverId = jsonTable[SERVERID]
		if not MyInfo.data.serverId then
			MyInfo.data.serverId = 0
		end
		MyInfo.data.serverPort = jsonTable[SERVERPORT]
		MyInfo.data.pushServerPort = jsonTable[PUSHPORT]
		MyInfo.data.userType = jsonTable[USER_TYPE]
		MyInfo.data.platform = jsonTable[PLATFORM]
		MyInfo.data.regTime = jsonTable[CRT_TIME]
		MyInfo.data.lotteryUrl = jsonTable[LOTTERY_URL]
		MyInfo.data.rewardUrl = jsonTable[REWARD_URL]
		if not MyInfo.data.rewardUrl or MyInfo.data.rewardUrl == "" then
			if MyInfo.data.phpSessionId then
				MyInfo.data.rewardUrl = "http://www.debao.com/?act=activity&mod=login_award&PHPSESSID="..MyInfo.data.phpSessionId
			end
		end
		MyInfo.data.rewardStatus = jsonTable[RWARD_STATUS]
		-- dump("服务器返回",MyInfo.data.platform)
		for i,v in pairs(GAllChannel) do 
			if v == jsonTable[PLATFORM] then 
				MyInfo.data.loginType = i
				break
			end
		end

	if device.platform == "android" or device.platform == "ios" then
		if MyInfo.data.userId ~= "" then 
			QManagerPlatform:crSetUid(MyInfo.data.userId)
		end
	end

		if MyInfo.data.userId ~= "" and MyInfo.data.userName~="" then
			QManagerPlatform:setAccountInfo(MyInfo.data.userId,MyInfo.data.userName)
		end
		
		if device.platform ~= "windows" then
			if jsonTable[PLATFORM] == "QQ" then
				QManagerPlatform:setAccountType({accountType = QManagerPlatform.TDCCAccountType.kAccountQQ})
			else
				QManagerPlatform:setAccountType({accountType = QManagerPlatform.TDCCAccountType.kAccountAnonymous})
			end
		end
		-----------
		MyInfo.data.safeRatio = 0.5

		MyInfo.data.firstLogin = jsonTable[FIRSTLOGIN]
		MyInfo.data.lastTableID = ""
		local sliver = jsonTable[SILVER_BALANCE]
		if sliver and sliver~="" then
			MyInfo.data.totalChips = sliver+0
		end
		MyInfo.data.currentOnlineNumber = jsonTable[CUR_UNUM]
		MyInfo.data.storeTip = jsonTable[PAYEVENT]

		MyInfo.data.regChannel = jsonTable[REG_CHANNEL]
		MyInfo.data.serverTime = jsonTable[SERVER_TIME]

		local tableList = jsonTable[TABLELIST]
		if type(tableList)=="table" then
			for index=1,#tableList do
				local tmp = UserListEach:new()
				tmp.tableId = tableList[index][TABLE_ID]
				MyInfo.data.lastTableID = tmp.tableId
				tmp.tabletype = tableList[index][TABLE_TYPE]
				MyInfo.data.userTableList.listUser[#MyInfo.data.userTableList.listUser+1] = tmp
			end
		end

		local procfg = jsonTable[PROCFG]
		if procfg then
			MyInfo.data.spanTime=procfg[USER_REGTIME]+0
			MyInfo.data.frequence_limit=procfg[FREQUENCE_LIMIT]+0.0
			if procfg[SILVER_LIMIT]~=nil and procfg[SILVER_LIMIT] ~="" then
				MyInfo.data.brokeMoney=procfg[SILVER_LIMIT]+0
			end
			MyInfo.data.activityId=procfg[ACTIVITY_ID]
			MyInfo.data.award_num=procfg[ AWARD_NUM]+0.0
		end
		MyInfo.data.userPotrait = jsonTable[USER_PORTRAIT]
		MyInfo.data.userQQ = jsonTable[USER_QQ]
		MyInfo.data.m_happyHourChance = jsonTable[HAPPYHOURCONFIG]  
	end
	return MyInfo.data
end

function MyInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	-- dump(jsonTable)
	if jsonTable then
		self:getData(jsonTable)
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

function MyInfo:getTotalChips()
	return MyInfo.data.totalChips+0.0001
end

function MyInfo:setTotalChips(chips)
	MyInfo.data.totalChips = chips+0
end
function MyInfo:getNextLevel()
    local curLevelExp  = tonumber(MyInfo.data.userExperience)
    local nextLevel = curLevelExp/100
    local nextLevelExp = (nextLevel + 1)*100

    for i = 15,23 do 
    	if nextLevel < i then
    		nextLevelExp = i * 100
    		break
    	end
    end
    return nextLevelExp
end
function MyInfo:new()
	MyInfo.data = {
			code = "",
			username = "",
			userName = "",
			responseCode = 1,
			downloadUrl = "",
			dscription = "",
			newVersion = "",
			privilege = 0,
			userId = "",
			userSession = "",
			phpSessionId = "",
			serverId = 0,
			serverPort = 30003,
			pushServerPort = 1,
			userType = "",
			platform = "",
			regTime = "",
			platform = "",
			lotteryUrl = "",
			rewardUrl = "",
			rewardStatus = 1,
			serverTime = 1,
			firstLogin = true,
			Global_ProxyIp = "",
			Global_ProxyPort = "",
			Global_Openkey = "",
			Global_Token = "",
			Global_Secret = "",

	userPotraitUri = "",		
	safeRatio = 0,
	loginType = eDebaoPlatformUnknow,
	userId = -1,
	userType = "TOURIST",    --/*正式 or not*///,
	userExp = 0,				--/*经验*///,
    userPhoneNO = "",
	diamondBalance=0.0,
	vipLevel=0,
    
	userDebaoDiamond = 0,		--/*德堡钻*///,
	totalChips = 0.0,
	userScore = 0,
	userSession = "",
	phpSessionId = "",
	serverId = 244,
	serverPort = 0,
	isNewer = false,
    leastSB = 5,
	m_firstLoginToday = true,
	storeTip = "",
	regedHours = 0,
	m_happyHourChance = 0,
    
	userLevel = 1,
	userSex   = "",
	userHead  = "",
	userVip   = 0,
	curVipExp = 0,			--当前VIP
	nextVipExp= 0,

	userClubId = "", -- 用户战队id
	userClubName = "",
	userClubPos  = "",--用户职位
	userExperience = 0,
	touchHideRoom = false,
	isKnow48Hour = false,
	requestPayRecord = false,
	payamount  = -1,
	isFetchLoginReward = false,
	isLearnGuide = false,
	noReadActType = 0,
	gameAdsType = 0,
	noticeNoReadNum = 0,
    
	showModifyInfo = false,
	firstLogin = false, 
	bAdvertisementShow = false,
	brokeMoney = 200,
	userTableList = UserTableList:new(),
	isSigned   = false,					--今日签到
	signTimes  = 0,						--本周签到次数
	isFirstLogin = false,				--第一次登录
	showFreegoldTips = false,			--免费红点
	showApplyBuy   = false,
	fightTeamId    = 0,
	headCheck	   = 0,					--头像审核，1-－审核中
			}
end

function MyInfo:getServerPort()
	return MyInfo.data.Global_ProxyPort
end

function MyInfo:setServerPort(point)
	MyInfo.data.Global_ProxyPort = point or ""
end

function MyInfo:clearCacheData()
	self:new()
end

MyInfo:new()
return MyInfo