---
-- SchedulerPool 调度池
--
-- 用于管理延迟操作的调度线程
-- 一般根据序列号Id和标识Tag进行管理，序列号Id代表了一个，而标识Tag代表了一类
--

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local SchedulerPool = class("SchedulerPool")

function SchedulerPool:ctor()
    self.pool_ = {}
    self.tags = {}
    self.id_ = 0
end

---
-- 清理池内所有调度
--
-- @return nil
--
function SchedulerPool:clearAll()
    for k, v in pairs(self.pool_) do
        scheduler.unscheduleGlobal(v)
    end
    self.pool_ = {}
end

---
-- 根据序列号Id删除调度线程
--
-- @number id 调度线程的序列号
-- @return nil
--
function SchedulerPool:clearById(id)
    if self.pool_[id] then
        scheduler.unscheduleGlobal(self.pool_[id])
        self.pool_[id] = nil
    end
end

---
-- 根据标识Tag删除调度线程
--
-- @param tag 调度线程的标识，类型自定义
-- @return nil
--
function SchedulerPool:clearByTag(tag)
    if self.tags[tag] then
        for i, v in pairs(self.tags[tag]) do
            self:clearById(i)
            self.tags[tag][i] = nil
        end
    end
end

---
-- 单次延迟调度线程
--
-- @func callback 调度的方法
-- @number  delay 延迟时间，单位秒
-- @param  tag 调度线程的标识，类型自定义
-- @param  ... 拓展参数
-- @return id 调度线程的序列号
--
function SchedulerPool:delayCall(callback, delay, tag, ...)
    self.id_ = self.id_ + 1
    local id = self.id_
    local args = {...}
    local handle = scheduler.performWithDelayGlobal(function()
        self.pool_[id] = nil
        if callback then
            callback(self, unpack(args))
        end
    end, delay)
    self.pool_[id] = handle
    if tag then
        if not self.tags[tag] then self.tags[tag] = {} end
        self.tags[tag][id] = true
    end
    return id
end

---
-- 循环调度线程
--
-- @func callback 调度的方法
-- @number  interval 循环间隔，单位秒
-- @param  tag 调度线程的标识，类型自定义
-- @param  ... 拓展参数
-- @return id 调度线程的序列号
--
function SchedulerPool:loopCall(callback, interval, tag, ...)
    self.id_ = self.id_ + 1
    local id = self.id_
    local args = {...}
    local handle = scheduler.scheduleGlobal(function()
        if callback then
            if not callback(self, id, unpack(args)) then
                scheduler.unscheduleGlobal(self.pool_[id])
                self.pool_[id] = nil
            end
        end
    end, interval)
    self.pool_[id] = handle
    if tag then
        if not self.tags[tag] then self.tags[tag] = {} end
        self.tags[tag][id] = true
    end
    return id
end


return SchedulerPool