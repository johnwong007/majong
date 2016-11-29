--
-- Author: junjie
-- Date: 2015-11-23 14:53:39
--
--[[发送http请求]]
local NetCallBack = {}
m_Session = ""
function NetCallBack:doSend(callback, tag, server, method, params,otherUrl,requestHeaderrs)
	local url = SERVER_URL

	if m_Session~=nil and m_Session~="" then
		url = url.."?"
		url = url..PHPSESSID
		url = url.."="..m_Session
	else
		url = url
	end
	-- url = url.."&method="..server.."/"..method
	local postData = "method="..server.."/"..method

	if params~=nil and requestHeaderrs == nil then
		-- url = url..params
		postData = postData..params
	end
	--[[otherSend]]--
	if otherUrl then 
		if requestHeaderrs ~=nil then
			url = otherUrl -- 融云等直接用url地址,参数放post body里面的调用方式
		else
			url = otherUrl..(params or "")
		end
	end
	if GTest then 
		--dump(callback)
	end
	----------------
	local request = nil
	request = network.createHTTPRequest(function (event) self:onCallback(event,callback,tag) end,url,"POST")
	request.tag=tag

	if otherUrl == nil then
		request:setPOSTData(postData)
	end
	if requestHeaderrs ~=nil then
			-- request:setPOSTData(postData) -- 融云等直接用url地址,参数用表单提交
			for k,v in pairs(params) do
				request:addPOSTValue(k,v)
			end

	end
	
	if request then
		if requestHeaderrs then
			if device.platform == "android" then
				for k,v in pairs(requestHeaderrs) do
					request:addRequestHeader(k.."="..v)
				end
			else	
				for k,v in pairs(requestHeaderrs) do
					request:addRequestHeader(k..":"..v);
				end	
			end
		end
		if not NetCallBack.m_pLoadingView then
			NetCallBack.m_pLoadingView = require("app.GUI.BuyLoadingScene"):new()
			NetCallBack.m_pLoadingView:setVisible(false)
	    	GameSceneManager:getCurScene():addChild(NetCallBack.m_pLoadingView, 1000,999)
	    	CMDelay(NetCallBack.m_pLoadingView,2,function () if NetCallBack.m_pLoadingView then NetCallBack.m_pLoadingView:setVisible(true) end end)
	    end
		request:setTimeout(30)
		request:start()
	end
end

function NetCallBack:setSession(session)
	m_Session = session
end

function NetCallBack:onCallback(event,callback,tag)
	if event.name ~= "progress" and event.name ~= "cancelled" then
		-- http请求成功回调/失败回调
	    local successCallback
	    local failCallback
	    if type(callback) == "table" then
	    	successCallback = callback[1]
	    	failCallback = callback[2]
	    else
	    	successCallback = callback
	    end

		local ok = (event.name == "completed")
	    local request = event.request

	    if NetCallBack.m_pLoadingView then 
	    	if GameSceneManager:getCurScene():getChildByTag(999) then
	    		NetCallBack.m_pLoadingView:removeFromParent()
	    	end
	    	NetCallBack.m_pLoadingView = nil
	    end

	    if not ok then
	        -- 请求失败，显示错误代码和错误消息
	        require("app.Network.Socket.TcpCommandRequest")
		    local tcpRequest = TcpCommandRequest:shareInstance()
		    tcpRequest:showInterConnect(true)
		    if failCallback then
		    	failCallback(request:getErrorCode(), tag)
		    end
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        -- print(code)
	        if failCallback then
	        	failCallback(code, tag)
	        end
	        return
	    end
	     -- 请求成功，显示服务端返回的内容
	    local response = request:getResponseString()

	    local jsonTable = json.decode(response)

		if successCallback then
			successCallback(jsonTable,tag)
		end
	end
end

--[[文件下载]]
--[[
	callbcak:回调方法
	url：下载路径
	tag：返回tag
	filePathAndName：保存路径＋名字
	progress：类似TAG，下载进度
	]]
function NetCallBack:doDownloadSend(callback, url, tag,filePathAndName,progress)
	local request = nil
	request = network.createHTTPRequest(function (event) self:onDownloadCallback(event,callback,filePathAndName,progress) end,url,"GET")
	request.tag=tag
	if request then
		request:setTimeout(30)
		request:start()
	end
end

function NetCallBack:onDownloadCallback(event,callback,filePathAndName,progress)

	local ok = (event.name == "completed")
    local request = event.request
 

    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
     -- 请求成功，显示服务端返回的内容
    local request = event.request  

 	local isCreateSuccess,fileName = self:createDownPath(filePathAndName)

 	if isCreateSuccess then
	--local filename = cc.FileUtils:getInstance():getWritablePath()--..filePathAndName
		request:saveResponseData(fileName) 
		if callback then
			callback(request.tag,progress,fileName)
		end
	end
end

--[[
	目录创建
	pathAndName:路径+文件名
	idx: 目录开始创建层级
]]
function NetCallBack:createDownPath(pathAndName)

	idx = 1
	local index = string.find(pathAndName,"/images")

	local splitPath = string.sub(pathAndName,index,string.len(pathAndName))
	local data = string.split(splitPath,"/")
	local oldPath = cc.FileUtils:getInstance():getWritablePath()..data[idx]
	--idx 
	while idx < #data do
		if CMCheckDirOK( oldPath ) then
			idx = idx + 1
			oldPath = oldPath .."/".. data[idx]
			--dump(oldPath)
		else
			return false
		end
	end

	return true,oldPath
end

--[[
	判断是否存在文件 
	pathAndName ：路径 ＋ 文件名，
	idx：		 保存所在的路径层级
]]
function NetCallBack:getCacheImage(pathAndName)
	local index = string.find(pathAndName,"/images") 
	if not index then 
		pathAndName = "/images" .. pathAndName
		index = string.find(pathAndName,"/images")
	end
	local splitPath = string.sub(pathAndName,index,string.len(pathAndName))
	local data = string.split(splitPath,"/")

	local newPath = ""
	idx = 1
	for i = idx,#data do
		newPath = newPath .. "/"..data[i]
	end

	local filePath = cc.FileUtils:getInstance():getWritablePath()..newPath
	local file     = io.open(filePath,"r")
	if file then
		io.close(file)
		return true,filePath
	else
		return false
	end
end
return NetCallBack