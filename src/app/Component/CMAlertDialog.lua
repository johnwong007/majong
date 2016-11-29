--
-- Author: junjie
-- Date: 2015-11-27 10:22:38
--
local CMAlertDialog = class("CMAlertDialog",function() 
	return display.newColorLayer(cc.c4b(0,0,0,125))
end)
local CMColorLabel     = require("app.Component.CMColorLabel")
CMAlertDialog.ShowNone= 0    --不显示按钮
CMAlertDialog.ShowOk  = 1	 --确定	
CMAlertDialog.ShowAll = 2    --确定，取消
CMAlertDialog.ShowAllSpecial = 3    --确定，取消

--titleText  : 文本标题
--text  	 : 文本内容
--scroll 	 : 是否滑动
--showType   : 按钮显示类型
--cancelText : 取消文本
--okText	 : 确认文本
--type(self.params.text) == "table" ：异步加载数据
--titleIcon  : 标题图片
--colorText  : 多颜色文本内容
--showClose  : 是否显示关闭按钮
--autoClose  : 是否点击任何按钮后自动关闭弹窗，默认true
local EnumMenu = 
{	
	eClose = 1,
	eOK    = 2,
	eBox   = 3,
}
function CMAlertDialog:ctor(params)
	self:setNodeEventEnabled(true)
	self.params = params or {}	
	self.params.showType = self.params.showType or self.ShowOk 	
	self.params.cancelText = self.params.cancelText or "取消"
	self.params.okText = self.params.okText or "确认"
	self.params.titleText = self.params.titleText or "温馨提示"
	self.params.showBox   = self.params.showBox
	self.params.scroll    = self.params.scroll
	self.params.showClose = self.params.showClose or 1
	self.params.showLine  = self.params.showLine or 1
	self.mIsSelectBox     = 0
	--self:initUI()
end
--[[
	UI创建
]]
function CMAlertDialog:create()
	self:initUI()
end
function CMAlertDialog:initUI() 	

 	-- local bg = cc.Sprite:create("picdata/public/alertBG.png")
 	-- bgWidth = bg:getContentSize().width
 	-- bgHeight= bg:getContentSize().height
 	-- self.mSize = cc.size(bgWidth - 100,bgHeight-100)
 	-- bg:setPosition(display.cx,display.cy)
 	-- self:addChild(bg)

 	bgWidth = 652
 	bgHeight= 348
	local bg = cc.ui.UIImage.new("picdata/public_new/bg_tc_tips.png",{scale9=true})
 	bg:setLayoutSize(652, 348)
	bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
		:addTo(self)
 	self.mSize = cc.size(bgWidth - 100,bgHeight-100)

 	self:addCheckBoxIf(bg)

 	local title = cc.ui.UILabel.new({
        color = cc.c3b(0, 255, 225),
        text  = self.params.titleText,
        size  = 36,
        font  = "FZZCHJW--GB1-0",
       -- UILabelType = 1,
    })
    title:setPosition(bgWidth/2-title:getContentSize().width/2,bgHeight - 46)
	bg:addChild(title)
	if self.params.titleIcon then
		local titleIcon = cc.Sprite:create(self.params.titleIcon) --"picdata/shop/rakepointIcon.png"
		titleIcon:setPosition(title:getPositionX() -titleIcon:getContentSize().width/2 - 15 , title:getPositionY())
		bg:addChild(titleIcon)
	end
	if self.params.showClose  == 1 then
		local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () self:menuCallBack(EnumMenu.eClose) end)
		btnClose:setPosition(bgWidth-20,bgHeight - 20)
		bg:addChild(btnClose,1)
		btnClose:setVisible(false)
	end

	if self.params.showLine  == 1 then
		local line = cc.Sprite:create("picdata/friend/line.png")
		line:setScaleX(3.15)
		line:setPosition(bgWidth/2,110)
		bg:addChild(line)
		line:setVisible(false)
	end
	
	local fontSize = 28
	local fontName = "黑体"
	--self.params.text = "题内通关可获题内通关可获得题内通\n满星评\n满星题内通\n题内通\n题内通\n评得满星评价满星评价评价关通关可获得题内通满星评价满星评价"
	--self.params.text = self.params.text or ""	
	-- local sTip = cc.ui.UILabel.new({text = self.params.text,font = fontName,size = 30,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(self.mSize.width - 56,0)})
	-- local nWidth = sTip:getContentSize().width
	if self.params.showType == self.ShowNone then
	elseif self.params.showType == self.ShowOk  then
		self.mBtnOk = CMButton.new({normal = "picdata/public/confirmBtn.png",pressed = "picdata/public/confirmBtn2.png"},function () self:menuCallBack(EnumMenu.eOK) end)
		self.mBtnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(177, 255, 51),
	    text = self.params.okText,
	    size = 32,
	    font = "FZZCHJW--GB1-0",
		}) )    
		self.mBtnOk:setPosition(bgWidth/2,60)
		bg:addChild(self.mBtnOk,1)
	elseif self.params.showType == CMAlertDialog.ShowAll then
		-- self.mBtnOk = CMButton.new({normal = "picdata/public/confirmBtn.png",pressed = "picdata/public/confirmBtn2.png"},function () self:menuCallBack(EnumMenu.eOK) end)
		
		self.mBtnOk = CMButton.new({normal = "picdata/public_new/btn_tc_tips_green.png",pressed = "picdata/public_new/btn_tc_tips_green_p.png"},
				function () self:menuCallBack(EnumMenu.eOK) end,{scale9 = true})
		self.mBtnOk:setButtonSize(312, 100)

		self.mBtnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(177, 255, 51),
	    text = self.params.okText,
	    size = 32,
	    font = "FZZCHJW--GB1-0",
		}) )    
		self.mBtnOk:setPosition(bgWidth/2+156,60)
		bg:addChild(self.mBtnOk,1)

		-- local btnCancel = CMButton.new({normal = "picdata/public/cancelBtn.png",pressed = "picdata/public/cancelBtn2.png"},function () self:menuCallBack(EnumMenu.eClose) end)
		
		local btnCancel = CMButton.new({normal = "picdata/public_new/btn_tc_tips_blue.png",pressed = "picdata/public_new/btn_tc_tips_blue_p.png"},
				function () self:menuCallBack(EnumMenu.eClose) end,{scale9 = true})
		btnCancel:setButtonSize(312, 100)

		btnCancel:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(161, 184, 229),
	    text = self.params.cancelText,
	    size = 32,
	    font = "FZZCHJW--GB1-0",
		}) )    
		btnCancel:setPosition(bgWidth/2 - 156,60)
		bg:addChild(btnCancel,1)
	else
		-- self.mBtnOk = CMButton.new({normal = "picdata/public/confirmBtn.png",pressed = "picdata/public/confirmBtn2.png"},function () self:menuCallBack(EnumMenu.eOK) end)
		
		self.mBtnOk = CMButton.new({normal = "picdata/public_new/btn_tc_tips_red.png",pressed = "picdata/public_new/btn_tc_tips_red_p.png"},
				function () self:menuCallBack(EnumMenu.eOK) end,{scale9 = true})
		self.mBtnOk:setButtonSize(312, 100)

		self.mBtnOk:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 255),
	    text = self.params.okText,
	    size = 40,
	    font = "FZZCHJW--GB1-0",
		}) )    
		self.mBtnOk:setPosition(bgWidth/2+156,60)
		bg:addChild(self.mBtnOk,1)

		-- local btnCancel = CMButton.new({normal = "picdata/public/cancelBtn.png",pressed = "picdata/public/cancelBtn2.png"},function () self:menuCallBack(EnumMenu.eClose) end)
		
		local btnCancel = CMButton.new({normal = "picdata/public_new/btn_tc_tips_blue.png",pressed = "picdata/public_new/btn_tc_tips_blue_p.png"},
				function () self:menuCallBack(EnumMenu.eClose) end,{scale9 = true})
		btnCancel:setButtonSize(312, 100)

		btnCancel:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(205, 219, 254),
	    text = self.params.cancelText,
	    size = 40,
	    font = "FZZCHJW--GB1-0",
		}) )    
		btnCancel:setPosition(bgWidth/2 - 156,60)
		bg:addChild(btnCancel,1)
	end

	if not self.params.scroll then
		local index = string.find(self.params.text,"#%d")
		local sTip
		if index then
			sTip = CMColorLabel.new({text = self.params.text,size = fontSize ,dimensions = cc.size(bgWidth - 100, 0)})
			sTip:setPosition(50,245)			
		else
			if string.len(self.params.text)< 36 then
				sTip = cc.ui.UILabel.new({
					text = self.params.text or "",
					color = cc.c3b(255,255,255),
					size = 28,
					-- dimensions = cc.size(bgWidth - 160, 0),
					})
				sTip:align(display.CENTER, bgWidth/2, 180 - sTip:getContentSize().height/2+20)
			else
				sTip = cc.ui.UILabel.new({
					text = self.params.text or "",
					color = cc.c3b(255,255,255),
					size = 28,
					textAlign = cc.TEXT_ALIGNMENT_LEFT,
					-- align = cc.TEXT_ALIGNMENT_CENTER,
					dimensions = cc.size(bgWidth - 160, 0)})	
				sTip:align(display.CENTER,bgWidth/2,155+32)
			end
			-- if string.len(self.params.text)< 36 then
			-- 	sTip = cc.ui.UILabel.new({text = self.params.text or "",color = cc.c3b(255,255,255),size = fontSize,textAlign = cc.TEXT_ALIGNMENT_CENTER,dimensions = cc.size(bgWidth - 80, 0)})	
			-- 	--sTip = cc.LabelTTF:create(self.params.text or "","黑体",fontSize,cc.size(bgWidth - 80, 0),cc.TEXT_ALIGNMENT_LEFT)
			-- 	sTip:align(display.CENTER,bgWidth/2,270 - sTip:getContentSize().height/2)
			-- else
			-- 	sTip = cc.ui.UILabel.new({text = self.params.text or "",color = cc.c3b(255,255,255),size = fontSize,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(bgWidth - 80, 0)})	
			-- 	--sTip = cc.LabelTTF:create(self.params.text or "","黑体",fontSize,cc.size(bgWidth - 80, 0),cc.TEXT_ALIGNMENT_LEFT)
			-- 	sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2+10,270 - sTip:getContentSize().height/2)
			-- end
		end
		bg:addChild(sTip,0)
	else
		if type(self.params.text) == "table"  then
		    local bound = {x = 40, y = 40, width = bgWidth- 80, height = 230} 
			self.mList  = cc.ui.UIListView.new {
	    	--bgColor = cc.c4b(200, 200, 200, 120),
	    	viewRect = cc.rect(bound.x,bound.y,bound.width,bound.height),    	
	    	async   = true,
	    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
	    	:onTouch(handler(self, self.touchListener))
	   		:addTo(bg)   

			self.mList:setDelegate(handler(self, self.sourceDelegate))
			self.mList:reload()	
		else
			local bound = {x = 40, y = 95, width = bgWidth- 80, height = 175} 
			if self.params.showType == 0 then
				bound.height = 230
				bound.y      = 45
			end
				
		     local node = cc.Node:create()
			 node:setContentSize(bound.width,bound.height)

			local sTip = cc.ui.UILabel.new({text = self.params.text,color = cc.c3b(255,255,255),size = 24,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(bgWidth - 80, 0)})	
			sTip:setPosition(bound.x,bound.y+bound.height/2-10)
			node:addChild(sTip)
			local item = cc.ui.UIScrollView.new({
			    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
			    viewRect = bound, 
			   -- scrollbarImgH = "scroll/barH.png",
			   -- scrollbarImgV = "scroll/bar.png",
			   --bgColor = cc.c4b(125,125,125,125)
			})
		    :addScrollNode(node)
		    --:onScroll(function (event)
		       -- print("ScrollListener:" .. event.name)
		    --end) --注册scroll监听
		    :addTo(bg)
		    item:getScrollNode():setPosition(0,bound.height/2-sTip:getContentSize().height/2+2)
		end
	end

	self:addColorLabelIf(bg)
end
--[[
	添加字符串背景
]]
function CMAlertDialog:addColorLabelIf(bg)
	if not self.params.colorText then return end
	local CMRichLabel 	   = require("app.Component.CMRichLabel")
	  --local strArr = {}
	  --strArr[4] = "[fontColor=fefefe fontSize=28]1、玩家在[/fontColor][fontColor=00ffff fontSize=28]中高级场玩牌[/fontColor][fontColor=fefefe fontSize=28],每局将获得数量不登的积分,[/fontColor][fontColor=00ffff fontSize=28]盲注级别越高,获得积分越多[/fontColor][fontColor=fefefe fontSize=28]。[/fontColor][fontColor=fefefe fontSize=28]\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t[/fontColor][fontColor=00ffff fontSize=28]2、VIP[/fontColor][fontColor=fefefe fontSize=28]玩家可获得相应等级的[/fontColor][fontColor=00ffff fontSize=28]积分返还加成[/fontColor][fontColor=fefefe fontSize=28]。\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t3、积分可在商城[/fontColor][fontColor=00ffff fontSize=28]兑换各种奖品[/fontColor][fontColor=fefefe fontSize=28]。[/fontColor]"
	  local curWidth = self.mSize.width + 15
	  local curHeight = 300

	  local params = {
	            text = self.params.colorText,
	            dimensions = cc.size(curWidth, curHeight)
	          }
	  local testLabel = CMRichLabel:create(params)
	  bg:addChild(testLabel)
	  testLabel:setPosition(50, bgHeight - 90)
end
--[[
	添加复选框
]]
function CMAlertDialog:addCheckBoxIf(bg)
	if not self.params.showBox then return end
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height 

	self.mBtnCheckBox = CMButton.new({normal = "picdata/public/btn_tick.png"},function () self:menuCallBack(EnumMenu.eBox) end,{Scale9 = false},{scale = false})
	self.mBtnCheckBox:setPosition(70,155)
	bg:addChild(self.mBtnCheckBox)

	local sTip = cc.ui.UILabel.new({text = "此问题不再弹出确认提示",
		color = cc.c3b(135,154,192),
		size = 26,
		textAlign = cc.TEXT_ALIGNMENT_LEFT,})	
	sTip:setPosition(100,155)
	bg:addChild(sTip,0)
	
end
function CMAlertDialog:touchListener(event)
	if event.name == "itemAppear" then
		--self:sourceDelegate(event.listView, cc.ui.UIListView.CELL_TAG,event.itemPos)
	end
end
--[[
	异步添加列表(数据量大的情况用）
]]
function CMAlertDialog:sourceDelegate(listView, tag, idx)
    --print(string.format("TestUIListViewScene tag:%s, idx:%s", tostring(tag), tostring(idx)))
 	if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.params.text
    elseif cc.ui.UIListView.CELL_TAG == tag then

        local item
        local content
        item = self.mList:dequeueItem()
        if not item then
            item = self.mList:newItem()       
        end
        item:removeAllChildren()

        --local sTip = cc.ui.UILabel.new({text = self.params.text[idx] or "",color = cc.c3b(255,255,255),size = 20,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(570, 0)})	
		local sTip = cc.LabelTTF:create(self.params.text[idx] or "","黑体",20,cc.size(570, 0),cc.TEXT_ALIGNMENT_LEFT)
		sTip:setPosition(0, 40)
		item:addContent(sTip)
		item:setItemSize(sTip:getContentSize().width, sTip:getContentSize().height)
        return item
    end
end
--[[
	按钮回调
]]
function CMAlertDialog:menuCallBack(_tag)
	if _tag == EnumMenu.eOK then
		if self.params.callOk then 
			self.params.callOk(self.mIsSelectBox)
		end					
	elseif _tag == EnumMenu.eClose then			
		if self.params.callCancle then 
			self.params.callCancle(self.mIsSelectBox)			
		end	
	elseif _tag == EnumMenu.eBox then
		self:onMenuCheckBox()
		return 
	end
	if self.params and self.params.autoClose ~= false then
		GIsClose = false
		CMClose(self)
	end
end
--[[
	复选宽选择
]]
function CMAlertDialog:onMenuCheckBox()
	if self.mIsSelectBox == 0 then
		self.mBtnCheckBox:setTexture("picdata/public/btn_tick1.png")
		self.mIsSelectBox = 1
	else
		self.mBtnCheckBox:setTexture("picdata/public/btn_tick.png")
		self.mIsSelectBox = 0
	end
end
return CMAlertDialog