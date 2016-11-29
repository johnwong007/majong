local myInfo = require("app.Model.Login.MyInfo")
local BaseMainPage = require("app.Logic.mainPage.BaseMainPage")
local DebaoMainPage = class("DebaoMainPage", function()
		return BaseMainPage:new()
	end)
require("app.Logic.UserConfig")

function DebaoMainPage:ctor()
	UserConfig.reqShowInfo = false
	DBHttpRequest:getUserUseFuncInfo(handler(self, self.httpResponse), "1")
end

function DebaoMainPage:onNodeEvent(event)
   	BaseMainPage.onNodeEvent(self,event)
end

function DebaoMainPage:setMainPageCallback(callback)
	BaseMainPage.setMainPageCallback(self,callback)
	self.m_pCallbackUI = callback
end

function DebaoMainPage:enterMainPageRequest()
	BaseMainPage.enterMainPageRequest(self)

	--充值记录
	if(not myInfo.data.requestPayRecord) then
	
        if (UserDefaultSetting:getInstance():getAppleCheckFlag() == 1) then
            DBHttpRequest:getUserChargeInfo(handler(self,self.httpResponse))
        end
	end
    
	if(myInfo.data.activityId=="") then
	
		DBHttpRequest:getRookieProtectionConfig(handler(self,self.httpResponse))
	else
	
        -- 		if(not myInfo.data.isFetchLoginReward)
        -- 		
        -- 			--查询是否由登录奖励
        -- 			DBHttpRequest:getLoginRewardInfo(handler(self,self.httpResponse))
        -- 		end
        
		self.m_pCallbackUI:showNewerGuide(myInfo.data.isNewer)
        
		if(not UserConfig.reqShowInfo) then
			--拉取显示信息
			DBHttpRequest:getUserShowInfo(handler(self,self.httpResponse),myInfo.data.userId,true)
			UserConfig.reqShowInfo = true
		end
	end
end

function DebaoMainPage:getLoginRewardInfo()

	if(not myInfo.data.isFetchLoginReward) then
	
		--查询是否由登录奖励
		DBHttpRequest:getLoginRewardInfo(handler(self,self.httpResponse))
	end
end

--[[http请求返回]]
----------------------------------------------------------
function DebaoMainPage:httpResponse(event)

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
    -- self:dealLoginResp(request:getResponse())
    if self.onHttpResponse then
	    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())
	end
end

function DebaoMainPage:onHttpResponse(tag, content, state)

	BaseMainPage.onHttpResponse(self,tag,content,state)

	if tag == POST_COMMAND_GETLOGINREWARDINFO then --[[登录奖励]]
		self:dealGetLoginRewardInfo(content)		
	elseif tag == POST_COMMAND_FETCHLOGINREWARD then --[[领取登录奖励]]
		self:dealFetchLoginReward(content)	
	elseif tag == POST_COMMAND_GETUSERSHOWINFO then --[[显示信息]]
		self:dealGetUserShowInfo(content)	
	elseif tag == POST_COM_GETROOKIEPROTECTIONCONFIG then
		self:dealGetRookieProtectionConfig(content)	
	elseif tag == POST_COM_GET_USER_CHARGE_INFO then --[[用户充值记录]]
		self:dealGetUserChargeInfo(content)	
	elseif tag == POST_COMMAND_getUserUseFuncInfo then
		self:dealGetUserUseFuncInfo(content)
	elseif tag == POST_COMMAND_GETRCTOKEN then
		-- dump(content,"content")
		if content.code == 200 then
            local rcData = {["AppKey"]= "8luwapkvuz8jl",["Token"]= content.token,
            ["UserId"]=myInfo.data.userId,["Username"]=myInfo.data.userName,["UserPotraitUri"]=myInfo.data.userPotraitUri}
            QManagerPlatform:initRongCloud(rcData)
            GIsConnectRCToken = true 
        end
	end
end

function DebaoMainPage:dealGetUserUseFuncInfo(strJson)
	DBHttpRequest:freshInterfaceGuide(handler(self, self.httpResponse)) --[[标记已领取]]
--     Json::Reader reader;
--     Json::Value var;
--     httpRequest->freshInterfaceGuide(this);//标记已领取
--     if(reader.parse(strJson , var))
--     {
--         int code = atoi(var[0]["7004"].asString().c_str());
--         if (code  == 0) {
--             m_pCallbackUI->showNewerGuide(true);
--         }else{
--             m_pCallbackUI->showNewerGuide(false);
--         }
--         MyInfo::shareInstance()->isNewer = false;
--     }else{
--         m_pCallbackUI->showNewerGuide(false);
--     }
-- }
end

function DebaoMainPage:dealGetTableMobileInfo(strJson)

	local data = require("app.Logic.Datas.Lobby.GetUserTableListMobile"):new()
	if( data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and
       data.code=="") then
	
		--返回用户不同赛事牌桌信息列表
	end
	data = nil
end

function DebaoMainPage:dealGetLoginRewardInfo(strJson)

	local data = require("app.Logic.Datas.DebaoMain.Admin.DMGetLoginRewardInfo"):new()
 	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
 	
		--领取奖励
		DBHttpRequest:fetchLoginReward(handler(self,self.httpResponse))
	else
	
		--48小时新手活动
		myInfo.data.isFetchLoginReward = true
		self:showDoubleExpDialog()
	end
	data = nil
end

function DebaoMainPage:dealFetchLoginReward(strJson)

	myInfo.data.isFetchLoginReward = true
	local data = require("app.Logic.Datas.DebaoMain.Admin.DMFetchLoginReward"):new()
	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
  	
		if(data.payNum > 0) then
		
			--更新账户
			myInfo.data:setTotalChips(myInfo.data.getTotalChips() + data.payNum)
			--领取成功
			if(self.m_pCallbackUI) then
			
				self.m_pCallbackUI:showLoginRewardCallbackDM(
                                                         data.continuesLoginDays,
                                                         data.payNum,
                                                         data.payType,
                                                         data.adsURL)
                
				self.m_pCallbackUI:updateUserAccount(myInfo.data.getTotalChips())
                
				self.m_pCallbackUI:updateNoReadNotice(0)
			end
		end
	else
	
		self:showDoubleExpDialog()
	end
	data = nil
end


function DebaoMainPage:dealGetUserShowInfo(strJson)
	-- normal_info_log("DebaoMainPage:dealGetUserShowInfo")
	local data = require("app.Logic.Datas.DebaoMain.Account.DMGetUserShowInfo"):new()

	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
		if(data.userId == myInfo.data.userId) then
			myInfo.data.userPotrait = data.userPortrait
			if not myInfo.data.userPotrait then
				myInfo.data.userPotrait = ""
			end
			
			-- 融云sdk 先模拟server取得token  然后初始化并连接
    -- if device.platform == "ios" then
  --   	local imageUtils = require("app.Tools.ImageUtils")
		-- myInfo.data.userPotraitUri = imageUtils:getHeadImageDownloadUrl(myInfo.data.userPotrait)

		-- if device.platform == "ios" then
        	-- DBHttpRequest:getRCToken(function(tableData,tag)if self.onHttpResponse then self:onHttpResponse(POST_COMMAND_GETRCTOKEN,tableData) end end,
        	-- 	myInfo.data.userId,myInfo.data.userName,myInfo.data.userPotraitUri)
       	-- end
    -- end
			
			myInfo.data.userSex     = (data.userSex == "None") and "" or data.userSex
			myInfo.data.userExp     = data.userExperience
			myInfo.data.userLevel   = data.userLevel
			myInfo.data.userClubId = tonumber(data.userClubId)
			myInfo.data.userClubName = data.userClubName

			-- if true then 
			-- if device.platform == 'ios' then
			-- 	if data.userClubId ~= "" and data.userClubId ~= "0" then
			-- 	local clubBtn = CMButton.new({normal = "picdata/public/clubIcon.png"},function () 
   --  			-- QManagerPlatform:enterClub({['targetId']='DebaoClub'..myInfo.data.userClubId,['clubName']=myInfo.data.userClubName})
   --  			local RewardLayer      = require("app.GUI.fightTeam.FightDemo").new()	
   -- 				 RewardLayer:create()
   -- 				self:addChild(RewardLayer)
   --  			end)
   --   			clubBtn:setPosition(30,display.cy)
   --   			cc.Director:getInstance():getRunningScene():addChild(clubBtn,10000)
			-- 	end
			-- end
			-- end

			if(self.m_pCallbackUI) then
			
				self.m_pCallbackUI:updateUserInfoUI(data.userPortrait,data.userLevel)
			end
			
			if(data.userPhone ~= "" and data.userPhone ~= "None") then
				myInfo.data.safeRatio = myInfo.data.safeRatio + 0.5
			end
		end
	end
	data = nil
    
	self:reqSafeSetting()
	
end

function DebaoMainPage:reqSafeSetting()

	local enter = UserConfig.enteredRoom
	local safe = UserDefaultSetting:getInstance():getSafeSetting()
    
	if(self.m_pCallbackUI) then
		local safe = (myInfo.data.safeRatio < 1.0) and (UserConfig.enteredRoom) and (UserDefaultSetting:getInstance():getSafeSetting())
		self.m_pCallbackUI:setSafeSettingVisible(safe)
		if(safe) then
			UserDefaultSetting:getInstance():setSafeSetting(false)
		end
	end
end

function DebaoMainPage:dealGetRookieProtectionConfig(strJson)

	local data = require("app.Logic.Datas.Lobby.GetRookieProtectionConfigDatas"):new()
	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
		myInfo.data.activityId  = data.activityId
		myInfo.data.award_num = data.award_num
		myInfo.data.brokeMoney = data.brokeMoney
		myInfo.data.frequence_limit = data.frequence_limit
		myInfo.data.spanTime = data.spanTime
        
		myInfo.data:JudgeIsNewer()
		myInfo.data:initLoginUserSettting()
		if(self.m_pCallbackUI) then
		
			self.m_pCallbackUI:showNewerGuide(myInfo.data.isNewer)
		end
	end
	data = nil
    
	if(not UserConfig.reqShowInfo) then
	
		--拉取显示信息
		DBHttpRequest:getUserShowInfo(handler(self,self.httpResponse),myInfo.data.userId,true)
		UserConfig.reqShowInfo = true
	end
end


function DebaoMainPage:dealGetUserChargeInfo(strJson)

	local data = require("app.Logic.Datas.DebaoMain.Account.DMGetUserChargeInfo"):new()
	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
		myInfo.data.payamount = data.transMoney
		myInfo.data.payPercent = data.percent
		myInfo.data.requestPayRecord = true
		if(self.m_pCallbackUI) then
		
			-- self.m_pCallbackUI:showFirstCharge(myInfo.data.payamount <= 0, data.percent)
            
		end
        
	end
	data = nil
end

function DebaoMainPage:dealGetAccountInfo(strJson) 
   local data = require("app.Logic.Datas.Account.AccountInfo"):new()
   local jsonTable = json.decode(strJson)
   if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
    	myInfo.data.totalChips = data.silverBalance
        myInfo.data.diamondBalance = data.diamondBalance
        DBHttpRequest:getUserTableList(handler(self,self.httpResponse))
    end
	data = nil
end

function DebaoMainPage:dealGetUserTableList(strJson) 
	local data = require("app.Logic.Datas.Lobby.GetUserTableList"):new()
    if (data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
    	if data.tableList and #data.tableList>0 then
    		if data.tableList[#data.tableList].usertableType == "TOURNEY" then
				-- 锦标赛
				DBHttpRequest:getTableInfo(handler(self,self.httpResponse),"TOURNEY", data.tableList[#data.tableList].usertableId, true)
			else
				self.m_pCallbackUI:reconnectSuccessedCallback(
                                                          data.tableList[#data.tableList].usertableId,
                                                          myInfo.data.userId)
			end
    	end
    end
    data = nil
end

function DebaoMainPage:dealGetTableInfo(strJson)
	dump("dealGetTableInfo")
    local info = require("app.Logic.Datas.Lobby.TourneyTableInfo"):new()
    if info:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
        self.m_pCallbackUI:alertEnterTourneyRoomCallback(info.matchName, info.tableId)
    end
end

----------------------------------------------------------

return DebaoMainPage