--
-- Author: JJ
-- Date: 2016-01-24 01:11:05
--
--[[
	目录/文件处理
]]
require "lfs"
--创建目录
--[[
    path:当前路径
    root:上一路径
    isFile:最后一层是不是文件
]]
function CMCreateDirectory(path,root,isFile)
    --一层目录
    if CMCheckDirectory(path) then 
        return true
    end
    --多层目录
    local IsSuc = false
    local firDir,secDir = CMResolveDirectory(path) 
    if isFile and not secDir then return true end
    path = (root or "")..firDir
	if CMCheckDirectory(path) then 
		IsSuc = true
	end

    if not IsSuc then
        if lfs.mkdir(path) then
        	print("路径创建OK->"..path)
            IsSuc = true
        else
            print("路径创建失败->",path)
        end
    end
    while secDir do 
        IsSuc = CMCreateDirectory(secDir,path,isFile)
        if not IsSuc then print("路径创建失败->",secDir) return false end
        break
    end
    return IsSuc
end

--目录解析
function CMResolveDirectory(path)
    local nBeginPos,nEndPos = string.find(path,"./")
    local secDir = nil
    if nEndPos then
        secDir = string.sub(path,nEndPos+1,string.len(path))
        path = string.sub(path,1,nEndPos)
    end

    return path,secDir
end
-- --移除目录
--[[
function CMRemoveDirectory(path)
	if CMCheckDirectory(path) then
		local pathes,directoryes = CMGetDirectoryAndFile(path)
		for i,v in pairs(pathes) do 
			print("移除文件->"..v)
			os.remove(v)
		end
		for i,v in pairs(directoryes) do 
			print("移除目录->"..v)
			dump(os.remove(v))
		end
    end
    return true
end
]]
--检查目录是否存在
function CMCheckDirectory(path)
    local oldpath = lfs.currentdir()
    if lfs.chdir(path) then
    	print("路径存在OK->"..path)
        lfs.chdir(oldpath)
        return true
    end
    return false
end
--[[
	修改跟目录
	]]
function CMSetRootDirectory(root)
	if not root then return true end
	if lfs.chdir(root) then
		print("路径设置OK->"..root)
        return true
    end
    return false
end
--获取目录的所有文件和目录
function CMGetDirectoryAndFile(rootpath,pathes,directoryes)
	pathes = pathes or {}
	directoryes = directoryes or {}
    local ret, files, iter = pcall(lfs.dir, rootpath)
   
    if ret == false then
        return pathes
    end
    for entry in files, iter do
        local next = false
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath .. '/' .. entry
            local attr = lfs.attributes(path)
            if attr == nil then
                next = true
            end

            if next == false then 
                if attr.mode == 'directory' then
                	table.insert(directoryes, path)
                    CMGetDirectoryAndFile(path, pathes,directoryes)
                else
                    table.insert(pathes, path)
                end
            end
        end
        next = false
    end

    return pathes,directoryes
end
--按照后缀名获取文件
function CMGetFileByLastName(rootpath,lastName,isDel)
    local pathes = CMGetDirectoryAndFile(rootpath)
    local retpathes = {}
    for i,v in pairs(pathes) do 
        local index = string.find(v,lastName)
        if index then
            table.insert(retpathes,v)
            if isDel then
                os.remove(v)
            end
        end
    end
    return retpathes
end
--[[目录重命名
改名 os.rename (oldname, newname)
改名 可以以用于移动文件。os.rename (/etc/file1,/home/file2)]]
function CMRename(oldname, newname)
	os.rename (oldname, newname)
end
--移除目录
function CMRemoveDirectory(rootpath,directoryes)
    -- print("os.rmdir:", rootpath)
    directoryes = directoryes or {}
    if not CMCheckDirectory(rootpath) then
    	return false
    end
     
    local function _rmdir(rootpath)
        local iter, dir_obj = lfs.dir(rootpath)
        while true do
            local entry = iter(dir_obj)
            if entry == nil then break end
            if entry ~= "." and entry ~= ".." then
                local path = rootpath.. '/'..entry 
                local mode = lfs.attributes(path, "mode")            
                if mode == "directory" then
                    _rmdir(path)
                elseif mode == "file" then
                    os.remove(path)
                end
            end
        end
        local succ, des = os.remove(rootpath)
        if des then print(des) end
        return succ
    end
    _rmdir(rootpath)
   
    return true
end

--检查文件是否存在
function CMCheckFile(fileName)
    local oldpath = lfs.currentdir()
    fileName = oldpath.."/"..(fileName or "")
    if not io.exists(fileName) then 
        print("文件不存在->"..fileName) 
        return false 
    end
    return true
end
--写入文件
function CMWriteFile(fileName,content,root,isFile)
    local rootPath = (root or "update/") .. fileName
    if not CMCreateDirectory(rootPath,"",isFile) then return end
    local file = io.open(rootPath,"w+")
    file:write(content)
    io.flush()
    file:close()
end
--比较文件
function CMCompareFile(fileName1,fileName2)
    if not CMCheckFile(fileName1) then
        return false
    end
    local oldpath = lfs.currentdir()
    local fullFileName1 = oldpath.."/"..(fileName1 or "")
    local fullFileName2 = oldpath.."/"..(fileName2 or "")
    local file1 = io.open(fullFileName1,"r+")
    if not file1 then print("文件打开失败->",fullFileName1) return false end
    local strFile1 = file1:read("*all")
    file1:close()
    --Add
    if not CMCheckFile(fileName2) then
        print("添加文件->"..fileName1)
        CMWriteFile(fileName1,strFile1,nil,true) 
        return false
    end
    --Compare        
    local file2 = io.open(fullFileName2,"r+")
    if not file2 then print("文件打开失败->",fullFileName2) return false end
    
    local strFile2 = file2:read("*all")
    file2:close()
    if strFile1 ~= strFile2 then
        print(fileName1 .."<-不相同->"..fileName2)
        CMWriteFile(fileName1,strFile1,nil,true)
    end

end
