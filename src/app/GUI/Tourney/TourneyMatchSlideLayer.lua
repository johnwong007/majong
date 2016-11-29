require("app.Network.Http.DBHttpRequest")
require("app.Logic.Room.MatchRankLogic")

TourneyStateUnkown = 0
TourneyStateSignUp = 1
TourneyStateSigned = 2
TourneyStateFull = 3
TourneyStateJoin = 4
TourneyStatePlaying = 5
TourneyStateDelay = 6

local TourneyInfoSl =
{
    index = 0,
    isSaved = 0,
    chimpionName = "",
    chimpionImage = "",
    imagePath = "",
    state = 0,
    tableId = "",
}

local CELL_SIZE = cc.size(334,420)
local TAG_INFO_DIALOG = 555

local eTagOnline = 10
local eTagLight = 11
local eTagMatchName = 12
local eTagTime = 13
local eTagTimeLabel = 14
local eTagTimeMask = 15
local eTagMatchStatus = 16
local eTagLogo = 17
local eTagSignNum = 18
local eTagSignBtn = 19
local eTagCell = 20
local eTagPageTab = 21


local AlertApplyResult=1
local AlertNewerProtect=2
local AlertApplyMatch=3
local AlertNetworkError=4
local AlertApplyResultToStore=5
local AlertApplyResultToQuickStart=6
local AlertApplyToSng=7
local AlertQuitMatch=8
local AlertQuitTourney=9



local TourneyMatchSlideLayer = class("TourneyMatchSlideLayer", function()
		return display.newLayer()
	end)

function TourneyMatchSlideLayer:create(matchGroupInfo)
    local layer  = TourneyMatchSlideLayer:new()
    layer:setMatchList(matchGroupInfo)
    if layer and layer:init() then
        layer:ignoreAnchorPointForPosition(false)
        return layer
    else
        layer = nil
        return nil
    end
end

function TourneyMatchSlideLayer:ctor()
	self.m_signupIndex = 0
    self.m_beginDistance = 0.0
    self.m_endDistance = 0.0
    self.m_matchList = {}
    self.m_totalInfo = {}
    self.m_scrollView = nil
    self.m_infoDialogHasShown = false
    self.m_filename = {}
end

function TourneyMatchSlideLayer:setMatchList(matchGroupInfo)
	self.m_matchList = matchGroupInfo
end

function TourneyMatchSlideLayer:init()
    self.m_totalInfo = {}
    -- dump(self.m_matchList)
    for i=1,#self.m_matchList do
    	
        local headImage = "http://cache.debao.com"
		if SERVER_ENVIROMENT == ENVIROMENT_TEST then
        	headImage = "http://debaocache.boss.com"
        end
        local info = clone(TourneyInfoSl)
        
        info.index = i
        info.chimpionImage = headImage..self.m_matchList[i].mobilePic
        info.chimpionName = self.m_matchList[i].mobilePic
        info.imagePath = ""

        if (info.chimpionName ~="") then
            info.isSaved = 0
            
           	local state = TourneyStateUnkown
            local regStatus = self.m_matchList[i].regStatus
            if(regStatus == 0) then
                state = TourneyStateSignUp
            else
                state = TourneyStateSigned
            end
            
            local bFull = self.m_matchList[i].curUnum+0 >= self.m_matchList[i].maxUnum+0
            if(bFull) then
                state = TourneyStateFull
            end
            if (self.m_matchList[i].matchStatus ~= "REGISTERING") then
            

            end
            
            info.state = state
            
            
            local resPath = cc.FileUtils:getInstance():getWritablePath()
            local filePath = ""
            local tmpPos = 1
            local strLen = string.len(info.chimpionName)
            for i=strLen,1,-1 do
            	if string.sub(info.chimpionName,i,i)=="/" then
            		tmpPos = i
            		break
            	end
            end
            local filename = string.sub(info.chimpionName,tmpPos+1,strLen)
            self.m_filename[#self.m_totalInfo+1] = filename
			filePath = resPath..filename
			local file = io.open(filePath,"r")
			if (not file) then
                --不存在就下载
				DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse), info.chimpionImage, info.chimpionName, false, #self.m_totalInfo+1)
			else
	
				--存在就读本地的
				io.close(file)
                info.isSaved =1
                --存在就读本地的
                info.imagePath = filePath
			end
 
            self.m_totalInfo[#self.m_totalInfo+1] = info
        end
    end

    -- dump(self.m_totalInfo)
    local cellBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/tourneyCellBG.png")
    local signBtnTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/sign.png")
    local nullBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/nullCellBG.png")
    local rebuyTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/rebuyIcon.png")
    local addonTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/addonIcon.png")
    local goldTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/signTypeGold.png")
    local rakepointTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/signTypeRakePoint.png")

    
    local goldBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/jb.png")
    local rakepointBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/jf.png")
    local czkBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/czk.png")
    local lightBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/tourneyCellBGlight.png")

    local timeLabelBGTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/jbs_time_bg.png")
    local timeLabelMaskTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/jbs_time_net.png")

    local subscriptTexure = cc.Director:getInstance():getTextureCache():addImage("picdata/tourney/subscript.png")

    -- self:setContentSize(cc.size(CELL_SIZE.width*3,CELL_SIZE.height))
    local container = display.newNode()
   	local num = #self.m_matchList
    -- local first = cc.Sprite:createWithTexture(nullBGTexure)
    -- first:setAnchorPoint(cc.p(0.5, 0.5))
    -- first:setPosition(cc.p(CELL_SIZE.width/2, CELL_SIZE.height/2+80))
    -- container:addChild(first)
    local background = cc.Sprite:createWithTexture(cellBGTexure)
    local signButton = cc.Sprite:createWithTexture(signBtnTexure)
    for i=1,num do
        local bg = cc.Sprite:createWithTexture(nullBGTexure)
        -- bg:setPosition(cc.p(CELL_SIZE.width/2 + (CELL_SIZE.width+30)*i,CELL_SIZE.height/2-15))
        bg:setPosition(cc.p(CELL_SIZE.width/2 + (CELL_SIZE.width+30)*(i-1),CELL_SIZE.height/2-15))
        bg:setTag(eTagPageTab+i-1)
        -- local cellMenuitem = cc.MenuItemImage:create()
		-- cellMenuitem:setNormalSpriteFrame(background:getSpriteFrame())
		-- cellMenuitem:setSelectedSpriteFrame(background:getSpriteFrame())
		-- cellMenuitem:registerScriptTapHandler(handler(self,self.cellCallBack))
		-- cellMenuitem:setPosition(cc.p(0,0))
        --cellMenuitem:setAnchorPoint(cc.p(0,0))
		-- cellMenuitem:setTag(eTagCell+i-1)
		-- local cellMenu = cc.Menu:create(cellMenuitem)
		-- cellMenu:setPosition(cc.p(0,0))

        local cellMenu = cc.ui.UIPushButton.new({normal="picdata/tourney/tourneyCellBG.png",pressed="picdata/tourney/tourneyCellBG.png",
            disabled="picdata/tourney/tourneyCellBG.png"})
        cellMenu:align(display.BOTTOM_LEFT, 0, 0)
            :onButtonClicked(handler(self,self.cellCallBack))
        cellMenu:setTag(eTagCell+i-1)
        cellMenu:setTouchSwallowEnabled(false)

        local payTypeIcon = nil
        if (self.m_matchList[i].payType == "RAKEPOINT") then
            payTypeIcon = cc.Sprite:createWithTexture(rakepointTexure)
        else
            payTypeIcon = cc.Sprite:createWithTexture(goldTexure)
        end
        payTypeIcon:setAnchorPoint(cc.p(0.5,0.5))
        payTypeIcon:setPosition(cc.p(173,86))
        

		-- local signMenuitem = cc.MenuItemImage:create()
		-- signMenuitem:setAnchorPoint(cc.p(0.5, 0.5))
		-- signMenuitem:setNormalSpriteFrame(signButton:getSpriteFrame())
		-- signMenuitem:setSelectedSpriteFrame(signButton:getSpriteFrame())
		-- signMenuitem:registerScriptTapHandler(handler(self,self.signBtnCallBack))
		-- signMenuitem:setPosition(cc.p(CELL_SIZE.width/2,85))
		-- signMenuitem:setTag(eTagCell+i-1)
		-- local signMenu = cc.Menu:create(signMenuitem)
		-- signMenu:setPosition(cc.p(0,0))

        local signMenu = cc.ui.UIPushButton.new({normal="picdata/tourney/sign.png",pressed="picdata/tourney/sign.png",
            disabled="picdata/tourney/sign.png"})
        signMenu:align(display.CENTER, CELL_SIZE.width/2, 85)
            :onButtonClicked(handler(self,self.signBtnCallBack))
        signMenu:setTag(eTagSignBtn+i-1)

        local payNum = StringFormat:FormatDecimals(self.m_matchList[i].payNum+self.m_matchList[i].serviceCharge,2)
        
        local payNumLabel = cc.LabelBMFont:create(payNum,"picdata/gamescene/chipNumSmall.fnt")
        payNumLabel:setAnchorPoint(cc.p(0, 0.5))
        payNumLabel:setPosition(cc.p(200, 86))
        
        local timeLabelBg = cc.Sprite:createWithTexture(timeLabelBGTexure)
        local timeLabelMask = cc.Sprite:createWithTexture(timeLabelMaskTexure)
        timeLabelBg:setPosition(cc.p(CELL_SIZE.width/2, 365))
        timeLabelMask:setPosition(cc.p(CELL_SIZE.width/2, 365))

        
        local time = EStringTime:create(self.m_matchList[i].preSetStartTime)
        local showTime = time:get_mmddhh_time()
        local timeLabel = cc.LabelTTF:create(showTime, "黑体", 30)
        timeLabel:setAnchorPoint(cc.p(0.5,0.5))
        timeLabel:setPosition(cc.p(CELL_SIZE.width/2, 365))
       
        timeLabel:setColor(cc.c3b(0, 255, 174))
      
        local signPlayer = self.m_matchList[i].curUnum .. "人"
        local signNum = cc.LabelTTF:create(signPlayer, "黑体", 29)
        signNum:setColor(cc.c3b(1, 250, 221))
        signNum:setAnchorPoint(cc.p(1, 0.5))
        signNum:setPosition(cc.p(280, 148))
        
        bg:addChild(cellMenu,1)
        bg:addChild(signMenu,2)
        --        没有mobilePic  则使用本地资源
        if (self.m_matchList[i].mobilePic == "") then
            local goldBG = nil
            local top = "金币"
            local bottom = "赛"
            local topLabel
            local bottomLabel
            local npos = nil
         
            if (self.m_matchList[i].tourneyMatchType == "金币") then
                
                goldBG = cc.Sprite:createWithTexture(goldBGTexure)
                npos,_ = string.find(self.m_matchList[i].matchName, "金币")
            elseif(self.m_matchList[i].tourneyMatchType == "话费") then
                goldBG = cc.Sprite:createWithTexture(czkBGTexure)
                npos,_ = string.find(self.m_matchList[i].matchName, "话费")
            else
                goldBG = cc.Sprite:createWithTexture(rakepointBGTexure)
                npos,_ = string.find(self.m_matchList[i].matchName, "积分")
            end

            if npos then
            	top = string.sub(self.m_matchList[i].matchName, 1, npos-1)
            	bottom = string.sub(self.m_matchList[i].matchName, npos)
        	end
            goldBG:setPosition(cc.p(167,255))
            bg:addChild(goldBG,2,eTagLogo)

            if (self.m_matchList[i].payNum+0.0>0) then
                topLabel = cc.LabelBMFont:create(top,"picdata/tourney/jbs_w-export.fnt")
                bottomLabel  = cc.LabelBMFont:create(bottom,"picdata/tourney/jbs_w-export.fnt")
            else
                topLabel = cc.LabelBMFont:create(top,"picdata/tourney/jbs_w_free-export.fnt")
                bottomLabel  = cc.LabelBMFont:create(bottom,"picdata/tourney/jbs_w_free-export.fnt")
            end
            topLabel:setPosition(cc.p(167 , 282))
            topLabel:setScale(0.96)
            bg:addChild(topLabel,3)
            
            bottomLabel:setPosition(cc.p(167, 226))
            bottomLabel:setScale(0.95)
            bg:addChild(bottomLabel,3)
            
        end
        bg:addChild(timeLabelBg,3,eTagTime)
        bg:addChild(timeLabel,3,eTagTimeLabel)
        bg:addChild(timeLabelMask,3,eTagTimeMask)
        bg:addChild(signNum,4)
        bg:addChild(payNumLabel,5)
        bg:addChild(payTypeIcon,5)
        
        local addonIcon = cc.Sprite:createWithTexture(addonTexure)
        addonIcon:setPosition(cc.p(64, 148))
        addonIcon:setAnchorPoint(cc.p(0.5, 0.5))
        bg:addChild(addonIcon,5)
        if (self.m_matchList[i].isRebuy) then
            local rebuyIcon = cc.Sprite:createWithTexture(rebuyTexure)
            rebuyIcon:setPosition(cc.p(99, 148))
            rebuyIcon:setAnchorPoint(cc.p(0.5, 0.5))
            bg:addChild(rebuyIcon,5)
        end
        
        local light = cc.Sprite:createWithTexture(lightBGTexure)
        light:setPosition(cc.p(0,0))
        light:setAnchorPoint(cc.p(0,0))
        bg:addChild(light,8,eTagLight)
        light:setVisible(false)
        
        if (self.m_matchList[i].payNum+0.0 == 0.0) then
            local subscript = cc.Sprite:createWithTexture(subscriptTexure)
            subscript:setAnchorPoint(cc.p(0,1))
            subscript:setPosition(cc.p(17,403))
            bg:addChild(subscript,9)
        end

        bg:setScale(0.8)
        container:addChild(bg)
        if i==2 then
            bg:setScale(0.9)
        end
    end

    local size = cc.Director:getInstance():getWinSize()
    -- self.m_scrollView = cc.ScrollView:create(cc.size((CELL_SIZE.width+30)*(num+2), CELL_SIZE.height),container)
    -- self.m_scrollView:setAnchorPoint(cc.p(0, 0))
    -- self.m_scrollView:setPosition(cc.p(0, 0))
    -- self.m_scrollView:setDirection(0)
    -- self.m_scrollView:setDelegate()
    -- self:addChild(self.m_scrollView, 555)
    -- self.m_scrollView:setContentOffset(cc.p(0, 0))

    container:setPosition(cc.p(0,0))

    self.m_startX=-1000
    local bound = {x = 0, y = -60, width=size.width, height=CELL_SIZE.height}

    self.m_scrollView = cc.ui.UIScrollView.new({
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        viewRect = bound,
           -- bgColor = cc.c4b(255,0,0,255)
        })
    self.m_scrollView:addScrollNode(container)
    self.m_scrollView:onScroll(function (event)
                if event.name == "began" then
                    local containerNode = self.m_scrollView:getScrollNode()
                    local num = #self.m_matchList
                    for i=1,num do
                        local tmp = containerNode:getChildByTag(eTagPageTab+i-1)
                        tmp:setScale(0.8)
                    end
                end
                -- dump(event.name)
                if event.name == "scrollEnd" or  event.name == "ended" then
                    local containerNode = self.m_scrollView:getScrollNode()
                    local num = #self.m_matchList
                    for i=1,num do
                        local tmp = containerNode:getChildByTag(eTagPageTab+i-1)
                        local tmpX = tmp:getPositionX()
                        if math.abs(tmpX-CELL_SIZE.width*3/2-30+containerNode:getPositionX())<CELL_SIZE.width/2 then
                            tmp:setScale(0.9)
                        else
                            tmp:setScale(0.8)
                        end
                    end
                end
            end) --注册scroll监听
        :addTo(self, 555)
        -- :setBounceable(false) -- 是否有回弹效果(默认支持)
    self.m_scrollView:getScrollNode():setPosition(0,0)
    self.m_scrollView:setPosition(cc.p(0,250))
    
    self:addTabPage()

    self:setTouchEnabled(true)
    self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onNodeTouchEvent))
    
    return true
end

function TourneyMatchSlideLayer:onNodeTouchEvent(event)
	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    -- event.x, event.y 是触摸点当前位置
    -- event.prevX, event.prevY 是触摸点之前的位置
	
	if event.name == "began" then
		return false
	elseif event.name == "began" then
		self.m_endDistance = event.x
	end
end

function TourneyMatchSlideLayer:clickButtonAtIndex(alertView, index)
    if (alertView.alertType == AlertApplyResultToStore) then
    
        if(index == 0) then
        
        else
        
            GameSceneManager:switchSceneWithType(EGSShop)
        end
    end
end

function TourneyMatchSlideLayer:cellCallBack(event)
    if self.m_infoDialogHasShown == true then
        return
    end
    local tag = event.target:getTag()
    if (math.abs(self.m_endDistance-self.m_beginDistance)<100) then
        self.m_infoDialogHasShown = true
    	tag = math.floor(tag/eTagCell)-1+tag%eTagCell
    	tag = tag+1
    	DBHttpRequest:getMatchInfo(handler(self,self.httpResponse), self.m_matchList[tag].matchId, "")
    	local dialog = require("app.GUI.Tourney.TourneyInfoDialog"):create()
        dialog:setFather(self)
    	dialog:updateIntroInfo(self.m_matchList[tag])

        dialog:setPosition(LAYOUT_OFFSET)
    	dialog:setTag(TAG_INFO_DIALOG)
    	self:getParent():addChild(dialog, 8)
    	dialog:show()
        -- dialog:setPositionY(dialog:getPositionY()+100)
    end
end

function TourneyMatchSlideLayer:dealGetMatchInfo(content)
    local info = require("app.Logic.Datas.Lobby.MatchInfo"):new()
    if (info:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
        -- dump(info)
        local data = {}
        local max1 = (info.gainList and #info.gainList > 0) and (info.gainList[#info.gainList].endRank) or 0
        local size = max1
       
        if(size <= 0) then
        
            if (info.prizePool ~="") then
                data[1] = clone(MatchStringNode)
                data[1].first = "1"
                data[1].second = info.prizePool
                local dialog = self:getParent():getChildByTag(TAG_INFO_DIALOG)
                if (dialog) then
                    dialog:updateMatchRewardList(data)
                end
            end
            return
        end
        
        
        --取出奖池奖励
        for i=1,#info.gainList do
        
            local node = info.gainList[i]
            for j=node.startRank,node.endRank do
                data[j] = clone(MatchStringNode)
                data[j].first = j
                data[j].second = node.gainStr
            end
        end
       
        --合并相同奖励内容
        local tmp = ""
        local needData = {}
        for i=1,#data do
        
            if #needData > 0 then
            
                if(data[i].second == needData[#needData].second) then
                
                    tmp = data[i].first
                else
                
                    if(tmp ~= "") then
                    
                        needData[#needData].first = needData[#needData].first .. "-" .. tmp
                        tmp = ""
                    end
                    needData[#needData+1] = data[i]
                end
            else
            
                needData[1]=data[i]
            end
        end
       
        if(tmp ~= "") then
        
            needData[#needData].first = needData[#needData].first .. "-" .. tmp
            tmp = ""
        end
     
        local dialog = self:getParent():getChildByTag(TAG_INFO_DIALOG)
        if (dialog) then
            dialog:updateMatchRewardList(needData)
        end

    
    end
    info=nil
end

function TourneyMatchSlideLayer:signBtnCallBack(event)
    local tag = event.target:getTag()
    tag = (math.floor(tag/eTagSignBtn)-1) + tag%eTagSignBtn
	tag = tag+1
    -- dump(tag)
    -- dump(self.m_matchList[tag])
    local _dialog = require("app.GUI.Tourney.TourneyApplyDialog"):create(
                                                             self.m_matchList[tag].matchName,
                                                             self.m_matchList[tag].ticketId,
                                                             self.m_matchList[tag].payNum+0.0,
                                                             self.m_matchList[tag].serviceCharge+0.0,
                                                             self,handler(self,self.applyMatchCallback),
                                                             self.m_matchList[tag].payType)
    self.m_signupIndex = tag
    self:getParent():addChild(_dialog,1000)
end

function TourneyMatchSlideLayer:applyMatchCallback(tableData)
    local _dialog = tableData
    local dict = _dialog:getUserObject()
    local dialogType = dict["type"]
    local ticketId = dict["ticketId"]

    if dialogType == "ticket" then
        DBHttpRequest:applyMatch(handler(self,self.httpResponse),self.m_matchList[self.m_signupIndex].matchId,true,true)
    else
        DBHttpRequest:applyMatch(handler(self,self.httpResponse),self.m_matchList[self.m_signupIndex].matchId,false,true)
    end
end

-- function TourneyMatchSlideLayer:scrollViewDidScroll(view)
    
--     local page = 0-(view:getContentOffset().x-CELL_SIZE.width/2)/(CELL_SIZE.width+30)

--     if (view:getScrollNode():getChildByTag(eTagPageTab+page-1)) then
--         local left =  view:getScrollNode():getChildByTag(eTagPageTab+page-1)
--         left:setScale(0.8)
--         local light = left:getChildByTag(eTagLight)
--         light:setVisible(false)

--     end
    
--     if (view:getScrollNode():getChildByTag(eTagPageTab+page)) then
--         local mid = view:getScrollNode():getChildByTag(eTagPageTab+page)

--             mid:setScale(1)
--         local light = mid:getChildByTag(eTagLight)
--         light:setVisible(true)

--     end

--     if (view:getScrollNode():getChildByTag(eTagPageTab+page+1)) then 
--         local right = view:getScrollNode():getChildByTag(eTagPageTab+page+1)
--         right:setScale(0.8)
--         local light = right:getChildByTag(eTagLight)
--         light:setVisible(false)
--     end

-- end

function TourneyMatchSlideLayer:httpResponse(event)

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

function TourneyMatchSlideLayer:onHttpResponse(tag, content, state)

    if tag==POST_COMMAND_APPLYMATCH then
        
        self:dealApplyMatch(content)

    elseif tag==POST_COMMAND_GETMATCHINFO then
        
        self:dealGetMatchInfo(content)

    end
end

function TourneyMatchSlideLayer:dealApplyMatch(content)

    local data = require("app.Logic.Datas.Lobby.ApplyMatch"):new()
    
    local dialog = self:getChildByTag(TAG_INFO_DIALOG)
    if (dialog) then 
        dialog:getParent():removeChild(dialog, true)
    end
    
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
     
        local datas = {}
        local result = data.applyMatchResult
        
        --特殊处理code  作为扩展当服务器返回此值直接取返回信息提示用户
        if (result == -16021) then
        
            local alert = require("app.Component.EAlertView"):alertView(
                                                      self:getParent(),
                                                      self,
                                                      "",
                                                      data.errorStr,
                                                      "确定",
                                                      nil
                                                      )
            alert:alertShow()
        else
        

            local resultTag1 = 10000
            local resultTag2 = -11057
            local resultTag3 = -18
			if TRUNK_VERSION==DEBAO_TRUNK then
            	resultTag1 = 0
            	resultTag2 = -13001
            	resultTag3 = -18
			end
            
            
            if result==resultTag1 then
            
                
                local alert = require("app.Component.ETooltipView"):alertView(
                                                              self:getParent(),
                                                              "",
                                                              "恭喜您报名成功"
                                                              )
                alert:show()
                
            else
            
                local resultStr = "          报名失败"
                if (result==resultTag2) then --(result==-13001)
                
                    resultStr = "对不起，您当前的余额无法支付当场比赛的报名费。是否立即充值？"
                    local alert = require("app.Component.EAlertView"):alertView(
                                                              self:getParent(),
                                                              self,
                                                              "",
                                                              resultStr,
                                                              "取消",
                                                              "立即充值",
                                                              nil
                                                              )
                    alert.alertType = AlertApplyResultToStore
                    if (alert) then
                    
                        alert:alertShow()
                    end
                elseif (result==resultTag3) then --(result==-5)
                
                    resultStr = "对不起，您不是付费用户，不能报名该场锦标赛。是否立即充值？"
                    local alert = require("app.Component.EAlertView"):alertView(
                                                              self:getParent(),
                                                              self,
                                                              "",
                                                              resultStr,
                                                              "取消",
                                                              "立即充值",
                                                              nil
                                                              )
                    alert.alertType = AlertApplyResultToStore
                    if (alert) then
                    
                        alert:alertShow()
                    end
                    
                else
                
                    local resultTag = {-2,-3,-4,-5,-7,-8,-11,-12,-13,-14,-15,-16,-17,-403,-500,-501,-10000,-12016,-13004,-13006,-13007,-14017,-14037,-14038}
                    local resultStrNew = {
                        "对不起，您没有资格报名该场锦标赛。-2",---2
                        "对不起，您已经报名该场锦标赛，不能重复报名。-3",---3
                        "对不起，报名时间已截止。-4",---4
                        "对不起，名额已满，请刷新列表。-5",---5
                        "对不起，您没有该场锦标赛的门票。-7",---7
                        "对不起，您没有资格报名该场锦标赛。-8",---8
                        "对不起，您没有资格报名该场锦标赛。-11",---11
                        "对不起，您没有资格报名该场锦标赛。-12",---12
                        "对不起，您没有资格报名该场锦标赛。-13",---13
                        "对不起，系统异常，请稍候重试。-14",---14
                        "对不起，系统异常，请稍候重试。-15",---15
                        "对不起，您没有资格报名该场锦标赛。-16",---16
                        "对不起，您没有资格报名该场锦标赛。-17",---17
                        "对不起，您还未登录，请稍候重试。-403",---403
                        "对不起，系统异常，请稍候重试。-500",---500
                        "对不起，系统异常，请稍候重试。-501",---501
                        "对不起，系统异常，请稍候重试。-10000",---10000
                        "对不起，系统异常，请稍候重试。-12016",---12016
                        "对不起，系统异常，请稍候重试。-13004",---13004
                        "对不起，系统异常，请稍候重试。-13006",---13006
                        "对不起，系统异常，请稍候重试。-13007",---13007
                        "对不起，系统异常，请稍候重试。-14017",---14017
                        "对不起，系统异常，请稍候重试。-14037",---14037
                        "对不起，系统异常，请稍候重试。-14038"---14038
                    }
                    local flag = -1
                    for i=1,24 do
                    
                        if (result==resultTag[i]) then
                        
                            flag = i
                            break
                        end
                    end
                    
                    if (flag~=-1) then
                    
                        resultStr = resultStrNew[flag]
                        local alert = require("app.Component.EAlertView"):alertView(
                                                                  self:getParent(),
                                                                  self,
                                                                  "",
                                                                  resultStr,
                                                                  "确定",
                                                                  nil
                                                                  )
                        alert.alertType = AlertApplyResult
                        if (alert) then
                        
                            alert:alertShow()
                        end
                    end
                end
            end
        end
    end
    
    data = nil
end


function TourneyMatchSlideLayer:addTabPage()
    -- dump(self.m_matchList)
    -- dump(self.m_totalInfo)

    for i=1,#self.m_totalInfo do
        if self.m_totalInfo and #self.m_totalInfo>0 and self.m_totalInfo[i].imagePath~=nil and self.m_totalInfo[i].imagePath~="" then 
            for j=1,#self.m_matchList do
                if self.m_totalInfo[i].index == j then
                    if self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):getChildByTag(eTagLogo)~=nil then

                        -- return
                    end
                    local sp = cc.Sprite:create(self.m_totalInfo[i].imagePath)
                    sp:setAnchorPoint(cc.p(0.5, 0.5))
                    sp:setPosition(cc.p(CELL_SIZE.width/2, 262))
                    self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):addChild(sp,2,eTagLogo)
                    self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):reorderChild(self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):getChildByTag(eTagTime), 3)
                    self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):reorderChild(self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):getChildByTag(eTagTimeLabel), 3)
                    self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):reorderChild(self.m_scrollView:getScrollNode():getChildByTag(eTagPageTab+j-1):getChildByTag(eTagTimeMask), 3)
                end
            end
        end

    end
end

function TourneyMatchSlideLayer:onHttpDownloadResponse(event)
    local ok = (event.name == "completed") 
    if ok then 
        local request = event.request  
        local filename = cc.FileUtils:getInstance():getWritablePath()..self.m_filename[request.tag]
        request:saveResponseData(filename) 
        self.m_totalInfo[request.tag].imagePath = filename
        self:addTabPage()
        -- dump(request.tag)
        -- dump(filename)
    end
end
return TourneyMatchSlideLayer