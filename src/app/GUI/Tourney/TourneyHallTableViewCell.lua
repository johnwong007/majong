require("app.Tools.StringFormat")
local payNumColorGold = cc.c3b(255,223,74)
local payNumColorRake = cc.c3b(154,168,255)
local signButtonColor1 = cc.c3b(215,255,178)
local signButtonColor2 = cc.c3b(189,211,255)

local TourneyHallTableViewCell = class("TourneyHallTableViewCell", function()
		return display.newNode()
	end)


function TourneyHallTableViewCell:ctor(params)
    self.eachInfo = params.data
    self.cellHeight = params.height
    self.cellWidth = params.width
    self.m_pCallbackUI = params.callback
    self.index = params.index
    
    -- dump(self.eachInfo)
    if self.eachInfo.isEmptyList then
        cc.ui.UIImage.new("picdata/public2/icon_empty.png")
        :align(display.BOTTOM_CENTER, 0, -20)
        :addTo(self)
        cc.ui.UILabel.new({
            text = "暂未参加任何比赛，赶紧去报名吧！",
            font = "fonts/FZZCHJW--GB1-0.TTF",
            size = 22,
            color = cc.c3b(134,153,191),
            -- align = cc.TEXT_ALIGNMENT_LEFT
            })
        :align(display.TOP_CENTER, 0, -45)
        :addTo(self)
        return
    end


	--[[背景]]
    local sprite = cc.ui.UIImage.new("picdata/tourneyNew/bg_list.png")
	self.background = cc.ui.UIPushButton.new({
    	normal = "picdata/tourneyNew/bg_list.png",
    	pressed = "picdata/tourneyNew/bg_list.png",
   	 	disabled = "picdata/tourneyNew/bg_list.png",
		})
		-- :setButtonSize(882, sprite:getContentSize().height)
        :onButtonClicked(function(event) 
            self:cellCallBack()
            end)
        :addTo(self):align(display.CENTER, 0, 0)
        :setTouchSwallowEnabled(false)

        self.payTypeIcon = nil
        local iconPath = nil
        if (self.eachInfo.payType == "RAKEPOINT") then
            iconPath = "picdata/tourneyNew/jf.png"
        end

        if string.find(self.eachInfo.matchName, "话费") then
            iconPath = "picdata/tourneyNew/hf.png"
        end

        if string.find(self.eachInfo.matchName, "京东") and not string.find(self.eachInfo.matchName, "门票") then
            iconPath = "picdata/tourneyNew/jd.png"
        end

        if string.find(self.eachInfo.matchName, "京东") and string.find(self.eachInfo.matchName, "门票") then
            iconPath = "picdata/tourneyNew/jd_mps.png"
        end

        if self.eachInfo.imagePath and self.eachInfo.imagePath~="" then
            iconPath = self.eachInfo.imagePath
        end
        if not iconPath then
            iconPath = "picdata/tourneyNew/jb.png"
        end

        self.payTypeIcon = cc.ui.UIImage.new(iconPath)
        self.payTypeIcon:align(display.CENTER, -self.cellWidth/2+47, 0)
        :addTo(self)
        
    local scaleRatio = 88/self.payTypeIcon:getContentSize().width
    self.payTypeIcon:setScale(scaleRatio)

    if self.eachInfo.listType~=eMatchListMyMatch and tonumber(self.eachInfo.regStatus)==0 then
        self.signMenu = cc.ui.UIPushButton.new({normal="picdata/tourneyNew/btn1_bm.png",pressed="picdata/tourneyNew/btn1_bm2.png",
            disabled="picdata/tourneyNew/btn1_bm2.png"})
        self.signMenu:align(display.RIGHT_CENTER, self.cellWidth/2-10, 0)
            :onButtonClicked(handler(self,self.signBtnCallBack))
            :addTo(self)
            :setTouchSwallowEnabled(true)

        local signMenuLabel = cc.ui.UILabel.new({
            text = "报名",
            font = "fonts/FZZCHJW--GB1-0.TTF",
            size = 30,
            color = cc.c3b(215,255,178)
            })
        signMenuLabel:enableShadow(signButtonColor1,cc.size(2,-2))
        self.signMenu:setButtonLabel("normal", signMenuLabel)
    else
        if self.eachInfo.matchStatus~="REGISTERING" then
            if self.eachInfo.tableId then
                self.joinMatchButton = cc.ui.UIPushButton.new({normal="picdata/tourneyNew/btn3_rz.png", 
                    pressed="picdata/tourneyNew/btn3_rz3.png", 
                    disabled="picdata/tourneyNew/btn3_rz3.png"})
                self.joinMatchButton:align(display.RIGHT_CENTER, self.cellWidth/2-10, -15)
                    :addTo(self)
                    :onButtonClicked(function(event)
                        self:cellBtnEnterGame(event)
                        end)
                    :setTouchSwallowEnabled(true)

                local label = cc.ui.UILabel.new({
                    text = "入桌",
                    font = "fonts/FZZCHJW--GB1-0.TTF",
                    size = 24,
                    color = cc.c3b(215,255,178)
                    })
                label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
                self.joinMatchButton:setButtonLabel("normal", label)
            end
        else
            self.quitMatchButton = cc.ui.UIPushButton.new({normal="picdata/tourneyNew/btn4_ts.png", 
                pressed="picdata/tourneyNew/btn4_ts2.png", 
                disabled="picdata/tourneyNew/btn4_ts2.png"})
            self.quitMatchButton:align(display.RIGHT_CENTER, self.cellWidth/2-10, -15)
                :addTo(self, 1)
                :onButtonClicked(function(event)
                    self:cellBtnQuitGame(event)
                    end)
                :setTouchSwallowEnabled(true)

            local label = cc.ui.UILabel.new({
                text = "退赛",
                font = "fonts/FZZCHJW--GB1-0.TTF",
                size = 24,
                color = cc.c3b(189,211,255)
                })
            label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
            self.quitMatchButton:setButtonLabel("normal", label)
        end

        cc.ui.UILabel.new({
            text = "已报名",
            font = "黑体",
            size = 24,
            color = cc.c3b(156,255,0),
            -- align = cc.TEXT_ALIGNMENT_LEFT
            })
        :align(display.CENTER, self.cellWidth/2-75, 20)
        :addTo(self)
    end

    local payNum = StringFormat:FormatDecimals(self.eachInfo.payNum,2)
    local serviceNum = StringFormat:FormatDecimals(self.eachInfo.serviceCharge,2)
    payNum = payNum.."+"..serviceNum
    local payNumPosX = self.cellWidth/2-260
    local payNumLabel
    if tonumber(self.eachInfo.payNum)==0 and tonumber(self.eachInfo.serviceCharge)==0 then
        payNum = "免费"
        payNumLabel = cc.ui.UILabel.new({
            text = payNum,
            font = "黑体",
            size = 22,
            color = payNumColorGold,
            align = cc.TEXT_ALIGNMENT_LEFT
            })
    else
        local payTypeImage
        if (self.eachInfo.payType == "RAKEPOINT") then
            payTypeImage = cc.ui.UIImage.new("picdata/tourneyNew/icon_jf.png")
            payNumLabel = cc.ui.UILabel.new({
                text = payNum,
                font = "黑体",
                size = 22,
                color = payNumColorRake,
                align = cc.TEXT_ALIGNMENT_LEFT
                })
        else
            payTypeImage = cc.ui.UIImage.new("picdata/tourneyNew/icon_jb.png")
            payNumLabel = cc.ui.UILabel.new({
                text = payNum,
                font = "黑体",
                size = 22,
                color = payNumColorGold,
                align = cc.TEXT_ALIGNMENT_LEFT
                })
        end
        payTypeImage:align(display.RIGHT_CENTER, payNumPosX, 0) 
            :addTo(self) 
    end    
    payNumLabel:align(display.LEFT_CENTER, payNumPosX, 0)
        :addTo(self)  

    local time = self.eachInfo.preSetStartTime or self.eachInfo.presetStartTime
    local timeNode = require("app.GUI.Tourney.TourneyTime").new({startTime=time, 
        delayTime=self.eachInfo.regDelayTime})
    timeNode:setPosition(payNumPosX-120, 0)
    timeNode:addTo(self)

    local matchNameLen = string.utf8len(self.eachInfo.matchName)
    local matchNameDefalutWidth = 280
    local matchNameLabel = cc.ui.UILabel.new({
        text = tostring(self.eachInfo.matchName),
        font = "黑体",
        size = 26,
        color = cc.c3b(255,255,255),
        align = cc.TEXT_ALIGNMENT_LEFT
        })
    matchNameLabel:align(display.LEFT_CENTER, -self.cellWidth/2+100, 15)
    matchNameLabel:addTo(self)
    if matchNameLen>14 then
        local w = matchNameLabel:getContentSize().width
        matchNameLabel:setScale(matchNameDefalutWidth/w)
    end

    local addonPosX = -self.cellWidth/2+230
    local addonPosY = -20
    local addonIcon = cc.ui.UIImage.new("picdata/tourneyNew/icon_addon.png")
    addonIcon:align(display.CENTER, addonPosX, addonPosY)
        :addTo(self)
    if self.eachInfo.isRebuy then
        local rebuyIcon = cc.ui.UIImage.new("picdata/tourneyNew/icon_rebuy.png")
        rebuyIcon:align(display.CENTER, addonPosX+40, addonPosY)
            :addTo(self)
    end

    local playerIconPosX = -self.cellWidth/2+130
    local playerIcon = cc.ui.UIImage.new("picdata/tourneyNew/icon_player.png")
        playerIcon:align(display.RIGHT_CENTER, playerIconPosX, addonPosY)
            :addTo(self)

    local playerNumLabel = cc.ui.UILabel.new({
        text = tostring(self.eachInfo.curUnum) .. "人",
        font = "黑体",
        size = 22,
        color = cc.c3b(188,201,229),
        align = cc.TEXT_ALIGNMENT_LEFT
        })
    playerNumLabel:align(display.LEFT_CENTER, playerIconPosX+8, addonPosY)
    playerNumLabel:addTo(self)

      
end

function TourneyHallTableViewCell:showMobileImage(filename)
    -- cc.ui.UIImage.new(filename)
    --     :align(display.CENTER, -self.cellWidth/2+10, 0)
    --     :addTo(self, 2, eTagLogo)

    
    -- filename = cc.FileUtils:getInstance():getWritablePath().."jf.png"
    self.payTypeIcon:setTexture(filename)
    local scaleRatio = 88/self.payTypeIcon:getContentSize().width
    self.payTypeIcon:setScale(scaleRatio)
end

function TourneyHallTableViewCell:getEachInfo()
    return self.eachInfo
end

function TourneyHallTableViewCell:cellCallBack(event)
	self.m_pCallbackUI:showInfoDialogCallback(self.index)
end

function TourneyHallTableViewCell:signBtnCallBack(event)
    self.m_pCallbackUI:signBtnCallBack(self.eachInfo, self.index)
end

function TourneyHallTableViewCell:cellBtnEnterGame(event)
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = self.eachInfo.tableId,m_isGameType = true })
end

function TourneyHallTableViewCell:cellBtnQuitGame(event)
    self.m_pCallbackUI:cellBtnQuitGame(self.eachInfo, self.index)
end

function TourneyHallTableViewCell:clickButtonAtIndex(alertView, index)
    if index ==1 then 
        local matchId = alertView:getUserObject()
        local tag = alertView:getTag()
        if tag==1 then
        elseif tag==2 then
            alertView:remove()
            -- DBHttpRequest:quitMatch(handler(self,self.httpResponse), matchId)
        end
    end
end

return TourneyHallTableViewCell