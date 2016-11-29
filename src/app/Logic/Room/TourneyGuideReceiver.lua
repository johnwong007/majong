local myInfo = require("app.Model.Login.MyInfo")

TourneyGuideReceiver = class("TourneyGuideReceiver", function()
		return display.newNode()
	end)

sharedTourneyGuideReceiver = nil

function TourneyGuideReceiver:sharedInstance()
	if sharedTourneyGuideReceiver == nil then
		local instance = TourneyGuideReceiver:new()
		sharedTourneyGuideReceiver = instance
	end
	return sharedTourneyGuideReceiver
end

function TourneyGuideReceiver:ctor()
	-- normal_info_log("TourneyGuideReceiver:ctor   功能不完全")

	self.m_reconnectTimes = 0
	self.m_bEnable = true
	self.m_currentView = nil
	self.m_isKicked = false
	self.m_bNetBreak = false
	self.m_bReconnecing = false
	self.m_bShowPKOutMessage = false

	self.tcpRequest = TcpCommandRequest:shareInstance()
	self.tcpRequest:addObserver(self)
	-- PushCommandRequest:shareInstance()->addObserver(this)
	-- CCNotificationCenter:sharedNotificationCenter()->addObserver(this, callfuncO_selector(TourneyGuideReceiver:onNetworkState), KJAVACALLNATIVE_NETWORKSATE_CHANGE, NULL)

    self:setNodeEventEnabled(true)
    self:retain()
end

function TourneyGuideReceiver:onNodeEvent(event)
    if event == "exit" then
    	self:onExit()
    end
end

function TourneyGuideReceiver:onExit()
    self.tcpRequest:removeObserver(self)
    self:release()
end

function TourneyGuideReceiver:registerCurrentView(view)
	self.m_currentView = view
end

function TourneyGuideReceiver:enableReceiver(bEnable)
	self.m_bEnable = bEnable
end

function TourneyGuideReceiver:onNetworkState(object)

	if (self.m_bNetBreak and self.m_bEnable and not self.m_bReconnecing and self.m_reconnectTimes >= 5) then
	
		--有网络进行重连
		DBHttpRequest:getServerPort(handler(self,self.httpResponse), currentVersion())
	end
end

function TourneyGuideReceiver:dealTableGuide(strJson)
	if not self.m_currentView then
		return
	end
	local info = require("app.Logic.Datas.TableData.TableGuide"):new()
	if (info:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
		local alertView = require("app.Component.EAlertView"):alertView(
                                                      cc.Director:getInstance():getRunningScene(),
                                                      self,
                                                      "",
                                                      "您报名的"..info.matchName.."已经开始，是否立即前往？",
                                                     "弃权", "立即前往")
		alertView:setTag(100)--锦标赛开始提示
		local strId = info.tableId
		alertView:setUserData(strId)
		alertView:alertShow()
	end
	info = nil
end

function TourneyGuideReceiver:showPkOutMessage()

	if not self.m_currentView then
		return
	end
	local alertView = require("app.Component.EAlertView"):alertView(
                                                  cc.Director:getInstance():getRunningScene(),
                                                  self,
                                                  "",
                                                  "对不起，您报名的pk赛未被分配到牌桌，我们已经为您报名了下一场pk赛，非常感谢您的支持。",
                                                  "确定")
	alertView:setTag(102)
	alertView:alertShow()
	
end

function TourneyGuideReceiver:dealSocketBreak(strJson)
	self.m_bNetBreak = true
	self.m_reconnectTimes = self.m_reconnectTimes+1
	if (self.m_isKicked or self.m_reconnectTimes >= 6) then
		return
	end
	DBHttpRequest:getServerPort(handler(self,self.httpResponse), currentVersion())
	self.m_bReconnecing = true
    
end

function TourneyGuideReceiver:dealKickUser(strJson)

	self.m_isKicked = true
    
	if (not self.m_currentView) then
		return
    end

	local alertView = require("app.Component.EAlertView"):alertView(
                                                  cc.Director:getInstance():getRunningScene(),
                                                  self,
                                                  Lang_Title_Prompt,
                                                  Lang_ACCOUNT_LOGIN_AT_OTHER,
                                                  Lang_Button_Quit,
                                                  Lang_Button_Relogin)
	alertView:setTag(101)----帐号其他地方登录提示
	alertView:alertShow()
	alertView:setCloseCallback(handler(self,self.kickUser))


	-- local RewardLayer = require("app.Component.CMAlertDialog").new({text = Lang_ACCOUNT_LOGIN_AT_OTHER,
	-- 	showType = 2,okText = Lang_Button_Quit,titleText = Lang_Title_Prompt,
	-- 	cancelText = Lang_Button_Quit,
	-- 			callOk = function () 
	-- 				cc.Director:getInstance():stopAnimation()
	-- 				cc.Director:getInstance():purgeCachedData()
	-- 				cc.Director:getInstance():endToLua()
	-- 				if device.platform == "ios" then
	-- 					os.exit()
	-- 				end
	-- 		 	end,
	-- 			callCancel = function ()
			
	-- 				self:relogin()
			
	-- 			end}) 
	-- CMOpen(RewardLayer, cc.Director:getInstance():getRunningScene(), 0, 1, MAX_ZORDER+1)
end

function TourneyGuideReceiver:OnTcpMessage(command, strJson)

	-- normal_info_log("TourneyGuideReceiver OnTcpMessage")
	local msg = "TourneyGuideReceiver"

	-- dump(strJson)
	-- print(command)
	-- print(COMMAND_TABLE_GUIDE)
	-- print(COMMAND_SOCKET_CONNECTION_BREAK)
	-- print(COMMAND_KICK_USER)
	-- print(COMMAND_PUSH_MSG)
	if command == COMMAND_TABLE_GUIDE then
        -- msg = msg..strJson
        if self.m_bEnable then
            self:dealTableGuide(strJson)
        end
    elseif command == COMMAND_SOCKET_CONNECTION_BREAK then
        if self.m_bEnable then
            self:dealSocketBreak(strJson)
        end
    elseif command == COMMAND_KICK_USER then
        -- msg = msg..strJson
        self:dealKickUser(strJson)
    elseif command == COMMAND_PUSH_MSG then
		local data = require("app.Logic.Datas.TableData.PushMessage"):new()
		if(data.parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
			if data.m_type == 47 then
				self:showPkOutMessage()
			end
		end
            
    elseif command == COMMOND_PUSH_CONNECTION_BREAK then
           
	elseif command == CASH_TABLE_GUIDE then
		GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = strJson["1002"],passWord = "",m_isFromMainPage = true,from = GameSceneManager.AllLayer.ZIDINGYI,enterClubOrNot = true})
	end
end
----------------------------------------------------------

--[[http请求返回]]
----------------------------------------------------------
function TourneyGuideReceiver:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
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
    -- self:dealLoginResp(request:getResponseString())
    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function TourneyGuideReceiver:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_GETSERVERPORT then
    	self:dealGetServerPort(content)
    end
end

function TourneyGuideReceiver:dealGetServerPort(strJson)

	myInfo:setServerPort(strJson+0)
	if self.tcpRequest:isConnect() then
	
		self.m_reconnectTimes = 0
		self.m_bNetBreak = false
	
	else
	
		if self.tcpRequest:connectSocket(myInfo.data.Global_ProxyIp , myInfo.data.Global_ProxyPort+0) then
		
			self.tcpRequest:sendTencentInitPkg(myInfo.data.serverId,myInfo.data.Global_Openkey)
			self.tcpRequest:startPing()
			self.m_bNetBreak = false
			self.m_reconnectTimes = 0
		end
	end
	self.m_bReconnecing = false
end

function TourneyGuideReceiver:relogin()

	if TRUNK_VERSION==DEBAO_TRUNK then
		-- if self.tcpRequest:isConnect() then
		-- 	self.tcpRequest:closeConnect()
		-- end
		QManagerData:removeAllCacheData()
		QManagerListener:clearAllLayerID()

		UserDefaultSetting:getInstance():setLastLoginTimeStamp(myInfo.data.userId,myInfo.data.serverTime)
		UserDefaultSetting:getInstance():setAutoLoginEnable(false)
		myInfo.data.phpSessionId = ""
		GIsConnectRCToken = false
		
		myInfo:clearCacheData()
		local tcp = TcpCommandRequest:shareInstance()
		if tcp:isConnect() then
			tcp:closeConnect()
		end
		local push = PushCommandRequest:shareInstance()
		if push:isConnect() then
			push:closeConnect()
		end
		QManagerPlatform:disConnectRongYun()
	    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
		-- UserDefaultSetting:getInstance():setAutoLoginEnable(false)
		-- UserDefaultSetting:getInstance():setLoginType("")
		-- -- local loginView = require("app.GUI.login.LoginView"):new()
		-- -- GameSceneManager:switchScene(loginView)
  --   	GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
	else
		cc.Director:getInstance():stopAnimation()
		cc.Director:getInstance():purgeCachedData()
		cc.Director:getInstance():endToLua()
		NativeJNI:JumpToTencentLoginView_Relogin_JNI() --跳转到腾讯登录页
	end
end

function TourneyGuideReceiver:kickUser()
	self:relogin()
end

function TourneyGuideReceiver:clickButtonAtIndex(alertView, index)

	local tag = alertView:getTag()
	if tag == 100 then --锦标赛开始提示
		
			local strId = alertView:getUserData()
			if index == 0 then
			
				self.tcpRequest:quitTourney(strId, myInfo.data.userId)
				DBHttpRequest:getSngMatch(handler(self,self.httpResponse), 0, "SNG_CRAZY", "REGISTERING", "")
			
			else
			
				-- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
				-- GameSceneManager:switchSceneWithNode(roomViewManager)
				-- roomViewManager:enterRoomWithTableId(strId)
				local isFromMainPage = true
				local fromLayer = nil
				if GameSceneManager.mCurSceneType == EGSTourney or GameSceneManager.mCurSceneType == GameSceneManager.AllScene.TourneyList then
					isFromMainPage = false
				end

				GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = strId,m_isFromMainPage = isFromMainPage,from = fromLayer})
			end
			strId = nil 
		
    elseif tag == 101 then --帐号其他地方登录提示
		
			if index ~= 0 then
			
				self:relogin()
			
			else --quit
			
				cc.Director:getInstance():stopAnimation()
				cc.Director:getInstance():purgeCachedData()
				cc.Director:getInstance():endToLua()
				if device.platform == "ios" then
					os.exit()
				end
			end
	end
	
end

return TourneyGuideReceiver

