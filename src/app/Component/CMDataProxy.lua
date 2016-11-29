---
-- CMDataProxy 数据代理模块
--
-- 注意：设置数据时若启用了proxy，getData获取到的相应dataTable是一个空的代理表，无法遍历。
-- 真实数据位于getmetatable(dataTable)的__index键。
--

local CMDataProxy = class("CMDataProxy")

CMDataProxy.DATA_KEYS = {}

CMDataProxy.DATA_KEYS.USERCONFIG = "USERCONFIG" --用户相关数据

CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH = "SIGNAL_STRENGTH" --信号强度

function CMDataProxy:ctor()
    -- 数据池
    self.dataPool_        = {}
    -- 数据池对应的handler池
    self.keyHandler_      = {}
    -- 数据中的属性对应的handler池
    self.propertyHandler_ = {}
    self.nextHandleIndex_ = 0
end

---
-- 设置一个data代理，如果withProxy为true，则跟踪data的更新操作
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @tab  data 需要进行数据代理的表
-- @bool  withProxy 是否需要跟踪data的更新操作
-- @return table 代理data的table
--
function CMDataProxy:setData(key, data, withProxy)    
    local dataPool        = self.dataPool_
    local keyHandler      = self.keyHandler_
    local propertyHandler = self.propertyHandler_

    -- 设置data
    if withProxy then
        if type(data) == "table" then
            local proxyTable = {}
            local metaTable  = {
                __index    = data, 
                __newindex = function (_, property, value)
                    -- 设置某个属性的value
                    data[property] = value;

                    -- 执行相应的处理函数
                    if propertyHandler[key] and propertyHandler[key][property] then
                        for _, handler in pairs(propertyHandler[key][property]) do
                            handler(value)
                        end
                    end
                end
            }
            setmetatable(proxyTable, metaTable)
            dataPool[key] = proxyTable

            -- 执行相应的处理函数
            if propertyHandler[key] then
                for property, handlerTable in pairs(propertyHandler[key]) do
                    for _, handler in pairs(handlerTable) do
                        handler(data[property])
                    end
                end
            end
        else
            dataPool[key] = data
        end
    else
        dataPool[key] = data
    end

    -- 执行相应的处理函数
    if keyHandler[key] then
        for _, handler in pairs(keyHandler[key]) do
            handler(data);
        end
    end

    return dataPool[key]
end

---
-- 缓存一个data，如果withProxy为true，则获取这个data的时候返回代理
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @bool  withProxy 是否需要跟踪data的更新操作
--
-- @return nil
--
function CMDataProxy:cacheData(key, withProxy)
    local cacheData = {}
    local data = self:getData(key)
    if data then
        if not withProxy then            
            cacheData.data = data
            cacheData._withProxy_ = false
            bm.cacheTable(key, cacheData)            
        else
            cacheData.data = getmetatable(data).__index
            cacheData._withProxy_ = true
            bm.cacheTable(key, cacheData)
        end
    end
end

---
-- 根据key键获取data对应的代理(未完成)
--
-- @param key 键，取自 CMDataProxy.DATA_KEYS
-- @return table 代理data的table
--
function CMDataProxy:getData(key)
    if self.dataPool_[key] then
        return self.dataPool_[key]
    else
        -- local cacheData = bm.cacheTable(key)
        -- if type(cacheData) == "table" then
        --     local withProxy = cacheData._withProxy_
        --     cacheData._withProxy_ = nil
        --     self:setData(key, cacheData.data, withProxy)
        --     return cacheData.data
        -- else
            return nil
        -- end        
    end    
end

---
-- 判断是否存在key键对应的代理
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @return table 代理data的table
--
function CMDataProxy:hasData(key)
    return self.dataPool_[key] ~= nil or false
end

---
-- 为一个data代理设置观察处理函数handler
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @func  handler 监听方法
--
-- @return handle number类型，handler序列号
--
function CMDataProxy:addDataObserver(key, handler)
    local keyHandler = self.keyHandler_

    if not keyHandler[key] then
        keyHandler[key] = {}
    end
    self.nextHandleIndex_ = self.nextHandleIndex_ + 1
    local handle = tostring(self.nextHandleIndex_)
    keyHandler[key][handle] = handler

    if self.dataPool_[key] then
        handler(self.dataPool_[key])
    end

    return handle
end

---
-- 根据handle序列号移除观察处理函数handler
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @number handle handler序列号
--
-- @return boolean boolean类型，是否成功
--
function CMDataProxy:removeDataObserver(key, handleToRemove)
    local keyHandler = self.keyHandler_

    if (keyHandler[key]) then
        for handle, _ in pairs(keyHandler[key]) do
            if handle == handleToRemove then
                keyHandler[key][handleToRemove] = nil
                return true
            end
        end
    end

    return false
end

---
-- 为一个data的property设置观察处理函数handler
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @string  property data表的属性
-- @func  handler 观察处理函数handler
-- @return handle number类型，handler序列号
--
function CMDataProxy:addPropertyObserver(key, property, handler)
    local propertyHandler = self.propertyHandler_

    if not propertyHandler[key] then
        propertyHandler[key] = {}
    end

    if not propertyHandler[key][property] then
        propertyHandler[key][property] = {}
    end

    self.nextHandleIndex_ = self.nextHandleIndex_ + 1
    local handle = tostring(self.nextHandleIndex_)
    propertyHandler[key][property][handle] = handler

    if self.dataPool_[key] then
        handler(self.dataPool_[key][property])
    end

    return handle
end

---
-- 移除特定handle的观察处理函数handler
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @string  property data表的属性
-- @func  handleToRemove 需要移除的观察处理函数handler
-- @return boolean 是否操作成功
--
function CMDataProxy:removePropertyObserver(key, property, handleToRemove)
    local propertyHandler = self.propertyHandler_

    if propertyHandler[key] and propertyHandler[key][property] then
        for handle, _ in pairs(propertyHandler[key][property]) do
            if handle == handleToRemove then
                propertyHandler[key][property][handleToRemove] = nil
                return true
            end
        end
    end

    return false
end

---
-- 清理一个data，并决定是否需要最后一次执行观察处理函数handler
--
-- @string key 键，取自 CMDataProxy.DATA_KEYS
-- @bool  noNeedHandler 是否需要最后一次执行观察处理函数handler
--
-- @return boolean 是否操作成功
--
function CMDataProxy:clearData(key, noNeedHandler)
    if self:hasData(key) then
        local keyHandler      = self.keyHandler_
        local propertyHandler = self.propertyHandler_

        -- data置为nil
        self.dataPool_[key] = nil

        if not noNeedHandler then
            -- 执行相应的处理函数
            if keyHandler[key] then
                for _, handler in pairs(keyHandler[key]) do
                    handler(nil)
                end
            end

            if propertyHandler[key] then
                for _, handlerTable in pairs(propertyHandler[key]) do
                    for _, handler in pairs(handlerTable) do
                        handler(nil)
                    end
                end
            end
        end

        return true
    else
        return false
    end
end

return CMDataProxy.new()