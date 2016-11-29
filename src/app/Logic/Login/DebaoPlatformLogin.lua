local tencentValue = require("app.Logic.Config.tencentValue")
require("app.Network.Http.DBHttpRequest")
-- require("app.Network.Socket.TcpCommandRequest")
require("app.Network.Socket.PushCommandRequest")
local myInfo = require("app.Model.Login.MyInfo")
require("app.EConfig")
require("app.Network.ParseKeyValue")
require("app.Logic.Config.UserDefaultSetting")
require("app.Logic.Room.TourneyGuideReceiver")
local PlatformLogin = require("app.Logic.Login.PlatformLogin")
local MusicPlayer = require("app.Tools.MusicPlayer")

local  NOTIFICATION_QQLOGINRESULT=	"notification_qqloginresult"
local  NOTIFICATION_OPENALIPAYRESULT=	"notification_openalipayresult"
local  NOTIFICATION_CHECKALIPAYOPENLOGIN=  "NOTIFICATION_CHECKALIPAYOPENLOGIN"
local  NOTIFICATION_ONOTHERPLATFORMLOGINRESULT=		"NOTIFICATION_ONOTHERPLATFORMLOGINRESULT"

local  NOTIFICATION_ANDROID_DEBAO_LOGIN = 	    "notification_android_debao_login"
local  NOTIFICATION_ANDROID_DEBAO_REGISTER=  	"notification_android_debao_register"
local  NOTIFICATION_ANDROID_DEBAO_FAST_LOGIN=  	 "notification_android_debao_fast_login"
local  NOTIFICATION_ANDROID_500WAN_LOGIN=       "notification_android_500wan_register"

local  NOTIFICATION_ANDROID_GET_VERIFY_CODE=       "notification_android_get_verify_code"
local  NOTIFICATION_ANDROID_BIND_MOBILE=       "notification_android_bind_mobile"
--local  NOTIFICATION_ANDROID_500WAN_LOGIN=       "notification_android_500wan_register"

local  NOTIFICATION_ANDROID_DEBAO_RENAME=       "notification_android_debao_rename"
local  NOTIFICATION_SHOW_SELECTDIALOG=       "notification_show_selectdialog"

local  NOTIFICATION_ANDROID_DEBAO_PWDSETTING=       "notification_android_debao_pwd_setting"
local  NOTIFICATION_ANDROID_DEBAO_ACCOUNTBIND=       "notification_android_debao_account_bind"
local  NOTIFICATION_LLPAY_CHECK_UESR_AUTH=       "notification_llpay_check_user_auth"

local  NOTIFICATION_ANDROID_500WAN_ACCOUNTBIND=       "notification_android_500wan_account_bind"


local DebaoPlatformLogin = class("DebaoPlatformLogin", function()
		return PlatformLogin:new()
	end)
local instance = nil

--[[socket监听函数]]
function DebaoPlatformLogin.onStatus(__event)
	if __event then
	end
	
end

function DebaoPlatformLogin.onClose(__event)
	DBLog("DebaoPlatformLogin.onClose:", __event.name)
end

function DebaoPlatformLogin.onClosed(__event)
	DBLog("DebaoPlatformLogin.onClosed:", __event.name)
end

function DebaoPlatformLogin.onConnectFailure(__event)
	DBLog("DebaoPlatformLogin.onConnectFailure: %s", __event.name)
end

function DebaoPlatformLogin:ctor()
	self.m_userName = ""
	self.m_password = ""
	self.m_loginType = 1
	self.m_bRemeber = false
	self.m_bAuto = false
    self.m_sdk_sign = ""

	self.m_loginStr = ""

	instance = self	

	self:setTcpIpandPort()

-- socket连接地址不需要加http://
	-- local proxyIp = string.gsub(myInfo.data.Global_ProxyIp,"http://","")
	-- self.tcpRequest:connectSocket(proxyIp , myInfo.data.Global_ProxyPort)
	

    self:setNodeEventEnabled(true)
    -- self:registerScriptHandler(handler(self, self.onNodeEvent))

    self.m_onLoginCallbackEvt = cc.EventListenerCustom:create(NOTIFICATION_QQLOGINRESULT, handler(self, self.onLoginCallback))
    self.m_onCheckOpenAlipayCallEvt = cc.EventListenerCustom:create(NOTIFICATION_CHECKALIPAYOPENLOGIN, handler(self, self.onCheckOpenAlipayCallback))
    self.m_onOtherPlatformLoginResultEvt = cc.EventListenerCustom:create(NOTIFICATION_ONOTHERPLATFORMLOGINRESULT, handler(self, self.onOtherPlatformLoginResult))
    local fixedPriority = 1
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.m_onLoginCallbackEvt, fixedPriority)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.m_onCheckOpenAlipayCallEvt, fixedPriority)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.m_onOtherPlatformLoginResultEvt, fixedPriority)

    self.m_onLR = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
    	handler(self, self.onLoginResult),0, true)

    MusicPlayer:getInstance():playBackgroundMusic()
end

function DebaoPlatformLogin:onNodeEvent(event)
    if event == "exit" then
    	self:onExit()
    end
end

function DebaoPlatformLogin:onExit()
	PlatformLogin.onExit(self)
		if self.m_onLoginCallbackEvt then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_onLoginCallbackEvt)
			self.m_onLoginCallbackEvt = nil
		end
		if self.m_onCheckOpenAlipayCallEvt then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_onCheckOpenAlipayCallEvt)
			self.m_onCheckOpenAlipayCallEvt = nil
		end
		if self.m_onOtherPlatformLoginResultEvt then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_onOtherPlatformLoginResultEvt)
			self.m_onOtherPlatformLoginResultEvt = nil
		end
		if self.m_onLR then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_onLR)
			self.m_onLR = nil
		end
end

function DebaoPlatformLogin:onLoginCallback(event)
	self.m_loginStr = ""
	self.m_loginStr = event:getDataString()
    
	cc.Director:getInstance():getScheduler():resumeTarget(self)
end


function DebaoPlatformLogin:onOtherPlatformLoginResult(event)
	local str = event:getDataString()
	
	local jsonTable = json.decode(strJson)
	if type(jsonTable)=="table" then 
		local platformType = root["platformType"]..""
		if (platformType == "DKBaidu") then
		
			local userid = root["userId"]..""
			local authCode = root["sessionId"]..""
			DBHttpRequest:debaoThreePlatFormLogin(handler(self,self.httpResponse), userid, "", 
				tencentValue:LoginIp(), authCode, "DUOKU")
		elseif (platformType == "DPay91") then
		
			local userid = root["dpayuserid"]..""
			local authCode = root["dpaysessionid"]..""
			DBHttpRequest:debaoThreePlatFormLogin(handler(self,self.httpResponse), userid, "", 
				tencentValue:LoginIp(), authCode, "91")
		end
		
        
	end
end
function DebaoPlatformLogin:onOpenAlipayCallback(event)
	normal_info_log("DebaoPlatformLogin:onOpenAlipayCallback")
	-- Json::Value  root
	-- Json::Reader  reader
	-- if (reader.parse(data, root))
	
	-- 	string alipayUserId = root["alipayuserid"].asString()
	-- 	string authCode = root["authcode"].asString()
	-- 	CCLog("alipayopen alipayuserid: %s    authcode: %s", alipayUserId.c_str(), authCode.c_str())
	-- 	DBHttpRequest:debaoLogin(handler(self, self.httpResponse), alipayUserId, authCode, "AOP", tencentValue:LoginIp(),currentVersion())
	-- end
end

function DebaoPlatformLogin:onCheckOpenAlipayCallback(event)

	self:imLogin()
end

function DebaoPlatformLogin:onLoginResult(delta)

	cc.Director:getInstance():getScheduler():pauseTarget(self)
	if (not self.m_loginStr) then
		return
	end
	local str = self.m_loginStr
	self.m_loginStr = ""
	
	local jsonTable = json.decode(str)
	if type(jsonTable)=="table" then
	
		local loginType = jsonTable["loginType"]..""
		if loginType == "qq" then
		
			local loginResult = jsonTable["loginResult"]..""
			if loginResult == "onCancel" then
			
			elseif loginResult == "onError" then
			
				local errorMessage = jsonTable["errorMessage"]..""
				self.m_pCallbackUI:loginFailedCallback(LOGIN_QQ_ONERROR, errorMessage)
			elseif loginResult == "onComplete" then
			
				local openId = jsonTable["openid"]..""
				local accessToken = jsonTable["access_token"]..""
				local expires_in = jsonTable["expires_in"]..""
				local expires = expires_in+0
				if openId == "" or accessToken == "" then
					return
				end
				self.m_pCallbackUI:showLoadingViewCallback(true)
				UserDefaultSetting:getInstance():setTencentOpenId(openId)
				UserDefaultSetting:getInstance():setTencentToken(accessToken)
				local now = os.time()
				UserDefaultSetting:getInstance():setTencentExpires(expires)
				UserDefaultSetting:getInstance():setTencentInfoTime(now)
                
                DBHttpRequest:debaoLoginForVersionControl(handler(self, self.httpResponse), openId, accessToken,
                 	tencentValue:LoginIp(), "QQ", currentVersion(), "","")
			end
		elseif loginType == "register" then
			local username =jsonTable["username"]..""
			local password = jsonTable["password"]..""
			if username ~= "" and password ~= "" then
			
				myInfo.data.loginType = eDebaoPlatformMainLogin
				self:debaoPlatformLoginRequest(username, password, eDebaoPlatformMainLogin, true, true)
				return
			end
		else
			local ck = jsonTable["ck"]..""
			if ck == "" then
				return
			end
			local now = os.time()
			UserDefaultSetting:getInstance():set500WANInfoTime(now)
			UserDefaultSetting:getInstance():set500WANToken(ck)
			self.m_pCallbackUI:showLoadingViewCallback(true)
            DBHttpRequest:debaoLoginForVersionControl(handler(self, self.httpResponse), ck, "", 
            	tencentValue:LoginIp(), "500WAN", currentVersion(), "","")
		end
	end
end

-- TODO delete, 貌似已弃用
function DebaoPlatformLogin:dealGetMyRushResp(strJson)
	local rushTableList = require("app.Logic.Datas.TableData.RushGetMyTableData"):new()
	if rushTableList:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		if rushTableList.rushPlayerTables and #rushTableList.rushPlayerTables>0 then
			local myRushId = rushTableList.rushPlayerTables[1]
            
			self.m_pCallbackUI:loginProgressCallback("")
			self.m_pCallbackUI:reconnectSuccessedCallback(myRushId,myInfo.data.userId,true)
            
			return
		end
	end
    
	self.m_pCallbackUI:loginProgressCallback("") --登录成功正在进入主界面
	self.m_pCallbackUI:loginSuccessedCallback()
end

function DebaoPlatformLogin:relogin()
	PlatformLogin.relogin(self)
	self:debaoPlatformLoginRequest(self.m_userName, self.m_password, self.m_loginType, true, true)
end

function DebaoPlatformLogin:DebaoLoginPre()
	self:getLoginCtrl()
end

function DebaoPlatformLogin:setTcpIpandPort()
	myInfo.data.Global_ProxyIp=""..g_ServerIP
	myInfo.data.Global_ProxyPort=""..g_ServerPort
end

function DebaoPlatformLogin:imLogin()
	if BRANCHES_VERSION == WIRELESS_91 then
		self.m_pCallbackUI:upgradeSuccessShowLoginCallback(eDebaoPlatformUnknow)
		return
	elseif BRANCHES_VERSION == ALIPAYOPEN then
		local data = self:getAlipayResult()
		if data ~= "" then
			self:onOpenAlipayCallback(data)
			return
		end
	end
	local lastLoginType = UserDefaultSetting:getInstance():getLastLoginType()
	if lastLoginType == "QQ" then
	
		local openid = UserDefaultSetting:getInstance():getTencentOpenId()
		local token = UserDefaultSetting:getInstance():getTencentToken()
		local bExpires = UserDefaultSetting:getInstance():getTencentExpires() +
        UserDefaultSetting:getInstance():getTencentInfoTime() <= os.time()
		if openid ~= "" and token ~= "" and not bExpires then
			myInfo.data.loginType = eDebaoPlatformQQLogin
			self:debaoPlatformLoginRequest(openid, token, eDebaoPlatformQQLogin, true, true)
		else
			self.m_pCallbackUI:upgradeSuccessShowLoginCallback(eDebaoPlatformQQLogin)
		end
	elseif lastLoginType == "TOURIST" then

	elseif lastLoginType == "DEBAO" then
		if (UserDefaultSetting:getInstance():getAutoLoginEnable()) then
			local name = UserDefaultSetting:getInstance():getDebaoLoginName()
			local password = UserDefaultSetting:getInstance():getDebaoLoginPassword()
			if (name ~= "" and password ~= "") then
			
				myInfo.data.loginType = eDebaoPlatformMainLogin
				self:debaoPlatformLoginRequest(name, password, eDebaoPlatformMainLogin, true, true)
				return
			end
		end
		self.m_pCallbackUI:upgradeSuccessShowLoginCallback(eDebaoPlatformMainLogin)
	elseif lastLoginType == "500WAN" then
		if (UserDefaultSetting:getInstance():getAutoLoginEnable()) then
			local name = UserDefaultSetting:getInstance():get500WANLoginName()
			local password = UserDefaultSetting:getInstance():get500WANLoginPassword()
			if (name ~= "" and password ~= "") then
			
				myInfo.data.loginType = eDebaoPlatform500wan
				self:debaoPlatformLoginRequest(name, password, eDebaoPlatform500wan, true, true)
				return
			end
		end
		self.m_pCallbackUI:upgradeSuccessShowLoginCallback(eDebaoPlatformMainLogin)
	else
		-- self.m_pCallbackUI:upgradeSuccessShowLoginCallback(eDebaoPlatformUnknow)
	end
end

function DebaoPlatformLogin:debaoUniqueUserRequest(wanname)
    local username=self.m_userName
    local password=self.m_password
  --   if self.m_loginType == eDebaoPlatformMainLogin then
  --       loginType="DEBAO"
  --   elseif self.m_loginType == eDebaoPlatformQQLogin then
  --           loginType="QQ"
		-- if device.platform == "android" then
  --       	username=UserDefaultSetting:getInstance():getTencentOpenId()
  --       	password=UserDefaultSetting:getInstance():getTencentToken()
		-- end
  --   elseif self.m_loginType == eDebaoPlatformTouristLogin then
  --       oginType="TOURIST"
  --   elseif self.m_loginType == eDebaoPlatform500wan then
  --       loginType="500WAN"
  --   elseif self.m_loginType == eDebaoPlatformPPS then
  --       loginType="PPS"
  --   elseif self.m_loginType == eDebaoPlatform91DPay then
  --       loginType="91"
  --   elseif self.m_loginType == eDebaoPlatformBaiduLogin then
  --       loginType="BAIDU"
  --   elseif self.m_loginType == eDebaoPlatformMeizuLogin then
  --       loginType="MEIZU"
  --   end

  	-- dump(MyInfo.data.platform,MyInfo.data.loginType)
    DBHttpRequest:debaoLoginForVersionControl(handler(self, self.httpResponse), username, password,
    	tencentValue:LoginIp(), GAllChannel[self.m_loginType], DBVersion,"","", wanname, m_sdk_sign)

end

function DebaoPlatformLogin:debaoForgetUsername( method, username, email,  mobile)
    DBHttpRequest:resetPassword(handler(self, self.httpResponse), method, username, email, mobile)
end

function DebaoPlatformLogin:debaoRegisterPC(username,password, sex)
    DBHttpRequest:registerPC(handler(self, self.httpResponse), username, password, sex, "")
end


function DebaoPlatformLogin:debaoRegisterRequest(username,password, sex)
    
    
    DBHttpRequest:quickRegister(handler(self, self.httpResponse), username, password, sex, tencentValue:LoginIp(), currentVersion(), "DEBAO")
end

function DebaoPlatformLogin:debaoPlatformLoginRequest(userName, password, loginType, bRemeberPassword, bAutoLogin, sign)
	-- normal_info_log("DebaoPlatformLogin:debaoPlatformLoginRequest")
	-- qq openid等  供调试用
	-- userName = "8A453067B6787F68004CE1C0B96057CE"
	-- password = "C77CFCBE066FD9B816C9E15501119DC5"
	-- loginType = 0
	if sign==nil or type(sign)~="string" then
		sign = ""
	end
   		self.m_userName = userName
   		self.m_password = password
   		self.m_loginType = loginType
		self.m_bRemeber = bRemeberPassword
		self.m_bAuto = bAutoLogin
		
		DBHttpRequest:debaoLoginForVersionControl(function(event) if self.httpResponse then self:httpResponse(event) end
   		end, userName, password, tencentValue:LoginIp(), GAllChannel[loginType], DBVersion, "","","")
   -- if loginType==eDebaoPlatformMainLogin then
   -- 		DBHttpRequest:debaoLoginForVersionControl(function(event) if self.httpResponse then self:httpResponse(event) end
   -- 			end, userName, password, tencentValue:LoginIp(), "DEBAO", DBVersion, "","","")
   --  elseif loginType==eDebaoPlatformTouristLogin then
   --  	userName = QManagerPlatform:getUniqueStr()
   --  	DBHttpRequest:debaoLoginForVersionControl(function(event) if self.httpResponse then self:httpResponse(event) end
   -- 			end, userName, password, tencentValue:LoginIp(), "TOURIST", DBVersion, "","" ,"")
   --  elseif loginType==eDebaoPlatformQQLogin then
   --  	DBHttpRequest:debaoLoginForVersionControl(function(event) self:httpResponse(event)
   -- 			end, userName, password, tencentValue:LoginIp(), "QQ", DBVersion, "","" ,"")
   --  elseif loginType==eDebaoPlatform500wan then
   --  	DBHttpRequest:debaoLoginForVersionControl(function(event) if self.httpResponse then self:httpResponse(event) end
   -- 			end, userName, password, tencentValue:LoginIp(), "500WAN", DBVersion, "","" ,"")
   --  elseif loginType==eDebaoPlatformBaiduLogin then 
   --  	DBHttpRequest:debaoLoginForVersionControl(function(event) self:httpResponse(event)
   -- 			end, userName, password, tencentValue:LoginIp(), "BAIDU", DBVersion, "","" ,"")
   --  elseif loginType==eDebaoPlatformMeizuLogin then 
   --  	DBHttpRequest:debaoLoginForVersionControl(function(event) self:httpResponse(event)
   -- 			end, userName, password, tencentValue:LoginIp(), "MEIZU", DBVersion, "","" ,"")

   --  end
end

function DebaoPlatformLogin:encryptionString(str)
	--require("crypto")
	local tmpCKey = "j%7lu9*#g5@z"
	return crypto.md5(str .. tmpCKey)
end

function DebaoPlatformLogin:connectSuccessEnterRoomOrMainpage()
	local loginType = ""
	if self.m_loginType == eDebaoPlatformMainLogin then
		loginType = "DEBAO"
		UserDefaultSetting:getInstance():setAutoLoginEnable(self.m_bAuto)
		UserDefaultSetting:getInstance():setDebaoLoginName(self.m_userName)
		UserDefaultSetting:getInstance():setDebaoLoginPassword(self.m_password)
	elseif self.m_loginType == eDebaoPlatformQQLogin then
		loginType = "QQ"
	elseif self.m_loginType == eDebaoPlatformTouristLogin then
		loginType = "TOURIST"
	elseif self.m_loginType == eDebaoPlatform500wan then
		loginType = "500WAN"
		UserDefaultSetting:getInstance():setAutoLoginEnable(self.m_bAuto)
		UserDefaultSetting:getInstance():set500WANLoginName(self.m_userName)
		UserDefaultSetting:getInstance():set500WANLoginPassword(self.m_password)
    elseif self.m_loginType == eDebaoPlatformPPS then
        loginType = "PPS"
    end
	UserDefaultSetting:getInstance():setLoginType(loginType)
end

function DebaoPlatformLogin:enterMainPage()
	self:connectSuccessEnterRoomOrMainpage()
	self.m_pCallbackUI:loginSuccessedCallback()
end

-- function DebaoPlatformLogin:dealLogin4VerisionResp(content)
-- 	local data = myInfo:getData(content)
-- 	m_Session = myInfo.data.phpSessionId
-- 	-- 解析成功
-- 	if data then
-- 		if data.code == "" then
--        	 	-- DBHttpRequest:setSession(myInfo->phpSessionId)
-- 			if self.tcpRequest:isConnect() then
-- 				self.m_pCallbackUI:showLoadingViewCallback(true)
-- 				self.tcpRequest:sendTencentInitPkg(myInfo.data.serverId, myInfo.data.Global_Openkey)
-- 				DBHttpRequest:getAccountInfo(function(event) self:httpResponse(event)end)
-- 				PushCommandRequest:getInstance()
--    			else
			
-- 			end

-- 		end
-- 	end
-- end

-- function DebaoPlatformLogin:OnTcpMessage(command, strJson)
-- 	normal_info_log("DebaoPlatformLogin:OnTcpMessage")
-- 	if command == COMMAND_CONNECT_RESP then
-- 		self:dealConnectSuccessResp(strJson)
-- 	elseif command == COMMAND_SOCKET_CONNECTION_BREAK then
-- 		self:dealNetBreakdown(strJson)
-- 	elseif command == COMMAND_PING_RESP then
-- 		return
-- 	elseif command == COMMAND_KICK_USER then
-- 		self:dealKickUser(strJson)
-- 	elseif command == COMMAND_RUSH_GET_PLAYER_RESP then
-- 		self:dealGetMyRushResp(strJson)
-- 	else
-- 	end
-- end

-- function DebaoPlatformLogin:dealConnectSuccessResp(strJson)
-- 	local m_code = strJson[CODE]
-- 	if m_code == "10000" then
-- 		self.tcpRequest:startPing()
-- 		TourneyGuideReceiver:sharedInstance():enableReceiver(true)
-- 		self:connectSuccessEnterRoomOrMainpage()
-- 	elseif m_code == "-10004" then
		
-- 	elseif m_code == "-10008" then
		
-- 	else
		
-- 	end
-- end

-- function DebaoPlatformLogin:dealNetBreakdown(strJson)
-- 	print("DebaoPlatformLogin:dealNetBreakdown")

-- end

-- function DebaoPlatformLogin:dealKickUser(strJson)
-- 	print("DebaoPlatformLogin:dealKickUser")

-- end

return DebaoPlatformLogin