httpdefine = require("app.Network.Http.HttpDefine")
require("app.GUI.jni.NativeJNI")
require("app.Network.Http.URLEncoder")
local NetCallBack = require("app.Network.Http.NetCallBack")
local myInfo = require("app.Model.Login.MyInfo")
m_Session = ""
DBHttpRequest = {}

--[[发送http请求]]
function doSend(callback, tag, server, method, params)
	local url = SERVER_URL
	if m_Session~=nil and m_Session~="" then
		url = url.."?"
		url = url..PHPSESSID
		url = url.."="..m_Session
	else
		url = url
	end

	local postData = "method="..server.."/"..method
	if params~=nil then
		postData = postData..params
	end
 	
	-- dump(url)
	-- local pos = 1
	-- for i=1,string.len(tableId) do
	-- 	if string.sub(tableId,i,i)=="#" then
	-- 		pos = i
	-- 	end
	-- end
	-- local result = string.sub(tableId,1,pos-1).."%23"..string.sub(tableId,pos+1)
	-- print(result)
	local request = nil
	request = network.createHTTPRequest(callback,url,"POST")
	request:setPOSTData(postData)
	request.tag=tag
	if request then
		request:setTimeout(30)
		request:start()
	end
end

function doDownloadSend(callback, url, tag, fileName)
	local request = nil
	request = network.createHTTPRequest(callback,url,"GET")
	request.tag=tag
	request.fileName = fileName
	if request then
		request:setTimeout(30)
		request:start()
	end
end

--[[构造http参数]]
function buildParams(...)
	local arg = {...}
	local arg_elements = nil
	if type(arg[1]) == "table" then
		arg_elements = arg[1]
	else
		arg_elements = arg
	end 
	local params =""
	for index=1,#arg_elements do
		params = params.."&params[]="..URLEncoder:encodeURI(arg_elements[index])
	end
	return params
end


----------------------------------------------------------
--[[ begin: 接口实现方法]]

function DBHttpRequest:setSession(session)
	m_Session = session
	NetCallBack:setSession(session)
end

function DBHttpRequest:getLoginCtr(callback)
	doSend(callback, POST_COMMAND_GETLOGINCONTROL, "Account", "getLoginCtr") 
end

function DBHttpRequest:uploadDeviceInfo(callback,info)
	local params = buildParams(info,DBChannel)
	NetCallBack:doSend(callback, POST_COMMAND_UPLOADDEVICEINFO, "Analysis", "mobileDevicesToActivate", params) 
end
---
-- 融云服务器API - 获取token
--
-- @param callback 回调函数
-- @param userId 用户ID
-- @param name 用户名
-- @param portraitUri 头像uri
-- @return json格式 在回调里处理
--
function DBHttpRequest:getRCToken(callback,userId,name,portraitUri)
		-- NetCallBack:doSend(callback, POST_COMMAND_TOURISTTURNDEBAO, "Account", "touristTurnDebao", params) 
-- URLEncoder:encodeURI api.cn.ronghub.com  api.cn.rong.io线下
	-- if device.platform == "ios" then
		if GIsConnectRCToken then return end
		local params = {['userId'] = URLEncoder:encodeURI(userId),['name'] = URLEncoder:encodeURI(name),['portraitUri'] = URLEncoder:encodeURI(portraitUri)}
		NetCallBack:doSend(callback, POST_COMMAND_GETRCTOKEN, "", "",
		 params,
		 "https://api.cn.ronghub.com/user/getToken.json",self:createRCHTTPHeaders())
	-- end
end
-- 创建融云 http headers
function DBHttpRequest:createRCHTTPHeaders()
	local sha1 = require("app.Tools.sha1")
	local appSecret = "XPtavcIQOE6QN"
	local timestamp = os.time()
	local signStr = appSecret.."508061691"..timestamp
	local hash_as_hex   = sha1(signStr)

	local table = {["App-Key"]="8luwapkvuz8jl",
					["Nonce"]="508061691",
					["Timestamp"]=timestamp,
					["Signature"]=hash_as_hex}

	return table
end

---
-- 融云服务器API - 禁言聊天室用户
--
-- @param callback [回调]
-- @param userId [用户id]
-- @param chatroomId [聊天室id]
-- @param minute [时间,单位:分钟]
-- @return [json格式,在回调里处理,{code:xx}]
--
function DBHttpRequest:ignoreRCMembers(callback,userId,chatroomId,minute)
	if device.platform == ios then
		local params = {['userId'] = URLEncoder:encodeURI(userId),['chatroomId'] = URLEncoder:encodeURI(chatroomId),['minute'] = URLEncoder:encodeURI(minute)}
		NetCallBack:doSend(callback, POST_COMMAND_IGNORERCMEMBERS, "", "",
		 params,
		 "https://api.cn.ronghub.com/chatroom/user/gag/add.json",self:createRCHTTPHeaders())
	end
end
---
-- [融云服务器API - 解除禁言聊天室用户]
--
-- @param callback [回调]
-- @param userId [用户id]
-- @param chatroomId [聊天室id]
-- @return [json格式,在回调里处理]
--
function DBHttpRequest:rollbackRCMembers(callback,userId,chatroomId)
	if device.platform == ios then
		local params = {['userId'] = URLEncoder:encodeURI(userId),['chatroomId'] = URLEncoder:encodeURI(chatroomId)}
		NetCallBack:doSend(callback, POST_COMMAND_ROLLBACKRCMEMBERS, "", "",
		 params,
		 "https://api.cn.ronghub.com/chatroom/user/gag/rollback.json",self:createRCHTTPHeaders())
	end
end

function DBHttpRequest:esunLogin(callback,name,password,type,ip,version)
	local sign = ""..name..password..ip..type..version.."j%7lu9*#g5@z"
	local params = buildParams(name,password,ip,type,version,sign,NativeJNI:getAndroidMac())
	doSend(callback, POST_COMMAND_ESUNLOGIN, "Account", "loginForMobile", params) 
end
--[[
 * 腾讯联运手机版用户登录(测试)
 *
 * @param string $token
 * @param string $secret
 *
 * @return array|integer   成功时返回用户信息数组，失败时返回错误码
]]

function DBHttpRequest:login(callback,name,password,version,isTestEnvironment,merge)
	if TRUNK_VERSION == DEBAO_TRUNK then
		local params = buildParams(username,password)
		doSend(callback, POST_COMMAND_LOGIN, "Account", "login", params) 
	else
		local params = buildParams(username,password,merge,"0",version)
		doSend(callback, POST_COMMAND_LOGIN, "Account", isTestEnvironment and "login" or "loginpro", params)
	end
end

function DBHttpRequest:debaoThreePlatFormLogin(callback,uid,timeStamp,ip,sign,loginType)
	local params = buildParams(uid,timeStamp,ip,loginType,currentVersion(),sign,NativeJNI:getAndroidMac())
	doSend(callback, POST_COMMAND_LOGIN, "Account", "loginForMobile", params) 
end


function DBHttpRequest:DBHttpLogin(callback,username,password,ip,loginType,version,macAddr,nickname,sdkSign)
	local params = buildParams(username,password,ip,loginType,version,"",macAddr,"","",nickname)
	doSend(callback, POST_COMMAND_LOGIN_FOR_MOBILE_NEW, "Account", "debaoLogin", params) 

	-- local url = SERVER_URL.."?method=Account/debaoLogin"
	-- url = url..params
	-- local request = nil
	-- request = network.createHTTPRequest(callback,url,"POST")
	-- request.tag=POST_COMMAND_LOGIN_FOR_MOBILE_NEW
	-- if request then
	-- 	request:setTimeout(30)
	-- 	request:start()
	-- end
end

function DBHttpRequest:debaoLoginForVersionControl(callback,username,password,ip,loginType,version,sign,macAddr,nickname,sdkSign)
	if loginType == "500WAN" or loginType=="DEBAO" then
		password = crypto.md5(password)
	end

	if logintype == "PPS" or logintype == "91" or logintype == "BAIDU" then
		sign = sdkSign
	else
		local tmpStr = username .. password ..ip .. loginType .. version .."j%7lu9*#g5@z" 
		sign = crypto.md5(tmpStr)
	end
	if not GameSceneManager.m_pLoadingView then
		-- GameSceneManager.m_pLoadingView = require("app.GUI.BuyLoadingScene"):new()
		GameSceneManager.m_pLoadingView = cc.ui.UIImage.new("statusbar.png")
		GameSceneManager.m_pLoadingView:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
		-- GameSceneManager.m_pLoadingView:setVisible(false)
    	GameSceneManager:getCurScene():addChild(GameSceneManager.m_pLoadingView, 9,999)
    	local action = cc.RotateBy:create(1, 360)
    	local forever = cc.RepeatForever:create(action)
    	GameSceneManager.m_pLoadingView:runAction(forever)
    	CMDelay(GameSceneManager.m_pLoadingView,2,function () if GameSceneManager.m_pLoadingView then GameSceneManager.m_pLoadingView:setVisible(true) GameSceneManager.m_pLoadingView = nil end end)
    end
	local params = buildParams(username,password,ip,loginType,version,sign or "",macAddr,"","",nickname)
	-- dump(params)
	doSend(callback, POST_COMMAND_LOGIN_FOR_MOBILE_NEW, "Account", "debaoLogin", params) 
end

function DBHttpRequest:touristTurnDebao(callback,name,password,mac,sex,email)
	local params = buildParams(name,password,sex,email,mac)
	-- doSend(callback, POST_COMMAND_TOURISTTURNDEBAO, "Account", "touristTurnDebao", params) 
	NetCallBack:doSend(callback, POST_COMMAND_TOURISTTURNDEBAO, "Account", "touristTurnDebao", params) 
end

function DBHttpRequest:updatePassword(callback,oldPassword,newPassword)
	local params = buildParams(oldPassword,newPassword)
	--doSend(callback, POST_UPDATE_PASSWORD, "Account", "updatePassword", params)
	NetCallBack:doSend(callback, POST_UPDATE_PASSWORD, "Account", "updatePassword", params) 
end

--[[ 当断线时，请求服务器更换serverid
 int serverId : 为不可用的serverId]]
function DBHttpRequest:getServerId(callback,serverId)
	local params = buildParams(serverId)
	doSend(callback, POST_COMMAND_GETSERVERID, "Account", "getServerId", params) 
end

function DBHttpRequest:getServerPort(callback,port,version)
	local params = buildParams(port,version)
	doSend(callback, POST_COMMAND_GETSERVERPORT, "Account", "getServerPort", params) 
end

--[[ * 用户在线人数
 *
 * @return integer 成功时 返回非负整数，失败时返回负数（错误码）]]
function DBHttpRequest:getUserOnLineCount(callback)
	doSend(callback, POST_COMMAND_GETUSERONLINECOUNT, "Lobby", "getUserOnLineCount")
end

function DBHttpRequest:getLotteryChances(callback,userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_GETLOTTERYCHANCES, "Activity", "getLoginLotteryInfo", params) 
end

--[[获取 vip 信息]]
function DBHttpRequest:getVipInfo(callback,uidList,isOldCallback)
	if isOldCallback==nil or isOldCallback==false then
		isOldCallback = false
	else 
		isOldCallback = true
	end
	local params = buildParams(uidList)
	if isOldCallback==true then
		doSend(callback, POST_COMMAND_GET_VIP_INFO, "User", "getMultUserVip", params) 
	else
		NetCallBack:doSend(callback, POST_COMMAND_GET_VIP_INFO, "User", "getMultUserVip", params) 
	end
end

function DBHttpRequest:loginLottery(callback,userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_LOGINLOTTERY, "Activity", "loginLottery", params) 
end

function DBHttpRequest:loginLotteryNew(callback,userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_LOGINLOTTERYNEW, "Activity", "loginLotteryNew", params) 
end

--[[
	获取日常任务列表
]]
function DBHttpRequest:taskListAll(callback)
	NetCallBack:doSend(callback, POST_COMMAND_taskListAll, "Activity", "taskListAll") 
end
--[[
	领取任务奖励
]]
function DBHttpRequest:taskFinishAndReward(callback,activityId,jsonArgs)
	local params = buildParams(activityId,jsonArgs)
	if activityId == "206" then
		NetCallBack:doSend(callback, POST_COMMAND_JoinActivity, "Activity", "joinActivity", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_taskFinishAndReward, "Activity", "taskFinishAndReward",params) 
	end
end
--[[ 
 * 获取公告(列表)
 *
 * @return array|integer
 ]]
function DBHttpRequest:getAnnounceList(callback)
	doSend(callback, POST_COMMAND_GETANNOUNCELIST, "Admin", "getAnnounceList")
end

--[[
 * 用户每天登录游戏领奖
 *
 * @return array|integer 成功时返回领奖信息数组，失败时返回错误码
 *
 * 附：
 * 	-403   => 未登录
 *	-14024 => 配置不存在
 *	-14025 => 服务异常
 *	-14026 => 活动id不存在
 *	-14027 => 登录信息错误
 *	-14028 => 登录奖励错误
 *	-14029 => 登录奖励资格错误
 *	-14030 => 登录奖励已领取
 *	-14031 => 创建订单失败
 *	-14032 => 兑奖失败
 *	-14033 => 当天再次登录，此返回无需再次兑换登录奖励
]]
function DBHttpRequest:fetchLoginReward(callback)
	doSend(callback, POST_COMMAND_FETCHLOGINREWARD, "Admin", "fetchLoginReward")
end

--[[
 * 获取玩家总手数(新手教程使用)
 *
 * @param int $uid
 * @return array
]]
function DBHttpRequest:getHandsNum(callback,userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_GETHANDSNUM, "Analysis", "getHandsNum", params) 
end

--[[获取我的当天的牌局数]]
function DBHttpRequest:getMyHandsSum(callback)
	doSend(callback, POST_COMMAND_GETHANDSNUM, "Activity", "getHandsSumNew")
end

--[[获取手牌奖励信息配置]]
function DBHttpRequest:getHandConfig(callback)
	doSend(callback, POST_COMMAND_GETHANDCONFIG, "Activity", "getHandsConfigNew")
end

--[[签到]]
function DBHttpRequest:getLoginSignInfo(callback)
	--doSend(callback, POST_COMMAND_getLoginSignInfo, "Activity", "getLoginSignInfo")
	NetCallBack:doSend(callback, POST_COMMAND_getLoginSignInfo, "Activity", "getLoginSignInfo")
end

--[[标记看过新手教程]]
function DBHttpRequest:freshInterfaceGuide(callback)
	doSend(callback, POST_COMMAND_freshInterfaceGuide, "Activity", "freshInterfaceGuide")
end

function DBHttpRequest:loginSign(callback)
	--doSend(callback, POST_COMMAND_loginSign, "Activity", "loginSign")
	NetCallBack:doSend(callback, POST_COMMAND_loginSign, "Activity", "loginSign")
end

--[[ * 获取用户账户信息(金钱余额)
 * @param $userid
 * @return array|integer 成功时返回用户账户信息数组，失败时返回错误码]]
function DBHttpRequest:getAccountInfo(callback,isNetCallBack)
	if isNetCallBack then
		NetCallBack:doSend(callback, POST_COMMAND_GETACCOUNTINFO, "Account", "getAccountInfo")
	else
		doSend(callback, POST_COMMAND_GETACCOUNTINFO, "Account", "getAccountInfo")
	end
end

 --[[* 获取用户所有正在进行的牌桌和玩家已报名赛事查询(手机专用)
 *
 * @return array|integer 成功时返回玩家正在进行的牌桌和赛事玩家列表数组，失败时返回负数（错误码）
 *
 * 附：
 * 	-403 => 未登录]]
function DBHttpRequest:getUserTableListMobile(callback)
	doSend(callback, POST_COMMAND_GETUSRETABLELISTMOBILE, "Lobby", "getUserTableListMobile")
end

--[[ * 现金桌快速入桌入座
 * 	根据用户的账户余额情况，帮玩家选取一个现金桌及座位号
 *
 * @return array|integer
 *
 * 附：
 * 	-403 => 未登录]]
function DBHttpRequest:quickStart(callback)
	doSend(callback, POST_COMMAND_QUICKSTART, "Lobby", "quickStart")
end

function DBHttpRequest:quickStartNew(callback)
	doSend(callback, POST_COMMAND_QUICKSTART_NEW, "Lobby", "quickStartNew")
end

--[[获取消息中心/消息数量]]
function DBHttpRequest:GetAllNoticesInfo(callback,type,isOldCallback)
	if isOldCallback==nil or isOldCallback==false then
		isOldCallback = false
	else 
		isOldCallback = true
	end
	local params = buildParams(type)
	if TRUNK_VERSION == DEBAO_TRUNK then
		if isOldCallback == true then
			doSend(callback, POST_COMMAND_GETALLNOTICEINFO, "Notice", "getAllNotice", params) 
		else
			NetCallBack:doSend(callback, POST_COMMAND_GETALLNOTICEINFO, "Notice", "getAllNotice", params)
		end 
	else
		if isOldCallback == true then
			doSend(callback, POST_COMMAND_GETALLNOTICEINFO, "Lobby", "getAllNotice", params) 
		else
			NetCallBack:doSend(callback, POST_COMMAND_GETALLNOTICEINFO, "Lobby", "getAllNotice", params) 
		end
	end
end

--[[获取未读公告/消息的数量]]
function DBHttpRequest:getNoReadNotice(callback)
	if TRUNK_VERSION == DEBAO_TRUNK then
		doSend(callback, POST_COMMAND_GETNOREADEDNOTICENUM, "Notice", "getNoReadNotice") 
	else
		doSend(callback, POST_COMMAND_GETNOREADEDNOTICENUM, "Lobby", "getNoReadNotice") 
	end
end

function DBHttpRequest:setApplePushToken(callback, userId, pushToken)
	local params = buildParams(userId, pushToken)
	doSend(callback, POST_COMMAND_SetApplePushToken, "Analysis", "setApplePushToken", params)
end

--[[读取未读取活动数量]]
function DBHttpRequest:getNoReadActivity(callback)
	if TRUNK_VERSION == DEBAO_TRUNK then
		doSend(callback, POST_COMMAND_GETACTIVITYNOTREADNUM, "Activity", "getActivityNotRead") 
	else
		doSend(callback, POST_COMMAND_GETACTIVITYNOTREADNUM, "Lobby", "getActivityNotRead") 
	end
end

function DBHttpRequest:getIsNewYear(callback)
	doSend(callback, POST_COMMAND_ISNEWYEAR, "Activity", "isNewYearTimes")
end

--[[读取是否有锦标赛推广]]
function DBHttpRequest:getMatchAdCtr(callback)
	doSend(callback, POST_COMMAND_GETMATCHADCTR, "Lobby", "getMatchAdCtr")
end

--[[
 * 现金桌买入
 *
 * @param string $tableId 牌桌id
 * @param float  $chips   筹码数
 *
 * @return integer        成功时返回1
 *
 * 附：
 * 	1    => 成功
 * 	-403 => 未登录
 * 	-500 => 系统异常
 * 	-501 => 系统异常
 * 	-1   => 玩家不在该桌上
 * 	-2   => 扣款错误
 * 	-3   => 小于最小兑换筹码
 * 	-4   => 筹码数量格式不正确
 * 	-5   => 筹码数不能为0
 * 	-10000 => 系统异常
 * 	-12016 => 用户不存在
 * 	-13001 => 用户余额不足
 * 	-13004 => 用户状态异常
 * 	-13006 => 账户未激活
 * 	-13007 => 账户已锁定
 ]]
function DBHttpRequest:buyIn(callback, tableId, chips)
	local params = buildParams(tableId, chips)
	doSend(callback, POST_COMMAND_BUYIN, "Lobby", "buyIn", params)
end

--[[
* 现金桌再次买筹码
 *
 * @param string $tableId 牌桌id
 * @param float  $chips   筹码数
 *
 * @return integer        成功时返回1
 *
 * 附：
 * 	1    => 成功
 * 	-403 => 未登录
 * 	-500 => 系统异常
 * 	-501 => 系统异常
 * 	-1   => 玩家不在该桌上
 * 	-2   => 扣款错误
 * 	-3   => 小于最小兑换筹码
 * 	-4   => 筹码数量格式不正确
 * 	-5   => 筹码数不能为0
 * 	-10000 => 系统异常
 * 	-12016 => 用户不存在
 * 	-13001 => 用户余额不足
 * 	-13004 => 用户状态异常
 * 	-13006 => 账户未激活
 * 	-13007 => 账户已锁定
]]
function DBHttpRequest:reBuy(callback, tableId, chips)
	local params = buildParams(tableId, chips)
	doSend(callback, POST_COMMAND_REBUY, "Lobby", "reBuy", params)
end

--[[
 * 领取新手破产保护奖励
 *
 * @return array|integer 成功时返回领取到的奖励信息，失败时返回错误码
 *
 * 附：
 * 	-1 => 用户不是新手（注册时间早于配置时间）
 * 	-2 => 用户余额大于破产限制金额
 * 	-3 => 已经领取3次破产保护
 * 	-4 => 申请资格失败
]]
function DBHttpRequest:fetchRookieProtection(callback)
	doSend(callback, POST_COMMAND_FETCHROOKIEPROTECTION, "Admin", "fetchRookieProtection")
end

function DBHttpRequest:getRookieProtectionConfig(callback)
	doSend(callback, POST_COM_GETROOKIEPROTECTIONCONFIG, "Admin", "getRookieProtectionConfig")
end

--[[
 * 获取QQ用户的昵称和图像信息
 *
 * @param string $uids 玩家ID列表，都好分隔
 * @return array(玩家ID=>array(昵称,头像))
]]
function DBHttpRequest:getQQUserInfo(callback, userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_GETQQUSERINFO, "Account", "getQQUserInfo", params)
end

--[[
 * 取得玩家赢利排名
 * @param int $id_site 金币场，银币场(1：金币场；2：银币场)
]]
function DBHttpRequest:getUserProfitRanking(callback, userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_GETUSERPROFITRANKING, "Analysis", "getUserProfitRanking", params)
end

function DBHttpRequest:updateUserPortrait(callback, portrait)
	local params = buildParams(portrait)
	doSend(callback, POST_COMMAND_UPDATEUSERPORTRAIT, "Account", "updateUserPortrait", params)
end

--[[
 * 单个玩家数据分析（用户手机客户端）
 *
 * @param string $userId 用户id
 * @param string $version 客户端版本
 * @param string $from 接口调用位置 PCENTER 个人中心 TABLE 桌子上,默认PCENTER
 * @return array
]]
function DBHttpRequest:hudForMobile(callback, userId, version, from, refresh)
	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(userId, currentVersion(), from)
		--doSend(callback, POST_COMMAND_HUDFORMOBILE, "Analysis", "hudForMobile", params)
		NetCallBack:doSend(callback, POST_COMMAND_HUDFORMOBILE, "Analysis", "hudForMobile", params)
	else
		local params = buildParams(userId, refresh, currentVersion())
		--doSend(callback, POST_COMMAND_HUDFORMOBILE, "Analysis", "hudForMobile", params)
		NetCallBack:doSend(callback, POST_COMMAND_HUDFORMOBILE, "Analysis", "hudForMobile", params)
	end
end

--[[
 * 添加关注
 *
 * @param string $dstUserId   目标用户id
 * @param string $dstUserName 目标用户名
 *
 * @return boolean|integer    成功时返回true
 *
 * 附:
 * 	(bool) true  => 添加关注成功
 * 	(bool) false => 添加关注失败
 * 	(integer)    => 接口失败
]]
function DBHttpRequest:addConcern(callback, dstUserId, dstUserName)
	local params = buildParams(dstUserId, dstUserName)
	doSend(callback, POST_COMMAND_ADDCONCERN, "Sns", "addConcern", params)
end

--[[
* 申请好友（申请后，系统会自动发送一条添加好友的私信给对方）
 *
 * @param string $dstUserId   对方用户id
 * @param string $dstUserName 对方用户名
 *
 * @return integer            成功时返回 1, 失败时返回其它值（错误码）
 *
 * 附:
 * 	1    => 成功。申请好友成功，且发送私信成功
 * 	-1   => 失败。申请好友成功，但发送私信失败
 * 	-2   => 失败。申请好友成功，但发送私信接口错误
 * 	-3   => 失败。申请好友失败
 * 	-4   => 失败。申请好友接口错误
 * 	-5   => 失败。已经是好友了。
 * 	-10  => 失败。频次限制：100次/小时
 * 	-11  => 失败。频次限制：向同一个用户，3次/小时
 * 	-403 => 失败。未登录
]]
function DBHttpRequest:applyFriend(callback, dstUserId, dstUserName)
	if isOldCallback==nil or isOldCallback==false then
		isOldCallback = false
	else 
		isOldCallback = true
	end
	local params = buildParams(dstUserId, dstUserName)
	if isOldCallback==true then
		doSend(callback, POST_COMMAND_APPLYFRIEND, "Sns", "applyFriend", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_APPLYFRIEND, "Sns", "applyFriend", params)
	end
end

--[[
 * 取消关注
 *
 * @param string $dstUserId   目标用户id
 * @param string $dstUserName 目标用户名
 *
 * @return boolean|integer
 *
 * 附:
 * 	(bool) true  => 取消关注成功
 * 	(bool) false => 取消关注失败
 * 	(integer)    => 接口失败
]]
function DBHttpRequest:removeFriend(callback, dstUserId, dstUserName, isOldCallback)
	if isOldCallback==nil or isOldCallback==false then
		isOldCallback = false
	else 
		isOldCallback = true
	end
	local params = buildParams(dstUserId, dstUserName)
	if isOldCallback==true then
		doSend(callback, POST_COMMAND_REMOVEFRIEND, "Sns", "removeFriend", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_REMOVEFRIEND, "Sns", "removeFriend", params)
	end
end

function DBHttpRequest:addFriend(callback, dstUserId, dstUserName, messageId)
	local params = buildParams(dstUserId, dstUserName, messageId)
	--doSend(callback, POST_COMMAND_ADDFRIEND, "Sns", "addFriend", params)
	NetCallBack:doSend(callback, POST_COMMAND_ADDFRIEND, "Sns", "addFriend", params)
end

function DBHttpRequest:refuseFriend(callback, dstUserId, dstUserName, messageId)
	local params = buildParams(dstUserId, dstUserName, messageId)
	--doSend(callback, POST_COMMAND_REFUSEFRIEND, "Sns", "refuseFriend", params)
	NetCallBack:doSend(callback, POST_COMMAND_REFUSEFRIEND, "Sns", "refuseFriend", params)
end

function DBHttpRequest:sendFriendMsg(callback, dstUserId, dstUserName, content)
	local params = buildParams(dstUserId, dstUserName, content)
	--doSend(callback, POST_COMMAND_SENDPRIVATEMESSAGE, "Sns", "sendPrivateMessage", params)
	NetCallBack:doSend(callback, POST_COMMAND_SENDPRIVATEMESSAGE, "Sns", "sendPrivateMessage", params)
end

function DBHttpRequest:removeConcern(callback, dstUserId, dstUserName)
	local params = buildParams(dstUserId, dstUserName)
	doSend(callback, POST_COMMAND_REMOVECONCERN, "Sns", "removeConcern", params)
end

--[[获取我的好友列表（包括牌桌、头像、等级等信息）]]
function DBHttpRequest:getFriendsList(callback, offset, limit)
	local params = buildParams(offset, limit)
	doSend(callback, POST_COMMAND_GETFRIENDSLIST, "Sns", "getFriendsList", params)
end

function DBHttpRequest:getFriendsListInfo(callback, offset, limit)
	local params = buildParams(offset, limit)
	--doSend(callback, POST_COMMAND_GETFRIENDSLISTINFO, "Sns", "getFriendsListInfo", params)
	NetCallBack:doSend(callback, POST_COMMAND_GETFRIENDSLISTINFO, "Sns", "getFriendsListInfo", params)
end

--[[
 *  获取好友数量
 *
 *  @param target <#target description#>
 *
 *  @return <#return value description#>
]]
function DBHttpRequest:getFriendsNum(callback)
	--doSend(callback, POST_COMMAND_GETFRIENDSNUMS, "Sns", "getFriendsNums")
	NetCallBack:doSend(callback, POST_COMMAND_GETFRIENDSNUMS, "Sns", "getFriendsNums")
end

--[[获取我的关注列表（包括牌桌、头像、等级等信息）（不包括已经是好友的玩家）]]
function DBHttpRequest:getConcernListInfo(callback, offset, limit)
	local params = buildParams(offset, limit)
	doSend(callback, POST_COMMAND_GETCONCERNLISTINFO, "Sns", "getConcernListInfo", params)
end

--[[
 *获取普通场盈利排行
 * 排行榜金币接口
 * @param int $id_site 1:金币场；2：银币场
 * @param string $type 盈利：win 亏损：lost
 * @param int $times times为查询的长度，0：周 1：月 2：总
 * @param int $friends 0:所有人；1：好友
 * @param int $p_num 返回数据数目
 * @return number|unknown
]]
function DBHttpRequest:getProfitRankList(callback, id_site, type, times, friends, p_num,offset)

	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(id_site, type, times,friends,p_num,currentVersion(),offset)
		--doSend(callback, POST_COMMAND_PROFITRANKLISTINFO, "Analysis", "getleaderBoardByGold", params)
		NetCallBack:doSend(callback, POST_COMMAND_PROFITRANKLISTINFO, "Analysis", "getleaderBoardByGold", params)
	else
		local params = buildParams(id_site, type, times,friends,p_num,offset)
		--doSend(callback, POST_COMMAND_PROFITRANKLIST, "Analysis", "getleaderBoardByGold", params)
		NetCallBack:doSend(callback, POST_COMMAND_PROFITRANKLIST, "Analysis", "getleaderBoardByGold", params)
	end
end

--[[ 
 * 排行榜积分接口
 * @param int $limit 返回数据数目
 * @param int $times times为查询的长度，0：周 1：月 2：总
 * @param int $friends 0:所有人；1：好友
 * @return number|unknown
 ]]
function DBHttpRequest:getChampionRankList(callback, limit, times, friends,offset)
	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(limit, times, friends, currentVersion(),offset)
		--doSend(callback, POST_COMMAND_POINTRANKLISTINFO, "Analysis", "getleaderBoardByPoints", params)
		NetCallBack:doSend(callback, POST_COMMAND_POINTRANKLISTINFO, "Analysis", "getleaderBoardByPoints", params)
	else
		local params = buildParams(limit, times, friends,offset)
		--doSend(callback, POST_COMMAND_CHAMPIONRANKLIST, "Analysis", "getleaderBoardByPoints", params)
		NetCallBack:doSend(callback, POST_COMMAND_CHAMPIONRANKLIST, "Analysis", "getleaderBoardByPoints", params)
	end
end

function DBHttpRequest:getleaderBoardByLevel(callback, offset, limit)
	local params = buildParams(limit, offset, currentVersion())
	--doSend(callback, POST_COMMAND_BALANCERANKLISTINFO, "Analysis", "getleaderBoardByLevel", params)
	NetCallBack:doSend(callback, POST_COMMAND_BALANCERANKLISTINFO, "Analysis", "getleaderBoardByLevel", params)
end

function DBHttpRequest:getRankListInfo(callback, _type,offset,limit)
	--if TRUNK_VERSION==DEBAO_TRUNK then
		if _type=="LEVEL" then
			DBHttpRequest:getleaderBoardByLevel(callback,offset or 0,limit or 20)
		elseif _type=="PROFIT" then
			DBHttpRequest:getProfitRankList(callback,1,"win",0,0,offset or 0,limit or 20)
		elseif _type=="POINT" then
			DBHttpRequest:getChampionRankList(callback,offset or 20,0,0,limit or 20)
		end
	-- else
	-- 	local m_tag = nil
	-- 	if _type=="LEVEL" then
	-- 		m_tag = POST_COMMAND_LEVELRANKLISTINFO
	-- 	elseif _type=="BALANCE" then
	-- 		m_tag = POST_COMMAND_BALANCERANKLISTINFO
	-- 	elseif _type=="PROFIT" then
	-- 		m_tag = POST_COMMAND_PROFITRANKLISTINFO
	-- 	elseif _type=="POINT" then
	-- 		m_tag = POST_COMMAND_POINTRANKLISTINFO
	-- 	end
	-- 	--doSend(callback, m_tag, "Analysis", "getRankListInfo")
	-- 	NetCallBack:doSend(callback, m_tag, "Analysis", "getRankListInfo")
	-- end
end

function DBHttpRequest:getTotalBalanceBoard(callback, pay_type, limit, sort_type)
	doSend(callback, POST_COMMAND_TOTALBALANCEBOARD, "Analysis", "getTotalBalanceBoard")
end

--[[
 * 获取我的同桌列表（包括牌桌、头像、等级等信息）
 *
 * @param integer $offset 偏移
 * @param integer $limit  数量
 *
 * @return array|integer
]]
function DBHttpRequest:getUserCompetitorListInfo(callback, offset, limit)
	local params = buildParams(offset, limit)
	doSend(callback, POST_COMMAND_GETUSERCOMPETITORLISTINFO, "Sns", "getUserCompetitorListInfo", params)
end

--[[
 * 完成新手向导领奖
 *
 * @return array|integer 成功时返回奖励信息数组
 *
 * 附：
 * 	-1   => 创建资格失败（已经领取过）
 * 	-2   => 领取奖励失败
 * 	-3   => 创建资格接口失败
 * 	-403 => 未登录
]]
function DBHttpRequest:FreshGuide(callback)
	doSend(callback, POST_COMMAND_FRESHGUIDE, "Activity", "freshGuide")
end

 --[[
 * 获取用户所有正在进行的牌桌
 *
 * @return array|integer 成功时返回玩家正在进行的牌桌，失败时返回负数（错误码）
 *
 * 附：
 * 	-403 => 未登录
 ]]
function DBHttpRequest:getUserTableList(callback)
	doSend(callback, POST_COMMAND_GETUSERTABLELIST, "Lobby", "getUserTableList")
end

function DBHttpRequest:joinActivity(callback, activityId, jsonArgs)
	local params = buildParams(activityId, jsonArgs)
	doSend(callback, POST_COMMAND_JoinActivity, "Activity", "joinActivity", params)
end

function DBHttpRequest:finishFreshGuide(callback, userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_finishFreshGuide, "Activity", "finishFreshGuide", params)
end

function DBHttpRequest:getUserUseFuncInfo(callback, funcId)
	local params = buildParams(funcId)
	doSend(callback, POST_COMMAND_getUserUseFuncInfo, "Activity", "getUserUseFuncInfo", params)
end

function DBHttpRequest:getActivityData(callback, activityId, jsonArgs, isOldCallback)
	local params = buildParams(activityId, jsonArgs)
	if isOldCallback then
		doSend(callback, POST_COMMAND_GetActivityData, "Activity", "getActivityData", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GetActivityData, "Activity", "getActivityData",params) 
	end
end

--[[ * 现金赛牌桌列表
 * (注：目前排序还没有实现)
 *
 * @param string $tableType   牌桌类型
 * 		"GOLD":   金币场
 * 		"SILVER": 银币场
 *
 * @param string $level       牌桌级别
 * 		"":        全部
 * 		"PRIMARY": 初级
 * 		"MIDDLE":  中级
 * 		"HIGH":    高级
 * 		"SUPER":   大师
 *
 * @param string $tableStatus 牌桌状态 (暂未实现该参数)
 * @param string $sortBy      排序字段名 (暂未实现该参数)
 * @param string $sortType    排序类型 (暂未实现该参数)
 *
 * @return array|integer      成功时返回现金赛牌桌列表数组，失败时返回错误码]]
function DBHttpRequest:getImmTableList(callback,tableType,level,tableStatus,sortBy,sortType,returnType,playType,tableOwner)
	local params = buildParams(tableType,level,tableStatus,sortBy,sortType,returnType,playType,tableOwner)
	doSend(callback, POST_COMMAND_GETIMMTABLELIST, "Lobby", "getImmTableList", params)
end

function DBHttpRequest:getDiyTableList(callback,pay_type,level,tableType)
	local params = buildParams(pay_type,level,tableType)
	doSend(callback, POST_COMMAND_GETDIYTABLELIST, "Lobby", "getDiyTableList", params)
end

--[[
 * 获取锦标赛列表
 * (注：目前排序还没有实现)
 *
 * @param string $matchType   赛事类型
 * 		"SITANDGO": 坐满即玩
 * 		"TOURNEY":  定时开始
 *
 * @param string $level       赛事级别
 * @param string $matchStatus 赛事状态
 * @param string $sortBy      排序字段名
 * @param string $sortType    排序类型(ASC / DESC)
 *
 * @return array|integer      成功时返回赛事列表数组，失败时返回错误码
]]
function DBHttpRequest:getMacthList(callback,matchType,level,matchStatus,sortBy,sortType)
	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(matchType,level,matchStatus,sortBy,sortType,false,currentVersion())
		doSend(callback, POST_COMMAND_GETMATCHLIST, "Lobby", "getMatchList", params)
	else
		local params = buildParams(matchType,level,matchStatus,sortBy,sortType)
		doSend(callback, POST_COMMAND_GETMATCHLIST, "Lobby", "getMatchList", params)
	end
end

--[[
 * 赛事玩家列表查询
 *
 * @param string $matchId 赛事id
 *
 * @return array|integer  成功时返回赛事玩家列表数组，失败时返回错误码
]]
function DBHttpRequest:getMatchUserList(callback, matchId)
	local params = buildParams(matchId)
	doSend(callback, POST_COMMAND_GETMATCHUSERLIST, "Lobby", "getMatchUserList", params)
end

--[[
 * 获取固定人数下的奖池分配（返回具体奖金）
 *
 * @param string $matchId
 * @param string $bonusName 奖池分配名
 * @param string $usersNum  玩家人数
 *
 * @return array|integer 成功时返回奖池分配信息，失败时返回错误码
 *
 * 附：
 * 	-404 => 未找到
]]
function DBHttpRequest:getPrizeInfo(callback, matchId, bonusName, usersNum)
	local params = buildParams(matchId, bonusName, usersNum)
	doSend(callback, POST_COMMAND_GETPRIZEINFO, "Admin", "getPrizeInfo", params)
end

--[[
 * 根据物品分配名取物品分配信息
 *
 * @param string $gainName 物品分配名
 *
 * @return array|integer 成功时返回物品分配信息，失败时返回错误码
 *
 * 附：
 * 	-404 => 未找到
]]
function DBHttpRequest:getGainInfoByName(callback, gainName)
	local params = buildParams(gainName)
	doSend(callback, POST_COMMAND_GETGAININFOBYNAME, "Admin", "getGainInfoByName", params)
end

function DBHttpRequest:getMatchListByGroup(callback,matchType,level,matchStatus,sortBy,sortType,returnType)
	local params = buildParams(matchType,level,matchStatus,sortBy,sortType,returnType)
	doSend(callback, POST_COMMAND_CHAMPIONSHIPLIST, "Lobby", "getMatchListByGroup", params)
end

--[[
 * 报名参加锦标赛
 * 报名需要先登录 （对于pc客户端，需要在请求url加上 PHPSESSID）
 *
 * @param string $matchId 赛事id
 * @param boolen $ticket 是否使用门票报名
 * @param bool $with_msg 是否返回异常描述信息
 *
 * @return integer        成功时返回0
 *
 * 附：
 * 	0  => 成功
 * 	-1 => 赛事不存在
 * 	-2 => 无参赛资格
 * 	-3 => 用户已经报名
 * 	-4 => 报名截至
 * 	-5 => 已经满员
 * 	-6 => 赛事目前禁止报名
 *  -11 => 渠道限制
 *  -12 => 注册时间限制
 *  -13 => VIP等级限制
 *  -14 => 相同注册ip人数限制
 *  -15 => 相同参赛ip人数限制
 * 	-403 => 未登录
 * 	-500 => 系统异常
 * 	-501 => 系统异常
 * 	-10000 => 系统异常
 * 	-12016 => 用户不存在
 * 	-13001 => 用户余额不足
 * 	-13004 => 用户状态异常
 * 	-13006 => 账户未激活
 * 	-13007 => 账户已锁定
]]
function DBHttpRequest:applyMatch(callback,matchId,ticket,withMsg)
	local params = nil
	if TRUNK_VERSION==DEBAO_TRUNK then
		local paramVec = {}
		paramVec[1] = matchId
		if ticket then
			paramVec[#paramVec+1] = "1"
		end
		if withMsg then
			paramVec[#paramVec+1] = "1"
		end
		params = buildParams(paramVec)
		doSend(callback, POST_COMMAND_APPLYMATCH, "Lobby", "applyMatch", params)
	else
		params = buildParams(matchId)
		doSend(callback, POST_COMMAND_APPLYMATCH, "Lobby", "applyMatch", params)
	end
end

function DBHttpRequest:getActivityList(callback, macAddress)
	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(macAddress)
		doSend(callback, POST_COMMAND_NEWGETACTIVITYLIST, "Activity", "getNewActivityList", params)
	else
		doSend(callback, POST_COMMAND_NEWGETACTIVITYLIST, "Lobby", "getNewActivityList")
	end
end

function DBHttpRequest:getActivityListNew(callback, args)
	local params = buildParams(args)
	--doSend(callback, POST_COMMAND_NEWGETACTIVITYLIST, "Activity", "getActivityList", params)
	NetCallBack:doSend(callback, POST_COMMAND_NEWGETACTIVITYLIST, "Activity", "getActivityList", params)
end

function DBHttpRequest:getActivityPrize(callback, activityid, macAddress)
	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(activityid,macAddress)
		doSend(callback, POST_COMMAND_GETACTIVITYPRIZE, "Activity", "getActivityPrize", params)
	else
		local params = buildParams(activityid,macAddress)
		doSend(callback, POST_COMMAND_GETACTIVITYPRIZE, "Lobby", "getActivityPrize", params)
	end
end

function DBHttpRequest:getActivityContent(callback, activityId)
	local params = buildParams(activityId)
	doSend(callback, POST_COMMAND_GETACTIVITYCONTENT, "Lobby", "getActivityContent", params)
end

--[[领取指定活动id的奖励]]
function DBHttpRequest:getActivityReward(callback, activityId)
	local params = buildParams(activityId)
	doSend(callback, POST_COMMAND_TAKEACTIVITYMONEY, "Admin", "fetchReward", params)
end

function DBHttpRequest:fetchReward(callback, userId, limitId)
	local params = buildParams(userId, limitId)
	doSend(callback, POST_COMMAND_TAKEACTIVITYMONEY, "Account", "fetchReward", params)
end

--[[查询指定活动id的奖励]]
function DBHttpRequest:queryActivityReward(callback, activityId)
	local params = buildParams(activityId)
	doSend(callback, POST_COMMAND_SELECTACTIVITYINFO, "Admin", "queryReward", params)
end

function DBHttpRequest:getRefillState(callback)
	doSend(callback, POST_COMMAND_GETPAYCONTROL, "Account", "getPayControl")
end

function DBHttpRequest:getDebaoCoin(callback, token, secret)
	if TRUNK_VERSION==DEBAO_TRUNK then
		return
	end
	local params = buildParams(token, secret)
	doSend(callback, POST_COMMAND_GETDEBAOCOIN, "Account", "getDebaoCoins", params)
end

-- function DBHttpRequest:getItemList(callback)
-- 	doSend(callback, POST_COMMAND_GETITEMLIST, "Props", "getItemList")
-- end

function DBHttpRequest:charge(callback, token, secret, item_id)
	local params = buildParams(token, secret, item_id)
	doSend(callback, POST_COMMAND_CHARGE, "Props", "buyChips", params)
end

--[[
* 获取用户拥有的道具列表
     * @param String $props_group 道具分类 CARD FACE DECORATION FUNCTION
     * @param Int $uid 用户ID，可不填
     * @param String $subclass 道具子类，可不填，用来取指定子类目的道具列表
     * @return Array/Int
]]
function DBHttpRequest:getUserPropsList(callback, group, uid, subclass)
	local params = buildParams(group, uid, subclass)
	doSend(callback, POST_COMMAND_GETUSERPROPSLIST, "Props", "getUserPropsList", params)
end

function DBHttpRequest:buyGoods(callback, goodsID, num)
	local params = buildParams(goodsID, num)
	--doSend(callback, POST_COMMAND_BUYGOODS, "Props", "buyGoods", params)
	NetCallBack:doSend(callback, POST_COMMAND_BUYGOODS, "Props", "buyGoods", params)
end

function DBHttpRequest:useProps(callback, props, args)
	local params = buildParams(props, args)
	doSend(callback, POST_COMMAND_USEPROPS, "Props", "useProps", params)
end

function DBHttpRequest:makeOverProps(callback, pid, dst_uid, dst_username, num)
	local params = buildParams(pid, dst_uid, dst_username, num)
	doSend(callback, POST_COMMAND_MAKEVOERPROPS, "Props", "makeOverProps", params)
end

function DBHttpRequest:bindQQ(callback, bindQQData)
	local params = buildParams(bindQQData)
	doSend(callback, POST_COMMAND_BINDQQ, "Account", "bindQQ", params)
end

function DBHttpRequest:bindEmail(callback, bindEmail)
	local params = buildParams(bindEmail)
	--doSend(callback, POST_COMMAND_BINDEMAIL, "Account", "setUserEmail", params)
	NetCallBack:doSend(callback, POST_COMMAND_BINDEMAIL, "Account", "setUserEmail", params)
end

--[[客户端报告]]
function DBHttpRequest:clientReport(callback, content, type, sceneId, client, os, browser)
	local params = buildParams(type, sceneId, client, os, browser, content)
	doSend(callback, POST_COMMAND_CLIENTREPORT, "Others", "clientReport", params)
end

--[[--数据上报
--统计用户行为]]
function DBHttpRequest:dataReport(callback, itid, data, expand)
	local params = buildParams(itid, data, expand)
	doSend(callback, POST_COMMAND_DATAREPORT, "Others", "dataReport", params)
end

--[[下载图片]]
function DBHttpRequest:downloadFile(callback, url, fileName, needProgress, tag)
	tag = tag and tag or 0
	doDownloadSend(callback, url, tag, fileName)
end

--[[检查版本更新]]
function DBHttpRequest:checkUpgrade(target, version, type)
	local content = ""
	local md5version = EUtils:MD5Version(version)
	content = content.."&Vname="..version
	content = content.."&type="..type
	content = content.."&sign="..md5version
	local url = URL_UPGRADE
	doOtherSend(callback, POST_COMMAND_UPGRADE, url, content)
end

function DBHttpRequest:getUserTimeWonInfo(target, bigPrecision, smallPrecision, siteId, limitId, userId)
	local params = buildParams(bigPrecision, smallPrecision, siteId, limitId, userId)
	doSend(callback, POST_COMMAND_GETUSERTIMEWONINFO, "Analysis", "getUserTimeWonInfo", params)
end

function DBHttpRequest:isFriend(callback, dstUserID)
	local params = buildParams(dstUserID)
	--doSend(callback, POST_COMMAND_ISFRIEND, "Sns", "isFriend", params)
	NetCallBack:doSend(callback, POST_COMMAND_ISFRIEND, "Sns", "isFriend", params)
end

function DBHttpRequest:getMatchInfo(callback, matchId, tableId)
	if TRUNK_VERSION==DEBAO_TRUNK then
		local params = buildParams(matchId, tableId,currentVersion())
		doSend(callback, POST_COMMAND_GETMATCHINFO, "Lobby", "getMatchInfo", params)
	else
		local params = buildParams(matchId, tableId)
		doSend(callback, POST_COMMAND_GETMATCHINFO, "Lobby", "getMatchInfo", params)
	end
end

function DBHttpRequest:getUserMatchTableInfo(callback, matchId)
	local params = buildParams(matchId)
	doSend(callback, POST_COMMAND_GETUSERMATCHTABLEINFO, "Lobby", "getUserMatchTableInfo", params)
end

function DBHttpRequest:getBlindDSInfo(callback, blindType)
	local params = buildParams(blindType)
	doSend(callback, POST_COMMAND_GETBLINDDSINFO, "Lobby", "getBlindDSInfo", params)
end

function DBHttpRequest:getMatchDetail(callback, matchId, tableId)
	local params = buildParams(matchId, tableId)
	doSend(callback, POST_COMMAND_GETMATCHDETAIL, "Lobby", "getMatchDetail", params)
end

function DBHttpRequest:getTableInfo(callback, tableType, tableId, isOldCallback)
	if isOldCallback==nil or isOldCallback==false then
		isOldCallback = false
	else 
		isOldCallback = true
	end
	local params = buildParams(tableType, tableId)
	if isOldCallback==true then
		doSend(callback, POST_COMMAND_GETTABLEINFO, "Lobby", "getTableInfo", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GETTABLEINFO, "Lobby", "getTableInfo", params)
	end
end

function DBHttpRequest:updateClientType(callback, version)
	local params = buildParams(version)
	doSend(callback, POST_COMMAND_UPDATECLIENTTYPE, "Account", "updateClientType", params)
end

function DBHttpRequest:getGoodName(callback, goodsId)
	local params = buildParams(goodsId)
	doSend(callback, POST_COMMAND_GETGOODSNAME, "Admin", "getGoodsName", params)
end

--[[获取登录奖励信息（腾讯版）]]
function DBHttpRequest:getLoginAwardInfo(callback)
	doSend(callback, POST_COMMAND_GETLOGINAWARDINFO, "Activity", "getLoginAwardInfo")
end

--[[获取登录奖励信息（主站版）]]
function DBHttpRequest:getLoginRewardInfo(callback)
	doSend(callback, POST_COMMAND_GETLOGINREWARDINFO, "Admin", "getLoginRewardInfo")
end

--[[领取登录奖励]]
function DBHttpRequest:loginReward(callback)
	doSend(callback, POST_COMMAND_LOGINREWARD, "Activity", "loginReward")
end

--[[获取登录奖励规则]]
function DBHttpRequest:getLoginAwardRules(callback)
	doSend(callback, POST_COMMAND_GETLOGINAWARDRULES, "Activity", "getLoginAwardRules")
end

--[[转盘抽奖活动]]
function DBHttpRequest:getHappyHourInfo(callback)
	doSend(callback, POST_COMMAND_HAPPYHOUR_INFO, "Activity", "getHappyHourInfo")
end

--[[ 
 * HappyHour活动抽奖
 * @return Array
 *
 * 附:
 * -1 抽奖失败
 * GOODS_ID 抽中的物品编号
 * GOODS_DESC 抽奖结果描述文字
 * TIMES 剩余抽奖次数
 ]]
function DBHttpRequest:happyHourReward(callback)
	doSend(callback, POST_COMMAND_HAPPYHOUR_REWARD, "Activity", "happyHourReward")
end

function DBHttpRequest:getBulletin(callback, type)
	local params = buildParams(type,1)
	doSend(callback, POST_COMMAND_GETBULLETIN, "Others", "getBulletin", params)
end

function DBHttpRequest:getSngPkBulletin(callback)
	local params = buildParams("K",1)
	doSend(callback, POST_COMMAND_GETSNGPKBULLETIN, "Others", "getBulletin", params)
end

--[[获取玩家赛事统计信息]]
function DBHttpRequest:getUserMatchAnalysis(callback, uid)
	local params = buildParams(uid,"true")
	doSend(callback, POST_COMMAND_GETUSERMATCHANALYSIS, "Analysis", "getUserMatchAnalysis", params)
end

function DBHttpRequest:getUserMatchData(callback, uid)
	local params = buildParams(uid)
	--doSend(callback, POST_COMMAND_getUserMatchData, "Account", "getMatchData", params)
	NetCallBack:doSend(callback, POST_COMMAND_getUserMatchData, "Account", "getMatchData", params)
end

--[[取充值列表数据]]
--[[
 * 获取商品列表(游戏币)
 * @param $ptype 充值类型
 * @return Array
 * 附：
 * DEBAO 德堡充值卡
 * ZFB 支付宝
 * CM 中移钱包
 * ZT 中腾支付
 ]]
function DBHttpRequest:getItemList(callback, ptype, btype)

	local params = buildParams(ptype, btype)
	-- dump(params)
	--doSend(callback, POST_COMMAND_GETITEMLIST, "Props", "getItemList", params)
	NetCallBack:doSend(callback, POST_COMMAND_GETITEMLIST, "Props", "getItemList", params)
end

--[[获取玩家的任务列表]]
function DBHttpRequest:getTaskList(callback)
	doSend(callback, POST_COMMAND_GETTASKLIST, "Task", "getTaskList")
end

--[[领取任务奖励]]
function DBHttpRequest:getTaskPrize(callback, taskID)
	local params = buildParams(taskID)
	doSend(callback, POST_COMMAND_GETTASKPRIZE, "Task", "getTaskPrize", params)
end

--[[HappyHour和Task配置]]
function DBHttpRequest:getTaskAndHappyHourConfig(callback)
	doSend(callback, POST_COMMAND_TASK_HAPPYHOUR_INFO, "Task", "getIconStatus")
end

--[[手机充值卡充值]]
function DBHttpRequest:phoneCardCharge(callback,uid,cardType,cardValue,cardid,cardpwd,exchangetype,sign,phpid)
	local params = buildParams(uid,cardType,cardValue,cardid,cardpwd,sign,exchangetype)
	NetCallBack:doSend(callback, POST_COMMAND_PHONECARD, "Account", "ztCharge", params)
end

--[[德堡充值卡充值]]
function DBHttpRequest:debaoCardCharge(callback,uid,cardid,cardpwd,sign,phpid)
	local params = buildParams(uid,cardid,cardpwd,sign)
	doSend(callback, POST_COMMAND_DEBAOCARD, "Account", "debaoCharge", params)
end

--[[取充值列表数据]]
--[[
 * 获取商品列表(游戏币)
 * @param $ptype 充值类型
 * @return Array
 * 附：
 * DEBAO 德堡充值卡
 * ZFB 支付宝
 * CM 中移钱包
 * ZT 中腾支付
 ]]
-- function DBHttpRequest:getItemList(callback, ptype)
-- 	local params = buildParams(ptype)
-- 	doSend(callback, nil, "Props", "getItemList", params)
-- end

--[[下单]]
function DBHttpRequest:createChargingOrder(callback,userid,exchangetype,ade_type,pay_channel,bank_type,totalFee,sign)
	local m_tag = nil
	if (pay_channel == "MM") then
		m_tag = POST_COMMAND_MM_CHARGINGORDER
	elseif (pay_channel == "ZFB") then
		m_tag = POST_COMMAND_ZBF_CHARGINGORDER
    elseif (pay_channel == "LLPAY") then
        m_tag = POST_COMMAND_LLPAY_CHARGINGORDER
	elseif (pay_channel == "CM") then
		m_tag = POST_COMMAND_YDQB_CHARGINGORDER
    -- 	else if (pay_channel == "UN") then
    -- 		m_tag = POST_COMMAND_UNIPAY_CHARGINGORDER
	elseif (pay_channel == "UNWO") then  --联通沃商店 第三方支付
		m_tag = POST_COMMAND_UNIPAY_CHARGINGORDER
    
	elseif (pay_channel == "UP") then
		m_tag = POST_COMMAND_UPOMP_CHARGINGORDER
	elseif(pay_channel == "PPS") then
		m_tag = POST_COMMAND_PPS_CHARGINGORDER
	elseif (pay_channel == "DUOKU") then
		m_tag = POST_COMMAND_DK_CHARGINGORDER
	elseif (pay_channel == "ALIPAY") then
		m_tag = POST_COMMAND_ALIPAYOPEN_CHARGINGORDER
	elseif (pay_channel == "WPAY") then
		m_tag = POST_COMMAND_WAP_CHARGINGORDER
	elseif(pay_channel == "CFT") then--tenpay
		m_tag = POST_COMMAND_TENPAY_CHARGINGORDER
	elseif (pay_channel == "DPAY") then
		m_tag = POST_COMMAND_91DPAY_CHARGINGORDER
	elseif (pay_channel == "TENCENT") then
		m_tag = POST_COMMAND_TENCENT_UNIPAY
    elseif (pay_channel == "APPLE") then
        m_tag = POST_COMMAND_APPLE_CHARGINGORDER
    elseif (pay_channel == "BAIDU") then
       	m_tag = POST_COMMAND_BAIDU_CHARGINGORDER
    elseif (pay_channel == "MEIZU") then
        m_tag = POST_COMMAND_MEIZU_CHARGINGORDER
    elseif (pay_channel == "JINLI") then
        m_tag = POST_COMMAND_JINLI_CHARGINGORDER
    elseif (pay_channel == "XIAOMI") then
        m_tag = POST_COMMAND_XIAOMI_CHARGINGORDER
    elseif (pay_channel == "WEIXIN_APP") then
        m_tag = POST_COMMAND_WEIXIN_CHARGINGORDER
    elseif (pay_channel == "PYW") then
        m_tag = POST_COMMAND_PYW_CHARGINGORDER
    elseif (pay_channel == "UPAY") then
        m_tag = POST_COMMAND_UPAY_CHARGINGORDER
    elseif (pay_channel == "NDUO") then
        m_tag = POST_COMMAND_NDUO_CHARGINGORDER
    elseif (pay_channel == "UUP") then
        m_tag = POST_COMMAND_UUCUN_CHARGINGORDER
    elseif (pay_channel == "MMY") then
        m_tag = POST_COMMAND_MMY_CHARGINGORDER
    elseif (pay_channel == "LT") then
        m_tag = POST_COMMAND_LT_CHARGINGORDER
    elseif (pay_channel == "ANQU") then
        m_tag = POST_COMMAND_ANQU_CHARGINGORDER
    end
    if pay_channel == "UNWO" then
		local params = buildParams(userid,exchangetype,ade_type,pay_channel,bank_type,totalFee,sign,
			-- NativeJNI:getAndroidIPAddr(),NativeJNI:getAndroidIMEI(),NativeJNI:getAndroidUnicomMac())
			QManagerPlatform:getIPAdress(),QManagerPlatform:getIMEI(),QManagerPlatform:getUnicomMacAddr())
		--doSend(callback, m_tag, "Account", "createChargingOrder", params)
		NetCallBack:doSend(callback, m_tag, "Account", "createChargingOrder", params)
    else
		local params = buildParams(userid,exchangetype,ade_type,pay_channel,bank_type,totalFee,sign)
		-- dump(params)
		--doSend(callback, m_tag, "Account", "createChargingOrder", params)
		NetCallBack:doSend(callback, m_tag, "Account", "createChargingOrder", params)
	end
end

function DBHttpRequest:getAccountInfoNew(callback)
	NetCallBack:doSend(callback, POST_COMMAND_GETACCOUNTINFO, "Account", "getAccountInfo")
end

function DBHttpRequest:ApplePaySuccessCallback(callback,userId,userName,receipt,innerOrderId,transactionIdentifier)
	local params = {
		userid = userId,
		username = userName,
		orderId = transactionIdentifier,
		innerOrderId = innerOrderId,
		receipt = receipt,
		version = URLEncoder:encodeURI(DBVersion),
		env = ""
	}

	local tmpStr = userId .. userName .. transactionIdentifier .. innerOrderId .. receipt .. URLEncoder:encodeURI(DBVersion)
	local sign   = CMMD5Charge(tmpStr)

	params.sign = sign

	local url = DOMAIN_URL.."/pay/appay.php?"

	NetCallBack:doSend(callback, POST_COMMAND_APPPAYNOTIFYSERVER, "", "",params,url, {})
end

---
-- 安趣支付通知php
--
-- @param callback [description]
-- @param userId [description]
-- @param userName [description]
-- @param receipt [description]
-- @param innerOrderId [description]
-- @param transactionIdentifier [description]
-- @return [description]
--
function DBHttpRequest:anquPaySuccessCallback(callback,uid,cporder,money,order)
	local params = {
		uid = uid,
		cporder = cporder,
		cpappid = "G100353",
		money = money,
		order = order,
	}

	local anqu_app_secret = "e679583a5e5795314e94ce01749d3107"
	local tmpStr = params.uid .. params.cporder .. params.money .. params.order .. anqu_app_secret
	local sign   = CMMD5Charge(tmpStr)

	params.sign = sign

	print(params.uid, "uid 安趣支付通知php数据")
	print(params.cporder, "cporder 安趣支付通知php数据")
	print(params.cpappid, " cpappid安趣支付通知php数据")
	print(params.money, "money 安趣支付通知php数据")
	print(params.order, "order 安趣支付通知php数据")

	local url = DOMAIN_URL.."/pay/anqu.php?"

	NetCallBack:doSend(callback, POST_COMMAND_ANQUPAYNOTIFYSERVER, "", "",params,url, {})
end

function DBHttpRequest:reduceTencentGameCoin(callback, url,openid,access_token,pf,pfkey,pay_token,amt,props_name,zoneid,userId,userName,innerOrderId,asynCallBack)	
	props_name = string.gsub(props_name," ","")
	userName = string.gsub(userName," ","")

	local content = url
	content = content.."?act=pay&mod=pay_money&openid="..openid
	content = content.."&access_token="..access_token
	content = content.."&pf="..pf
	content = content.."&pfkey="..pfkey
	content = content.."&pay_token="..pay_token
	content = content.."&amt="..amt
	content = content.."&props_name="..URLEncoder:encodeURI(props_name)
	content = content.."&zoneid="..zoneid
	content = content.."&userid="..userId
	content = content.."&username="..URLEncoder:encodeURI(userName)
	content = content.."&innerOrderId="..innerOrderId
	content = content.."&asynCallBack="..URLEncoder:encodeURI(asynCallBack)

	local tmpStr = userId .. userName ..innerOrderId..openid .. props_name 
	local sign   = TencentMD5Charge(tmpStr)
	content = content.."&sign="..sign

	-- local url = DOMAIN_URL.."/pay/appay.php?"
	NetCallBack:doSend(callback, POST_COMMAND_REDUCE_TENCENT_GAMECOIN, "", "","",content)
	-- doOtherSend(callback, POST_COMMAND_QUERY_TENCENT_GAMECOIN, url, content)
end

function DBHttpRequest:queryTencentGameCoin(callback,url,openid,access_token,pf,pfkey, pay_token,  zoneid,  userId,  userName)	
	local content = url
	content = content.."?act=pay&mod=get_balance&openid="..openid
	content = content.."&access_token="..access_token
	content = content.."&pf="..pf
	content = content.."&pfkey="..pfkey
	content = content.."&pay_token="..pay_token
	content = content.."&zoneid="..zoneid
	content = content.."&userid="..userId
	content = content.."&username="..URLEncoder:encodeURI(userName)

	local tmpStr = userId .. userName .. openid .. access_token 
	local sign   = TencentMD5Charge(tmpStr)
	content = content.."&sign="..sign

	-- local url = DOMAIN_URL.."/pay/appay.php?"
	NetCallBack:doSend(callback, POST_COMMAND_QUERY_TENCENT_GAMECOIN, "", "","",content)
	-- doOtherSend(callback, POST_COMMAND_QUERY_TENCENT_GAMECOIN, url, content)
end

function DBHttpRequest:jailbreakChargeSuccessRequestGoodsCallback(callback, url, userId, userName, orderId)	
	--[[string content("http://debao.boss.com/pay/notify/zfb_parsenotifyRsa.php")]]
	local content = ""
	content = content.."&userid="..userId
	content = content.."&username="..userName
	content = content.."&orderId="..orderId
	content = content.."&innerOrderId="

	local tmpStr = (userId..userName..orderId)
	local md5version = MD5Charge(version)
	content = content.."&sign="..md5version
	local url = URL_UPGRADE
	doOtherSend(callback, POST_COMMAND_CHARGESUCREQUESTGOODS, url, content)
	--[["http://debao.boss.com/pay/notify/zfb_parsenotifyRsa.php"]]
end

--[[获取图像列表]]
function DBHttpRequest:getPortraitPics(callback, fid)
	if fid and string.len(fid)>0 then
		local params = buildParams(fid)
		-- doSend(callback, POST_COMMAND_GETPORTRAITPICS, "Others", "getPortraitPics", params)
		NetCallBack:doSend(callback, POST_COMMAND_GETPORTRAITPICS, "Others", "getPortraitPics", params)
	else
		-- doSend(callback, POST_COMMAND_GETPORTRAITPICS, "Others", "getPortraitPics")
		NetCallBack:doSend(callback, POST_COMMAND_GETPORTRAITPICS, "Others", "getPortraitPics")
	end
end

--[[获取显示信息（主站版）]]
function DBHttpRequest:getUserShowInfo(callback, userId, isOldCallback)
	if isOldCallback==nil or isOldCallback==false then
		isOldCallback = false
	else 
		isOldCallback = true
	end
	local params = buildParams(userId)
	if isOldCallback then
		doSend(callback, POST_COMMAND_GETUSERSHOWINFO, "Account", "getUserShowInfo", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GETUSERSHOWINFO, "Account", "getUserShowInfo", params)
	end
end

function DBHttpRequest:getUserListShowInfo(callback, userList)
	local params = buildParams(userList)
	doSend(callback, POST_COMMAND_getUserListShowInfo, "Account", "getUserShowInfo", params)
end

function DBHttpRequest:getUserListLevel(callback, userList)
	local params = buildParams(userList)
	--doSend(callback, POST_COMMAND_getUserListLevel, "Sns", "getLadderPoint", params)
	NetCallBack:doSend(callback, POST_COMMAND_getUserListLevel, "Sns", "getLadderPoint", params)
end

function DBHttpRequest:updateUserInfo(callback, portraid, nickname, sex)
	local params = buildParams(portraid, nickname, sex)
	--doSend(callback, POST_COM_UPDATE_USER_INFO, "Account", "updateUserInfo", params)
	NetCallBack:doSend(callback, POST_COM_UPDATE_USER_INFO, "Account", "updateUserInfo", params)
end

function DBHttpRequest:setUserSex(callback, sex)
	local params = buildParams(sex)
	doSend(callback, POST_COMMAND_SETUSERSEX, "Account", "setUserSex", params)
end

function DBHttpRequest:getUserChargeInfo(callback)
	doSend(callback, POST_COM_GET_USER_CHARGE_INFO, "Account", "getUserChargeInfo")
end

function DBHttpRequest:getActivityNotify(callback)
	local version = currentVersion()
	local channel = string.sub(version, -5)
	local params = buildParams(channel)
	doSend(callback, POST_COMMAND_GETACTIVITYNOTIFY, "Activity", "getActivityNotify", params)
end

function DBHttpRequest:uploadFile(callback,uid,path)
	normal_info_log("DBHttpRequest:uploadFile上传文件功能未实现")
end

function DBHttpRequest:freshGuide(callback)
	doSend(callback, POST_FINISH_GAME_TECH, "Activity", "freshGuide")
end

function DBHttpRequest:getMobileVerifyCode(callback, mobile)
	local params = buildParams(mobile)
	--doSend(callback, POST_COMMAND_GETMOBILEVERIFYCODE, "Account", "getMobileVerifyCode", params)
	NetCallBack:doSend(callback, POST_COMMAND_GETMOBILEVERIFYCODE, "Account", "getMobileVerifyCode", params)
end

function DBHttpRequest:bindMobile(callback, mobile, code)
	local params = buildParams(mobile,code)
	--doSend(callback, POST_COMMAND_BINLDMOBILE, "Account", "bindMobile", params)
	NetCallBack:doSend(callback, POST_COMMAND_BINLDMOBILE, "Account", "bindMobile", params)
end

--[[ RushRoom]]
function DBHttpRequest:rushRoomBuyIn(callback, tableId, configId, chips)
	local params = buildParams(tableId, configId, chips)
	doSend(callback, POST_COMMAND_RUSHBUYIN, "Lobby", "rushBuyin", params)
end

function DBHttpRequest:getFriendsMessage(callback, status)
	local params = buildParams(status)
	-- doSend(callback, POST_COMMAND_GETFRIENDSMESSAGE, "Sns", "getFriendsMessage", params)
	NetCallBack:doSend(callback, POST_COMMAND_GETFRIENDSMESSAGE, "Sns", "getFriendsMessage", params)
end

function DBHttpRequest:getRankPic(callback, version)
	if version and string.len(version)>0 then
		local params = buildParams(status)
		doSend(callback, POST_COMMAND_GETRANKPIC, "Analysis", "getRankPic", params)
	else
		doSend(callback, POST_COMMAND_GETRANKPIC, "Analysis", "getRankPic")
	end
end

function DBHttpRequest:getChannelReportSwitch(callback)
	local version = currentVersion()
	local channel = string.sub(version, -5)
	local params = buildParams(channel)
	doSend(callback, POST_COMMAND_GET_REPORT_SWITCH, "Analysis", "channelReportSwitch", params)
end

function DBHttpRequest:deleteSomePrivateMessages(callback, messageId)
	local params = buildParams(messageId)
	--doSend(callback, POST_COMMAND_DELETESOMEPRIVATEMESSAGES, "Sns", "deleteSomePrivateMessages", params)
	NetCallBack:doSend(callback, POST_COMMAND_DELETESOMEPRIVATEMESSAGES, "Sns", "deleteSomePrivateMessages", params)
end

function DBHttpRequest:setShowNotify(callback, activiteId, bShow)
	local params = buildParams(activiteId,bShow and 0 or 1)
	doSend(callback, POST_COMMAND_SETSHOWNOTIFY, "Activity", "setShowNotify", params)
end

function DBHttpRequest:getMessageNotReadCount(callback)
	doSend(callback, POST_COMMAND_GETMESSAGENOTREADCOUNT, "Sns", "getMessageNotReadCount")
end

function DBHttpRequest:getMessage(callback, type, srcId, status)
	local params = buildParams(type, srcId, status)
	--doSend(callback, POST_COMMAND_getMessage, "Sns", "getMessage", params)
	NetCallBack:doSend(callback, POST_COMMAND_getMessage, "Sns", "getMessage", params)
end

function DBHttpRequest:getSplash(callback)
	local version = currentVersion()
	local params = buildParams(version)
	doSend(callback, POST_COMMAND_GETSPLASH, "Others", "getSplash", params)
end

function DBHttpRequest:getFaces(callback)
	local version = currentVersion()
	local params = buildParams(version)
	doSend(callback, POST_COMMAND_CHAT_FACE_INFO, "Others", "getFaces", params)
end

--[[获取首冲赠送比例]]
function DBHttpRequest:getFirstPayRate(callback)
	doSend(callback, POST_COMMAND_FIRST_PAY_RATE, "Account", "getFirstPayRate")
end

--[[获取手机轮播推荐赛事]]
function DBHttpRequest:getBroadCastMatchList(callback)
	doSend(callback, POST_COMMAND_BroadCastMatchList, "Lobby", "getBroadCastMatchList")
end

--[[
 * 玩家已报名赛事查询
 *
 * @return array|integer 成功时返回赛事玩家列表数组，失败时返回错误码
]]
function DBHttpRequest:getApplyMatch(callback)
	doSend(callback, POST_COMMAND_ApplyedMatch, "Lobby", "getApplyMatch")
end

--[[
 * 获取玩家物品信息
 *
 * @return Array/Int
 ]]
function DBHttpRequest:getKnapSack(callback)
	--doSend(callback, POST_COMMAND_GetKnapSack, "Props", "getKnapSack")
	NetCallBack:doSend(callback, POST_COMMAND_GetKnapSack, "Props", "getKnapSack")
end

--[[
 * 获取玩家的门票列表
 *
 * @return Array/Int
 ]]
function DBHttpRequest:getUserTicketList(callback)
	doSend(callback, POST_COMMAND_UserTicketList, "Sns", "getUserTicketList")
end

--[[
 *获取门票图片信息
 *@param int $img_id 图片id 逗号分隔
 *@return array
 *  [
 *		{
 *			"imageid" : "398",
 *			"filename" : "/static/images/news/shoppic/20131127171639_8430.jpg"
 *		}
 *	]
]]
function DBHttpRequest:getUserTicketImg(callback, imageId)
	local params = buildParams(imageId)
	doSend(callback, POST_COMMAND_UserTicketImage, "Sns", "getUserTicketImg", params)
end

function DBHttpRequest:getUserSngPKInfo(callback, userId)
	local params = buildParams(userId)
	doSend(callback, POST_COMMAND_GETUSERSNGPKINFO, "Analysis", "getUserSngPKInfo", params)
end

function DBHttpRequest:getGoodsList(callback, type)
	local params = buildParams(type,"SYSTEM")
	--doSend(callback, POST_COMMAND_GETGOODSLIST, "Props", "getGoodsList", params)
	NetCallBack:doSend(callback, POST_COMMAND_GETGOODSLIST, "Props", "getGoodsList", params)
end

--[[取系统时间]]
function DBHttpRequest:getServerTime(callback)
	doSend(callback, POST_COMMAND_GETSERVERTIME, "Common", "getServerTime")
end

function DBHttpRequest:getSngPkMatchInfo(callback)
	doSend(callback, POST_COMMAND_GETSNGPKMATCHINFO, "Lobby", "getSngPkMatchInfo")
end

function DBHttpRequest:getLoginConfig(callback, version)
	local params = buildParams(version)
	doSend(callback, POST_COMMAND_GETLOGINCONFIG, "Others", "getLoginConfig", params)
end

function DBHttpRequest:applySngPK(callback, bUseTicket)
	local params = buildParams(NativeJNI:getAndroidMac(), bUseTicket and 1 or 0)
	doSend(callback, POST_COMMAND_APPLYSNGPK, "Lobby", "applySngPK", params)
end

function DBHttpRequest:quitMatch(callback, matchId)
	local params = buildParams(matchId)
	doSend(callback, POST_COMMAND_QUITMATCH, "Lobby", "quitMatch", params)
end

function DBHttpRequest:quitDiyMatch(callback, matchId)
	local params = buildParams(matchId)
	doSend(callback, POST_COMMAND_QUIT_DIY_MATCH, "Lobby", "quitDiyMatch", params)
end

function DBHttpRequest:weixinShare(callback, type)
	local params = buildParams(type)
	doSend(callback, POST_COMMAND_SHARETOWECHATREPORT, "Others", "weixinShare", params)
end

--[[svn]]
function DBHttpRequest:sendBoardInfo(callback, hid, hname, hinfo, remark)
	local params = buildParams(hid, hname, hinfo, remark)
	doSend(callback, POST_COMMAND_SENDBOARDINFO, "Analysis", "addFavoriteHands", params)
end

function DBHttpRequest:getBoardInfo(callback, fid)
	local params = buildParams(fid)
	doSend(callback, POST_COMMAND_GETBOARDINFO, "Analysis", "getFavoriteHandsInfo", params)
end

function DBHttpRequest:getESunCK(callback, username, password)
	normal_info_log("DBHttpRequest:getESunCK未实现")
	-- local content = "http://inter.boss.com/interface/client/requestdebao.php?c_id=10038&c_outtype=0&iscompress=0&charset=GBK&c_type=1&cpid=83&type=3"
	-- content = content.."&userid="..userId
	-- content = content.."&username="..userName
	-- content = content.."&orderId="..orderId
	-- content = content.."&innerOrderId="

	-- local tmpStr = (userId..userName..orderId)
	-- local md5version = MD5Charge(version)
	-- content = content.."&sign="..md5version
	-- doOtherSend(callback, POST_COMMAND_GETESUNCK, content)
end

function DBHttpRequest:sendVerifyMsg(callback, verifyMod, recver, username, platform)
	local params = buildParams(verifyMod, recver, username, platform)
	NetCallBack:doSend(callback, POST_COMMAND_sendVerifyMsg, "Account", "sendVerifyMsg", params)
end

function DBHttpRequest:verifyPhoneCode(callback, code)
	local params = buildParams(code)
	NetCallBack:doSend(callback, POST_COMMAND_verifyPhoneCode, "Account", "verifyPhoneCode", params)
end

function DBHttpRequest:getVerifyCode(callback, username)
	local params = buildParams(username)
	doSend(callback, POST_COMMAND_getVerifyCode, "Account", "getVerifyCode", params)
end

function DBHttpRequest:resetPassword(callback, method, username, email, mobile)
	local params = buildParams(method, username, email, mobile)
	NetCallBack:doSend(callback, POST_COMMAND_ResetPassword, "Account", "resetPassword", params)
end

function DBHttpRequest:getLoginSwitch(callback)
	doSend(callback, POST_COMMAND_GET_LOGINSWITCH, "Account", "loginSwitch")
end

function DBHttpRequest:getShopSwitch(callback)
	doSend(callback, POST_COMMAND_GET_SHOPSWITCH, "Props", "shopSwitch")
end

function DBHttpRequest:requestUniqueUser(callback, wanname, username, password)
	local params = buildParams(username, wanname, password, "", "", "500WAN")
	doSend(callback, POST_COMMAND_SIGN_BIND_500, "Account", "signBindWan", params)
end

function DBHttpRequest:getSngMatch(callback, level, tourneyType, matchStatus, returnType)
	local params = buildParams(level, tourneyType, matchStatus)
	doSend(callback, POST_COMMAND_GetSngMatch, "Lobby", "getSngMatch", params)
end

function DBHttpRequest:applySng(callback, payType, payNum, playType, applyIp)
	local params = buildParams(payType, payNum, playType)
	doSend(callback, POST_COMMAND_ApplySngMatch, "Lobby", "applySng", params)
end

--[[请求addon]]
function DBHttpRequest:addOn(callback, matchId, tableId)
	local params = buildParams(matchId, tableId)
	doSend(callback, POST_COMMAND_AddOn, "Lobby", "addOn", params)
end

function DBHttpRequest:getUserReplay(callback, page, num)
	--[[arg3 0不显示已删除牌局,1为显示]]
	--[[arg6 2降序,1升序]]
	local params = buildParams("","",0,"","",2)
	--doSend(callback, POST_COMMAND_GetUserHandsFavorite, "Analysis", "getUserHandsFavorite", params)
	NetCallBack:doSend(callback, POST_COMMAND_GetUserHandsFavorite, "Analysis", "getUserHandsFavorite", params)
end

function DBHttpRequest:upFavoriteHands(callback, fid, hname, remark)
	local params = buildParams(fid, hname, remark)
	--doSend(callback, POST_COMMAND_UpFavoriteHands, "Analysis", "upFavoriteHands", params)
	NetCallBack:doSend(callback, POST_COMMAND_UpFavoriteHands, "Analysis", "upFavoriteHands", params)
end

function DBHttpRequest:delFavoriteHands(callback, fid)
	local params = buildParams(fid)
	--doSend(callback, POST_COMMAND_DelFavoriteHands, "Analysis", "delFavoriteHands", params)
	NetCallBack:doSend(callback, POST_COMMAND_DelFavoriteHands, "Analysis", "delFavoriteHands", params)
end

function DBHttpRequest:registerPC(callback, name, password, sex, verifyCode)
	local sign = "debao_fuck_ip"
	local regChannel = string.sub(DBVersion,-5,-1) --"DEBAO"
	sign = crypto.md5(sign)
	local params = buildParams(name, password, sex, sign, "", "", regChannel, "")
	NetCallBack:doSend(callback, POST_COMMAND_REGISTERPC, "Account", "registerInnerMobile", params)
end

function DBHttpRequest:quickRegister(callback, name, password, sex, ip, version, platform)
	local sign = "debao_fuck_ip"
	local params = buildParams(name, password, sex, sign, ip, version, platform)
	doSend(callback, POST_COMMAND_QUICKREGISTER, "Account", "quickRegister", params)
end

function DBHttpRequest:getRefreshReportSwitch(callback)
	local version = currentVersion()
	local channel = string.sub(version, -5)
	local params = buildParams(channel)
	doSend(callback, POST_COMMAND_REFRESH_REPORT_SWITCH, "Analysis", "freshReportSwitch", params)
end

function DBHttpRequest:getLableShowConfig(callback)
	doSend(callback, POST_COMMAND_GetLableShowConfig, "Admin", "getLableShowConfig")
end

function DBHttpRequest:getMatchDetailByName(callback, name)
	local params = buildParams(name)
	doSend(callback, POST_COMMAND_GetMatchDetailByName, "Lobby", "getMatchDetailByName", params)
end

function DBHttpRequest:getcheckUserAuth(callback, realName, idcardNo)
	local params = buildParams(realName, idcardNo)
	doSend(callback, POST_COMMAND_CheckUserAuth, "Account", "checkUserAuth", params)
end

function DBHttpRequest:applyDiyMtt(callback, match_id, passwd)
	passwd = crypto.md5(passwd)
	local params = buildParams(match_id, passwd)
	doSend(callback, POST_COMMAND_APPLY_DIY_MTT, "Lobby", "applyDiyMtt", params)
end

function DBHttpRequest:startDiyMatch(callback, match_id)
	local params = buildParams(match_id)
	doSend(callback, POST_COMMAND_START_DIY_MATCH, "Lobby", "startDiyMatch", params)
end

function DBHttpRequest:kickApply(callback, accept_id, match_id)
	local params = buildParams(accept_id, match_id)
	doSend(callback, POST_COMMAND_KICK_APPLY, "Lobby", "kickApply", params)
end

function DBHttpRequest:getExpressInfo(callback, userId,isOldCallback)
	local params = buildParams(userId)
	if isOldCallback then
		doSend(callback, POST_COMMAND_getExpressInfo, "Account", "getExpressInfo", params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_getExpressInfo, "Account", "getExpressInfo", params)
	end
end

--[[
	vip信息
	]]
function DBHttpRequest:getUserVipInfo(callback, userId)
	local params = buildParams(userId)
	NetCallBack:doSend(callback, POST_COMMAND_getUserVipInfo, "User", "getUserVipInfo", params)
end
--[[
 * 修改玩家扩展信息（不需修改项则不用填写）
 * @param string $truename 玩家真实姓名
 * @param string $sex 玩家性别
 * @param string $country 玩家所属国家
 * @param string $province 玩家所在省份
 * @param string $city 玩家所在城市
 * @param string $address_detail 玩家住址
 * @param string $idcard 玩家身份证
 * @param string $wbai_name 绑定的500账号
 * @return bool
 ]]
function DBHttpRequest:updateUserExtensionInfo(callback, truename, sex, country, province, city, address_detail, idcard, wbai_name)
	local sign = "debao_fuck_ip"
	local params = buildParams(truename, sex, country, province, city, address_detail, idcard, wbai_name)
	--doSend(callback, POST_COMMAND_updateUserExtensionInfo, "Account", "updateUserExtensionInfo", params)
	NetCallBack:doSend(callback, POST_COMMAND_updateUserExtensionInfo, "Account", "updateUserExtensionInfo", params)
end
--[[
	公告内容
]]
function DBHttpRequest:getAffiches(callback,userId)
	local regChannel = string.sub(DBVersion,-5,-1) --"DEBAO"
	local version    = string.gsub(DBVersion,string.sub(DBVersion,1,7),"")
	version = string.gsub(version,string.sub(DBVersion,-6,-1),"")
	local params = buildParams(userId,regChannel,version)
	NetCallBack:doSend(callback, POST_COMMAND_ANNOUNCEINFO, "Notice", "getAffiches",params)
end
--[[
	公告奖励领取
]]
function DBHttpRequest:getAward(callback,userId,id)
	local params = buildParams(userId,id)
	NetCallBack:doSend(callback, POST_COMMAND_ANNOUNCEAWARD, "Notice", "getAward",params)
end
--[[检查session]]
function DBHttpRequest:checkGameSession(callback)
	local params = buildParams(myInfo.data.userName,myInfo.data.userId,myInfo.data.userSession)
	NetCallBack:doSend(callback, POST_COMMAND_CHECKGAMESESSION, "User", "checkGameSession",params)
end

--[[创建session]]
function DBHttpRequest:createGameSession(callback)	
	local params = buildParams(myInfo.data.userId, myInfo.data.userName, myInfo.data.phpSessionId)
	NetCallBack:doSend(callback, POST_COMMAND_CREATEGAMESESSION, "Account", "createGameSession",params)
end

--[[创建私人房间]]
function DBHttpRequest:useRoomCard(callback, pid, room_name, password, seat_num, blind_level, duration)
	password = crypto.md5(password)
	local params = buildParams(pid, room_name, password, seat_num, blind_level, duration)
	NetCallBack:doSend(callback, POST_COMMAND_USE_ROOMCARD, "Props", "useRoomCard",params)
end

--[[创建单桌sng房间]]
function DBHttpRequest:useMatchCard(callback,pid,room_name,password,seat_num,init_chips,up_seconds,
	desc,blind_type,wait_time,plan_starttime,pay_type,pay_money,hand_fee,
	min_player,max_player,bonus_config,is_rebuy,is_addon)
	-- print(pid)
	-- print(room_name)
	-- print(password)
	-- print(seat_num)
	-- print(init_chips)
	-- print(up_seconds)
	-- print(desc)
	-- print(blind_type)
	-- print(wait_time)
	-- print(plan_starttime)
	-- print(pay_type)
	-- print(pay_money)
	-- print(hand_fee)
	-- print(min_player)
	-- print(max_player)
	-- print(bonus_config)
	-- print(is_rebuy)
	-- print(is_addon)

	password = crypto.md5(password)
	local params = nil
	if desc then
		params = buildParams(pid,room_name,password,seat_num,init_chips,up_seconds,desc,blind_type,wait_time,plan_starttime,pay_type,pay_money,hand_fee,min_player,max_player,bonus_config,is_rebuy,is_addon)
	else
		params = buildParams(pid,room_name,password,seat_num,init_chips,up_seconds)
	end
	NetCallBack:doSend(callback, POST_COMMAND_USE_MATCHCARD, "Props", "useMatchCard",params)
end

--[[私人局买入申请订单列表]]
function DBHttpRequest:getBuyinApplyOrders(callback, table_id)
	local params = buildParams(table_id)
	NetCallBack:doSend(callback, POST_COMMAND_BUYIN_APPLY_ORDERS, "Account", "getBuyinApplyOrders",params)
end

--[[
============私人局买入申请订单列表============
* [getMyPriTable 自己开创的私人桌列表]
     * @param  string $status OPEN    开放状态
     *                        CLOSED  关闭状态
     *                        ALL     不区分状态，只取指定数量条目
]]
function DBHttpRequest:getMyPriTable(callback, status)
	local params = buildParams(status)
	NetCallBack:doSend(callback, POST_COMMAND_GET_MY_PRITABLE, "Account", "getMyPriTable",params)
end
--[[
	个人中心 朋友局纪录
]]
function DBHttpRequest:getPriTableList(callback, uid, start, num)
	local params = buildParams(uid, start, num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_PRITABLE_LIST, "Account", "getPriTableList",params)
end
--[[
	个人中心 朋友局纪录排名
]]
function DBHttpRequest:getPriTableUserList(callback, table_id, start, num)
	local params = buildParams(table_id, start, num)
	-- dump(params)
	NetCallBack:doSend(callback, POST_COMMAND_GET_PRITABLE_USER_LIST, "Account", "getPriTableUserList",params)
end

--[[根据configId获取tableId]]
function DBHttpRequest:getDiyTableIdByFid(callback, id, isOldCallback)
	local params = buildParams(id)
	if isOldCallback then
		doSend(callback, POST_COMMAND_GET_DiyTableIdByFid, "Lobby", "getDiyTableIdByFid",params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GET_DiyTableIdByFid, "Lobby", "getDiyTableIdByFid",params)
	end
end

--[[根据tableId获取configId]]
function DBHttpRequest:getDiyFidByTableId(callback, id, isOldCallback)
	local params = buildParams(id)
	if isOldCallback then
		doSend(callback, POST_COMMAND_GET_DiyFidByTableId, "Lobby", "getDiyFidByTableId",params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GET_DiyFidByTableId, "Lobby", "getDiyFidByTableId",params)
	end
end

--[[SNG报名]]
function DBHttpRequest:applyDiyMatch(callback, tableId, password, isOldCallback)
	password = crypto.md5(password)
	local params = buildParams(tableId, password)
	if isOldCallback then
		doSend(callback, POST_COMMAND_GET_ApplyDiyMatch, "Lobby", "applyDiyMatch",params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GET_ApplyDiyMatch, "Lobby", "applyDiyMatch",params)
	end
end

-------------------------------------战队接口------------------------------------------------
--[[
	取用户扩展信息成功(活动拆分)
]]
function DBHttpRequest:getUserExtentionInfo(callback, userId)
	local params = buildParams(userId)
	-- dump(params)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getUserExtentionInfo, "User", "getUserExtentionInfo",params)
end
--[[
	* 创建俱乐部
	 * @param String $club_name 俱乐部名称
	 * @param String $club_type 俱乐部类型 CLUB/TEAM
	 @return Int
]]
function DBHttpRequest:createClub(callback, club_name, club_type)
	local params = buildParams(club_name, club_type)
	NetCallBack:doSend(callback, POST_COMMAND_GET_createClub, "Club", "createClub",params)
end
--[[
	获取俱乐部列表
]]
function DBHttpRequest:getClubList(callback,start,num)
	local params = buildParams(start, num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubList, "Club", "getClubList",params)
end
--[[
	获取俱乐部列表
	@param String $club_name 俱乐部名称
	@param String $owner_name 队长名
]]
function DBHttpRequest:searchClub(callback,club_name,owner_name)
	local params = buildParams(club_name, owner_name)
	NetCallBack:doSend(callback, POST_COMMAND_GET_searchClub, "Club", "searchClub",params)
end
--[[
	查询已提交申请俱乐部列表
]]
function DBHttpRequest:getClubApplyList(callback)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubApplyList, "Club", "getClubApplyList")
end
--[[
	查询俱乐部申请列表
	 * @param $club_id
	 @return Array
]]
function DBHttpRequest:getReviewClubList(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getReviewClubList, "Club", "getReviewClubList",params)
end
--[[
	* 申请加入俱乐部
	 * @param $club_id
	 * @return Int
]]
function DBHttpRequest:applyClub(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_applyClub, "Club", "applyClub",params)
end
--[[
	 * 批量审核玩家申请
	 * @param $club_id
	 * @param $apply_id
	 * @param $action EXAMINED/REJECT
	 * @return Int
]]
function DBHttpRequest:ReviewClubList(callback,club_id,apply_id,action)
	local params = buildParams(club_id,apply_id,action)
	NetCallBack:doSend(callback, POST_COMMAND_GET_ReviewClubList, "Club", "ReviewClubList",params)
end
--[[
	 * 获取任务列表
	 * @return Array
]]
function DBHttpRequest:getDailyTaskList(callback)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getDailyTaskList, "Club", "getDailyTaskList")
end
--[[
	 * 获取领奖资格
	 * @param $activity_id
	 * @return Array
]]
function DBHttpRequest:queryReward(callback,queryReward)
	local params = buildParams(queryReward)
	NetCallBack:doSend(callback, POST_COMMAND_GET_queryReward, "Club", "queryReward",params)
end
--[[
	* 领取奖励
	 * @param $reward_id
	 * @return Array
]]
function DBHttpRequest:receiveRewards(callback,reward_id)
	local params = buildParams(reward_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_receiveRewards, "Club", "receiveRewards",params)
end
--[[
	* 获取俱乐部信息
	 * @return Array
]]
function DBHttpRequest:getClubInfo(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubInfo, "Club", "getClubInfo",params)
end
--[[
	* 获取俱乐部成员身份
	 * @return Array
]]
function DBHttpRequest:getMemberInfo(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getMemberInfo, "Club", "getMemberInfo",params)
end
--[[
	* 获取俱乐部成员
	 * @param Int $club_id
	 * @return Array
]]
function DBHttpRequest:getClubMembers(callback,club_id,uid,start,num)
	local params = buildParams(club_id,uid,start,num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubMembers, "Club", "getClubMembers",params)
end
--[[
	* 获取俱乐部动态
	 * @param Int $club_id
	 * @param Int $num
	 * @return Array
]]
function DBHttpRequest:getClubHistory(callback,club_id,num)
	local params = buildParams(club_id,num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubHistory, "Club", "getClubHistory",params)
end
--[[
	 * 获取俱乐部公告
	 * @param Int $club_id
	 * @return Array
]]
function DBHttpRequest:getClubNotice(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubNotice, "Club", "getClubNotice",params)
end
--[[
	 * 设置俱乐部公告
	* @param int $club_id
	* @param string $notice
	* @return unknown
]]
function DBHttpRequest:saveClubNotice(callback,club_id,notice)
	local params = buildParams(club_id,notice)
	NetCallBack:doSend(callback, POST_COMMAND_GET_saveClubNotice, "Club", "saveClubNotice",params)
end
--[[
	 * 给会员派发奖励
	 * @param $accept_uid 派发对象成员uid
	 * @param $value 派发数额
	 * @param $club_id 俱乐部ID
	 * @return Int --RAKEPOINT,GOLD
]]
function DBHttpRequest:sentMoneyToMember(callback,accept_uid,value,club_id,pay_type)
	local params = buildParams(accept_uid,value,club_id,pay_type)
	NetCallBack:doSend(callback, POST_COMMAND_GET_sentMoneyToMember, "Club", "sentMoneyToMember",params)
end
--[[
	* 踢出俱乐部玩家
	 * @param $accept_uid 踢出对象成员uid
	 * @param $club_id 俱乐部ID
	 * @return Int
]]
function DBHttpRequest:kickOutMember(callback,accept_uid,club_id)
	local params = buildParams(accept_uid,club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_kickOutMember, "Club", "kickOutMember",params)
end
--[[
	* 任命俱乐部成员
	 * @param $accept_uid 任命对象成员uid
	 * @param $club_position 俱乐部职务
	 * @param $club_id 俱乐部ID
	 * @return Int
]]
function DBHttpRequest:appointMember(callback,accept_uid,club_position,club_id)
	local params = buildParams(accept_uid,club_position,club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_appointMember, "Club", "appointMember",params)
end
--[[
	* 解散俱乐部
	 * @return Int
]]
function DBHttpRequest:dissolveClub(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_dissolveClub, "Club", "dissolveClub",params)
end
--[[
	* 退出俱乐部
	 * @return Int
]]
function DBHttpRequest:quitClub(callback,club_id)
	local params = buildParams(club_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_quitClub, "Club", "quitClub",params)
end
--[[
	* 获取战队排行榜
	 * @return Array
]]
function DBHttpRequest:getClubBoardList(callback,num)
	local params = buildParams(num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getClubBoardList, "Club", "getClubBoardList",params)
end
--[[
	* 战队钻石兑换接口
	 * @param $club_id 战队ID
	 * @param $goods_id 需要兑换的商品ID
         * @return Array
]]
function DBHttpRequest:useClubDiamondExchange(callback,club_id,goods_id)
	local params = buildParams(club_id,goods_id)
	NetCallBack:doSend(callback, POST_COMMAND_GET_useClubDiamondExchange, "Club", "useClubDiamondExchange",params)
end
--[[
	* 战队成员捐赠钻石接口
	* @param $num 捐赠数量 
    * @return Array
]]
function DBHttpRequest:donateDiamondToClub(callback,num)
	local params = buildParams(num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_donateDiamondToClub, "Club", "donateDiamondToClub",params)
end
--[[
	允许基金捐赠操作的战队白名单
]]
function DBHttpRequest:donateFundWhiteList(callback)
	NetCallBack:doSend(callback, POST_COMMAND_GET_donateFundWhiteList, "Club", "donateFundWhiteList")
end
--[[
	* 捐赠战队基金
     * @param $num 	数量
     * @return code
]]
function DBHttpRequest:donateFund(callback,num)
	local params = buildParams(num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_donateFund, "Club", "donateFund",params)
end
--[[
	* 邀请玩家加入自己所在战队
	 * @param $accept_uid 被邀请人的UID
     * @return code
]]
function DBHttpRequest:inviteMember(callback,accept_uid)
	local params = buildParams(accept_uid)
	NetCallBack:doSend(callback, POST_COMMAND_GET_inviteMember, "Club", "inviteMember",params)
end
--[[
	* 邀请玩家加入自己所在战队
	 * @param $accept_uid 被邀请人的UID
     * @return code
]]
function DBHttpRequest:acceptInvite(callback,club_id,oper_uid)
	local params = buildParams(club_id,oper_uid)
	NetCallBack:doSend(callback, POST_COMMAND_GET_acceptInvite, "Club", "acceptInvite",params)
end

function DBHttpRequest:priTableList(callback,club_id,isOldCallback)
	local params = buildParams(club_id)
	if isOldCallback then
		doSend(callback, POST_COMMAND_GET_priTableList, "Club", "priTableList",params)
	else
		NetCallBack:doSend(callback, POST_COMMAND_GET_priTableList, "Club", "priTableList",params)
	end
end
-------------------------------------战队接口结束------------------------------------------------

function DBHttpRequest:checkVersion(callback)
	local configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..DBPatchVersion.."&params[]="..DBChannel
	if DBAPKVersion then
        configIp = configIp .."&params[]=".. DBAPKVersion
    end
	NetCallBack:doSend(callback, POST_COMMAND_GET_checkVersion, "","",nil,configIp)
end

--[[
	/**
	* [exchangePoint 德堡钻兑换金币
	* @param  int $point_num 要兑换的德堡钻数目
	*/
]]
function DBHttpRequest:exchangePoint(callback,point_num)
	local params = buildParams(point_num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_exchangePoint, "Account", "exchangePoint",params)
end
--[[
	/**
	* 购买商品，作为礼物送给指定玩家
	*
	* @param Int $ware_id 商品ID
	* @param string $accept_uid 接受人uid
	* @param Int $buy_num 购买数量
	* @return Int 1成功 其他失败
	*/
]]
function DBHttpRequest:buyAsGift(callback,ware_id,accept_uid,buy_num)
	local params = buildParams(ware_id,accept_uid,buy_num)
	NetCallBack:doSend(callback, POST_COMMAND_GET_buyAsGift, "Props", "buyAsGift",params)
end
function DBHttpRequest:getPerson(callback)
	NetCallBack:doSend(callback, POST_COMMAND_GET_getPerson, "User", "getPerson")
end
--[[
  	个人信息：修改个人信息操作
]]
function DBHttpRequest:updatePerson(callback,truename,idcard)
	local params = buildParams(truename,idcard)
	NetCallBack:doSend(callback, POST_COMMAND_GET_updatePerson, "User", "updatePerson",params)
end

function DBHttpRequest:tableLevelToGameAddr(callback,big_blind,small_blind)
	local params = buildParams(big_blind,small_blind)
	doSend(callback, POST_COMMAND_TABLELEVEL_TO_GAMEADDR, "Lobby", "tableLevelToGameAddr", params)
end
return DBHttpRequest
