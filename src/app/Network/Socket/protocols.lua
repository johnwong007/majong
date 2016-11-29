--- DO NOT EDIT ME MANUALLY!
-- protocol definition. 
-- @author parse2lua.py
-- Creation: 2014-01-10
require "app.Network.CommandDefine"
require "app.Network.ParseKeyValue"

-- local _p = {
-- send = {
--     [1000] = {
--         [0] = {
--             ["keys"] = {"uid","sid","pid"},
--             ["fmt"] = "R3",
--             },
--         },
--     [1001] = {
--         [0] = {
--             ["keys"] = {"pid"},
--             ["fmt"] = "R",
--             },
--         },
--     [1002] = {
--         [0] = {
--             ["keys"] = {"sid","pid"},
--             ["fmt"] = "R2",
--             },
--         },
--     [1003] = {
--         [0] = {
--             ["keys"] = {},
--             ["fmt"] = "",
--             },
--         },
--     },
-- receive = {
--     [2000] = {
--         [0] = {
--             ["keys"] = {"flag","ver","role","sex","lv","money","gold","crystal","ap","dust","mithril","goodsNum","goodsMaxNum",},
--             ["fmt"] = "RSSR10",
--             },
--         },
--     },
-- }
-- return _p



local _p = {
    send = {
        [1001] = {
            {
                key = "list",
                fmt = {
                    { 
                        key = "id",fmt = "int"
                    },
                    { 
                        key = "name",fmt = "string"
                    },
                    { 
                        key = "level",fmt = "int"
                    },
                    { 
                        key = "sex",fmt = "int"
                    }
                }
            },
            {
                key = "userid",fmt = "int"
            }
        },

        [COMMAND_CONNECT] = {
            {
                key = SESSION_ID,fmt = "string"
            },
            {
                key = USER_AGENT,fmt = "string"
            },
            {
                key = COMM_PROTO_VER,fmt = "string"
            }
        }

    },
    receive = {
    --  返回
        [5001] = {
            {
                key = "result",fmt = "int" 
            },
            {
                key = "list",
                fmt = {
                    { 
                        key = "id",fmt = "int"
                    },
                    { 
                        key = "name",fmt = "string"
                    },
                    { 
                        key = "level",fmt = "int"
                    },
                    { 
                        key = "sex",fmt = "int"
                    }
                }
            }
        }
    }
}
return _p












