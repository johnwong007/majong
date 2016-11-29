local MusicPlayer = require("app.Tools.MusicPlayer")
local TourneyHallView = class("TourneyHallView", function()
	return display.newLayer()
end)
require("app.Tools.StringFormat")
require("app.Logic.Config.UserDefaultSetting")
local GameLayerManager  = require("app.GUI.GameLayerManager")

function TourneyHallView:scene()
    local layer = TourneyHallView:new()
    local pScene = display.newScene()
    layer:addTo(pScene)
    return pScene
end

function TourneyHallView:create()

end

function TourneyHallView:ctor()

    --[[初始化工作]]
    -------------------------------------------------------
	self:setNodeEventEnabled(true)
    self.m_hall = require("app.Logic.Tourney.TourneyHall").new({callback = self})
    self.m_hall:addTo(self)

    -------------------------------------------------------

	self.m_hallBg = cc.ui.UIImage.new(GDIFROOTRES .. "picdata/MainPage_dif/mainpageBG.png")
	self.m_hallBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
		:addTo(self)

	local topItemPosY = display.height - 57

	--[[返回按钮]]
	local backBtn = cc.ui.UIPushButton.new({normal="picdata/public/back.png", pressed="picdata/public/back.png",
		disabled="picdata/public/back.png"})
	backBtn:align(display.CENTER, 57, topItemPosY)
		:onButtonClicked(handler(self, self.pressBack))
		:addTo(self)

    --[[金币、商城]]
    local toolBarTop = require("app.Component.ToolBarTop").new({dispatchEvtOpen = "HidePrivateHallSearch", dispatchEvtClose = "ShowPrivateHallSearch"})
    toolBarTop:setPosition(CONFIG_SCREEN_WIDTH/2--[[ + 37]],topItemPosY)
    self:addChild(toolBarTop)
    self.m_goldNum = toolBarTop.m_goldNum
    self.m_scoreNum = toolBarTop.m_scoreNum

    --[[设置按钮]]
	-- local setBtn = cc.ui.UIPushButton.new({normal="picdata/hall/setBtn.png", pressed="picdata/hall/setBtn2.png",
	-- 	disabled="picdata/hall/setBtn2.png"})
	-- setBtn:align(display.CENTER, display.width-57, topItemPosY)
	-- 	:onButtonClicked(handler(self, self.pressHiddenRoom))
	-- 	:addTo(self)
	-- 	:setTouchSwallowEnabled(false)


	self.tableBg = cc.ui.UIImage.new("picdata/tourneyNew/bg.png")
		:align(display.CENTER_BOTTOM, CONFIG_SCREEN_WIDTH/2, -10)
		:addTo(self)
	
    ----------------------------------------------

    self.m_matchTipsButton = CMButton.new({normal = "picdata/public2/btn_qas.png",pressed = "picdata/public2/btn_qas2.png"}, handler(self, self.showMatchTips), {scale9 = false})
    self.m_matchTipsButton:setPosition(290, self.tableBg:getContentSize().height-58)
    self.tableBg:addChild(self.m_matchTipsButton, 10)

    self.m_matchTipsNode = display.newNode()
        :align(display.CENTER, 290, self.tableBg:getContentSize().height-58-8)
        :addTo(self.tableBg, 10)

    self.m_matchTipsBg = cc.ui.UIImage.new("picdata/tourneyNew/bg_tips.png")
        :align(display.CENTER_TOP, 0, 0)
        :addTo(self.m_matchTipsNode)

    cc.ui.UILabel.new({
        text = "图表说明",
        font = "黑体",
        size = 20,
        color = cc.c3b(255,255,255),
        align = cc.TEXT_ALIGNMENT_LEFT
        })
        :align(display.LEFT_CENTER, 10, 100)
        :addTo(self.m_matchTipsBg)

    local addonIcon = cc.ui.UIImage.new("picdata/tourneyNew/icon_rebuy.png")
    addonIcon:align(display.LEFT_CENTER, 10, 65)
        :addTo(self.m_matchTipsBg)

    cc.ui.UILabel.new({
        text = "可重购比赛(Re-buy)",
        font = "黑体",
        size = 20,
        color = cc.c3b(255,255,255),
        align = cc.TEXT_ALIGNMENT_LEFT
        })
        :align(display.LEFT_CENTER, 40, 65)
        :addTo(self.m_matchTipsBg)

    local rebuyIcon = cc.ui.UIImage.new("picdata/tourneyNew/icon_addon.png")
    rebuyIcon:align(display.LEFT_CENTER, 10, 30)
        :addTo(self.m_matchTipsBg)

    cc.ui.UILabel.new({
        text = "可加码比赛(Addon)",
        font = "黑体",
        size = 20,
        color = cc.c3b(255,255,255),
        align = cc.TEXT_ALIGNMENT_LEFT
        })
        :align(display.LEFT_CENTER, 40, 30)
        :addTo(self.m_matchTipsBg)

    self.m_matchTipsNode:setVisible(false)
    --------------------------------------------------
    self.m_feeTipsButton = CMButton.new({normal = "picdata/public2/btn_qas.png",pressed = "picdata/public2/btn_qas2.png"}, handler(self, self.showFeeTips), {scale9 = false})
    self.m_feeTipsButton:setPosition(750, self.tableBg:getContentSize().height-58)
    self.tableBg:addChild(self.m_feeTipsButton, 10)

    self.m_feeTipsNode = display.newNode()
        :align(display.CENTER, 750, self.tableBg:getContentSize().height-58-8)
        :addTo(self.tableBg, 10)

    self.m_feeTipsBg = cc.ui.UIImage.new("picdata/tourneyNew/bg_tips.png")
        :align(display.CENTER_TOP, 0, 0)
        :addTo(self.m_feeTipsNode)

    cc.ui.UILabel.new({
        text = "金币报名(报名费+服务\n费，如\"10万+1万\"),退\n赛的时候全额退还,开赛\n后无法退赛。",
        font = "黑体",
        size = 20,
        color = cc.c3b(255,255,255),
        align = cc.TEXT_ALIGNMENT_LEFT
        })
        :align(display.LEFT_CENTER, 10, 65)
        :addTo(self.m_feeTipsBg)

    self.m_feeTipsNode:setVisible(false)
    --------------------------------------------------


	------------------------------------------------------------------------------------------------
    local button_images1 = {
        off = "picdata/tourneyNew/btn_qb.png",
        off_pressed = "picdata/tourneyNew/btn_qb2.png",
        off_disabled = "picdata/tourneyNew/btn_qb2.png",
        on = "picdata/tourneyNew/btn_qb2.png",
        on_pressed = "picdata/tourneyNew/btn_qb.png",
        on_disabled = "picdata/tourneyNew/btn_qb2.png",
    }
    local button_images2 = {
        off = "picdata/tourneyNew/btn_jb.png",
        off_pressed = "picdata/tourneyNew/btn_jb2.png",
        off_disabled = "picdata/tourneyNew/btn_jb2.png",
        on = "picdata/tourneyNew/btn_jb2.png",
        on_pressed = "picdata/tourneyNew/btn_jb.png",
        on_disabled = "picdata/tourneyNew/btn_jb2.png",
    }
    local button_images3 = {
        off = "picdata/tourneyNew/btn_hf.png",
        off_pressed = "picdata/tourneyNew/btn_hf2.png",
        off_disabled = "picdata/tourneyNew/btn_hf2.png",
        on = "picdata/tourneyNew/btn_hf2.png",
        on_pressed = "picdata/tourneyNew/btn_hf.png",
        on_disabled = "picdata/tourneyNew/btn_hf2.png",
    }
    local button_images4 = {
        off = "picdata/tourneyNew/btn_jf.png",
        off_pressed = "picdata/tourneyNew/btn_jf2.png",
        off_disabled = "picdata/tourneyNew/btn_jf2.png",
        on = "picdata/tourneyNew/btn_jf2.png",
        on_pressed = "picdata/tourneyNew/btn_jf.png",
        on_disabled = "picdata/tourneyNew/btn_jf2.png",
    }
    local button_images5 = {
        off = "picdata/tourneyNew/btn_wdbs.png",
        off_pressed = "picdata/tourneyNew/btn_wdbs2.png",
        off_disabled = "picdata/tourneyNew/btn_wdbs2.png",
        on = "picdata/tourneyNew/btn_wdbs2.png",
        on_pressed = "picdata/tourneyNew/btn_wdbs.png",
        on_disabled = "picdata/tourneyNew/btn_wdbs2.png",
    }
    self.m_bSoundEnabled = false
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
        :addButton(cc.ui.UICheckBoxButton.new(button_images1)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(button_images2)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(button_images3)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(button_images4)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(button_images5)
            :align(display.LEFT_CENTER))
        :setButtonsLayoutMargin(2, 2, 2, 2)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            if event.selected==1 then
                self.m_hall:switchTab(eMatchListRecommend)
            elseif event.selected==2 then
                self.m_hall:switchTab(eMatchListGold)
            elseif event.selected==3 then
                self.m_hall:switchTab(eMatchListCalls)
            elseif event.selected==4 then
                self.m_hall:switchTab(eMatchListRakepoint)
            elseif event.selected==5 then
                self.m_hall.m_matchListType = eMatchListMyMatch
                self.m_hall:getMyApplyMatch()
            end
            if self.m_bSoundEnabled then
                MusicPlayer:getInstance():playButtonSound()
            end
        end)
        :align(display.LEFT_BOTTOM, 26, 12)
        :addTo(self.tableBg)
        group:getButtonAtIndex(5):setPosition(760, 34)
        group:getButtonAtIndex(1):setButtonSelected(true)

        --[[隐藏积分赛]]
        if GIOSCHECK then
            group:getButtonAtIndex(3):setVisible(false)
        end

        group:getButtonAtIndex(4):setVisible(false)

    --[[我的比赛按钮]]
    -- self.signedMatch = cc.ui.UIPushButton.new({normal="picdata/tourneyNew/btn_wdbs.png", pressed="picdata/tourneyNew/btn_wdbs2.png",
    --     disabled="picdata/tourneyNew/btn_wdbs2.png"})
    -- self.signedMatch:align(display.RIGHT_BOTTOM, self.tableBg:getContentSize().width-28, 14)
    --     :onButtonClicked(function()
    --             -- self:button_click(105)
    --         end)
    --     :addTo(self.tableBg)

end

function TourneyHallView:showMatchTips()
    if self.m_matchTipsNode:isVisible() then
        self.m_matchTipsNode:stopAllActions()
        self.m_matchTipsNode:setVisible(false)
        return
    end
    self.m_matchTipsNode:setVisible(true)
    transition.execute(self.m_matchTipsNode, cc.DelayTime:create(4), {
        onComplete = function() 
            self.m_matchTipsNode:setVisible(false)
        end
        })
end

function TourneyHallView:showFeeTips()
    if self.m_feeTipsNode:isVisible() then
        self.m_feeTipsNode:stopAllActions()
        self.m_feeTipsNode:setVisible(false)
        return
    end
    self.m_feeTipsNode:setVisible(true)
    transition.execute(self.m_feeTipsNode, cc.DelayTime:create(4), {
        onComplete = function() 
            self.m_feeTipsNode:setVisible(false)
        end
        })
end

function TourneyHallView:onExit()
    TourneyGuideReceiver:sharedInstance():registerCurrentView(nil)
end

function TourneyHallView:onEnter()
    TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
    self.m_bSoundEnabled = true
end

function TourneyHallView:pressBack()
    -- CMClose(self, true)
    GameSceneManager:switchSceneWithType(EGSMainPage)
end

function TourneyHallView:switchTab(matchInfo, matchListType, scrollToLastPos)
    local x,y
    if self.m_tourneyMatchLayer then
        x,y=self.m_tourneyMatchLayer.tableView:getScrollNode():getPosition()
        self.m_tourneyMatchLayer:removeFromParent(true)
        self.m_tourneyMatchLayer = nil
    end

    if matchInfo and #matchInfo>0 then
        -- self.m_tourneyMatchLayer = require("app.GUI.Tourney.TourneyMatchSlideLayer"):create(matchInfo)
        -- self.m_tourneyMatchLayer:setAnchorPoint(cc.p(0.5,0.5))
        -- self.m_tourneyMatchLayer:setPosition(cc.p(display.cx,275-120))
        -- self:addChild(self.m_tourneyMatchLayer,8)

        self.m_tourneyMatchLayer = require("app.GUI.Tourney.TourneyHallTableView").new({data=matchInfo, callback=self, listType = matchListType})
        self.m_tourneyMatchLayer:addTo(self.tableBg)

        if y and scrollToLastPos then
            self.m_tourneyMatchLayer:scrollTo(0,y)
        end
    end
end

function TourneyHallView:showMobileImage(filename, cellIndex)
    if self.m_tourneyMatchLayer then
        self.m_tourneyMatchLayer:showMobileImage(filename, cellIndex)
    end
end

function TourneyHallView:showInfoDialogCallback(tag)
    if self.m_infoDialogHasShown == true then
        return
    end
    self.m_hall:showInfoDialog(tag)
end

function TourneyHallView:signBtnCallBack(eachInfo, tag)
    local _dialog = require("app.GUI.Tourney.TourneyApplyDialog"):create(eachInfo.matchName, eachInfo.ticketId,
        tonumber(eachInfo.payNum), tonumber(eachInfo.serviceCharge), self, handler(self,self.applyMatchCallback),
        eachInfo.payType)
    self.m_signupIndex = tag
    self:addChild(_dialog,1000)
end

function TourneyHallView:cellBtnQuitGame(eachInfo)
    local alert = require("app.Component.EAlertView"):alertView(self,self,
        "温馨提示","是否退赛?","取消","确定")
    alert:setTag(2)
    alert:setUserObject(eachInfo.matchId)
    if alert then
        alert:alertShow()
    end
end

function TourneyHallView:showInfoDialog(matchList)
    self.m_infoDialogHasShown = true
    local dialog = require("app.GUI.Tourney.TourneyInfoDialog"):create()
    dialog:setFather(self)
    dialog:updateIntroInfo(matchList)
    dialog:setPosition(LAYOUT_OFFSET)
    dialog:setTag(TAG_INFO_DIALOG)
    self:addChild(dialog, 8)
    dialog:show()
end

function TourneyHallView:updateInfoDialogRewardList(rewardList)
    local dialog = self:getChildByTag(TAG_INFO_DIALOG)
    if dialog then
        dialog:updateMatchRewardList(rewardList)
    end
end

function TourneyHallView:applyMatchCallback(tableData)
    local _dialog = tableData
    local dict = _dialog:getUserObject()
    local dialogType = dict["type"]
    local ticketId = dict["ticketId"]
    self.m_hall:applyMatch({dialogType = dialogType, index=self.m_signupIndex})
end

function TourneyHallView:clickButtonAtIndex(alertView, index)
    if index ==1 then 
        local matchId = alertView:getUserObject()
        local tag = alertView:getTag()
        if tag==1 then
        elseif tag==2 then
            alertView:remove()
            self.m_hall:quitMatch(matchId)
        end
    end


    if alertView.alertType and alertView.alertType == AlertApplyResultToStore then
    
        if index == 0 then
        
        else
            -- GameSceneManager:switchSceneWithType(EGSShop)
            local layer = GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self)
        end
    end
end

function TourneyHallView:showQuitMatchResult(isSuc, resultStr)
    if isSuc then
        local alert = require("app.Component.ETooltipView"):alertView(self,"",resultStr)
        alert:show()
    else
        local alert = require("app.Component.ETooltipView"):alertView(self,"",resultStr)
        alert:show()
    end
end

return TourneyHallView