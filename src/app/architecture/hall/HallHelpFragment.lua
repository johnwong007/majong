local g_help_text = "牌数共一百三十六张：\n  筒、索、万、东、南、西、北风、中、发、白字牌（合计28张）\n1、风牌：东、南、西、北，各4张，共16张。\n2、箭牌：中、发、白，各4张，共12张。序数牌（合计108张）\n1、万子牌：从一万至九万，各4张，共36张。\n2、筒子牌：从一筒至九筒，各4张，共36张。也有的地方称为饼，从一饼到九饼。\n3、索子牌：从一索至九索，各4张，共36张。也有的地方称为条，从一条到九条。\n"..
"特殊牌型编辑\n"..
"牌型 番数 分值 说明\n"..
"清一色 4 16 整副牌由同一花色组成\n"..
"混碰 4 16 混一色 + 碰碰胡\n"..
"清碰 5 32 清一色 + 碰碰胡\n"..
"混幺九 5 32 由幺九牌和字牌组成的牌型\n"..
"小三元 5 32 拿齐中、发、白三种三元牌，但其中一种是将\n"..
"小四喜 5 32 胡牌者完成东、南、西、北其中三组刻子，一组对子\n"..
"字一色 6 64 由字牌组合成的刻子牌型\n"..
"清幺九 6 64 只由幺九两种牌组成的刻子牌型\n"..
"大三元 6 64 胡牌时，有中、发、白三组刻子\n"..
"大四喜 6 64 胡牌者完成东、南、西、北四组刻子\n"..
"技巧口诀编辑\n"..
"1：如果手中1万有一张，2万有一对这种牌型，\n"..
"别人丢了3万，如有混就不要吃(吃听张除外）；\n"..
"2：牌局一直不胡，不要动牌，要打牌池熟张，牌动就有放大牌的可能；\n"..
"3：单吊的牌不要只吊一张都没有见过的张，\n"..
"最好吊两头都可以碰掉的牌，外面见一张子的或者是风子；\n"..
"4：下家丢8、9万，可能手中还有4、7万，打4、7万要小心一点；\n"..
"5：外面的风子除了东风以外全都见了，就不能打了，\n"..
"有人要杠开，至少看了二轮再打；\n"..
"6：147，258的麻将规则：下家丢了1万，3、4、7万就千万不能吃，2、5万就要吃；\n"..
"7：开始几轮，除嵌张、边张外，两头张最好不吃，\n"..
"先上别的张，等上家再拿到这种牌时，他还会打下来；\n"..
"8：外面有人7万碰掉，8万再见二张，9万很有可能有人碰；\n"..
"9：开始几轮，有人丢东风，手中有东风和西风，要先丢掉西风，\n"..
"因为有可能有人拿西风做对，别人丢了，你将被轮出一轮，东风还可能拿对；\n"..
"10：牌过半，上家落风子就不要碰(碰听张除外)；\n"..
"11：自己没有混听张，比如说2、5万，上家丢了2、5万，\n"..
"如果你吃了可听2、5、8，所以没有必要吃；\n"..
"12：牌开始时先丢荡张，再丢风子，但是手中风子不可超过二张；\n"..
"13：下家丢3、8万，可能手握3、5、6、8万，打4、7万要小心一点。"
local CommonFragment = require("app.architecture.components.CommonFragment")

local HallHelpFragment = class("HallHelpFragment", function()
		return CommonFragment:new()
	end)

function HallHelpFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
end

function HallHelpFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallHelpFragment:onEnterTransitionFinish()
end

function HallHelpFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallHelpFragment:initUI()
    local bound = {x = 20, y = 0, width = CONFIG_SCREEN_WIDTH, height = CONFIG_SCREEN_HEIGHT-120} 
	local text = cc.ui.UILabel.new({
            text  = g_help_text,
            size  = 26,
            color = cc.c3b(125,0,0),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
            dimensions = cc.size(bound.width-20,0),
        })
    text:align(display.LEFT_TOP, 20,bound.height)
    self.m_pContentScrollView = cc.ui.UIScrollView.new({
	    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	    viewRect = bound, 
	   -- scrollbarImgH = "scroll/barH.png",
	   -- scrollbarImgV = "scroll/bar.png",
	   bgColor = cc.c4b(125,125,125,125)
	})
    self.m_pContentScrollView:addScrollNode(text)
    :addTo(self)
end

return HallHelpFragment