---
-- DEBUG日志侧边栏
--

local DebugLogPopup = class("DebugLogPopup", function() return display.newNode() end)
local ListItemText = import("app.Component.ListItemText")

DebugLogPopup.WIDTH = 480
DebugLogPopup.HEIGHT  = 570

function DebugLogPopup:ctor()
    self.background_ = display.newScale9Sprite("picdata/public_new/bg.png", 0, 0, cc.size(DebugLogPopup.WIDTH, DebugLogPopup.HEIGHT))
    self.background_:addTo(self)
    self:pos(- DebugLogPopup.WIDTH * 0.5, display.cy - 50)

    self.btn_ = cc.ui.UIPushButton.new({normal="picdata/public_new/btn_back.png"}, {scale9=true})
        :setButtonSize(72, 72)
        :pos(DebugLogPopup.WIDTH + 25, DebugLogPopup.HEIGHT - 40)
        :onButtonClicked(handler(self, self.onBtnClicked_))
        :addTo(self.background_)
    self.isShow_ = false

    self.debugListView_ = cc.ui.UIListView.new({
            viewRect = cc.rect(DebugLogPopup.WIDTH * -0.5, DebugLogPopup.HEIGHT * -0.5, DebugLogPopup.WIDTH, DebugLogPopup.HEIGHT - 90),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        })
    self.debugListView_:pos(DebugLogPopup.WIDTH * 0.5, DebugLogPopup.HEIGHT * 0.5 + 10)
        :addTo(self.background_);
    self.stopButton = cc.ui.UICheckBoxButton.new({off = "picdata/public/checkboxOff.png", on = "picdata/public/checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "停止滚动", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :pos(DebugLogPopup.WIDTH - 155, DebugLogPopup.HEIGHT - 40)
        :onButtonStateChanged(handler(self, self.onStopScroll))
        :addTo(self.background_)
end

---
-- 添加需要显示的日志
--
-- @string str 日志字符串
-- @string  tag 日志标签，配合 CMPrintTag 使用
--
function DebugLogPopup:addData(str, tag)
    if GV.debugTag and GV.debugTag ~= "" and GV.debugTag ~= tag then
        return
    end
    if self.debugListView_ then
        if not self.m_debugMsgNum then
            self.m_debugMsgNum = 0
        end
        self.m_debugMsgNum = self.m_debugMsgNum + 1
        if type(str) == "table" then
            self:dump(str, nil, 5)
        else
            local message = "[".. self.m_debugMsgNum .."]"..str
            self:createItems(message)
        end
    end
    return self
end

function DebugLogPopup:onBtnClicked_(event)
	if self.isShow_ then
		self:onHide()
		self.btn_:setScaleX(-1)
	else
		self:onShow()
		self.btn_:setScaleX(1)
	end
end

function DebugLogPopup:onStopScroll(event)
    if event.target:isButtonSelected() then
        self.stopScroll = true
    else
        self.stopScroll = false
    end
end

function DebugLogPopup:onHide(removeFunc)
	self.isShow_ = false
    self:stopAllActions()
    self.debugListView_:hide()
    transition.moveTo(self, {time=0.3, x=-DebugLogPopup.WIDTH * 0.5, easing="OUT"})
    return self
end

function DebugLogPopup:onShow()
	self.isShow_ = true
    self:stopAllActions()
    self.debugListView_:show()
    transition.moveTo(self, {time=0.3, x=DebugLogPopup.WIDTH * 0.5, easing="OUT"})
    return self
end

function DebugLogPopup:dump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end
    if not self.m_debugMsgNum then
        self.m_debugMsgNum = 0
    end
    self.m_debugMsgNum = self.m_debugMsgNum + 1
    local traceback = string.split(debug.traceback("", 2), "\n")
    self:createItems(("[".. self.m_debugMsgNum .."]dump from: " .. string.trim(traceback[3])))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        self:createItems(line)
    end
end

function DebugLogPopup:createItems(data)
    local oldpos = self.debugListView_.scrollNode:getPositionY()
    local item = self.debugListView_:newItem()
    local itemSize = cc.size(DebugLogPopup.WIDTH, 132)
    local listItemText = ListItemText.new(DebugLogPopup.WIDTH):onDataSet(data)
    item:addContent(listItemText)
    item:setItemSize(listItemText:getContentSize().width or itemSize.width, listItemText:getContentSize().height or itemSize.height)
    self.debugListView_:addItem(item)
    self.debugListView_:reload()
    if self.stopScroll then
        self.debugListView_:scrollTo(0, oldpos - (listItemText:getContentSize().height or itemSize.height))
    else
       self.debugListView_:scrollTo(0, 0)
    end
    return self
end

return DebugLogPopup