local majong = cc.ui.UIImage.new("picdata/mahjong/mahjong1S.png")
majongWidth = majong:getContentSize().width*SCALE_FACTOR
majongHeight = majong:getContentSize().height*SCALE_FACTOR
majongWidth = 20
majongHeight = 32
table_padding_top = 16
table_padding_bottom = 16
table_padding_left = 10
table_padding_right = 10
cell_width = 104
function getSafaLocWith(seatNum,seatNo)
	if seatNum == 4 then
		if seatNo == 1 then
			return cc.p(cell_width/2,90+65+table_padding_bottom)
			-- return cc.p(cell_width/2+table_padding_left,majongHeight+65+table_padding_bottom)
		elseif seatNo == 2 then
			return cc.p(cell_width/2,CONFIG_SCREEN_HEIGHT/2)
			-- return cc.p(cell_width/2+table_padding_left,CONFIG_SCREEN_HEIGHT/2)
		elseif seatNo == 3 then
			return cc.p(CONFIG_SCREEN_WIDTH-200,CONFIG_SCREEN_HEIGHT-cell_width/2)
			-- return cc.p(CONFIG_SCREEN_WIDTH-200,CONFIG_SCREEN_HEIGHT-cell_width/2-table_padding_top)
		elseif seatNo == 4 then
			return cc.p(CONFIG_SCREEN_WIDTH-cell_width/2,CONFIG_SCREEN_HEIGHT/2)
			-- return cc.p(CONFIG_SCREEN_WIDTH-cell_width/2-table_padding_right,CONFIG_SCREEN_HEIGHT/2)
		end
	end 
end