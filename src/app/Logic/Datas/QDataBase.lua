--
-- Author: junjie
-- Date: 2015-12-31 15:24:06
--

local QDataBase = {}

function QDataBase:Init(_msg)
	self._msg = _msg
end
function QDataBase:Instance(key)
	--key = "QDataBase"
    if self.instance == nil then       
        self.instance = self:new()
        QManagerData:insertCacheData(key,self.instance)
    end
    return self.instance
end
function QDataBase:isExistMsgData()
	if self._msg then 
		return true
	else 
		return false
	end
end
function QDataBase:removeMsgData()
	self._msg    = nil
	self._newMsg = nil
end
function QDataBase:getMsgData()
	return self._msg
end
return QDataBase