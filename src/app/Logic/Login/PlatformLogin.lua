local myInfo = require("app.Model.Login.MyInfo")
require("app.LangStringDefine")
require("app.Network.Socket.TcpCommandRequest")
--[[更新类型(-1校验失败，0不需要升级，1强制升级，2可选升级）]]
CHECK_ERROR = -1
NO_UPGRADE  = 0
MANDATORY_UPGRADE = 1
OPTIONAL_UPGRADE = 2

local s_bChechedVersion = false
local s_applePayUserId = "s_applePayUserId"
local s_applePayUserName = "s_applePayUserName"
local s_applePayEncodeJson = "s_applePayEncodeJson"
local s_applePayOrderId = "s_applePayOrderId"
local s_applePaytrans = "s_applePaytrans"

local PlatformLogin = class("PlatformLogin", function()
		return display.newNode()
	end)

function PlatformLogin:ctor()
	
	self.tcpRequest = TcpCommandRequest:shareInstance()
	self.tcpRequest:addObserver(self)
	self.m_errorCode = SOCKET_LINK_ERRORCODE
	self.m_errorMsg = Lang_LOGIN_ERROR_PROMPT
    
	self.m_pCallbackUI = nil
	self.m_upgradeURL = ""

    local fixedPriority = 1
 	self.customEvt = cc.EventListenerCustom:create("SOCKET_TCP_CONNECTED", handler(self, self.socketConnected))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.customEvt, fixedPriority)
 	self.customEvt1 = cc.EventListenerCustom:create("SOCKET_TCP_CONNECT_FAILURE", handler(self, self.socketConnectFailure))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.customEvt1, fixedPriority)
end

function PlatformLogin:socketConnected()
		if self.m_pCallbackUI then
			self.m_pCallbackUI:showLoadingViewCallback(true)
		end
        -- 获取个人信息后进入主页面
        DBHttpRequest:getUserShowInfo({handler(self,self.dealGetUserShowInfoResp), function(errorCode, tag)
        		self:enterMainPage()
        	end},myInfo.data.userId)
end

function PlatformLogin:socketConnectFailure()

	--normal_info_log("socket cannot connected!!")
	if(not self.m_pCallbackUI) then
		return
	end
	self.m_pCallbackUI:loginProgressCallback("")--网络连接不上
	--self.m_pCallbackUI:loginFailedCallback(NO_INTERNET_CONNECTED,Lang_NO_NETWORK)--网络连接不上
end

function PlatformLogin:setChild(child)
	-- self.m_child = child
end

function PlatformLogin:onNodeEvent(event)
    if event == "exit" then
    	self:onExit()
    end
end

function PlatformLogin:onExit()
    self.tcpRequest:removeObserver(self)
	if self.customEvt then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.customEvt)
		self.customEvt = nil
	end
	if self.customEvt1 then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.customEvt1)
		self.customEvt1 = nil
	end
end

function PlatformLogin:setLogicCallback(callback)
	self.m_pCallbackUI = callback
end

function PlatformLogin:relogin()

	if(self.tcpRequest:isConnect()) then
		self.tcpRequest:closeConnect()
	end
    
	if(PushCommandRequest:shareInstance():isConnect()) then
		PushCommandRequest:shareInstance():closeConnect()
	end
end

function PlatformLogin:restoreApplePay(userId, userName, receipt, innerOrderId, transactionIdentifier)
	local data = UserDefaultSetting:getInstance():getApplePayData()	
	if data and data.userId == myInfo.data.userId then
		DBHttpRequest:ApplePaySuccessCallback(function(tag,tableData) self:onHttpResponse(tag,tableData) end,data.userId,data.userName,data.encodeJson,data.orderId,data.transactionIdentifier)
	end
end

function PlatformLogin:reportBtnClick(data)

	if (UserDefaultSetting:shareInstance():getChannelReportSwitch()==1) then
	
		if (UserDefaultSetting:shareInstance():getRefreshReportSwitch()==0) then
		
			DBHttpRequest:reportBtnClick(handler(self,self.httpResponse),"http:--www.debao.com/index.php?act=ajax&mod=report",data)
            
		elseif(UserDefaultSetting:shareInstance():getRefreshReportSwitch()==1
                 and UserDefaultSetting:shareInstance():getRepeatReportFlag()==0) then
            
			DBHttpRequest:reportBtnClick(handler(self,self.httpResponse),"http:--www.debao.com/index.php?act=ajax&mod=report",data)
			UserDefaultSetting:shareInstance():setRepeatReportFlag(1)
		end
		
	end
end

function PlatformLogin:platformLoginRequest(userName, password)

	DBHttpRequest:login(handler(self,self.httpResponse),userName, password,currentVersion(),device.platform == "windows")
end
function PlatformLogin:foldMatch(tableId)

	self.tcpRequest:quitTourney(tableId, myInfo.data.userId)
end
function PlatformLogin:imLogin()

	return
end
function PlatformLogin:upgrade()

    --	NativeJNI:openUpgrade_JNI(self.m_upgradeURL)
	self.m_pCallbackUI:upgradeJNI_Callback(self.m_upgradeURL)
end
function PlatformLogin:DebaoLoginPre()

	return
end
function PlatformLogin:checkVersion()

	if (s_bChechedVersion) then
		self:imLogin()
	else
	
		local upgradeType = OPTIONAL_UPGRADE..""
		DBHttpRequest:checkUpgrade(handler(self,self.httpResponse),currentVersion(), upgradeType)
	end
end
function PlatformLogin:getLoginCtrl()

	--DBHttpRequest:getLoginCtr(handler(self,self.httpResponse))
end

function PlatformLogin:getLoginConfig()

	--DBHttpRequest:getLoginConfig(handler(self,self.httpResponse), currentVersion())
end

function PlatformLogin:getChannelReportSwitch()

	DBHttpRequest:getChannelReportSwitch(handler(self,self.httpResponse))
end

function PlatformLogin:getRefreshReportSwitch()

	DBHttpRequest:getRefreshReportSwitch(handler(self,self.httpResponse))
end

--Tcp Resp
function PlatformLogin:dealConnectSuccessResp(strJson)
	if(not self.m_pCallbackUI) then
		return
    end

	local data = require("app.Logic.Datas.Lobby.ConnectRespData"):new()
	if (data:parseJson(strJson)==BIZ_PARS_JSON_FAILED) then
	
		self.m_pCallbackUI:loginProgressCallback("")--请求数据出错
		--self.m_pCallbackUI:loginFailedCallback(LOGIN_REQUES_ERRORCODE,Lang_LOGIN_ERROR_PROMPT)--请求数据出错
		self.m_errorCode = LOGIN_REQUES_ERRORCODE
		self.m_errorMsg = Lang_LOGIN_ERROR_PROMPT
		self.tcpRequest:closeConnect()
		data = nil
		return
	end
	local code = data.m_code+0	
    
	if code==10000 then
		self.tcpRequest:startPing()
		TourneyGuideReceiver:sharedInstance():enableReceiver(true)
		self:connectSuccessEnterRoomOrMainpage()
		QManagerPlatform:submitPlayerInfo()
		-- GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
	elseif code==-10004 then
		self.m_pCallbackUI:loginProgressCallback("")--登录失败
		self.m_errorCode = LOGIN_ACCOUNTISLOGINED_ERRORCODE
		self.m_errorMsg = Lang_ACCOUNT_ERROR
		self.tcpRequest:closeConnect()
	elseif code==-10008 then--超过服务器可连接总数,直接重连
        self.m_pCallbackUI:loginProgressCallback("")--登录失败
        self.m_errorCode = LOGIN_ACCOUNTISLOGINED_ERRORCODE
        self.m_errorMsg = Lang_SERVER_ERROR
        self.tcpRequest:closeConnect()
    else
		self.m_pCallbackUI:loginProgressCallback("")--登录失败
		self.m_errorCode = LOGIN_TIMEOUT_ERRORCODE
		self.m_errorMsg = Lang_LOGIN_ERROR_PROMPT..data.m_code
		self.tcpRequest:closeConnect()
	end
	data = nil
end

-- function PlatformLogin:connectSuccessEnterRoomOrMainpage()

-- 	local userTablelist = myInfo.data.userTableList
-- 	if (#userTablelist.listUser>0) then --目前只重连了最后一个房间
	
-- 		if (userTablelist.listUser[#userTablelist.listUser].tabletype == "TOURNEY") then
		
-- 			-- 锦标赛
-- 			DBHttpRequest:getTableInfo(handler(self,self.httpResponse),"TOURNEY", userTablelist.listUser[#userTablelist.listUser].tableId, true)
		
-- 		else
		
-- 			self.m_pCallbackUI:loginProgressCallback("")--正在进入房间
-- 			self.m_pCallbackUI:reconnectSuccessedCallback(
--                                                       userTablelist.listUser[#userTablelist.listUser].tableId,
--                                                       myInfo.data.userId)
-- 		end
	
-- 	else
-- 		self.m_pCallbackUI:loginProgressCallback("")--登录成功正在进入主界面
-- 		self.m_pCallbackUI:loginSuccessedCallback()
-- 	end
-- end
function PlatformLogin:dealNetBreakdown(strJson)

	self.tcpRequest:stopPing()
	PushCommandRequest:shareInstance():stopPing()
	DBHttpRequest:getServerPort(handler(self,self.httpResponse),myInfo:getServerPort(),currentVersion())--请求更新serverPort
end
function PlatformLogin:dealGetMyRushResp(strJson)

    
end



function PlatformLogin:dealGetUserTableList(strJson)

end

function PlatformLogin:dealGetAccountInfo(strJson)
	-- normal_info_log("PlatformLogin:dealGetAccountInfo")

	local data = require("app.Logic.Datas.Account.AccountInfo"):new()
	if( data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
		myInfo.data.totalChips = data.silverBalance
		myInfo.data.diamondBalance = data.diamondBalance
        DBHttpRequest:getUserTableList(handler(self,self.httpResponse))
	end
	data = nil
end

function PlatformLogin:dealGetLoginCtrl(strJson)

	local data = require("app.Logic.Datas.Account.GetLoginControl"):new()
	if(data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and data.code=="") then
	
        self:checkVersion()
	
	else
	
		self.m_pCallbackUI:loginFailedCallback(NO_INTERNET_CONNECTED,Lang_NO_NETWORK)--网络连接不上
	end
	data = nil
	
end

function PlatformLogin:dealGetLoginConfig(strJson)

	local info = require("app.Logic.Datas.Others.GetLoginConfig"):new()
	if(info:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and
       info.code=="") then
	
		local splashPath = ""
        
		if(info.updateUrl ~= "") then
		
			self.m_upgradeURL = info.updateUrl
			if (info.bForceUpdate) then
			
				self:upgrade()
			
			else
			
				s_bChechedVersion = true
				if(self.m_pCallbackUI) then
					self.m_pCallbackUI:loginConfig_Callback(info.versionDesc, splashPath)
				end
			end
		
		elseif (info.splashUrl ~= "") then
		
			local urlSplit = nil			
			mysplit(info.splashUrl, "/", urlSplit)
			local fileName = urlSplit[#urlSplit]
			local resPath = cc.FileUtils:getInstance():getWritablePath()
			local filePath = resPath..fileName
			sprintf(filePath,"%s%s",resPath,fileName)
            
			local file = io.open(filePath,"r")
            
			if (not file) then
			
				local dictionary = {}
				dictionary["url"] = info.splashUrl
				dictionary["fileName"] = fileName
				-- PerformTool* tool = new PerformTool()
				-- tool:performMainThread(dictionary, eDownloadFileBackground)
			
			else
			
				io.close(file)
				splashPath = filePath
				if(self.m_pCallbackUI) then
					self.m_pCallbackUI:loginConfig_Callback("", splashPath)
				end
			end
		
		else
		
			--self:imLogin()()
		end
		
	
	else
	
		self.m_pCallbackUI:loginFailedCallback(NO_INTERNET_CONNECTED,Lang_NO_NETWORK)--网络连接不上
	end
	info = nil
end



function PlatformLogin:dealGetUnicomReportSwitch(strJson)

    
	normal_info_log("============= strJson "..strJson)
	normal_info_log("============report switch "..strJson)
    
	UserDefaultSetting:getInstance():setChannelReportSwitch(strJson+0)
end

function PlatformLogin:dealRefreshReportSwitch(strJson)

	normal_info_log("============= strJson "..strJson)
	normal_info_log("============report switch "..strJson)
    
	UserDefaultSetting:getInstance():setRefreshReportSwitch(strJson+0)
end

function PlatformLogin:dealReportBtnClick(strJson)

    
	normal_info_log("============= strJson "..strJson)
	
end

function PlatformLogin:setTcpIpandPort()

	if (SERVER_ENVIROMENT == ENVIROMENT_NORMAL) then
		myInfo.data.Global_ProxyPort=myInfo:getServerPort()..""
	else
		myInfo.data.Global_ProxyIp=g_ServerIP
		myInfo.data.Global_ProxyPort=g_ServerPort..""
	end
end
--Http Resp
function PlatformLogin:dealLoginResp(strJson)

    if(not self.m_pCallbackUI) then
    	return
    end
    
    if( myInfo:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and	myInfo.data.code == "") then
    
        if (myInfo.data.responseCode == -10006) then 
            local errorMsg ="您的游戏版本过低,点击确认后将跳转升级."
            self.m_pCallbackUI:loginProgressCallback(errorMsg)
            
            self.m_pCallbackUI:loginFailedCallback(NEED_TO_UPDATE,errorMsg)
        else
            DBHttpRequest:setSession(myInfo.data.phpSessionId)
            self:setTcpIpandPort()
            normal_info_log("Server IP: "..myInfo.data.Global_ProxyIp)
            normal_info_log("Server PORT: "..myInfo.data.Global_ProxyPort)
				local proxyIp = string.gsub(myInfo.data.Global_ProxyIp,"http://","")
				myInfo.data.Global_ProxyIp = proxyIp
				self.tcpRequest:connectSocket(proxyIp , myInfo.data.Global_ProxyPort)
	            if self.tcpRequest:isConnect() then
            
                self.m_pCallbackUI:showLoadingViewCallback(true)
                self.tcpRequest:sendTencentInitPkg(myInfo.data.serverId,myInfo.data.Global_Openkey)
                local pushConn = false
				if (SERVER_ENVIROMENT == ENVIROMENT_NORMAL) then
                	pushConn = PushCommandRequest:shareInstance():connectSocket(proxyIp, myInfo.data.pushServerPort)
				else
                	pushConn = PushCommandRequest:shareInstance():connectSocket(g_PushServerIP, g_PushServerPort)
				end
                if(pushConn) then
                    PushCommandRequest:shareInstance():reportUserID(myInfo.data.userId,currentVersion())
                    PushCommandRequest:shareInstance():startPing()
                end
            
            else
            
                normal_info_log("socket cannot connected!!")
                if(not self.m_pCallbackUI) then
                	return
                end
                self.m_pCallbackUI:loginProgressCallback("")--网络连接不上
                self.m_pCallbackUI:loginFailedCallback(NO_INTERNET_CONNECTED,Lang_NO_NETWORK)--网络连接不上
            end
        end
    
    elseif(myInfo.data.code == "-10007") then--服务器维护中.
    
        local errorMsg = Lang_SERVER_IS_UPDATING..strJson--登录出错
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
    
    elseif (myInfo.data.code == "-1" or myInfo.data.code =="1") then
    
        --用户名密码错误
        local errorMsg = Lang_LOGIN_USERNAMEORPASSWORD_ERROR
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
    
    elseif(myInfo.data.code == "-12002") then -- 用户唯一性 500wan 用户 修改用户名
    
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:showUniqueUserDialog()
        
    elseif (myInfo.data.code == "-12016") then--用户不存在
        if (myInfo.data.loginType == eDebaoPlatformMainLogin) then 
            local errorMsg = "用户帐号或者密码错误"..myInfo.data.code
            self.m_pCallbackUI:loginProgressCallback(errorMsg)
            self.m_pCallbackUI:showLoadingViewCallback(false)
            self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
        else
            --用户不存在  设置昵称 注册一个帐号
            self.m_pCallbackUI:showLoadingViewCallback(false)
            self.m_pCallbackUI:showUniqueUserDialog()
        end
        
    elseif (myInfo.data.code == "-400") then --用户名或者密码错误
        
        local errorMsg = "用户名或者密码错误"..myInfo.data.code
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
    elseif (myInfo.data.code == "-13007") then
        local errorMsg = Lang_USER_IS_LOCK..strJson--登录出错
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
    else
    
        local errorMsg = Lang_LOGIN_ERROR_PROMPT..strJson--登录出错
        if string.utf8len(strJson)>200 then 
            errorMsg = Lang_NETWORK_NEED_AUTH
        end
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
    end
end

function PlatformLogin:dealCheckUpgrade(strJson)

	local data = require("app.Logic.Datas.Upgrade.Upgrade"):new()
	if(data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS) then
	
		if(data.m_isUpgrade) then
		
			self.m_upgradeURL = data.m_upgradeUrl
			if(data.m_upgradeType==MANDATORY_UPGRADE) then
			
				self:upgrade()
			
			else
			
				s_bChechedVersion = true
				if(self.m_pCallbackUI) then
					self.m_pCallbackUI:upgradePrompt(data.m_upgradeType, data.m_versionDesc)
				end
			end
		
		else
		
			s_bChechedVersion = true
		end
	end
	data = nil
end
function PlatformLogin:dealGetServerId(strJson)

	local data = require("app.Logic.Datas.Upgrade.GetServerId"):new()
	if(data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS) then
	
		myInfo.data.serverId = data.serverId
	end
	data = nil
    
	if(not self.m_pCallbackUI) then
		return
	end
	self.m_pCallbackUI:loginFailedCallback(self.m_errorCode,self.m_errorMsg)--网络断开连接
end
function PlatformLogin:dealGetServerPort(strJson)

	myInfo:setServerPort(strJson+0)
    
	if(not self.m_pCallbackUI) then
		return
	end
	self.m_pCallbackUI:loginFailedCallback(self.m_errorCode,self.m_errorMsg)--网络断开连接
end

function PlatformLogin:dealGetTableInfo(strJson)

	local info = require("app.Logic.Datas.Lobby.TourneyTableInfo"):new()
	if (info:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS and info.code=="") then
	
		self.m_pCallbackUI:alertEnterTourneyRoomCallback(info.matchName, info.tableId)
	
	else
	
		self.m_pCallbackUI:loginSuccessedCallback()
	end
	
   	info = nil
end
function PlatformLogin:dealSignBind500(strJson)

    
	--跟 esun Login处理方式一样
    
	if(not self.m_pCallbackUI) then
		return
    end
	if( myInfo:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and	myInfo.data.code == "") then
	
		DBHttpRequest:setSession(myInfo.data.phpSessionId)
        
		self:setTcpIpandPort()
        
		normal_info_log("Server IP:%s"..myInfo.data.Global_ProxyIp)
		normal_info_log("Server PORT:%s"..myInfo.data.Global_ProxyPort)
		-- self.tcpRequest:connectSocket(myInfo.data.Global_ProxyIp , myInfo.data.Global_ProxyPort+0)
        if self.tcpRequest:isConnect() then
		
			self.m_pCallbackUI:showLoadingViewCallback(true)
			local proxyIp = string.gsub(myInfo.data.Global_ProxyIp,"http://","")
			 myInfo.data.Global_ProxyIp = proxyIp
				self.tcpRequest:connectSocket(proxyIp , myInfo.data.Global_ProxyPort)			
			local pushConn = false
			if (SERVER_ENVIROMENT == ENVIROMENT_NORMAL) then
				pushConn = PushCommandRequest:shareInstance():connectSocket(proxyIp, myInfo.data.pushServerPort)
			else
				pushConn = PushCommandRequest:shareInstance():connectSocket(g_PushServerIP, g_PushServerPort)
			end
			if(pushConn) then
				PushCommandRequest:shareInstance():reportUserID(myInfo.data.userId,currentVersion())
				PushCommandRequest:shareInstance():startPing()
			end
		
		else
		
			normal_info_log("socket cannot connected!!")
			if(not self.m_pCallbackUI) then
				return
			end
			self.m_pCallbackUI:loginProgressCallback("")--网络连接不上
			self.m_pCallbackUI:loginFailedCallback(NO_INTERNET_CONNECTED,Lang_NO_NETWORK)--网络连接不上
		end
	
	elseif(myInfo.data.code == "-10007") then--服务器维护中.
	
		local errorMsg = Lang_SERVER_IS_UPDATING..strJson--登录出错
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
	
	elseif (myInfo.data.code == "-1") then
	
		--用户名密码错误
		local errorMsg = Lang_LOGIN_USERNAMEORPASSWORD_ERROR
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
	
	elseif(myInfo.data.code == "-12002") then -- 用户唯一性 500wan 用户 修改用户名
	
		self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:showUniqueUserDialog()
	
	else
	
		local errorMsg = Lang_LOGIN_ERROR_PROMPT..strJson--登录出错
        if (string.len(strJson)>200) then
            errorMsg = Lang_NETWORK_NEED_AUTH
        end
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
	end
    
    
end

function PlatformLogin:OnTcpMessage(command, strJson)
	 -- dump("PlatformLogin:OnTcpMessage")
	if command == COMMAND_CONNECT_RESP then
		self:dealConnectSuccessResp(strJson)
	elseif command == COMMAND_SOCKET_CONNECTION_BREAK then 
		self:dealNetBreakdown(strJson)
	elseif command == COMMAND_PING_RESP then 
		
	elseif command == COMMAND_KICK_USER then 
		-- self:dealKickUser(strJson)
	elseif command == COMMAND_RUSH_GET_PLAYER_RESP then 
		self:dealGetMyRushResp(strJson)
	end
end

function PlatformLogin:dealLogin4VerisionResp(strJson)
	-- dump("PlatformLogin:dealLogin4VerisionResp",strJson)
	if not self.m_pCallbackUI then
		return
    end
    if myInfo:parseJson(strJson)==BIZ_PARS_JSON_FAILED then
    	local errorMsg = "登录失败,解析请求数据出错" 
    	-- self.m_pCallbackUI:loginProgressCallback(errorMsg)
    	self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)

    	return
    end
 -- dump(strJson)
	if(myInfo.data.code == "") then
		if (myInfo.data.responseCode == -10006) then
            local errorMsg ="您的游戏版本过低,点击确认后将跳转升级."
			self.m_pCallbackUI:loginProgressCallback(errorMsg)
            
			self.m_pCallbackUI:loginFailedCallback(NEED_TO_UPDATE,errorMsg)
		else
			DBHttpRequest:setSession(myInfo.data.phpSessionId)
			self:setTcpIpandPort()

			local proxyIp = string.gsub(myInfo.data.Global_ProxyIp,"http://","")
			myInfo.data.Global_ProxyIp = proxyIp
			self.tcpRequest:connectSocket(proxyIp , myInfo.data.Global_ProxyPort)

            
		end
        
	
	elseif(myInfo.data.code == "-10007") then--服务器维护中.
	
		local errorMsg = Lang_SERVER_IS_UPDATING..strJson--登录出错
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
	
	elseif (myInfo.data.code == "-1" or myInfo.data.code =="1") then
		 
		--用户名密码错误
		local errorMsg = Lang_LOGIN_USERNAMEORPASSWORD_ERROR
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
	
	elseif(myInfo.data.code == "-12002") then -- 用户唯一性 500wan 用户 修改用户名
		local CMToolTipView = require("app.Component.CMToolTipView")
         CMOpen(CMToolTipView,self.m_pCallbackUI,{text = "昵称已存在,请重新输入",isSuc = false})
		self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:showUniqueUserDialog()
        
	elseif (myInfo.data.code == "-12016") then--用户不存在
        if (myInfo.data.loginType == eDebaoPlatformMainLogin) then
            local errorMsg = "用户帐号或者密码错误"..myInfo.data.code
            self.m_pCallbackUI:loginProgressCallback(errorMsg)
            self.m_pCallbackUI:showLoadingViewCallback(false)
            self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
        else
            --用户不存在  设置昵称 注册一个帐号
           local CMToolTipView = require("app.Component.CMToolTipView")
           CMOpen(CMToolTipView,self.m_pCallbackUI,{text = "设置新的昵称",isSuc = false})
           self.m_pCallbackUI:showLoadingViewCallback(false)
           self.m_pCallbackUI:showUniqueUserDialog()       
        end
        
    elseif (myInfo.data.code == "-400") then--用户名或者密码错误
        
        local errorMsg = "用户名或者密码错误"..myInfo.data.code
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
    elseif(myInfo.data.code == "-403") then
        local errorMsg = "用户名未激活,请先进行激活"..myInfo.data.code
        DBHttpRequest:setSession(myInfo.data.phpSessionId)
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(NEED_VERIFY_ERROR, errorMsg)
    elseif (myInfo.data.code == "-13007") then
        local errorMsg = Lang_USER_IS_LOCK..strJson--登录出错
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
    else
		local errorMsg = Lang_LOGIN_ERROR_PROMPT..strJson--登录出错
        if (string.len(strJson)>200) then
            errorMsg = Lang_NETWORK_NEED_AUTH
        end
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
	end
    
end

function PlatformLogin:dealESunLoginResp(strJson)
	if(not self.m_pCallbackUI) then
		return
    end

	if( myInfo:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and	myInfo.data.code == "") then
	
		DBHttpRequest:setSession(myInfo.data.phpSessionId)
        
		self:setTcpIpandPort()
        
		normal_info_log("Server IP:%s"..myInfo.data.Global_ProxyIp)
		normal_info_log("Server PORT:%s"..myInfo.data.Global_ProxyPort)
		local proxyIp = string.gsub(myInfo.data.Global_ProxyIp,"http://","")
		myInfo.data.Global_ProxyIp = proxyIp
		if(self.tcpRequest:connectSocket(proxyIp , myInfo.data.Global_ProxyPort)) then
		
			self.m_pCallbackUI:showLoadingViewCallback(true)
			self.tcpRequest:sendTencentInitPkg(myInfo.data.serverId,myInfo.data.Global_Openkey)
			local pushConn = false
			if (SERVER_ENVIROMENT == ENVIROMENT_NORMAL) then
				pushConn = PushCommandRequest:shareInstance():connectSocket(proxyIp, myInfo.data.pushServerPort)
			else
				pushConn = PushCommandRequest:shareInstance():connectSocket(g_PushServerIP, g_PushServerPort)
			end
			if(pushConn) then
				PushCommandRequest:shareInstance():reportUserID(myInfo.data.userId,currentVersion())
				PushCommandRequest:shareInstance():startPing()
			end
		
		else
		
			normal_info_log("socket cannot connected!!")
			if(not self.m_pCallbackUI) then 
				return
			end
			self.m_pCallbackUI:loginProgressCallback("")--网络连接不上
            self.m_pCallbackUI:showLoadingViewCallback(false)
			self.m_pCallbackUI:loginFailedCallback(NO_INTERNET_CONNECTED,Lang_NO_NETWORK)--网络连接不上
		end
	
	elseif(myInfo.data.code == "-10007") then--服务器维护中.
	
		local errorMsg = Lang_SERVER_IS_UPDATING..strJson--登录出错
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
	
	elseif (myInfo.data.code == "-1") then
	
		--用户名密码错误
		local errorMsg = Lang_LOGIN_USERNAMEORPASSWORD_ERROR
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE, errorMsg)
	
	elseif(myInfo.data.code == "-12002") then -- 用户唯一性 500wan 用户 修改用户名
	
		self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:showUniqueUserDialog()
        
    elseif (myInfo.data.code == "-13007") then
        local errorMsg = Lang_USER_IS_LOCK..strJson--登录出错
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
        self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
        
    elseif (myInfo.data.code == "-400") then--用户名或者密码错误
            local errorMsg = "用户名或密码错误"..myInfo.data.code
            self.m_pCallbackUI:loginProgressCallback(errorMsg)
            self.m_pCallbackUI:showLoadingViewCallback(false)
            self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
    else
	
		local errorMsg = Lang_LOGIN_ERROR_PROMPT..strJson--登录出错
        if (string.len(strJson)>200) then
            errorMsg = Lang_NETWORK_NEED_AUTH
        end
		self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:showLoadingViewCallback(false)
		self.m_pCallbackUI:loginFailedCallback(LOGIN_ACCOUNT_ERRORCODE,errorMsg)
	end
end


function PlatformLogin:dealQuickRegister(strJson)
    self.m_pCallbackUI:showLoadingViewCallback(false)
    local info = require("app.Logic.Datas.Account.RegisterRespInfo"):new()
    if (info:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
        if (info.responseCode==10000) then
            --            成功 使用账号登录
            self.m_pCallbackUI:registerCallback()
        else
            local errorMsg = info.description--登录出错
            self.m_pCallbackUI:loginProgressCallback(errorMsg)
            self.m_pCallbackUI:loginFailedCallback(REGISTER_ERROR,errorMsg)
        end
    else
        local errorMsg ="注册出错，请检查网络设置。如还有问题请联系客服"--登录出错
        self.m_pCallbackUI:loginProgressCallback(errorMsg)
        self.m_pCallbackUI:loginFailedCallback(REGISTER_ERROR,errorMsg)
        
    end
end

function PlatformLogin:dealApplePayNotifyServerResp(tableData)
	local tips = ""
	tableData = -3
	if tableData == 1 then
		local orderId    = cc.UserDefault:getInstance():getStringForKey(s_applePayOrderId)
		QManagerPlatform:onChargeSuccess(orderId)
		UserDefaultSetting:getInstance():setApplePayData()
		tips = "已成功补单"
	elseif tableData == -3 then
		local data = UserDefaultSetting:getInstance():getApplePayData()
		if data and data.times < 3 then
			cc.UserDefault:getInstance():setIntegerForKey(s_applePayTimes,data.times + 1)
			DBHttpRequest:ApplePaySuccessCallback(function(tag,tableData) self:onHttpResponse(tag,tableData) end,data.userId,data.userName,data.encodeJson,data.orderId,data.transactionIdentifier)
		end
		tips = "对不起，购买过程发生错误，将重新请求发货，请稍候"
	else
	    tips = "对不起，购买过程发生错误，请联系客服人员"                    	
	end 
	local AlertDialog = require("app.Component.CMAlertDialog").new({text = tips})
	CMOpen(AlertDialog,self)
end
function PlatformLogin:dealResetPassword(strJson)
    local resCode = strJson+0
    local info = ""
    if resCode==1 then
        info = "新密码已成功以信息形式发送到您绑定的邮箱/手机号，请注意查收。若接收有误，可在1分钟后重新尝试重置密码。"..strJson
    elseif resCode==-1 then
        info = "系统参数错误" .. strJson
    elseif resCode==-2 then
        info = "用户名错误" .. strJson
    elseif resCode==-3 then
        info = "Email错误" .. strJson
    elseif resCode==-4 then
        info = "手机号码错误" .. strJson
    elseif resCode==-5 then
        info = "短时间内重置次数超过5次" .. strJson
    elseif resCode==-6 then
        info = "用户信息不存在" .. strJson
    elseif resCode==-7 then
        info = "所用邮箱或手机与用户绑定的信息不符" .. strJson
    elseif resCode==-8 then
        info = "发送邮件失败" .. strJson
    elseif resCode==-9 then
        info = "发送手机短信失败" .. strJson
    elseif resCode==-10 then
        info = "发送手机短信失败" .. strJson
    else
        info="发送手机短信失败,系统错误"..strJson
    end
    self.m_pCallbackUI:resetPasswordCallback(info)
end

function PlatformLogin:dealGetUserShowInfoResp(strJson,tag)
	local data = require("app.Logic.Datas.DebaoMain.Account.DMGetUserShowInfo"):new()
	if(data:parseJson(strJson, false) == BIZ_PARS_JSON_SUCCESS) then
		if(data.userId == myInfo.data.userId) then
			myInfo.data.userPotrait = data.userPortrait
			if not myInfo.data.userPotrait then
				myInfo.data.userPotrait = ""
			end
			if(data.userPhone ~= "" and data.userPhone ~= "None") then
				myInfo.data.safeRatio = myInfo.data.safeRatio + 0.5
			end
			myInfo.data.userSex     = (data.userSex == "None") and "" or data.userSex
			myInfo.data.userExp     = data.userExperience
			myInfo.data.userLevel   = data.userLevel
			myInfo.data.userClubId = tonumber(data.userClubId)
			myInfo.data.userClubName = data.userClubName

	    	local imageUtils = require("app.Tools.ImageUtils")
			myInfo.data.userPotraitUri = imageUtils:getHeadImageDownloadUrl(myInfo.data.userPotrait)

			-- 获取融云token
			DBHttpRequest:getRCToken(function(tableData,tag)
					if tableData.code == 200 then
			            local rcData = {["AppKey"]= "8luwapkvuz8jl",["Token"]= tableData.token,
			            ["UserId"]=myInfo.data.userId,["Username"]=myInfo.data.userName,["UserPotraitUri"]=myInfo.data.userPotraitUri}
			            QManagerPlatform:initRongCloud(rcData)
			            GIsConnectRCToken = true
			        end
				end,myInfo.data.userId,myInfo.data.userName,myInfo.data.userPotraitUri)
		end
	end
	self:enterMainPage()
end

function PlatformLogin:httpResponse(event)
    local ok = (event.name == "completed")
    local request = event.request
    if event.name ~= "progress" and GameSceneManager.m_pLoadingView then 
    	if GameSceneManager:getCurScene():getChildByTag(999) then
    		GameSceneManager.m_pLoadingView:removeFromParent()
    	end
    	GameSceneManager.m_pLoadingView = nil
    end
 	if event.name == "failed" then
 		if not self.RewardLayer then
	 		self.RewardLayer = require("app.Component.CMAlertDialog").new({text = "网络连接异常，请检查网络是否正常后，再重试！",showType = 1,showClose = 0,
			callOk = function () 
				CMClose(self.RewardLayer)
				self.RewardLayer = nil
			end})
			CMOpen(self.RewardLayer, self:getParent())
		end
 	end
 	-- dump(event.name)
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    --服务器补充session
    if request.tag == POST_COMMAND_LOGIN_FOR_MOBILE_NEW then
    	local session = request:getResponseHeadersString()
    	local i,j = string.find(session,"uck=")
    	if i then
	    	session = string.sub(session,i+4,-1)
	    	local i,j = string.find(session,";")
	    	session = string.sub(session,1,j-1)
	    	myInfo.data.phpSessionId = session
	        DBHttpRequest:setSession(session)
	    end
    	-- dump(session)
    end
    --dump(request:getResponseHeadersString())
    -- dump(response)
	-- self:dealLoginResp(request:getResponseString())
	if self.onHttpResponse then
		self:onHttpResponse(request.tag, request:getResponseString(), request:getState())
	end

end

function PlatformLogin:onHttpResponse(tag, content, state)
	-- dump(content,tag)
	if GTest then
	tag = POST_COMMAND_APPPAYNOTIFYSERVER
	end
	if tag == POST_COMMAND_REGISTERPC then
		local jsonTable = json.decode(content)
		if type(jsonTable)=="table" then
			if jsonTable["0001"]+0 == 1 then
                local ssid =  jsonTable["0002"]..""
                myInfo.data.phpSessionId = ssid
                DBHttpRequest:setSession(myInfo.data.phpSessionId)
                self.m_pCallbackUI:showMobileVerify()
            else
                local desc = jsonTable["600E"]..""
                self.m_pCallbackUI:loginFailedCallback(REGISTER_ERROR,(state==ehttpNoNetwork and Lang_NO_NETWORK or desc)) --[[网络断开连接]]
            end
		end
	elseif tag == POST_COMMAND_LOGIN then
		self:dealLoginResp(content)
		if TRUNK_VERSION~=DEBAO_TRUNK then
			DBHttpRequest:updateClientType(handler(self, self.httpResponse),currentVersion())
		end
	elseif tag == POST_COMMAND_GETSERVERID then
		self:dealGetServerId(content)
	elseif tag == POST_COMMAND_UPGRADE then
		self:dealCheckUpgrade(content)
	elseif tag == POST_COMMAND_GETSERVERPORT then
		self:dealGetServerPort(content)
	elseif tag == POST_COMMAND_GETTABLEINFO then
		self:dealGetTableInfo(content)
	elseif tag == POST_COMMAND_GETUSERTABLELIST then
		self:dealGetUserTableList(content)
	elseif tag == POST_COMMAND_GETACCOUNTINFO then
		self:dealGetAccountInfo(content)
	elseif tag == POST_COMMAND_GETLOGINCONTROL then
		self:dealGetLoginCtrl(content)
	elseif tag == POST_COMMAND_GETLOGINCONFIG then 
		self:dealGetLoginConfig(content)
	elseif tag == POST_COMMAND_GET_REPORT_SWITCH then--[[获取统计开关]]
		self:dealGetUnicomReportSwitch(content)
	elseif tag == POST_COMMAND_REFRESH_REPORT_SWITCH then--[[获取统计去重复 开关]]
		self:dealRefreshReportSwitch(content)
	elseif tag == POST_COMMAND_REPORT_BTN_CLICK then--[[统计上报结果]]
		self:dealReportBtnClick(content)
	elseif tag == POST_COMMAND_LOGIN_FOR_MOBILE_NEW then--[[新版登录逻辑]]
		self:dealLogin4VerisionResp(content)
	elseif tag == POST_COMMAND_SIGN_BIND_500 then
		self:dealSignBind500(content)
	elseif tag == POST_COMMAND_ESUNLOGIN then
		self:dealESunLoginResp(content)
	elseif tag == POST_COMMAND_QUICKREGISTER then
		self:dealQuickRegister(content)
	elseif tag == POST_COMMAND_APPPAYNOTIFYSERVER then--[[苹果补单]]
		self:dealApplePayNotifyServerResp(json.decode(content))
	elseif tag == POST_COMMAND_ResetPassword then
		--self:dealResetPassword(content)
	end
end
	
return PlatformLogin