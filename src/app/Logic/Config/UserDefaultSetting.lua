local myInfo = require("app.Model.Login.MyInfo")
s_boolIsHideFullRoom = "s_boolIsHideFullRoom" --是否隐藏满员桌
s_boolIsEmptyFullRoom = "s_boolIsEmptyFullRoom" --是否隐藏空员桌

s_boolIsShowSixSeat = "s_boolIsShowSixSeat" --是否显示 六人桌
s_boolIsShowNineSeat = "s_boolIsShowNineSeat" --是否显示九人桌

s_boolIsHideSixSeat = "s_boolIsHideSixSeat" --是否隐藏 六人桌
s_boolIsHideNineSeat = "s_boolIsHideNineSeat" --是否隐藏 九人桌

s_boolIsMusicEnable     = "s_boolIsMusicEnable"   --背景音乐
s_boolIsSoundEnable     = "s_boolIsSoundEnable"   --声音
s_boolIsVibrateEnable     = "s_boolIsVibrateEnable"   --震动
s_boolIsBubbleEnable    = "s_boolIsBubbleEnable"  --聊天
s_boolNewTipsEnable     = "s_boolNewTipsEnable"   --新手指引
s_intLastLoginTimeStamp = "s_intLastLoginTimeStamp"--上一次登录时间戳
s_boolIsAutoBuyChipsEnable = "s_boolIsAutoBuyChipsEnable" --是否自动买入
s_intFreeGoldTimes = "s_intFreeGoldTimes" --免费金币次数

s_boolIsLearn = "s_boolIsLearn"  --主界面是否显示提示新手学习标志
s_boolIsFirstLost = "s_boolIsFirstLost"	--是否第一次输光手上筹码

--用户登录信息
s_userTokenKey	= "s_saveUserTokenKey" --存起用户登录的获取到的token
s_userSecretKey = "s_saveUserSecretKey" --存起用户登录获取到的secret
s_serverIpKey = "s_saveServerIPKey" --存起用户登录是获取的IP

--规则了解
s_boolClickedLoginRewardRule = "s_boolClickedLoginRewardRule" --是否了解过登录奖励规则

--商城
s_boolClickedShopScene = "s_boolClickedShopScene" --是否点击过商场

--主站
s_lastTimeDebaoName = "s_lastTimeDebaoName" --最后一次登录的用户名
s_lastTimeDebaoPassword = "s_lastTimeDebaoPassword" --最后一次登录的密码
s_lastTime500Name = "s_lastTime500Name" --最后一次登录的500用户名
s_lastTime500Password = "s_lastTime500Password" --最后一次登录的500密码
s_boolRememberAccount = "s_boolRememberAccount" --是否记住帐号
s_boolRememberPassword = "s_boolRememberPassword" --是否记住密码
s_bool500RememberAccount = "s_bool500RememberAccount" --是否记住500帐号
s_bool500RememberPassword = "s_bool500RememberPassword" --是否记住500密码

s_boolAutoLogin = "s_boolAutoLogin" --是否自动登录
s_bool500AutoLogin = "s_bool500AutoLogin" --是否500帐号自动登录
s_stringLastLoginType = "s_stringLastLoginTypeNew" --上次登录方式
s_stringTencentOpenId = "s_stringTencentOpenId"
s_stringTencentToken = "s_stringTencentToken"
s_intTencentExpires = "s_intTencentExpires"
s_intTencentInfoTime = "s_intTencentInfoTime"
s_showAdvertisement="s_showAdvertisement"--是否不再显示公告

s_string500WANToken = "s_string500WANToken"
s_int500WANExpires = "s_int500WANExpires"
s_int500WANInfoTime = "s_int500WANInfoTime"

s_boolNeedWinLoseTip = "s_boolNeedWinLoseTip"
s_boolNeedShowDown = "s_boolNeedShowDown"

s_bShowAddFriendsFromConcern = "s_bShowAddFriendsFromConcern"

s_b48HoursOver = "s_bnewer48HoursOver"

s_face_version = "s_face_version"
s_safe_setting = "s_safe_setting"

s_pk_match_applyed = "s_pk_match_applyed"

s_uniconm_report_switch = "s_uniconm_report_switch"

s_refresh_report_switch = "s_refresh_report_switch"

s_repeat_report_flag = "s_repeat_report_flag"

s_game_type = "s_game_type"

s_llpay_flag = "s_llpay_flag"

s_android_package_dir = "s_android_package_dir"
s_android_sdk_version = "s_android_sdk_version"

s_unlogin_debao_uname = "s_unlogin_debao_uname"
s_unlogin_500wan_uname = "s_unlogin_500wan_uname"
s_unregister_debao_uname = "s_unregister_debao_uname"

s_lastLogin_uname = "s_lastLogin_uname"
s_lastLogin_password = "s_lastLogin_password"

s_user_potrait  = "s_user_potrait"
s_user_sex  = "s_user_sex"

i_user_privilege  = "i_user_privilege"

i_RakePointGameShow  = "i_RakePointGameShow"

i_SNGGameShow  = "i_SNGGameShow"
i_getAppleCheckFlag  = "i_getAppleCheckFlag"

--[[Appstore充值]]
s_applePayUserId = "s_applePayUserId"
s_applePayUserName = "s_applePayUserName"
s_applePayEncodeJson = "s_applePayEncodeJson"
s_applePayOrderId = "s_applePayOrderId"
s_applePaytrans = "s_applePaytrans"
s_applePayTimes = "s_applePayTimes"
s_privateRoomMsgHint = "s_privateRoomMsgHint"

--[[安趣充值]]
s_anquPayUserId = "s_anquPayUserId"
s_anquPayPcorder = "s_anquPayPcorder"
s_anquPayOrder = "s_anquPayOrder"
s_anquPayMoney = "s_anquPayMoney"
s_anquPayTimes = "s_anquPayTimes"

UserDefaultSetting = class("UserDefaultSetting")

sharedUserDefaultSetting = nil
local sharedUserDefault = cc.UserDefault:getInstance()

function UserDefaultSetting:getInstance()
	if sharedUserDefaultSetting == nil then
		sharedUserDefaultSetting = UserDefaultSetting:new()
	end
	return sharedUserDefaultSetting
end

function UserDefaultSetting:ctor()

	--默认
	self.m_isHideFullRoom = sharedUserDefault:getBoolForKey(s_boolIsHideFullRoom,false)
	self.m_isHideEmptyRoom = sharedUserDefault:getBoolForKey(s_boolIsEmptyFullRoom,false)
	self.m_isShowSixSeat = sharedUserDefault:getBoolForKey(s_boolIsShowSixSeat,true)
	self.m_isShowNineSeat = sharedUserDefault:getBoolForKey(s_boolIsShowNineSeat,true)
	self.m_isHideSixSeat = sharedUserDefault:getBoolForKey(s_boolIsHideSixSeat,false)
	self.m_isHideNineSeat = sharedUserDefault:getBoolForKey(s_boolIsHideNineSeat,false)
    --默认的三项都是打开的
	self.m_isSoundEnable   = sharedUserDefault:getBoolForKey(s_boolIsSoundEnable,true)
	self.m_isBubbleEnable  = sharedUserDefault:getBoolForKey(s_boolIsBubbleEnable,true)
    self.m_isVibrateEnable = sharedUserDefault:getBoolForKey(s_boolIsVibrateEnable,true)
	self.m_showAdvertisement = sharedUserDefault:getBoolForKey(s_showAdvertisement, true)
	
	self.m_token = sharedUserDefault:getStringForKey(s_userTokenKey,"")
	self.m_secret = sharedUserDefault:getStringForKey(s_userSecretKey,"")
	self.m_ip = sharedUserDefault:getStringForKey(s_serverIpKey,g_ServerIP)
    
	self.m_debaoName = sharedUserDefault:getStringForKey(s_lastTimeDebaoName, "")
	self.m_debaoPassword = sharedUserDefault:getStringForKey(s_lastTimeDebaoPassword, "")
	self.m_500Name =sharedUserDefault:getStringForKey(s_lastTime500Name, "")
	self.m_500Password = sharedUserDefault:getStringForKey(s_lastTime500Password, "")
	
	self.m_bAutoLogin = sharedUserDefault:getBoolForKey(s_boolAutoLogin, true)
	self.m_b500AutoLogin = sharedUserDefault:getBoolForKey(s_bool500AutoLogin, true)
	self.m_bRemeberAccount = sharedUserDefault:getBoolForKey(s_boolRememberAccount, true)
	self.m_bRemeberPassword = sharedUserDefault:getBoolForKey(s_boolRememberPassword, false)
	self.m_b500RemeberAccount = sharedUserDefault:getBoolForKey(s_bool500RememberAccount, true)
	self.m_b500RemeberPassword = sharedUserDefault:getBoolForKey(s_bool500RememberPassword, true)
	
	self.m_freegoldTimes = sharedUserDefault:getIntegerForKey(s_intFreeGoldTimes, 3)
	--m_lastLoginType = sharedUserDefault:getStringForKey(s_stringLastLoginType, "TOURIST")
	
	self.m_lastLoginType = sharedUserDefault:getStringForKey(s_stringLastLoginType, "")
    
	self.m_tencentOpenId = sharedUserDefault:getStringForKey(s_stringTencentOpenId, "")
	self.m_tencentToken = sharedUserDefault:getStringForKey(s_stringTencentToken, "")
	self.m_tencentExpiresin = sharedUserDefault:getIntegerForKey(s_intTencentExpires, 0)
	self.m_tencentInfoTime = sharedUserDefault:getIntegerForKey(s_intTencentInfoTime, 0)
    
	self.m_500WANToken = sharedUserDefault:getStringForKey(s_string500WANToken, "")
	self.m_500WANExpiresin = sharedUserDefault:getIntegerForKey(s_int500WANExpires, 0)
	self.m_500WANInfoTime = sharedUserDefault:getIntegerForKey(s_int500WANInfoTime, 0)
    
	self.m_bNeedShowDown = sharedUserDefault:getBoolForKey(s_boolNeedShowDown,true)
	self.m_bNeedWinLoseTip = sharedUserDefault:getBoolForKey(s_boolNeedWinLoseTip,true)
    
	--初始化
	self.m_isNewTipsEnable = true
	self.m_nLastLoginTimeStamp = 0

	self.bAutoInit = false
	self.m_isAutoBuyChipsEnable = false
	self.bLostInit = false
end

----------------------------------------------------------

function UserDefaultSetting:get500WANLoginName()
	return self.m_500Name
end
function UserDefaultSetting:get500WANLoginPassword()
	return self.m_500Password
end
function UserDefaultSetting:getDebaoLoginName()
	return self.m_debaoName
end
function UserDefaultSetting:getDebaoLoginPassword()
	return self.m_debaoPassword
end

function UserDefaultSetting:getRemeberAccountEnable()
	return self.m_bRemeberAccount
end
function UserDefaultSetting:getRemeberPasswordEnable()
	return self.m_bRemeberPassword
end
function UserDefaultSetting:getAutoLoginEnable()
	return self.m_bAutoLogin
end
function UserDefaultSetting:get500AutoLoginEnable()
	return self.m_b500AutoLogin
end
function UserDefaultSetting:get500RemeberAccountEnable()
	return self.m_b500RemeberAccount
end
function UserDefaultSetting:get500RemeberPasswordEnable()
	return self.m_b500RemeberPassword
end
function UserDefaultSetting:get500AutoLoginEnable()
	return self.m_b500AutoLogin
end
function UserDefaultSetting:getLastLoginType()
	return self.m_lastLoginType
end
function UserDefaultSetting:getTencentOpenId()
	return self.m_tencentOpenId
end
function UserDefaultSetting:getTencentToken()
	return self.m_tencentToken
end
function UserDefaultSetting:getTencentExpires()
	return self.m_tencentExpiresin
end
function UserDefaultSetting:getTencentInfoTime()
	return self.m_tencentInfoTime
end
function UserDefaultSetting:get500WANToken()
	return self.m_500WANToken
end
function UserDefaultSetting:get500WANExpires()
	return self.m_500WANExpiresin
end
function UserDefaultSetting:get500WANInfoTime()
	return self.m_500WANInfoTime
end
function UserDefaultSetting:getHideFullRoom()
	return self.m_isHideFullRoom
end
function UserDefaultSetting:getHideEmptyRoom()
	return self.m_isHideEmptyRoom
end

function UserDefaultSetting:getShowSixSeat()
	return self.m_isShowSixSeat
end
function UserDefaultSetting:getShowNineSeat()
	return self.m_isShowNineSeat
end

function UserDefaultSetting:getHideSixSeat()
	return self.m_isHideSixSeat
end
function UserDefaultSetting:getHideNineSeat()
	return self.m_isHideNineSeat
end
function UserDefaultSetting:getFreeGoldTimes()
	return self.m_freegoldTimes
end
function UserDefaultSetting:setFreeGoldTimes(times)
    sharedUserDefault:setIntegerForKey(s_intFreeGoldTimes, times)
    self.m_freegoldTimes = times
    sharedUserDefault:flush()
end
function UserDefaultSetting:getSoundEnable()
	return self.m_isSoundEnable
end
function UserDefaultSetting:setMusicEnable(value)
    sharedUserDefault:setBoolForKey(s_boolIsMusicEnable, value)
	sharedUserDefault:flush()
end
function UserDefaultSetting:getMusicEnable()
	return sharedUserDefault:getBoolForKey(s_boolIsMusicEnable, true)
end
function UserDefaultSetting:getVibrateEnable()
	return self.m_isVibrateEnable
end
function UserDefaultSetting:getBubbleEnable()
	return self.m_isBubbleEnable
end
function UserDefaultSetting:getNewTipsEnable()
	return self.getNewTipsEnable
end
function UserDefaultSetting:getLastLoginTimeStamp()
	return self.m_nLastLoginTimeStamp
end
function UserDefaultSetting:getUserToken()
	return self.m_token
end
function UserDefaultSetting:getUserSecret()
	return self.m_secret
end
function UserDefaultSetting:getServerIP()
	return self.m_ip
end
function UserDefaultSetting:getIsLearn()
	return self.m_isLearn
end
--[[游戏规则]]
function UserDefaultSetting:isClickLoginRewardRule()
	return self.m_bClickLoginRewardRule
end
--[[商城是否点击过（充值提示用）]]
function UserDefaultSetting:isClickShopScene()
	return self.m_bClickShopScene
end
--[[设置是否亮牌]]
function UserDefaultSetting:needShowDown()
	return self.m_bNeedShowDown
end
--[[设置是否显示盈亏]]
function UserDefaultSetting:needWinLoseTip()
	return self.m_bNeedWinLoseTip
end
function UserDefaultSetting:getShowAdvertisement()
	return self.m_showAdvertisement
end
--[[游戏规则]]
function UserDefaultSetting:isClickLoginRewardRule()
	return self.m_bClickLoginRewardRule
end
--[[游戏规则]]
function UserDefaultSetting:isClickLoginRewardRule()
	return self.m_bClickLoginRewardRule
end
--[[游戏规则]]
function UserDefaultSetting:isClickLoginRewardRule()
	return self.m_bClickLoginRewardRule
end
--[[游戏规则]]
function UserDefaultSetting:isClickLoginRewardRule()
	return self.m_bClickLoginRewardRule
end
----------------------------------------------------------
function UserDefaultSetting:initLoginUserSetting()
	self.m_isNewTipsEnable = sharedUserDefault:getBoolForKey(s_boolNewTipsEnable,myInfo.data.isNewer)
	
	--[[上次登录时间戳]]
	local key = ""
	key = key..s_intLastLoginTimeStamp
	key = key..myInfo.data.userId
	self.m_nLastLoginTimeStamp = sharedUserDefault:getIntegerForKey(key, 0)

	--[[大厅新手教学]]
	key = ""
	key = key..s_boolIsLearn
	key = key..myInfo.data.userId
	self.m_isLearn = sharedUserDefault:getBoolForKey(key, false)

	--[[登录奖励规则]]
	key = ""
	key = key..s_boolClickedLoginRewardRule
	key = key..myInfo.data.userId
	self.m_bClickLoginRewardRule = sharedUserDefault:getBoolForKey(key, false)

	--[[是否点击过商城]]
	key = ""
	key = key..s_boolClickedShopScene
	key = key..myInfo.data.userId
	self.m_bClickShopScene = sharedUserDefault:getBoolForKey(key, false)
end

function UserDefaultSetting:getAutoBuyChip()	
	if self.bAutoInit == false then
		local key = s_boolIsAutoBuyChipsEnable..myInfo.data.userId
		self.m_isAutoBuyChipsEnable = sharedUserDefault:getBoolForKey(key, false)
		self.bAutoInit = true
	end
	return self.m_isAutoBuyChipsEnable
end

function UserDefaultSetting:getHasFirstLost()	
	if self.bLostInit == false then
		local key = s_boolIsFirstLost..myInfo.data.userId
		self.m_hasFirstLost = sharedUserDefault:getBoolForKey(key, false)
		self.bAutoInit = true
	end
	return self.m_hasFirstLost
end

function UserDefaultSetting:setHasFistLost(hasLost)
	if hasLost == self.m_hasFirstLost then
		return 
	end
	local key = s_boolIsFirstLost..myInfo.data.userId
	sharedUserDefault:setBoolForKey(setBoolForKey, hasLost)
	self.m_hasFirstLost = hasLost
	sharedUserDefault:flush()
end

function UserDefaultSetting:setSoundEnable(isSoundEnable)
	if isSoundEnable == self.m_isSoundEnable then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolIsSoundEnable, isSoundEnable)
	self.m_isSoundEnable = isSoundEnable
	sharedUserDefault:flush()
end

function UserDefaultSetting:setVibrateEnable(isVibrateEnable)
	if isVibrateEnable == self.m_isVibrateEnable then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolIsVibrateEnable, isVibrateEnable)
	self.m_isVibrateEnable = isVibrateEnable
	sharedUserDefault:flush()
end

function UserDefaultSetting:setBubbleEnable(isBubbleEnable)
	if isBubbleEnable == self.m_isBubbleEnable then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolIsVibrateEnable, isBubbleEnable)
	self.m_isBubbleEnable = isBubbleEnable
	sharedUserDefault:flush()
end

function UserDefaultSetting:setNewTipsEnable(isNewTipsEnable)
	if isNewTipsEnable == self.m_isNewTipsEnable then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolIsVibrateEnable, isNewTipsEnable)
	self.m_isNewTipsEnable = isNewTipsEnable
	sharedUserDefault:flush()
end

function UserDefaultSetting:setLastLoginTimeStamp(userId, timeStamp)
	if timeStamp ~= self.m_nLastLoginTimeStamp then
		self.m_nLastLoginTimeStamp = timeStamp
		local key = s_intLastLoginTimeStamp..myInfo.data.userId
		sharedUserDefault:setIntegerForKey(key, timeStamp)
		sharedUserDefault:flush()
	end
end

function UserDefaultSetting:setAutoBuyChip(isAutoEnable)
	if isAutoEnable == self.m_isAutoBuyChipsEnable then
		return 
	end
	local key = s_intLastLoginTimeStamp..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, isAutoEnable)
	self.m_isAutoBuyChipsEnable = isAutoEnable
	sharedUserDefault:flush()
end

function UserDefaultSetting:setUserToken(token)
	if token == self.m_token then
		return 
	end
	sharedUserDefault:setStringForKey(s_userTokenKey, token)
	self.m_token = token
	sharedUserDefault:flush()
end

function UserDefaultSetting:setUserSecret(serect)
	if serect == self.m_secret then
		return 
	end
	sharedUserDefault:setStringForKey(s_userSecretKey, serect)
	self.m_secret = serect
	sharedUserDefault:flush()
end

function UserDefaultSetting:setServerIP(ip)
	if ip == self.m_ip then
		return 
	end
	sharedUserDefault:setStringForKey(s_userTokenKey, ip)
	self.m_ip = ip
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500WANLoginName(name)
	if name == self.m_500Name then
		return 
	end
	sharedUserDefault:setStringForKey(s_lastTime500Name, name)
	self.m_500Name = name
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500WANLoginPassword(password)
	if password == self.m_500Password then
		return 
	end
	sharedUserDefault:setStringForKey(s_lastTime500Password, password)
	self.m_500Password = password
	sharedUserDefault:flush()
end

function UserDefaultSetting:setDebaoLoginName(name)
	if name == self.m_debaoName then
		return 
	end
	sharedUserDefault:setStringForKey(s_lastTimeDebaoName, name)
	self.m_debaoName = name
	sharedUserDefault:flush()
end

function UserDefaultSetting:setDebaoLoginPassword(password)
	if password == self.m_debaoPassword then
		return 
	end
	sharedUserDefault:setStringForKey(s_lastTimeDebaoPassword, password)
	self.m_debaoPassword = password
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500RemeberAccountEnable(bEanble)
	if bEanble == self.m_b500RemeberAccount then
		return 
	end
	sharedUserDefault:setBoolForKey(s_bool500RememberAccount, bEanble)
	self.m_b500RemeberAccount= bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500RemeberPasswordEnable(bEanble)
	if bEanble == self.m_b500RemeberPassword then
		return 
	end
	sharedUserDefault:setBoolForKey(s_bool500RememberPassword, bEanble)
	self.m_b500RemeberPassword = bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:setAppleCheckFlag(flag)
	sharedUserDefault:setStringForKey(i_getAppleCheckFlag, flag)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getAppleCheckFlag()
	return sharedUserDefault:getIntegerForKey(i_getAppleCheckFlag)
end

function UserDefaultSetting:setSNGGameShow(Show)
	sharedUserDefault:setIntegerForKey(i_SNGGameShow, Show)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getSNGGameShow()
	return sharedUserDefault:getIntegerForKey(i_SNGGameShow)
end

function UserDefaultSetting:setRakePointGameShow(Show)
	self.m_isRakePointGameShow = Show
	sharedUserDefault:setIntegerForKey(i_RakePointGameShow, Show)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getRakePointGameShow()
	return sharedUserDefault:getIntegerForKey(i_RakePointGameShow)
end

function UserDefaultSetting:setRemeberAccountEnable(bEanble)
	if bEanble == self.m_bRemeberAccount then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolRememberAccount, bEanble)
	self.m_bRemeberAccount = bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:setRemeberPasswordEnable(bEanble)
	if bEanble == self.m_bRemeberPassword then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolRememberPassword, bEanble)
	self.m_bRemeberPassword = bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:setAutoLoginEnable(bEanble)
	if bEanble == self.m_bAutoLogin then
		return 
	end
	sharedUserDefault:setBoolForKey(s_boolAutoLogin, bEanble)
	self.m_bAutoLogin = bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500AutoLoginEnable(bEanble)
	if bEanble == self.m_b500AutoLogin then
		return 
	end
	sharedUserDefault:setBoolForKey(s_bool500AutoLogin, bEanble)
	self.m_b500AutoLogin = bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:setLoginType(loginType)
	if loginType == self.m_lastLoginType then
		return 
	end
	sharedUserDefault:setStringForKey(s_stringLastLoginType, loginType)
	self.m_lastLoginType = loginType
	sharedUserDefault:flush()
end

function UserDefaultSetting:setTencentOpenId(openId)
	if openId == self.m_tencentOpenId then
		return 
	end
	sharedUserDefault:setStringForKey(s_stringTencentOpenId, openId)
	self.m_tencentOpenId = openId
	sharedUserDefault:flush()
end

function UserDefaultSetting:setTencentToken(token)
	if token == self.m_tencentToken then
		return 
	end
	sharedUserDefault:setStringForKey(s_stringTencentToken, token)
	self.m_tencentToken = token
	sharedUserDefault:flush()
end

function UserDefaultSetting:setTencentExpires(time)
	if time == self.m_tencentExpiresin then
		return 
	end
	sharedUserDefault:setIntegerForKey(s_intTencentExpires, time)
	self.m_tencentExpiresin = time
	sharedUserDefault:flush()
end

function UserDefaultSetting:setTencentInfoTime(time)
	if time == self.m_tencentInfoTime then
		return 
	end
	sharedUserDefault:setIntegerForKey(s_intTencentInfoTime, time)
	self.m_tencentInfoTime = time
	sharedUserDefault:flush()
end

function UserDefaultSetting:setTencentToken(token)
	if token == self.m_500WANToken then
		return 
	end
	sharedUserDefault:setStringForKey(s_string500WANToken, token)
	self.m_500WANToken = token
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500WANExpires(time)
	if time == self.m_500WANExpiresin then
		return 
	end
	sharedUserDefault:setIntegerForKey(s_int500WANExpires, time)
	self.m_500WANExpiresin = time
	sharedUserDefault:flush()
end

function UserDefaultSetting:set500WANInfoTime(time)
	if time == self.m_500WANInfoTime then
		return 
	end
	sharedUserDefault:setIntegerForKey(s_int500WANInfoTime, time)
	self.m_500WANInfoTime = time
	sharedUserDefault:flush()
end

function UserDefaultSetting:setHideFullRoom(hideRoom)  
	if self.m_isHideFullRoom == hideRoom then
		return
	end
	sharedUserDefault:setBoolForKey(s_boolIsHideFullRoom, hideRoom)
	self.m_isHideFullRoom = hideRoom
	sharedUserDefault:flush()
end
	
function UserDefaultSetting:setHideEmptyRoom(hideRoom) 
	if self.m_isHideEmptyRoom == hideRoom then
		return
	end
	sharedUserDefault:setBoolForKey(s_boolIsEmptyFullRoom, hideRoom)
	self.m_isHideEmptyRoom = hideRoom
	sharedUserDefault:flush()
end

function UserDefaultSetting:setShowSixSeat(showSixSeat)	
	if self.m_isShowSixSeat == showSixSeat then
		return
	end
	sharedUserDefault:setBoolForKey(s_boolIsShowSixSeat, showSixSeat)
	self.m_isShowSixSeat = showSixSeat
	sharedUserDefault:flush()
end

function UserDefaultSetting:setShowNineSeat(showNineSeat)
	if self.m_isShowNineSeat == showNineSeat then
		return
	end
	sharedUserDefault:setBoolForKey(s_boolIsShowNineSeat, showNineSeat)
	self.m_isShowNineSeat = showNineSeat
	sharedUserDefault:flush()
end

function UserDefaultSetting:setHideSixSeat(hideSixSeat)	
	if self.m_isHideSixSeat == hideSixSeat then
		return
	end
	sharedUserDefault:setBoolForKey(s_boolIsHideSixSeat, hideSixSeat)
	self.m_isHideSixSeat = hideSixSeat
	sharedUserDefault:flush()
end

function UserDefaultSetting:setHideNineSeat(hideNineSeat)
	if self.m_isHideNineSeat == hideNineSeat then
		return
	end
	sharedUserDefault:setBoolForKey(s_boolIsHideNineSeat, hideNineSeat)
	self.m_isHideNineSeat = hideNineSeat
	sharedUserDefault:flush()
end

function UserDefaultSetting:setIsLearn(isLearn)
	if self.m_isLearn == isLearn then
		return
	end
	local key = s_boolIsLearn..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, isLearn)
	self.m_isLearn = isLearn
	sharedUserDefault:flush()
end

function UserDefaultSetting:setIsClickLoginRewardRule(isClicked)
	if self.m_bClickLoginRewardRule == isClicked then
		return
	end
	local key = s_boolClickedLoginRewardRule..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, isClicked)
	self.m_bClickLoginRewardRule = isClicked
	sharedUserDefault:flush()
end

function UserDefaultSetting:setIsClickShopScene(isClicked)
	if self.m_bClickShopScene == isClicked then
		return
	end
	local key = s_boolClickedShopScene..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, isClicked)
	self.m_bClickShopScene = isClicked
	sharedUserDefault:flush()
end

function UserDefaultSetting:setNeedShowDown(needShow)
	if self.m_bNeedShowDown == needShow then
		return
	end
	local key = s_boolNeedShowDown..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, needShow)
	self.m_bNeedShowDown = needShow
	sharedUserDefault:flush()
end

function UserDefaultSetting:setNeedWinLoseTip(needTip)
	if self.m_bNeedWinLoseTip == needTip then
		return
	end
	local key = s_boolNeedWinLoseTip..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, needTip)
	self.m_bNeedWinLoseTip = needTip
	sharedUserDefault:flush()
end

function UserDefaultSetting:getShowAddFriendsFromConcern()
	local key = s_bShowAddFriendsFromConcern..myInfo.data.userId
	self.m_bShowAddFriendsFromConcern = sharedUserDefault:getBoolForKey(key, true)
	return self.m_bShowAddFriendsFromConcern
end

function UserDefaultSetting:setShowAddFriendsFromConcern(bEnable)
	if self.m_bShowAddFriendsFromConcern == bEnable then
		return
	end
	local key = s_bShowAddFriendsFromConcern..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, bEnable)
	self.m_bShowAddFriendsFromConcern = bEnable
	sharedUserDefault:flush()
end

function UserDefaultSetting:get48HoursOver()
	local key = s_b48HoursOver..myInfo.data.userId
	self.m_b48HoursOver = sharedUserDefault:getBoolForKey(key, false)
	return self.m_b48HoursOver
end

function UserDefaultSetting:set48HoursOver(bOver)
	if self.m_b48HoursOver == bOver then
		return
	end
	local key = s_b48HoursOver..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, bOver)
	self.m_b48HoursOver = bOver
	sharedUserDefault:flush()
end

function UserDefaultSetting:setShowAdvertisement(bEanble)
	if self.m_showAdvertisement == bEanble then
		return
	end
	local key = s_showAdvertisement..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, bEanble)
	self.m_showAdvertisement = bEanble
	sharedUserDefault:flush()
end

function UserDefaultSetting:setFaceVersion(version)
	sharedUserDefault:setStringForKey(s_face_version, version)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getFaceVersion()
	return sharedUserDefault:getStringForKey(s_face_version, "")
end

function UserDefaultSetting:setSafeSetting(isNeed)
	local key = s_safe_setting..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, isNeed)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getSafeSetting()
	local key = s_safe_setting..myInfo.data.userId
	return sharedUserDefault:getBoolForKey(key, true)
end

function UserDefaultSetting:setPKMatchApplyed(applyed)
	local key = s_pk_match_applyed..myInfo.data.userId
	sharedUserDefault:setBoolForKey(key, applyed)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getPKMatchApplyed()
	local key = s_pk_match_applyed..myInfo.data.userId
	return sharedUserDefault:getBoolForKey(key, false)
end

function UserDefaultSetting:setChannelReportSwitch(reportSwitch)
	local key = s_uniconm_report_switch
	sharedUserDefault:setIntegerForKey(key, reportSwitch)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getChannelReportSwitch()
	local key = s_uniconm_report_switch
	return sharedUserDefault:getIntegerForKey(key, 0)
end

function UserDefaultSetting:setRefreshReportSwitch(refreshSwitch)
	local key = s_refresh_report_switch
	sharedUserDefault:setIntegerForKey(key, refreshSwitch)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getRefreshReportSwitch()
	local key = s_refresh_report_switch
	return sharedUserDefault:getIntegerForKey(key, 0)
end

function UserDefaultSetting:setRepeatReportFlag(repeatFlag)
	local key = s_repeat_report_flag
	sharedUserDefault:setIntegerForKey(key, repeatFlag)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getRepeatReportFlag()
	local key = s_repeat_report_flag
	return sharedUserDefault:getIntegerForKey(key, 0)
end

function UserDefaultSetting:getGameLeaveType()	
	return sharedUserDefault:getIntegerForKey(s_game_type, 0)
end

function UserDefaultSetting:setGameLeaveType(type)	
	sharedUserDefault:setIntegerForKey(s_game_type, type)
	sharedUserDefault:flush()
end

function UserDefaultSetting:setAppleRePayTime(orderId, time)
	sharedUserDefault:setIntegerForKey(orderId, time)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getApplePayTime(orderId)
	return sharedUserDefault:getIntegerForKey(orderId)
end

function UserDefaultSetting:setLLPayFlag(flag)
	sharedUserDefault:setStringForKey(s_llpay_flag, flag)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getLLPayFlag()
	return sharedUserDefault:getStringForKey(s_llpay_flag)
end

function UserDefaultSetting:setAndroidPackageDir(dir)
	sharedUserDefault:setStringForKey(s_android_package_dir, dir)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getAndroidPackageDir()
	return sharedUserDefault:getStringForKey(s_android_package_dir)
end

function UserDefaultSetting:setAndroidSdkVersion(version)
	sharedUserDefault:setIntegerForKey(s_android_sdk_version, version)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getAndroidSdkVersion()
	return sharedUserDefault:getIntegerForKey(s_android_sdk_version)
end

function UserDefaultSetting:setUnloginDebaoUname(uname)
	sharedUserDefault:setStringForKey(s_unlogin_debao_uname, uname)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getUnloginDebaoUname()
	return sharedUserDefault:getStringForKey(s_unlogin_debao_uname)
end

function UserDefaultSetting:setLastLoginName(name)
	sharedUserDefault:setStringForKey(s_lastLogin_uname, name)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getLastLoginName()
	return sharedUserDefault:getStringForKey(s_lastLogin_uname)
end

function UserDefaultSetting:setLastLoginPassword(pw)
	sharedUserDefault:setStringForKey(s_lastLogin_password, pw)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getLastPassword()
	return sharedUserDefault:getStringForKey(s_lastLogin_password)
end

function UserDefaultSetting:setUnlogin500wanUname(uname)
	sharedUserDefault:setStringForKey(s_unlogin_500wan_uname, uname)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getUnlogin500wanUname()
	return sharedUserDefault:getStringForKey(s_unlogin_500wan_uname)
end

function UserDefaultSetting:setUnregisterDebaoUname(uname)
	sharedUserDefault:setStringForKey(s_unregister_debao_uname, uname)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getUnregisterDebaoUname()
	return sharedUserDefault:getStringForKey(s_unregister_debao_uname)
end

function UserDefaultSetting:setUserPotrait(userpotrait)
	sharedUserDefault:setStringForKey(s_user_potrait, userpotrait)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getUserPotrait()
	return sharedUserDefault:getStringForKey(s_user_potrait)
end

function UserDefaultSetting:setUserSex(userpotrait)
	sharedUserDefault:setStringForKey(s_user_sex, userpotrait)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getUserSex()
	return sharedUserDefault:getStringForKey(s_user_sex)
end

function UserDefaultSetting:setUserPrivilege(privilege)
	sharedUserDefault:setIntegerForKey(i_user_privilege, privilege)
	sharedUserDefault:flush()
end

function UserDefaultSetting:getUserPrivilege()
	return sharedUserDefault:getIntegerForKey(i_user_privilege)
end

function UserDefaultSetting:setApplePayData(key1,key2,key3,key4,key5)
	if device.platform == "ios" then
		sharedUserDefault:setStringForKey(s_applePayUserId,key1 or "")
		sharedUserDefault:setStringForKey(s_applePayUserName, key2 or "")
		sharedUserDefault:setStringForKey(s_applePayEncodeJson, key3 or "")
		sharedUserDefault:setStringForKey(s_applePayOrderId, key4 or "")
		sharedUserDefault:setStringForKey(s_applePaytrans, key5 or "")

		sharedUserDefault:setIntegerForKey(s_applePayTimes,0)
		sharedUserDefault:flush()
	end
end

function UserDefaultSetting:getApplePayData()
	if device.platform == "ios" then
        local userId = sharedUserDefault:getStringForKey(s_applePayUserId)
        if userId == "" then return end
        local data = {}
        data.userId = userId
        data.userName   = sharedUserDefault:getStringForKey(s_applePayUserName)
        data.encodeJson = sharedUserDefault:getStringForKey(s_applePayEncodeJson)
        data.orderId    = sharedUserDefault:getStringForKey(s_applePayOrderId)
        data.transactionIdentifier = sharedUserDefault:getStringForKey(s_applePaytrans) 

        data.times      = sharedUserDefault:getIntegerForKey(s_applePayTimes)
        return data
    end
end

function UserDefaultSetting:setAnQuApplePayData(key1,key2,key3,key4)
	if device.platform == "ios" then
		sharedUserDefault:setStringForKey(s_anquPayUserId, key1 or "")
		sharedUserDefault:setStringForKey(s_anquPayPcorder, key2 or "")
		sharedUserDefault:setStringForKey(s_anquPayOrder, key3 or "")
		sharedUserDefault:setStringForKey(s_anquPayMoney, key4 or "")

		sharedUserDefault:getIntegerForKey(s_anquPayTimes, 0)
		sharedUserDefault:flush()
	end
end

function UserDefaultSetting:getAnQuApplePayData()
	if device.platform == "ios" then
        local userId = sharedUserDefault:getStringForKey(s_anquPayUserId)
        if userId == "" then return end
        local data = {}
        data.uid = userId
        data.cporder = sharedUserDefault:getStringForKey(s_anquPayPcorder)
        data.order = sharedUserDefault:getStringForKey(s_anquPayOrder)
        data.money = sharedUserDefault:getStringForKey(s_anquPayMoney)

        data.times = sharedUserDefault:getIntegerForKey(s_anquPayTimes)
        return data
    end
end

function UserDefaultSetting:setApplyFriend(key,value)
--s_refuse_apply:决绝好友
--s_agree_apply:同意
--s_addfriend  :删除好友
	sharedUserDefault:setIntegerForKey(key, value)
	sharedUserDefault:flush()
end
function UserDefaultSetting:getApplyFriend(key)
	return sharedUserDefault:getIntegerForKey(key)
end

function UserDefaultSetting:getPrivateRoomMsgHint()
	return sharedUserDefault:getBoolForKey(s_privateRoomMsgHint, false) 
end

function UserDefaultSetting:setPrivateRoomMsgHint(value)
	sharedUserDefault:setBoolForKey(s_privateRoomMsgHint, value)
end
----------------------------------------------------------
function UserDefaultSetting:setIsUpLoadDevice(value)
	sharedUserDefault:setBoolForKey("IsUploadDevice", value)
end
function UserDefaultSetting:getIsUpLoadDevice()
	return sharedUserDefault:getBoolForKey("IsUploadDevice") 
end

--[[
	公告弹窗日期记录,同一天只弹一次
]]
function UserDefaultSetting:setAnnouncePopupDate(value)
	sharedUserDefault:setStringForKey("AnnouncePopupDate", value)
end
function UserDefaultSetting:getAnnouncePopupDate()
	return sharedUserDefault:getStringForKey("AnnouncePopupDate") 
end

--[[
	公告阅读ID记录
]]
function UserDefaultSetting:setAnnounceIDs(value)
	sharedUserDefault:setStringForKey("AnnounceIDs", value)
end
function UserDefaultSetting:getAnnounceIDs()
	return sharedUserDefault:getStringForKey("AnnounceIDs") 
end
return UserDefaultSetting
