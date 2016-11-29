local ByteArray = require("framework.cc.utils.ByteArray")

local __pack = string.pack("<bihP2", 0x59, 11, 1101, "", "中文")

local __ba = ByteArray.new()

__ba:writeBuf(__pack)

__ba:setPos(1)

print("=================	test.lua begin	==============")

print("ba.len:", __ba:getLen())

print("ba.readByte:", __ba:readByte())

print("ba.readInt:", __ba:readInt())

print("ba.readShort:", __ba:readShort())

print("ba.readString:", __ba:readStringUShort())

print("ba.readString:", __ba:readStringUShort())

print("ba.available:", __ba:getAvailable())

print("ba.toString(8):", __ba:toString(8))
print("ba.toString(10):", __ba:toString(10))
print("ba.toString(16):", __ba:toString(16))

local __ba2 = ByteArray.new()

-- __ba2:writeByte(0x59)
-- 	:writeInt(11)
-- 	:writeShort(1101)
-- __ba2:writeStringUShort("")
__ba2:writeStringUShort("中文")

print("ba2.toString(10):", __ba2:toString(10))











print("=================	test.lua end	==============")