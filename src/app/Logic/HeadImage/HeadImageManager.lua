local HEAD_IMAGE_ROOT = "images/heads"
local HeadImageManager = class("HeadImageManager")

sharedHeadImageManager = nil
function HeadImageManager:getInstance()
	if not sharedHeadImageManager then
		sharedHeadImageManager = HeadImageManager:new()
	end
	return sharedHeadImageManager
end

function HeadImageManager:ctor()
	self.m_headList = {}
end

function HeadImageManager:setHeadImageRoot(headImageRoot)
	HEAD_IMAGE_ROOT = headImageRoot
	if HEAD_IMAGE_ROOT==nil then
		HEAD_IMAGE_ROOT = "images/heads"
	end
end

function HeadImageManager:findHeadPath(headURL)
	
	local ID = self:URLToID(headURL)
    local isExist = cc.FileUtils:getInstance():isFileExist(self:IDToPath(ID))
    if (isExist and headURL ~="") then
        return self:IDToPath(ID)
    end
    
    for i=1,#self.m_headList do
	
		if(self.m_headList[i] == ID) then
		
			return self:IDToPath(ID)
		end
	end
	return ""
end

function HeadImageManager:storeToPath(data, size, URL)

	--检查是否已经存在
	local FileRoot = ""..HEAD_IMAGE_ROOT
	FileRoot = cc.FileUtils:getInstance():getWritablePath()..FileRoot --"" + FileRoot
	-- io.open(FileRoot, "w")
	local ID = self:URLToID(URL)
	local _path = self:IDToPath(ID)
	--CCLog("HeadImageManager----path %s", _path)
	local file = io.open(_path,"r")
	if(file) then
		io.close(file)
	else
		file = io.open(_path,"wb+")
		if (file) then
		
			io.write(data,1,size,file)
			io.close(file)
		end
	end
    
	local hasItem = false
	for i=1,#self.m_headList do
	
		if(m_headList[i] == ID) then
		
			hasItem = true
			break
		end
	end
	if(not hasItem) then
		self.m_headList[#self.m_headList] = ID
	end
    
	return true
end

function HeadImageManager:IDToPath(ID)

	local _path = cc.FileUtils:getInstance():getWritablePath()
	_path = _path .. HEAD_IMAGE_ROOT
	_path = _path .. "/" .. ID
	return _path
end

function HeadImageManager:URLToID(URL)
	local pos = 0
	for i=string.len(""..URL),1,-1 do
		if string.sub(URL,i,i) == "/" then
			pos = i
			break
		end
	end
	local ID = string.sub(URL,pos+1)
	return ID
end

return HeadImageManager