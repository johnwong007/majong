
--筹码图片路径
C_CHIP_LABLE_PATH = "picdata/table/chip.png"
C_CHIP_BACK_PATH = "picdata/table/chipBG.png"

--收筹码位置
C_PRIZE_POT_POS =
{
	cc.p(400,409),	cc.p(550,409),cc.p(600,409)
}

--2人桌下筹码位置
C_HAND_CHIP_POS_2 =
{
	cc.p(280,140),	cc.p(480,550)
}

--2人桌桌上筹码位置
C_ROUND_CHIP_POS_2 =
{
	cc.p(402,233),	cc.p(597,445)
}

--6人桌下筹码位置
--C_HAND_CHIP_POS_6[6] =
--{
--	cc.p(777,640-503),	cc.p(181,640-503),	cc.p(116,640-302),
--	cc.p(231,640-121),	cc.p(727,640-121),	cc.p(844,640-302)
--}
C_HAND_CHIP_POS_6 =
{
    cc.p(450,100),	cc.p(146,117),	cc.p(80,367),
    cc.p(280,515),	cc.p(746,515),	cc.p(936,367)
}
--6人桌桌上筹码位置
--C_ROUND_CHIP_POS_6[6] =
--{
--	cc.p(694,640-440),	cc.p(249,640-441),	cc.p(163,640-343),
--	cc.p(249,640-161),	cc.p(694,640-161),	cc.p(780,640-343)
--}
C_ROUND_CHIP_POS_6 =
{
    cc.p(430,225),	cc.p(166,210),	cc.p(140,360),
    cc.p(230,430),	cc.p(736,430),	cc.p(825,360)
}

--9人桌下筹码位置
--C_HAND_CHIP_POS_9[9] =
--{
--	cc.p(480,640-516),	cc.p(182,640-516),	cc.p(106,640-383),
--	cc.p(106,640-250),	cc.p(231,640-117),	cc.p(727,640-117),
--	cc.p(854,640-236),	cc.p(854,640-384),	cc.p(778,640-516)
--}

C_HAND_CHIP_POS_9 =
{
    cc.p(480,90),	cc.p(126,137),	cc.p(80,279),
    cc.p(140,430),	cc.p(280,515),	cc.p(746,515),
    cc.p(885,430),	cc.p(930,279),	cc.p(885,137)
}
--9人桌桌上筹码位置
--C_ROUND_CHIP_POS_9[9] =
--{
--	cc.p(427,640-432),	cc.p(235,640-452),	cc.p(205,640-354),
--	cc.p(205,640-221),	cc.p(241,640-155),	cc.p(694,640-155),
--	cc.p(730,640-221),	cc.p(730,640-354),	cc.p(700,640-452)
--}
C_ROUND_CHIP_POS_9 =
{
    cc.p(430,225),	cc.p(176,210),	cc.p(135,300),
    cc.p(180,390),	cc.p(265,428),	cc.p(713,428),
    cc.p(805,390),	cc.p(820,300),	cc.p(775,210)
}
function SEATNO_IS_WRIGHT(_num,_no)  
	return _no >= 0 and _no < _num 
end

--获取手上筹码坐标
function getHandChipPosWith(seatNum, seatNo)

	if(not SEATNO_IS_WRIGHT(seatNum,seatNo)) then
		return cc.p(0,0)
	end
	if(seatNum == 6) then
		return cc.pAdd(LAYOUT_OFFSET, C_HAND_CHIP_POS_6[seatNo+1])
	elseif(seatNum == 9) then
		return cc.pAdd(LAYOUT_OFFSET, C_HAND_CHIP_POS_9[seatNo+1])
	elseif(seatNum == 2) then
		return cc.pAdd(LAYOUT_OFFSET, C_HAND_CHIP_POS_2[seatNo+1])
	else
		return cc.p(0,0)
	end
end

--获取桌上筹码坐标
function getRoundChipPosWith(seatNum, seatNo)

	if(not SEATNO_IS_WRIGHT(seatNum,seatNo)) then
		return cc.p(0,0)
	end
	if(seatNum == 6) then
		return cc.pAdd(LAYOUT_OFFSET, C_ROUND_CHIP_POS_6[seatNo+1])
	elseif(seatNum == 9) then
		return cc.pAdd(LAYOUT_OFFSET, C_ROUND_CHIP_POS_9[seatNo+1])
	elseif(seatNum == 2) then
		return cc.pAdd(LAYOUT_OFFSET, C_ROUND_CHIP_POS_2[seatNo+1])
	else
		return cc.p(0,0)
	end
end

--获取奖池坐标
function getPrizePotPosWith(index)

    if(index == 1) then
		return cc.pAdd(LAYOUT_OFFSET, C_PRIZE_POT_POS[1])
    elseif(index == -1) then
        return cc.pAdd(LAYOUT_OFFSET, C_PRIZE_POT_POS[3])
    else
		return cc.pAdd(LAYOUT_OFFSET, C_PRIZE_POT_POS[2])
    end
end