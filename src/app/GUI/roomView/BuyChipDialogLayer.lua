local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")

--[[
Callbacks:
    "pressCancel",
    "pressBuyChip",
    "pressCancelBuy",

Members:
    self.m_buyChipsBG CCSprite
    self.m_zxmr_label CCLabelTTF
    self.m_zdmr_label CCLabelTTF
    self.m_zuixiaomairu CCLabelTTF
    self.m_zuidamairu CCLabelTTF
    self.m_mr_label CCLabelTTF
    self.m_buyProgBG CCSprite
    self.m_buyProgress CCSprite
    self.m_buyChipsThumb CCSprite
    self.m_zidongmairu CCSprite
    self.m_buychiptip CCLabelTTF
]]
local BuyChipDialogLayer = Oop.class("BuyChipDialogLayer", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI.roomView", "ccb")
    return CCBLoader:load("BuyChipDialogLayer", owner)
end)

function BuyChipDialogLayer:ctor()
    -- @TODO: constructor
 
end

function BuyChipDialogLayer:pressCancel(sender, event)
    -- @TODO: implement this
    self:getParent():button_click("cancel")
end

function BuyChipDialogLayer:pressBuyChip(sender, event)
    -- @TODO: implement this
    self:getParent():button_click("mairuchouma")
end

function BuyChipDialogLayer:pressCancelBuy(sender, event)
    -- @TODO: implement this
    self:getParent():button_click("buyclose")
end



return BuyChipDialogLayer