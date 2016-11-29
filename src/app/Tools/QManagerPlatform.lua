--
-- Author: junjie
-- Date: 2015-12-22 17:20:44
--
--平台管理
--luaJ返回错误代码解释:
-- 错误代码    描述
-- -1  不支持的参数类型或返回值类型
-- -2  无效的签名
-- -3  没有找到指定的方法
-- -4  Java 方法执行时抛出了异常
-- -5  Java 虚拟机出错
-- -6  Java 虚拟机出错

local QManagerPlatform = {}
QManagerPlatform.mAllLayer = {}
--TalkData
--[[
    talkingData统计用
]]
QManagerPlatform.EOnEventWhere = 
{
    eOnEventShopRecharge = "商城",
    eOnEventQuickRecharge= "快速充值",
    eOnEventOtherRecharge= "其它充值方式",
    eOnEventUnkowRecharge= 3,
}
QManagerPlatform.EOnEventActionType = 
{
    eOnEventActionOpenShop = "打开商城",
    eOnEventActionClickItem= "选择商品",
    eOnEventActionSelectedChannel = "选择充值方式",
    eOnEventActionRechargeSuc = "充值成功",
}

QManagerPlatform.TDCCAccountType =
{
    kAccountAnonymous = 0,
    kAccountRegistered = 1,
    kAccountSianWeibo = 2,
    kAccountQQ = 3,
    kAccountTencentWeibo = 4,
    kAccountND91 = 5,
    kAccountType1 = 11,
    kAccountType2 = 12,
    kAccountType3 = 13,
    kAccountType4 = 14,
    kAccountType5 = 15,
    kAccountType6 = 16,
    kAccountType7 = 17,
    kAccountType8 = 18,
    kAccountType9 = 19,
    kAccountType10 = 20
}

local myInfo = require("app.Model.Login.MyInfo")
require("app.LangStringDefine")
require("app.CommonDataDefine.CommonDataDefine")

local IOSCLASSNAME    = "ManagerPlatform"
local TALKINGDATANAME = "TalkingGameAnalytics"
local JNI_JAVACLASSNAME = ""
if TRUNK_VERSION == DEBAO_TRUNK then
      JNI_JAVACLASSNAME = "com/debao/texaspoker/DebaoPokerBase"
else
      JNI_JAVACLASSNAME = "org/gktk/debao/DebaoPokerBase"
end

function QManagerPlatform:new(_params)
    _params = _params or {}
    setmetatable(_params,self)
    self.__index = self    
    return _params
end

function QManagerPlatform:getInstance(_params)
    if self.instance == nil then       
        self.instance = self:new(_params)
    end
    return self.instance    
end

--[[
    上传头像
]]
function QManagerPlatform:showPickHeadImage(data)
	if device.platform == "android" then   
        local methodName ="showPickHeadImage"
        local args       = {myInfo.data.userId,UPLOAD_URL,data.callback}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
	elseif device.platform == "ios" then
        local methodName = "uerPickHeadImage"
        local args       = {userId = myInfo.data.userId,callback = data.callback,url = UPLOAD_URL}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
	end
end
--[[
    融云初始化
]]
function QManagerPlatform:initRongCloud(data)
    if device.platform == "ios" then
        local methodName = "initWithAppKeyAndUid"
        local args       = {AppKey = data.AppKey,Token = data.Token,UserId = data.UserId,Username = data.Username ,UserPotraitUri = data.UserPotraitUri}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName ="initWithAppKeyAndUid"
        local content    = json.encode(data)
        local args       = {content}
        local sig        = "(Ljava/lang/String;)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    进入聊天室
    ios:战队聊天室和语音聊天室室分开写的
    android:战队聊天室和语音聊天室室一样的
]]
function QManagerPlatform:enterChatRoom(data)
    if device.platform == "ios" then
        local methodName = "enterChatRoom"
        local args       = {TargetId = data.TargetId,callBack = data.callBack,messageCount = data.messageCount or 1}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        GChatText = {}
        local newData = {}
        newData.targetId = data.TargetId
        newData.messageCount = data.messageCount or 1
        newData.callBack = data.callBack or function (data) dump(data)  end
        QManagerPlatform:enterClub(newData)
    end
end
--[[
    退出聊天室
]]
function QManagerPlatform:quitChatRoom(data)
    if device.platform == "ios" then
        QManagerPlatform:stopAllPlayAudio()
        local methodName = "quitChatRoom"
        local args       = {TargetId = data.TargetId}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        QManagerPlatform:stopAllPlayAudio()
        QManagerPlatform:quitClubRoom(data)
    end
end
--[[
    录制完语音发送。。。
]]
function QManagerPlatform:stopClubRecord(data)
    if device.platform == "ios" then
        local methodName = "stopRecord"
        data.userId      = string.format("%s#%s",data.userId or "",data.fromWhere or "")
        local args       = {TargetId = data.TargetId,UserId = data.userId,Callback = data.callBack}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "stopRecord"
        data.userId      = string.format("%s#%s",data.userId or "",data.fromWhere or "")      --拓展数据，做字符拼接，修改语音来自牌桌
        local tempData   = {TargetId = data.TargetId,UserId = data.userId,duration = data.duration}
        local content    = json.encode(tempData)
        local args       = {content,data.callBack}
        local sig        = "(Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    取消录音
]]
function QManagerPlatform:cancelClubRecord(data)
    if device.platform == "ios" then
        local methodName = "cancelRecord"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "cancelRecord"
        local args       = {}
        local sig        = "()V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    开始录音
]]
function QManagerPlatform:startClubRecord(data)
    if device.platform == "ios" then
        local methodName = "startRecord"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "startRecord"
        local args       = {}
        local sig        = "()V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    进入战队聊天室
]]
function QManagerPlatform:enterClub(data)
    if device.platform == "ios" then
        local methodName = "enterClubRoom"
        local args       = {TargetId = data.targetId,ClubName = data.clubName,Callback = data.callBack,MessageCount = data.messageCount}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "enterClubRoom"
        local tempData   = {TargetId = data.targetId,ClubName = data.clubName,MessageCount = data.messageCount}
        local content    = json.encode(tempData)
        local args       = {content,data.callBack}
        local sig        = "(Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    退出战队聊天室
]]
function QManagerPlatform:quitClubRoom(data)
    if device.platform == "ios" then
        local methodName = "quitClubRoom"
        local args       = {TargetId = data.TargetId}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
     elseif device.platform == "android" then
        local methodName = "quitClubRoom"
        local content    = json.encode(data)
        local args       = {content}
        local sig        = "(Ljava/lang/String;)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end

function QManagerPlatform:testEnterClub()
     if device.platform == "ios" then
        local methodName = "enterClubRoom"
        local args       = {TargetId = "DebaoClub1099"}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    end
end
--[[
    播放战队语音
]]
function QManagerPlatform:playAudio(data)
    if device.platform == "ios" then
        local methodName = "playAudio"
        local args       = {Content = data.content}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "playAudio"
        local args       = {data.content}
        local sig        = "(Ljava/lang/String;)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    离桌/退出房间移除所有语音
]]
function QManagerPlatform:stopAllPlayAudio(data)
    if device.platform == "ios" then
        -- QManagerPlatform:setPlayFlag({playFlag = "NO"}) --临时修改，等重新上传appstore修改
        local methodName = "stopAllPlayAudio"
        local args       = {}
        local ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    elseif device.platform == "android" then
        QManagerPlatform:stopPlayAudio()
        QManagerScheduler:removeLocalScheduler({layer = GameSceneManager:getCurScene()})
        QManagerPlatform.mVoiceLayer = nil
        GPaiJuChat = {}
    end
end
--[[
    停止当前正在播放的语音
]]
function QManagerPlatform:stopPlayAudio(data)
    if device.platform == "ios" then
        local methodName = "stopPlayAudio"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "stopPlayAudio"
        local args       = {}
        local sig        = "()V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    除语音外的其他消息(文字/表情/牌桌列表/进入房间通知)
]]
function QManagerPlatform:sendMessage(data)
    if device.platform == "ios" then
        local methodName = "sendMessage"
        local args       = {TargetId = data.targetId,Content = data.content,Callback = data.callBack,UserId = data.userId,Type = data.nType}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "sendMyClubMessage"
        local tempData   = {TargetId = data.targetId,Content = data.content,UserId = data.userId,Type = data.nType}
        local content    = json.encode(tempData)
        local args       = {content,data.callBack}
        local sig        = "(Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    废弃
]]
function QManagerPlatform:getRCTotalUnreadCount(data)
        if device.platform == "ios" then
        local methodName = "getRCTotalUnreadCount"
        local args       = {Callback = data.callBack}
        local  ok, ret   = luaoc.callStaticMethod("RCPlatform", methodName, args)
        return ret
    end
end
--[[
    设置是否可以播放
]]
function QManagerPlatform:setPlayFlag(data)
    if device.platform == "ios" then
        local methodName = "setPlayFlag"
        local args       = {playFlag = data.playFlag}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        local flag = false
        if data.playFlag == "YES" then
            flag = true
        end
        local methodName = "setPlayFlag"
        local args       = {flag}
        local sig        = "(Z)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    发送牌桌内语音消息
]]
function QManagerPlatform:stopRecord(data)
    if device.platform == "ios" then
        CMDelay(GameSceneManager:getCurScene(),0.5,function () 
            local methodName = "stopRecord"
            local args       = {TargetId = data.TargetId,UserId = string.format("%s#%s",data.userId or "",data.fromWhere or "")}
            local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        end)
        -- return ret
    elseif device.platform == "android" then
        data.callBack = function (data) dump(data) end          
        QManagerPlatform:stopClubRecord(data)
    end
end
--[[
    取消牌桌内语音录制
]]
function QManagerPlatform:cancelRecord(data)
    if device.platform == "ios" then
        local methodName = "cancelRecord"
        local args       = {TargetId = data.TargetId}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        QManagerPlatform:cancelClubRecord(data)
    end
end
--[[
    开始牌桌内语音录制
]]
function QManagerPlatform:startRecord(data)
    if device.platform == "ios" then
        local methodName = "startRecord"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        QManagerPlatform:startClubRecord(data)
    end
end
--[[
    断开融云连接
]]
function QManagerPlatform:disConnectRongYun()
    if device.platform == "ios" then
        local methodName = "disConnectRongYun"
        local args       = {["isReceivePush"] = "NO"}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    elseif device.platform == "android" then
        local methodName = "disConnectRongYun"
        local args       = {}
        local sig        = "()V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    牌桌内语音队列
]]
-- function QManagerPlatform:playNextAudio(content)
--     -- dump(GPaiJuChat,"GPaiJuChat")
--     if not content then return end
--     if device.platform == "android" then
--         local data =  {}
--         data.content = content 
--         table.insert(GPaiJuChat,data)
--         data.callBack   = function (jsonData) QManagerPlatform:isPlayingCallBack(jsonData) end
--         QManagerPlatform:getIsPlayingAudio(data)
--     end

-- end
-- function QManagerPlatform:isPlayingCallBack(jsonData)
--      dump(jsonData,"isPlaying")
--     local retData = json.decode(tostring(jsonData)) or {}
--     local isPlaying = retData.isPlaying
--     if not isPlaying then
--         QManagerPlatform:playAudio(GPaiJuChat[1])
--         table.remove(GPaiJuChat,1)
--     end
       
-- end

--[[
    是否正在播放
]]
function QManagerPlatform:getIsPlayingAudio(data)
    if device.platform == "android" then
        local methodName = "getIsPlayingAudio"
        local args       = {data.callBack}
        local sig        = "(I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    微信分享
]]
function QManagerPlatform:shareToWeChat(data)

    if device.platform == "android" then
        local methodName ="shareToWeChat"
        local args       = {data.title,data.content,data.nType,data.url}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "shareToWeChat"
        local args       = {title = data.title,content = data.content,nType = data.nType,url = data.url}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

---
-- 安趣－初始化
--
function QManagerPlatform:initAnqu()
    if device.platform == "ios" then
        local methodName = "initAnqu"
        local args = {}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

---
-- 安趣－帐号登陆
--
function QManagerPlatform:anquLogin(callbackFunc)
    if device.platform == "ios" then
        local methodName = "anquLogin"
        local args = {callback = callbackFunc}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return
    end
    callbackFunc({sessiond="3a8e9e9f32f3eb6be62627f90ab51392",uid="1498308"})
end

---
-- 安趣－提交游戏扩展数据
--
function QManagerPlatform:anquExtinfo()
    --[[
     *  @param serverid    服务id
     *  @param serverName  服务器名字
     *  @param roleld      角色ID
     *  @param roleName    角色名
     *  @param roleLevel    角色level
    --]]
    if device.platform == "ios" then
        local methodName = "anquExtinfo"
        local args = {serverid="ios",serverName="anqu",roleld=myInfo.data.userId,roleName=myInfo.data.userName,roleLevel=myInfo.data.userLevel}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

---
-- 安趣－支付
--
function QManagerPlatform:anquPay(params, callbackFunc)
    --[[
     *  @param money    金额
     *  @param subject  商品名（主题）
     *  @param body      商品描述
     *  @param outOrderid CP订单号
     *  @param mPext       附加信息，可置空
     *  @param productid 商品对应的产品id
    --]]
    dump(params,"iccccc anquPay")
    if device.platform == "ios" then
        local methodName = "anquPay"
        local args = {callback = callbackFunc,money=params.money,subject=params.subject,body=params.body,outOrderid=params.outOrderid,mPext=params.mPext,productid=params.productid,rolename=params.rolename}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

--[[
    AppStore：
    整包更新跳转
]]
function QManagerPlatform:jumpToUpdate(data)
    if device.platform == "android" then
        local methodName ="jumpToUpdate"
        local args       = {data}
        local sig        = "(Ljava/lang/String;)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "jumpToUpdate"
        local args       = {url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=667788066"}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

--[[
    网页跳转
]]
function QManagerPlatform:jumpToWebView(data)

    if device.platform == "android" then
        local methodName ="callAppointUrl"
        local args       = {data.url}
        local sig        = "(Ljava/lang/String;)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "jumpToWebView"
        local args       = {url = data.url}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end
function QManagerPlatform:HeadChangeCallback(resultData)
    dump("HeadChangeCallback")
end
--[[
    活动提示
]]
function QManagerPlatform:getActivityTips()
    local sTip = ""
    if device.platform == "android" then
        sTip = "活动最终解释权归德堡所有"
    else
        sTip = "活动最终解释权归德堡所有，活动由德堡主办，与Apple Inc.无关"
    end 
    return sTip
end
--[[
    QQ登录
]]
function QManagerPlatform:openQQLogin(luaCallBack)
    if device.platform == "android" then
        local methodName ="showQQLoginView"
        local args       = {function (jsonStr) local jObj = json.decode(jsonStr) luaCallBack(jObj) end}
        local sig        = "(I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "callQQLogin"
        local args       = {callback = luaCallBack}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

function QManagerPlatform:tencentUnipay_JNI(goldNum,luaCallBack)
    local methodName = "startTencentUnipayStatic"
    local args       = {goldNum, luaCallBack}
    local sig        = "(Ljava/lang/String;I)V"
    local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end

function QManagerPlatform:showBaiduPayView(orderId,goodsname,price,asynCallBack,sign,luaCallBack)
    local methodName = "showBaiduPayView"
    local args       = {orderId,goodsname,price,asynCallBack,sign, luaCallBack}
    local sig        = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end

function QManagerPlatform:callBaiduLogin(luacallback)
    local methodName = "callBaiduLogin"
    local args = {luacallback}
    local sig        = "(I)V"
    luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end

function QManagerPlatform:callMeizuLogin(luacallback)
    local methodName = "callMeizuLogin"
    local args = {luacallback}
    local sig        = "(I)V"
    luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end
--[[
    第三方SDK登录
]]
function QManagerPlatform:callLogin(luacallback)
    if device.platform == "android" then
        local methodName = "callLogin"
        local args = {luacallback}
        local sig        = "(I)V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    提交数据
]]
function QManagerPlatform:submitPlayerInfo()
    if device.platform == "android" then
        local methodName = "submitPlayerInfo"
        local data =  {}
        data.userName    = myInfo.data.userName
        data.userId      = myInfo.data.userId
        data.serverName  = tostring(myInfo.data.serverId)
        data = json.encode(data)
        dump("submitPlayerInfo",data)
        local args = {data}
        local sig        = "(Ljava/lang/String;)V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    第三方SDK支付
]]
function QManagerPlatform:showPayView(data,callback)
    --if device.platform == "android" then
        local content = json.encode(data)
        local methodName ="showPayView"
        local args       = {content,callback}
        local sig        = "(Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
   -- end
end
--[[
    第三方SDK切换账户
]]
function SwitchUserAccount(userData)
    QManagerPlatform:setIsSwitchAccount(true,userData)
   local MoreMainLayer = require("app.GUI.setting.MoreMainLayer"):new()
    MoreMainLayer:onMenuLogout()
end

-- OC全局调用lua  OC方面直接LuaObjcBridge::getStack()->executeString("OCCallLuaFunc({xx,xx})")
function OCCallLuaFunc(data)
    -- data = {
    --     ["tag"] = "receiveMsg",
    --     ["type"] = "textMsg",
    --     ["content"] = "测试",

    -- }
 --     data = {
 --     ["content" ] = "/(null)1461832152536.caf",
 --     ["duration"] = 3,
 --     ["tag"    ]  = "receiveMsg",
 --     ["type"  ]   = "voiceMsg",
 --     ["userId"]   = "(null)",
 -- }
    -- dump(data,"deep")
    -- print(data)
    -- datacopy = deepCopy(data)
     -- dump(json.decode(tostring(data)))
    if device.platform == "android" then
        data = json.decode(tostring(data))
    end
    print(data,data.tag)
    if not data or type(data) ~= "table" then return end

    -- data = {['tag'] = 'receiveMsg',['userId']='(null)',['content']='咕咕咕',['type']='textMsg'}
    if data.tag == "showTalkIcon" then              --牌桌内收到语音
        if device.platform == "android" then
            table.insert(GPaiJuChat,data)           --添加到播放队列
            QManagerPlatform:PlayNextVoice(data)
        else
            local tempData = string.split(data.userId,"#")
            data.userId = tempData[1]
            QManagerListener:Notify({layerID = eRoomViewID,tag = "showTalkIcon" , userId =data.userId,content = data.content, duration = data.duration})
        end    
    elseif data.tag == "receiveMsg" then            --战队内收到聊天信息
        -- dump(data,"receiveMsg")
        -- print(data.tag)
        QManagerListener:Notify({layerID = eFTChatNodeID,userId = data.userId,nType = data.type,content = data.content,duration = data.duration})      
    elseif data.tag == "playAudioFinish" then       --语音播放结束
        -- dump(GPaiJuChat) 播放回调有延迟废弃掉
        -- if #GPaiJuChat > 0 then
        --     QManagerPlatform:playAudio(GPaiJuChat[1])
        --     table.remove(GPaiJuChat,1)
        -- end
    elseif data.tag == "logOut" then   
        QManagerData:removeAllCacheData()
        QManagerListener:clearAllLayerID()

        UserDefaultSetting:getInstance():setLastLoginTimeStamp(myInfo.data.userId,myInfo.data.serverTime)
        UserDefaultSetting:getInstance():setAutoLoginEnable(false)
        myInfo.data.phpSessionId = ""
        GIsConnectRCToken = false
        
        myInfo:clearCacheData()
        local tcp = TcpCommandRequest:shareInstance()
        if tcp:isConnect() then
            tcp:closeConnect()
        end
        local push = PushCommandRequest:shareInstance()
        if push:isConnect() then
            push:closeConnect()
        end
        QManagerPlatform:disConnectRongYun()
        GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
    end
end
--[[
    战队内语音队列播放
]]
function QManagerPlatform:PlayNextVoice(data)
 --         data = {
 --     ["content" ] = "/(null)1461832152536.caf",
 --     ["duration"] = 3,
 --     ["tag"    ]  = "receiveMsg",
 --     ["type"  ]   = "voiceMsg",
 --     ["userId"]   = "(null)",
 -- }
    if not data then 
        dump("data is nil")
        return 
    end
    if not QManagerPlatform.mVoiceLayer then
        QManagerPlatform.mVoiceLayer = QManagerScheduler:insertLocalScheduler({layer = GameSceneManager:getCurScene(),listener = function () self:updateTime(data.duration) end,interval = tonumber(data.duration)})
        local tempData = string.split(data.userId,"#")
        data.userId = tempData[1]
        QManagerListener:Notify({layerID = eRoomViewID,tag = "showTalkIcon" , userId =data.userId,content = data.content, duration = data.duration})
        QManagerPlatform:stopPlayAudio()
        QManagerPlatform:playAudio(GPaiJuChat[1])
        table.remove(GPaiJuChat,1)
    end
    
end
--[[
    播放完一条回调
]]
function QManagerPlatform:updateTime(time)
    -- dump(time,"QManagerPlatform:updateTime")
    -- dump(#GPaiJuChat )
    if #GPaiJuChat > 0 then
        QManagerPlatform.mVoiceLayer = nil
        QManagerPlatform:PlayNextVoice(GPaiJuChat[1])
    else
        QManagerScheduler:removeLocalScheduler({layer = GameSceneManager:getCurScene()})
        QManagerPlatform.mVoiceLayer = nil
    end
end
--[[
    设置是否渠道注销回调
]]
function QManagerPlatform:setIsSwitchAccount(isSwitch,userArg)
    QManagerPlatform.isSwitch = isSwitch
    QManagerPlatform.args     = userArg
end
function QManagerPlatform:getIsSwitchAccount()
    return QManagerPlatform.isSwitch,QManagerPlatform.args 
end
function QManagerPlatform:callWeChatPay(data,callback)
    local methodName ="callWeChatPay"
    local args       = {data.partnerId,data.prepayid,data.noncestr,data.timestamp,data.packageStr,data.sign,callback}
    local sig        = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end 

function QManagerPlatform:showMeizuPayView(orderId,goodsName,price,callBackUrl,sign,luaCallBack)
    local methodName ="showMeizuPayView"
    local args       = {orderId,goodsName,price,callBackUrl,sign,luaCallBack}
    local sig        = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end

function QManagerPlatform:openAlipayJni(recordId,callBackUrl,price,goodsName,goodsSct,accessToken,luaCallBack)
    if device.platform == "android" then
        local methodName ="showAliPayView"
        local args       = {recordId,callBackUrl,price,goodsName,goodsSct,accessToken, luaCallBack}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[
    渠道支付
]]
function QManagerPlatform:openUpompPay_JNI(orderId,ordertime,sign,luaCallBack)
    if device.platform == "android" then
        local methodName ="showUpompPayView"
        local args       = {orderId,ordertime,sign,luaCallBack}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "buy"
        local args       = {orderId = orderId,goodsid = ordertime,callback = luaCallBack}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end
--[[
    获取APPStore充值产品列表
]]
function QManagerPlatform:getIAPProducts()
   
    if device.platform == "ios" then        
        local methodName = "getIAPProducts"
        local args = require("app.GUI.recharge.GoldConfig")
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end

function QManagerPlatform:callTenPay(url,callBackUrl,luaCallBack)
    if device.platform == "android" then
        local methodName ="callAppOpenUrl"
        local args       = {url,callBackUrl,luaCallBack}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;I)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    end
end
--[[ 
    获取安卓mac地址/iOS UUID
]]
function QManagerPlatform:getUniqueStr()
    if device.platform == "android" then
       local methodName ="getMacAddr"
        local args       = {}
        local sig        = "()Ljava/lang/String;"
        local  ok, ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)      
        return ret
    elseif device.platform == "ios" then
        local methodName = "getUUID"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret
    end

    return "2641BF85-BS69B-4991-BE6F-BbA682d2F3QC" 
end

function QManagerPlatform:showUniPayView(recordId,vacCode,thirdPartyCode,callBackUrl,buyStr,money,luaCallback)
        local methodName ="showUniPayView"
        local args       = {recordId,  vacCode, thirdPartyCode,  callBackUrl,  buyStr,  money,luaCallback}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V"
        local ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
end
--[[
    游戏震动
]]
function QManagerPlatform:callVibrate()
    if device.platform == "android" then
        local methodName ="callAndroidVibrate"
        local args       = {}
        local sig        = "()V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)        
    elseif device.platform == "ios" then
        local methodName = "callVibrate"
        local args       = {}
        luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end
function QManagerPlatform:restartGameApp()
    if device.platform == "android" then
        -- local methodName ="restartGameApp"
        -- local args       = {}
        -- local sig        = "()V"
        -- luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)        
    elseif device.platform == "ios" then
        -- local methodName = "callVibrate"
        -- local args       = {}
        -- luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
    end
end
function QManagerPlatform:getTalkingdataString()
    if device.platform == "android" then
        local methodName ="getTalkingdataString"
        local args       = {}
        local sig        = "()Ljava/lang/String;"
        local  ok, ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)
        return ret
    elseif device.platform == "ios" then
        local methodName = "getTalkingdataString"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)

        return ret or "20210"
    else
        return DBChannel
    end
end
--[[
    废弃
]]
function QManagerPlatform:getAPKVersion()
    if device.platform == "ios" then
        local methodName = "getAPKVersion"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        return ret 
    end
end
--[[
    获取渠道号
]]
function QManagerPlatform:getCurrentVersion()
    if device.platform == "android" then
        local methodName ="getCurrentVersion"
        local args       = {}
        local sig        = "()Ljava/lang/String;"
        local  ok, ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)        
        return ret
    elseif device.platform == "ios" then
        local methodName = "getCurrentVersion"
        local args       = {}
        local  ok, ret   = luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)

        return ret or "DeBao V2.2.10210"
    else
        return DBChannel
    end
end
--  以下三个方法暂时只供联通沃商店渠道使用
function QManagerPlatform:getIPAdress()
       local methodName ="getIPAdress"
        local args       = {}
        local sig        = "()Ljava/lang/String;"
        local  ok, ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)        
        return ret
end

function QManagerPlatform:getIMEI()
       local methodName ="getIMEI"
        local args       = {}
        local sig        = "()Ljava/lang/String;"
        local  ok, ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)        
        return ret
end

function QManagerPlatform:getUnicomMacAddr()
       local methodName ="getUnicomMacAddr"
        local args       = {}
        local sig        = "()Ljava/lang/String;"
        local  ok, ret        = luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName,args, sig)        
        return ret 
end

--------------------------------------------------------------------------
                --[[按键返回 start]]--
--添加监听事件
function QManagerPlatform:addKeyBackClicked(scene)
    if device.platform == "android" or device.platform == "mac" then
        scene:setKeypadEnabled(true) 
        scene:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
            if event.key == "back" then
               QManagerPlatform:onKeyCallBack()
            end
        end)
    end 
end
--[[
    按键返回－－添加子层
]]
function QManagerPlatform:addLayer(self)
    if device.platform == "android" or device.platform == "mac" then
        if not self then return end
        table.insert(QManagerPlatform.mAllLayer,1,self)
    end
end
--[[
    移除最近的一个layer／返回上一个状态
]]
function QManagerPlatform:removeLayer(self)
    if device.platform == "android" or device.platform == "mac" then
        if not self then return end
        if QManagerPlatform.mAllLayer[1] == self then
            table.remove(QManagerPlatform.mAllLayer,1)
        else
            for i,v in pairs(QManagerPlatform.mAllLayer) do 
                if v == self then
                    table.remove(QManagerPlatform.mAllLayer,i)
                    break
                end
            end 
        end
    end
end
--[[
    游戏退出提示框
]]
function QManagerPlatform:onExitGame()
    -- body
    if device.platform == "android" or device.platform == "mac" then
        local RewardLayer = require("app.Component.CMAlertDialog").new({text = "确定要退出游戏？",showType = 2,callOk = function () os.exit() end})
        CMOpen(RewardLayer, cc.Director:getInstance():getRunningScene())
    end
end
--[[
    按键返回－－回调
]]

function QManagerPlatform:onKeyCallBack()
    if device.platform == "android" or device.platform == "mac" then
        local lens = #QManagerPlatform.mAllLayer
        if lens == 0 then
            if GameSceneManager.mCurSceneType == EGSHall or GameSceneManager.mCurSceneType == GameSceneManager.AllScene.TourneyList or GameSceneManager.mCurSceneType == GameSceneManager.AllScene.ReplayView then
                GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
            elseif GameSceneManager.mCurSceneType == GameSceneManager.AllScene.RoomViewManager then
                -- GameSceneManager:switchSceneWithType(EGSHall)
                GameSceneManager.mRoomViewManager:keyBackClicked()
            else
                self:onExitGame()
            end
        else
            CMClose(QManagerPlatform.mAllLayer[1])
        end
    end
end
function QManagerPlatform:clearAllLayerID()
    QManagerPlatform.mAllLayer = {}
end
                --[[按键返回 end]]--
--------------------------------------------------------------------------

-- CrashReport
function QManagerPlatform:crSetUid(uid)
    --bugly sdk直接导出了lua方法
    buglySetUserId(uid)
    -- if device.platform == "android" then

    -- elseif device.platform == "ios" then
        
    -- end
end

--------------------------------------------------------------------------
                --[[TalkingDataGA start]]--

function QManagerPlatform:onStart()
    local channelId  = string.sub(DBVersion,string.len(DBVersion)- 4,string.len(DBVersion))
     if device.platform == "android" then

    elseif device.platform == "ios" then
        local methodName = "onStart"
        local args       = {appId = "587D419373240DB39BCB7112B23C770E",channelId = channelId}
        luaoc.callStaticMethod(TALKINGDATANAME, methodName, args)
    end
end

function QManagerPlatform:setAccountInfo(uid,uname)
     if device.platform == "android" then
       local methodName ="setAccountInfo"
        local args       = {uid,uname}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;)V"
       luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "setAccountInfo"
        local args       = {accountId = uid ,accountName = uname}
        luaoc.callStaticMethod(TALKINGDATANAME, methodName, args)
    end
end
function QManagerPlatform:setAccountType(data)
     if device.platform == "android" then
        local methodName ="setAccountType"
        local args       = {data.accountType or 0}
        local sig        = "(I)V"
       luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "setAccountType"
        local args       = {accountType = data.accountType or 0}
        luaoc.callStaticMethod(TALKINGDATANAME, methodName, args)
    end
end

function QManagerPlatform:onChargeRequest(args)
    if args.paymentType == "" then
        return
    end
     if device.platform == "android" then
        local methodName ="onChargeRequest"
        local arg       = {args.orderId,args.iapId,args.currencyAmount+0.0,args.virtualCurrencyAmount+0.0,args.paymentType}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;FFLjava/lang/String;)V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, arg, sig)
    elseif device.platform == "ios" then
        local methodName = "onChargeRequst"
        --local args       = {orderId = data.orderId,iapId = data.orderId,currencyAmount = data.orderId,virtualCurrencyAmount = data.orderId,paymentType = data.orderId}
        luaoc.callStaticMethod(TALKINGDATANAME, methodName, args)
    end
end

function QManagerPlatform:onChargeSuccess(args)
     if device.platform == "android" then
       local methodName ="onChargeSuccess"
        local arg       = {args}
        local sig        = "(Ljava/lang/String;)V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, arg, sig)
    elseif device.platform == "ios" then
        local methodName = "onChargeSuccess"
        --local args       = {orderId = "09231732481"}
        luaoc.callStaticMethod(TALKINGDATANAME, methodName, args)
    end
end

function QManagerPlatform:onEvent(data)
     if device.platform == "android" then
        local methodName ="TDGAOnEvent"
        local args       = {data.where,data.nType}
        local sig        = "(Ljava/lang/String;Ljava/lang/String;)V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then
        local methodName = "onEvent"
        local args       = {where = data.where,nType = data.nType}
        luaoc.callStaticMethod(TALKINGDATANAME, methodName, args)
    end
end
--[[
    打开斗地主
]]
function QManagerPlatform:startApp(data)
     if device.platform == "android" then
        local methodName ="startApp"
        local args       = {"com.debao.doudizhu"}
        local sig        = "(Ljava/lang/String;)V"
        luaj.callStaticMethod(JNI_JAVACLASSNAME, methodName, args, sig)
    elseif device.platform == "ios" then 
        local callback = function () 
            
        end
        local methodName = "startApp"
        local args       = {}
        local ok, ret    =luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        -- dump(ok,ret)
        if not ret or ret == "0" then
            -- local url = "itms-services://?action=download-manifest&url=https://o8byzlq6r.qnssl.com/doudizhu.plist"
            -- local data = {}
            -- data.url = url
            -- QManagerPlatform:jumpToUpdate(data)
            local methodName = "jumpToUpdate"
            local args       = {url = "https://itunes.apple.com/us/app/bao-dou-zhu-zui-niu-dou-zhu/id1123884780?l=zh&ls=1&mt=8"}
            luaoc.callStaticMethod(IOSCLASSNAME, methodName, args)
        end
        
      
    end
end


                --[[TalkingDataGA end]]--
--------------------------------------------------------------------------
--------------------------------------------------------------------------
                --[[渠道 start]]--
--[[
    渠道帅选
]]
function QManagerPlatform:filterItemList(srcData)        
    for i,v in pairs(srcData) do 
        if BRANCHES_VERSION == CHINAMOBILEMM then
            if v == "CM" or v == "UN" then
                table.remove(srcData,i)
            end
        elseif BRANCHES_VERSION == CHINAUNICOM then
            if v == "UNWO" then
                table.remove(srcData,i)
            end
        elseif BRANCHES_VERSION == TENCENT_WITH_PAY then
            if v == "TENCENT" then
                table.remove(srcData,i)
            end
        elseif BRANCHES_VERSION == ALIPAYOPEN then
            if v == "ALIPAY" then
                table.remove(srcData,i)
            end
        else
            if v == "MM" or v == "UN" then 
                table.remove(srcData,i)
            end
        end
    end

     return srcData
end
                --[[渠道 end]]--
--------------------------------------------------------------------------

---
-- 安趣登出全局方法
--
function gAnquLogout()
    QManagerData:removeAllCacheData()
    QManagerListener:clearAllLayerID()

    UserDefaultSetting:getInstance():setLastLoginTimeStamp(myInfo.data.userId,myInfo.data.serverTime)
    UserDefaultSetting:getInstance():setAutoLoginEnable(false)
    myInfo.data.phpSessionId = ""
    GIsConnectRCToken = false
    
    myInfo:clearCacheData()
    local tcp = TcpCommandRequest:shareInstance()
    if tcp:isConnect() then
        tcp:closeConnect()
    end
    local push = PushCommandRequest:shareInstance()
    if push:isConnect() then
        push:closeConnect()
    end
    QManagerPlatform:disConnectRongYun()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.LoginView)
end

return QManagerPlatform