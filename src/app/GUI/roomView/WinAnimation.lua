
--图片路径
C_YOU_WIN_BACKGROUND_PATH = "picdata/table/uWinLight.png"--背景亮点
C_YOU_WIN_SHOW_PATH       = "picdata/table/uWin.png"--you win 图片

REWARD_BACKGROUND_PATH = "picdata/gameTech/rewardLight.png"--背景亮点
REWARD_SHOW_PATH       = "picdata/gameTech/reward1.png"--you win 图片

local WinAnimation = class("WinAnimation", function()
		return cc.Sprite:create()
	end)

function WinAnimation:create(pParent, pWin)
	local p = WinAnimation:new()
	p:initData(pBack, pWin)
	p:init()
	return p
end

function WinAnimation:ctor()

end

function WinAnimation:initData(pBack, pWin)
	self.m_pBackground = pBack
	self.m_pWin = pWin
end

function WinAnimation:init()
	if not self.m_pBackground or not self.m_pWin then
		return false
    end

	self:initWithTexture(self.m_pBackground:getTexture())
    
	local size = self.m_pBackground:getContentSize()
	self.m_pWin:setAnchorPoint(cc.p(0.5,0.5))
	self.m_pWin:setPosition(cc.p(size.width / 2 - 8, size.height / 2))
	self:WinDisappear()
	self:addChild(self.m_pWin)
end



function WinAnimation:runWinAnimation(pParent, zorder)

    --位置信息593.307
    local C_YOU_WIN_POS = cc.p(SCREEN_IPHONE5 and 568 or 480,250)
    
	local pBack = cc.Sprite:create(C_YOU_WIN_BACKGROUND_PATH)
	local pWin  = cc.Sprite:create(C_YOU_WIN_SHOW_PATH)
    
	assert(pBack and pWin,"WinAnimation you win images missed.")
    
	local pWinObject = WinAnimation:create(pBack,pWin)
    
	if pWinObject and pParent then
	
		pWinObject:setPosition(C_YOU_WIN_POS)
		pWinObject:setVisible(false)
		pParent:addChild(pWinObject,zorder)
		pWinObject:doRunWinAnimation()
	end
end

function WinAnimation:runRewardAnimation(pParent, zorder)

    --位置信息593.307
    local C_YOU_WIN_POS = cc.p(SCREEN_IPHONE5 and 568 or 480,330)
    
    local pBack = cc.Sprite:create(REWARD_BACKGROUND_PATH)
    local pWin  = cc.Sprite:create(REWARD_SHOW_PATH)
    
    assert(pBack and pWin,"WinAnimation you win images missed.")
    
   	local pWinObject = WinAnimation:create(pBack,pWin)
    
    if pWinObject and pParent then
    
        pWinObject:setPosition(C_YOU_WIN_POS)
        pWinObject:setVisible(false)
        pParent:addChild(pWinObject,zorder)
        pWinObject:doRunWinAnimation()
    end
end



function WinAnimation:doRunWinAnimation()

	if self.m_pWin then
	
		local actionArray = {}
        actionArray[#actionArray+1] = cc.ScaleTo:create(1.5,1.0,1.0)
        actionArray[#actionArray+1] = cc.FadeIn:create(1.5)
        
		local action = cc.Spawn:create(actionArray)
        
		self.m_pWin:runAction(cc.Sequence:create(
                                             cc.CallFunc:create(handler(self,self.WinAppear)),
                                             action,
                                             cc.CallFunc:create(handler(self,self.WinDisappear))
                                             )
							  )
	end
end

function WinAnimation:WinAppear()

	if self.m_pBackground and self.m_pWin then
	
		self:setVisible(true)
        
		self.m_pWin:setVisible(true)
		self.m_pWin:setScale(0.5)
	end	
end

function WinAnimation:WinDisappear()

	if self.m_pBackground and self.m_pWin then
		self:getParent():removeChild(self, true)
	end	
end


return WinAnimation