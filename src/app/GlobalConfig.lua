--[[
  RANCHES_VERSION START分支版本()
  ]]--
require("app.VersionConfig")
TENCENT_HALL  =  0   --腾讯版(0-9);
TENCENT_DESK  =  1
QZONE_HALL    =  2
QZONE_DESK    =  3
SAMSUNG_DESK  =  4   --三星版;
DEBAO_MIAN    =  100   --主站版(100-200);
CHINAMOBILEMM =  101   --中移动MM商城
CHINAUNICOM   =  102 --联通
PPSPLATFORM   =  103 --pps平台
ALIPAYOPEN    =  104 --支付宝钱包开放平台
DKBAIDU       =  105   --百度多酷
WIRELESS_91   =  106   --91无线
APPLESTORE    = "Apple Appstore"--appstore
APPLEJB       = "iOS Jailbreak1"--ios越狱渠道1

-- 存放一些全局配置
MAIN_PAGE_CALLBACK 		= "main_page_callback"  --主页回调
ENVIROMENT_NORMAL		= 1 --正式环境;
ENVIROMENT_TEST			= 2 --测试环境;
ENVIROMENT_PRE			= 3 --预发布环境;

BRANCHES_VERSION    = DEBAO_MIAN--//DEBAO_MIAN//CHINAMOBILEMM//TENCENT_WITH_PAY        //腾讯大厅版或独立版通过这个宏来改变;
-- 线下环境:0 线上环境:1
SERVER_ENVIROMENT = ENVIROMENT_NORMAL --ENVIROMENT_TEST ENVIROMENT_NORMAL
TRUNK_VERSION      = DEBAO_TRUNK
-- 是否开启调试Log--0:关闭  --1:开启
IS_DBLOG_ON = 1
-- 手机平台
DEBAO_IOS                    =  0 --ios
DEBAO_ANDROID                =  1 --android

DEBAO_PHONE_PLATFORM         =  DEBAO_ANDROID 
NEED_SNG                      =       true  --[[是否需要SNG]]
NEED_PRI_MTT          =       true  --[[是否需要德堡MTT]]
SHOW_FINAL_STATICS_ID    =       nil --[[私人局是否显示最终账单，牌局结束开启,为空不显示]]
SHOW_GIGESET    =       nil --[[私人局是否显示最终账单，牌局结束开启,为空不显示]]

function DBLog(...)
	if IS_DBLOG_ON==1 then
		print(...)
	end
end

function socket_send_log(command, params)
	if IS_DBLOG_ON==1 then
		print("[debao_socket_send] command: "..string.format("0x%08x", command).." params: "..params)
	end
end

function normal_info_log(pszFormat)
	if IS_DBLOG_ON==1 then
		print(os.date("%Y-%m-%d %H:%M:%S").." [debao_log_normal_info]"..pszFormat)
	end
end


function table_copy (tbl)
  	local new_tbl = {}
  	for key,value in pairs(tbl) do
   		local value_type = type(value)
   		local new_value
   		if value_type == "function" then
   			new_value = loadstring(string.dump(value))
   		 -- Problems may occur if the function has upvalues.
   		elseif value_type == "table" then
    		new_value = table_copy(value)
   		else
    		new_value = value
   		end
   		new_tbl[key] = new_value
  	end
  return new_tbl
end
table.copy = table_copy

function mysplit(inputstr, sep, tableSplit)
    if sep == nil then
        sep = "%s"
    end
    i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        tableSplit[i] = str
        i = i + 1
    end
    return tableSplit
end

function allNumber(str)
    local flag = true
    for index=1,#str do
        local tempStr = string.byte(str, index)
        if tempStr<string.byte("0") or tempStr>string.byte("9") then
            flag = false
            break
        end
    end
    return flag
end

SCREEN_IPHONE5 = false