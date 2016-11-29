QZONEDEFAULTIMAGEMD    ="c1bb6a4abacecb1ff0bbf838ab3a4e08"
QZONEDEFAULTIMAGEMDBIG ="03b42d62450ffcb05428b958512bea22"

HEADIMAGEPERMANENTDIR ="HeadImagePermanent"
HEADIMAGECACHEDIR     ="images/heads"

-- #if (TRUNK_VERSION==DEBAO_TRUNK)
-- DFAULTFILEPATHMAN     ="picdata/personFace/head1.png"
-- DFAULTFILEPATHWOMAN   ="picdata/personFace/head5.png"
-- DFAULTFILEPATH        ="picdata/personFace/head18.png"
-- #else
-- DFAULTFILEPATHMAN     ="picdata/personFace/head19.png"
-- DFAULTFILEPATHWOMAN   ="picdata/personFace/head19.png"
-- DFAULTFILEPATH        =""
-- #endif
DFAULTFILEPATHMAN     ="picdata/personFace/head1.png"
DFAULTFILEPATHWOMAN   ="picdata/personFace/head5.png"
DFAULTFILEPATH        ="picdata/personFace/head1.png"

REDDIAMOND            ="picdata/public/statusbar_41_hognzhuanshi_public_android.png"
YELLOWDIAMOND         ="picdata/public/statusbar_42_huangzhuanshi_public_android.png"
BlUEDIAMOND           ="picdata/public/statusbar_43_lanzhuanshi_public_android.png"

kUSERCHANGEHEADIMAGE	="kUSERCHANGEHEADIMAGE"
USER_CHANGE_HEAD_RESULT	="USER_CHANGE_HEAD_RESULT"

local HeadImage = class("HeadImage", function()
		return display.newSprite()
	end)

function HeadImage:createWithImageUrl(imagefileDir, imageUrl, imageSize, privilege, privilegeSize, headSex, judgeSex)
	
	judgeSex = judgeSex or false
	local sp = HeadImage:new()
	sp:initWith(imagefileDir, imageUrl, imageSize, privilege, privilegeSize, headSex, judgeSex)
	return sp
end

function HeadImage:initWith(imagefileDir, imageUrl, imageSize, privilege, privilegeSize, headSex, judgeSex)
	self.m_imagefileDir = imagefileDir
	self.m_imageUrl = imageUrl
	self.m_imageSize = imageSize
	self.m_privilege = privilege
	self.m_privilegeSize = privilegeSize
	self.m_needJudgeSex = judgeSex
	self.m_headSex = headSex
	if (TRUNK_VERSION==DEBAO_TRUNK) then
		self:changeHead(imageUrl)
	else
		self:addBackPhoto()
		self:requestUserHeadImage(imageUrl)
	end
end

function HeadImage:ctor()
	self.m_headSprite = nil
	self.m_imageUrl = ""
    
	self.m_VipSprite = nil
	self.m_privilege = 0
	self.m_imagefileDir = HEADIMAGECACHEDIR
    
	self.m_backSprite = nil
	self.m_gifHead = nil
	self.m_needJudgeSex = false
    
	self.m_bNeedNotify = false
    self.m_maskPath=""
end

function HeadImage:setOpacity(var)

	-- self:setOpacity(var)
    
	if(self.m_headSprite) then
	
		self.m_headSprite:setOpacity(var)
	end
    if (self.m_backSprite) then
        self.m_backSprite:setOpacity(var)
    end
end

function HeadImage:getVipStr(vipType)

	local vipString = ""
	if vipType==1 then
        vipString = YELLOWDIAMOND
    elseif vipType==2 then
        vipString = REDDIAMOND
    elseif vipType==3 then
        vipString = BlUEDIAMOND
	end
	return vipString
end

function HeadImage:LoadVipPhoto(privilege)

	local vipStr = self:getVipStr(privilege)
	if(vipStr=="") then
		return
	end
	if(self.m_VipSprite) then
		self:removeChild(self.m_VipSprite,false)
		self.m_VipSprite = nil
	end
	self.m_VipSprite= cc.Sprite:create(vipStr)
	self.m_VipSprite:setScaleX(self.m_privilegeSize.width/self.m_VipSprite:getContentSize().width)
	self.m_VipSprite:setScaleY(self.m_privilegeSize.height/self.m_VipSprite:getContentSize().height)
	self.m_VipSprite:setPosition(cc.p((self.m_imageSize.width-self.m_privilegeSize.width)/2,-(self.m_imageSize.height-self.m_privilegeSize.height)/2))
	self:addChild(self.m_VipSprite,11)
end

function HeadImage:formatHeadImageNameChar(imageUrl, illegalChar)

	local newImageUrl = ""
	local paths = {}
	paths = string.split(imageUrl,illegalChar)
	for i=1,#paths do
		newImageUrl = newImageUrl .. paths[i]
	end
	return newImageUrl
end

function HeadImage:formatHeadImageName(imageUrl)

	local newImageUrl = ""
	local newImageUrl1 = formatHeadImageNameChar(imageUrl,"/")
	local newImageUrl2 = formatHeadImageNameChar(newImageUrl1,"?")
	local newImageUrl3 = formatHeadImageNameChar(newImageUrl2,":")
	local newImageUrl4 = formatHeadImageNameChar(newImageUrl3,"*")
	local newImageUrl5 = formatHeadImageNameChar(newImageUrl4,"<")
	local newImageUrl6 = formatHeadImageNameChar(newImageUrl5,">")
	local newImageUrl7 = formatHeadImageNameChar(newImageUrl6,"|")
	local newImageUrl8 = formatHeadImageNameChar(newImageUrl7,"\"")
	local newImageUrl9 = formatHeadImageNameChar(newImageUrl8,"\\")
	return newImageUrl9
end

function HeadImage:getImageDir(fileName)

	--确定源文件位置
	local resPath = cc.FileUtils:getInstance():getWritablePath()
	local roomHeadFilePath = resPath .. self.m_imagefileDir
	local filePath = roomHeadFilePath+"\\"+fileName
	return filePath
end

function HeadImage:deleteHeadImage(imageUrl)

	--CCLOG("ImageUrl------------------------%s",imageUrl)
	local fileName = self:formatHeadImageName(imageUrl)
	local filePath = self:getImageDir(fileName)
    
	self:remove(filePath)
    
end

function HeadImage:requestUserHeadImage(imageUrl)
	normal_info_log(" HeadImage:requestUserHeadImage"..imageUrl)
	--imageUrl = "http:--q2.qlogo.cn/g?b=qq&k=lzvSX7JAv0MIXB7MhiakkTA&s=40&t=12563"
	if ((imageUrl=="")or(testHeadImage(imageUrl)==1)) then
	
		return
	end
	local fileName = self:formatHeadImageName(imageUrl)
	local filePath = self:getImageDir(fileName)
	--CCLOG("FilePath------------------------%s\n",filePath)
    
	local file = io.open(filePath,"r")
	if (not file) then
		--不存在就下载
		DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse),imageUrl, fileName)
	else
	
		--存在就读本地的
		io.close(file)
		self:addHeadPhoto(filePath)
	end
end

----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function HeadImage:onHttpDownloadResponse(event)
    local ok = (event.name == "completed") 
    if ok then 
        local request = event.request  
         local code = request:getResponseStatusCode()
         if not self.m_filename then return end
        local filename = cc.FileUtils:getInstance():getWritablePath().."images/heads/"..self.m_filename
         if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        -- print(code)

	         if CMCheckDirOK(cc.FileUtils:getInstance():getWritablePath().."images/") then
	         	if CMCheckDirOK(cc.FileUtils:getInstance():getWritablePath().."images/heads") then
		         	local filename = cc.FileUtils:getInstance():getWritablePath().."images/heads/"..self.m_filename
		        	CMWriteFile(filename, CMReadFile(cc.FileUtils:getInstance():fullPathForFilename("picdata/personFace/smhead18.png")))
		            self:changeHead(self.m_filename)
		        end
		     end
	         return
	    end
        if CMCheckDirOK(cc.FileUtils:getInstance():getWritablePath().."images/") then
        	if CMCheckDirOK(cc.FileUtils:getInstance():getWritablePath().."images/heads") then
		        request:saveResponseData(filename) 
		        self:changeHead(self.m_filename)
		    end
	    end
    end
end

function HeadImage:getDefaultHeadPath()

	if(TRUNK_VERSION == DEBAO_TRUNK) then
		if(self.m_needJudgeSex) then
			self.m_headDefaultPath = ""..((self.m_headSex == SEX_MAN) and (DFAULTFILEPATHMAN) or (DFAULTFILEPATHWOMAN))
		else
			self.m_headDefaultPath =  ""..(DFAULTFILEPATH)
		end
	else
		self.m_headDefaultPath = ""..((self.m_headSex == SEX_MAN) and (DFAULTFILEPATHMAN) or (DFAULTFILEPATHWOMAN))
	end
	return self.m_headDefaultPath
end

function HeadImage:addHeadPhotoBytexture(texture)

	if (self.m_headSprite) then
	
		self:removeChild(self.m_headSprite,false)
		self.m_headSprite = nil
	end
	self.m_headSprite = cc.Sprite:createWithTexture(texture)
	if (not self.m_headSprite) then
	
		self:addHeadPhoto("")
	else
	
		if (self.m_backSprite) then
		
			self:removeChild(self.m_backSprite,true)
		end
		self.m_headSprite:setScaleX(self.m_imageSize.width/self.m_headSprite:getContentSize().width)
		self.m_headSprite:setScaleY(self.m_imageSize.height/self.m_headSprite:getContentSize().height)
		self.m_headSprite:setPosition(cc.p(0,0))
		self:addChild(self.m_headSprite,4)
	end
end

function HeadImage:setMaskPath(path)

    self.m_maskPath=path
end

function HeadImage:getMaskPath()

    return self.m_maskPath
end


function HeadImage:maskedSprite(textureSprite)
    local maskSprite=nil
    
    if (self.m_maskPath ~= "") then
        maskSprite= cc.Sprite:create(self.m_maskPath)
    else
        maskSprite = cc.Sprite:create("picdata/table/maskedBG.png")
    end
    
    local renderTexture = cc.RenderTexture:create(maskSprite:getContentSize().width, maskSprite:getContentSize().height)
    
    maskSprite:setPosition(cc.p(maskSprite:getContentSize().width / 2, maskSprite:getContentSize().height / 2))
    textureSprite:setScale(maskSprite:getContentSize().width/textureSprite:getContentSize().width)
--    textureSprite:setPosition(cc.p(textureSprite:getContentSize().width / 2, textureSprite:getContentSize().height / 2))
    textureSprite:setPosition(cc.p(maskSprite:getContentSize().width / 2, maskSprite:getContentSize().height / 2))

    maskSprite:setBlendFunc(1, 0)
    textureSprite:setBlendFunc(0x0304, 0)
    
    renderTexture:begin()
    maskSprite:visit()
    textureSprite:visit()
    renderTexture:endToLua()
    
    local retval = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture())
    retval:setFlippedY(true)
    return retval
end

function HeadImage:addHeadPhoto(filePath)

	if (self.m_headSprite) then
	
		self:removeChild(self.m_headSprite,false)
		self.m_headSprite = nil
	end
    
	filePath = (filePath=="") and self:getDefaultHeadPath() or filePath
    
	self.m_headSprite=cc.Sprite:create(filePath)
    -- 	if (not self.m_headSprite)
    -- 	
    -- 		self.m_headSprite = (cc.Sprite*)EDynamicExpressionNode:dynamicExpressionNode(filePath)
    -- 	end
	if (not self.m_headSprite) then
	
		filePath = self:getDefaultHeadPath()
		self.m_headSprite = cc.Sprite:create(filePath)
	end
	if (self.m_backSprite) then
	
		removeChild(self.m_backSprite,true)
	end
	self.m_headSprite:setScaleX(self.m_imageSize.width/self.m_headSprite:getContentSize().width)
	self.m_headSprite:setScaleY(self.m_imageSize.height/self.m_headSprite:getContentSize().height)
	self.m_headSprite:setPosition(cc.p(0,0))
	self:addChild(self.m_headSprite,4)
    
end

function HeadImage:addBackPhoto()

	local filePath = self:getDefaultHeadPath()
	self.m_backSprite=self:maskedSprite(cc.Sprite:create(filePath))
	self.m_backSprite:setScaleX(self.m_imageSize.width/self.m_backSprite:getContentSize().width)
	self.m_backSprite:setScaleY(self.m_imageSize.height/self.m_backSprite:getContentSize().height)
	self.m_backSprite:setPosition(cc.p(0,0))
	self:addChild(self.m_backSprite,3)
end

function HeadImage:setNeedNotify(bNeed)

	self.m_bNeedNotify = bNeed
end
function HeadImage:changeHead(imageUrl, bFoceUpdate, headImageRoot)
	-- normal_info_log("HeadImage:changeHead 待完善，从服务下载图片，更新用户头像")
	-- dump(imageUrl)
	-- print(bFoceUpdate)
	-- print(headImageRoot)
	if imageUrl == nil then
		imageUrl = ""
	end
	bFoceUpdate = bFoceUpdate or false
	local strFile = ""
	if imageUrl then
		local headImageManager = require("app.Logic.HeadImage.HeadImageManager"):getInstance()
		if headImageRoot then
			local pattern = ".png"
			local m,n = string.find(headImageRoot,pattern)	
			if m then
				local mordern = "(.+)/"
				headImageRoot = string.gsub(headImageRoot,"(.+)/images","images")
				local i,j = string.find(headImageRoot,mordern)
				headImageRoot = string.sub(headImageRoot,i,j)
			end
		end

		headImageManager:setHeadImageRoot(headImageRoot)
		strFile = headImageManager:findHeadPath(imageUrl)
	end
	if(strFile=="" or bFoceUpdate) then
		--下载
		if imageUrl and imageUrl~="" then
			local nTmp = nil
			for i=1,string.len(""..imageUrl) do
				if string.sub(imageUrl,i,i) == "/" then
					nTmp = i
				end
			end
			if(nTmp ~= nil) then
				self.m_filename = string.sub(imageUrl,nTmp+1)
				local pattern = ".png"
				local m,n = string.find(imageUrl,pattern)	
				local headPath
				if m  then
				  	headPath = string.sub(imageUrl,1,m).."big.png"
				else
					headPath = imageUrl
				end
				--dump(headPath)
				local path = DOMAIN_URL..headPath
				DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse),path)
			end
		end
		imageUrl = self:getDefaultHeadPath()
	else
	
		imageUrl = strFile
	end

	local urlType = "png"
	if imageUrl ~= nil then
		local pos = 0
		for i=1,string.len(""..imageUrl) do
			if string.sub(imageUrl,i,i) == "." then
				pos = i
			end
		end
		urlType = string.sub(imageUrl,pos + 1)
	end

	if(urlType=="gif") then
	
		if(self.m_gifHead) then
		
			self:removeChild(self.m_gifHead,true)
			self.m_gifHead = nil
		end
		-- self.m_gifHead = EDynamicExpressionNode:dynamicExpressionNode(imageUrl)
		-- self.m_gifHead:setScaleX(self.m_imageSize.width/120)
		-- self.m_gifHead:setScaleY(self.m_imageSize.height/120)
		-- self.m_gifHead:setPosition(cc.p(0,0))
		-- self:addChild(self.m_gifHead,100)
        
		if(self.m_backSprite) then
		
			self.m_backSprite:setVisible(false)
		end
	else
	
		if(self.m_backSprite) then
		
			self:removeChild(self.m_backSprite,true)
			self.m_backSprite = nil
		end
        local blackTmpBG = cc.Sprite:create("picdata/public/blackTmpCircle.png")
        blackTmpBG:setScaleX(self.m_imageSize.width/blackTmpBG:getContentSize().width)
        blackTmpBG:setScaleY(self.m_imageSize.height/blackTmpBG:getContentSize().height)
        blackTmpBG:setPosition(cc.p(0,0))
        self:addChild(blackTmpBG,3)

        if imageUrl then
        	self.m_backSprite=self:maskedSprite(cc.Sprite:create(imageUrl))
			self.m_backSprite:setScaleX(self.m_imageSize.width/self.m_backSprite:getContentSize().width)
			self.m_backSprite:setScaleY(self.m_imageSize.height/self.m_backSprite:getContentSize().height)
			self.m_backSprite:setPosition(cc.p(0,0))
			self:addChild(self.m_backSprite,3)
        end
		if self.m_gifHead then
			self.m_gifHead:setVisible(false)
		end
	end
    
end

function HeadImage:testHeadImage(imageUrl)
	local tmpstring = {}
	tmpstring[1] = "1"
	tmpstring[2] = "2"
	tmpstring[3] = "3"
	tmpstring[4] = "4"
	tmpstring[5] = "5"
	tmpstring[6] = "6"
	tmpstring[7] = "7"
	tmpstring[8] = "8"
	tmpstring[9] = ""
	tmpstring[10] = "None"
	local pictag=-1
	for i=1,10 do
	
		local strc = string.find(imageUrl,tmpstring[i])
		if strc then
			pictag = i
			break
		end
	end
	local testr = 0
	if (pictag ~=-1) then
	
		--addHeadPhoto(defaultFilePath)
		testr = 1
	end
	return testr
end

return HeadImage