local tmp_token= "2B533E1676A081231B793B6FB86E46A9"
local tmp_secret="55CBD13AB4444059C4D5E64101ECD690"
local tmp_openkey="64206e7fb4903001"

s_Android_MacAddr = ""
s_Android_LoginIp = ""

tencentValue = {}

tencentValue.tencent_token = tmp_token
tencentValue.tencent_secret = tmp_secret
tencentValue.tencent_openkey = tmp_openkey

function tencentValue:LoginIp()
	return s_Android_LoginIp
end

function tencentValue:AndroidMac()

	return s_Android_MacAddr
end
function tencentValue:LoginIp()

	return s_Android_LoginIp
end

function tencentValue:TOKEN()

	return self.tencent_token
end
function tencentValue:SECRET()

	return self.tencent_secret
end
function tencentValue:KEY()

	return self.tencent_openkey
end

return tencentValue