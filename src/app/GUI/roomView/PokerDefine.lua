require("app.GUI.roomView.RoomViewDefine")


POKER_DISP_ACTION_DURATION    =0.8        --发牌动画时间间隔
POKER_SWITCH_ACTION_DURATION  =0.2        --翻牌时间间隔
POKER_MOVE_ACTION_DURATION    =0.5        --poker座位移动动画时间间隔

--高亮牌的红边框
s_pPokerHighLight     = "picdata/public/pokerHighLight.png"
--非凸起牌遮罩
s_pPokerWinMask       = "picdata/db_poker/poker_zhezhao_android.png"

--poker图片资源所在的文件路径
POKER_RESOURCE_ROOT_PATH ="picdata/db_poker/"
POKER_BACK_NAME ="poker_back"
if SHOW_GIGESET then
    POKER_BACK_NAME ="poker_back2"
end
--庄家发牌位
DEALER_LOC_POKER     = cc.p(480,499-20)

--高亮突出牌的向上偏移
POKER_HIGHLIGHT_MOVEUP    = cc.p(0,12)
POKER_HIGHLIGHT_MOVEDown  = cc.p(0,-12)

--5张公牌的坐标
local POKER_LOC_PUBLIC_Y = 308
POKER_LOC_PUBLIC_0 = cc.p(480-94-94+15,POKER_LOC_PUBLIC_Y)
POKER_LOC_PUBLIC_1 = cc.p(480-94+15,POKER_LOC_PUBLIC_Y)
POKER_LOC_PUBLIC_2 = cc.p(480+15,POKER_LOC_PUBLIC_Y)
POKER_LOC_PUBLIC_3 = cc.p(480+94+15,POKER_LOC_PUBLIC_Y)
POKER_LOC_PUBLIC_4 = cc.p(480+94+94+15,POKER_LOC_PUBLIC_Y)


--607 + 41+25-1
--Poker相对于UserCell的偏移
--暗牌时
--POKER1_LOC_OFFSET_USERCELL = cc.p(80,26)
--POKER2_LOC_OFFSET_USERCELL = cc.p(120,29)
--明牌时左边
POKER1_LOC_OFFSET_USERCELL_LEFT  = cc.p(-45-5,12-5)
POKER2_LOC_OFFSET_USERCELL_LEFT  = cc.p(-15-25,12)
--明牌时右边
POKER1_LOC_OFFSET_USERCELL_RIGHT = cc.p(15+25,12-5)
POKER2_LOC_OFFSET_USERCELL_RIGHT = cc.p(45+5,12)

POKER1_LOC_OFFSET_USERCELL_MID = cc.p(-15,-5)
POKER2_LOC_OFFSET_USERCELL_MID = cc.p(15,0)
--自己拿牌时Poker相对于UserCell的偏移 这里是发完暗牌在牌桌位置, playerview里进行重新定位
POKER1_SELF_OFFSET_USERCELL_BACK = cc.p(194,8)
POKER2_SELF_OFFSET_USERCELL_BACK = cc.p(245,8)
--明牌
POKER1_SELF_OFFSET_USERCELL  = cc.p(194-20,-8)
POKER2_SELF_OFFSET_USERCELL  = cc.p(245-20,-8)

--[[add by wangjun 2015-10-29]]
--------------------------------------------------------------------------------
POKER_LOC_DELTA = cc.p(-40,-40)
-- POKER_LOC_PUBLIC_0 = cc.pAdd(POKER_LOC_PUBLIC_0, POKER_LOC_DELTA)
-- POKER_LOC_PUBLIC_1 = cc.pAdd(POKER_LOC_PUBLIC_1, POKER_LOC_DELTA)
-- POKER_LOC_PUBLIC_2 = cc.pAdd(POKER_LOC_PUBLIC_2, POKER_LOC_DELTA)
-- POKER_LOC_PUBLIC_3 = cc.pAdd(POKER_LOC_PUBLIC_3, POKER_LOC_DELTA)
-- POKER_LOC_PUBLIC_4 = cc.pAdd(POKER_LOC_PUBLIC_4, POKER_LOC_DELTA)

POKER_USERCELL_DELTA = cc.p(25,-35)
-- POKER1_LOC_OFFSET_USERCELL_LEFT=cc.pAdd(POKER1_LOC_OFFSET_USERCELL_LEFT,POKER_USERCELL_DELTA)
-- POKER2_LOC_OFFSET_USERCELL_LEFT=cc.pAdd(POKER2_LOC_OFFSET_USERCELL_LEFT,POKER_USERCELL_DELTA)
-- POKER1_SELF_OFFSET_USERCELL_BACK=cc.pAdd(POKER1_SELF_OFFSET_USERCELL_BACK,POKER_USERCELL_DELTA)
-- POKER2_SELF_OFFSET_USERCELL_BACK=cc.pAdd(POKER2_SELF_OFFSET_USERCELL_BACK,POKER_USERCELL_DELTA)
-- POKER1_SELF_OFFSET_USERCELL=cc.pAdd(POKER1_SELF_OFFSET_USERCELL,POKER_USERCELL_DELTA)
-- POKER2_SELF_OFFSET_USERCELL=cc.pAdd(POKER2_SELF_OFFSET_USERCELL,POKER_USERCELL_DELTA)
--------------------------------------------------------------------------------


function POKER_PUBLIC_LOC(index, _index)   
    if(index == _index) then
        return true
    else
       return false 
    end
end

function getMidPokerLocWith(isMySelf, seatNum, seatNo, index, isBack)
    if(seatNo == -1) then --公牌
        if POKER_PUBLIC_LOC(index, 0) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_0) end
        if POKER_PUBLIC_LOC(index, 1) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_1) end
        if POKER_PUBLIC_LOC(index, 2) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_2) end
        if POKER_PUBLIC_LOC(index, 3) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_3) end
        if POKER_PUBLIC_LOC(index, 4) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_4) end
    else
        if (isMySelf) then
            if(isBack) then --暗牌时
                if(index == 0) then 
                    return cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_SELF_OFFSET_USERCELL_BACK)
                end
                if(index == 1) then
                    return cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_SELF_OFFSET_USERCELL_BACK)
                end
            else  --亮牌
                if(index == 0) then
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_SELF_OFFSET_USERCELL)
                    if(isMySelf) then
                        pos.x = pos.x - 19
                    end
                    return pos
                end
                if(index == 1) then
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_SELF_OFFSET_USERCELL)
                    if(isMySelf) then
                        pos.x = pos.x - 19
                    end
                    return pos
                end
            end
        else
            local dir = getDirectBySeatNoAndSeatNum(seatNo,seatNum)
        
            if(dir == cell_left and index == 0) then
                local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_LOC_OFFSET_USERCELL_MID)
                if(isMySelf) then
                    pos.x = pos.x - 19
                end
                return pos
            end
            if(dir == cell_left and index == 1) then
                local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_LOC_OFFSET_USERCELL_MID)
                if(isMySelf) then
                    pos.x = pos.x - 19
                end
                return pos
            end
        
            if(dir == cell_right and index == 0) then
                local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_LOC_OFFSET_USERCELL_MID)
                if(isMySelf) then
                    pos.x = pos.x + 24
                end
                return pos
            end
            if(dir == cell_right and index == 1) then
                local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_LOC_OFFSET_USERCELL_MID)
                if(isMySelf) then
                    pos.x = pos.x + 24
                end
                return pos
            end
        end
    end
    return cc.p(0,0)
end

function getPokerLocWith(isMySelf, seatNum, seatNo, index, isBack)
	if(seatNo == -1) then --公牌
		if POKER_PUBLIC_LOC(index, 0) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_0) end
		if POKER_PUBLIC_LOC(index, 1) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_1) end
		if POKER_PUBLIC_LOC(index, 2) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_2) end
		if POKER_PUBLIC_LOC(index, 3) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_3) end
		if POKER_PUBLIC_LOC(index, 4) then return cc.pAdd(LAYOUT_OFFSET,POKER_LOC_PUBLIC_4) end
	else
        if (isMySelf) then
            if(isBack) then --暗牌时
                if(index == 0) then 
                    return cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_SELF_OFFSET_USERCELL_BACK)
                end
                if(index == 1) then 
                    return cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_SELF_OFFSET_USERCELL_BACK)
                end
            else  --亮牌
            
                if(index == 0) then
                
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_SELF_OFFSET_USERCELL)
                    if(isMySelf) then
                    
                        pos.x = pos.x - 19
                    end
                    return pos
                end
                if(index == 1) then
                
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_SELF_OFFSET_USERCELL)
                    if(isMySelf) then
                    
                        pos.x = pos.x - 19
                    end
                    return pos
                end

            end
        else
                local dir = getDirectBySeatNoAndSeatNum(seatNo,seatNum)
                
                if(dir == cell_left and index == 0) then
                
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_LOC_OFFSET_USERCELL_LEFT)
                    if(isMySelf) then
                    
                        pos.x = pos.x - 19
                    end
                    return pos
                end
                if(dir == cell_left and index == 1) then
                
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_LOC_OFFSET_USERCELL_LEFT)
                    if(isMySelf) then
                        pos.x = pos.x - 19
                    end
                    return pos
                end
                
                if(dir == cell_right and index == 0) then
                
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER1_LOC_OFFSET_USERCELL_RIGHT)
                    if(isMySelf) then
                    
                        pos.x = pos.x + 24
                    end
                    return pos
                end
                if(dir == cell_right and index == 1) then
                
                    local pos = cc.pAdd(getCellLocWith(seatNum,seatNo),POKER2_LOC_OFFSET_USERCELL_RIGHT)
                    if(isMySelf) then
                        pos.x = pos.x + 24
                    end
                    return pos
                end
            end
    end
    
	return cc.p(0,0)
end