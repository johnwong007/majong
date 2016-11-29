
local scheduler = require("framework.scheduler")
local QManagerScheduler = require("app.Tools.QManagerScheduler"):getInstance({})

local HINT_NOT_NEED_UPDATE = "当前版本为DEBUG版本，不需要更新"
local HINT_UPDATE_FINISH = "下载更新完成,即将进入游戏"
local HINT_DOWNLOAD_FAILED = "下载更新失败,请检查网络,点击屏幕任意位置进行重新请求"
local HINT_GET_VERSION_FAILED = "请求版本号失败,点击屏幕任意位置进行重新请求"
local HINT_GET_VERSION_ING = "正在获取版本列表"
local HINT_GET_VERSION_SUCCESS = "获取最新版本号"
local HINT_GET_VERSION_NO_NETWORK = "版本更新列表请求网络出错"
local HINT_CHECK_NET_AND_RESTART = "网络请求失败,请检查网络并重启游戏"
local HINT_UPDATE_ING = "正在更新中....."
local HINT_IS_LATEST_VERSION = "当前版本已经是最新版本"
local HINT_NEED_UPDATE = "您的版本过低,点击屏幕将跳转更新"

local NEEDUPDATE = true       --是否需要更新
local DEBUG_UPDATE = false       --更新测试模式
local nowVersion   = string.sub(DBVersion,string.len(DBVersion)- 8,string.len(DBVersion))
local screenClickFlag = false
local requestTimes = 0

local UpdateLogic  = class("UpdateLogic", function()
    return display.newScene("UpdateLogic")    
end)

function UpdateLogic:ctor(params)
 	self.m_pCallbackUI = params.callback
    self:setNodeEventEnabled(true)
end

function UpdateLogic:onExit()
    QManagerScheduler:removeLocalScheduler({layer = self})
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function UpdateLogic:onEnter()

end

function UpdateLogic:onEnterTransitionFinish()
	if not NEEDUPDATE then
		self.m_pCallbackUI:setProgressLabel(HINT_NOT_NEED_UPDATE)
		isUpdateSuc = true
		self:noUpdateStart()
		return
    end
    self:requestLatestVersion()
end

--【【没有更新或更新完执行】】
function UpdateLogic:noUpdateStart()
    self:endProcess()
end

--[[结束更新，超时重新请求]]
function UpdateLogic:endProcess()
	if isUpdateSuc then
    	local tmpChannel = string.sub(self._latestVersion,string.len(self._latestVersion)- 4,string.len(self._latestVersion))
    	local tmpVersion = string.gsub(self._latestVersion,"."..self._latestVersion,"")
    	self:getLatestVersion(tmpChannel, tmpVersion)
	else
    	QManagerScheduler:removeLocalScheduler({layer = self}) 

    	self:setTouchEnabled(true)
        self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        	self.m_pCallbackUI:progressTimerAnimate()
            local configIp
            local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
            local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
    		self:getLatestVersion(tmpChannel, tmpVersion)
        	return false
    	end)
	end
end

--【【获取最新版本号】】            
function UpdateLogic:getLatestVersion(channel, version)
	local tmpChannel = channel
    local tmpVersion = version
    if DEBUG_UPDATE then
        configIp = "http://debao.boss.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia_test.json"
    else
        configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia.json"
    end
    local request = network.createHTTPRequest(handler(self,self.requestCallBack),configIp, "POST")
    request:setTimeout(10)
    request:start()
end

--【【请求版本号】】            
function UpdateLogic:requestLatestVersion()
    self.m_pCallbackUI:setProgressLabel(HINT_GET_VERSION_ING)
    if not NEEDUPDATE then       
    	self.m_pCallbackUI:setProgressLabel(HINT_NOT_NEED_UPDATE)       
        return
    end

    self.m_pCallbackUI:progressTimerAnimate()

    local configIp
    local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
    local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
    self:getLatestVersion(tmpChannel, tmpVersion)
end

--【【版本号请求回调】】
function UpdateLogic:requestCallBack(event)
    local sTips = ""
    if event.name == "progress" then
        screenClickFlag = true
        sTips = HINT_GET_VERSION_ING
    elseif event.name == "completed" then
        sTips = HINT_GET_VERSION_SUCCESS
    elseif event.name == "failed" then
        sTips = HINT_GET_VERSION_NO_NETWORK  
    end
    self.m_pCallbackUI:setProgressLabel(sTips)

    local ok = (event.name == "completed")
    local request = event.request
    if event.name == "failed" then  
        if requestTimes > 3  then
    		-- self.m_pCallbackUI:setProgressLabel(HINT_CHECK_NET_AND_RESTART)
            -- return        
        end
        screenClickFlag = false 
        self.m_pCallbackUI:stopProgressTimerAnimation()
        self.m_pCallbackUI:setProgressLabel(HINT_GET_VERSION_FAILED) 
        self:setTouchEnabled(true)
        self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        	if screenClickFlag == false then
	            local configIp
	            local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
	            local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
    			self.m_pCallbackUI:progressTimerAnimate()
	            requestTimes = requestTimes + 1
    			self:getLatestVersion(tmpChannel, tmpVersion)
	            screenClickFlag = true
    		end
        	return false
    	end)
    
        return
    end

    if not ok then    
        self.m_pCallbackUI:setProgressLabel(HINT_UPDATE_ING) 
        return
    end


    local code = tonumber(request:getResponseStatusCode())

    if code ~= 200 then        
        self.m_pCallbackUI:setProgressLabel(HINT_GET_VERSION_NO_NETWORK..request:getResponseStatusCode())     
        return
    end   
   
    local needDownVersions = json.decode(request:getResponseString())

    if type(needDownVersions) ~= "table" then
        self:noUpdateStart()
        return
    end

    local status = needDownVersions.status 
    if status == 0 then
        self._latestVersion    = needDownVersions.version
        self.m_pCallbackUI:setLatestVersionLabelVisible(true)
        self.m_pCallbackUI:setLatestVersionLabelString(string.format("最新版本:%s",self._latestVersion))
    end
    
        if status == 2 then
        	self.m_pCallbackUI:setProgressLabel(HINT_IS_LATEST_VERSION)
        	self.m_pCallbackUI:setCurVersionLabelString(string.format("当前版本:%s",nowVersion))
            self._latestVersion = nowVersion
            isUpdateSuc = true
            self:updateSuccess()
        elseif status == 1 then
-- 全包下载   跳转出浏览器
-- 跳出之前先删除update文件夹
			self.m_pCallbackUI:stopProgressTimerAnimation()
        	self.m_pCallbackUI:setProgressLabel(HINT_NEED_UPDATE)
            self:setTouchEnabled(true)
            self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            require("app.Component.CMHandleDirectory")
            CMRemoveDirectory(device.writablePath.."update/")
            local qMP = require("app.Tools.QManagerPlatform")
            qMP:jumpToUpdate(needDownVersions.url)
            return false
            end)
            
        else
            self.needDownVersions = needDownVersions
            self.requestUrl = string.gsub(needDownVersions.url,".zip","-res.zip")
            self:getPatchFromServer(self.requestUrl)

            QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:onEnterFrame() end,interval = 1})
        end
end

--[[更新完成]]
function UpdateLogic:updateSuccess()
    QManagerScheduler:removeLocalScheduler({layer = self}) 
    self.m_pCallbackUI:updateSuccess()
end

--[[检查补丁是否下载完成]]
function UpdateLogic:onEnterFrame()

    if self.dataRecv ~= nil then
        if self.requestUrl == self.needDownVersions.url then
            --处理补丁文件流
            self.m_pCallbackUI:setProgressLabel("开始下载补丁")

            local fn = device.writablePath.."update/src/"..string.sub(self._latestVersion,1,3)..".zip"
            io.writefile(fn, self.dataRecv)
            if self:checkFile(fn, nil) then
				self.m_pCallbackUI:stopProgressTimerAnimation()
    			self.m_pCallbackUI:progressTimerAnimate()

                cc.LuaLoadChunksFromZIP(fn)
                isUpdateSuc = true
                self:endProcess()
                return
            end           
        else
            --处理资源文件流
            local fn = device.writablePath.."res"..self._latestVersion..".zip"
            self.m_pCallbackUI:setProgressLabel("开始下载资源")
            io.writefile(fn, self.dataRecv)
            if self:checkFile(fn, nil) then
                local updateDir = device.writablePath.."update/"
                local flag = cc.FileUtils:getInstance():uncompressDir(fn,updateDir)
                if flag then 
					self.m_pCallbackUI:stopProgressTimerAnimation()
                    os.remove(fn)
    				self.m_pCallbackUI:progressTimerAnimate()
                    self.requestUrl = self.needDownVersions.url
                    self.dataRecv = nil
                    self:getPatchFromServer(self.requestUrl)
                end
                return
            end
        end
    end
end

--[[下载补丁]]
function UpdateLogic:getPatchFromServer(url)
    -- local url = self.requestUrl
    local request = network.createHTTPRequest(function(event)
        self:onResponse(event, index)
        end, url, "GET")

    if request then
        request:setTimeout(waittime or 600)
        request:start()
    else
        self:endProcess()
    end
end

function UpdateLogic:onResponse(event, index, dumpResponse)
    local request = event.request


    if event.name == "completed" then
        if request:getResponseStatusCode() ~= 200 then
            --todo 线下更新失败允许进入游戏,正式上线时去除 isUpdateSuc = true   for Android
            -- isUpdateSuc = true
            self:endProcess()
        else
            self.dataRecv = request:getResponseData()
        end
    elseif event.name == "progress" then
            --todo 线下更新失败允许进入游戏,正式上线时去除 isUpdateSuc = true   for Android
    elseif event.name ~= "progress" then
            -- isUpdateSuc = true
            self:endProcess()
    end
end

--【【创建下载目录】】
function UpdateLogic:createDownPath( path )
    if not self:checkDirOK(path) then
        print("更新目录创建失败，直接开始游戏")
        self:noUpdateStart()
        return
    else
        --print("更新目录存在或创建成功")
    end
end

--【【检查目录是否存在】】
function UpdateLogic:checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        return true
    end
    if lfs.mkdir(path) then
        return true
    end
end

--[[判断补丁包是否下载完成]]
function UpdateLogic:checkFile(fileName, cryptoCode)

    if not cc.FileUtils:getInstance():isFileExist(fileName) then
        return false
    end

    local data=self:readFile(fileName)
    if data==nil then
        return false
    end

    if cryptoCode==nil then
        return true
    end

    local ms = crypto.md5(hex(data))
    if ms==cryptoCode then
        return true
    end

    return false
end

--[[文件是否存在]]
function UpdateLogic:readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

--【【删除所有目录】】
function UpdateLogic:delAllFilesInDirectory( path )
    print(path)
    for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
          local f = path..'/'..file
          local attr = lfs.attributes (f)
          assert (type(attr) == "table")
          if attr.mode == "directory" then
              self:delAllFilesInDirectory (f)
          else
              os.remove(f)
          end
      end
    end
end

string.startWith = function(str,strStart)
    local a,_ = string.find(str,strStart)
    return a==1
end


string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
return UpdateLogic