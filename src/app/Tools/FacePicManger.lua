local FacePicManger = class("FacePicManger")

sharedFacePicManger = nil
function FacePicManger:getInstance()
	if not sharedFacePicManger then
		sharedFacePicManger = FacePicManger:new()
	end
	return sharedFacePicManger
end

function FacePicManger:ctor()

end

function FacePicManger:getFaceByName(name)
	-- local path = cc.FileUtils:getInstance():getWritablePath().."images/faces/face/"..name..".png"
	-- local zipFileName = cc.FileUtils:getInstance():getWritablePath().."images/faces/face.zip"
	-- local zipFilePath = cc.FileUtils:getInstance():getWritablePath().."images/faces/face/"
	
	-- local path = device.writablePath.."images/faces/face/"..name..".png"
	-- local zipFileName = device.writablePath.."images/faces/face.zip"
	-- local zipFilePath = device.writablePath.."images/faces/face/"
	
	-- if not self:checkFile(path) then
	-- 	if not self:checkFile(zipFileName) then
	-- 		return false
	-- 	end
	-- 	cc.FileUtils:getInstance():uncompressDir(zipFileName, zipFilePath)
	-- 	return cc.ui.UIImage.new(path)
	-- end
	local path = "picdata/face/"..name..".png"
	return cc.ui.UIImage.new(path)
end

function FacePicManger:checkUncompress()
	-- local path = cc.FileUtils:getInstance():getWritablePath().."images/faces/face/1.png"
	-- local zipFileName = cc.FileUtils:getInstance():getWritablePath().."images/faces/face.zip"
	-- local zipFilePath = cc.FileUtils:getInstance():getWritablePath().."images/faces/face/"

	local path = device.writablePath.."images/faces/face/1.png"
	local zipFileName = device.writablePath.."images/faces/face.zip"
	local zipFilePath = device.writablePath.."images/faces/face/"
	
	if not self:checkFile(path) then
		if not self:checkFile(zipFileName) then
			return nil
		end
		cc.FileUtils:getInstance():uncompressDir(zipFileName, zipFilePath)
		return true
	end
	return true
end

function FacePicManger:checkFile(fileName)
    if not io.exists(fileName) then
        return false
    end

    local data=self:readFile(fileName)
    if data==nil then
        return false
    end
    return true
end

function FacePicManger:readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

return FacePicManger