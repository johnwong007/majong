local tencentValue = require("app.Logic.Config.tencentValue")
local LoginContract = require("app.architecture.login.LoginContract")
require("app.Logic.Config.UserDefaultSetting")
local myInfo = require("app.Model.Login.MyInfo")
require("app.architecture.net.HttpClient")
require("app.LangStringDefine")
require("app.Network.Socket.TcpCommandRequest")
require("app.Network.Socket.PushCommandRequest")
require("app.Logic.Room.TourneyGuideReceiver")
require("app.Network.ParseKeyValue")
require("app.Network.Http.DBHttpRequest")
require("app.architecture.global.GlobalConfig")

local g_tips = {"您正以游客身份登录游戏...","正在为您登录帐号"}

local LoginPresenter = class("LoginPresenter", function()
		return LoginContract.Presenter:new()
	end)

function LoginPresenter:ctor(o,params)
    self.m_sdk_sign = ""
	self.m_pLoginDataRepository = params.repository
	self.m_pLoginView = params.view
	self.m_pLoginView:setPresenter(self)
	-- HttpClient:setSession("")	--[[清空session]]
end

function LoginPresenter:start()
	self.m_pTcpRequest = TcpCommandRequest:shareInstance()
	self.m_pTcpRequest:addObserver(self)
	self:initLogin()
	return self
end

function LoginPresenter:socketConnected()
end

function LoginPresenter:onExit()
    self.m_pTcpRequest:removeObserver(self)
	if self.customEvt then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.customEvt)
		self.customEvt = nil
	end
end

function LoginPresenter:initLogin()
    myInfo.data.Global_Token = tencentValue.tencent_token
    myInfo.data.Global_Secret = tencentValue.tencent_secret
    myInfo.data.Global_Openkey = tencentValue.tencent_openkey
    myInfo.data.Global_Token = g_ServerIP
    myInfo.data.Global_ProxyPort = g_ServerPort
end

function LoginPresenter:switchLayer(tag)
	if tag==self.m_pLoginView.Layer.LoginDebao then
		self:getDebaoLoginInfo()
    elseif tag==self.m_pLoginView.Layer.Login500Wan then
		self:get500WanLoginInfo()
    end
end

function LoginPresenter:getDebaoLoginInfo()  		
	local rememberAccount = UserDefaultSetting:getInstance():getRemeberAccountEnable()
	local rememberPassword = UserDefaultSetting:getInstance():getRemeberPasswordEnable()
	self.m_pLoginView:setRememberAccount(rememberAccount)
	self.m_pLoginView:setRememberPassword(rememberPassword)

	if rememberAccount then
		self.m_pLoginView:setUsernameTextField(self:getDebaoLoginName())
		if rememberPassword then
			self.m_pLoginView:setPasswordTextField(self:getDebaoLoginPassword())
		end
	end
end

function LoginPresenter:get500WanLoginInfo()
	local rememberAccount = UserDefaultSetting:getInstance():get500RemeberAccountEnable()
	local rememberPassword = UserDefaultSetting:getInstance():get500RemeberPasswordEnable()
	self.m_pLoginView:setRememberAccount(rememberAccount)
	self.m_pLoginView:setRememberPassword(rememberPassword)

	if rememberAccount then
		self.m_pLoginView:setUsernameTextField(self:get500WANLoginName())
		if rememberPassword then
			self.m_pLoginView:setPasswordTextField(self:get500WANLoginPassword())
		end
	end
end

function LoginPresenter:getDebaoLoginName()
	return UserDefaultSetting:getInstance():getDebaoLoginName()
end

function LoginPresenter:getDebaoLoginPassword()
	return UserDefaultSetting:getInstance():getDebaoLoginPassword()
end

function LoginPresenter:get500WANLoginName()
	return UserDefaultSetting:getInstance():get500WANLoginName()
end

function LoginPresenter:get500WANLoginPassword()
    return UserDefaultSetting:getInstance():get500WANLoginPassword()
end

function LoginPresenter:majongLoginRequest(params)
	local tips = ""
    if params.loginType == eDebaoPlatformTouristLogin then
    	tips = g_tips[1]
    else
    	tips = g_tips[2]
    end
    
    self.m_pLoginView:showLoadingWithTips({
        tips = tips, 
        tipsBg = "picdata/public/slice01_01.png", 
        viewRect=cc.size(360,240), 
        scale9=true, 
        showTimes = 0.5,
        timeOutCallback = handler(self, self.loginTimeOut),
        })
	-- params = params or {}
	-- self.m_userName = params.userName
	-- self.m_password = params.password
	-- self.m_loginType = params.loginType
	-- self.m_bRemeberAccount = params.bRemeberAccount
	-- self.m_bRemeberPassword = params.bRemeberPassword
	-- HttpClient:debaoLoginForVersionControl({handler(self, self.dealLogin4VerisionResp),
	-- 	handler(self, function()
	-- 		self.m_pLoginView:loginProgressCallback()
	-- 		self.m_pLoginView:showLoadingViewCallback(false)
	-- 		end)}, self.m_userName, self.m_password, tencentValue:LoginIp(), GAllChannel[self.m_loginType], DBVersion, "","","")	
end

function LoginPresenter:loginTimeOut()
	self.m_pLoginView:loginTimeOut()
end

function LoginPresenter:dealLoginResp(jsonTable,tag)
	
end

function LoginPresenter:setTcpIpandPort()
	myInfo.data.Global_ProxyIp=tostring(g_ServerIP)
	myInfo.data.Global_ProxyPort=tostring(g_ServerPort)
end

function LoginPresenter:OnTcpMessage(command, strJson)
	if command == COMMAND_CONNECT_RESP then
	elseif command == COMMAND_SOCKET_CONNECTION_BREAK then 
	elseif command == COMMAND_PING_RESP then
	elseif command == COMMAND_KICK_USER then
	elseif command == COMMAND_RUSH_GET_PLAYER_RESP then	
	end
end

function LoginPresenter:dealGetServerPort(jsonTable,tag)
	myInfo:setServerPort(tonumber(jsonTable))
	self.m_pLoginView:loginProgressCallback("")
    self.m_pLoginView:showLoadingViewCallback(false)
	self.m_pLoginView:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, Lang_LOGIN_TIMEOUT)
end
--Tcp Resp
function LoginPresenter:dealConnectSuccessResp(strJson)
	local data = require("app.Logic.Datas.Lobby.ConnectRespData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_FAILED then
		self.m_pLoginView:loginProgressCallback("")--请求数据出错
		self.m_errorCode = LOGIN_REQUES_ERRORCODE
		self.m_errorMsg = Lang_LOGIN_ERROR_PROMPT
		self.m_pTcpRequest:closeConnect()
		data = nil
		return
	end
	local code = 10000	
    
	if code==10000 then
		self.m_pTcpRequest:startPing()
		TourneyGuideReceiver:sharedInstance():enableReceiver(true)
		self:connectSuccessEnterRoomOrMainpage()
		-- 获取个人信息后进入主页面
		self.m_pLoginView:updateProgressTimer(1, 90)
    	HttpClient:getUserShowInfo({handler(self,self.dealGetUserShowInfoResp), function(errorCode, tag)
    		self.m_pLoginView:setTips(5)
    		self.m_pLoginView:updateProgressTimer(0, 100)
    		-- self.m_pLoginView:loginSuccessedCallback()	
    	end},myInfo.data.userId)
    else
		self.m_pLoginView:loginProgressCallback("")--登录失败
		self.m_errorCode = LOGIN_TIMEOUT_ERRORCODE
		self.m_errorMsg = Lang_LOGIN_ERROR_PROMPT..data.m_code
		self.m_pTcpRequest:closeConnect()
	end
	data = nil
end

function LoginPresenter:connectSuccessEnterRoomOrMainpage()
	local loginType = ""
	if self.m_loginType == eDebaoPlatformMainLogin then
		loginType = "DEBAO"
		UserDefaultSetting:getInstance():setRemeberAccountEnable(self.m_bRemeberAccount)
		UserDefaultSetting:getInstance():setRemeberPasswordEnable(self.m_bRemeberPassword)
		UserDefaultSetting:getInstance():setDebaoLoginName(self.m_userName)
		UserDefaultSetting:getInstance():setDebaoLoginPassword(self.m_password)
	elseif self.m_loginType == eDebaoPlatformQQLogin then
		loginType = "QQ"
	elseif self.m_loginType == eDebaoPlatformTouristLogin then
		loginType = "TOURIST"
	elseif self.m_loginType == eDebaoPlatform500wan then
		loginType = "500WAN"
		UserDefaultSetting:getInstance():set500RemeberAccountEnable(self.m_bRemeberAccount)
		UserDefaultSetting:getInstance():set500RemeberPasswordEnable(self.m_bRemeberPassword)
		UserDefaultSetting:getInstance():set500WANLoginName(self.m_userName)
		UserDefaultSetting:getInstance():set500WANLoginPassword(self.m_password)
    elseif self.m_loginType == eDebaoPlatformPPS then
        loginType = "PPS"
    end
	UserDefaultSetting:getInstance():setLoginType(loginType)
end

--------------------------------------------------------------------------------------------------------------

return LoginPresenter