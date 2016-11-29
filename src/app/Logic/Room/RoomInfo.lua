	TABLE_STATE_WAIT_SYNC     = 20000        --# 等待赛事同步规则
	TABLE_STATE_INIT          = 20001        --# 初始
	TABLE_STATE_SETBUTTON     = 20002        --# 设置庄家
	TABLE_STATE_WAIT_BLIND    = 20003        --# 等待玩家下盲注和底注
	TABLE_STATE_SET_FBETER    = 20004        --# 设置第一位下注者
	TABLE_STATE_HAND          = 20005        --# 发手牌
	TABLE_STATE_FIRST_BET     = 20006        --# 荷官循环等待玩家下注
	TABLE_STATE_FLOP          = 20007        --# 发翻牌123
	TABLE_STATE_SECOND_BET    = 20008        --# 荷官循环再次等待玩家下注
	TABLE_STATE_TURN          = 20009        --# 发转牌4
	TABLE_STATE_THIRD_BET     = 20010        --# 荷官循环三次等待玩家下注
	TABLE_STATE_RIVER         = 20011        --# 发河牌5
	TABLE_STATE_FOURTH_BET    = 20012        --# 荷官循环四次等待玩家下注 
	TABLE_STATE_PRIZE         = 20013        --# 荷官分配奖池
	TABLE_STATE_SHOWDOWN      = 20014        --# 荷官等待亮牌玩家亮牌
	TABLE_STATE_END           = 20015        --# 荷官清理牌桌,上传一手牌局信息

local RoomInfo = class("RoomInfo", cc.Ref)

function RoomInfo:ctor()
	self.payType = ""
	self.tableId = ""
	self.tableName = ""
	self.tableType = ""
	self.sequence = 0
	self.tableStatus = TABLE_STATE_INIT
	self.smallBlind = 0.0
	self.bigBlind = 0.0
	self.buttonNo = 0
	self.sBlindNo = 0
	self.bBlindNo = 0
	self.buyChipsMin = 0.0
	self.buyChipsMax = 0.0
	self.tmpBuyChipsMin = 0.0
	self.tmpBuyChipsMax = 0.0
	self.gameMinBuyin = 0.0 --设置房间的最小买入
    
	self.handId = ""    --牌局ID，牌局回放等用到
    
	self.gameSpeed = 0
	self.seatNum = 0
	self.comunityCard = {}
	self.isFirstRound = true--是否是第一圈（新手引导用到）
	self.hasAllIn = false--是否有人all in
	self.pot = 0.0
end

return RoomInfo