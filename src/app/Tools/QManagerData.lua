--
-- Author: junjie
-- Date: 2015-12-31 10:51:30
--
local QManagerData = {}
QManagerData.cacheData = {}
function QManagerData:insertCacheData(key,userData)
	if not QManagerData.cacheData[key] then
		QManagerData.cacheData[key] = userData
	end
end

function QManagerData:removeCacheData(key,nType)
	--dump( QManagerData.cacheData)
	if QManagerData.cacheData[key] then 
		QManagerData.cacheData[key]:removeMsgData(nType)
	end
	QManagerData.cacheData[key] = nil
	--dump( QManagerData.cacheData)
end

function QManagerData:removeAllCacheData()
	for i,v in pairs(QManagerData.cacheData) do
		if v.removeMsgData then
			v:removeMsgData()
		end
		v = nil
	end
end
function QManagerData:getCacheData(key)
	if not QManagerData.cacheData[key] then
		QManagerData.cacheData[key] = require(string.format("app.Logic.Datas.%s",key)):Instance(key)
	end
	assert(QManagerData.cacheData[key],"QManagerData不存在key ＝ " .. key)
	
	return QManagerData.cacheData[key]
end
return QManagerData