require("app.GlobalConfig")
-- http服务器地址 线下:0  线上:1
if SERVER_ENVIROMENT==ENVIROMENT_TEST then
	-- 图片
	IMGSERVICEURL = "http://debaocache.boss.com/style/images/match/"
	-- 域
	DOMAIN_URL  =   "http://debao.boss.com"
	-- DOMAIN_URL  =    g_ServerIP
	-- 接口
	SERVER_URL   =  DOMAIN_URL .. "/service/router.php"
	-- SERVER_URL   =  "http://www.debao.com/service/router.php"		--线上
	UPLOAD_URL	 =	"http://debao.boss.com/index.php?act=upload&mod=portrait&uid="
elseif SERVER_ENVIROMENT==ENVIROMENT_NORMAL then
	-- 图片
	IMGSERVICEURL = "http://cache.debao.com/style/images/match/"
	-- 域
	 DOMAIN_URL  =   "http://www.debao.com"
	--DOMAIN_URL = "http://119.147.211.234"
	-- 接口
	 SERVER_URL   =  "http://www.debao.com/service/router.php"
	--SERVER_URL   =  "http://119.147.211.234/service/router.php"

	UPLOAD_URL	 =	"http://www.debao.com/index.php?act=upload&mod=portrait&uid="

end

BIZ_PARS_JSON_SUCCESS                         =0
BIZ_PARS_JSON_FAILED                          =-1

 PHPSESSID     =        "PHPSESSID" --登录用户session;
 POST_COMMAND_EMPTY                            =100000      -- 空指令
 POST_COMMAND_LOGIN                            =100001      -- 登录指令
 POST_COMMAND_REGISTE                          =100002      -- 注册指令
 POST_COMMAND_TOURISTTURNDEBAO				  =100198	-- 游客绑定
 POST_UPDATE_PASSWORD						  =100199	--更改密码
 POST_COMMAND_CHECKGAMESESSION                 =100003      -- 检测game session是否有效
 POST_COMMAND_GETUSERINFO    	              =100004      -- 玩家信息查询
 POST_COMMAND_GETUSERSHOWINFO                  =100005      -- 玩家显示信息查询
 POST_COMMAND_GETUSERPROVINCE                  =100006      -- 获取玩家省份
 POST_COMMAND_GETACCOUNTINFO                   =100007      -- 获取用户帐户信息
 POST_COMMAND_GETALLACCOUNTINFO                =100008      -- 获取所有用户帐户信息
 POST_COMMAND_GETMYBALANCEBYTABLE              =100009      -- 获取用户在该牌桌（现金桌）对应币种的余额
 POST_COMMAND_TOURISTUSERLOGIN                 =100010      -- 游客登陆
 POST_COMMAND_GETBONUSINFOBYNAME               =100011      -- 根据奖金分配名取奖金分配信息
 POST_COMMAND_GETGAININFOBYNAME                =100012      -- 根据物品分配名取物品分配信息
 POST_COMMAND_GETGOODNAME                      =100013      -- 根据物品id获取物品名称
 POST_COMMAND_GETPRIZEPOOL                     =100014      -- 获取赛事当前彩池
 POST_COMMAND_GETPRIZEINFO                     =100015      -- 获取固定人数下的奖池分配（返回具体奖金）
 POST_COMMAND_GETLOGINAWARDINFO                =100016      -- 查询用户是否可以领取登录奖励(腾讯版)
 POST_COMMAND_FETCHLOGINREWARD                 =100017      -- 用户每天登录游戏领奖
 POST_COMMAND_GETMYLEVELINFO                   =100018      -- 获取我的等级、年度/月度经验
 POST_COMMAND_GETMYMILESTONEINFO               =100019      -- 获取我的里程碑信息
 POST_COMMAND_GETUSEREXPMILESTONELIMITLIST     =100020      -- 获取用户有资格的里程碑列表
 POST_COMMAND_GETANNOUNCELIST                  =100021      -- 获取公告(列表)
 POST_COMMAND_GETANNOUNCEINFO                  =100022      -- 获取单条公告
 POST_COMMAND_RECORDCLIENTEXCEPTINAL           =100023      -- 记录客户端异常
 POST_COMMAND_GETPLAYERNOTEINFO                =100024      -- 查询玩家备注信息
 POST_COMMAND_INSERTPLAYERMANAGER              =100025      -- 添加玩家备注信息
 POST_COMMAND_UPDATEPLAYERNOTEINFO             =100026      -- 修改玩家备注信息
 POST_COMMAND_DELETEPLAYERNOTEINFO             =100027      -- 删除玩家备注信息
 POST_COMMAND_GETSERVERTIME                    =100028      -- 获取服务器时间(unix时间戳<秒>)
 POST_COMMAND_GETMATCHLIST                     =100029      -- 获取锦标赛列表
 POST_COMMAND_APPLYMATCH                       =100030      -- 报名参加锦标赛 报名需要先登录
 POST_COMMAND_QUITMATCH                        =100031      -- 退出锦标赛
 POST_COMMAND_GETMATCHINFO                     =100032      -- 赛事详情查询
 POST_COMMAND_GETIMMTABLELIST                  =100033      -- 现金赛牌桌列表
 POST_COMMAND_GETDIYTABLELIST                  =100033      -- 私人牌桌列表
 POST_COMMAND_GETMATCHUSERLIST                 =100034      -- 赛事玩家列表查询
 POST_COMMAND_GETAPPLYMATCH                    =100035      -- 玩家已报名赛事查询
 POST_COMMAND_GETTABLEINFO                     =100036      -- 查询牌桌信息
 POST_COMMAND_GETTABLELIST                     =100037      -- 赛事牌桌列表查询
 POST_COMMAND_GETMATCHTABLEUSERLIST            =100038      -- 牌桌玩家列表查询(锦标赛)
 POST_COMMAND_GETCASHTABLEPLAYANDWAITUSERLIST  =100039      -- 牌桌在玩和等待的玩家列表查询(现金赛)
 POST_COMMAND_GETUSERONLINECOUNT               =100040      -- 用户在线人数
 POST_COMMAND_GETSTARTEDTABLENUM               =100041      -- 开赛牌桌数量
 POST_COMMAND_GETBLINDDSINFO                   =100042      -- 盲注结构
 POST_COMMAND_GETPRIZEDSINFO                   =100043      -- 奖项结构
 POST_COMMAND_GETAPPLYSTATUS                   =100044      -- 获取用户是否报名某赛事
 POST_COMMAND_GETUSERMANAGER                   =100045      -- 获取用户某个赛事正在进行的牌桌
 POST_COMMAND_GETUSERTABLELIST                 =100046      -- 获取用户所有正在进行的牌桌
 POST_COMMAND_BUYIN                            =100047      -- 现金桌买入
 POST_COMMAND_REBUY                            =100048      -- 再次买入
 POST_COMMAND_CHECKWAITINGLIST                 =100049      -- 查询自己是否在指定牌桌的等待玩家列表中
 POST_COMMAND_GETUSERCASHCHIPS                 =100050      -- 获取用户在桌子上的筹码（各币种余额）
 POST_COMMAND_GETMOBILEMATCHINFO               =100051      -- 根据级别（按报名费+服务费）获取合适的淘汰赛
 POST_COMMAND_QUICKSTART                       =100052      -- 现金桌快速入桌入座* 	根据用户的账户余额情况，帮玩家选取一个现金桌及座位号
 POST_COMMAND_GETMATCHAPPLYUSERCOUNT           =100053      -- 获取赛事当前报名人数（为手机客户端提供
 POST_COMMAND_CHECKPHPSESSION                  =100054      -- 根据cookie检测是否登录（仅用于flash）
 POST_COMMAND_GETBONUSINFO                     =100055      -- 获取固定人数下的奖池分配
 POST_COMMAND_FIND_MY_PASSWORD                 =100056      -- 找回密码
 POST_COMMAND_GETMOBILESUITABLEMATCH           =100060      --根据级别（按报名费+服务费）获取合适的淘汰赛
 POST_COMMAND_PRODUCTORDER                     =100061      --生成订单号
 POST_COMMAND_GETACCOUNTDETAILINFO             =100062      -- 获取账户明细
 POST_COMMAND_TOURIST_GIFT                     =100063      -- 领取游客第一次登录奖励
 POST_COMMAND_HUD                              =100064      -- Head Up Display 玩家数据分析
 POST_COMMAND_HUDFORMOBILE                     =100065      -- 单个玩家数据分析（用户手机客户端）
 POST_COMMAND_GETUSERTYPE                      =100066      -- 获取数据分析功能的用户类型
 POST_COMMAND_UPDATEUSERSETTING                =100067      -- 更新数据分析用户设置
 POST_COMMAND_APPLYFRIEND                      =100068      -- 申请好友（申请后，系统会自动发送一条添加好友的私信给对方)
 POST_COMMAND_ADDFRIEND                        =100069      -- 添加好友（对方申请好友后，才能添加）
 POST_COMMAND_REFUSEFRIEND                     =100070      -- 拒绝好友请求
 POST_COMMAND_REMOVEFRIEND                     =100071      -- 删除好友
 POST_COMMAND_ISFRIEND                         =100072      -- 是否好友
 POST_COMMAND_GETFRIENDSLIST                   =100073      -- 获取我的好友列表
 POST_COMMAND_GETFRIENDSLISTINFO               =100074      -- 获取我的好友列表（包括牌桌、头像、等级等信息）
 POST_COMMAND_GETFRIENDSNUMS                   =100075      -- 获取我的好友总数
 POST_COMMAND_GETFRIENDMESSAGEGROUPBYUSER      =100076      --按用户获取我的好友消息列表
 POST_COMMAND_GETFRIENDMESSAGE                 =100077      -- 获取与指定用户的往来私信
 POST_COMMAND_GETSYSTEMMESSAGE                 =100078      -- 获取我的系统消息
 POST_COMMAND_GETMESSAGENOTREADCOUNT           =100079      -- 获取私信未读数量
 POST_COMMAND_READSINGLEMESSAGE                =100080      -- 设置单条私信已读
 POST_COMMAND_READFRIENDMESSAGE                =100081      -- 设置某个好友或全部好友私信已读
 POST_COMMAND_READSYSTEMMESSAGE                =100082      -- 设置全部系统私信已读
 POST_COMMAND_SENDPRIVATEMESSAGE               =100083      -- 发送私信（给好友）
 POST_COMMAND_DELETEMSGBYIDASRECEIVER          =100084      --  删除一条指定的他人发给我的私信
 POST_COMMAND_DELETEMSGBYIDASSENDER            =100085      -- 删除一条指定的我发给他人的私信
 POST_COMMAND_DELETEUSERSMESSAGE               =100086      -- 删除与指定用户的往来私信
 POST_COMMAND_DELETESOMEPRIVATEMESSAGES        =100087      --删除指定的多条私信
 POST_COMMAND_DELETESOMEUSERSMESSAGE           =100088      --删除指定的多个发送者的私信
 POST_COMMAND_ADDCONCERN                       =100089      --添加关注
 POST_COMMAND_REMOVECONCERN                    =100090      --取消关注
 POST_COMMAND_DOICONCERNHIM                    =100091      -- 我关注他吗？ Do I concern him ?
 POST_COMMAND_DOESHECONCERNME                  =100092      -- 他关注我吗？Does he concern me ?
 POST_COMMAND_DOWECONCERNEACHOTHER             =100093      --我们互相关注吗？ Do we concern each other ?
 POST_COMMAND_GETCONCERNLIST                   =100094      --获取我的关注列表 （不包括已经是好友的玩家）
 POST_COMMAND_GETCONCERNLISTINFO               =100095      --获取我的关注列表（包括牌桌、头像、等级等信息）（不包括已经是好友的玩家）
 POST_COMMAND_GETUSERCOMPETITORLIST            =100096      --获取我的同桌列表
 POST_COMMAND_GETUSERCOMPETITORLISTINFO        =100097      --获取我的同桌列表（包括牌桌、头像、等级等信息）
 POST_COMMAND_GETRELATIONS                     =100098      --查询与指定玩家的关系
 POST_COMMAND_GETPLAYERTABLELISTINFO           =100099      --查询一个玩家的进行中的牌桌列表信息（包括现金桌、锦标赛、坐满即玩） 返回该玩家进行中的牌桌列表信息（最多返回4个）
 POST_COMMAND_FRESHGUIDE                       =100100      --完成新手向导领奖
 POST_COMMAND_SETUSERSEX                       =100101      --设置性别
 POST_COMMAND_UPGRADE                          =100102      --检查升级
 POST_COMMAND_GETUSERSEX                       =100103      --获取用户性别
 POST_COMMAND_GETUSRETABLELISTMOBILE           =100104      --获取用户不同赛事牌桌信息列表
 POST_COMMAND_GETROOKIEPROTECTIONCONFIG        =100105      --破产保护
 POST_COMMAND_FETCHROOKIEPROTECTION            =100106      --领取新手破产保护奖励
 POST_COMMAND_CLIENTREPORT                     =100107      --客户端报告
 POST_COMMAND_QQUSERINFO                       =100108      --腾讯联运手机版用户登录
 POST_COMMAND_GETQQUSERINFO                    =100109      --获取QQ用户的昵称和图像信息
  POST_COMMAND_GETMYHANDSSUM                   =100110      --获取我的当天的牌局数
  POST_COMMAND_GETHANDCONFIG                   =100111      --获取手牌奖励信息配置
  POST_COMMAND_SELECTACTIVITYINFO              =100112      --查询指定活动id的奖励资格信息
  POST_COMMAND_TAKEACTIVITYMONEY               =100113      --领取指定活动id的奖励
 POST_COMMAND_GETHANDSNUM	              	  =100114      --获取玩家总手数
 POST_COMMAND_GETUSERTIMEWONINFO               =100116      --获取盈利时间曲线图信息
 POST_COMMAND_GETUSERPROFITRANKING             =100117      --获取排名信息
 POST_COMMAND_GETIMMTABLELISTNEW               =100118      --现金赛牌桌列表
 POST_COMMAND_QUICKSTART_TABLELIST             =100119      --牌桌列表快速进入牌桌
 POST_COMMAND_GETNEWACTIVITYINFO               =100120
 POST_COMMAND_GETNEWONEACTIVITYINFO			  =100121
 POST_COMMAND_GETALLNOTICEINFO				  =100122
 POST_COMMAND_GETNOREADEDNOTICENUM			  =100123      --获取未读公告/消息的数量
 POST_COMMAND_GETACTIVITYLIST					=100124  --获取活动列表
 POST_COMMAND_GETACTIVITYCONTENT					=100125	--获取活动具体内容
 POST_COMMAND_DOWNLOADFILE						=100126 --下载文件
 POST_COMMAND_GETSERVERID						=100127 --获取腾讯服务器ID
 POST_COMMAND_GETBUYHISTORY						=100128
 POST_COMMAND_GETDEBAOCOIN						=100129
 POST_COMMAND_CHARGE								=100130
 POST_COMMAND_GETPAYCONTROL						=100131
 POST_COMMAND_GETITEMLIST						=100132
 POST_COMMAND_GETGOODSLIST						=100140
 POST_COMMAND_GETUSERPROPSLIST					=100141
 POST_COMMAND_BUYGOODS							=100142
 POST_COMMAND_USEPROPS							=100143
 POST_COMMAND_MAKEVOERPROPS						=100144
 POST_COMMAND_PROFITRANKLIST                     =100145--普通场盈利排行;
 POST_COMMAND_CHAMPIONRANKLIST                   =100146--锦标赛积分排行;
 POST_COMMAND_CHAMPIONSHIPLIST                   =100147--大厅锦标赛;
 POST_COMMAND_NEWGETACTIVITYLIST					=100150  --新获取活动列表;
 POST_COMMAND_BINDQQ								=100151	--绑定QQ;
 POST_COMMAND_GETLOTTERYCHANCES					=100152
 POST_COMMAND_GETMATCHDETAIL						=100153
 POST_COMMAND_LOGINLOTTERY						=100154
 POST_COMMAND_GETACTIVITYNOTREADNUM				=100155 --读取未读取活动数量;
 POST_COMMAND_UPDATEUSERPORTRAIT					=100156 --头像;
 POST_COMMAND_TOTALBALANCEBOARD					=100157 --资产排行;
 POST_COMMAND_DATAREPORT							=100158 --数据上报(统计用户行为);
 POST_COMMAND_GETACTIVITYPRIZE					=100159 --获取活动奖励;
 POST_COMMAND_GETSERVERPORT						=100160 --获取腾讯服务器Port;
 POST_COMMAND_UPDATECLIENTTYPE					=100161 --客户端上报版本;
 POST_COMMAND_GETGOODSNAME                       =100162
 POST_COMMAND_GETMATCHADCTR                      =100163
 POST_COMMAND_LOGINLOTTERYNEW                    =100164
 POST_COMMAND_ISNEWYEAR                          =100165
 POST_COMMAND_LOGINREWARD                        =100166 --领取登录奖励;
 POST_COMMAND_HAPPYHOUR_INFO                     =100167 --happyHour转盘抽奖;
 POST_COMMAND_HAPPYHOUR_REWARD                   =100168 --happyHour转盘抽奖反馈;
 POST_COMMAND_GETBULLETIN                        =100169 --获取商城和大厅广告位;
 POST_COMMAND_GETLOGINAWARDRULES                 =100179 --获取登录奖励规则;
 POST_COMMAND_QUICKSTART_NEW						=100180 --新的快速开始(主站版);
 POST_COMMAND_GETUSERMATCHANALYSIS               =100181--赛事统计
 POST_COMMAND_BALANCERANKLISTINFO                =100182--余额排行
 POST_COMMAND_PROFITRANKLISTINFO                 =100183--盈利排行
 POST_COMMAND_POINTRANKLISTINFO                  =100184--积分排行
 POST_COMMAND_LEVELRANKLISTINFO					=100187--牌手分
 POST_COMMAND_GETTASKLIST                        =100185--获取玩家的任务列表
 POST_COMMAND_GETTASKPRIZE                       =100186--领取任务奖励
 POST_COMMAND_TASK_HAPPYHOUR_INFO                =100189 --happyHour和任务配置
 POST_COMMAND_DEBAOCARD                          =100190      --德堡充值卡
 POST_COMMAND_PHONECARD                          =100191      --手机充值卡
 POST_COMMAND_LLPAY_CHARGINGORDER			    =100500		--连连支付下单
 POST_COMMAND_ZBF_CHARGINGORDER			        =100196		--支付宝下单
 POST_COMMAND_MM_CHARGINGORDER			            =100197		--移动话费下单
 POST_COMMAND_YDQB_CHARGINGORDER					=100195			--移动钱包下单
 POST_COMMAND_GETLOGINREWARDINFO					=100198      -- 查询用户是否可以领取登录奖励（主站版）
 POST_COMMAND_GETPORTRAITPICS					=100199		--图像列表
 POST_COM_GETROOKIEPROTECTIONCONFIG				=100200		--获取破产配置;
 POST_COM_UPDATE_USER_INFO				        =100201		--修改用户信息;
 POST_COM_GET_USER_CHARGE_INFO				    =100202		--获取用户充值记录信息;
 POST_COMMAND_GETLOGINCONTROL					=100203		--获取500wan，QQ登录方式是否开启;
 POST_COMMAND_BINDEMAIL							=100204	--绑定QQ;
 POST_COMMAND_CHARGESUCREQUESTGOODS				=100205		--支付成功通知服务器发货
 POST_COMMAND_GETACTIVITYNOTIFY					=100206
 POST_UPLOAD_FORM_FILE							=100207     --上传头像;
 POST_FINISH_GAME_TECH							=100208     --完成新手向导领奖
 POST_COMMAND_GETMOBILEVERIFYCODE				=100209		--获取验证码
 POST_COMMAND_BINLDMOBILE						=100210		--绑定手机
 POST_COMMAND_UNIPAY_CHARGINGORDER				=100212		--联通支付下单
 POST_COMMAND_RUSHBUYIN                          =100211      --Rush牌桌玩家买入
 POST_COMMAND_UPOMP_CHARGINGORDER				=100213		--银联支付
 POST_COMMAND_GETFRIENDSMESSAGE					=100214		--好友消息
 POST_COMMAND_GETRANKPIC							=100215		--排行榜图片
 POST_COMMAND_SETSHOWNOTIFY						=100216		--是否显示活动公告
 POST_COMMAND_GETSPLASH							=100217		--获取闪屏信息
 POST_COMMAND_PPS_CHARGINGORDER					=100218		--pps支付
 POST_COMMAND_DK_CHARGINGORDER					=100219		--多酷支付
 POST_COMMAND_ALIPAYOPEN_CHARGINGORDER           =100220      --阿里巴巴支付
 POST_COMMAND_WAP_CHARGINGORDER					=100221		--微派支付
 POST_COMMAND_TENPAY_CHARGINGORDER               =100222      --财付通
 POST_COMMAND_CHAT_FACE_INFO                     =100223      --聊天表情信息
 POST_COMMAND_FIRST_PAY_RATE                     =100224      --首充奖励配置
 POST_COMMAND_BroadCastMatchList                 =100225      --获取手机轮播推荐赛事
 POST_COMMAND_ApplyedMatch                         =100226      --玩家已报名赛事查询
 POST_COMMAND_UserTicketList                     =100227 --获取玩家的门票列表
 POST_COMMAND_UserTicketImage                     =100228--获取门票图片信息

 POST_COMMAND_GETUSERSNGPKINFO					=100229		--取用户连胜信息
 POST_COMMAND_GETSNGPKMATCHINFO					=100230		--pk赛配置

 POST_COMMAND_GETLOGINCONFIG						=100231		--登陆配置

 POST_COMMAND_APPLYSNGPK							=100232		--报名pk赛
 POST_COMMAND_91DPAY_CHARGINGORDER				=100234		--91点金充值
 POST_COMMAND_GETSNGPKBULLETIN					=100235		--pk赛广告
 POST_COMMAND_APPLE_CHARGINGORDER				=100238		--苹果商城金充值
 POST_COMMAND_APPPAYNOTIFYSERVER                 =100239  --苹果支付发货通知

 POST_COMMAND_BAIDU_CHARGINGORDER       = 100302 --百度渠道下单
 POST_COMMAND_MEIZU_CHARGINGORDER       = 100303 --魅族渠道下单
 POST_COMMAND_JINLI_CHARGINGORDER       = 100304 --金立渠道下单
 POST_COMMAND_XIAOMI_CHARGINGORDER       = 100305 --小米渠道下单

 POST_COMMAND_SHARETOWECHATREPORT				=100236		--分享微信上报
 POST_COMMAND_TENCENT_UNIPAY     				=100237		--应用宝支付

 POST_COMMAND_UPLOADDEVICEINFO                   =100247--上传硬件信息
 POST_COMMAND_SENDBOARDINFO                    =100240      --收藏牌局
 POST_COMMAND_GETESUNCK                         =10038    --获取500联合登陆key
 POST_COMMAND_GETBOARDINFO		=100241

 POST_COMMAND_QUERY_TENCENT_GAMECOIN             =100260 --查询腾讯游戏币 数量
 POST_COMMAND_REDUCE_TENCENT_GAMECOIN             =100261 --扣费腾讯游戏币


 POST_COMMAND_REPORT_BTN_CLICK		             =100262 --报告按钮点击次数
 POST_COMMAND_GET_REPORT_SWITCH	                 =100263 --获取统计按钮 点击次数开关
 POST_COMMAND_REFRESH_REPORT_SWITCH	             =100264 --  统计按钮 点击次数 去重复 开关

 POST_COMMAND_GET_VIP_INFO                     =100249  --获取 vip信息

 POST_COMMAND_LOGIN_FOR_MOBILE_NEW                     =100250  --新版登录接口

 POST_COMMAND_GET_LOGINSWITCH                     =100251  --loginswitch
 POST_COMMAND_GET_SHOPSWITCH                     =100252  --显示or隐藏接口
 POST_COMMAND_QUICKREGISTER                  =100253  --快速注册
 POST_COMMAND_SIGN_BIND_500						=100245

 POST_COMMAND_ESUNLOGIN							=10038 --500登录
 POST_COMMAND_GetSngMatch			=100244 --获取SNG比赛列表
 POST_COMMAND_ApplySngMatch			=100246 --SNG报名
 POST_COMMAND_AddOn		=100248

 POST_COMMAND_GetUserHandsFavorite	=100242--获取收藏牌局列表
  POST_COMMAND_DelFavoriteHands		=100243--删除收藏牌局
 POST_COMMAND_SetApplePushToken                    =100270  --上传苹果推送token
 POST_COMMAND_GetLableShowConfig                    =100271  --获取牌桌页面配置
 POST_COMMAND_GetMatchDetailByName           =100272  --获取赛事详情
 POST_COMMAND_GetKnapSack                     =100273 --获取玩家物品列表
 POST_COMMAND_CheckUserAuth                   =100274 --获取实名认证

POST_COMMAND_JoinActivity                     = 100276 --参加活动
POST_COMMAND_GetActivityData               	  = 100277 --参加活动

POST_COMMAND_getLoginSignInfo                 = 100285 --签到信息
POST_COMMAND_loginSign                        = 100286 --请求签到

POST_COMMAND_sendVerifyCode		              = 100287 --发送验证码
POST_COMMAND_verifyCode		                  = 100288 --验证验证码
POST_COMMAND_UpFavoriteHands		          = 100289 --更新牌局名称
POST_COMMAND_REGISTERPC		                  = 100290 --新版注册接口
POST_COMMAND_getVerifyCode		              = 100291 --新版注册接口
POST_COMMAND_sendVerifyMsg                    = 100292 --新版注册接口
POST_COMMAND_verifyPhoneCode                  = 100293

POST_COMMAND_taskFinishAndReward              = 100294	--领取任务奖励
POST_COMMAND_taskListByGroup                  = 100295
POST_COMMAND_taskListAll                      = 100296	--日常任务列表
POST_COMMAND_getUserVipInfo                   = 100297  --vip信息
POST_COMMAND_getActivityDataForTask           = 100298
POST_COMMAND_finishFreshGuide                 = 100299
POST_COMMAND_getUserUseFuncInfo               = 100300 --是否第一次登录
POST_COMMAND_freshInterfaceGuide              = 100301 --标记看过新手教程


POST_COMMAND_ANNOUNCEINFO 					  = 100302  --公告内容
POST_COMMAND_ANNOUNCEAWARD					  = 100303  --公告奖励
POST_COMMAND_CREATEGAMESESSION	 			  = 100304  --创建usersessionId

POST_COMMAND_USE_ROOMCARD					= 100305 --使用开房卡
POST_COMMAND_USE_MATCHCARD					= 100306 --使用sng开房卡
POST_COMMAND_BUYIN_APPLY_ORDERS					= 100307 --申请买入列表
POST_COMMAND_GET_MY_PRITABLE					= 100308 --自己开创的私人桌列表
POST_COMMAND_GET_PRITABLE_LIST					= 100309 --参与过的私人牌局列表
POST_COMMAND_GET_PRITABLE_USER_LIST				= 100310 --私人局中玩家详情 买入、盈利状况等
POST_COMMAND_WEIXIN_CHARGINGORDER 				= 100311 -- 微信下单
POST_COMMAND_GET_DiyTableIdByFid 				= 100312 -- 根据config id获取table数据
POST_COMMAND_GET_DiyFidByTableId 				= 100313 -- 根据table id获取config id数据
POST_COMMAND_GET_ApplyDiyMatch 					= 100314 -- SNG报名
POST_COMMAND_PYW_CHARGINGORDER   				= 100315 --朋友玩下单
POST_COMMAND_UPAY_CHARGINGORDER   				= 100316 --酷派下单

POST_COMMAND_GET_createClub						= 100317--战队开始
POST_COMMAND_GET_getClubList					= 100318
POST_COMMAND_GET_searchClub						= 100319
POST_COMMAND_GET_getClubApplyList				= 100320
POST_COMMAND_GET_getReviewClubList				= 100321
POST_COMMAND_GET_applyClub						= 100322
POST_COMMAND_GET_ReviewClubList					= 100323
POST_COMMAND_GET_getDailyTaskList				= 100324
POST_COMMAND_GET_queryReward					= 100325
POST_COMMAND_GET_receiveRewards					= 100326
POST_COMMAND_GET_getClubInfo					= 100327
POST_COMMAND_GET_getMemberInfo					= 100328
POST_COMMAND_GET_getClubMembers					= 100329
POST_COMMAND_GET_getClubHistory					= 100330
POST_COMMAND_GET_getClubNotice					= 100331
POST_COMMAND_GET_saveClubNotice					= 100332
POST_COMMAND_GET_sentMoneyToMember				= 100333
POST_COMMAND_GET_kickOutMember					= 100334
POST_COMMAND_GET_appointMember					= 100335
POST_COMMAND_GET_dissolveClub					= 100336
POST_COMMAND_GET_quitClub						= 100337
POST_COMMAND_GET_getClubBoardList				= 100338
POST_COMMAND_GET_useClubDiamondExchange			= 100339
POST_COMMAND_GET_donateDiamondToClub			= 100340
POST_COMMAND_GET_donateFund						= 100341
POST_COMMAND_GET_inviteMember					= 100342
POST_COMMAND_GET_acceptInvite					= 100343--战队结束
POST_COMMAND_GET_getUserExtentionInfo			= 100344

POST_COMMAND_GETRCTOKEN							= 100345
POST_COMMAND_IGNORERCMEMBERS					= 100346
POST_COMMAND_ROLLBACKRCMEMBERS 					= 100347
POST_COMMAND_GET_priTableList 					= 100348
POST_COMMAND_GET_checkVersion 					= 100349
POST_COMMAND_GET_exchangePoint 					= 100350
POST_COMMAND_GET_buyAsGift 						= 100351
POST_COMMAND_GET_getPerson 						= 100352 --实名认证获取个人信息
POST_COMMAND_GET_updatePerson					= 100353 --实名认证更新个人信息

POST_COMMAND_APPLY_DIY_MTT 						= 100355 --朋友局MTT报名
POST_COMMAND_START_DIY_MATCH 					= 100356 --朋友局MTT开赛
POST_COMMAND_KICK_APPLY 						= 100357 --朋友局MTT踢除报名
POST_COMMAND_QUIT_DIY_MATCH 					= 100358 --朋友局sng退赛
POST_COMMAND_GETUSERMATCHTABLEINFO 				= 100359 --获取正在进行的牌桌信息


POST_COMMAND_NDUO_CHARGINGORDER   				= 100370 --N多下单
POST_COMMAND_UUCUN_CHARGINGORDER  				= 100371 --悠悠村下单
POST_COMMAND_MMY_CHARGINGORDER  				= 100372 --木蚂蚁下单
POST_COMMAND_LT_CHARGINGORDER  					= 100373 --力天下单
POST_COMMAND_TABLELEVEL_TO_GAMEADDR                  =100400     -- 获取对应盲注级别的服务器地址

POST_COMMAND_ANQU_CHARGINGORDER					= 100401 --安趣支付下单
POST_COMMAND_ANQUPAYNOTIFYSERVER                 = 100402 --安趣支付发货通知





