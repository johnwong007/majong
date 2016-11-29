local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
require("app.Logic.Config.UserDefaultSetting")
require("app.Tools.EStringTime")
require("app.Logic.Datas.TableData.PushMessage")
require("app.Logic.Datas.Props.UserPropsList")
local MusicPlayer = require("app.Tools.MusicPlayer")

local BaseMainPage = class("BaseMainPage", function()
		return display.newNode()
	end)

function BaseMainPage:ctor()
	self.m_pCallbackUI = nil
	self.isNewYear = false
	self.tcpRequest = TcpCommandRequest:shareInstance()
	self.tcpRequest:addObserver(self)
	
    self:setNodeEventEnabled(true)
    -- self:registerScriptHandler(handler(self, self.onNodeEvent))
    DBHttpRequest:getUserPropsList(handler(self, self.httpResponse), "FUNCTION", myInfo.data.userId)
    -- DBHttpRequest:useRoomCard(handler(self, self.httpResponse), 78, myInfo.data.userName, "123456", 9, "50/100", "3600")
    -- DBHttpRequest:useRoomCard(handler(self, self.httpResponse), 79, "手机端自定义sng1", "123456", 9, "50/100", "3600")
    -- DBHttpRequest:useRoomCard(handler(self, self.httpResponse), 80, "手机端自定义sng1", "123456", 9, "50/100", "3600")
    -- DBHttpRequest:useMatchCard(handler(self, self.httpResponse), 81, "手机端自定义sng1", "123456", 9, "3000", "180")
    
	-- MusicPlayer:getInstance():playBackgroundMusic()
end


function BaseMainPage:onNodeEvent(event)
    if event == "exit" then
        self:onExit()
    end
end

function BaseMainPage:onEnterTransitionFinish()
    DBHttpRequest:getAccountInfo(function(event) self:httpResponse(event)end)

    self.eventGetUserTableList = cc.EventListenerCustom:create("GetUserTableList", function(event)
            self:getUserTableList(event)
        end)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.eventGetUserTableList, 12)
end

function BaseMainPage:onExit()
	self.tcpRequest:removeObserver(self)
    if self.eventGetUserTableList then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.eventGetUserTableList)
        self.eventGetUserTableList = nil
    end
end

function BaseMainPage:getUserTableList()
	DBHttpRequest:getUserTableList(handler(self,self.httpResponse))
end

function BaseMainPage:setMainPageCallback(callback)
	self.m_pCallbackUI = callback
end

-- requets
function BaseMainPage:enterMainPageRequest()
	if self.m_pCallbackUI then
		self.m_pCallbackUI:showOnlinePersonCallback(myInfo.data.currentOnlineNumber)
		DBHttpRequest:GetAllNoticesInfo(handler(self,self.httpResponse),"4",true)
	end
end

function BaseMainPage:OnTcpMessage(command, strJson)
	-- normal_info_log("BaseMainPage:OnTcpMessage")
	if command == COMMAND_PING_RESP then --[[心跳包]]
	elseif command == COMMAND_TABLE_GUIDE then --[[通知进入锦标赛]]

	elseif command == COMMAND_PUSH_MSG then --[[推送消息（大喇叭，滚动公告）]]
		self:dealPushMessageResp(strJson)

	end
end

function BaseMainPage:dealLoginReward(strJson)
	return 
end
function BaseMainPage:dealGetLotteryChances(strJson)
	return 
end
function BaseMainPage:dealUserOnlineCount(strJson)

	local data = require("app.Logic.Datas.Lobby.UserOnLineCount"):new()
	if(data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS) then
	
		myInfo.data.currentOnlineNumber = data.onLineCount
		if(self.m_pCallbackUI) then
			self.m_pCallbackUI:showOnlinePersonCallback(myInfo.data.currentOnlineNumber)
		end
	end
end
function BaseMainPage:dealGetTableMobileInfo(strJson)return end
function BaseMainPage:dealGetAccountInfo(strJson)return end
function BaseMainPage:dealAnnounceList(strJson)return end


function BaseMainPage:dealPushMessageResp(data)
-- 	dump(data)
-- 	-- if(not self.m_pCallbackUI) then
-- 	-- 	return
-- 	-- end
--     if type(data) ~= "table" then return end
--     local simbol = data["simbol"]
--     local nType  = tonumber(data["type"])
--     local receive= data["receive"]
--     local message= data["message"]

--     if nType == 71 then      		--免费任务更新
--     	myInfo.data.showFreegoldTips = true 
--     elseif nType == 29 then 		--广播通知
--     	self.m_pCallbackUI:addLoudSpeakerMsg(data[BOARDCAST_CONTENT] or "")
--     elseif nType == 50 then 		--未知
--     	DBHttpRequest:GetAllNoticesInfo(handler(self,self.httpResponse),"4",true)
--     end
end

function BaseMainPage:showNetBreakDownHlocal(state)

	local errorMsg = ((state == ehttpNoNetwork) and Lang_NO_NETWORK or Lang_LOGIN_ERROR_PROMPT)
	if(self.m_pCallbackUI) then
	
		self.m_pCallbackUI:showError_Callback(errorMsg)
	end
end

function BaseMainPage:dealGetNewYearInfo(strJson)

	local getNewYearInfo = require("app.Logic.Datas.Lobby.GetNewYearInfo"):new()
	if(getNewYearInfo:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
		self.isNewYear = getNewYearInfo.isNewYear
		DBHttpRequest:getLotteryChances(handler(self,self.httpResponse),myInfo.data.userId)
	end
	getNewYearInfo=nil
end



--[[http请求返回]]
----------------------------------------------------------
function BaseMainPage:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- pr(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- pr(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    -- dump(json.decode(response),request.tag)
    -- self:dealLoginResp(request:getResponse())
    if self and self.onHttpResponse then
    	self:onHttpResponse(request.tag, request:getResponseString(), request:getState())
    end

end

function BaseMainPage:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_GETUSERPROPSLIST then --[[获取开房卡信息]]
		local userPropsList = UserPropsList:getInstance()
		userPropsList:updatePropsList(content)
		-- dump(json.decode(content))
		-- dump(userPropsList.m_propsList)
	elseif tag == POST_COMMAND_ISNEWYEAR then --[[新年活动]]
		self:dealGetNewYearInfo(content)
	elseif tag == POST_COMMAND_GETLOTTERYCHANCES then
		self:dealGetLotteryChances(content)
	elseif tag == POST_COMMAND_FETCHLOGINREWARD then --[[每日登录领奖]]
		self:dealLoginReward(content)
	elseif tag == POST_COMMAND_GETUSERONLINECOUNT then 
		self:dealUserOnlineCount(content)
	elseif tag == POST_COMMAND_GETUSRETABLELISTMOBILE then
		self:dealGetTableMobileInfo(content)
	elseif tag == POST_COMMAND_GETACCOUNTINFO then
		self:dealGetAccountInfo(content)
	elseif tag == POST_COMMAND_GETANNOUNCELIST then
		self:dealAnnounceList(content)
	elseif tag == POST_COMMAND_GETALLNOTICEINFO then --[[滚动公告消息]]
		self:dealNoticeResp(content)
	elseif tag == POST_COMMAND_GETUSERTABLELIST then
		self:dealGetUserTableList(content)
	elseif tag == POST_COMMAND_GETTABLEINFO then
		self:dealGetTableInfo(content)
	end
end
----------------------------------------------------------

function BaseMainPage:dealGetUserTableList(strJson)end
function BaseMainPage:dealGetTableInfo(strJson)end
function BaseMainPage:dealNoticeResp(strJson)

	local data = require("app.Logic.Datas.Lobby.NoticeInfos"):new()
	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
		if data.list and #data.list>0 and self.m_pCallbackUI then
			local message = {}
			for i=1,#data.list do
				message[#message+1]=data.list[i].noticeContent
			end
			self.m_pCallbackUI:updateNoticeList(message,true)
		end
	end
	data = nil
end

function BaseMainPage:reqMyDoubleExpTime()

	if (UserDefaultSetting:getInstance():get48HoursOver()) then
		return -1
 	end

	if myInfo.data.regTime==nil or myInfo.data.regTime=="" then
	
		return -1
	end


	local t = os.date("*t")
	local localTime = t
    
	local regTimeString = myInfo.data.regTime
	local tempTimeString = EStringTime:new(regTimeString)
    
	local regTime = {}
	regTime.year = tempTimeString.year
	regTime.month = tempTimeString.month
	regTime.day = tempTimeString.day
	regTime.hour = tempTimeString.hour
	local eStringTime = EStringTime:new()
	local subHour = eStringTime:getSubHourOfAThanB(localTime,regTime)
    
	
	return subHour
end

--48小时新手活动
function BaseMainPage:showDoubleExpDialog()

	local subHour = self:reqMyDoubleExpTime()
	if(subHour>=0 and subHour<=48) then
	
		self.m_pCallbackUI:showGuideDialogCallback(subHour)
		UserDefaultSetting:getInstance():set48HoursOver(true)
	end
end
return BaseMainPage
