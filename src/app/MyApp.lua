
require("config")
require("cocos.init")
require("framework.init")
require("framework.cc.init")

GDIFROOTRES         = "scene/"
local MyApp = class("MyApp", cc.mvc.AppBase)
function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()   
    cc.FileUtils:getInstance():createDirectory(device.writablePath.."update/res/")
    cc.FileUtils:getInstance():createDirectory(device.writablePath.."update/src/")
    cc.FileUtils:getInstance():addSearchPath(device.writablePath.."update/res/")
    self:addSearchPath()
    self:setAdaptPlatform()
    self:loadPatches()
    require("app.GUI.GameSceneManager")
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
    -- require("app.Component.CMCommon")
    -- GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomView)
end

--[[加载补丁包]]
function MyApp:loadPatches()
  
    require("app.VersionConfig")
    local localVersionNum = cc.FileUtils:getInstance():getStringFromFile("version.txt")
    if device.platform == "mac" then
        localVersionNum = cc.FileUtils:getInstance():getStringFromFile("../version.txt")
    end
    package.loaded["app.VersionConfig"] = nil


    local lfs = require"lfs"
    local path = device.writablePath.."update/src"
    local versionTable = {}

    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
            local vNum = string.gsub(file,".zip","")
            if tonumber(vNum) <= tonumber(localVersionNum) then
                --补丁比本地版本低,直接删除之
                require("app.Component.CMHandleDirectory")
                os.remove(path.."/"..file)
                CMRemoveDirectory(device.writablePath.."update/res/")
            else
                table.insert(versionTable,tonumber(vNum))
            end
        end
    end
    table.sort(versionTable)
    for k,v in pairs(versionTable) do
        local zipFileName = path.."/"..string.format("%.1f",v)..".zip"
        cc.LuaLoadChunksFromZIP(zipFileName)
    end
    require("app.VersionConfig")
end

--[[更新完成，进入游戏]]
function MyApp:start()
    -- 先加载所有补丁
    self:loadPatches()
    
    require("app.GUI.GameSceneManager")
    QManagerPlatform:onStart()
    -- self:InitLogin()
    -- 设置3D视角
    cc.Director:getInstance():setProjection(1)
    local scene = GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
    cc.Director:getInstance():setAnimationInterval(1/30)

    local MusicPlayer = require("app.Tools.MusicPlayer")
    MusicPlayer:getInstance():playBackgroundMusic()
end

--[[
    平台适配
]]
function MyApp:setAdaptPlatform()
   
    ------------
    local sharedDirector         = cc.Director:getInstance()
    local glview = sharedDirector:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("QuickCocos",
            cc.rect(0, 0, CONFIG_SCREEN_WIDTH or 960, CONFIG_SCREEN_HEIGHT or 640))
        sharedDirector:setOpenGLView(glview)
    end
    local size = glview:getFrameSize()
    if device.platform == "android" then 
        CONFIG_SCREEN_WIDTH = 1136 
        CONFIG_SCREEN_HEIGHT= 640
        GDIFROOTRES     = "scene1136/"
        CONFIG_TYPE     = cc.ResolutionPolicy.EXACT_FIT
        glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT,CONFIG_TYPE )
    else--if device.platform == "ios" then

        if size.width == 1024 or size.width == 2048 then
            CONFIG_SCREEN_WIDTH = 960 
            CONFIG_SCREEN_HEIGHT= 640
            GDIFROOTRES     = "scene/"  
        elseif size.width > 960 then
            CONFIG_SCREEN_WIDTH = 1136 
            CONFIG_SCREEN_HEIGHT= 640
            GDIFROOTRES     = "scene1136/"
        end
        display.cx      = CONFIG_SCREEN_WIDTH/2
        CONFIG_TYPE     = cc.ResolutionPolicy.SHOW_ALL
        glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT,CONFIG_TYPE )
    end

end
-- function MyApp:InitLogin()

-- end
function MyApp:onExit()
    print(1)
   require("app.Network.Socket.TcpCommandRequest")
   local tcpRequest = TcpCommandRequest:shareInstance()
   tcpRequest:closeConnect()
end

function MyApp:onEnterBackground()
    print("onEnterBackground")
    display.pause()
end

function MyApp:onEnterForeground()
    print("onEnterForeground")
    display.resume()
end

function MyApp:addSearchPath()
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/activity")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/chat")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/db_gold")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/db_poker")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/walcome")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/face")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/friend")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/gamescene")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/gameTech")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/hall")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/loadingscene")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/login")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/MainPage")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/more")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/notice")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/personalCenter")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/personFace")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/public")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/rank")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/reward")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/setting")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/shop")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/table")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/tourney")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/public/level")
    cc.FileUtils:getInstance():addSearchPath("res/picdata/public/vip")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/hall_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/loadingscene_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/login_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/loadingscene_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/MainPage_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/table_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/tourney_dif")
    cc.FileUtils:getInstance():addSearchPath("res/scene/picdata/setting_dif")
    cc.FileUtils:getInstance():addSearchPath("res/fonts")

    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/activity")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/chat")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/db_gold")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/db_poker")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/walcome")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/face")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/friend")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/gamescene")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/gameTech")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/hall")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/loadingscene")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/login")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/MainPage")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/more")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/notice")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/personalCenter")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/personFace")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/public")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/rank")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/reward")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/setting")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/shop")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/table")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/tourney")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/public/level")
    cc.FileUtils:getInstance():addSearchPath("update/res/picdata/public/vip")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/hall_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/loadingscene_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/login_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/loadingscene_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/MainPage_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/table_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/tourney_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/scene/picdata/setting_dif")
    cc.FileUtils:getInstance():addSearchPath("update/res/fonts")
    -- cc.FileUtils:getInstance():addSearchPath("src/")


end

return MyApp
