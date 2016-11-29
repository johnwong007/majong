---
-- 网络信号指示器
--

local RoomSignalIndicator = class("RoomSignalIndicator", function() return display.newNode() end)

function RoomSignalIndicator:ctor()
    self.signal1_ = display.newSprite("picdata/public_new/icon_wifi1.png", 0, 0):addTo(self)
    self.signal2_ = display.newSprite("picdata/public_new/icon_wifi2.png", 0, 0):addTo(self)
    self.signal3_ = display.newSprite("picdata/public_new/icon_wifi3.png", 0, 0):addTo(self)

    self.signalNo_ = display.newSprite("picdata/public_new/loading_small.png", 0, 0):addTo(self)
    self.signalNo_:setVisible(false)

    self.isFlashing_ = false
end

---
-- 设置信号指示器的强度
--
-- @number strength -1无网络\0正在重连\1弱\2中\3强
--
function RoomSignalIndicator:setSignalStrength(strength)
    self:setAllVisible(strength)
    self:flash_(strength == 0)
end

function RoomSignalIndicator:setAllVisible(strength)
    strength = strength or 0
    if strength < 1 then
        self.signal1_:setVisible(false)
        self.signal2_:setVisible(false)
        self.signal3_:setVisible(false)
        self.signalNo_:setVisible(true)
    else
        self.signal1_:setVisible(strength == 1)
        self.signal2_:setVisible(strength == 2)
        self.signal3_:setVisible(strength > 2)
        self.signalNo_:setVisible(false)
    end
end

function RoomSignalIndicator:flash_(isFlash)
    if self.isFlashing_ ~= isFlash then
        self.isFlashing_ = isFlash
        self.signalNo_:stopAllActions()
        if isFlash then
            self.signalNo_:runAction(cc.RepeatForever:create(transition.sequence({
                --params:时间，角度
                cc.RotateTo:create(1,180),
                cc.RotateTo:create(1,360)

            })))
        end
    end
end

return RoomSignalIndicator