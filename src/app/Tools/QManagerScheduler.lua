--
-- Author: junjie
-- Date: 2015-12-15 20:37:26
--
local QManagerScheduler = {}

QManagerScheduler._scheduler 		= require("framework.scheduler")
QManagerScheduler._heartTime        = 0
QManagerScheduler.mOnlineTime       = 0
QManagerScheduler.listener          = {}
local mHeartTime                    = 4
function QManagerScheduler:new(_params)
    _params = _params or {}
    setmetatable(_params,self)
    self.__index = self    
    return _params
end
function QManagerScheduler:getInstance(_params)
    if self.instance == nil then       
        self.instance = self:new(_params)
    end
    return self.instance
    
end
function QManagerScheduler:startGolbalScheduler()
	self._heartBeatHandle = self._scheduler.scheduleGlobal(function () 					
		-- self:checkMemory()
		self:checkOnlineTime()
	end, mHeartTime)	
end

function QManagerScheduler:stopGolbalScheduler()
	if self._heartBeatHandle then 		
		self._scheduler.unscheduleGlobal(self._heartBeatHandle)
		self._heartBeatHandle = nil
	end
end
--[[
	_params:
	listener, interval,layer
]]
function QManagerScheduler:insertLocalScheduler(_params)
	self:removeLocalScheduler(_params)
	self.listener[_params.layer] = self._scheduler.scheduleGlobal(_params.listener, _params.interval or 1)	
	return self.listener[_params.layer]
end
function QManagerScheduler:removeLocalScheduler(_params)
	if self.listener[_params.layer] then
		self._scheduler.unscheduleGlobal(self.listener[_params.layer])
	end
	self.listener[_params.layer] = nil
end
function QManagerScheduler:getListenerLayerID(layer)
	for i,v in pairs(self.listener) do 
		if i == layer then
			return v
		end
	end
	return false
end
function QManagerScheduler:checkMemory()
	collectgarbage("collect")
	collectgarbage("collect")
	collectgarbage("collect")
	print("memorey   " .. collectgarbage("count"))
end
function QManagerScheduler:checkOnlineTime()
	self.mOnlineTime = self.mOnlineTime + mHeartTime
	-- dump(self.mOnlineTime)
	if self.mOnlineTime > 3*3600 then
		if self.mOnlineLayer then return end
		self.mOnlineLayer = require("app.Component.CMAlertDialog").new({text = "你当前累计在线时间已超过3小时，请注意多消息！",showType = 1,
			callOk = function () 
				self.mOnlineLayer = nil
			end
			
			})
		self.mOnlineTime = 0
		CMOpen(self.mOnlineLayer, GameSceneManager:getCurScene())
		
	end
end
return QManagerScheduler