--
-- Author: junjie
-- Date: 2016-04-29 17:32:40
--
local FightCommonLayer = class("FightCommonLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
FightCommonLayer.ShowNone= 0    --不显示按钮
FightCommonLayer.ShowOk  = 1	 --确定	
FightCommonLayer.ShowAll = 2    --确定，取消
local EnumMenu = 
{	
	eClose = 1,
	eOK    = 2,
	eBox   = 3,
}
function FightCommonLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}
	self.mAtivityName = self.params.mAtivityName or {
		-- "金币","月卡","道具",
	}
	self.mActivitySprite = {}
	self.mAllSelectNode =  {}
	self.params.size    = self.params.size or cc.size(668,398)	
	self.params.showType = self.params.showType or self.ShowOk 	
	self.params.cancelText = self.params.cancelText or "取消"
	self.params.okText = self.params.okText or "确认"
	self.params.titleText = self.params.titleText or "温馨提示"
	self.params.showClose = self.params.showClose or 1
	self.params.isOkClose   = self.params.isOkClose or 1
	self.params.showLine  = self.params.showLine or 1
	self.params.cancelPath = self.params.cancelPath or "picdata/public2/w_btn_qx.png"
	self.params.okPath = self.params.okPath or "picdata/public2/w_btn_qd.png"
end
--[[
	UI创建
]]
function FightCommonLayer:create()
	self:initUI()
    self:createLeftUI()
    if self.params.selectIdx then
   	 	self:onSelectBtn(self.params.selectIdx)
   	end
end
--[[
	一级提示框
]]
function FightCommonLayer:initUI()
	local size = self.params.size
	self.mBg = display.newScale9Sprite("picdata/fightteam/teambg.png", 0, 0, size)
	self.mBg:pos(display.cx, display.cy)
	self:addChild(self.mBg)
	self.mBgWidth = self.mBg:getContentSize().width
	self.mBgHeight= self.mBg:getContentSize().height
	if self.params.titlePath then
		local index = string.find(self.params.titlePath,".png")
		if index then
			local titleBg = cc.Sprite:create("picdata/fightteam/bg_t.png")
			titleBg:setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height - 50 + (self.params.titleOffY or 0))
			self.mBg:addChild(titleBg)

			local title = cc.Sprite:create(self.params.titlePath)
			title:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+10)
			titleBg:addChild(title)
		else
			local title = cc.ui.UILabel.new({
		        color = cc.c3b(0, 255, 255),
		        text  = self.params.titlePath,
		        size  = 36,
		        font  = "FZZCHJW--GB1-0",
		       -- UILabelType = 1,
		    })
		    title:setPosition(size.width/2-title:getContentSize().width/2,size.height - 40)
			self.mBg:addChild(title)
		end
	end
	if self.params.showClose  == 1 then
		local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () self:menuCallBack(EnumMenu.eClose) end, {scale9 = false})    
	    :align(display.CENTER, size.width/2-430,self.mBg:getContentSize().height-50) --设置位置 锚点位置和坐标x,y
	    :addTo(self.mBg,2)
	end
    
end
--[[
	二级提示框，较小
]]
function FightCommonLayer:initSecondUI()
	local size = self.params.size 
	self.mBg = display.newScale9Sprite("picdata/public/bg_2_tc_l.png", 0, 0, size)
	self.mBg:setPosition(display.cx,display.cy)
	self:addChild(self.mBg)
	self.mBgWidth = self.mBg:getContentSize().width
	self.mBgHeight= self.mBg:getContentSize().height

	if self.params.showClose  == 1 then
		local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () self:menuCallBack(EnumMenu.eClose) end)
		btnClose:setPosition(self.mBgWidth-20,self.mBgHeight - 20)
		self.mBg:addChild(btnClose,1)
	end

	if self.params.titlePath then
		local index = string.find(self.params.titlePath,".png")
		if index then
			local title = cc.Sprite:create(self.params.titlePath)
			title:setPosition(self.mBgWidth/2,self.mBgHeight-50)
			self.mBg:addChild(title)
		else
			local title = cc.ui.UILabel.new({
		        color = cc.c3b(0, 255, 255),
		        text  = self.params.titlePath,
		        size  = 36,
		        font  = "FZZCHJW--GB1-0",
		       -- UILabelType = 1,
		    })
		    title:setPosition(size.width/2-title:getContentSize().width/2,size.height - 40)
			self.mBg:addChild(title)
		end
	end
	if self.params.showLine  == 1 then
		local line = cc.Sprite:create("picdata/friend/line.png")
		line:setScaleX(3.15)
		line:setPosition(self.mBgWidth/2,110)
		self.mBg:addChild(line)
	end

    if self.params.showType == self.ShowNone then
	elseif self.params.showType == self.ShowOk  then
		local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
			function () self:menuCallBack(EnumMenu.eOK) end,nil,{textPath = self.params.okPath})
		-- btnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	 --    --UILabelType = 1,
	 --    color = cc.c3b(156, 255, 0),
	 --    text = self.params.okText,
	 --    size = 32,
	 --    font = "FZZCHJW--GB1-0",
		-- }) )    
		btnOk:setPosition(self.mBgWidth/2,60)
		self.mBg:addChild(btnOk,1)
	else
		local btnOk = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
			function () self:menuCallBack(EnumMenu.eOK) end,nil,{textPath = self.params.okPath})
		-- btnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	 --    --UILabelType = 1,
	 --    color = cc.c3b(156, 255, 0),
	 --    text = self.params.okText,
	 --    size = 32,
	 --    font = "FZZCHJW--GB1-0",
		-- }) )    
		btnOk:setPosition(self.mBgWidth/2+140,60)
		self.mBg:addChild(btnOk,1)

		local btnCancel = CMButton.new({normal = "picdata/public2/btn_h74_blue.png",pressed = "picdata/public2/btn_h74_blue2.png"},
			function () self:menuCallBack(EnumMenu.eClose) end,nil,{textPath = self.params.cancelPath})
		-- btnCancel:setButtonLabel("normal",cc.ui.UILabel.new({
	 --    --UILabelType = 1,
	 --    color = cc.c3b(161, 184, 229),
	 --    text = self.params.cancelText,
	 --    size = 32,
	 --    font = "FZZCHJW--GB1-0",
		-- }) )    
		btnCancel:setPosition(self.mBgWidth/2 - 140,60)
		self.mBg:addChild(btnCancel,1)

	end
end
function FightCommonLayer:menuCallBack(_tag)
	local isCloseSelf = 1
	if _tag == EnumMenu.eOK then
		if self.params.callOk then 
			self.params.callOk(self.mIsSelectBox)
		end		
		isCloseSelf = self.params.isOkClose		
	elseif _tag == EnumMenu.eClose then			
		if self.params.callCancle then 
			self.params.callCancle(self.mIsSelectBox)			
		end	
	end
	if self and isCloseSelf == 1 then
		CMClose(self)
	end
end
function FightCommonLayer:onMenuClose(sender, event)
	CMClose(self)
end
return FightCommonLayer