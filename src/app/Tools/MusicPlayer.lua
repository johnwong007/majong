--[[声音资源文件]]
MUSIC_FILE_BACKGROUND 			="sounds/background.mp3"
MUSIC_FILE_BACKGROUND 			="sounds/bgMain.mp3"
MUSIC_FILE_BACKGROUND2 			="sounds/background2.mp3"
MUSIC_FILE_BACKGROUND2 			="sounds/bgFight.mp3"
EFFECT_FILE_DISPATCH           ="scene/sounds/card.wav"
EFFECT_FILE_FOLD               ="scene/sounds/fold_cards.mp3"
EFFECT_FILE_CHECK              ="scene/sounds/check2.mp3"
EFFECT_FILE_WAITFOR            ="scene/sounds/active_game.mp3"
EFFECT_FILE_TIMEOUT			="scene/sounds/tick2.mp3"
EFFECT_FILE_WIN                ="scene/sounds/winner.wav"
EFFECT_FILE_LOSE                ="scene/sounds/loser.mp3"
EFFECT_FILE_CALL_PRIZECHIPS    ="scene/sounds/ydcm.wav"
EFFECT_FILE_GAME_START                ="scene/sounds/game_start.mp3"
EFFECT_FILE_BET_CHIP                ="scene/sounds/bet_large_stack.mp3"
EFFECT_FILE_BET_MAN           ="scene/sounds/bet_man.mp3"
EFFECT_FILE_CALL_MAN         ="scene/sounds/call_man.mp3"
EFFECT_FILE_CHECK_MAN         ="scene/sounds/check_man.mp3"
EFFECT_FILE_FOLD_MAN         ="scene/sounds/fold_man.mp3"
EFFECT_FILE_RAISE_MAN         ="scene/sounds/raise_man.mp3"
EFFECT_FILE_RERAISE_MAN         ="scene/sounds/re_raise_man.mp3"
EFFECT_FILE_ALL_IN_MAN                ="scene/sounds/all_in_man.mp3"
EFFECT_FILE_BET_SLIDER_BEEP                ="scene/sounds/bet_slider_beep.mp3"
EFFECT_FILE_CHAT_BUBBLE   		="scene/sounds/chat_bubble.mp3"
EFFECT_FILE_DIALOG_CLOSE   		="scene/sounds/dialog_close.mp3"
EFFECT_FILE_DIALOG_OPEN   		="scene/sounds/dialog_open.mp3"
EFFECT_FILE_DISPATCH_CARD   		="scene/sounds/dispatch_card.mp3"

EFFECT_FILE_PRESS_BUTTON   		="scene/sounds/press_button.mp3"
local SimpleAudioEngine = cc.SimpleAudioEngine

local MusicPlayer = class("MusicPlayer")

sharedMusicPlayer = nil
function MusicPlayer:getInstance()
	if not sharedMusicPlayer then
		sharedMusicPlayer = MusicPlayer:new()
	end
	return sharedMusicPlayer
end

function MusicPlayer:ctor()
	self.shareSetting = require("app.Logic.Config.UserDefaultSetting"):getInstance()
	self.m_timeoutSoundId = 0
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DISPATCH) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_FOLD) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CHECK) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_WAITFOR) )
	--SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_TIMEOUT) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_WIN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_LOSE) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CALL_PRIZECHIPS) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_GAME_START) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_ALL_IN_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_CHIP) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CALL_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CHECK_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_FOLD_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_RAISE_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_RERAISE_MAN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_SLIDER_BEEP) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CHAT_BUBBLE) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DIALOG_CLOSE) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DIALOG_OPEN) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DISPATCH_CARD) )
	SimpleAudioEngine:getInstance():preloadEffect( cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_PRESS_BUTTON) )
	SimpleAudioEngine:getInstance():preloadMusic( cc.FileUtils:getInstance():fullPathForFilename(MUSIC_FILE_BACKGROUND) )
	SimpleAudioEngine:getInstance():preloadMusic( cc.FileUtils:getInstance():fullPathForFilename(MUSIC_FILE_BACKGROUND2) )
    
	-- set default volume
	SimpleAudioEngine:getInstance():setEffectsVolume(1)
end

--点击按钮
function MusicPlayer:playButtonSound()
	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_PRESS_BUTTON))
	end
end

-- --发牌
-- function MusicPlayer:playDispatchCardSound()

-- 	if(self.shareSetting:getSoundEnable()) then
-- 		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DISPATCH_CARD))
-- 	end
-- end

--关闭对话框
function MusicPlayer:playDialogCloseSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DIALOG_CLOSE))
	-- end
end

--打开对话框
function MusicPlayer:playDialogOpenSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DIALOG_OPEN))
	-- end
end

--聊天气泡
function MusicPlayer:playChatBubbleSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CHAT_BUBBLE))
	-- end
end

--加注滑动条声音
function MusicPlayer:playBetSliderBeepSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_SLIDER_BEEP))
	-- end
end

--下筹码声音
function MusicPlayer:playBetChipSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	-- SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_CHIP))
	-- 	self:playCallSound()
	-- end
end

--下注
function MusicPlayer:playBetManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_MAN))
	-- end
end

--跟注
function MusicPlayer:playCallManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CALL_MAN))
	-- end
end

--看牌
function MusicPlayer:playCheckManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CHECK_MAN))
	-- end
end

--弃牌
function MusicPlayer:playFoldManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_FOLD_MAN))
	-- end
end

--加注
function MusicPlayer:playRaiseManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_RAISE_MAN))
	-- end
end

--再加注
function MusicPlayer:playReRaiseManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_RERAISE_MAN))
	-- end
end

--Allin
function MusicPlayer:playAllInManSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_ALL_IN_MAN))
	-- end
end

--比赛开始
function MusicPlayer:playGameStartSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_GAME_START))
	-- end
end

--播放声音
function MusicPlayer:playDispatchCardSound1()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DISPATCH_CARD))
	-- end
end

--播放声音
function MusicPlayer:playDispatchCardSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_DISPATCH))
	end
end

function MusicPlayer:playCallSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_BET_CHIP))
	end
end

function MusicPlayer:callVibrate()
    if (self.shareSetting:getVibrateEnable()) then 
--        ((AppDelegate *)CCApplication::sharedApplication())->callVibrate()
        QManagerPlatform:callVibrate()
    end
end

function MusicPlayer:playFoldSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_FOLD))
	end
end

function MusicPlayer:playCheckSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CHECK))
	end
end

function MusicPlayer:playWaitForSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_WAITFOR))
	end
end

function MusicPlayer:playBackgroundMusic(nId)
	if(self.shareSetting:getMusicEnable()) then
		if nId then
			SimpleAudioEngine:getInstance():playMusic(cc.FileUtils:getInstance():fullPathForFilename(MUSIC_FILE_BACKGROUND2),true)
		else	
			SimpleAudioEngine:getInstance():playMusic(cc.FileUtils:getInstance():fullPathForFilename(MUSIC_FILE_BACKGROUND),true)
		end
	end
end

-- function MusicPlayer:pauseBackgroundMusic()
-- 	if self.shareSetting:getMusicEnable() then
-- 		SimpleAudioEngine:getInstance():pauseBackgroundMusic()
-- 	end
-- end

-- function MusicPlayer:resumeBackgroundMusic()
-- 	if self.shareSetting:getMusicEnable() then
-- 		SimpleAudioEngine:getInstance():resumeBackgroundMusic()
-- 	end
-- end

function MusicPlayer:stopBackgroundMusic()
	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():stopMusic()
	end
end

function MusicPlayer:playActionWillTimeout()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playMusic(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_TIMEOUT),true)
	end
end
function MusicPlayer:stopActionWillTimeout()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():stopMusic()
	end
end
function MusicPlayer:playWinSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_WIN))
	end
end
function MusicPlayer:playLoseSound()

	-- if(self.shareSetting:getSoundEnable()) then
	-- 	SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_LOSE))
	-- end
end

function MusicPlayer:parseOrPlaySound()

    if(self.shareSetting:getSoundEnable()) then
        self:stopBackgroundMusic()
        self.shareSetting:setSoundEnable(false)
    else
        self.shareSetting:setSoundEnable(true)
        self:playBackgroundMusic()
    end
end

function MusicPlayer:parseOrPlayVibrate()

    if(self.shareSetting:getVibrateEnable()) then
        self.shareSetting:setVibrateEnable(false)
    else
        self.shareSetting:setVibrateEnable(true)
    end
end

function MusicPlayer:playPrizeChipsSound()

	if(self.shareSetting:getSoundEnable()) then
		SimpleAudioEngine:getInstance():playEffect(cc.FileUtils:getInstance():fullPathForFilename(EFFECT_FILE_CALL_PRIZECHIPS))
	end
end

--调节音量
function MusicPlayer:setVolume(volume)

	SimpleAudioEngine:getInstance():setEffectsVolume(volume)
end

return MusicPlayer