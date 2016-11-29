 
local nowVersion   = string.sub(DBVersion,string.len(DBVersion)- 8,string.len(DBVersion))
local IsAddTestButton = false    --添加测试按钮

local UpdateSceneNew  = class("UpdateSceneNew", function()
    return display.newScene("UpdateSceneNew")    
end)


function UpdateSceneNew:ctor()
    self.logic = require("app.update.UpdateLogic").new({callback = self})
    self.logic:addTo(self)

    self:initUI()

    self:setNodeEventEnabled(true)
    self:addKeyBackClicked()
end

function UpdateSceneNew:initUI()
	self.m_layer = require("app.GUI.LoadingSceneLayer"):new() 
    self:addChild(self.m_layer)

    self:newProgressTimer( "picdata/loadingscene/jdt_bg.png","picdata/loadingscene/jdt.png" )
    self.progressLabel  = self.m_layer.hintLabel 
    -- self.progressLabel  = display.newTTFLabel({text = "检查更新中...", size = 26, align = cc.TEXT_ALIGN_CENTER, color = display.COLOR_WHITE}):pos(display.cx,140):addTo(self,1) 
    self.curVersionLabel   = display.newTTFLabel({text = string.format("当前版本:%s",nowVersion), size = 26, align = cc.TEXT_ALIGN_RIGHT, color = display.COLOR_WHITE}):pos(display.width - 160,80):addTo(self) 
    self.latestVersionLabel= display.newTTFLabel({text = string.format("最新版本:%s",""), size = 26, align = cc.TEXT_ALIGN_RIGHT, color = display.COLOR_WHITE}):pos(display.width - 160,40):addTo(self)
    self.latestVersionLabel:setVisible(false)
end

function UpdateSceneNew:addKeyBackClicked()
	if device.platform == "android" then
        self:setKeypadEnabled(true) 
        self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
            if event.key == "back" then
                if self.mLayer then 
                    self.mLayer:removeFromParent()
                    self.mLayer = nil
                else
                    self:showExitGame()
                end
            end
        end)
    end
end

--【【更新进度条】】
function UpdateSceneNew:newProgressTimer( bgBarImg,progressBarImg ) 
    local prebg = display.newSprite(bgBarImg)
    prebg:setPosition(cc.p(display.cx,250))
    self:addChild(prebg)

    local pro = cc.Sprite:create(progressBarImg)
    local progress = cc.ProgressTimer:create(pro)   
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)    
    progress:setBarChangeRate(cc.p(1, 0))      
    progress:setMidpoint(cc.p(0,1)) 
    progress:setPercentage(0)      
    progress:setPosition(cc.p(display.cx,250))     
    self:addChild(progress) 
    self.progressTimer = progress
end

--[[切换线上线下按钮]]
function UpdateSceneNew:addTestButton()
    cc.ui.UIPushButton.new("picdata/public/btn_1_110_green.png", {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "线上环境",
            size = 18
        }))
        :setButtonLabel("pressed", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "选择线上环境",
            size = 18,
            color = cc.c3b(255, 64, 64)
        }))
        :setButtonLabel("disabled", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "选择线上环境",
            size = 18,
            color = cc.c3b(0, 0, 0)
        }))
        :onButtonClicked(function(event)
           SERVER_ENVIROMENT = ENVIROMENT_NORMAL --ENVIROMENT_TEST ENVIROMENT_NORMAL
           require("app.MyApp").new():start()
            end)
            :align(display.CENTER, display.cx, display.cy + 80)
            :addTo(self)

            cc.ui.UIPushButton.new("picdata/public/btn_1_110_green.png", {scale9 = true})
            :setButtonSize(240, 60)
            :setButtonLabel("normal", cc.ui.UILabel.new({
                UILabelType = 2,
                text = "测试环境",
                size = 18
            }))
            :setButtonLabel("pressed", cc.ui.UILabel.new({
                UILabelType = 2,
                text = "选择测试环境",
                size = 18,
                color = cc.c3b(255, 64, 64)
            }))
            :setButtonLabel("disabled", cc.ui.UILabel.new({
                UILabelType = 2,
                text = "选择测试环境",
                size = 18,
                color = cc.c3b(0, 0, 0)
            }))
            :onButtonClicked(function(event)
                require("app.GlobalConfig")
                SERVER_ENVIROMENT = ENVIROMENT_TEST --ENVIROMENT_TEST ENVIROMENT_NORMAL
                require("app.MyApp").new():start()
            end)
            :align(display.CENTER, display.cx, display.cy - 80)
            :addTo(self)
end

function UpdateSceneNew:showExitGame()
    if self.mLayer then self.mLayer:removeFromParent() self.mLayer = nil end
    local layer = cc.Layer:create()
    self:addChild(layer,10)
    self.mLayer = layer

    local bg = cc.Sprite:create("picdata/public/alertBG.png")
    bgWidth = bg:getContentSize().width
    bgHeight= bg:getContentSize().height
    self.mSize = cc.size(bgWidth - 100,bgHeight-100)
    bg:setPosition(display.cx,display.cy)
    self.mLayer:addChild(bg)

    local title = cc.ui.UILabel.new({
        color = cc.c3b(255, 228, 173),
        text  = "温馨提示",
        size  = 36,
        font  = "font/FZZCHJW--GB1-0.TTF",
       -- UILabelType = 1,
    })
    title:setPosition(bgWidth/2-title:getContentSize().width/2,bgHeight - 50)
    bg:addChild(title)
    local sTip = cc.ui.UILabel.new({text = "确定要退出游戏？",color = cc.c3b(255,255,255),size = 28,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(bgWidth - 80, 0)})  
    sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2+10,270 - sTip:getContentSize().height/2)
    bg:addChild(sTip,0)

    local btnClose = cc.ui.UIPushButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"})
        :onButtonClicked(function(event)
           self.mLayer:removeFromParent()
           self.mLayer = nil
            end)
            :align(display.CENTER, bgWidth-20,bgHeight - 20)
            :addTo(bg)
    local btnClose = cc.ui.UIPushButton.new({normal = "picdata/public/cancelBtn.png",pressed = "picdata/public/cancelBtn2.png"})
        :setButtonLabel("normal",cc.ui.UILabel.new({
        --UILabelType = 1,
        color = cc.c3b(156, 255, 0),
        text = "取消",
        size = 28,
        font = "FZZCHJW--GB1-0",
        }) )  
        :onButtonClicked(function(event)
            self.mLayer:removeFromParent()
           self.mLayer = nil
        end)
        :align(display.CENTER, bgWidth/2-140, 60)
        :addTo(bg)

    local btnExit = cc.ui.UIPushButton.new({normal = "picdata/public/confirmBtn.png",pressed = "picdata/public/confirmBtn2.png"})
        :setButtonLabel("normal",cc.ui.UILabel.new({
        --UILabelType = 1,
        color = cc.c3b(156, 255, 0),
        text = "退出",
        size = 28,
        font = "FZZCHJW--GB1-0",
        }) )  
        :onButtonClicked(function(event)
           os.exit()
        end)
        :align(display.CENTER, bgWidth/2+140, 60)
        :addTo(bg)
end

function UpdateSceneNew:setProgressLabel(text)
	if self.progressLabel then
		self.progressLabel:setString(text)
	end
end

function UpdateSceneNew:endUpdate(success)
	if success then
    	self.progressTimer:stopAllActions()
    	self.progressTimer:setPercentage(100)
    	self.progressLabel:setString(HINT_UPDATE_FINISH)
    	self.curVersionLabel:setString(string.format("当前版本:%s",self._latestVersion or nowVersion))

    	self:progressTimerAnimate()
	else
    	self.progressTimer:stopAllActions()
    	self.progressLabel:setString(HINT_DOWNLOAD_FAILED)  
        self.progressTimer:stopAllActions()
        self.progressLabel:setString(HINT_GET_VERSION_FAILED) 
	end
end

function UpdateSceneNew:progressTimerAnimate()
	self.progressTimer:setPercentage(0)
	local ac = cc.ProgressFromTo:create(10.0,0,90)
	self.progressTimer:runAction(ac)
end

function UpdateSceneNew:stopProgressTimerAnimation()
	self.progressTimer:stopAllActions()
end

function UpdateSceneNew:setLatestVersionLabelVisible(isVisible)
	self.latestVersionLabel:setVisible(isVisible)
end

function UpdateSceneNew:setLatestVersionLabelString(text)
    self.latestVersionLabel:setString(text)
end

function UpdateSceneNew:setCurVersionLabelString(text)
    self.curVersionLabel:setString(text)
end

--【【更新进度条】】
function UpdateSceneNew:progressTimerAction( progressTimer,fromPercentage,toPercentage,duration )
    if not duration then duration = 0.3 end
    local ac = CCProgressFromTo:create(duration,fromPercentage,toPercentage)
    progressTimer:runAction(ac)
end

--[[更新完成]]
function UpdateSceneNew:updateSuccess()
    if IsAddTestButton then
        self:addTestButton()
    else
        SERVER_ENVIROMENT = ENVIROMENT_NORMAL --ENVIROMENT_TEST ENVIROMENT_NORMAL
        require("app.MyApp").new():start()
    end
end

function UpdateSceneNew:onEnter()

end

function UpdateSceneNew:onEnter()

end

function UpdateSceneNew:onEnterTransitionFinish()

end

function UpdateSceneNew:onExit()

end

return UpdateSceneNew