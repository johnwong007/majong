--
-- Author: junjie
-- Date: 2016-02-29 14:54:32
--
-- 当前版本号
-- 10848 Baidu
-- 10210 安卓主站
-- 20210 iOS
-- 10116 应用宝 
-- 10837 联通沃商店
-- 10839 魅族
-- 10838 畅梦科技(没有支付和登录,只做渠道包)
-- 10858 朋友玩
-- 10859 酷派
-- 10860 N多
-- 10861 悠悠村
-- 10862 木蚂蚁
-- 10863 乐天
-- 10864 上海沃豆科技 CPS包
-- 10865 北京极维客 CPS包
-- 10866 安趣 IOS渠道

package.loaded["app.Tools.QManagerPlatform"] = nil
package.loaded["app.Tools.QManagerScheduler"] = nil
package.loaded["app.Model.Login.MyInfo"] 		= nil
package.loaded["app.LangStringDefine"] 			= nil

QManagerPlatform   = require("app.Tools.QManagerPlatform"):getInstance({})
QManagerScheduler  = require("app.Tools.QManagerScheduler"):getInstance({})
local myInfo = require("app.Model.Login.MyInfo")
require("app.LangStringDefine")
DBVersion = "DeBao V1.0.00001"
DBChannel = string.sub(DBVersion,string.len(DBVersion)- 4,string.len(DBVersion)) 
DBVersion = string.gsub(DBVersion,DBChannel,QManagerPlatform:getTalkingdataString())	--版本号
DBChannel = string.sub(DBVersion,string.len(DBVersion)- 4,string.len(DBVersion)) 		--渠道号
DBPatchVersion   = string.gsub(string.gsub(DBVersion,"DeBao V",""),"."..DBChannel,"")   --补丁版本号
local allChannelVersion={
	["20210"] = "3.9",		--IOS整包更新版本
	["10001"] = "2.2",
	["10116"] = "2.2",
	["10210"] = "2.3",		--安卓主站
	["10238"] = "2.5",

	["10837"] = "2.2",
	["10838"] = "2.5",
	["10848"] = "2.5",
	["10851"] = "2.5",
	["10852"] = "2.5",

	["10853"] = "2.5",
	["10854"] = "2.5",
	["10855"] = "2.5",
	["10856"] = "2.5",
	["10857"] = "2.2",

	["10858"] = "2.2",
	["10859"] = "2.5",
	["10860"] = "2.5",
	["10861"] = "2.5",
	["10862"] = "2.5",
	["10863"] = "2.5",
	["11111"] = "2.5",
}
DBAPKVersion = allChannelVersion[DBChannel] 		--APK版本号设置

