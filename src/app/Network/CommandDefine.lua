function hexToDecimal(hexValue)
	local hexValueStr = ""..hexValue
	local decimalValue = 0
	for i = 1,#hexValueStr do
		local tmp = string.byte(hexValueStr, i)
		if tmp >= 97 and tmp <= 102 then   			--当前位为A~F
			decimalValue = decimalValue*16+tmp+10-97
		elseif tmp >= 65 and tmp <= 70 then 		--当前位为A~F
			decimalValue = decimalValue*16+tmp+10-65
		else 										--当前位为0~9
			decimalValue = decimalValue*16+tmp-48
		end
	end
	return decimalValue
end

VERSION_10  =hexToDecimal(3130)  -- 版本 10
-- VERSION_10  =0x3130  -- 版本 10
VERSION_11  =hexToDecimal(3131)  -- 版本 11
VERSION_13  =hexToDecimal(3133)  -- 版本 13

-- Socket断线指令;
COMMAND_SOCKET_CONNECTION_BREAK         =hexToDecimal(900001)

COMMOND_BREAK_TO_RECONNECT_TIMEOUT      =hexToDecimal(900004)

COMMOND_PUSH_CONNECTION_BREAK			=hexToDecimal(900002)

--[[*******************************************COMMAND 信令 START*******************************************]]
--服务类型CONN;
PING							=hexToDecimal(00000001)      --链路检查;
COMMAND_PING_RESP				=hexToDecimal(80000001)      --链路检查回应;
COMMAND_CONNECT					=hexToDecimal(00000002)      --连接请求，如果带有session信息代表重连;
COMMAND_CONNECT_RESP			=hexToDecimal(80000002)      --连接回应，返回（新建的）session信息;
COMMAND_QUIT					=hexToDecimal(00000003)		--退出服务;
COMMAND_QUIT_RESP				=hexToDecimal(80000003)		--退出回应;
COMMAND_CLOSED_BY_NEW			=hexToDecimal(00000004)		--有新的连接建立，关闭本连接;
COMMAND_BANLANCE_CHANGE         =hexToDecimal("0001000A")      --余额变动通知客户端
--服务类型ACCT
COMMAND_LOGIN					=hexToDecimal(00050001)		--登录请求;
COMMAND_LOGIN_RESP				=hexToDecimal(80050001)		--登录回应，如果成功的话需要通知user信息绑定到session;
COMMAND_LOGOUT					=hexToDecimal(00050002)      --登出请求;
COMMAND_LOGOUT_RESP				=hexToDecimal(80050002)		--登出回应
COMMAND_CREATE_ACCOUNT			=hexToDecimal(00050003)		--创建账号（注册）
COMMAND_CREATE_ACCOUNT_RESP		=hexToDecimal(80050003)		--创建账号回应
COMMAND_USER_GET_INFO			=hexToDecimal(00050004)		--获取用户信息
COMMAND_USER_GET_INFO_RESP		=hexToDecimal(80050004)		--获取用户信息回应
--服务类型MTCH
COMMAND_TOURNEY_QUIT            =hexToDecimal(00020012)      --请求放弃锦标赛
COMMAND_TOURNEY_QUIT_RESP       =hexToDecimal(80020012)      --放弃锦标赛响应
COMMAND_MATCH_REGISTER			=hexToDecimal(00060001)		--登记（参加）赛事（锦标赛）
COMMAND_MATCH_REGISTER_RESP		=hexToDecimal(80060001)		--登记回应
COMMAND_MATCH_UNREGISTER		=hexToDecimal(00060002)		--退出比赛
COMMAND_MATCH_UNREGISTER_RESP	=hexToDecimal(80060002)		--退出回应
COMMAND_MATCH_LIST				=hexToDecimal(00060003)		--赛事列表
COMMAND_MATCH_LIST_RESP			=hexToDecimal(80060003)		--列表回应
COMMAND_MATCH_GET_TABLE			=hexToDecimal(00060004)		--获取比赛桌号
COMMAND_MATCH_GET_TABLE_RESP	=hexToDecimal(80060004)		--桌号回应
COMMAND_MATCH_INFO				=hexToDecimal(00060005)		--获取赛事信息
COMMAND_MATCH_INFO_RESP			=hexToDecimal(80060005)		--获取赛事信息回应
COMMAND_ELIMINATED_MSG			=hexToDecimal(00060006)		--淘汰（出局）消息
COMMAND_TABLE_SYNC_REQ			=hexToDecimal(00060007)		--赛事向游戏索取牌桌同步信息（游戏对应返回 TABLE_SYNC_MSG）
COMMAND_BUY_CHIPS_FINISH		=hexToDecimal(00060008)		--大厅通知赛事：有用户买入筹码（传入订单ID，赛桌ID，用户ID）
COMMAND_BUY_CHIPS_FINISH_RESP	=hexToDecimal(80060008)		--大厅通知赛事：有用户买入筹码回应
--服务类型LOBB
COMMAND_TABLE_LIST				=hexToDecimal(00010001)		--获取牌桌列表
COMMAND_TABLE_LIST_RESP			=hexToDecimal(80010001)		--获取牌桌列表回应
COMMAND_CASH_OUT_PLAYER			=hexToDecimal(00010002)		--赛事通知代理：有用户兑现筹码（传入订单ID）
COMMAND_CASH_OUT_PLAYER_RESP	=hexToDecimal(80010002)		--赛事通知代理：有用户兑现筹码回应
COMMAND_PRIZE_MATCH_PLAYER		=hexToDecimal(00010003)		--赛事通知代理：给用户派奖。入参有match_id, user_id, user_name, rank
COMMAND_SAVE_MATCH_PLAYER_STAT	=hexToDecimal(00010004)		--赛事通知代理：保存用户赛事统计数据（总的手数和总的被抽水数等）
--服务类型GAME
COMMAND_TABLE_JOIN				=hexToDecimal(00020001)		--加入牌桌
COMMAND_TABLE_JOIN_RESP			=hexToDecimal(80020001)		--加入牌桌回应
COMMAND_TABLE_LEAVE				=hexToDecimal(00020002)		--离开牌桌
COMMAND_TABLE_LEAVE_RESP		=hexToDecimal(80020002)		--离开牌桌回应
if TRUNK_VERSION==DEBAO_TRUNK then
COMMAND_TABLE_INFO				=hexToDecimal(00020003)		--获取牌桌信息
COMMAND_TABLE_INFO_RESP			=hexToDecimal(80020003)		--获取牌桌信息回应
else
COMMAND_TABLE_INFO				=hexToDecimal(00020015)		--获取牌桌信息(QQ)
COMMAND_TABLE_INFO_RESP			=hexToDecimal(80020015)		--获取牌桌信息回应(QQ)
end
COMMAND_FAST_SIT                =hexToDecimal(00020018)		--快速开始入座指令
COMMAND_FAST_SIT_RESP           =hexToDecimal(80020018)		--快速开始入座指令回复
COMMAND_BUY_REQ                 =hexToDecimal(00020019)		--玩家请求买入筹码
COMMAND_BUY_RESP                =hexToDecimal(80020019)		--玩家买入筹码返回
COMMAND_NEW_BUY_REQ             =hexToDecimal("0002001A")      --玩家买入筹码到指定值
COMMAND_NEW_BUY_RESP            =hexToDecimal("8002001A")      --玩家买入筹码到指定值回复

-- COMMAND_TABLE_INFO_MOBILE       =hexToDecimal(00020015)      --手机版获取牌桌信息请求指令
COMMAND_SIT						=hexToDecimal(00020004)		--坐下
COMMAND_SIT_MSG					=hexToDecimal(80020004)		--坐下消息
COMMAND_SIT_OUT					=hexToDecimal(00020005)		--离开座位
COMMAND_SIT_OUT_MSG				=hexToDecimal(80020005)		--离开座位消息
COMMAND_BUY_IN					=hexToDecimal(00020006)		--买入
COMMAND_BUY_IN_RESP				=hexToDecimal(80020006)		--买入回应
COMMAND_TABLE_MJOIN				=hexToDecimal(00020007)		--把用户带入牌桌（内部服务间调用）
COMMAND_TABLE_MJOIN_RESP		=hexToDecimal(80020007)		--把用户带入牌桌回应
COMMAND_TABLE_MLEAVE			=hexToDecimal(00020008)		--把用户带离牌桌（内部服务间调用）
COMMAND_TABLE_MLEAVE_RESP		=hexToDecimal(80020008)		--把用户带离牌桌回应
COMMAND_BUY_CHIPS_PLAYER		=hexToDecimal(00020009)		--赛事通知游戏：有用户买入筹码（传入订单ID，赛桌ID，用户ID）
COMMAND_BUY_CHIPS_PLAYER_RESP	=hexToDecimal(80020009)		--赛事通知游戏：有用户买入筹码回应
COMMAND_CORRECT_PLAYER_CHIPS	=hexToDecimal("0002000A")		--赛事通知游戏：纠正（更新）用户筹码
COMMAND_CORRECT_PLAYER_CHIPS_RESP	=hexToDecimal("8002000A")	--赛事通知游戏：纠正（更新）用户筹码回应
COMMAND_JOIN_WAITING			=hexToDecimal("0002000B")		--加入排队等待
COMMAND_JOIN_WAITING_RESP		=hexToDecimal("8002000B")		--加入等待响应
COMMAND_UNJOIN_WAITING			=hexToDecimal("0002000C")		--取消排队等待
COMMAND_UNJOIN_WAITING_RESP		=hexToDecimal("8002000C")		--取消等待响应
COMMAND_END_WAITING				=hexToDecimal("0002000D")		--结束等待，通知入座
COMMAND_KEEP_TABLE				=hexToDecimal("0002000E")		--保持桌子（继续围观）
COMMAND_KEEP_TABLE_RESP			=hexToDecimal("8002000E")		--保持桌子（继续围观）回应

UPDATE_PLAYER_CHIPS             =hexToDecimal(00020224)      --更新玩家余额131620

COMMAND_REMIND_USER_TABLE_WILL_DESTROY  =hexToDecimal(00020228)      --提醒客户端，5分钟后，牌桌即将销毁    131624
COMMAND_REMIND_USER_TABLE_CARD_DESTROY  =hexToDecimal(00020229)      --提醒客户端，此局结束后，牌桌即将销毁 131625

--服务类型GAME
COMMAND_TABLE_CREATE			=hexToDecimal(00020301)		--创建牌桌
COMMAND_TABLE_CREATE_RESP		=hexToDecimal(80020301)		--创建牌桌回应
COMMAND_TABLE_START				=hexToDecimal(00020302)		--启动赛桌
COMMAND_TABLE_START_RESP		=hexToDecimal(80020302)		--启动赛桌回应
COMMAND_TABLE_PAUSE				=hexToDecimal(00020303)		--暂停赛桌
COMMAND_TABLE_PAUSE_RESP		=hexToDecimal(80020303)		--暂停赛桌回应
COMMAND_TABLE_DESTROY			=hexToDecimal(00020304)		--销毁赛桌
COMMAND_TABLE_DESTROY_RESP		=hexToDecimal(80020304)		--销毁赛桌回应
COMMAND_TABLE_SYNC_RULE			=hexToDecimal(00020305)		--同步赛事规则
COMMAND_TABLE_SYNC_RULE_RESP	=hexToDecimal(80020305)		--同步赛事规则回应
COMMAND_TABLE_GUIDE				=hexToDecimal(00020306)		--引导用户加入赛桌
COMMAND_GET_PLAYERS				=hexToDecimal(00020307)		--询问桌子玩家
COMMAND_GET_PLAYERS_RESP		=hexToDecimal(80020307)		--返回信息
COMMAND_PRE_BUY_CHIPS_MSG       =hexToDecimal(00020309)     --预买成功回复（提示本局结束后把钱加上）/等候Addon消息
COMMAND_ADDON_FINISH_RESP       =hexToDecimal(00020112)      --Addon回应消息
COMMAND_TABLE_ADDON_MSG         =hexToDecimal(00020308)      --Addon消息

--服务类型GAME
COMMAND_CALL					=hexToDecimal(00020101)		--跟注
COMMAND_CALL_MSG				=hexToDecimal(80020101)		--跟注消息
COMMAND_RAISE					=hexToDecimal(00020102)		--加注
COMMAND_RAISE_MSG				=hexToDecimal(80020102)		--加注消息
COMMAND_FOLD					=hexToDecimal(00020103)		--弃牌
COMMAND_FOLD_MSG				=hexToDecimal(80020103)		--弃牌消息
COMMAND_CHECK					=hexToDecimal(00020104)		--看牌
COMMAND_CHECK_MSG				=hexToDecimal(80020104)		--看牌消息
COMMAND_ALL_IN					=hexToDecimal(00020105)		--all in
COMMAND_ALL_IN_MSG				=hexToDecimal(80020105)		--all in消息
COMMAND_CANCEL_TRUSTEESHIP		=hexToDecimal(00020106)		--取消托管
COMMAND_CANCEL_TRUSTEESHIP_MSG	=hexToDecimal(80020106)		--取消托管回应
COMMAND_SHOWDOWN				=hexToDecimal(00020107)		--设置亮牌
COMMAND_SHOWDOWN_RESP			=hexToDecimal(80020107)		--设置亮牌消息
COMMAND_SET_AUTO_BLIND			=hexToDecimal(00020108)		--设置自动缴纳盲注类型
COMMAND_SET_AUTO_BLIND_RESP		=hexToDecimal(80020108)		--设置自动缴纳盲注类型回应
--服务类型GAME
COMMAND_WAIT_FOR_MSG			=hexToDecimal(00020201)		--正在等待谁（座位号用户id等）操作（或者什么事件）
COMMAND_HAND_START_MSG			=hexToDecimal(00020202)		--这手牌局开始
COMMAND_POCKET_CARD				=hexToDecimal(00020203)		--手牌
COMMAND_FLOP_CARD_MSG			=hexToDecimal(00020204)		--翻牌
COMMAND_TURN_CARD_MSG			=hexToDecimal(00020205)		--转牌
COMMAND_RIVER_CARD_MSG			=hexToDecimal(00020206)		--河牌
COMMAND_SHOWDOWN_MSG			=hexToDecimal(00020207)		--亮牌
COMMAND_POT_MSG					=hexToDecimal(00020208)		--奖池（变动）消息
COMMAND_PRIZE_MSG				=hexToDecimal(00020209)		--（奖池）派奖消息
COMMAND_TABLE_SYNC_MSG			=hexToDecimal("0002020A")		--同步牌桌信息（每手结束以后同步信息到赛事）
COMMAND_SELECT_BUTTON_MSG		=hexToDecimal("0002020B")		--抽牌决定庄家，结果信息
COMMAND_TABLE_BLIND_MSG			=hexToDecimal("0002020C")		--盲注缴纳消息（小盲和大盲信息）
COMMAND_TABLE_ANTE_MSG			=hexToDecimal("0002020D")		--底注缴纳消息
COMMAND_TABLE_BUTTON_MSG		=hexToDecimal("0002020E")		--庄家位置信息（包括小盲和大盲位置）
COMMAND_TRUSTEESHIP_MSG			=hexToDecimal("0002020F")		--处理托管玩家消息
COMMAND_PLAYER_TIMEOUT_MSG		=hexToDecimal(00020210)		--处理玩家超时消息
COMMAND_SHOWDOWN_REQ			=hexToDecimal(00020211)		--荷官请求亮牌
COMMAND_TABLE_RAKE_BF_FLOP_MSG	=hexToDecimal(00020212)		--翻牌前抽水消息
COMMAND_BUY_CHIPS_MSG			=hexToDecimal(00020213)		--玩家筹码购买成功
COMMAND_TABLE_DESTROY_MSG		=hexToDecimal(00020214)		--销毁赛桌消息
COMMAND_PUNISH_BLIND_TO_BET		=hexToDecimal(00020215)		--盲注惩罚（归入下注）消息
COMMAND_PUNISH_BLIND_NO_BET		=hexToDecimal(00020216)		--盲注惩罚（不归入下注）消息
COMMAND_HAND_FINISH_MSG			=hexToDecimal(00020217)		--本手牌结束
--服务类型CHAT
COMMAND_TABLE_CHAT				=hexToDecimal(00030001)		--提交发言
COMMAND_TABLE_CHAT_MSG			=hexToDecimal(80030001)		--将发言分发给目标用户
COMMAND_NOTICE_ANNOUNCE			=hexToDecimal(00030002)		--提交通告
COMMAND_NOTICE_ANNOUNCE_MSG		=hexToDecimal(80030002)		--将通告分发给目标用户

COMMAND_APPLY_FRIEND            =hexToDecimal(00070001)--=hexToDecimal(00030003)         --好友申请
COMMAND_ADD_FRIEND              =hexToDecimal(00070002)--=hexToDecimal(00030004)         --添加好友
COMMAND_REFUSE_APPLY_FRIEND     =hexToDecimal(00070003)--=hexToDecimal(00030005)         --申请被拒绝
--锦标赛报名、退赛
COMMAND_APPLY_MATCH             =hexToDecimal("0006000A")      --报名
COMMAND_APPLY_MATCH_RESP        =hexToDecimal("8006000A")      --报名回应
COMMAND_CANCEL                  =hexToDecimal("0006000B")     --退赛
COMMAND_CANCEL_RESP             =hexToDecimal("8006000B")     --退赛回应

COMMAND_LEAVE_CHIPS_STATE		=hexToDecimal(00020116)		--退出房间盈利通知


COMMAND_PUSH_REPORT_USERID		=hexToDecimal(00001001)		--上报用户身份
COMMAND_PUSH_REPORT_USERID_RESP	=hexToDecimal(00002001)      --上报用户身份回应;
COMMAND_PUSH_MSG				=hexToDecimal(00002002)		--推送消息

COMMAND_KICK_USER				=hexToDecimal(80030003)		--帐号在其他地方登录

COMMAND_PASSIVE_REBUY_REQ		=hexToDecimal(00020111)		--被动rebuy
COMMAND_REBUY					=hexToDecimal(00020110)		--rebuy
COMMAND_REBUY_RESP				=hexToDecimal(80020110)		--主动rebuy回应
--Rush牌桌
COMMAND_RUSH_JOIN_REQ           =hexToDecimal(00020311)      --玩家请求进入rush牌桌
COMMAND_RUSH_JOIN_RESP          =hexToDecimal(80020311)      --玩家请求进入牌桌回复
COMMAND_RUSH_BUY_REQ            =hexToDecimal(00020313)      --补充筹码
COMMAND_RUSH_BUY_RESP           =hexToDecimal(80020313)      --补充筹码回复
COMMAND_RUSH_PRE_BUY_RESP       =hexToDecimal(80020314)      --预买成功
COMMAND_RUSH_FOLD_REQ           =hexToDecimal(00020315)      --快速弃牌
COMMAND_RUSH_FOLD_RESP          =hexToDecimal(80020315)      --快速弃牌回复
COMMAND_RUSH_LEAVE_REQ          =hexToDecimal(00020316)      --离开房间
COMMAND_RUSH_LEAVE_RESP         =hexToDecimal(80020316)      --离开房间回复
COMMAND_RUSH_CANCEL_TRUSTEE_REQ =hexToDecimal(00020317)      --取消托管
COMMAND_RUSH_CANCEL_TRUSTEE_RESP =hexToDecimal(80020317)     --取消托管回复
COMMAND_RUSH_GET_TABLE_INFO_REQ  =hexToDecimal(00020318)    --获取牌桌信息
COMMAND_RUSH_GET_TABLE_INFO_RESP =hexToDecimal(80020318)     --获取牌桌信息回复
COMMAND_RUSH_GET_PLAYER_REQ      =hexToDecimal(00020319)     --获取牌桌玩家信息
COMMAND_RUSH_GET_PLAYER_RESP     =hexToDecimal(80020319)     --获取牌桌玩家信息回复
COMMAND_RUSH_TRUSTEE_TIME_OUT    =hexToDecimal(80020320)     --托管超时被强制踢出牌桌
COMMAND_RUSH_BUY_CHIPS_TIME_OUT  =hexToDecimal(80020321)     --购买筹码超时

--[[私人桌买入申请指令]]
COMMAND_BUYIN_APPLY           =hexToDecimal(00060014)      --私人桌申请买入指令
COMMAND_BUYIN_APPLY_RESP          =hexToDecimal(80060014)      --私人桌申请买入指令
COMMAND_APPLY_ANSWER          =hexToDecimal(00020218)      --私人桌申请买入指令回复
COMMAND_APPLY_ANSWER_RESP           =hexToDecimal(80020218)      --私人桌申请买入指令回复

COMMAND_PKOUT_MESSAGE			=hexToDecimal(00080002)		--pk赛未匹配成功
COMMAND_TABLE_WAIT_MSG          =hexToDecimal(00060013)      --hands by hands指令

CASH_TABLE_GUIDE        = 0x0006000E    --引导玩家入桌


APPLY_OPERATION_DELAY     		= hexToDecimal(00020233)       --申请操作延时
APPLY_OPERATION_DELAY_RESP		= hexToDecimal(80020233)         --申请操作延时
USER_OPERATE_DELAY_MSG    		= 0x00020234         --玩家申请延时后通知牌桌内玩家
APPLY_PUBLIC_CARD     			= hexToDecimal(00020236)       --牌局结束后申请查看未发出的公共牌
APPLY_PUBLIC_CARD_RESP			= hexToDecimal(80020236)         --牌局结束后申请查看未发出的公共牌服务器返回
TRUSTEESHIP_PROTECT     		= hexToDecimal(00020237)       --申请托管留座保护
TRUSTEESHIP_PROTECT_RESP		= hexToDecimal(80020237)         --申请托管留座保护服务器返回
--[[*******************************************COMMAND 信令 END*******************************************]]

--[[***************************全局变量定义，如c++中的枚举***************************]]

AUTO_BLIND_ACCEPT_ALL             = 0 -- #自动支付新手盲、或者正常的前注、大盲注;
AUTO_BLIND_REFUSE_NEWBLIND        = 1 -- #拒绝新手盲、但自动支付正常的前注、大盲注;
AUTO_BLIND_REFUSE_ALL             = 2 -- #全部拒绝 – 拒绝新手盲，也拒绝正常的前注、小盲注、大盲注;
AUTO_BLIND_REFUSE_BBLIND          = 3 -- #只拒绝缴纳大盲注, 支付正常的前注和小盲注 ( 下一手大盲注离座 )












