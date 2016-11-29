--
-- Author: junjie
-- Date: 2015-12-18 09:58:30
--
local MoreMainLayer = class("MoreMainLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")
local MusicPlayer = require("app.Tools.MusicPlayer")
require("app.Logic.Config.UserDefaultSetting")
require("app.Network.Socket.TcpCommandRequest")
require("app.Network.Socket.PushCommandRequest")
require("app.Network.Http.DBHttpRequest")
local TAG = {


}
local EnumMenu = 
{	
	eBtnLogout = 1,
	eBtnSound  = 2,
	eBtnZD     = 3,
	eBtnVersion= 4,
	eBtnAbout  = 5,
	eBtnScore  = 6,
	eBtnClear  = 7,--清除补丁
	eBtnCheck  = 8,--检查更新
}
function MoreMainLayer:ctor(params)
	self:setNodeEventEnabled(true)
end
function MoreMainLayer:create()
	self:initUI()
	DBHttpRequest:checkVersion(function(tableData,tag) self:httpResponse(tableData,tag) end)	
end
function MoreMainLayer:onExit()

end
function MoreMainLayer:initUI()

	self.mBg = cc.Sprite:create("picdata/more/moreBG.png")
    
	self.mBg:setPosition(display.cx,display.cy)
	self:addChild(self.mBg)

	local title = cc.Sprite:create("picdata/more/moreTitle.png")
	title:setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height - title:getContentSize().height/2+10)
	self.mBg:addChild(title)

	local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end)    
    :align(display.CENTER, self.mBg:getContentSize().width - 20,self.mBg:getContentSize().height-20) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

    self.mSecBg = cc.Sprite:create("picdata/more/moreBGContent.png")
    local bgWidth = self.mSecBg:getContentSize().width
	local bgHeight= self.mSecBg:getContentSize().height
	self.mSecBg :setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height/2-15)
	self.mBg:addChild(self.mSecBg )

	local bound = {x = 0, y = 0, width = self.mSecBg:getContentSize().width, height = self.mSecBg:getContentSize().height} 	

	local node = cc.Node:create()
	node:setContentSize(bound.width,bound.height)

	local posy = bgHeight - 20
	local userName = myInfo.data.userName or ""
	if myInfo.loginType == eDebaoPlatformTouristLogin then
		userName = "(游客)"..myInfo.data.userName
	end 
	local name = cc.ui.UILabel.new({
		        text  = "当前帐号",
		        size  = 24,
		        color = cc.c3b(135, 154, 192),
		        x     = 40,
		        y     = posy,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        --UILabelType = 1,
        		font  = "黑体",
		    })
	node:addChild(name)

	posy = posy - 60
	local data = {}
	data.textPath = "picdata/more/logout.png"
	if DBChannel ~= "10866" then --部分联运渠道去除登出功能
		data.btnPath = "picdata/public2/btn_h50_blue.png"
		data.btnTag  = EnumMenu.eBtnLogout
	end
	data.text = userName
	local accountNode = self:createCell(data)
	accountNode:setPosition(bgWidth/2,posy)
	node:addChild(accountNode)

	posy = posy - 70
	local gemaset = cc.ui.UILabel.new({
		        text  = "游戏设置",
		        size  = 24,
		        color = cc.c3b(135, 154, 192),
		        x     = 40,
		        y     = posy,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        --UILabelType = 1,
        		font  = "黑体",
		    })
	node:addChild(gemaset)

	--音效

	posy = posy - 60
	local data = {}
	data.btnPath = "picdata/public/sliderClose.png"
	if UserDefaultSetting:getInstance():getSoundEnable() then
		data.btnPath = "picdata/public/sliderOpen.png"
	else
		data.btnPath = "picdata/public/sliderClose.png"
	end
	data.btnTag  = EnumMenu.eBtnSound
	data.path = "picdata/more/music.png"
	data.scale = false
	local accountNode = self:createCell(data)
	accountNode:setPosition(bgWidth/2,posy)
	node:addChild(accountNode)

	--振动
	posy = posy - 80
	local data = {}
	data.btnPath = "picdata/public/sliderClose.png"
	if UserDefaultSetting:getInstance():getVibrateEnable() then
		data.btnPath = "picdata/public/sliderOpen.png"
	else
		data.btnPath = "picdata/public/sliderClose.png"
	end
	data.btnTag  = EnumMenu.eBtnZD
	data.path = "picdata/more/vibration.png"
	data.scale = false
	local accountNode = self:createCell(data)
	accountNode:setPosition(bgWidth/2,posy)
	node:addChild(accountNode)

	--版本
	posy = posy - 70
	local sVersion = cc.ui.UILabel.new({
		        text  = "其他",
		        size  = 24,
		        color = cc.c3b(135, 154, 192),
		        x     = 40,
		        y     = posy,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        --UILabelType = 1,
        		font  = "黑体",
		    })
	node:addChild(sVersion)


	local data = {
	{path = "picdata/more/version.png",btnPath = nil,offy = 60,btnText = DBVersion,text = nil,btnTag = nil,},
	{path = "picdata/more/w_jcgx.png",textPath = "picdata/more/btn_update.png",btnPath = "picdata/public2/btn_h50_blue.png",offy = 80,btnText = nil,text = nil,btnTag = EnumMenu.eBtnCheck,},
	-- {path = "picdata/more/w_qchc.png",textPath = "picdata/more/btn_clean.png",btnPath = "picdata/public2/btn_h50_blue.png",offy = 80,btnText = nil,text = nil,btnTag = EnumMenu.eBtnClear,},
}
	for i = 1,#data do 
		posy = posy - data[i].offy 
		local accountNode = self:createCell(data[i])
		accountNode:setPosition(bgWidth/2,posy)
		node:addChild(accountNode)
		if i == 2 then 
			self.mBtnCheck = accountNode
			self.mBtnCheck:getChildByTag(101):setVisible(false)
			if GIOSCHECK then
	    		self.mBtnCheck:setVisible(false)
	    	end
		end
	end
	

    -- if DEBAO_PHONE_PLATFORM == DEBAO_IOS then
		--关于
		posy = posy - 80	
		local data = {}
		data.btnPath = "picdata/more/rightArrow.png"
		data.btnTag  = EnumMenu.eBtnAbout
		data.path = "picdata/more/about.png"
		data.IsBtn = true
		local accountNode = self:createCell(data)
		accountNode:setPosition(bgWidth/2,posy)
		node:addChild(accountNode)
		-- if UserDefaultSetting:getInstance():getAppleCheckFlag() ==1 then
		if device.platform == "ios" then
			--App评分
			posy = posy - 80	
			local data = {}
			data.btnPath = "picdata/more/rightArrow.png"
			data.btnTag  = EnumMenu.eBtnScore
			data.path = "picdata/more/score.png"
			data.IsBtn = true
			local accountNode = self:createCell(data)
			accountNode:setPosition(bgWidth/2,posy)
			node:addChild(accountNode)
		end
		-- end
	-- end

	local item = cc.ui.UIScrollView.new({
	    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	    viewRect = bound, 
	   -- scrollbarImgH = "scroll/barH.png",
	   -- scrollbarImgV = "scroll/bar.png",
	   --bgColor = cc.c4b(125,125,125,125)
	})
    :addScrollNode(node)
    :onScroll(function (event)
        --print("ScrollListener:" .. event.name)
    end) --注册scroll监听
    :addTo(self.mSecBg)
	--item:getScrollNode():setPosition(0,node:getContentSize().height)

end
function MoreMainLayer:createCell(data)
	data = data or {} 
	local bg = cc.Sprite:create("picdata/more/moreCell.png")

	if data.text then
		local name = cc.ui.UILabel.new({
			        text  = data.text,
			        size  = 24,
			        color = cc.c3b(1, 250, 221),
			        x     = 50,
			        y     = bg:getContentSize().height/2,
			        align = cc.ui.TEXT_ALIGN_LEFT,
			        --UILabelType = 1,
	        		font  = "黑体",
			    })
		bg:addChild(name)
	end
	if data.path  then
		local name = cc.Sprite:create(data.path)
		name:setPosition(30+name:getContentSize().width/2,bg:getContentSize().height/2)
		bg:addChild(name)
	end
	if data.btnText then
		local btnText = cc.ui.UILabel.new({
			        text  = data.btnText,
			        size  = 26,
			        color = cc.c3b(1, 250, 221),
			        x     = bg:getContentSize().width - 240,
			        y     = bg:getContentSize().height/2,
			        align = cc.ui.TEXT_ALIGN_LEFT,
			        --UILabelType = 1,
	        		font  = "黑体",
			    })
		bg:addChild(btnText)
	end
	if data.btnPath then
		local btnClose = CMButton.new({normal = data.btnPath},function () self:onMenuCallBack(data.btnTag,bg) end,{scale9 = false},{scale = data.scale,textPath = data.textPath})    
	    :align(display.CENTER, bg:getContentSize().width - 80,bg:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
	    :addTo(bg,0,101)
	     btnClose:setTouchSwallowEnabled(false)
	     if data.IsBtn then
			btnClose:setPosition(bg:getContentSize().width - 40,bg:getContentSize().height/2)
		end
	end
	if data.IsBtn then
		bg:setTouchEnabled(true)
		bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event,btn) return self:onMenuCallBack(data.btnTag,bg) end)
	end
    return bg
end

function MoreMainLayer:onMenuCallBack(tag,node)
	if tag == EnumMenu.eBtnLogout then

		self:onMenuLogout()

	elseif tag == EnumMenu.eBtnSound then
		MusicPlayer:getInstance():parseOrPlaySound()
		if UserDefaultSetting:getInstance():getSoundEnable() then
			node:getChildByTag(101):setTexture("picdata/public/sliderOpen.png")
		else
			node:getChildByTag(101):setTexture("picdata/public/sliderClose.png")
		end
	elseif tag == EnumMenu.eBtnZD then
		MusicPlayer:getInstance():parseOrPlayVibrate()
		if UserDefaultSetting:getInstance():getVibrateEnable() then
			node:getChildByTag(101):setTexture("picdata/public/sliderOpen.png")
		else
			node:getChildByTag(101):setTexture("picdata/public/sliderClose.png")
		end
	elseif tag == EnumMenu.eBtnVersion then

	elseif tag == EnumMenu.eBtnAbout then
		self:setVisible(false)
		local RewardLayer = require("app.Component.CMAlertDialog").new({text = self:getContent(),titleText = "德堡用户协议",scroll = true,showType = 0,callOk = function () self:setVisible(true) end})
		CMOpen(RewardLayer, self:getParent())
	elseif tag == EnumMenu.eBtnScore then

	elseif tag == EnumMenu.eBtnClear then
		local tips = "清除缓存后，需要重新登录游戏进行更新，确定清除吗？"
		local RewardLayer = require("app.Component.CMAlertDialog").new({
			text = tips,
			showType = 2,
			callOk = function () self:onMenuClear() end})
		CMOpen(RewardLayer, self:getParent())
	elseif tag == EnumMenu.eBtnCheck then
		local tips = "检测到有新的版本，是否前往更新？\n(更新后请重启游戏)"
		local RewardLayer = require("app.Component.CMAlertDialog").new({
			text = tips,
			showType = 2,
			callOk = function () require("app.GUI.GameSceneManager")
    			GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.UpdateScene) end})
		CMOpen(RewardLayer, self:getParent())
	end
end
function MoreMainLayer:onMenuLogout()
	QManagerData:removeAllCacheData()
	QManagerListener:clearAllLayerID()

	UserDefaultSetting:getInstance():setLastLoginTimeStamp(myInfo.data.userId,myInfo.data.serverTime)
	UserDefaultSetting:getInstance():setAutoLoginEnable(false)
	myInfo.data.phpSessionId = ""
	GIsConnectRCToken = false
	
	myInfo:clearCacheData()
	local tcp = TcpCommandRequest:shareInstance()
	if tcp:isConnect() then
		tcp:closeConnect()
	end
	local push = PushCommandRequest:shareInstance()
	if push:isConnect() then
		push:closeConnect()
	end
	QManagerPlatform:disConnectRongYun()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)

end
function MoreMainLayer:onMenuClear()
	require("app.Component.CMHandleDirectory")
    CMRemoveDirectory(device.writablePath.."update/")
    self:onCheckDirctory()
    
end
--[[
	判断是否清除完成
]]
function MoreMainLayer:onCheckDirctory()
	self:showProgress(true)
	local dir = device.writablePath.."update/"
	while true do
		if not CMCheckDirectory(dir) then
			CMDelay(self,1,function () self:showProgress(false) self:showRestart() end)
			break
		end
	end
end
--[[
	显示删除进度条
]]
function MoreMainLayer:showProgress(bool)
	if bool then
		self:newProgressTimer("picdata/public/probg.png","picdata/public/pro.png" )	
	else
		if self.mProgressNode then
			self.mProgressNode:removeFromParent(true)
			self.mProgressNode = nil
		end
	end
end
--[[
	游戏重启
]]
function MoreMainLayer:showRestart()
	local tips = "清除完毕,立即重启？"
	local RewardLayer = require("app.Component.CMAlertDialog").new({
		text = tips,
		showType = 1,
		callOk = function () 
		-- QManagerPlatform:restartGameApp() 
		os.exit()
		end})
	CMOpen(RewardLayer, self:getParent())
end
--【【更新进度条】】
function MoreMainLayer:newProgressTimer( bgBarImg,progressBarImg )
	self.mProgressNode = cc.Node:create()
	self:addChild(self.mProgressNode) 

	local tips = display.newTTFLabel({text = string.format("正在删除,请稍候.."), 
	size = 22, align = cc.TEXT_ALIGN_CENTER, color = cc.c3b(125,125,0)}):pos(display.cx,60)
	:addTo(self.mProgressNode)

    local prebg = display.newSprite(bgBarImg)
    prebg:setPosition(cc.p(display.cx,100))
    self.mProgressNode:addChild(prebg)

    local pro = cc.Sprite:create(progressBarImg)
    local progress = cc.ProgressTimer:create(pro)   
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)    
    progress:setBarChangeRate(cc.p(1, 0))      
    progress:setMidpoint(cc.p(0,1)) 
    progress:setPercentage(0)      
    progress:setPosition(display.cx,100)     
    self.mProgressNode:addChild(progress) 
    self.progressTimer = progress


    self.progressTimer:runAction(cca.repeatForever(cca.progressFromTo(1,0,100)))
    -- self.progressTimer:stopAllActions()
end
function MoreMainLayer:getContent()
	local str = {}
	str[1] = "1.特别提示 \n1.1德堡手机游戏平台同意按照《德堡手机游戏平台通行证用户服务协议》（下称\"本协议\”）的规定及其不时发布的操作规则提供基于互联网的相关服务(以下称\"服务\”)，为获得服务，服务使用人(以下称\"用户\”)同意本协议的全部条款并按照页面上的提示完成全部的注册程序。德堡手机游戏平台服务涉及到的德堡手机游戏平台产品的所有权以及相关软件的知识产权归德堡手机游戏平台所有。德堡手机游戏平台所提供的服务必须按照其发布的服务条款和操作规则严格执行。本服务条款的效力范围及于德堡手机游戏平台的一切产品和服务，用户在享受德堡手机游戏平台德堡手机游戏平台任何单项服务时，应当受本服务条款的约束。用户在进行注册程序过程中点击\"同意\”按钮即表示用户完全接受本"
	str[2] = "协议项下的全部条款。 \n1.2由于用户及市场状况的不断变化，德堡手机游戏平台保留随时修改本协议条款的权利，修改本协议条款时，德堡手机游戏平台将于相关页面公告修改的事实，而不另行对用户进行个别通知。若用户不同意修改的内容，可停止使用全部德堡手机游戏平台所提供的服务。若用户继续使用德堡手机游戏平台所提供的任意服务，即视为用户业已接受德堡手机游戏平台所修订的内容。 \n1.3用户可随时造访www.debao.com查阅最新协议。用户在使用德堡手机游戏平台提供的各项服务之前，应仔细阅读本协议，如用户不同意本协议及/或随时对其的更改，请停止使用德堡手机游戏平台提供的服务。 \n1.4如果用户希望通过德堡手机游戏平台通行证账号使用任一网站提供的论坛服务时，用户还需接受"
	str[3] = "《论坛服务用户使用协议》。《德堡手机游戏平台用户信息保密条款》系明确约定德堡手机游戏平台对于用户使用德堡手机游戏平台服务而提供和产生的信息承担一定保密义务的条款，是本协议的重要组成部分。请务必仔细阅读《德堡手机游戏平台用户信息保密条款》，对本议的同意即视为对《德堡手机游戏平台用户信息保密条款》的同意。 \n2.服务内容 \n2.1德堡手机游戏平台服务的具体内容由德堡手机游戏平台根据实际情况提供，例如论坛(BBS)、聊天室、电子邮件、发表新闻评论等。德堡手机游戏平台保留随时变更、中断或终止部分或全部服务的权利。\n2.2德堡手机游戏平台在提供服务时，可能会对部分服务(例如网络游戏及其他电信增值服务)的用户收取一定的费用。在此情况下，德堡手机游戏平台会在相关页面上做"
	str[4] = "出明确提示。如用户不同意支付该等费用，则可不接受相关服务。\n2.3用户理解：德堡手机游戏平台仅提供相关服务，此之外与相关服务有关的设备(如电脑、调制解调器及其他与接入互联网有关的装置)及所需的费用(如为接入互联网而支付的电话费及上网费)均应由用户自行负担。\n2.4用户应使用正版软件接受服务。\n3.用户帐号\n3.1用户帐号注册\n3.1.1用户必须完全同意协议所有条款并完成注册程序，在用户注册成功后，德堡手机游戏平台将给予每个用户一个用户帐号及相应的密码，该用户帐号和密码由用户负责保管；用户应当对以其用户帐号进行的所有活动和事件负法律责任。\n3.1.2注册过程中，用户应按照相关网页上的要求输入正确的个人基本资料，包括真实姓名"
	str[5] = "和有效的身份证、护照、军人证号码。用户承诺以其真实身份注册账号，并保证所提供的个人身份资料信息真实、完整、有效，依据法律规定和本协议的约定对所提供的信息承担相应的法律责任。\n3.1.3用户输入的姓名和身份证、护照、人证号码结合其与之对应的证件，作为用户的唯一有效身份证明；在用户无法有效证明其身份时，德堡手机游戏平台有权拒绝提供任何信息或承担任何义务。\n3.1.4每位用户只能拥有一个德堡手机游戏平台账号，且必须在使用本服务时使用该单一账号，德堡手机游戏平台禁止用户使用多重账号，若用户使用多重账号，德堡手机游戏平台有权不经过通知立即关闭其账号，并且冻结其资金。\n3.2用户帐号修改\n3.2.1用户以真实身份注册成为德堡手机游戏平台用户"
	str[6] = "后，需要修改所提供的个人信息（包括电子邮箱、联系方式）的，须向德堡手机游戏平台提供与原注册资料相符合的身份证复印件及需要修改的信息，经德堡手机游戏平台核实成功后，及时有效地为用户提供修改服务。\n3.2.2用户帐号信息发生变更而未及时修改，导致无法证明用户的有效身份，德堡手机游戏平台有权拒绝提供任何信息或承担任何义务。\n3.3用户帐号使用\n3.3.1用户在使用德堡手机游戏平台服务过程中，必须遵循以下原则：\n\t(A)遵守中国有关的法律和法规；\n\t(B)不得为任何非法目的而使用服务系统；\n\t(C)遵守所有与服务有关的网络协议、规定和程序；\n\t(D)不得利用德堡手机游戏平台服务系统进行任何可能对互联网的正常运转造成不利影响的行为；\n\t(E)不得利用德堡手机游戏平台服务"
	str[7] = "系统传输任何骚扰性的、中伤他人的、辱骂性的、恐吓性的、庸俗淫秽的或其他任何非法的信息资料；\n\t(F)不得利用德堡手机游戏平台服务系统进行任何不利于德堡手机游戏平台的行为；\n\t(G)就德堡手机游戏平台及合作商业伙伴的服务、产品、业务咨询应采取相应机构提供的沟通渠道，不得在公众场合发布有关德堡手机游戏平台及相关服务的负面宣传；\n\t(H)如发现任何非法使用用户帐号或帐号出现安全漏洞的情况，应立即通告德堡手机游戏平台；\n3.3.2用户使用根据本协议获得的用户帐号和密码登录德堡手机游戏平台的网站或接受其他德堡手机游戏平台提供的服务项目时，应遵守该网站或服务项目的相关服务协议及使用守则，用户登录上述网站或接受上述服务项目时即视为对相关服务协议及使用守则的接受。"
	str[8] = "\n3.3.3用户同意接受德堡手机游戏平台通过电子邮件或其他方式向用户发送的商品促销或其他相关商业信息。\n3.4用户帐号的保管\n3.4.1德堡手机游戏平台有权审查用户注册所提供的身份信息是否真实、有效，并应积极地采取技术与管理等合理措施保障用户账号的安全、有效；用户有义务妥善保管其账号及密码，并正确、安全地使用其账号及密码。任何一方未尽上述义务导致账号密码遗失、账号被盗等情形而给用户和他人的民事权利造成损害的，应当承担由此产生的法律责任。\n3.4.2德堡手机游戏平台对登录后所持账号产生的行为依法享有权利和承担责任。如若有任何第三方向德堡手机游戏平台发出指示，在确认其提供账户、密码信息准确的情况下，用户同意且德堡手机游戏平台有"
	str[9] = "权视为该行为获得了用户的充分授权，该行为所产生结果直接归属于用户本身。\n3.4.3若用户发现账号或密码被他人非法使用或有异常使用的情形，请立即通知德堡手机游戏平台，并有权通知德堡手机游戏平台暂停该账号的登录和使用，但用户在进行该等申请时应提供与其注册身份信息相一致的个人有效身份信息。德堡手机游戏平台核实用户所提供的个人有效身份信息与所注册的身份信息相一致的，应当及时采取措施暂停用户账号的登录和使用。德堡手机游戏平台违反上述约定，未及时采取措施暂停用户账号的登录和使用，因此而给用户造成损失的，应当承担其相应的法律责任。用户没有提供其个人有效身份证件或者用户提供的个人有效身份证件与所注册的身份信息不一致的，德堡手机游戏平台"
	str[10] = "有权拒绝用户上述请求。\n3.4.4若德堡手机游戏平台发现疑似遭盗用的会员帐号，有权立即终止该会员帐号的使用权。3\n.4.5若因为用户自身原因，而导致账号、密码遭他人非法使用时，德堡手机游戏平台将不负责处理。用户自身原因包括但不限于：任意向第三者透露账号和密码及所有注册资料；多人共享同一个账号；安装非法或来路不明的程序等。\n4.所有权\n4.1德堡手机游戏平台提供的服务内容中包括和/或涉及的所有的作品及资料（包括但不仅限于任何字幕、计算机代码、主题、物件、游戏角色、游戏角色名称、故事内容、对话内容、流行语、游戏概念、美术作品、动画、声效、乐曲、音像效果、运算方法、文档、线上聊天记录副本、游戏角色资料信息、游戏客户端"
	str[11] = "和服务器软件等），其著作权、专利权、商标专用权、商业秘密权及其它知识产权，均为德堡手机游戏平台或授权德堡手机游戏平台使用的合法权利人所有，除非事先经德堡手机游戏平台或其权利人的合法授权，任何人皆不得擅自以任何形式使用，否则德堡手机游戏平台可立即终止向用户提供产品和服务，并依法追究其法律责任，赔偿德堡手机游戏平台6一切损失。\n4.2未经德堡手机游戏平台授权，任何人不得擅自复制、反编译(de-compile)、反汇编(disassemble)任何功能或程序，不得对任何功能和/或程序进行反向工程(reverseengineering)。\n4.3用户在此同意并确认，用户账号数据和所有其它相关信息，包括用户提供的个人信息、账号中的游戏角色和虚拟物品（除另有约定外，本条款所"
	str[12] = "指的\"虚拟物品\”包括游戏内虚拟货币、积分、道具、装备、材料等）都归德堡手机游戏平台所有。\n5、服务的中止和终止\n5.1服务的中止用户在此同意并确认，其有下列行为之一时，德堡手机游戏平台有权中止为该用户提供部分或全部服务，对其帐户做冻结处理：\n5.1.1提供虚假注册身份信息；\n5.1.2实施了违法本协议的行为；\n5.1.3实施了损害第三方用户权益或利益的行为；\n5.1.4在用户实施5.1.1和5.1.2行为后，德堡手机游戏平台有权中止为该用户提供部分或全部服务；德堡手机游戏平台在采取中止措施时，将告知用户中止期间，中止期间应该是合理的，中止期间届满后，德堡手机游戏平台应当及时恢复对用户的服务。但中止期间届满时，如果用户的违约状态仍然存在的，则德堡手机游戏平台"
	str[13] = "有权延长中止服务的期间。\n5.1.5德堡手机游戏平台依据用户实施5.1.1和5.1.2行为，采取中止服务措施的，应当承担相应的举证责任。\n5.2服务的终止用户同意其实施了下列行为之一时，德堡手机游戏平台有权终止为该用户提供服务，对其帐户做删除处理：\n5.2.1发布违法信息；\n5.2.2严重违背社会公德以及其他违反法律禁止性规定的行为；\n5.2.3通过非法手段、不正当手段或其他不公平的手段使用德堡手机游戏平台服务或参加德堡手机游戏平台活动；\n5.2.4干扰德堡手机游戏平台正常地提供产品和服务，包括但不限于：攻击、侵入德堡手机游戏平台的网站服务器、游戏服务器客户端程序或使网站服务器过载；\n5.2.5破解、修改德堡手机游戏平台提供的客户端程序；\n5.2.6制作、发布、传播、使用"
	str[14] = "任何形式的妨碍游戏公平性的辅助工具或程序(外挂)；\n5.2.7利用程序的漏洞和错误(Bug)破坏游戏的正常进行或传播该漏洞或错误(Bug)；\n5.2.8连续180天没有使用德堡手机游戏平台所提供的服务（自用户最后一次使用服务之日起计算），则自第180天当天的24时起，德堡手机游戏平台有权采取措施终止该用户继续使用服务，删除该用户帐号，包括但不限于注册信息、等级信息、角色信息、物品信息等一切与注册帐号相关的信息，且勿需对删除该帐号所带来的任何利益损失负责；\n5.2.9实施其他不合理地干扰或阻碍他人使用德堡手机游戏平台所提供服务或损害其他用户利益和权益的行为；\n5.2.10德堡手机游戏平台依据用户实施5.2.1和5.2.2行为，采取终止服务措施的，应当承担"
	str[15] = "相应的举证责任。\n5.3为了维护和保证用户使用德堡手机游戏平台服务时的公平性，在德堡手机游戏平台发现用户数据异常时，无论用户对该异常数据的产生是否存在过错，德堡手机游戏平台均有权根据本协议及之后不定期发布的服务公告等，采取相应措施：包括但不限于对该账号的冻结、中止、终止、删除；用户在此承诺德堡手机游戏平台有权作出上述行为，并承诺不就上述行为要求德堡手机游戏平台作出任何形式的补偿或退费。\n6、用户的义务\n6.1自行提供与服务有关的设备(如电脑、调制解调器及其他与接入互联网有关的装置)并承担所需的费用(如为接入互联网而支付的电话费及上网费。\n6.2使用正版软件接受服务。\n6.3按照第3.1条的规定完成注册程序，提供详尽、准确的个人资料并"
	str[16] = "不断更新个人资料。如果因为用户提供的资料包含有不正确的信息，导致用户不能正常使用德堡手机游戏平台提供的服务，德堡手机游戏平台不承担任何责任。\n6.4遵守第3.3条中所述的各项约定。\n6.5用户承诺，非经德堡手机游戏平台同意，用户不能利用德堡手机游戏平台的各项服务进行销售或其他商业用途。如用户有需要将服务用于商业用途，应书面通知德堡手机游戏平台并获得德堡手机游戏平台的明确授权。\n6.6履行第6条约定义务之外的所有其他任何义务。\n6.7用户承诺，任何时候不以任何理由在用户之间发起或参与任何串通作弊的活动，否则，德堡手机游戏平台有权对发起或参与者采取封号措施，并保留追究法律责任的权利。\n6.8用户承诺，游戏金币只用于本人在游戏中使用，不与任意用户在游戏中"
	str[17] = "及线下进行任何叫卖、转让游戏金币的行为，若违反此规定，德堡手机游戏平台有权对参与者采取永久封号，账户清零的措施。\n7、德堡手机游戏平台的义务\n7.1在法律法规允许的范围内，利用互联网为用户提供网络服务。\n7.2严格按照《德堡手机游戏平台用户信息保密条款》的约定对用户信息承担保密义务。\n7.3依据我国法律规定，核实用户所提供的个人有效身份信息与所注册的身份信息是否一致，经核实后，发现一致的，德堡手机游戏平台应当为用户提供账号注册人证明、原始注册信息等必要的协助和支持，并根据需要向有关行政机关和司法机关提供相关证据信息资料。\n8.服务的中断、停止\n8.1用户了解并认可，为了网站的正常运行，德堡手机游戏平台需定期或不定期地对网站进行停机维护，"
	str[18] = "这种因系统维护或升级的需要而需暂停服务时，德堡手机游戏平台将尽可能事先进行通告。因此类情况而造成的正常服务的中断、停止，用户应该予以理解。\n8.2发生下列情形之一时，德堡手机游戏平台有权停止或中断服务器所提供之服务，对因此而产生的不便或损害，德堡手机游戏平台不承担任何责任：\n8.2.1定期检查或施工，更新软硬件等；\n8.2.2服务器遭受损坏，导致无法正常运作；\n8.2.3突发性的软硬件设备与电子通信设备故障；\n8.2.4网路提供商线路或其它故障，无法提供服务；\n8.2.5在紧急情况之下为维护国家安全或其它会员及第三者之人身安全；\n8.2.6不可抗力及其他第三方原因致使德堡手机游戏平台无法提供服务；\n8.2.7由于相关政府机构的要求。\n8.3用户同意德堡手机游戏平台"
	str[19] = "享有通过提前60天在服务所涉官方网站公告通知的方式中断或终止部分或全部服务的权利，用户已明确知晓上述权利的授予且知晓因上述权利的行使可能给自身及其他第三方造成的直接或间接利益减损，用户在此明确表示不追究德堡手机游戏平台因行使上述单方中断或终止服务权利而可能导致的一切责任。\n8.4用户在此同意并确认：德堡手机游戏平台提供服务时可能会涉及到虚拟物品（包括但不限于道具、材料等），该虚拟物品仅在服务运营期内有效，服务停止时，虚拟物品将随服务停止运营而消失，用户一经获得将不得以任何形式退还给德堡手机游戏平台。但对于用户已经购买但尚未使用的虚拟货币，德堡手机游戏平台将以法定货币方式或用户接受的其他方式退还用户。德堡手机游戏平台将在"
	str[20] = "终止服务公告中明确虚拟货币申请退还的期限和具体的退还政策。用户届时应依照德堡手机游戏平台公布的具体政策申请办理退还手续。如在德堡手机游戏平台的申请退还期限届满后，用户依照德堡手机游戏平台公布具体政策提交的退还申请未能到达德堡手机游戏平台指定接受地址的，视为用户自动放弃该项退还权利，德堡手机游戏平台针对该用户已经购买但尚未使用的虚拟货币有权予以拒绝进行退还处理。\n9.免责声明\n9.1德堡手机游戏平台就其所提供的服务，不负任何明示或默示的担保责任，而其所提供的服务的稳定、安全、无误及不中断性亦有可能因第8条所述情形而受到影响。用户应自行承担使用服务所有的风险及因此可能导致的损害，包括而不限于其因使用服务而到德堡手机游戏平台官方网站下载游戏"
	str[21] = "或资料图片而导致用户或其所使用的计算机系统非因德堡手机游戏平台主观原因造成的损害，或发生任何资料的流失等。\n9.2德堡手机游戏平台对其服务不保证不出现任何程序BUG,并对由此可能产生的问题不承担任何赔偿责任。\n9.3德堡手机游戏平台不保证其所提供的服务将符合每位用户的要求，不保证服务将不受干扰，也不对服务的及时性、安全性、出错发生以及信息是否能准确、及时、顺利地传送作任何担保。\n9.4用户明确同意其使用德堡手机游戏平台服务所存在的风险将完全由其自己承担；因其使用德堡手机游戏平台服务而产生的一切后果也由其自己承担，德堡手机游戏平台对用户不承担任何责任。\n9.5由于虚拟物品之间的交易存在一定的风险（包括但不限于虚拟物品因复制等数据异常而可能被删"
	str[22] = "除；国家现阶段法律对其价值认定仍处于空白等），用户在交易过程中应对交易方及交易物品尽审慎注意义务，除非该交易系依照德堡手机游戏平台书面明确指示为之，否则，德堡手机游戏平台将不对该交易中产生的任何问题进行支持和保障。\n9.6用户在此同意并确认，在适用法律允许的最大范围内，德堡手机游戏平台所提供的服务是在\"现状\”及\"现有\”基础上提供给用户使用，不包括任何类型的明示或暗示的担保（包括但不限于适销性、针对特定目的的适用性、所有权、不侵权以及由交易习惯所引发的各种可能性）。德堡手机游戏平台不保证用户可按照其所选择的时间和地点访问或使用德堡手机游戏平台服务，不保证德堡手机游戏平台服务不会中断或没有错误，不保证缺陷必被纠正，也不保证德堡手机游戏平台"
	str[23] = "服务均不含病毒或其它有害要素。\n9.7用户在服务所涉官方网站上所表达的观点、建议、意见和其它内容均为用户本人看法，不代表德堡手机游戏平台的观点，因此而产生的法律纠纷或责任，与德堡手机游戏平台无关，均由用户承担。\n10.违约赔偿\n10.1用户同意保障和维护德堡手机游戏平台及其他用户的利益，如因用户违反有关法律、法规或本协议项下的任何条款而导致德堡手机游戏平台、或其关系企业、受雇人、受托人、代理人或/及其它相关履行辅助人或任何其他第三人因此而受到损害或支出费用（包括但不限于由法律诉讼、行政程序等所支出的诉讼费用、律师费用、实际遭受损失的费用等），用户应负担损害赔偿责任。\n10.2德堡手机游戏平台对于用户使用其服务或无法使用网络所导致"
	str[24] = "的任何直接、间接、衍生的损害或所失利益不负任何损害赔偿责任。\n11、纠纷处理方式\n11.1用户之间纠纷处理方式\n11.1.1德堡手机游戏平台作为提供服务的运营商，如若用户之间发生纠纷且无法协商一致的，可向国家相关行政机关或司法机关寻求解决，包括但不限于向公安机关报案、申请仲裁或向人民法院提起诉讼等。德堡手机游戏平台将会为实名注册用户提供必要的协助和支持，并根据有关行政机关和司法机关的要求承担一定的举证责任或采取必要措施。\n11.1.2因使用德堡手机游戏平台所提供服务的用户之间发生纠纷的，也可向德堡手机游戏平台的客服人员投诉并举证。用户需提供与其账号注册信息一致的个人有效身份证件、必要的国家行政或司法机关文件和其他本公司要求提供的相关"
	str[25] = "证据。经德堡手机游戏平台审核确认后，可以给予必要的协助和支持。\n11.2用户与德堡手机游戏平台之间纠纷处理方式\n11.2.1用户对德堡手机游戏平台的服务有任何异议的，可以向德堡手机游戏平台的客服人员投诉并举证。查证属实的，德堡手机游戏平台将立即更正并按照现行法律规定及本协议之约定给予用户必要的补偿。\n11.2.2用户对德堡手机游戏平台提供的服务有任何异议的，可向德堡手机游戏平台所在地人民法院提起诉讼。2.法律管辖\n12.1本协议的订立、执行和解释及争议的解决均应适用中国法律。\n12.2如双方就本协议内容或其执行发生任何争议，双方应尽量友好协商解决；协商不成时，任何一方均可向德堡手机游戏平台所有权人所在地的人民法院提起诉讼。\n13.通知和送达\n13.1本协议项下所有的通知均可"
	str[26] = "通过重要页面公告、电子邮件或常规的信件传送等方式进行；该等通知于发送之日视为已送达收件人。\n14.授权使用\n14.1用户在此同意并确认，其藉由使用德堡手机游戏平台提供的服务而上传、传送、输入或以其他方式提供到德堡手机游戏平台服务所涉官方网站的任何原创作品、交流信息、图像、声音和所有材料及信息，包括但不限于任何聊天记录、语音通信信息、IP地址、软硬件使用信息以及用户个人信息，均视为用户授予德堡手机游戏平台对该等信息和/或作品永久的、不可撤销的、全球范围内的、免费的、非排他性的许可，德堡手机游戏平台可在现行法律范围内就该等信息和/或作品进行使用，包括但不限于复制、修正、改编、修改、翻译、重编、创建衍生作品、制造、引入流通、出版、"
	str[27] = "发行、销售、许可、转让、出租、租赁、传输、公开展示、公开表演、提供电子访问接口、广播、通过通信手段向公众传达、展示、表演、输入电脑内存、使用并实现此类用户内容及所有在其基础上修改和衍生的作品、分授权给其他任何第三方。\n15.其他规定\n15.1本协议构成双方对本协议之约定事项及其他有关事宜的完整协议，除本协议规定的之外，未赋予本协议各方其他权利。15.2如本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，本协议的其余条款仍应有效并且有约束力。\n15.3本协议中的标题仅为方便而设，不具法律或契约效果。\n16.解释权\n16.1在适用法律允许的最大范围内，德堡手机游戏平台保留对本协议的最终解释权。用户如对本协议有任何"
	str[28] = "疑问，请登陆德堡手机游戏平台或官方网站获取相关信息或拨打本公司客服电话。"
	return str
end
function MoreMainLayer:showParentControl()
	local str = {}
	str[1] ="一、申请条件\n\t1、申请人需为被监护未成年人的法定监护人；\n\t2、申请人的被监护人年龄小于18周岁；\n\t3、申请人需为大陆公民，不含港、澳、台人士。\n二、申请需要提交材料\n\t申请文档：德堡游戏监护服务申请文档（点击下载）\n\t温馨提醒，您在邮寄申请书时，要记得一起提供如下资料：\n\t附件1：申请人的身份证（复印件）\n\t附件2：被申请人的身份证（复印件）\n\t附件3：申请人与被申请人的监护法律关系证明文件（户口簿或者其他合法有效证明文件）"
	str[2] ="三、申请方式\n\t申请材料务必为纸质，材料邮寄至我司，详细请邮件咨询：KF@debao.com\n\t邮寄信息：\n\t收件方：深圳市广阔天空网络科技有限公司 客服部\n\t邮寄地址：深圳市南山区科苑中区深圳软件园二期9栋6楼\n\t邮政编码：518057"
	str[3] ="四、申请流程：\n\t监护人提出申请；\n\t若监护人发现被监护人沉溺于德堡游戏，监护人可向我司申请发起未成年人家长监护机制；\n\t监护人须通过邮寄方式向我司提供纸质的有效材料，提出未成年人账户监控申请；我司在收到邮件后开始启动监护机制审核流程；\n\t首先进入疑似账号身份确认期（15个自然日）；\n\t经我司审查，申请材料完整且符合要求者，我司将通过官方邮箱联系疑似帐号归属者，告知其在15个自然日内将按照监护人需求对其账号进行相关操作，并要求疑似账号归属者提供身份材料以便我司判定其与监护人监护关系；\n\t若疑似账号归属者在15个自然日内不能提供有效身份证明或逾期提供，则默认为疑似账号归属者与被监护人身份相符，我司即按照监护人的申请要求，将其游戏账号纳入防沉迷系统；\n\t若疑似账号归属者在15个自然日内提供的身份证明与被监护人相符，我司即按照监护人的申请要求，将其游戏账号纳入防沉迷系统；\n\t若疑似账号归属者在15个自然日内提供的身份证明与被监护人不符，我司则无法判定其与被监护人的身份关系，在此情况下，为保障用户游戏账号安全，我司将通知监护人通过公安机关出具账号找回协查证明，由我司协助被监护人找回游戏账号后再进行后续操作。"
	str[4] ="五、其他要求：\n\t1、申请人应提交完备的申请材料，并及时补充我司审核所需信息；建议申请人请熟知电脑、互联网、游戏等操作的人员协助，以便提供符合要求的资料；\n\t2、申请人应保证所提交的信息及材料真实有效；对于提供虚假信息或伪造证件、伪造监护关系证明书者，我司将保留追究其法律责任的权利。\n（二）备注：\n\t若监护人的家长监护申请获得通过，则我司会每周定期发送被监护账号的账户信息与游戏历程至申请人的申请邮箱。"

	return str
end
function MoreMainLayer:showAntiAddiction()
	local str = {}
	str[1] ="Q:什么是防沉迷系统？\nA :防沉迷系统，是根据政府《网络游戏防沉迷系统开发标准》及其相关要求开发实施，自2007年7月16日起已正式实施。旨在解决未成年人沉迷网络游戏的现状，让未成年人无法依赖长时间的在线来获得游戏内个人能力的增长，报偿值的增加，有效控制未成年人使用者的在线时间，改变不利于未成年人身心健康的不良游戏习惯。"
	str[2] ="Q:防沉迷系统设计目的？\nA :防止未成年人过度游戏，倡导健康游戏习惯，保护未成年人的合法权益；帮助法定监护人了解其监护对象是否参与此网络游戏、是否受到防沉迷系统的保护等情 况；在实现上述目的的同时，兼顾成年玩家自主支配其游戏时间的合法权益。"
	str[3] ="Q:实名认证系统与防沉迷系统的关系是怎样？\nA :实名认证系统用于收集玩家的身份证号及姓名，并以此作为判断玩家是否需要受到防沉 迷系统保护的重要依据。\n\t实名信息显示为不满18周岁的用户，将被初步判定为未成年人，纳入防沉迷状态。其实名信息于成年后用户自行至实名认证提交至公安机关进行验证。\n\t实名信息显示为已满18周岁的用户，将被初步判定为成年人。其实名信息在等待公安部门验证前将被处于非防沉迷状态，如果通过公安部门的实名验证，则正式进入非防沉迷状态。如失败，则被纳入防沉迷状态。在注册后任何时间用户都可自行至实名认证提交实名信息至公安机关进行验证。\n\t实名信息验证成功的帐号不纳入防沉迷系统。相反，认证失败的帐号将被纳入防沉迷系统。"
	str[4] ="Q:防沉迷系统的具体内容和执行方法？\nA:确定健康游戏时间标准\n\t1. 定义使用者累计3小时以内的游戏时间为“健康”游戏时间。\n\t2. 定义使用者在累计游戏3小时之后，再持续下去的2小时游戏时间为“疲劳”游戏时间。\n\t3. 定义使用者累计游戏时间超过5小时为“不健康”游戏时间。"
	str[5] ="促进使用者养成健康的游戏习惯\n\t为保障使用者适度使用并有足够的休息时间，对游戏的间隔时间和收益进行限制和引导的处理办法：\n\t1. 根据以上考虑，不同累计在线时间的游戏收益处理如下：累计在线时间在3小时以内，游戏收益为正常；3-5小时内，收益降为正常值的50%；5小时以上，收益降为0。\n\t2. 由于不同的游戏有不同范畴，因此对于当前角色扮演类的网络游戏，特别是目前将作为试点的游戏，建议定义为“游戏收益=游戏中获得的经验值＋获得的虚拟物品”。收益为50％，则指获得经验值减半，虚拟物品减半。收益为0,则指无法获得经验值，无法获得虚拟物品。\n\t3. 定义使用者在累计游戏3小时之后，再持续下去的2小时游戏时间为“疲劳”游戏时间。\n\t4. 定义使用者累计游戏时间超过5小时为“不健康”游戏时间。"
	str[6] ="初始化累计时间——由于使用者上下线的行为比较复杂，会出现以下多种情况，因此限时与提示的实现方法如下：\n\t使用者在线后，其持续在线时间将累计计算，称为“累计在线时间”。\n\t使用者下线后，其不在线时间也将累计计算，称为“累计下线时间”。\n\t使用者累计在线时间在3小时以内的，游戏收益正常。每累计在线时间满1小时，应提醒一次：“您累计在线时间已满1小时。”至累计在线时间满3小时时，应提醒：“您累计在线时间已满3小时，请您下线休息，做适当身体活动。"
	str[7] ="如果累计在线时间超过3小时进入第4－5小时，在开始进入时就应做出警示：“您已经进入疲劳游戏时间，您的游戏收益将降为正常值的50％，请您尽快下线休息，做适当身体活动。”此后，应每30分钟警示一次。如果累计在线时间超过5小时进入第6小时，在开始进入时就应做出警示：“您已进入不健康游戏时间，请您立即下线休息。如不下线，您的身体健康将受到损害，您的收益已降为零。”此后，应每15分钟警示一次。受防沉迷系统限制的用户，当下线时间超过5小时时，累计游戏时间初始化为0。初始化后进入游戏就会开始重新计算累计游戏时间。"
	str[8] ="Q:防沉迷系统的执行对象？\nA:未成年用户（未满18岁者）；身份验证信息不完整的用户；未经过身份验证的用户。\nQ:用户在注册和游戏中如果年龄刚好在18岁，系统能够及时转换未成年人和成年人的身份吗？\nA :在未成年人年龄自然增长到成年人后，系统能自动识别并完成身份的转换。"
	str[9] ="Q:我是成年人，还有必要填写实名信息么？\nA:当然需要，所有未登记实名信息的玩家都将默认纳入防沉迷系统的保护范围。\nQ:我的帐号被盗了，能用实名登记的身份证据来找回帐号吗？"
	str[10] ="A :实名信息不做帐号的安全依据和归属判断。实名信息的唯一作用就是确定玩家是否为防沉迷对象。至于人工取回帐号所需要的那个证件号码，是指注册帐号时填写的有效证件号码，而不是实名信息里的身份证号。"
	str[11] ="Q:上线3小时后下线，然后累计3小时后上线可以清除在线时间么？\nA :不会的，按照国家规定，只有累计下线5小时，才会清除一次累计在线时间。也就是说，无论您在线3分钟或是100个小时，只要您累计下线时间达5小时，所有在线累计时间都会清零。"
	return str
end
--[[
	网络回调
]]
function MoreMainLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
    if tag == POST_COMMAND_GET_checkVersion then
    	local nStatus = tableData.status
        if nStatus == 2 then
			self.mBtnCheck:getChildByTag(101):removeFromParent()
        	local btnText = cc.ui.UILabel.new({
			        text  = "已是最新",
			        size  = 26,
			        x     = self.mBtnCheck:getContentSize().width - 140,
			        y     = self.mBtnCheck:getContentSize().height/2,
			        align = cc.ui.TEXT_ALIGN_LEFT,
			        --UILabelType = 1,
	        		font  = "黑体",
			    })
			self.mBtnCheck:addChild(btnText)
        	-- CMShowTip("当前版本已经是最新版本")
        else
        	local btnText = cc.ui.UILabel.new({
			        text  = "有更新",
			        color = cc.c3b(255,0,0),
			        size  = 26,
			        x     = self.mBtnCheck:getContentSize().width - 240,
			        y     = self.mBtnCheck:getContentSize().height/2,
			        align = cc.ui.TEXT_ALIGN_LEFT,
			        --UILabelType = 1,
	        		font  = "黑体",
			    })
			self.mBtnCheck:addChild(btnText)

        	self.mBtnCheck:getChildByTag(101):setVisible(true)
        end
        if GIOSCHECK then
    		self.mBtnCheck:setVisible(false)
    	end
    end
end
return MoreMainLayer