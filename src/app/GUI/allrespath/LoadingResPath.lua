--
-- Author: junjie
-- Date: 2016-05-13 11:26:37
--
local LoadingResPath = {}
LoadingResPath.allLoad = {"MainPagePath","ActivityPath","RewardPath"}
function LoadingResPath:getResPath(nType)

	if type(nType) ~= "table" then
		if not self:checkType(nType) then return {} end
		return self:resortDir(nType)
	end
	-- dump(LoadingResPath)
	local lens = 0
	for i,v in pairs(nType) do 
		lens = lens + #v
	end
	return lens

end
function LoadingResPath:checkType(nType)
	for i,v in pairs(LoadingResPath.allLoad) do 
		if v == nType then 
			return true 
		end
	end
	return false
end
function LoadingResPath:resortDir(nType)
	-- local allPath = LoadingResPath[nType]
	local allPath = require(string.format("app.GUI.allrespath.%s",nType))
	local newAllPath = {}
	local notPng = 0
	for i,v in pairs(allPath) do
		local _,index = string.find(v,".+.png") --检测是否是png图片
		if index then
			table.insert(newAllPath,v)
		else
			notPng = notPng + 1
		end
	end
	dump(newAllPath)
	return newAllPath
end

return LoadingResPath