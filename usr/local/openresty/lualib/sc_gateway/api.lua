local _util = require "sc_gateway.util"

local lrucache = require "resty.lrucache"

local c, err = lrucache.new(200)
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local mids = ngx.shared.mids

local keys = mids:get_keys(100000)

local infodict = {}
for i = 1, #keys do
    local key = keys[i]
    local value = mids:get(key)
    local ret = "Client-Mid=" .. key .. ",Client-Version=" .. value
    infodict[i] = ret
end
local ret = table.concat(infodict, "\n")
ngx.print(ret)
ngx.exit(200)
