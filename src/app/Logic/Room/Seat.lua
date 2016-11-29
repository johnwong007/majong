--[[玩家状态]]

	PLAYER_STATE_INIT         = 30000       --# 初始;
	PLAYER_STATE_REMAIN       = 30003       -- # 留座;
	PLAYER_STATE_CAN_PLAY     = 30005       -- # 可以比赛!;
	PLAYER_STATE_PLAY         = 30006       --  # 比赛!;
	PLAYER_STATE_ALLIN        = 30007       -- # allin!;
	PLAYER_STATE_FOLD         = 30008       -- # 弃牌;
	PLAYER_STATE_AFK          = 30009       --暂离;
    --  PLAYER_STATE_WIN          = 30010,      --胜利;

local Seat = class("Seat")

function Seat:ctor()
	self.seatId = -1
	self.userId = ""
	self.userName = ""
	--self.qqName = ""
	self.roundChips = 0
	self.handChips = 0
	self.seatChips = 0
	self.isTrustee = false
	self.imageURL = ""
	self.userStatus = PLAYER_STATE_INIT

	self.pokerCard1=""
	self.pokerCard2=""
end

function Seat:standup()
	self.seatId = -1
	self.userId = ""
	self.userName = ""
	--self.qqName = ""
	self.roundChips = 0
	self.handChips = 0
	self.seatChips = 0
	self.isTrustee = false
	self.imageURL = ""
	self.userStatus = PLAYER_STATE_INIT

	self.pokerCard1=""
	self.pokerCard2=""
end

function Seat:hasPlayer()
	return self.seatId>=0
end
return Seat