local CommonFragment = require("app.architecture.components.CommonFragment")
local CMRadioButton = require("app.Component.CMRadioButton")
local MusicPlayer = require("app.Tools.MusicPlayer")
local CMTextButton = require("app.Component.CMTextButton")
local HallSettingFragment = class("HallSettingFragment", function()
		return CommonFragment:new()
	end)

function HallSettingFragment:ctor(params)
	self.params = params
	if UserDefaultSetting:getInstance():getMusicEnable() then
		self.musicValue = 1
	else
		self.musicValue = 0
	end
	if UserDefaultSetting:getInstance():getSoundEnable() then
		self.soundValue = 1
	else
		self.soundValue = 0
	end

    self:setNodeEventEnabled(true)
	-- 注册事件
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
		dump("=====>")
   --  	if self.musicSlider and not self.musicSlider:isSelected() then
			-- local value = math.round(self.musicSlider:getValue())
			-- self.musicSlider:setValue(value)
   --  	end
   --  	if self.soundSlider and not self.soundSlider:isSelected() then
			-- local value = math.round(self.soundSlider:getValue())
			-- self.soundSlider:setValue(value)
   --  	end
    end)
end

function HallSettingFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallSettingFragment:onEnterTransitionFinish()
end

function HallSettingFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallSettingFragment:logout()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
end

-- function HallSettingFragment:back()
-- 	CommonFragment.back(self)
-- end

function HallSettingFragment:saveData()
	UserDefaultSetting:getInstance():setMusicEnable(self.musicValue<0.5 and false or true)
	UserDefaultSetting:getInstance():setSoundEnable(self.soundValue<0.5 and false or true)
end

function HallSettingFragment:initUI()
	self.m_pLogout = CMTextButton:new({
        textColorN = cc.c3b(125, 0, 0),
        textColorS = cc.c3b(225, 0, 0),
        text  = "退出登陆",
        callback  = handler(self, self.logout)
    })
    self.m_pLogout:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2-self.bgHeight/2+100)
    self:addChild(self.m_pLogout)  

    -- self.musicImage = cc.ui.UIImage.new("picdata/hall/setting/img_on.png")
    -- self.musicImage:align(display.CENTER, self.m_pLogout:getPositionX(), self.m_pLogout:getPositionY()+100)
    -- 	:addTo(self)

    -- self.soundImage = cc.ui.UIImage.new("picdata/hall/setting/img_on.png")
    -- self.soundImage:align(display.CENTER, self.m_pLogout:getPositionX(), self.musicImage:getPositionY()+100)
    -- 	:addTo(self)


	local sprite1 = cc.Sprite:create("picdata/hall/setting/img_off.png")
	local sprite2 = cc.Sprite:create("picdata/hall/setting/img_on.png")
	local sprite3 = cc.Sprite:create("picdata/hall/setting/img_dice.png")
	sprite1:setScaleY(24/30)
	self.musicSlider = cc.ControlSlider:create(sprite1, 
		sprite2, sprite3)
	self.musicSlider:registerControlEventHandler(handler(self,self.valueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	self.musicSlider:setMaximumValue(1)
	self.musicSlider:setMinimumValue(0)
	self.musicSlider:setValue(self.musicValue)
	self.musicSlider:setPosition(self.m_pLogout:getPositionX()-15, self.m_pLogout:getPositionY()+100)
	self:addChild(self.musicSlider, 1)
	local sprite4 = cc.Sprite:create("picdata/hall/setting/img_off.png")
	local sprite5 = cc.Sprite:create("picdata/hall/setting/img_on.png")
	local sprite6 = cc.Sprite:create("picdata/hall/setting/img_dice.png")
	sprite4:setScaleY(24/30)
	self.soundSlider = cc.ControlSlider:create(sprite4, 
		sprite5, sprite6)
	self.soundSlider:registerControlEventHandler(handler(self,self.valueChanged), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
	self.soundSlider:setMaximumValue(1)
	self.soundSlider:setMinimumValue(0)
	self.soundSlider:setValue(self.soundValue)
	self.soundSlider:setPosition(self.m_pLogout:getPositionX()-15, self.musicSlider:getPositionY()+100)
	self:addChild(self.soundSlider, 1)
	self.musicSlider:setEnabled(false)
	self.soundSlider:setEnabled(false)

    cc.ui.UILabel.new({
        color = cc.c3b(0, 0, 0),
        text  = "音乐",
        size  = 26,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_RIGHT
        })
    	:align(display.RIGHT_CENTER, self.musicSlider:getPositionX()-self.musicSlider:getContentSize().width/2-25, 
    		self.musicSlider:getPositionY())
    	:addTo(self)

    cc.ui.UILabel.new({
        color = cc.c3b(255, 0, 0),
        text  = "音效",
        size  = 26,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_RIGHT
        })
    	:align(display.RIGHT_CENTER, self.soundSlider:getPositionX()-self.soundSlider:getContentSize().width/2-25, 
    		self.soundSlider:getPositionY())
    	:addTo(self)

    self.m_pMusicBtn = CMRadioButton:new({
        hint = "",
        on="picdata/hall/setting/img_music_on.png",
        off="picdata/hall/setting/img_music_off.png",
        callback = handler(self,self.musicValueChanged),})
    self.m_pMusicBtn:align(display.LEFT_CENTER, self.musicSlider:getPositionX()+self.musicSlider:getContentSize().width/2+35,
    		self.musicSlider:getPositionY()-35)
    self.m_pMusicBtn:addTo(self)

    self.m_pSoundBtn = CMRadioButton:new({
        hint = "",
        on="picdata/hall/setting/img_sound_on.png",
        off="picdata/hall/setting/img_sound_off.png",
        callback = handler(self,self.soundValueChanged),})
    self.m_pSoundBtn:align(display.LEFT_CENTER, self.soundSlider:getPositionX()+self.soundSlider:getContentSize().width/2+35, 
    		self.soundSlider:getPositionY()-35)
    self.m_pSoundBtn:addTo(self)
    self.m_pMusicBtn:setButtonSelected(self.musicValue<0.5 and false or true)
    self.m_pSoundBtn:setButtonSelected(self.soundValue<0.5 and false or true)
end

function HallSettingFragment:valueChanged(slider)
	-- if self.musicSlider then
	-- 	self.musicValue = self.musicSlider:getValue()
	-- end
	-- if self.soundSlider then
	-- 	self.soundValue = self.soundSlider:getValue()
	-- end
	-- if self.m_pMusicBtn then
 --    	self.m_pMusicBtn:setButtonSelected(self.musicValue<0.5 and false or true)
 --    end
 --    if self.m_pSoundBtn then 
 --    	self.m_pSoundBtn:setButtonSelected(self.soundValue<0.5 and false or true)
 --    end
end

function HallSettingFragment:musicValueChanged(value)
	if value then
		if self.musicSlider then
			self.musicSlider:setValue(1)
		end
		self.musicValue = 1

		MusicPlayer:getInstance():playBackgroundMusic()
		-- MusicPlayer:getInstance():resumeBackgroundMusic()
	else
		if self.musicSlider then
			self.musicSlider:setValue(0)
		end
		self.musicValue = 0
		-- MusicPlayer:getInstance():pauseBackgroundMusic()
		MusicPlayer:getInstance():stopBackgroundMusic()
	end
	self:saveData()
end

function HallSettingFragment:soundValueChanged(value)
	if value then
		if self.soundSlider then
			self.soundSlider:setValue(1)
		end
		self.soundValue = 1
	else
		if self.soundSlider then
			self.soundSlider:setValue(0)
		end
		self.soundValue = 0
	end
	self:saveData()
end

return HallSettingFragment