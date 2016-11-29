
	NO_NETWORK=0
	ACCOUNT_EXCEPTION=1
	DATA_ERROR=2
	OTHER_ERROR=3
	QUICKSTART_ERROR=4
	BANKRUPT_ERROR=5
	TABLEID_NOEXIST=6

	ePassiveRebuyInit=0
	ePassiveRebuyYes=1
	ePassiveRebuyNo=2


--牌桌状态
	kTableStageNone=0
	kTableStageEnter=1
	kTableStagePocket=2
	kTableStageFlop=3
	kTableStageTurn=4
	kTableStageRiver=5
	kTableStageClose=6


--操作面板操作提示
	kOBOHNone=0
	kOBOHFlopRaise=1
	kOBOHPocketRaise=2


--提示操作类型
	kTGHTNone=0--不显示
	kTGHTPocketGreatCallRaise=1--您的底牌很大哦，可以跟注/加注
	kTGHTPocketPairCallRaise=2--您的底牌为口袋对子，可以跟注/加注
	kTGHTPocketCautious=3--又有人下注了哦！请谨慎下注！
	kTGHTPocketGoodCallRaise=4--您的底牌还不错哦，可以跟注/加注！
	kTGHTPocketHigh=5--您的牌型为高牌，不建议您跟注加注，请谨慎玩牌
	kTGHTFlopGreatRaise=6--哇！您的牌很大哦！赶紧加注吧
	kTGHTFlopAllIn=7--有人ALL IN了哦！请谨慎下注！
	kTGHTFlopCautious=8--您的牌型一般！请谨慎下注！
	kTGHTTurnSelf=9--轮到您自己操作了哦！


 --离开房间的类型
	LEAVE_ROOM_TO_NULL		=0 --默认;
	LEAVE_ROOM_TO_SHOP=1			   --退出房间进入商城;
	LEAVE_ROOM_TO_QUITROOM=2		   --退出房间进入主页面/进入大厅;
	LEVAE_ROOM_TO_CHANGROOM=3	   --退出房间更换房间;
	LEVAE_ROOM_TO_TOURNEYROOM=4		--退出房间进入锦标赛房间;
	LEVAE_ROOM_TO_QUITTOURNEY=5		--退出锦标赛
	LEVAE_ROOM_TO_OTHERTOURNEY=6		--并桌处理
	LEAVE_ROOM_TO_RANK=7              --进入排行榜
	LEAVE_ROOM_TO_ACTIVITY=8          --进入活动
	LEAVE_ROOM_TO_SNGPKMATCH=9		--进入pk赛


 -- 买入筹码失败时除充值外的操作类型
	BUYINFAIL_ACTION_CANCEL=0		--不操作
	BUYINFAIL_ACTION_CHANGEROOM=1	--快速开始
	BUYINFAIL_ACTION_QUITEROOM=2		--离开房间


	eBlindCurrent=0		--当前盲注
	eBlindNext=1			--下局盲注

