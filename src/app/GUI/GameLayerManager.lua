--
-- Author: junjie
-- Date: 2015-12-10 10:49:19
--
local GameLayerManager = {}
GameLayerManager.TYPE = {
	SHOPGOLD 	= 1,	--商城
	ACTIVITY 	= 2,	--活动
	EXCHARGE 	= 3,	--兑换
	DIALYTASK	= 4,	--日常任务（免费）
	RANK 		= 5, 	--排行榜
	MORESET 	= 6,	--更多设置
	DAILYSIGN   = 7,	--每日签到
	MAILCENTER	= 8,	--消息中心
	FRIEND 		= 9, 	--好友
	VIP         = 10,	--VIP特权
	PHONEBIND   = 11,   --手机绑定
	HELP        = 12,   --帮助
	PERSONCENTER= 13,   --个人中心
	JIAOXUE		= 14,   --教学
	ANNOUNCE    = 15,   --公告
	FIGHTTEAM   = 16,   --战队

}
function GameLayerManager:switchLayerWithType(LayerType,parent,params,isPlay,dispatchEvt)
	parent = parent or cc.Director:getInstance():getRunningScene()
	local layerPopup 
	if LayerType == GameLayerManager.TYPE.SHOPGOLD then
		layerPopup = require("app.GUI.recharge.ShopGoldLayer")
		params = {
			easing = false
		}
	elseif LayerType == GameLayerManager.TYPE.ACTIVITY then
		layerPopup = require("app.GUI.newactivity.ActivityLayer")
	elseif LayerType == GameLayerManager.TYPE.EXCHARGE then
		layerPopup = require("app.GUI.recharge.ExchargeLayer")
		params = {
			easing = false
		}
	elseif LayerType == GameLayerManager.TYPE.DIALYTASK then
		layerPopup = require("app.GUI.roomView.TaskListLayer")
	elseif LayerType == GameLayerManager.TYPE.RANK then
		layerPopup = require("app.Component.CMCommonLayer")
		params = {
			titlePath = "picdata/rank/title_phb.png",
			bgType = 3,
			selectIdx = 1,
			mAtivityName = {"牌手分榜","周盈利榜","锦标赛榜"}
		}
	elseif LayerType == GameLayerManager.TYPE.MORESET then
		layerPopup = require("app.GUI.setting.MoreMainLayer")
	elseif LayerType == GameLayerManager.TYPE.DAILYSIGN then
		layerPopup = require("app.GUI.reward.RewardLayer"):new()
	elseif LayerType == GameLayerManager.TYPE.MAILCENTER then
		local selectIdx = 1
		if MyInfo.data.showApplyBuy then
			selectIdx = 4
		end
		layerPopup = require("app.Component.CMCommonLayer")
		params = {
			titlePath = "picdata/notice/title.png",
			--titleOffY = -40,
			bgType = 3,
			selectIdx = selectIdx,
			mAtivityName = {"个人日志","系统消息","充值记录","买入申请"}}
		
	elseif LayerType == GameLayerManager.TYPE.FRIEND then
		layerPopup = require("app.GUI.friends.FriendLayer")
	elseif LayerType == GameLayerManager.TYPE.VIP then
		layerPopup = require("app.GUI.setting.MoreVersionLayer")
	elseif LayerType == GameLayerManager.TYPE.PHONEBIND then
		layerPopup = require("app.GUI.setting.MobileBlind")
	elseif LayerType == GameLayerManager.TYPE.HELP then
		layerPopup = require("app.GUI.setting.MoreRuleScene")
	elseif LayerType == GameLayerManager.TYPE.PERSONCENTER then
		layerPopup = require("app.GUI.personCenter.PersonCenterLayer")
		-- layerPopup = require("app.architecture.personCenter.PersonCenterFragment")
	elseif LayerType == GameLayerManager.TYPE.JIAOXUE then
		layerPopup =require("app.GUI.gameTechView.GameTechView"):create("game_tech_table_id",6,2)
        GameSceneManager:switchSceneWithNode(layerPopup);
        return 
    elseif LayerType == GameLayerManager.TYPE.ANNOUNCE then
    	layerPopup = require("app.GUI.notice.AnnounceLayer")
    elseif LayerType == GameLayerManager.TYPE.FIGHTTEAM then
    	local FTManager = require("app.GUI.fightTeam.FTManager")
    	local layerPopup      = FTManager:Instance()
		layerPopup:onEnter({["parent"] = parent})
		return
	end
	if layerPopup then
		CMOpen(layerPopup, parent, params, isPlay, nil, dispatchEvt)
   	end
    return layerPopup
end



return GameLayerManager