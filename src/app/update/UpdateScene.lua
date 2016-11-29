--- 更新模块
-- @module 更新模块
--

--package.loaded[ "app.update.UpdateScene"] = nil 
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
require("app.VersionConfig")
local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")
local scheduler = require("framework.scheduler")
local QManagerScheduler = require("app.Tools.QManagerScheduler"):getInstance({})
require("app.Tools.EStringTime")

local UpdateScene  = class("UpdateScene", function()
    return display.newScene("UpdateScene")    
end)
-- local CMLayer = require("app.Component.CMBaseLayer")
--添加测试按钮
local IsAddTestButton = false
-- local IsForceUpdate   = false    --是否需要整包强制更新
local NEEDUPDATE   = true       --是否需要更新
local DEBUG_UPDATE = false       --更新测试模式

if not G_RELEASE then
    IsAddTestButton = true
end

-- local server       = "http://120.24.214.146:7878/"
-- local versionFile  = "version/?fileVersion="
-- local allFileList  = "xinyuangong/res/download/"
-- local nowVersion   = string.sub(DBVersion,string.len(DBVersion)- 8,string.len(DBVersion))
local nowVersion   = string.gsub(DBVersion,"DeBao V","")
-- local bigVersion   = cc.UserDefault:getInstance():getStringForKey("VERSION_BIG")
local isUpdateSuc  = false
local screenClickFlag = false
local requestTimes = 0
local EnumMenu = 
{   
    eClose = 1,
    eOK    = 2,
    eBox   = 3,
}
function UpdateScene:ctor()
    self.path = device.writablePath
    -- local LoadingSceneLayer = require("app.GUI.LoadingSceneLayer"):new() 
    -- self.m_layer  = LoadingSceneLayer
    -- self:addChild(self.m_layer)
    -- self.progressLabel  = LoadingSceneLayer.hintLabel 
    -- self:newProgressTimer( "picdata/loadingscene/jdt_bg.png","picdata/loadingscene/jdt.png" )

    self.m_layer = require("app.architecture.loading.LoadingFragment").new() 
    self.m_layer:create()
    self.m_layer:addTo(self)
    self:newProgressTimer("picdata/loginNew/login/progress_login_bg.png", "picdata/loginNew/login/progress_login.png")

    self.progressLabel  = display.newTTFLabel({text = "检查更新中...", size = 26, align = cc.TEXT_ALIGN_CENTER, color = display.COLOR_WHITE}):pos(display.cx,110):addTo(self) 
    self.curVersionLabel   = display.newTTFLabel({text = string.format("当前版本:%s",nowVersion), size = 26, align = cc.TEXT_ALIGN_RIGHT, color = display.COLOR_WHITE}):pos(display.width - 160,80):addTo(self) 
    self.latestVersionLabel= display.newTTFLabel({text = string.format("最新版本:%s",""), size = 26, align = cc.TEXT_ALIGN_RIGHT, color = display.COLOR_WHITE}):pos(display.width - 160,40):addTo(self)
    self.progressLabel:setVisible(false)
    self.curVersionLabel:setVisible(false)
    self.latestVersionLabel:setVisible(false)
    -- if NEED_SPECIAL then
    --     self.curVersionLabel:setColor(cc.c3b(0,0,0))
    --     self.latestVersionLabel:setColor(cc.c3b(0,0,0))
    --     self.curVersionLabel:setPositionX(260)
    --     self.latestVersionLabel:setPositionX(260)
    -- end
    self:addKeyBackClicked()
end

function UpdateScene:onEnter()
    print("enter UpdateScene")
end

function UpdateScene:onEnterTransitionFinish()
    -- NEEDUPDATE = false
   if not NEEDUPDATE then
    print("当前版本为DEBUG版本，不需要更新！")
    self.progressLabel:setString("当前版本为DEBUG版本，不需要更新")
    -- self:performWithDelay(function (  )
        isUpdateSuc = true
        self:updateSuccess()
    -- end,1)
    return
    end

    self:requestLatestVersion()
end

---
-- [请求最新版本]
-- @return [无返回值]
--            
function UpdateScene:requestLatestVersion()
    self.progressLabel:setString("正在获取版本列表")
    if not NEEDUPDATE then       
        self.progressLabel:setString("当前版本为DEBUG版本，不需要更新")        
        return
    end
    local configIp
    local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
    local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
    if DEBUG_UPDATE then
        print("测试模式更新 ！")
        configIp = "http://debao.boss.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia_test.json"
    else
        configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia.json"
    end
    -- configIp = "http://192.168.23.111:3000/update"
    if DBAPKVersion then
        configIp = configIp .."&params[]=".. DBAPKVersion
    end
    self.progressTimer:setPercentage(0)
    local ac = cc.ProgressFromTo:create(10.0,0,90)
    self.progressTimer:runAction(ac)
    local request = network.createHTTPRequest(handler(self,self.requestCallBack),configIp, "POST")
    request:setTimeout(10)
    request:start()
end

---
-- [请求最新版本网络回调处理]
--
-- @param event [网络请求事件]
-- @return [无返回值]
--
function UpdateScene:requestCallBack(event)
    local sTips = ""
    if event.name == "progress" then
        screenClickFlag = true
        sTips = "正在获取版本列表"   
    elseif event.name == "completed" then
        sTips = "获取最新版本号"   
    elseif event.name == "failed" then
        sTips = "版本更新列表请求网络出错"   
    end
    if self.progressLabel then
        self.progressLabel:setString(sTips)
    end
    local ok = (event.name == "completed")
    local request = event.request
    if event.name then 
        --print("request event.name = " .. event.name) 
    end

    if event.name == "failed" then  
        -- if requestTimes > 3  then
        --     self.progressLabel:setString("网络请求失败,请检查网络并重启游戏") 
        --     return        
        -- end
        screenClickFlag = false 
        self.progressTimer:stopAllActions()
        self.progressLabel:setString("请求版本号失败,点击屏幕任意位置进行重新请求") 
        self.m_layer.m_loadingBg:setTouchEnabled(true)
        self.m_layer.m_loadingBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if screenClickFlag == false then

            local configIp
            local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
            local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
            if DEBUG_UPDATE then
                print("测试模式更新 ！")
                configIp = "http://debao.boss.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia_test.json"
            else
                configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia.json"
            end
            if DBAPKVersion then
                configIp = configIp .."&params[]=".. DBAPKVersion
            end
            -- dump(configIp)
            self.progressTimer:setPercentage(0)
            local ac = cc.ProgressFromTo:create(10.0,0,90)
            requestTimes = requestTimes + 1
            self.progressTimer:runAction(ac)
            local request = network.createHTTPRequest(handler(self,self.requestCallBack),configIp, "POST")
            request:setTimeout(10)
            request:start()
            screenClickFlag = true
    end
        return false
    end)
        -- self:endProcess()  
        return
    end

    if not ok and self.progressLabel then    
        self.progressLabel:setString("正在更新中.....") 

        return
    end
    local code = tonumber(request:getResponseStatusCode())

    if code ~= 200 then        
        self.progressLabel:setString("版本更新列表请求网络出错"..request:getResponseStatusCode())
        return
    end   
    -- local jsonStr = string.gsub(request:getResponseString(),"\"\"","\"")
    local needDownVersions = json.decode(request:getResponseString())
        -- local needDownVersions = json.decode(needDownVersions)
    if type(needDownVersions) ~= "table" then
        --todo 线下更新失败允许进入游戏,正式上线时去除 isUpdateSuc = true   for Android
        -- isUpdateSuc = true
        self:noUpdateStart()
        return
    end

    local status = needDownVersions.status 

    if status == 0 then
        self._latestVersion    = needDownVersions.version
        -- self.latestVersionLabel:setVisible(true)
        self.latestVersionLabel:setString(string.format("最新版本:%s",self._latestVersion))
        self.m_layer.hintLabel:setString("正在为您将版本更新为：DeBao V"..self._latestVersion)
    end
    
    -- if needDownVersions.code == 200 then
        if status == 2 then
            self.progressLabel:setString("当前版本已经是最新版本")
            self.curVersionLabel:setString(string.format("当前版本:%s",nowVersion))
            self._latestVersion = nowVersion
            isUpdateSuc = true
            self:updateSuccess()
        elseif status == 1 then
            self.progressTimer:stopAllActions()
            self.progressLabel:setString("您的版本过低,请及时更新")
            self:showVersionLower(needDownVersions.url,needDownVersions.IsForceUpdate)
            self.m_layer.m_loadingBg:setTouchEnabled(true)
            self.m_layer.m_loadingBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                self:showVersionLower(needDownVersions.url,1)
            end)
            return false            
        else
            self.needDownVersions = needDownVersions
            self.requestUrl = string.gsub(needDownVersions.url,".zip","-res.zip")
            self:getPatchFromServer(self.requestUrl)

            QManagerScheduler:insertLocalScheduler({layer = self,listener = function () self:onEnterFrame() end,interval = 1})
        end

end

---
-- [下载文件]
--
-- @param url [下载地址]
-- @return [无返回值]
--
function UpdateScene:getPatchFromServer(url)
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
---
-- [下载文件网络回调]
--
-- @param event [网络请求事件]
-- @param  index [预留参数]
-- @param  dumpResponse [预留参数]
-- @return [无返回值]
--
function UpdateScene:onResponse(event, index, dumpResponse)
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

---
-- [检查文件是否下载完成]
--
-- @param fileName [文件名]
-- @param  cryptoCode [加密码,预留参数,暂不使用]
--
-- @return [bool值,是否存在]
--
function UpdateScene:checkFile(fileName, cryptoCode)

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

---
-- [文件是否存在]
--
-- @param path [文件路径]
-- @return [文件内容]
--
function UpdateScene:readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

---
-- [下载文件检查定时器]
-- @return [无返回值]
--
function UpdateScene:onEnterFrame()
    if self.dataRecv ~= nil then
        if self.requestUrl == self.needDownVersions.url then
            
            --处理补丁文件流
            -- print("self.requestUrl"..string.sub(self._latestVersion,1,3))
            self.progressLabel:setString("开始下载补丁")

            local fn = device.writablePath.."update/src/"..string.sub(self._latestVersion,1,3)..".zip"
            io.writefile(fn, self.dataRecv)
            if self:checkFile(fn, nil) then
                self.progressTimer:stopAllActions()
                local ac = cc.ProgressFromTo:create(10.0,70,90)
                self.progressTimer:runAction(ac)
                cc.LuaLoadChunksFromZIP(fn)
                isUpdateSuc = true
                self:endProcess()
                return
            end           
        else
            --处理资源文件流
            local fn = device.writablePath.."res"..self._latestVersion..".zip"
                self.progressLabel:setString("开始下载资源")
            io.writefile(fn, self.dataRecv)
            if self:checkFile(fn, nil) then
                local updateDir = device.writablePath.."update/"
                local flag = cc.FileUtils:getInstance():uncompressDir(fn,updateDir)
                if flag then 
                    self.progressTimer:stopAllActions()
                    os.remove(fn)
                    local ac = cc.ProgressFromTo:create(10.0,30,90)
                    self.progressTimer:runAction(ac)
                    self.requestUrl = self.needDownVersions.url
                    self.dataRecv = nil
                    self:getPatchFromServer(self.requestUrl)
                end
                return
            end
        end
    end
end

---
-- [更新完成]
-- @return [无]
--
function UpdateScene:updateSuccess()
    QManagerScheduler:removeLocalScheduler({layer = self}) 
    if IsAddTestButton then
        self:addTestButton()
    else
        SERVER_ENVIROMENT = ENVIROMENT_NORMAL --ENVIROMENT_TEST ENVIROMENT_NORMAL
        require("app.MyApp").new():start()
    end
end

---
-- [切换线上线下按钮,显示相关]
-- @return [无]
--
function UpdateScene:addTestButton()
    cc.ui.UIPushButton.new("picdata/public/btn_1_110_green.png", {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "线上环境",
            size = 18
        }))
        :setButtonLabel("pressed", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "选择线上环境",
            size = 18,
            color = cc.c3b(255, 64, 64)
        }))
        :setButtonLabel("disabled", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "选择线上环境",
            size = 18,
            color = cc.c3b(0, 0, 0)
        }))
        :onButtonClicked(function(event)
           SERVER_ENVIROMENT = ENVIROMENT_NORMAL --ENVIROMENT_TEST ENVIROMENT_NORMAL
           require("app.MyApp").new():start()
            end)
            :align(display.CENTER, display.cx, display.cy + 80)
            :addTo(self)

            cc.ui.UIPushButton.new("picdata/public/btn_1_110_green.png", {scale9 = true})
            :setButtonSize(240, 60)
            :setButtonLabel("normal", cc.ui.UILabel.new({
                UILabelType = 2,
                text = "测试环境",
                size = 18
            }))
            :setButtonLabel("pressed", cc.ui.UILabel.new({
                UILabelType = 2,
                text = "选择测试环境",
                size = 18,
                color = cc.c3b(255, 64, 64)
            }))
            :setButtonLabel("disabled", cc.ui.UILabel.new({
                UILabelType = 2,
                text = "选择测试环境",
                size = 18,
                color = cc.c3b(0, 0, 0)
            }))
            :onButtonClicked(function(event)
                require("app.GlobalConfig")
                SERVER_ENVIROMENT = ENVIROMENT_TEST --ENVIROMENT_TEST ENVIROMENT_NORMAL
                require("app.MyApp").new():start()
            end)
            :align(display.CENTER, display.cx, display.cy - 80)
            :addTo(self)
end

---
-- [结束更新,进入游戏or重新请求]
-- @return [无]
--
function UpdateScene:endProcess()
-- self:removeNodeEventListener(cc.NODE_ENTER_FRAME_EVENT)
-- self:unscheduleUpdate()

if isUpdateSuc then
        -- local vFile = io.open(device.writablePath.."update/version.txt","w")
        -- vFile:write("DeBao V"..self._latestVersion)
        -- vFile:close()

    self.progressTimer:stopAllActions()
    self.progressTimer:setPercentage(100)
    self.progressLabel:setString("下载更新完成,即将进入游戏")
    self.curVersionLabel:setString(string.format("当前版本:%s",self._latestVersion or nowVersion))

    local tmpChannel = string.sub(self._latestVersion,string.len(self._latestVersion)- 4,string.len(self._latestVersion))
    local tmpVersion = string.gsub(self._latestVersion,"."..self._latestVersion,"")
    -- dump(tmpChannel,tmpVersion)
    if DEBUG_UPDATE then
        print("测试模式更新 ！")
        configIp = "http://debao.boss.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia_test.json"
    else
        configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia.json"
    end
    if DBAPKVersion then
        configIp = configIp .."&params[]=".. DBAPKVersion
    end
    -- configIp = "http://192.168.23.111:3000/update"
    self.progressTimer:setPercentage(0)
    local ac = cc.ProgressFromTo:create(10.0,0,90)
    self.progressTimer:runAction(ac)
    local request = network.createHTTPRequest(handler(self,self.requestCallBack),configIp, "POST")
    request:setTimeout(10)
    request:start()

    
else
    QManagerScheduler:removeLocalScheduler({layer = self}) 

    self.progressTimer:stopAllActions()
    self.progressLabel:setString("下载更新失败,请检查网络,点击屏幕任意位置进行重新请求") 
    -- self.m_layer.m_loadingBg:setTouchEnabled(true)

         
        self.progressTimer:stopAllActions()
        self.progressLabel:setString("请求版本号失败,点击屏幕任意位置进行重新请求") 
        self.m_layer.m_loadingBg:setTouchEnabled(true)
        self.m_layer.m_loadingBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            local configIp
            local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
            local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
            if DEBUG_UPDATE then
                print("测试模式更新 ！")
                configIp = "http://debao.boss.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia_test.json"
            else
                configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia.json"
            end
            if DBAPKVersion then
                configIp = configIp .."&params[]=".. DBAPKVersion
            end
            self.progressTimer:setPercentage(0)
            local ac = cc.ProgressFromTo:create(10.0,0,90)
            self.progressTimer:runAction(ac)
            local request = network.createHTTPRequest(handler(self,self.requestCallBack),configIp, "POST")
            request:setTimeout(10)
            request:start()
        return false
    end)

    -- self.m_layer.m_loadingBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    -- local configIp
    -- local tmpChannel = string.sub(nowVersion,string.len(nowVersion)- 4,string.len(nowVersion))
    -- local tmpVersion = string.gsub(nowVersion,"."..tmpChannel,"")
    -- if DEBUG_UPDATE then
    --     print("测试模式更新 ！")
    --     configIp = "http://debao.boss.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia_test.json"
    -- else
    --     configIp = "http://www.debao.com/service/router.php?method=Version/GetLatest&params[]="..tmpVersion.."&params[]="..tmpChannel--"http://120.24.214.146:7878/xinyuangong/res/download/ClientConfig/address_qunxia.json"
    -- end
    -- self.progressTimer:setPercentage(0)
    -- local ac = cc.ProgressFromTo:create(10.0,0,90)
    -- self.progressTimer:runAction(ac)
    -- local request = network.createHTTPRequest(handler(self,self.requestCallBack),configIp, "POST")
    -- request:setTimeout(10)
    -- request:start()
    -- self.m_layer.m_loadingBg:removeTouchEvent()
    --     return false
    -- end)
end

end


---
-- [废弃方法,不再使用]
--
-- @return [无]
--
function UpdateScene:comPareVersion(_nowVersion,_compVersion)    
    local nowList  = string.split(_nowVersion,".")
    local compList = string.split(_compVersion,".")

    --print(nowList[1].."--"..compList[1])
    if tonumber(nowList[1]) < tonumber(compList[1]) then
        print("大版本号不同")
        return true
    else
                
    end   
    --print(nowList[2].."--"..compList[2])
    if tonumber(nowList[2]) < tonumber(compList[2]) then 
        print("中版本号不同")
        return true
    else     
        
    end

    --预留
    if tonumber(nowList[3]) < tonumber(compList[3]) then
        print("小版本号不同") 
        return true
    else
          
    end
    return false
end
---
-- [废弃方法,不再使用]
--
-- @return [无]
--
function UpdateScene:checkVersion(_latestVersion)
    --local nowVersion   = cc.UserDefault:getInstance():getStringForKey("current-version-codezd")
     if string.len(nowVersion) == 0 then
        nowVersion = "1.0.0"
        cc.UserDefault:getInstance():setStringForKey("current-version-codezd",nowVersion)
    end

    if nowVersion == _latestVersion then 
        return true
    else
        return false
    end
end
---
-- [废弃方法,不再使用]
--
-- @return [无]
--
function UpdateScene:afterUpdateStart()
    if self.needRestart then
        print("提示需要重新启动游戏")
        require("game")
        game.exit()
        return
    end
    print("更新成功，启动游戏")

    -- package.loaded["config"] = nil
    -- CCLuaLoadChunksFromZIP("game.zip")
    -- require("game")
    -- game.startup()
end

---
-- [没有更新或更新完执行]
--
-- @return [无]
--
function UpdateScene:noUpdateStart()
    --dump("没有更新或者更新失败启动游戏")
    -- require("game")
    -- CCLuaLoadChunksFromZIP("game.zip")
    -- game.startup()
    -- QManagerScene = require("app.manager.QManagerScene")
    -- QManagerScene:StartGame()
    -- if NEEDUPDATE then
    --     QManagerScene = require("app.manager.QManagerScene"):getInstance({sceneId = 1})
    -- else
    --     QManagerScene = require("app.manager.QManagerScene"):getInstance({sceneId = 1})
    -- end   
    self:endProcess()
end
---
-- [创建下载目录]
--
-- @param path [路径]
-- @return [无]
--
function UpdateScene:createDownPath(path)
    if not self:checkDirOK(path) then
        print("更新目录创建失败，直接开始游戏")
        self:noUpdateStart()
        return
    else
        --print("更新目录存在或创建成功")
    end
end

---
-- [检查目录是否存在]
--
-- @param path [description]
-- @return [description]
--
function UpdateScene:checkDirOK(path)
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

---
-- [更新进度条]
--
-- @param  bgBarImg [进度条底图]
-- @param progressBarImg  [进度条图]
--
-- @return [description]
--
function UpdateScene:newProgressTimer( bgBarImg,progressBarImg ) 
    local prebg = display.newSprite(bgBarImg)
    prebg:setPosition(cc.p(display.cx,150))
    self:addChild(prebg)

    local pro = cc.Sprite:create(progressBarImg)
    local progress = cc.ProgressTimer:create(pro)   
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)    
    progress:setBarChangeRate(cc.p(1, 0))      
    progress:setMidpoint(cc.p(0,1)) 
    progress:setPercentage(0)      
    progress:setPosition(cc.p(display.cx,150))     
    self:addChild(progress) 
    self.progressTimer = progress
end

---
-- [更新进度条动画]
--
-- @param  progressTimer [进度条]
-- @param fromPercentage [进度]
-- @param toPercentage [需要达到进度]
-- @param duration  [持续时间]
-- @return [无]
--
function UpdateScene:progressTimerAction( progressTimer,fromPercentage,toPercentage,duration )
    if not duration then duration = 0.3 end
    local ac = CCProgressFromTo:create(duration,fromPercentage,toPercentage)
    progressTimer:runAction(ac)
end

---
-- [删除目录方法]
--
-- @param path [路径]
-- @return [无]
--
function UpdateScene:delAllFilesInDirectory( path)
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
---
-- [添加Android返回键监听]
-- @return [无]
--
function UpdateScene:addKeyBackClicked()
    -- if device.platform == "android" then
        self:setKeypadEnabled(true) 
        self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
            if event.key == "back" then
                if self.mLayer then 
                    self.mLayer:removeFromParent()
                    self.mLayer = nil
                else
                    self:showExitGame()
                end
            end
        end)
    -- end 
end
---
-- [退出游戏弹窗]
--
-- @return [无]
--
function UpdateScene:showExitGame()
    if self.mLayer then self.mLayer:removeFromParent() self.mLayer = nil end
    local layer = cc.Layer:create()
    self:addChild(layer,10)
    self.mLayer = layer

    local bg = cc.Sprite:create("picdata/public/alertBG.png")
    bgWidth = bg:getContentSize().width
    bgHeight= bg:getContentSize().height
    self.mSize = cc.size(bgWidth - 100,bgHeight-100)
    bg:setPosition(display.cx,display.cy)
    self.mLayer:addChild(bg)

    local title = cc.ui.UILabel.new({
        color = cc.c3b(255, 228, 173),
        text  = "温馨提示",
        size  = 36,
        font  = "font/FZZCHJW--GB1-0.TTF",
       -- UILabelType = 1,
    })
    title:setPosition(bgWidth/2-title:getContentSize().width/2,bgHeight - 50)
    bg:addChild(title)
    local sTip = cc.ui.UILabel.new({text = "确定要退出游戏？",color = cc.c3b(255,255,255),size = 28,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(bgWidth - 80, 0)})  
    sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2+10,270 - sTip:getContentSize().height/2)
    bg:addChild(sTip,0)

    local btnClose = cc.ui.UIPushButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"})
        :onButtonClicked(function(event)
           self.mLayer:removeFromParent()
           self.mLayer = nil
            end)
            :align(display.CENTER, bgWidth-20,bgHeight - 20)
            :addTo(bg)
    local btnClose = cc.ui.UIPushButton.new({normal = "picdata/public/cancelBtn.png",pressed = "picdata/public/cancelBtn2.png"})
        :setButtonLabel("normal",cc.ui.UILabel.new({
        --UILabelType = 1,
        color = cc.c3b(156, 255, 0),
        text = "取消",
        size = 28,
        font = "FZZCHJW--GB1-0",
        }) )  
        :onButtonClicked(function(event)
            self.mLayer:removeFromParent()
           self.mLayer = nil
        end)
        :align(display.CENTER, bgWidth/2-140, 60)
        :addTo(bg)

    local btnExit = cc.ui.UIPushButton.new({normal = "picdata/public/confirmBtn.png",pressed = "picdata/public/confirmBtn2.png"})
        :setButtonLabel("normal",cc.ui.UILabel.new({
        --UILabelType = 1,
        color = cc.c3b(156, 255, 0),
        text = "退出",
        size = 28,
        font = "FZZCHJW--GB1-0",
        }) )  
        :onButtonClicked(function(event)
           os.exit()
        end)
        :align(display.CENTER, bgWidth/2+140, 60)
        :addTo(bg)
end

function UpdateScene:onExit()
    QManagerScheduler:removeLocalScheduler({layer = self})
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function UpdateScene:showVersionLower(url,IsForceUpdate)
    if self.mVersionBg then self.mVersionBg:removeFromParent() end
    local showType = 1
    if IsForceUpdate and tonumber(IsForceUpdate) == 0 then
        showType = 2
    end
    local params = {
        text = "德堡德州扑克4.0版本震撼来袭，诚邀您下载至最新版本！\n1.新增语音功能，聊天玩牌两不误\n前往德堡主站：www.debao.com或者应用商店下载最新版本",
        showType = showType,okText = "确认",titleText = "温馨提示",showBox = false,scroll= true,showLine=0,
        callOk = function (isSelect) 
            if self.mVersionBg then 
                self.mVersionBg:removeFromParent()
                self.mVersionBg = nil
            end
            -- 全包下载   跳转出浏览器
            -- 跳出之前先删除update文件夹
            require("app.Component.CMHandleDirectory")
            CMRemoveDirectory(device.writablePath.."update/")
            local qMP = require("app.Tools.QManagerPlatform")
            qMP:jumpToUpdate(url)
        end,
        callCancle = function ()
            if self.mVersionBg then 
                self.mVersionBg:removeFromParent()
                self.mVersionBg = nil
            end
            self:updateSuccess()
        end
        }
    self.mVersionBg = self:showTipBox(params)
    self:addChild(self.mVersionBg)
end
function UpdateScene:showTipBox(params) 
    self.ShowNone= 0    --不显示按钮
    self.ShowOk  = 1    --确定   
    self.ShowAll = 2    --确定，取消 
    self.params = params or {}  
    self.params.showType = self.params.showType or self.ShowOk  
    self.params.scroll    = self.params.scroll

    local size = cc.size(702,488) 
    local bg = cc.ui.UIImage.new("picdata/fightteam/bg_tc.png", {scale9 = true})
    bg:setLayoutSize(size.width,size.height)
    bg:setPosition(display.cx-size.width/2,display.cy-size.height/2+12)

    local bgWidth = bg:getContentSize().width
    local bgHeight= bg:getContentSize().height


    local size = cc.size(644,292)
    local secBg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    secBg:setLayoutSize(size.width,size.height)
    secBg:setPosition(bgWidth/2-size.width/2,bgHeight/2-130)
    bg:addChild(secBg)

    local title = cc.Sprite:create("picdata/public/w_title_bbgx.png")
    title:setPosition(bgWidth/2,bgHeight - 50)
    bg:addChild(title)


    
    local fontSize = 28
    local fontName = "黑体"

    if self.params.showType == self.ShowNone then
    elseif self.params.showType == self.ShowOk  then
        local btnOk = cc.ui.UIPushButton.new({normal = "picdata/public/btn_yes.png",pressed = "picdata/public/btn_yes2.png"}) 
        :onButtonClicked(function(event)
           self:menuCallBack(EnumMenu.eOK)
        end)
        :align(display.CENTER, bgWidth/2, 60)
        :addTo(bg)
    else

        local btnOk = cc.ui.UIPushButton.new({normal = "picdata/public/btn_yes.png",pressed = "picdata/public/btn_yes2.png"})
        :onButtonClicked(function(event)
           self:menuCallBack(EnumMenu.eOK)
        end)
        :align(display.CENTER, bgWidth/2+140, 60)
        :addTo(bg)

        local btnCancel = cc.ui.UIPushButton.new({normal = "picdata/public/btn_no.png",pressed = "picdata/public/btn_no2.png"})
        :onButtonClicked(function(event)
           self:menuCallBack(EnumMenu.eClose)
        end)
        :align(display.CENTER, bgWidth/2- 140, 60)
        :addTo(bg)

    end

    if not self.params.scroll then
        local index = string.find(self.params.text,"#%d")
        local sTip = cc.ui.UILabel.new({text = self.params.text or "",color = cc.c3b(255,255,255),size = fontSize,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(bgWidth - 80, 0)})      
        sTip:setPosition(bgWidth/2-sTip:getContentSize().width/2+10,270 - sTip:getContentSize().height/2)
        bg:addChild(sTip,0)
    else
        if type(self.params.text) == "table"  then
            local bound = {x = 40, y = 40, width = bgWidth- 80, height = 230} 
            self.mList  = cc.ui.UIListView.new {
            --bgColor = cc.c4b(200, 200, 200, 120),
            viewRect = cc.rect(bound.x,bound.y,bound.width,bound.height),       
            async   = true,
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
            :onTouch(handler(self, self.touchListener))
            :addTo(bg)   

            self.mList:setDelegate(handler(self, self.sourceDelegate))
            self.mList:reload() 
        else
            local bound = {x = 40, y = 120, width = bgWidth- 80, height = 275} 
            if self.params.showType == 0 then
                bound.height = 230
                bound.y      = 45
            end
                
             local node = cc.Node:create()
             node:setContentSize(bound.width,bound.height)

            local sTip = cc.ui.UILabel.new({text = self.params.text,color = cc.c3b(255,255,255),size = 24,textAlign = cc.TEXT_ALIGNMENT_LEFT,dimensions = cc.size(bgWidth - 80, 0)})    
            sTip:setPosition(bound.x,bound.y+bound.height/2-10)
            node:addChild(sTip)
            local item = cc.ui.UIScrollView.new({
                direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
                viewRect = bound, 
               -- scrollbarImgH = "scroll/barH.png",
               -- scrollbarImgV = "scroll/bar.png",
               -- bgColor = cc.c4b(125,125,125,125)
            })
            :addScrollNode(node)
            --:onScroll(function (event)
               -- print("ScrollListener:" .. event.name)
            --end) --注册scroll监听
            :addTo(bg)
            item:getScrollNode():setPosition(0,bound.height/2-sTip:getContentSize().height/2+2)
        end
    end

    return bg
end
--[[
    按钮回调
]]
function UpdateScene:menuCallBack(_tag)
    if _tag == EnumMenu.eOK then
        if self.params.callOk then 
            self.params.callOk(self.mIsSelectBox)
        end                 
    elseif _tag == EnumMenu.eClose then         
        if self.params.callCancle then 
            self.params.callCancle(self.mIsSelectBox)           
        end 
    end
    if self then
        GIsClose = false
        self:removeFromParent()
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

return UpdateScene