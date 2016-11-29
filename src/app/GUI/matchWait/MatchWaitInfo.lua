--
-- Author: wangj
-- Date: 2016-05-17 17:06:03
--
local myInfo = require("app.Model.Login.MyInfo")
local topItemPosY = display.height - 57
local WaitInfoLayer = {
    MatchDetail = 1,
    PlayerList = 2,
    Award = 3,
    Upsecond = 4
}

local WaitInfoOperation = {
    ApplyMatch = 1,
    StartMatch = 2,
    JoinMatch = 3
}

local MatchWaitInfoLogic = class("MatchWaitInfoLogic", function()
	return display.newNode()
end)

function MatchWaitInfoLogic:ctor(params)
	self:setNodeEventEnabled(true)
	self.m_callbackUI = params.m_callbackUI
    self.params = params.data or {}
    self.matchId = self.params.matchId
    self.password = self.params.password

    self.m_hasApply = false
    self.curUnum = self.params.curUnum
    self.m_userList = nil
    self.m_hideKickUserButton = false

    self.m_rankLogic = require("app.Logic.Room.MatchRankLogic"):create(self)
end

function MatchWaitInfoLogic:updatePsd(psd)
     self.password = psd
end

function MatchWaitInfoLogic:getSngUserList()
    self.m_hasApply = false
    if not self.m_userList then
        self.m_userList = {}
        local array = string.split(self.params.applyList, ",")
        
        for i=1,#array do
            local index = string.find(array[i],":")
            local player = {}
            player.first = ""..i
            player.second = StringFormat:formatName(string.sub(array[i], index+1), 12)
            player.third = string.sub(array[i], 0, index-1)
            self.m_userList[#self.m_userList+1] = player

            if tonumber(player.third) == tonumber(myInfo.data.userId) then
                self.m_hasApply = true
            end
        end
    else
        for i=1,#self.m_userList do
            if tonumber(self.m_userList[i].third) == tonumber(myInfo.data.userId) then
                self.m_hasApply = true
            end
        end
    end
    self.m_callbackUI:updateApplyButton(self.m_hasApply)
end

function MatchWaitInfoLogic:onEnter()
    
end

function MatchWaitInfoLogic:onExit()
    local event = cc.EventCustom:new("ShowPrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function MatchWaitInfoLogic:onEnterTransitionFinish()
    local event = cc.EventCustom:new("HidePrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    -- self:getMatchInfo()
    if self.params.playType == "MTT" then
        self:getMatchUserList()
    else
        self:getSngUserList()
    end
end

function MatchWaitInfoLogic:applyDiyMtt()
    DBHttpRequest:applyDiyMtt(function(event) if self.httpResponse then self:httpResponse(event) end
        end,self.matchId, self.password) 
end

function MatchWaitInfoLogic:applyDiyMatch()
    DBHttpRequest:applyDiyMatch(handler(self, self.httpResponse), self.matchId, self.password, true)
end

function MatchWaitInfoLogic:quitMatch()
    if self.params.playType == "MTT" then
        DBHttpRequest:quitMatch(function(event) if self.httpResponse then self:httpResponse(event) end
            end,self.matchId) 
    else
        self:quitDiyMatch()
    end
end

function MatchWaitInfoLogic:quitDiyMatch()
    DBHttpRequest:quitDiyMatch(function(event) if self.httpResponse then self:httpResponse(event) end
        end,self.matchId) 
end

function MatchWaitInfoLogic:getMatchInfo()
    DBHttpRequest:getMatchInfo(function(event) if self.httpResponse then self:httpResponse(event) end
        end,self.matchId,"") 
end

function MatchWaitInfoLogic:getUserMatchTableInfo()
    DBHttpRequest:getUserMatchTableInfo(function(event) if self.httpResponse then self:httpResponse(event) end
        end,self.matchId) 
end

function MatchWaitInfoLogic:getMatchUserList()
    DBHttpRequest:getMatchUserList(function(event) if self.httpResponse then self:httpResponse(event) end
        end,self.matchId) 
end

function MatchWaitInfoLogic:getPrizeInfo()
    -- if self.m_bonusName and string.len(self.m_bonusName)>0 then
    --     self.m_prizeResponed = false
    --     DBHttpRequest:getPrizeInfo(handler(self,self.httpResponse),self.matchId,self.m_bonusName,self.m_curPlayer)
    -- else
    
    --     self.m_prizeResponed = true
    -- end

    -- if self.m_gainName and string.len(self.m_gainName)>0 then
    
    --     self.m_gainResponed = false
    --     DBHttpRequest:getGainInfoByName(handler(self,self.httpResponse),self.m_gainName)
    -- else
    
    --     self.m_gainResponed = true
    -- end
    self.m_rankLogic:getMatchRewardList(self.matchId,self.m_bonusName,self.m_gainName,self.m_curPlayer)
end

function MatchWaitInfoLogic:getBlindDSInfo()
    self.m_blindType = self.m_blindType or "1500-54-180s-Quick"
    DBHttpRequest:getBlindDSInfo(handler(self,self.httpResponse), self.m_blindType)
end

function MatchWaitInfoLogic:startDiyMatch()
    DBHttpRequest:startDiyMatch(handler(self,self.httpResponse), self.matchId)
end

function MatchWaitInfoLogic:joinMatch()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = self.tableId,passWord = self.password,m_isFromMainPage = true,from = GameSceneManager.AllLayer.ZIDINGYI,enterClubOrNot = true})
end

function MatchWaitInfoLogic:kickApply(userId)
    DBHttpRequest:kickApply(handler(self,self.httpResponse), userId, self.matchId)
end

function MatchWaitInfoLogic:updateMatchRewardList(pData)
    -- self.m_rewardListData = pData
    self.m_rewardListData = {}
    --取出奖池奖励
    for i=1,#self.m_rankLogic.m_prizeInfoList do
        local node = self.m_rankLogic.m_prizeInfoList[i]
        local data = {}
        if node.prizeBeginRank~=node.prizeEndRank then
            data.first = "第"..node.prizeBeginRank.."-"..node.prizeEndRank.."名"
        else
            data.first = "第"..node.prizeBeginRank.."名"
        end
        data.second = (node.bonusRatio*100).."%总奖池"
        data.third = StringFormat:FormatDecimals(node.bonusRatio * node.prizePool,2)
        self.m_rewardListData[#self.m_rewardListData+1] = data
    end
    self.m_callbackUI:showMatchRewardList(self.m_rewardListData)
end

--[[http请求返回]]
----------------------------------------------------------
function MatchWaitInfoLogic:httpResponse(event)

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

function MatchWaitInfoLogic:onHttpResponse(tag, content, state)
    if tag == POST_COMMAND_GETMATCHINFO then
        self:dealGetMatchInfo(content)
    elseif tag == POST_COMMAND_GETUSERMATCHTABLEINFO then
        self:dealGetUserMatchTableInfo(content)
    elseif tag == POST_COMMAND_GETMATCHUSERLIST then
        self:dealGetMatchUserList(content)
    elseif tag == POST_COMMAND_APPLY_DIY_MTT then
        self:dealApplyDiyMtt(content)
    elseif tag == POST_COMMAND_GET_ApplyDiyMatch then
        self:dealApplyDiyMatch(content)
    elseif tag == POST_COMMAND_QUITMATCH then
        self:dealQuitMatch(content)
    elseif tag == POST_COMMAND_QUIT_DIY_MATCH then
        self:dealQuitDiyMatch(content)
    elseif tag == POST_COMMAND_GETBLINDDSINFO then
        self:dealGetBlindDSInfo(content)
    elseif tag == POST_COMMAND_START_DIY_MATCH then
        self:dealStartDiyMatch(content)
    elseif tag == POST_COMMAND_KICK_APPLY then
        self:dealKickApply(content)
    end
end

--[[锦标赛信息]]
function MatchWaitInfoLogic:dealGetMatchInfo(content)
    local info = require("app.Logic.Datas.Lobby.MatchInfo"):new()
    if info:parseJson(content) == BIZ_PARS_JSON_SUCCESS then
        -- dump(info)
        self.matchInfo = info
        self.m_bonusName = info.bonusName
        self.m_gainName = info.gainName
        self.m_curPlayer = info.curUnum
        self.m_blindType = info.blindType
        self.m_startTime = info.presetStartTime
        
        self:updateMatchStatus(info.matchStatus)
        self.m_callbackUI:showMatchDetail(info)
        self.m_callbackUI:updateMTTTime(EStringTime:getTimeStampFromNow(self.m_startTime))
    end
    info = nil
end

--[[正在进行的牌桌信息]]
function MatchWaitInfoLogic:dealGetUserMatchTableInfo(content)
    local info = json.decode(content)
    if info and type(info)=="table" then
        self.tableId = tostring(info[TABLE_ID])
        if self.tableId then
            self.m_callbackUI:showJoinTableButton()
        end
    end
end

function MatchWaitInfoLogic:updateMatchStatus(status)
    self.m_matchStatus = status
    if self.m_matchStatus=="ANNOUNCED" then
        self.m_callbackUI:showAnnouncedInfo()
    elseif self.m_matchStatus=="REGISTERING" then
        self.m_callbackUI:showRegisteringInfo()
    elseif self.m_matchStatus=="SYNCING" or self.m_matchStatus=="STARTING" then
        self:getUserMatchTableInfo()
        self.m_hideKickUserButton = true
        self.m_callbackUI:showJoinTableInfo()
    else
        self.m_callbackUI:hideButtons()
        self.m_hideKickUserButton = true
    end
end

--[[报名信息]]
function MatchWaitInfoLogic:dealGetMatchUserList(content)
    if not content then
    
        return
    end
    self.m_hasApply = false
    local parser = require("app.Logic.Datas.Lobby.MatchUserList"):new()
    if(parser:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
        if(self.m_callbackUI) then
            local userList = {}
            for i=1,#parser.matchUserList do
                local player = {}
                player.first = ""..i
                player.second = StringFormat:formatName(parser.matchUserList[i].userName, 12)
                player.third = parser.matchUserList[i].userId
                userList[#userList+1] = player

                if parser.matchUserList[i].userId == myInfo.data.userId then
                    self.m_hasApply = true
                end
            end

            self.curUnum = #parser.matchUserList
            self.m_callbackUI:showMatchUserList(userList)
        end
    end
    self.m_callbackUI:updateApplyButton(self.m_hasApply)
    parser = nil
end

function MatchWaitInfoLogic:dealApplyDiyMtt(content)
    -- dump(content)
    if content and content == "0" then
        CMShowTip("恭喜您报名成功！")
        self.m_hasApply = true
        self.curUnum = self.curUnum+1
        self.m_callbackUI:updateApplyButton(true)
    elseif content and content == "-3" then
        CMShowTip("对不起，您已报名！")
    elseif content and content == "-5" then
        CMShowTip("超过报名人数限制！")
    elseif content and content == "-13001" then
        CMShowTip("德堡钻不足！")
    elseif content and content == "-12017" then
        CMShowTip("密码错误！")
    else
        CMShowTip("报名失败！")
    end
end

function MatchWaitInfoLogic:dealApplyDiyMatch(content)
    local code = tonumber(content)
    local msg = ""
    if (code and code == 0) or (code and code == 1) then
        msg = "恭喜您报名成功！"
        self.m_hasApply = true
        self.curUnum = self.curUnum+1
        self.m_callbackUI:updateApplyButton(true)
    elseif code and code == -3 then 
        msg = "您已经报名该赛事!"
    elseif code and code == -5 then  
        msg = "报名已超过人数限制" 
    elseif code and code == -12017 then
        msg = "密码错误！"
    elseif code and code == -13001 then
        msg = "德堡钻不足！"
    else
        msg = "报名失败！"
    end
    CMShowTip(msg)
end

function MatchWaitInfoLogic:dealQuitMatch(content)
    if content == "-1" then
        CMShowTip("赛事不存在！")
    elseif content == "-4" then
        CMShowTip("退赛截止时间已过！")
    elseif content == "-6" then
        CMShowTip("该赛事目前不允许退赛！")
    elseif content == "-8" then
        CMShowTip("未报名该赛事！")
    elseif content == "-10" then
        CMShowTip("人满之后不能退赛！")
    elseif content == "-403" then
        CMShowTip("未登录！")
    elseif content == "-500" then
        CMShowTip("系统异常！")
    elseif content == "-501" then
        CMShowTip("系统异常！")
    elseif content == "-10000" then
        CMShowTip("系统异常！")
    elseif content == "-12016" then
        CMShowTip("用户不存在！")
    elseif content == "-13004" then
        CMShowTip("用户状态异常！")
    else
        local code = tonumber(json.decode(content))
        if code>0 then
            CMShowTip("退赛成功！")
            self.m_hasApply = false
            self.curUnum = self.curUnum-1
            self.m_callbackUI:updateApplyButton(false)
        else
            CMShowTip("取消报名失败！")
        end
    end
end

function MatchWaitInfoLogic:dealQuitDiyMatch(content)
    if content == "-14017" then
        CMShowTip("赛事不存在！")
    elseif content == "-9" then
        CMShowTip("报名信息不存在！")
    else
        local code = tonumber(json.decode(content))
        if code>0 then
            CMShowTip("退赛成功！")
            self.m_hasApply = false
            self.curUnum = self.curUnum-1
            self.m_callbackUI:updateApplyButton(false)

            for i=1,#self.m_userList do
                if tonumber(self.m_userList[i].third) == tonumber(myInfo.data.userId) then
                    table.remove(self.m_userList, i)
                end
            end
        else
            CMShowTip("取消报名失败！")
        end
    end
end

function MatchWaitInfoLogic:dealGetBlindDSInfo(content)
    local info = require("app.Logic.Datas.Lobby.BlindDSInfo"):new()
    if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
    
        self.m_blindDSInfo = info
        local data = {}
        for i=1,#info.blindConfig do
            data[i] = {}
            data[i].first = info.blindConfig[i].blindLevel
            data[i].second = info.blindConfig[i].smallBlind.."/"..info.blindConfig[i].bigBlind
            data[i].third = info.blindConfig[i].ante
            data[i].forth = info.blindConfig[i].blindDuration.."秒"
        end
        self.m_callbackUI:showMatchBlindDSInfo(data)
        return
    end
    -- self.m_blindDSInfo = nil
end

function MatchWaitInfoLogic:dealStartDiyMatch(content)
    local jsonTable = json.decode(content)
    local info = jsonTable["INFO"]
    local code = info["CODE"]
    if code == "-14017" then
        CMShowTip("赛事不存在！")
    elseif code == "-14037" then
        CMShowTip("赛事状态错误！")
    elseif code == "-16001" then
        CMShowTip("无权限操作！")
    elseif code == "-16003" then
        CMShowTip("报名人数不足！")
    end
end

function MatchWaitInfoLogic:dealKickApply(content)
    if content == "1" then
        CMShowTip("成功踢出玩家！")
    else
        CMShowTip("踢出玩家失败！")
    end
    self:getMatchUserList()
end

-- function MatchWaitInfoLogic:dealPrizeInfo(strJson)

--     self.m_prizeResponed = true
--     if(not strJson) then
--         return
--     end
    
--     local parser = require("app.Logic.Datas.Admin.PrizeList"):new()
--     if(parser:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
    
--         self.m_prizeInfoList = parser.prizeInfoList
--         if(self.m_gainResponed) then
        
--             self:enterDealRewardLogic()
--         end
--     end
--     parser = nil
-- end

-- function MatchWaitInfoLogic:dealGainInfoByName(strJson)

--     self.m_gainResponed = true
--     if(not strJson) then
    
--         return
--     end
--     local parser = require("app.Logic.Datas.Admin.GainList"):new()
--     if(parser:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
    
--         self.m_gainInfoList = parser.gainInfoList
--         if(self.m_prizeResponed) then
        
--             self:enterDealRewardLogic()
--         end
--     end
--     parser = nil
-- end
---------------------------------------------------------------------------
local MatchWaitInfo = class("MatchWaitInfo", function()
	return display.newLayer()
end)

function MatchWaitInfo:create()
	self:initUI()
end

function MatchWaitInfo:ctor(params)
    self.m_logic = MatchWaitInfoLogic.new({m_callbackUI = self, data = params})
    self.m_logic:addTo(self)

    self.params = params or {}
    self.isOwner = tonumber(self.params.ownerId)==tonumber(myInfo.data.userId)
end

function MatchWaitInfo:initUI()
    -- self.currentLayerId = WaitInfoLayer.MatchDetail
	self.background = cc.ui.UIImage.new("picdata/public2/background.png", {scale9 = true})
    self.background:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
        :addTo(self)
    self.background:setLayoutSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)

    --[[返回按钮]]
    local backBtn = cc.ui.UIPushButton.new({normal="picdata/public/back.png", pressed="picdata/public/back.png",
        disabled="picdata/public/back.png"})
    backBtn:align(display.CENTER, 57, topItemPosY)
        :onButtonClicked(handler(self, self.pressBack))
        :addTo(self)

	local titleBg = cc.ui.UIImage.new("picdata/public2/bg_title.png")
		:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, topItemPosY-10)
		:addTo(self)

    self.roomType = self.params.playType or "MTT"

    local titlePath = "picdata/matchWait/w_title_mtt.png"
    if self.roomType~="MTT" then
    	titlePath = "picdata/matchWait/w_title_sng.png"
    end
    local title = cc.ui.UIImage.new(titlePath)
		:align(display.CENTER, titleBg:getPositionX(), titleBg:getPositionY()+10)
		:addTo(self)

	local buttonPadding = 160
	local buttonPos = 60
	self.cancelButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_blue.png", pressed="picdata/public/btn_blue2.png", 
		disabled="picdata/public/btn_blue2.png"})
	self.cancelButton:align(display.CENTER, CONFIG_SCREEN_WIDTH/2-buttonPadding, buttonPos)
		:addTo(self, 1)
		:onButtonClicked(function(event)
			self:pressCancelMatch(event)
			end)
		:setTouchSwallowEnabled(false)

	self.confirmButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", pressed="picdata/public/btn_green2.png", 
		disabled="picdata/public/btn_green2.png"})
	self.confirmButton:align(display.CENTER, CONFIG_SCREEN_WIDTH/2+buttonPadding, buttonPos)
		:addTo(self, 1)
		:onButtonClicked(function(event)
			self:pressStartMatch(event)
			end)
		:setTouchSwallowEnabled(false)

    self.joinMatchButton = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", pressed="picdata/public/btn_green2.png", 
        disabled="picdata/public/btn_green2.png"})
    self.joinMatchButton:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, buttonPos)
        :addTo(self, 1)
        :onButtonClicked(function(event)
            self:pressJoinMatch(event)
            end)
        :setTouchSwallowEnabled(false)

	-- local label = cc.ui.UILabel.new({
	-- 	text = "报名",
	-- 	font = "黑体",
	-- 	size = 32,
	-- 	color = cc.c3b(189,211,255)
	-- 	})
 --    label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
	-- self.cancelButton:setButtonLabel("normal", label)
 --    label:setVisible(false)

	-- local label1 = cc.ui.UILabel.new({
	-- 	text = "立即开赛",
	-- 	font = "黑体",
	-- 	size = 32,
	-- 	color = cc.c3b(215,255,178)
	-- 	})
 --    label1:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
	-- self.confirmButton:setButtonLabel("normal", label1)
 --    label1:setVisible(false)

 --    local label2 = cc.ui.UILabel.new({
 --        text = "进入比赛",
 --        font = "黑体",
 --        size = 32,
 --        color = cc.c3b(215,255,178)
 --        })
 --    label2:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
 --    self.joinMatchButton:setButtonLabel("normal", label2)
 --    self.joinMatchButton:setVisible(false)
 --    label2:setVisible(false)

    self.applyMatchTitle = cc.ui.UIImage.new("picdata/matchWait/w_bm.png")
    self.applyMatchTitle:align(display.CENTER, 0, 0):addTo(self.cancelButton)

    self.startMatchTitle = cc.ui.UIImage.new("picdata/matchWait/w_ljks.png")
    self.startMatchTitle:align(display.CENTER, 0, 0):addTo(self.confirmButton)

    self.joinMatchTitle = cc.ui.UIImage.new("picdata/matchWait/w_jrss.png")
    self.joinMatchTitle:align(display.CENTER, 0, 0):addTo(self.joinMatchButton)
    self.joinMatchButton:setVisible(false)

    self.announceHint = cc.ui.UILabel.new({
                    text = "公告中...",
                    font = "Arial",
                    size = 26,
                    color = cc.c3b(0,255,225)
                    }) 
    self.announceHint:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, buttonPos)
    self.announceHint:addTo(self)
    self.announceHint:setVisible(false)

    if not self.isOwner or self.roomType~= "MTT" then
        self.cancelButton:setPositionX(CONFIG_SCREEN_WIDTH/2)
        self.confirmButton:setVisible(false)
    end

	self.m_dialogBg = cc.ui.UIImage.new("picdata/public2/bg_tc2.png", {scale9 = true})
		:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
		:addTo(self)
	self.m_dialogBg:setLayoutSize(928, 412)
	----------------------------------------------------------------------------
	self.bgTop = cc.ui.UIImage.new("picdata/matchWait/bg_top.png", {scale9 = true})
		:align(display.CENTER_TOP, self.m_dialogBg:getContentSize().width/2, 
			self.m_dialogBg:getContentSize().height)
		:addTo(self.m_dialogBg)
	self.bgTop:setLayoutSize(946, 66)

	local padding = 140
	local posx = self.bgTop:getContentSize().width/2+18
	local posy = self.bgTop:getContentSize().height/2+5
	self.tableIdHint1 = cc.ui.UILabel.new({
	                text = "牌局ID:",
	                font = "Arial",
	                size = 26,
	                color = cc.c3b(0,255,225)
	                }) 
	self.tableIdHint1:align(display.RIGHT_CENTER, posx-padding, posy)
	self.tableIdHint1:addTo(self.bgTop)

	self.tableIdHint2 = cc.ui.UILabel.new({
	                text = ""..self.params.matchId,
	                font = "Arial",
	                size = 26,
	                color = cc.c3b(0,255,225)
	                }) 
	self.tableIdHint2:align(display.LEFT_CENTER, self.tableIdHint1:getPositionX(), self.tableIdHint1:getPositionY())
	self.tableIdHint2:addTo(self.bgTop)

	self.signedNumHint1 = cc.ui.UILabel.new({
	                text = "已报名:",
	                font = "Arial",
	                size = 26,
	                color = cc.c3b(0,255,225)
	                }) 
	self.signedNumHint1:align(display.RIGHT_CENTER, posx+padding, self.tableIdHint1:getPositionY())
	self.signedNumHint1:addTo(self.bgTop)

	self.signedNumHint2 = cc.ui.UILabel.new({
	                text = ""..self.m_logic.curUnum,
	                font = "Arial",
	                size = 26,
	                color = cc.c3b(0,255,225)
	                }) 
	self.signedNumHint2:align(display.LEFT_CENTER, self.signedNumHint1:getPositionX(), self.tableIdHint1:getPositionY())
	self.signedNumHint2:addTo(self.bgTop)
	----------------------------------------------------------------------------
	self.tabBg = cc.ui.UIImage.new("picdata/public2/btn_tags_bg.png", {scale9 = true})
		:align(display.CENTER_TOP, self.bgTop:getPositionX(), 
			self.bgTop:getPositionY()-65)
		:addTo(self.m_dialogBg)
	self.tabBg:setLayoutSize(808, 50) 

	local button_images1 = {
        off = "picdata/public2/btn_tags.png",
        off_pressed = "picdata/public2/btn_tags2.png",
        off_disabled = "picdata/public2/btn_tags2.png",
        on = "picdata/public2/btn_tags2.png",
        on_pressed = "picdata/public2/btn_tags.png",
        on_disabled = "picdata/public2/btn_tags2.png",
    }
    local button_images2 = {
        off = "picdata/public2/btn_tags.png",
        off_pressed = "picdata/public2/btn_tags2.png",
        off_disabled = "picdata/public2/btn_tags2.png",
        on = "picdata/public2/btn_tags2.png",
        on_pressed = "picdata/public2/btn_tags.png",
        on_disabled = "picdata/public2/btn_tags2.png",
    }
    local button_images3 = {
        off = "picdata/public2/btn_tags.png",
        off_pressed = "picdata/public2/btn_tags2.png",
        off_disabled = "picdata/public2/btn_tags2.png",
        on = "picdata/public2/btn_tags2.png",
        on_pressed = "picdata/public2/btn_tags.png",
        on_disabled = "picdata/public2/btn_tags2.png",
    }
    local button_images4 = {
        off = "picdata/public2/btn_tags.png",
        off_pressed = "picdata/public2/btn_tags2.png",
        off_disabled = "picdata/public2/btn_tags2.png",
        on = "picdata/public2/btn_tags2.png",
        on_pressed = "picdata/public2/btn_tags.png",
        on_disabled = "picdata/public2/btn_tags2.png",
    }
    local button_images5 = {
        off = "picdata/matchWait/w_tag_ssxq.png",
        off_pressed = "picdata/matchWait/w_tag_ssxq2.png",
        off_disabled = "picdata/matchWait/w_tag_ssxq2.png",
        on = "picdata/matchWait/w_tag_ssxq2.png",
        on_pressed = "picdata/matchWait/w_tag_ssxq.png",
        on_disabled = "picdata/matchWait/w_tag_ssxq2.png",
    }
    local button_images6 = {
        off = "picdata/matchWait/w_tag_wjlb.png",
        off_pressed = "picdata/matchWait/w_tag_wjlb2.png",
        off_disabled = "picdata/matchWait/w_tag_wjlb2.png",
        on = "picdata/matchWait/w_tag_wjlb2.png",
        on_pressed = "picdata/matchWait/w_tag_wjlb.png",
        on_disabled = "picdata/matchWait/w_tag_wjlb2.png",
    }
    local button_images7 = {
        off = "picdata/matchWait/w_tag_jl.png",
        off_pressed = "picdata/matchWait/w_tag_jl2.png",
        off_disabled = "picdata/matchWait/w_tag_jl2.png",
        on = "picdata/matchWait/w_tag_jl2.png",
        on_pressed = "picdata/matchWait/w_tag_jl.png",
        on_disabled = "picdata/matchWait/w_tag_jl2.png",
    }
    local button_images8 = {
        off = "picdata/matchWait/w_tag_sm.png",
        off_pressed = "picdata/matchWait/w_tag_sm2.png",
        off_disabled = "picdata/matchWait/w_tag_sm2.png",
        on = "picdata/matchWait/w_tag_sm2.png",
        on_pressed = "picdata/matchWait/w_tag_sm.png",
        on_disabled = "picdata/matchWait/w_tag_sm2.png",
    }
    local width = 200
    local height = 46
    self.matchInfoButton = cc.ui.UIPushButton.new({normal="picdata/matchWait/w_tag_ssxq.png", pressed="picdata/matchWait/w_tag_ssxq2.png", 
            disabled="picdata/matchWait/w_tag_ssxq2.png"})
    self.matchInfoButton:align(display.CENTER, width/2+2, height/2+2)
        :addTo(self.tabBg, 1)
        :setTouchSwallowEnabled(false)

    self.playerListButton = cc.ui.UIPushButton.new({normal="picdata/matchWait/w_tag_wjlb.png", pressed="picdata/matchWait/w_tag_wjlb2.png", 
            disabled="picdata/matchWait/w_tag_wjlb2.png"})
    self.playerListButton:align(display.CENTER, width*3/2, height/2+2)
        :addTo(self.tabBg, 1)
        :setTouchSwallowEnabled(false)

    self.awardButton = cc.ui.UIPushButton.new({normal="picdata/matchWait/w_tag_jl.png", pressed="picdata/matchWait/w_tag_jl2.png", 
            disabled="picdata/matchWait/w_tag_jl2.png"})
    self.awardButton:align(display.CENTER, width*5/2, height/2+2)
        :addTo(self.tabBg, 1)
        :setTouchSwallowEnabled(false)

    self.upsecondButton = cc.ui.UIPushButton.new({normal="picdata/matchWait/w_tag_sm.png", pressed="picdata/matchWait/w_tag_sm2.png", 
            disabled="picdata/matchWait/w_tag_sm2.png"})
    self.upsecondButton:align(display.CENTER, width*7/2, height/2+2)
        :addTo(self.tabBg, 1)
        :setTouchSwallowEnabled(false)

    width = 204
    local button1 = cc.ui.UICheckBoxButton.new(button_images1, {scale9 = true})
            :align(display.CENTER)
    button1:setButtonSize(width, height)
    local button2 = cc.ui.UICheckBoxButton.new(button_images2, {scale9 = true})
            :align(display.CENTER)
    button2:setButtonSize(width, height)
    local button3 = cc.ui.UICheckBoxButton.new(button_images3, {scale9 = true})
            :align(display.CENTER)
    button3:setButtonSize(width, height)
    local button4 = cc.ui.UICheckBoxButton.new(button_images4, {scale9 = true})
            :align(display.CENTER)
    button4:setButtonSize(width, height)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
        :addButton(button1)
        :addButton(button2)
        :addButton(button3)
        :addButton(button4)
        :setButtonsLayoutMargin(0, -2, 0, -2)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            if event.selected==1 then
                self.matchInfoButton:setButtonEnabled(false)
                self.playerListButton:setButtonEnabled(true)
                self.awardButton:setButtonEnabled(true)
                self.upsecondButton:setButtonEnabled(true)
                self:switchLayer(WaitInfoLayer.MatchDetail)
            elseif event.selected==2 then
                self.matchInfoButton:setButtonEnabled(true)
                self.playerListButton:setButtonEnabled(false)
                self.awardButton:setButtonEnabled(true)
                self.upsecondButton:setButtonEnabled(true)
                self:switchLayer(WaitInfoLayer.PlayerList)
            elseif event.selected==3 then
                self.matchInfoButton:setButtonEnabled(true)
                self.playerListButton:setButtonEnabled(true)
                self.awardButton:setButtonEnabled(false)
                self.upsecondButton:setButtonEnabled(true)
                self:switchLayer(WaitInfoLayer.Award)
            elseif event.selected==4 then
                self.matchInfoButton:setButtonEnabled(true)
                self.playerListButton:setButtonEnabled(true)
                self.awardButton:setButtonEnabled(true)
                self.upsecondButton:setButtonEnabled(false)
                self:switchLayer(WaitInfoLayer.Upsecond)
            end
        end)
        :align(display.CETNER, 2, 2)
        :addTo(self.tabBg)
        -- group:getButtonAtIndex(5):setPosition(760, 34)
        group:getButtonAtIndex(1):setButtonSelected(true)

	----------------------------------------------------------------------------

	if self.roomType~="MTT" then
    	self:initSNG()
    else
    	self:initMTT()
    end
end

function MatchWaitInfo:showAnnouncedInfo()
    self.announceHint:setVisible(true)
    self.cancelButton:setVisible(false)
    self.confirmButton:setVisible(false)
    self.joinMatchButton:setVisible(false)
end

function MatchWaitInfo:showRegisteringInfo()
    self.announceHint:setVisible(false)
    self.cancelButton:setVisible(true)
    self.confirmButton:setVisible(true)
    self.joinMatchButton:setVisible(false)

    if not self.isOwner or self.roomType~= "MTT" then
        self.cancelButton:setPositionX(CONFIG_SCREEN_WIDTH/2)
        self.confirmButton:setVisible(false)
    end
end

function MatchWaitInfo:showJoinTableInfo()
    self.announceHint:setVisible(false)
    self.cancelButton:setVisible(false)
    self.confirmButton:setVisible(false)
end

function MatchWaitInfo:showJoinTableButton()
    self.joinMatchButton:setVisible(true)
end

function MatchWaitInfo:hideButtons()
    self.announceHint:setVisible(false)
    self.cancelButton:setVisible(false)
    self.confirmButton:setVisible(false)
    self.joinMatchButton:setVisible(false)
end

function MatchWaitInfo:initSNG()
    self.tableIdHint1:setString("牌桌名:")
    self.tableIdHint2:setString(self.params.tableName)
end

function MatchWaitInfo:initMTT()
    local timeBg = cc.ui.UIImage.new("picdata/matchWait/bg_time.png")
		:align(display.RIGHT_CENTER, CONFIG_SCREEN_WIDTH-20, topItemPosY-8)
		:addTo(self)
	local timeData = {timestamp=3679,color=cc.c3b(255,102,0),padding=21, length=3,
		position = cc.p(CONFIG_SCREEN_WIDTH-153,topItemPosY-2)}	
	self.timeLabel = require("app.GUI.dialogs.CountDownTimeLabel").new(timeData)
	self.timeLabel:addTo(self,1)
	self.timeLabel:create()
end

function MatchWaitInfo:updateMTTTime(timestamp)
    self.timeLabel:setTimestamp(timestamp)
end

function MatchWaitInfo:showMatchDetail(data)
    if self.currentLayerId ~= WaitInfoLayer.MatchDetail then
        return
    end
    if self.m_currentLayer then
        self.m_currentLayer:removeFromParent(true)
        self.m_currentLayer = nil
    end
    local width = self.m_dialogBg:getContentSize().width
    local height = self.m_dialogBg:getContentSize().height-115
    local layer = require("app.GUI.matchWait.MatchWaitDetail").new({
        viewRect = cc.rect(0,0,width,height),
        matchInfo = data,
        roomType = self.roomType})
    layer:create()
    layer:addTo(self.m_dialogBg,10)
    layer:setPosition(0, 0)
    self.m_currentLayer = layer
end

function MatchWaitInfo:showMatchUserList(data)
    if self.currentLayerId ~= WaitInfoLayer.PlayerList then
        return
    end
    if self.m_currentLayer then
        self.m_currentLayer:removeFromParent(true)
        self.m_currentLayer = nil
    end
    local width = self.m_dialogBg:getContentSize().width
    local height = self.m_dialogBg:getContentSize().height-115
    local layer = require("app.GUI.matchWait.MatchWaitUserList").new({
        viewRect = cc.rect(0,0,width,height),
        data = data,
        isOwner = self.isOwner,
        roomType = self.roomType,
        hideKickButton = self.m_logic.m_hideKickUserButton,
        kickUserCallback = function(userId) self:kickApplyUser(userId) end})
    layer:create()
    layer:addTo(self.m_dialogBg,10)
    layer:setPosition(0, 0)
    self.m_currentLayer = layer
end

function MatchWaitInfo:showMatchRewardList(data)
    if self.currentLayerId ~= WaitInfoLayer.Award then
        return
    end
    if self.m_currentLayer then
        self.m_currentLayer:removeFromParent(true)
        self.m_currentLayer = nil
    end
    local width = self.m_dialogBg:getContentSize().width
    local height = self.m_dialogBg:getContentSize().height-115
    local layer = require("app.GUI.matchWait.MatchWaitRewardList").new({
        viewRect = cc.rect(0,0,width,height),
        data = data,
        roomType = self.roomType})
    layer:create()
    layer:addTo(self.m_dialogBg,10)
    layer:setPosition(0, 0)
    self.m_currentLayer = layer
end

function MatchWaitInfo:showMatchBlindDSInfo(data)
    if self.currentLayerId ~= WaitInfoLayer.Upsecond then
        return
    end
    if self.m_currentLayer then
        self.m_currentLayer:removeFromParent(true)
        self.m_currentLayer = nil
    end
    local width = self.m_dialogBg:getContentSize().width
    local height = self.m_dialogBg:getContentSize().height-115
    local layer = require("app.GUI.matchWait.MatchWaitBlindDSInfo").new({
        viewRect = cc.rect(0,0,width,height),
        data = data})
    layer:create()
    layer:addTo(self.m_dialogBg,10)
    layer:setPosition(0, 0)
    self.m_currentLayer = layer
end

function MatchWaitInfo:pressBack(event)
	CMClose(self)
end

function MatchWaitInfo:updateApplyButton(hasApply)
    self.m_hasApply = hasApply
    if self.m_hasApply == true then
        -- self.cancelButton:setButtonLabelString("normal", "取消报名")
        self.applyMatchTitle:setTexture("picdata/matchWait/w_qxbm.png")
        -- if self.roomType~="MTT" then
            -- self.cancelButton:setVisible(false)
        -- end
    else
        -- self.cancelButton:setButtonLabelString("normal", "报名")
        self.applyMatchTitle:setTexture("picdata/matchWait/w_bm.png")
    end
    self.signedNumHint2:setString(""..self.m_logic.curUnum)
end

function MatchWaitInfo:pressCancelMatch(event)
    if self.m_hasApply == true then
        self.m_logic:quitMatch()
    else
        self.m_operation = WaitInfoOperation.ApplyMatch
        if self.isOwner and self.roomType and self.roomType=="MTT" then
            self:enterPswCallback({passsword=""})
        else
            self:showEnterPsdDialog()
        end
    end
end

function MatchWaitInfo:showEnterPsdDialog()
    local dialog = require("app.GUI.hallview.EnterPasswordDialog").new({m_pCallbackUI = function(params) self:enterPswCallback(params) end})
    dialog:addTo(self, 1001)
    dialog:show()
end

function MatchWaitInfo:enterPswCallback(params)
    self.m_logic:updatePsd(params.passsword)
    if self.m_operation == WaitInfoOperation.ApplyMatch then
        if self.roomType == "MTT" then
            self.m_logic:applyDiyMtt()
        else
            self.m_logic:applyDiyMatch() 
        end
    elseif self.m_operation == WaitInfoOperation.StartMatch then
        self.m_logic:startDiyMatch()
    elseif self.m_operation == WaitInfoOperation.JoinMatch then
        self.m_logic:joinMatch()
    end
end

function MatchWaitInfo:pressStartMatch(event)
    self.m_logic:startDiyMatch()
    -- self.m_operation = WaitInfoOperation.StartMatch
    -- self:showEnterPsdDialog()
end

function MatchWaitInfo:pressJoinMatch(event)
    self.m_operation = WaitInfoOperation.JoinMatch
    self:showEnterPsdDialog()
end

function MatchWaitInfo:switchLayer(layerId)
    if self.currentLayerId == layerId then
        return
    end
    self.currentLayerId = layerId
    if layerId == WaitInfoLayer.MatchDetail then
        if self.roomType == "MTT" then
            self.m_logic:getMatchInfo()
        else
            self:showMatchDetail(self.params)
        end
    elseif layerId == WaitInfoLayer.PlayerList then
        if self.roomType == "MTT" then
            self.m_logic:getMatchUserList()
        else
            self:showMatchUserList(self.m_logic.m_userList)
        end
    elseif layerId == WaitInfoLayer.Award then
        if self.roomType == "MTT" then
            self.m_logic:getPrizeInfo()
        else
            self:showMatchRewardList()
        end
    elseif layerId == WaitInfoLayer.Upsecond then
        self.m_logic:getBlindDSInfo()
    end
end

function MatchWaitInfo:kickApplyUser(userId)
    self.m_logic:kickApply(userId)
end

return MatchWaitInfo