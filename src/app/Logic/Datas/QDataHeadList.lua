--
-- Author: junjie
-- Date: 2015-12-14 17:12:34
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataHeadList = class("QDataHeadList",QDataBase)
function QDataHeadList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataHeadList:Init(_msg,nType)
	self._msg = self._msg or {}
	self._msg[nType] = _msg

	--dump(self._msg)
end

--[[
  经典头像列表
]]
function QDataHeadList:getMsgData(nType)
	if not self._msg then return nil end
	return self._msg[nType]
end

return QDataHeadList