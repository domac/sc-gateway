local _util = require "sc_gateway.util"
local _config = require "sc_gateway.config"
local lrucache = require "resty.lrucache"
local math = require("math")

local passW = 0

ngx.log(ngx.INFO, "access by gateway")

local c, err = lrucache.new(200)
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local args = ngx.req.get_uri_args()
local cmd = args["cmd"]

function send_config()
    local data = _util.get_from_cache("configs")
    if (data == nil) then
        ngx.log(ngx.INFO, "reflash data from config_path")
        data = _util.readFile(_config["config_path"])
        _util.set_to_cache("configs", data, 10)
        return data
    end
    ngx.log(ngx.INFO, "get data from cache")
    return data
end

function updateMidAndClientVersion()
    local headertables = ngx.req.get_headers()
    local mid = headertables["Client-Mid"]
    if (mid == nil) then
        mid = ngx.var.arg_mid
    end

    if (mid ~= nil) then
        clientVersion = headertables["Client-Version"]
        if (clientVersion == nil) then
            clientVersion = ""
        end
        _util.update_mid(mid, clientVersion)
    end
end

function passWeight()
    local cache_counter = ngx.shared.counter
    local newVal, err, forcible = cache_counter:incr("weight", 1, 0)
    local m = math.fmod(newVal - 1, 100)
    if (100 - passW) > m then
        ngx.log(ngx.ERR, "[reject] current counter:" .. newVal .. " mod:" .. m)
        local ret = _config["ret_ok"]
        _util.write(ret)
        ngx.exit(200)
    else
        -- ngx.log(ngx.ERR, ">>>>>>>>> current counter:" .. newVal .. " mod:" .. m)
        ngx.exec("@connsc")
    end
end

_util.set_headers()

updateMidAndClientVersion()

-- pass by 20180
local server_port = ngx.var.server_port
if (server_port == "28180") then
    local ret = _config["ret_other"]
    _util.write(ret)
    ngx.exit(200)
end

if (cmd == "6621") then
    local cdata = send_config()
    _util.write(cdata)
elseif (cmd == "6002") then
    local ret = _config["ret_6002"]
    _util.write(ret)
else
    passWeight()
end
