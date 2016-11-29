local DialogBase = require("app.GUI.roomView.DialogBase")

local kLeaveRoom = 0
local kChangeRoom = 1
local kQuickRecharge = 2

local InsufficientBalanceDialog = class("InsufficientBalanceDialog", function(event)
		return DialogBase:new()
	end)

function InsufficientBalanceDialog:create(pCallback, pCallbackFuc, base, bigBlind, balance, minBuyin, action)

	local dialog = InsufficientBalanceDialog:new()
	dialog:init(pCallback,pCallbackFuc,base,bigBlind,balance,minBuyin,action)
	return dialog
end

function InsufficientBalanceDialog:init(pCallback, pCallbackFuc, base, bigBlind, balance, minBuyin, action)
	self.m_balance = balance
	self.m_minBuyin = minBuyin
	self.m_buyClickTarget = pCallback
	self.m_buyClickCallback = pCallbackFuc

    self:manualLoadxml()
    
    local vipRank=tonumber(MyInfo.data.vipRank)
    local nextVipRank= tonumber(MyInfo.data.nextVipRank)


    if type(vipRank)~="number" then
   		vipRank = 0
    end
    if type(nextVipRank)~="number" then
   		nextVipRank = vipRank+1
    end

    local userLv = tonumber(MyInfo.data.vipLevel)
    local vipIcon = self.vipIcon
    local vipIconSp = "picdata/shop/vip" .. userLv .. ".png"
    vipIcon:setTexture(cc.Sprite:create(vipIconSp):getTexture())
    
    local tmp = vipRank.."/"..nextVipRank
    local infoLabel = cc.ui.UILabel.new({
		text = tmp,
		font = "Arial",
		size = 18,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, display.cx-82, display.cy+115)
		-- :addTo(self, 6) 
	infoLabel:setVisible(false)	

    local tmpNum = nextVipRank+0-vipRank
    local lvNum = userLv+1
    local vipContentBg = self.vipContentBg
  
    if userLv+0 == 0 then 
        if (MyInfo.data.payamount <= 0) then 
            self.vipIcon:setVisible(false)
            self.vip_jdt_bg:setVisible(false)
            self.vipContent:setVisible(false)
            vipContentBg:setTexture(cc.Sprite:create("picdata/gamescene/yebz_ad_scdlb.png"):getTexture())
            if GIOSCHECK then
            	vipContentBg:setVisible(false)
            end
            local gap = 15
        	vipContentBg:setPositionY(vipContentBg:getPositionY()+gap)
        	self.prompt_notenough:setPositionY(self.prompt_notenough:getPositionY()+gap)
        	self.myMoney:setPositionY(self.myMoney:getPositionY()+gap)
        	self.prompt_notenough1:setPositionY(self.prompt_notenough1:getPositionY()+gap)
        	self.minBuy:setPositionY(self.minBuy:getPositionY()+gap)
        else
            local scaleX = vipRank / nextVipRank
            local progress = cc.ui.UIImage.new("picdata/shop/vip_jdt.png")
            progress:setScaleX(scaleX)
            progress:setAnchorPoint(cc.p(0, 0))
            progress:setPosition(cc.p(0, 0))
            self.vip_jdt_bg:addChild(progress,4)
            
            vipContentBg:setTexture(cc.Sprite:create("picdata/gamescene/yebz_ad_vip0.png"):getTexture())
            self:addChild(infoLabel,5)
        end
    elseif (userLv>0 and userLv+0<4) then
        local  scaleX = vipRank /  nextVipRank
        local progress = cc.Sprite:create("picdata/shop/vip_jdt.png")
        progress:setScaleX(scaleX)
        progress:setAnchorPoint(cc.p(0, 0))
        progress:setPosition(cc.p(0, 0))
        self.vip_jdt_bg:addChild(progress,4)
        
        vipContentBg:setTexture(cc.Sprite:create("picdata/gamescene/yebz_ad_vip1-3.png"):getTexture())
        self:addChild(infoLabel,5)
    else
--      默认就是v4+图片  不做替换了
        local  scaleX = vipRank /  nextVipRank
        local progress = cc.Sprite:create("picdata/shop/vip_jdt.png")
        progress:setScaleX(scaleX)
        progress:setAnchorPoint(cc.p(0, 0))
        progress:setPosition(cc.p(0, 0))
        self.vip_jdt_bg:addChild(progress,4)
        
        self:addChild(infoLabel,5)
    end
    
    
    local contentStr =""
    if (lvNum<=10) then 
        contentStr = "再充值"..tmpNum.."元可达到VIP"..lvNum
    else
        contentStr = "您已经是尊贵的VIP10用户了"
    end
    self.vipContent:setString(contentStr)
    
	self:updateInfo()
end

function InsufficientBalanceDialog:manualLoadxml()
	local bgPosx = display.cx
	local bgPosy = display.cy
	cc.ui.UIImage.new("chargeDialogBg.png")
		:align(display.CENTER, bgPosx+15, bgPosy)
		:addTo(self)
	cc.ui.UIImage.new("yebz_title.png")
		:align(display.CENTER, bgPosx+10, bgPosy+190)
		:addTo(self)

	self.cancel = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, bgPosx+333, bgPosy+202)
		:addTo(self, 1)
		:onButtonClicked(function(event)
			self:button_click("cancel")
			end)

	self.vipContentBg = cc.ui.UIImage.new("yebz_ad_vipyh.png")
		:align(display.CENTER, bgPosx, bgPosy)
		:addTo(self)

	self.vipIcon = cc.ui.UIImage.new("vip0.png")
		:align(display.LEFT_CENTER, bgPosx-260, bgPosy+130)
		:addTo(self,2)

	self.vip_jdt_bg = cc.ui.UIImage.new("vip_jdt_bg.png")
		:align(display.CENTER, bgPosx-177, bgPosy+102)
		:addTo(self,2)

	self.vipContent = cc.ui.UILabel.new({
		text = "再充值20000元可达到VIP10",
		font = "黑体",
		size = 18,
		color = cc.c3b(228,213,180),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, bgPosx+37, bgPosy+115)
		:addTo(self, 4)

	self.prompt_notenough = cc.ui.UILabel.new({
		text = "您的金币账户余额为",
		font = "黑体",
		size = 22,
		color = cc.c3b(134,164,223),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, bgPosx-280, bgPosy-120)
		:addTo(self, 3)

	self.myMoney = cc.ui.UILabel.new({
		text = "",
		font = "黑体",
		size = 22,
		color = cc.c3b(255,0,0),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.prompt_notenough:getPositionX()+self.prompt_notenough:getContentSize().width+40, bgPosy-120)
		:addTo(self, 3)

	self.prompt_notenough1 = cc.ui.UILabel.new({
		text = "无法支付本房间最小买入",
		font = "黑体",
		size = 22,
		color = cc.c3b(134,164,223),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.myMoney:getPositionX()+self.myMoney:getContentSize().width+40, bgPosy-120)
		:addTo(self, 3)

	self.minBuy = cc.ui.UILabel.new({
		text = "2220.3万",
		font = "黑体",
		size = 22,
		color = cc.c3b(0,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, self.prompt_notenough1:getPositionX()+self.prompt_notenough1:getContentSize().width+5, bgPosy-120)
		:addTo(self, 3)

	self.change_room = cc.ui.UIPushButton.new({normal="btn_kshz.png", pressed="btn_kshz.png", disabled="btn_kshz.png"})
		:align(display.CENTER, bgPosx-146, bgPosy-190)
		:addTo(self, 4)
		:onButtonClicked(function(event)
			self:button_click("change_room")
			end)

	self.quickRecharge = cc.ui.UIPushButton.new({normal="btn_ljcz.png", pressed="btn_ljcz.png", disabled="btn_ljcz.png"})
		:align(display.CENTER, bgPosx+138, bgPosy-190)
		:addTo(self, 4)
		:onButtonClicked(function(event)
			self:button_click("quickRecharge")
			end)
end

function InsufficientBalanceDialog:setButtonClickCallback(target, callfunc)

	if(self.m_target ~= target and self.m_callback ~= callfunc) then
	
		self.m_target = target
		self.m_callback = callfunc
	end
end


function InsufficientBalanceDialog:button_click(strId)
	if(strId == "cancel") then
	
		self:remove()
	elseif(strId == "quickRecharge") then
	
		local action = kQuickRecharge
		if(self.m_target and self.m_callback) then
		
			self.m_callback(self, action)
		end
        self:remove()
	elseif(strId == "change_room") then
	
		local action = kChangeRoom
		if(self.m_target and self.m_callback) then
		
			self.m_callback(self, action)
		end
    else
    
        if tag == 10000 then
        
            self:remove()
        end
    end
end

function InsufficientBalanceDialog:updateInfo()

	local myMoney = self.myMoney
    local minBuy = self.minBuy
  
    myMoney:setString(StringFormat:FormatDecimals(self.m_balance,2))
    minBuy:setString(StringFormat:FormatDecimals(self.m_minBuyin,2))
    myMoney:setPositionX(myMoney:getPositionX()-myMoney:getContentSize().width/2)

end

function InsufficientBalanceDialog:clickBuyCallback(value)

	if(self.m_buyClickTarget and self.m_buyClickCallback) then
	
		self.m_buyClickCallback(value)
	end
	self:removeAllChildren(true)
	self:removeFromParent(true)
end

return InsufficientBalanceDialog