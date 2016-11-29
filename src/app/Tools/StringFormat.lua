StringFormat = {}
MoneyFormat = {"万","亿"}


------------------------------------------------------------------------

function StringFormat:getStringLen(str)
	if type(str) ~= "string" then return 0 end
	local length = 0
	local lenInByte = string.len(str)
	local i = 1
	local char = ""
	while i <= lenInByte do 
	    local curByte = string.byte(str, i)
	    local byteCount = 1
	    if curByte < 0x80 then
	        byteCount = 1
	    elseif curByte < 0xc2 then
	    elseif curByte < 0xe0 then
	        byteCount = 2
	    elseif curByte < 0xf0 then
	        byteCount = 3
	    elseif curByte < 0xf8 then
	        byteCount = 4
	    elseif curByte < 0xfc then
	        byteCount = 5
	    elseif curByte < 0xfe then
	        byteCount = 6
	    end
	    i = i + byteCount 
	    if byteCount==1 then
	    	length = length+1
	   	else
	    	length = length+2
	   	end 
	end
	return length
end

	function StringFormat:formatName(name, pSize)
		--name = "₯㎕ζั͡✾ ✎﹏ℳ๓天使"
  --       local count=string.utf8len(name)
  --       local tmpFront = ""
  --       local tmpStrEnd = ".."
  --       if count > pSize then
		-- 	tmpFront = string.sub(name, 1, pSize)
		-- 	tmpFront = tmpFront..tmpStrEnd
  --       else
  --       	tmpFront = name
  --       end
		-- return	tmpFront
	-- if true then return name end
	local str = name
	local needLens = pSize
	local IsDot = true
	if type(str) ~= "string" then return "" end 
	local lenInByte = string.len(str)
	needLens = needLens or lenInByte 
	local i = 1
	local char = ""
	while i <= lenInByte do 
	    local curByte = string.byte(str, i)
	    --dump(curByte)
	    local byteCount = 1
	    if curByte < 0x80 then
            byteCount = 1
        elseif curByte < 0xc2 then
        elseif curByte < 0xe0 then
            byteCount = 2
        elseif curByte < 0xf0 then
            byteCount = 3
        elseif curByte < 0xf8 then
            byteCount = 4
        elseif curByte < 0xfc then
            byteCount = 5
        elseif curByte < 0xfe then
            byteCount = 6
        end
	    
	    char = string.sub(str, 1, i+byteCount-1)
	    
	    i = i + byteCount 
	    if i > needLens then
	    	break
	    end  
	end
	if string.len(char) < lenInByte and IsDot then 
		char = char .. "..."
	end
	return char
    end

	function StringFormat:formatMoney(name, pSize)
    
        local count=string.len(name)
        local tmpFront = ""
        local tmpStrEnd = ""
        if count > pSize then
			tmpFront = string.sub(name, pSize*2)
			tmpFront = tmpFront..tmpStrEnd
        else
        	tmpFront = name
        end
		return	tmpFront
		-- return name
    end

	function StringFormat:formatDate(date, precision)
    
        local dateInteger = ""
        local dataDecimals = ""
        local Decimalspos = 0
        local dot = "."
        local pos,_ = string.find(data,dot,1)
        if not pos then
            return date
        end
        dateInteger = string.sub(date,1,pos-1)
        dataDecimals = string.sub(data,pos)
        
        local tmpcount=string.len(dataDecimals)
        if (tmpcount>precision) then
        	dataDecimals = string.sub(dataDecimals,1,precision)
        end
        return dateInteger.."."..dataDecimals
        -- return date
    end

	function StringFormat:FormatDecimalsCN(num, flags)
    
        
        --flags 为 保留几位 小数点  -1 表示保留全部小数点， 0 表示不要小数点
    
	local flag = 0
	while num/10000>=1 do
		num = num/10000
		flag = flag+1
		if flag == 2 then
			break
		end
	end
	local result = math.floor(num)
	--统一取一位小数
	if result-num ~= 0 then
		result = result+math.floor((num-result)*10)*0.1
	end
	local final = ""..result
	if MoneyFormat[flag] then
		final = final..MoneyFormat[flag]
	end
	return final
        
    end

------------------------------------------------------------------------
function StringFormat:FormatDecimals(num, flags)
-- flags 为 保留几位 小数点  -1 表示保留全部小数点， 0 表示不要小数点

	local flag = 0
	while num/10000>=1 do
		num = num/10000
		flag = flag+1
		if flag == 2 then
			break
		end
	end
	local result = math.floor(num)
	--统一取一位小数
	if result-num ~= 0 then
		result = result+math.floor((num-result)*10)*0.1
	end
	local final = ""..result
	if flag>0 and MoneyFormat[flag] then
		final = final..MoneyFormat[flag]
	end
	return final
end

function StringFormat:FormatFloat(num)
	local flag = 0
	while num/10000>=1 do
		num = num/10000
		flag = flag+1
		if flag == 2 then
			break
		end
	end
	local result = math.floor(num)
	--统一取一位小数
	if result-num ~= 0 then
		result = result+math.floor((num-result)*10)*0.1
	end
	local final = ""..result
	-- if flag>0 and MoneyFormat[flag] then
	-- 	final = final..MoneyFormat[flag]
	-- end
	return final
end

function StringFormat:FtoA(tmp, pos)
	local result = ""..tmp
	local finalIndex = 1
	local flag = false   --是不是小数
	local decimalNum = 0
	for i=1,string.len(result) do
		if string.sub(result,i,i)=="." then
			flag = true
		else
			if flag==true then
				decimalNum = decimalNum+1
				if decimalNum>=pos then
					break
				end
			end
		end
		finalIndex = finalIndex+1
	end
	return string.sub(result,1,finalIndex)
	-- return tmp
end

function StringFormat:GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end
------------------------------------------------------------------------


return StringFormat