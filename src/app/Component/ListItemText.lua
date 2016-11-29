--
-- ListItemText 用于ListView的只有文字的Item
--

local ListItemText = class("ListItemText", function() return display.newNode() end)

ListItemText.WIDTH = 400
ListItemText.HEIGHT = 20

function ListItemText:ctor(width, height)
    self.m_width = width or ListItemText.WIDTH
    self.m_height = height or ListItemText.HEIGHT
end

---
-- 设置文字
--
-- @string text 文字字符串
--
function ListItemText:onDataSet(text)
    if not CMIsNull(self.label_) then
        self.label_:removeFromParent()
    end
    --testLabel_用于测量大小
    self.testLabel_ = display.newTTFLabel({text="", size=20, color=cc.c3b(0xa0, 0xff, 0x82), align=cc.ui.TEXT_ALIGN_LEFT})
    self.testLabel_:setString(text or "")

    local testCsize = self.testLabel_:getContentSize()

    if testCsize.width > self.m_width - 80 then
        self.label_ = display.newTTFLabel({text="", size=20, color=cc.c3b(0xfa, 0xe6, 0xff), dimensions=cc.size(self.m_width - 30, 0), align=cc.ui.TEXT_ALIGN_LEFT})
        :addTo(self)
    else
        self.label_ = display.newTTFLabel({text="", size=20, color=cc.c3b(0xfa, 0xe6, 0xff), align=cc.ui.TEXT_ALIGN_LEFT})
        :addTo(self)
    end

    self.label_:setString(text or "")
    local csize = self.label_:getContentSize()
    local itemBgWidth = csize.width + 30
    local itemBgHeight = csize.height + 5

    self.label_:pos(itemBgWidth/2, itemBgHeight/2)
    self:setContentSize(cc.size(self.m_width, itemBgHeight))
    return self
end

return ListItemText