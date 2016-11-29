UserConfig = {}

	UserConfig.forceSelectMatch = false --[[forece user select first match for 91 version]]
	UserConfig.enteredRoom = false --[[是否进过牌桌，用户安全设置引导判断项]]
	UserConfig.reqShowInfo = false --[[主页是否请求过现实信息]]
	UserConfig.getAffichesSign = false --[[主页是否请求公告]]
	UserConfig.noReadAffichesIDs = {} --[[未读公告ID列表]]

	UserConfig.openid=""
	UserConfig.access_token=""
	UserConfig.pf=""
	UserConfig.pfkey=""
	UserConfig.pay_token=""
	UserConfig.zoneid=""
	UserConfig.format=""
	UserConfig.appid=""
	UserConfig.goodsname=""
	UserConfig.orderId=""
	UserConfig.asynCallBack=""
	UserConfig.price=""

	GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.USERCONFIG, UserConfig, true)
	
	return UserConfig