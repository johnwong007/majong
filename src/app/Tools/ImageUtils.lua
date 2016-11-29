ImageUtils = {}

-- fix bug
--某些图片改为jpg了  统一用此方法更换图片名
function ImageUtils:getImageFileName(filename)
	if cc.FileUtils:getInstance():isFileExist(filename) then
        return filename
    else
    	return string.gsub(filename,".png",".jpg")
    end
end

function ImageUtils:getHeadImageDownloadUrl(imageUrl)
	if imageUrl and imageUrl~="" then
			local nTmp = nil
			for i=1,string.len(""..imageUrl) do
				if string.sub(imageUrl,i,i) == "/" then
					nTmp = i
				end
			end
			if(nTmp ~= nil) then
				-- self.m_filename = string.sub(imageUrl,nTmp+1)
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
				return path
				-- DBHttpRequest:downloadFile(handler(self,self.onHttpDownloadResponse),path)
			end
	end
	return ""
end

return ImageUtils