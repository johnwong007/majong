
--
-- Author: junjie
-- Date: 2015-11-20 15:04:56
--
QManagerScheduler = require("app.Tools.QManagerScheduler"):getInstance({})
QManagerPlatform  = require("app.Tools.QManagerPlatform"):getInstance({})
CMButton 		  = require("app.Component.CMButton")
CMSpriteButton    = require("app.Component.CMSpriteButton")
CMInput 		  = require("app.Component.CMInput")
QManagerData      = require("app.Tools.QManagerData")
QManagerListener  = require("app.Tools.QManagerListener")
CMMask 			  = require("app.Component.CMMask")
require("app.Tools.FilterWords")
require("app.Component.CMHandleDirectory")
local MusicPlayer = require("app.Tools.MusicPlayer")

if device.platform == "ios" then
	GIOSCHECK = false  		--false：关闭审核
	
end
if device.platform == "ios" and DBChannel == "20210" then
	QManagerPlatform:getIAPProducts()
end

QManagerScheduler:startGolbalScheduler()
--font--
GArail = "fonts/arial.ttf"
GFZZC  = "fonts/FZZCHJW--GB1-0.TTF"
--队列
GTip 			= {}			--普通提示
GBroadTips 		= {} 	        --广播提示
GPaiJuChat      = {} 			--牌桌内语音列表

CMColor			= {}
CMColor[1]		= cc.c3b(253,232,175)		--浅黄
CMColor[2]		= cc.c3b(213,144,88)		--深黄
CMColor[3]		= cc.c3b(124,0,17)			--暗红
CMColor[4]		= cc.c3b(143,225,64)		--绿色
CMColor[5]		= cc.c3b(95,45,19)			--褐色
CMColor[6]		= cc.c3b(156,112,59)		--土黄	
CMColor[7]		= cc.c3b(75,31,12)			--咖啡色

GIsOpen         = false
GIsConnectRCToken = false 					--是否连上获取融云的token	

-- 定义全局静态类的句柄		
local GV = GV or {}
_G.GV = GV

local mt = {}
mt.__index = function(t, k)
	if k == "UserConfig" then
		return GV.CMDataProxy:getData(GV.CMDataProxy.DATA_KEYS.USERCONFIG)
	end
end

setmetatable(GV, mt)

GV.CMDataProxy = import(".CMDataProxy")

GV.CMDisplayScale = math.max(display.widthInPixels/960, display.heightInPixels/640)

--[[
	延迟执行某个方法
]]			
function CMDelay(node, delayTime, fuc, bRepeate, tag)
	if not node then
		-- Log("common ac_dly_fuc node is nil value.");
		return 
	end
	local ac_dly = cc.DelayTime:create(delayTime);
	local ac_fuc = cc.CallFunc:create(fuc);
	local ac_seq = cc.Sequence:create(ac_dly, ac_fuc);
	if bRepeate and bRepeate == true then
		ac_seq = cc.RepeatForever:create(ac_seq);
	end
	if tag then
		ac_seq:setTag(tag);
	end
	
	node:runAction(ac_seq);
end
--[[
	漂浮提示语
]]
function CMShowTip(_tips,_playEffect)
	--_tips = "返回码：".._tips
	if #GTip >= 1 then 
		CMDelay(cc.Director:getInstance():getRunningScene() ,0.1,function () CMShowTip(_tips) end)
		return
	end
	-- if _playEffect then
	-- 	QManagerSound:playEffectByTag(QManagerSound._effectTag.eReward)
	-- end
	local temp = cc.ui.UILabel.new({text = _tips,size = 28})
	local tipBg =cc.ui.UIImage.new("picdata/public/bg_tips.png", {scale9 = true})
    --tipBg:setLayoutSize(temp:getContentSize().width + 40,112)
    tipBg:setLayoutSize(578,112)
    :pos(display.cx-tipBg:getContentSize().width/2,display.height/2)
    :addTo(cc.Director:getInstance():getRunningScene(), 1000)

    local text = cc.ui.UILabel.new({text = _tips,size = 26})	
	text:setPosition(cc.p(tipBg:getContentSize().width/2-text:getContentSize().width/2,tipBg:getContentSize().height/2))
	tipBg:addChild(text,0)
	table.insert(GTip,tipBg)
	
	for i,v in pairs(GTip) do
		if #GTip > 1 then 
			CMDelay(GTip[i],1.5,function () transition.moveBy(v, {y = 80, time = 1.5, onComplete = function()				
		        v:removeSelf()
		        GTip[i] = nil	        
		    end}) end)
		else
			transition.moveBy(v, {y = 80, time = 1, onComplete = function()
		        v:removeSelf()
		        GTip[i] = nil	        
		    end})
		end
	    
	end

end

--[[
	整数转时间
]]
function CMFormatTimeStyle(num)
	local num = tonumber(num);
	local strTime = "";
	
	local now = os.date("*t", os.time())
	local t = os.date("*t", num)
	strTime = string.format("%04d%02d%02d",t.year,t.month ,t.day)
	return strTime,t
end
--[[
	返回格式化时间
]]
function CMGetCurrentTime()
	local t = os.date("*t", os.time())
	local strTime = string.format("%04d/%02d/%02d %02d:%02d:%02d",t.year,t.month,t.day,t.hour,t.min,t.sec)
	return strTime
end
--[[
	数字转化
]]
function CMFormatNum(num)
	local isMinus = nil
	num = tonumber(num)
	if num < 0 then
		isMinus = true
	end
	num = math.abs(num)
	if num >= 100000000 then
		num =  math.floor(num/100000000) .. "亿"
	elseif num >= 10000 then
		num = math.floor(num/10000) .. "万"
	else
		
	end
	if isMinus then 
		num = "-"..num
	end
	return num
end
--[[
	isNotAdd:不添加到返回层
]]
function CMOpen(self,parent,params,isPlay,zorder,dispatchEvt)
	if tolua.isnull(parent) then
		print("parent 有问题")
		return
	end
	local isNotAdd = false
	if zorder==nil then
		zorder = 10
	end
	GIsClose = false
	if type(params) == "table" and params.isEnter then

	else
		if GMaskLayer or GIsOpen then  return end
	end
	MusicPlayer:getInstance():playDialogOpenSound()
	
	GIsOpen = true
	isPlay = isPlay or 1
	local posx = nil
	local easing = "backOut"
	local transTime = 0.3
	if type(params) == "table" then
		posx = params.posx
		isNotAdd = params.isNotAdd
		if params.easing == false then
			easing = nil
			transTime = 0.2
		else
			easing = params.easing or easing
		end
	else
		posx = params
	end

	if type(self) == "table" then
	   self = self.new(params)	

	end
	self:create() 

	if posx then self:setPositionX(posx) end

    parent:addChild(self,zorder)
    if isPlay == 1 then
    	GMaskLayer = CMMask.new()
		parent:addChild(GMaskLayer)

		if not CMIsNull(self.mBg) then
	   	    self.mBg:setScale(0.8)
			transition.scaleTo(self.mBg, {scale=1, time=transTime, easing=easing, onComplete = function()
			        if GMaskLayer then GMaskLayer:removeFromParent() GMaskLayer  = nil end
			        GIsOpen = false
			    end,})
		else
			if GMaskLayer then GMaskLayer:removeFromParent() GMaskLayer  = nil end
			GIsOpen = false
		end
	else
		GIsOpen = false
   	end
   	if not isNotAdd then
   		QManagerPlatform:addLayer(self)
   	end
    --CMDelay(self, 0.4,function ()  GIsOpen = false end)
    if dispatchEvt then
		local event = cc.EventCustom:new(dispatchEvt)
    	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
	end
    return self
end
function CMClose(self,isPlay,dispatchEvt)
	if not self or tolua.isnull(self) then 
		return 
	end
	if GIsClose then return end
	MusicPlayer:getInstance():playDialogCloseSound()
	GIsClose = true 
	--local moveAction      = cc.MoveBy:create(0.45, cc.p(0, -480))	
    -- local funcAction      = cc.CallFunc:create(function () 
    -- 	if GMaskLayer then GMaskLayer:removeFromParent() GMaskLayer  = nil end
    -- 	GIsOpen = false  
    -- 	self:removeFromParent()  end) 
    --self:runAction(cc.Sequence:create(moveAction,funcAction))
    self.httpResponse = nil
    -- if false then 
    if isPlay then 
	    transition.execute(self, cc.MoveBy:create(0.45, cc.p(0, -480)), {
			    
			    onComplete = function()
			        if GMaskLayer and  GIsOpen == false then GMaskLayer:removeFromParent() GMaskLayer  = nil end	
			        QManagerPlatform:removeLayer(self)	    	  
			    	self:removeFromParent()		    	
			    	GIsOpen = false
			    	GIsClose= false
			    end,
			})
	else
		if GMaskLayer --[[and  GIsOpen == false]] then GMaskLayer:removeFromParent() GMaskLayer  = nil end	
        QManagerPlatform:removeLayer(self)	    	  
    	self:removeFromParent(true)
    	self = nil	    	
    	GIsOpen = false
    	GIsClose= false
	end
    if dispatchEvt then
		local event = cc.EventCustom:new(dispatchEvt)
    	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
	end
end

--[[
	人物头像
]]
function CMCreateHeadBg(headPath,size1,size2,headImageRoot)
	headPath =  headPath or "/static/images/sysimage/avatar.png"
	size1 = size1 or cc.size(70,70)
	szie2 = size2 or cc.size(0,0)
	local __pattern1 = ".gif"
	--local __pattern2 = ".jpg"
	local index,_ = string.find(headPath,__pattern1)	
	--local index2,_ = string.find(headPath,__pattern2)	
	--if index or index2 then 
	if index then
		headPath =  "/static/images/sysimage/avatar.png"

	end
	local headPic = require("app.GUI.HeadImage"):createWithImageUrl(HEADIMAGECACHEDIR,"",size1,0,size2,0,"")
    headPic:changeHead(headPath,false,headImageRoot)

    return headPic
end
--[[
	检查目录是否存在
]]
function CMCheckDirOK( path )
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

--[[
	写文件
]]
function CMReadFile(filename)
	--filename =  cc.FileUtils:getInstance():getWritablePath() .. "images/heads/avatar.png"
	--local f = io.open(filename,'r')
   local f = assert(io.open(filename,'r'))
   local string = f:read("*all")
   --print(string)
   f:close()
    return string
end
--[[
	读文件
]]
function CMWriteFile(filename,content)
	 local f = assert(io.open(filename,'w'))
	 f:write(content)
	 f:close()
end
--[[
	修改适配问题
]]
function CMDealAdapter(bg)
    bg:setScaleX(CONFIG_SCREEN_WIDTH/bg:getContentSize().width)
    bg:setScaleY(display.height/bg:getContentSize().height)
    bg:setPosition(CONFIG_SCREEN_WIDTH/2, display.cy)
end

--[[
	中文转换3个字节
]]
function CMStringToString(str,needLens,IsDot)
	--local str = "Jimmy: 你好,世界!"
	-- str = "₯㎕ζั͡✾ ✎﹏ℳ๓天使"
	-- local needLens =31
	if type(str) ~= "string" then return "" end 
	local lenInByte = string.len(str)
	needLens = needLens or lenInByte 
	local i = 1
	local char = ""
	while i <= lenInByte do 
	    local curByte = string.byte(str, i)
	    --dump(curByte)
	    local byteCount = 1;
	    -- if curByte>0 and curByte<=127 then
	    --     byteCount = 1  
	    -- elseif curByte > 127 then
	    --     byteCount = 3  
	    -- end
	   	if curByte>0 and curByte<=127 then
	   		byteCount = 1
	    elseif curByte < 0xc2 then

        elseif curByte < 0xe0 then
            byteCount = 2
        elseif curByte < 0xf0 then
            byteCount = 3
        elseif curByte < 0xf8 then
            byteCount = 4
        elseif curByte < 0xfc then
            byteCount = 5
        elseif curByte < 0xfe then
            byteCount = 6
        end
	    char = string.sub(str, 1, i+byteCount-1)
	    
	    i = i + byteCount 
	    if i > needLens then
	    	break
	    end  
	end
	if string.len(char) < lenInByte and IsDot then 
		char = char .. "."
	end

	return char
end
--[[
	中文2个字节计算
	]]
function CMGetStringLen(str,needLens,IsDot)
	if type(str) ~= "string" then return "" end 
	local lenInByte = string.len(str)
	needLens = needLens or lenInByte 
	local i = 1
	local char = ""
	local curCount = 0
	while i <= lenInByte do 
	    local curByte = string.byte(str, i)
	    --dump(curByte)
	    local byteCount = 1;
	 	local nChinaCount = 2
	   	if curByte>0 and curByte<=127 then
	   		byteCount = 1
	   		nChinaCount = 1
	    elseif curByte < 0xc2 then

        elseif curByte < 0xe0 then
            byteCount = 2
        elseif curByte < 0xf0 then
            byteCount = 3
        elseif curByte < 0xf8 then
            byteCount = 4
        elseif curByte < 0xfc then
            byteCount = 5
        elseif curByte < 0xfe then
            byteCount = 6
        end
	    
	    curCount = curCount + nChinaCount
	    if curCount > needLens then
	    	if IsDot then 
	    		break 
	    	else
	    		return char,lenInByte
	    	end
	   		-- break
	   	end

	   	char = string.sub(str, 1, i+byteCount-1)	    
	    i = i + byteCount 
	end
	if curCount > needLens and IsDot then 
		char = char .. ".."
	end

	return char,curCount
end
--[[
	加密
]]
function CMMD5Charge(str)
	local tmpCKey = "9a4762f234593191ce66de1116fb594d"
	return crypto.md5(crypto.md5(str)..tmpCKey)
end

function TencentMD5Charge(str)
	local tmpCKey = "E035A58712!#@DEBAO%TENCENT%pay*!"
	return crypto.md5(crypto.md5(str)..tmpCKey)
end
--[[
	牌型
]]
function CMAddCard(cardData)
	local node = cc.Node:create()
    local data = string.split(cardData,",")
    if #data < 5 then return node end
    
	local colorStr = {[0] = "s",[1] = "h",[2] = "c",[3] = "d"}
	--local str = "8s"
	local posx = 0
	for i = 1,#data do
		local num   = string.sub(data[i],1,1)
		local color = string.sub(data[i],2,2)
		local path = ""
		for i,v in pairs(colorStr) do 
			if v == color then
				if num == "T" then num = 10 end
				path = string.format("picdata/db_poker/%s_%s.png",i,num)
				break
			end
		end
		local card = cc.Sprite:create(path)
		card:setScale(0.5)
		card:setPosition(posx,0)
		node:addChild(card)
		posx = posx + card:getBoundingBox().width + 2
	end
	return node
end

--[[
	字符串时间转时间戳
]]
function CMStringTime(str)
	-- local str = "2016-03-18 17:15:52" 
	str = str or os.date("%x %X",os.time())
	str = string.gsub(str,"/","-")
    str = string.gsub(str," ","-")
    str = string.gsub(str,":","-")
    local t = string.split(str,"-")
    local tab = {year=t[1], month=t[2], day=t[3], hour=t[4],min=t[5],sec=t[6]}
    local time = os.time(tab)
    return time
end

function CMTimeToStyle(nTime)
	local t = {}
	t.day  = math.floor(nTime/(24 *3600))
	t.month= math.floor(t.day/30)
	t.hour = math.floor(nTime/3600)
	t.min  = math.floor(nTime/60)%60
	return t
end
--[[
	返回已过去时间
]]
function CMGetOverTime(nTime)
	local t = CMTimeToStyle(nTime)
	local sTips = ""
	if t.month ~= 0 then
		sTips = t.month.."个月"
	elseif	t.day ~= 0 then
		sTips = t.day.."天"
	elseif t.hour ~= 0 then
		sTips = t.hour.."小时"
	elseif t.min ~= 0 then			
		sTips = t.min.."分钟"
	else
		sTips = "1分钟"
	end

	return sTips
end

function isRightPhoneNumber(number) 
	if not number then return end
	local isPhoneNumber = true
	if string.len(number)==11 then
		for i=1,11 do
			local char = tonumber(string.sub(number, i, i))
			-- dump(char)
			if i==1 and char~=1 then
				isPhoneNumber = false
				break
			end
			if char and char>=0 and char<=9 then

			else
				isPhoneNumber = false
				break
			end
		end
	else
		isPhoneNumber = false
	end
	return isPhoneNumber
end

--[[
	返回已过去时间
]]
function revertPhoneNumber(number)
	local result = number
	if isRightPhoneNumber(number) then
		result = string.sub(number, 1, 3).."..."..string.sub(number, 8, 11)
	end
	return result
end

function isRightEmail(str)  
    if string.len(str or "") < 6 then return false end  
    local b,e = string.find(str or "", '@')  
    local bstr = ""  
    local estr = ""  
    if b then  
        bstr = string.sub(str, 1, b-1)  
        estr = string.sub(str, e+1, -1)  
    else  
        return false  
    end  
  
    -- check the string before '@'  
    local p1,p2 = string.find(bstr, "[%w_]+")  
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end  
  
    -- check the string after '@'  
    if string.find(estr, "^[%.]+") then return false end  
    if string.find(estr, "%.[%.]+") then return false end  
    if string.find(estr, "@") then return false end  
    if string.find(estr, "%s") then return false end --空白符  
    if string.find(estr, "[%.]+$") then return false end  
  
    _,count = string.gsub(estr, "%.", "")  
    if (count < 1 ) or (count > 3) then  
        return false  
    end  
  
    return true  
end   

--[[
	判断参数是否为空
	1、参数是userdata类型
	2、参数是number\string\table等其他类型
]]
function CMIsNull(target)
	if type(target) == "userdata" then
		return tolua.isnull(target)
	else
		if target then
			return false
		else
			return true
		end
	end
end

---
-- 给一个Sprite更好换图片（实际为更换纹理）
--
-- @param target sprite对象
-- @string  image 图片路径
--
function CMSpriteImage(target, image)
	cc.Director:getInstance():getTextureCache():addImageAsync(image,
    function()
    	if not CMIsNull(target) then
	        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(image)
	        target:setTexture(texture)
	    end
    end)
end

---
-- 分辨率修正
--
-- @param target sprite对象
-- @param  scale 缩放比例
--
function CMFixScale(target, scale)
	if CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
		if not scale then
			target:scale(GV.CMDisplayScale)
		else
			target:scale(scale)
		end
	end
end

---
-- 打印日志到界面
--
-- @param target sprite对象
-- @param  scale 缩放比例
--
function CMPrintToScene(data, tag)
	if DEBUG > 1 then
		local scene = display.getRunningScene()
		if scene then
			if CMIsNull(GV.debugListPop) then
				GV.debugListPop = import("app.Tools.DebugLogPopup").new():addTo(scene, 9900)
			end
			GV.debugListPop:addData(data, tag)
		end
	end
end

---
-- 设置日志界面的tag
--
-- @string tag 标签字符
--
function CMPrintTag(tag)
	GV.debugTag = tag
end

-- CMPrintTag("dealTableInfoResp")