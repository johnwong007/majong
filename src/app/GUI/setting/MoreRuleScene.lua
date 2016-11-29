--
-- Author: junjie
-- Date: 2015-11-18 14:41:47
--
local MoreRuleScene = class("MoreRuleScene", function()
	--return display.newScene()
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local CMButton = require("app.Component.CMButton")
local MoreRuleScenePath = require("app.GUI.allrespath.MoreRuleScenePath")
local mMaxScrollPage = 5
--[[
	成员变量说明：
	self._dotNor ：圆点

]]
function MoreRuleScene:ctor()
	self:setNodeEventEnabled(true) 	
end
function MoreRuleScene:create()
	self:initUI()
end
function MoreRuleScene:initUI()
	dump("=======>")
	self.mLayer = display.newColorLayer(cc.c4b( 0,0,0,125))
	self:addChild(self.mLayer)
	local scrollBg = cc.Sprite:create(MoreRuleScenePath.Helper.ruleBg)
	CMDealAdapter(scrollBg)
	self.mLayer:addChild(scrollBg)

	local dot = self:createDot(1,5)
	dot:setPosition(display.cx-dot:getContentSize().width/2,50)
	self.mLayer:addChild(dot)

	local btnHelp = CMButton.new({normal = MoreRuleScenePath.Helper.gameHelpBtn,pressed = MoreRuleScenePath.Helper.gameHelpBtn,},function () CMClose(self) end, {scale9 = false})    
    :align(display.LEFT, 150,display.height - 50) --设置位置 锚点位置和坐标x,y
    :addTo(self.mLayer)
	self:createPageView()
	CMDelay(self,0.05,function () self:onMenuTest() end)
	-- self:testCMChatButton()
	-- self:testGetMemory()

end
function MoreRuleScene:testGetMemory()
	-- if true then 
	-- 	self:readFile("Resource")
	-- 	return 
	-- end
	--"table,LoginView"
	local directory = "MainPage"
	local fileName  = "MainPagePath"
-- 	local directory = {
-- 	{path = "activity",outPath = "ActivityPath"},{path = "gamescene",outPath = "GameScenePath"},{path = "db_gold",outPath = "GoldPath"},
-- 	{path = "hall",outPath = "HallPath"},{path = "login",outPath = "LoginViewPath"},{path = "MainPage",outPath = "MainPagePath"},
-- 	{path = "personalCenter",outPath = "PersonalCenterPath"},{path = "db_poker",outPath = "LoginViewPath"},{path = "MainPage",outPath = "MainPagePath"},
-- }
	local removeRoot = ""
	local memoryPath = CMGetDirectoryAndFile(device.writablePath.."res/picdata/"..directory)
	-- dump(memoryPath)
	self:writeFile(fileName,memoryPath,"picdata/"..directory)
	for i,v in pairs(memoryPath) do
		-- display.removeSpriteFrameByImageName(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function MoreRuleScene:length_of_file(filename)
	  local fh = assert(io.open(filename, "rb"))
	  local len = assert(fh:seek("end"))
	  fh:close()
	  -- dump(len)
	  return len
end
function MoreRuleScene:writeFile(fileName,memoryPath,directory)
	local filePath = string.format(device.writablePath.."src/app/GUI/allrespath/%s.lua",fileName)
	-- dump(filePath)
	local f = assert(io.open(filePath,'w'))
	 -- f:write(content)
	 f:write("local "..fileName .. " = {}\n")
	 f:write("-- 目录:"..directory.."\n\n")
	 local name = ""
	 local nBeginPos,nEndPos 
	 local valueKey = ""
	 local spc = ""
	 local lens = 0 
	 for i,v in pairs(memoryPath) do
	 	 lens = math.round(self:length_of_file(v)/1000)
	 	 -- lens = math.floor(self:length_of_file(v)/1000)
	 	 v = string.gsub(v,device.writablePath.."res/","")
	 	 nBeginPos,nEndPos = string.find(v,".+/")
		 if nEndPos then 	
		 	name = string.sub(v,nEndPos+1,#v)
		 	name = string.gsub(name,".png","")
		 	name = string.upper(name)
		 	-- dump(name)
		 	spc = string.rep(" ", 40 - string.len(string.format("%s[\"%s\"]",fileName,name)))
		 	valueKey = string.format("%s[\"%s\"]%s= \"%s\"",fileName,name,spc,v)
		 	print(valueKey)
		 	valueKey = valueKey ..string.rep(" ",50 - string.len(string.format("%s[\"%s\"]",fileName,name)))..string.format("--%sKB",lens)
	 		f:write(valueKey.."\n")
		 end
	
	 end
	 f:write("\n".."return "..fileName)
	 f:close()
	 
end
function MoreRuleScene:readFile(fileName)
	local filePath = string.format(device.writablePath.."src/app/GUI/allrespath/%s.lua",fileName)
	-- dump(filePath)
	local f = assert(io.open(filePath,'r'))
	local totalSize = 0
	for line in f:lines() do 
		line = string.gsub(line,".+%-%-","")
		line = string.gsub(line,"KB","")
		-- if string.len(line) > 0 then			
		-- 	table.insert(sizeTable,line)
		-- end
		-- dump(sizeTable)
		if tonumber(line) then
			totalSize = totalSize + tonumber(line)
		end
		-- print(line)
	end

	f:close()
	print(totalSize/1000)
end
local btnHelp
function MoreRuleScene:testCMChatButton()
	local CMChatButton = require("app.Component.CMChatButton")
    btnHelp = CMChatButton.new({normal = MoreRuleScenePath.Helper.gameHelpBtn},
    {
    	callBegin 	= function ()  self:onMenuCallBack(1) end,
    	callMoveIn 	= function ()  self:onMenuCallBack(2) end,
    	callMoveOut = function ()  self:onMenuCallBack(3) end,
    	callEndIn  	= function ()  self:onMenuCallBack(4) end,
    	callEndOut 	= function ()  self:onMenuCallBack(5) end,})    
    :align(display.LEFT, display.cx,display.height/2) --设置位置 锚点位置和坐标x,y
    :addTo(self.mLayer)
    btnHelp:setTexture(MoreRuleScenePath.Helper.gameHelpBtn,true)
    btnHelp:setButtonEnabled(false)
    btnHelp:setTexture(MoreRuleScenePath.Helper.gameHelpBtn)
end

function MoreRuleScene:onMenuCallBack(tag)

	if tag == 1 then
		-- start record
	elseif tag == 2 then 

	elseif tag == 3 then
		-- print(btnHelp:getTouchTime())
	elseif tag == 4 then
		-- print(btnHelp:getTouchTime())
		-- local time 
	elseif tag == 5 then
		-- print(btnHelp:getTouchTime())
		-- 结束
	end
end
function MoreRuleScene:onEnter()

end 
function MoreRuleScene:onEnterTransitionFinish()
	
	
end

function MoreRuleScene:onExit()
	--print("退出MoreRuleScene")
	for i,v in pairs(MoreRuleScenePath.Helper) do
		display.removeSpriteFrameByImageName(v)
	end
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function MoreRuleScene:start()
	--self:init()
end

function MoreRuleScene:onMenuTest()
	if device.platform == "ios" or device.platform == "android" then return end
	--QManagerPlatform:openQQLogin()
	--QManagerPlatform:getUniqueStr()
	-- QManagerPlatform:setAccountInfo()
	-- QManagerPlatform:onChargeRequst()
	-- QManagerPlatform:onChargeSuccess()
	--CMClose(self)
	--QManagerPlatform:showPickHeadImage()
	--local data       = {title = "我在#德堡扑克#的一场精彩牌局",content = "我在#德堡扑克#中录制的一场精彩牌局,小伙伴们快来围观~~~",nType = 1,url = "http://debao.boss.com/index.php?act=video&mod=getmobilevideo&fid="..544}
	--QManagerPlatform:shareToWeChat(data)
	--QManagerPlatform:jumpToUpdate(data)
	-- display.captureScreen(
	--     function (bSuc, filePath)
	--     	if bSuc then 
	--     		print("save")
	--     	end
	--         --bSuc 截屏是否成功
	--         --filePath 文件保存所在的绝对路径
	--     end, device.writablePath.."/res/screen.png")
	-- local LoadingScene = require("app.GUI.LoadingScene")
	-- local scene = display.newScene()
 --    display.replaceScene(scene)
    --local RewardLayer = require("app.GUI.reward.RewardLayer"):new(0)
    --local RewardLayer = require("app.GUI.roomView.TaskListLayer"):new()
    -- local RewardLayer = require("app.GUI.recharge.ExchargeLayer"):new()
    -- local RewardLayer = require("app.GUI.recharge.ShopGoldLayer"):new()
    -- local spc1 = string.rep(" ", 96)
    -- local spc2 = string.rep(" ", 82)
    -- 	  strArr = string.format("[fontColor=fefefe fontSize=28]1、玩家在[/fontColor][fontColor=00ffff fontSize=28]中高级场玩牌[/fontColor][fontColor=fefefe fontSize=28],每局将获得数量不登的积分,[/fontColor][fontColor=00ffff fontSize=28]盲注级别越高,获得积分越多[/fontColor][fontColor=fefefe fontSize=28]。[/fontColor][fontColor=fefefe fontSize=28]%s[/fontColor][fontColor=00ffff fontSize=28]2、VIP[/fontColor][fontColor=fefefe fontSize=28]玩家可获得相应等级的[/fontColor][fontColor=00ffff fontSize=28]积分返还加成[/fontColor][fontColor=fefefe fontSize=28]。%s3、积分可在商城[/fontColor][fontColor=00ffff fontSize=28]兑换各种奖品[/fontColor][fontColor=fefefe fontSize=28]。[/fontColor]",spc1,spc2)

    -- local RewardLayer = require("app.Component.CMAlertDialog").new({titleText = "积分说明",text = "",showType = 1,titleIcon = "picdata/shop/rakepointIcon.png",okText = "立即提升VIP",colorText = strArr})
    -- --local RewardLayer = require("app.GUI.recharge.ShopChannelLayer"):new()
   -- local RewardLayer = require("app.GUI.friends.FriendShowLayer"):new()
    --local RewardLayer = require("app.GUI.ranking.RankLayer"):new()
    -- local RewardLayer = require("app.GUI.notice.NoticeLayer").new({nType = 5})
    -- local RewardLayer = require("app.Component.CMToolTipView").new({text = "兑换成功"})
    --local RewardLayer = require("app.GUI.friends.FriendLayer"):new()
    -- local RewardLayer = require("app.GUI.friends.FriendMsgLayer"):new()
    -- local RewardLayer = require("app.GUI.setting.MoreVersionLayer"):new()
    --local RewardLayer = require("app.GUI.newactivity.ActivityLayer"):new()
    --local RewardLayer = require("app.GUI.personCenter.PersonCenterLayer"):new()
    --local RewardLayer = require("app.GUI.personCenter.HeadEditLayer"):new()
    -- local RewardLayer = require("app.GUI.personCenter.MyPacketLayer"):new()
    -- local RewardLayer = require("app.GUI.personCenter.MyMatchLayer"):new({})
    --local RewardLayer = require("app.GUI.personCenter.DataExplainLayer"):new()
    --local RewardLayer = require("app.GUI.personCenter.AccountEditLayer"):new()
    -- local RewardLayer = require("app.GUI.personCenter.MyBoardLayer"):new()
    -- local RewardLayer = require("app.GUI.setting.PasswordSetting"):new()
    -- local RewardLayer = require("app.GUI.setting.MobileBlind"):new()
    -- local RewardLayer = require("app.GUI.setting.EmailBlind"):new()
    -- local RewardLayer = require("app.GUI.setting.EsunBind"):new()
    -- local RewardLayer = require("app.GUI.login.DebaoRegister"):new()
     --local RewardLayer = require("app.GUI.login.Login500wan"):new()
    -- local RewardLayer = require("app.GUI.setting.MoreMainLayer"):new()
    --local RewardLayer = require("app.GUI.recharge.ShopMobileCardLayer"):new()

    -- local RewardLayer = require("app.Component.CMCommonLayer").new({bgType = 3})
    --local RewardLayer = require("app.GUI.notice.AnnounceLayer"):new()
    -- local RewardLayer = require("app.GUI.login.DebaoRegister").new({nType = 1})
    --local RewardLayer = require("app.GUI.login.MobileVerify").new({nType = 1})
    -- local RewardLayer = require("app.GUI.login.ForgetPasswordLayer"):new()
    -- local RewardLayer = require("app.GUI.login.DebaoUniqueUser"):new()
    -- local RewardLayer      = require("app.Component.CMNoticeView").new()	
    -- local RewardLayer = require("app.GUI.newactivity.RechargeAwardLayer"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.FightDemo").new()	
    -- local RewardLayer      = require("app.GUI.fightTeam.FTManager"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.allTeam.FTAllTeamLayer"):new()

   	-- local RewardLayer      = require("app.GUI.fightTeam.allTeam.FTCreateTeamLayer"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTMyTeamLayer"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTFirstPageNode"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTMemberListNode"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTChatNode"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTRewardLayer"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTAppointLayer"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTApplyLayer"):new()
    -- local RewardLayer      = require("app.GUI.fightTeam.myTeam.FTEditNoticeLayer"):new()
    -- local RewardLayer = require("app.GUI.login.LoadingMemoryLayer"):new()
    -- CMOpen(RewardLayer,self,{awardData,isEnter = true}) 	
    -- local RewardLayer      = require("app.GUI.recharge.DebaoZuanLayer"):new()
    -- local RewardLayer      = require("app.GUI.recharge.DebaoZuanRecordLayer"):new()
    -- local RewardLayer      = require("app.GUI.recharge.DebaoZuanGiveLayer"):new()
    local RewardLayer      = require("app.GUI.roomView.TrusteeshipProtectCountDown").new({timeStamp = 30,callback=handler(self,self.testCallback)})
    -- local RewardLayer      = require("app.GUI.login..ChoiceGameLayer"):new()
    RewardLayer:create()
   self:addChild(RewardLayer)
   self.testLayer = RewardLayer
    --cc.Director:getInstance():getRunningScene():addChild(RewardLayer,100)

    -- local RewardLayer = require("app.GUI.reward.RewardLayer"):new(1)
    -- RewardLayer:setPosition(display.cx,display.cy)
    --CMOpen(RewardLayer,self)
    --require("app.Component.CMHandleDirectory")
    --local ret = CMGetFileByLastName(device.writablePath.."res",".xml",true)
    --dump(ret)
end
--创建TableView
function MoreRuleScene:createPageView()
	local scrollBg = cc.Sprite:create(string.format(MoreRuleScenePath.Helper.rule,1))
	scrollBg:setPosition(display.cx,display.cy)	
	
	local width = scrollBg:getContentSize().width
	local height = scrollBg:getContentSize().height
	local x = display.cx - width/2
	local y = display.cy - height/2-40

    self.mPageview = cc.ui.UIPageView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        viewRect = cc.rect(x, y, width, height),
        column = 1, row = 1,
        padding = {left = 0, right = 0, top = 0, bottom = 0},
        columnSpace = 0, rowSpace = 0}
        :onTouch(handler(self, self.touchListener))        
        :addTo(self.mLayer)    
    
   	self:createPageItem()
    self.mPageview:reload()
end
--[[
	scrollview内容
]]
function MoreRuleScene:createPageItem()	

	for i = 1,mMaxScrollPage do 
		local item = self.mPageview:newItem()
		self.mPageview:addItem(item)  
		local sp = cc.Sprite:create(string.format(MoreRuleScenePath.Helper.rule,i))
		sp:setPosition(sp:getContentSize().width/2,sp:getContentSize().height/2)
		item:addChild(sp)

	end
end
function MoreRuleScene:testCallback(event)
	if self.testLayer then
		self.testLayer:removeFromParent(true)
		self.testLayer = nil
	end
end
function MoreRuleScene:touchListener(event)
    --dump(event)     
    --local listView = event.listView
    if 1 > event.pageIdx then    	
   		self.mPageview:gotoPage(1)    	
    elseif mMaxScrollPage < event.pageIdx then    	  	
   		self.mPageview:gotoPage(mMaxScrollPage)
    end
    self._dotNor:setPositionX((self.mPageview:getCurPageIdx()-1)*20)

    dump("========MoreRuleScene:touchListener========")
    if not self.testLayer then
	    local RewardLayer      = require("app.GUI.roomView.TrusteeshipProtectCountDown").new({timeStamp = 1,callback=handler(self,self.testCallback)})
	    -- local RewardLayer      = require("app.GUI.login..ChoiceGameLayer"):new()
	    RewardLayer:create()
	   self:addChild(RewardLayer)
	   self.testLayer = RewardLayer
	end
end
function MoreRuleScene:createDot(_curNum,_totalNum)
	local node = cc.Node:create()

	local posx = 0
	local posy = 0

	for i = 1,_totalNum do		
		local dot_pre = cc.Sprite:create(MoreRuleScenePath.Helper.listPointGray)
		dot_pre:setPosition(cc.p(posx,posy))
		posx = posx + 20
		node:addChild(dot_pre)
	end

	self._dotNor = cc.Sprite:create(MoreRuleScenePath.Helper.listPoint)
	self._dotNor:setPosition(cc.p(0,posy))
	node:addChild(self._dotNor)

	node:setContentSize(cc.size(self._dotNor:getContentSize().width*_totalNum,self._dotNor:getContentSize().height))
	return node
end


return MoreRuleScene