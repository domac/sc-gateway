local _Util = {}

function _Util.get_post_data()
    local args = {}
    local request_method = ngx.var.request_method
    -- get post data
    if "POST" == request_method then
        ngx.req.read_body()
        args = ngx.req.get_body_data()
    end

    return args
end

function _Util.get_remote_ip()
    local ip = ngx.req.get_headers()["X-Real-IP"]
    if not ip then
        ip = ngx.req.get_headers()["x_forwarded_for"]
    end
    if not ip then
        ip = ngx.var.remote_addr
    end
    return ip
end

function _Util.get_args()
    local args = {}
    local request_method = ngx.var.request_method
    if "GET" == request_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == request_method then
        ngx.req.read_body()
        args = ngx.req.get_post_args()
    end
    return args
end

function _Util.request_time()
    local ngx_time = ngx.time()
    local server_time = os.date("%Y-%m-%d %H:%M:%S", ngx_time)
    return server_time
end

function _Util.readFile(fileName)
    local f = assert(io.open(fileName, "r"))
    local content = f:read("*all")
    f:close()
    return content
end

function _Util.set_headers()
    local headertables = ngx.req.get_headers()
    ngx.header["Client-Guid"] = headertables["Client-Guid"]
    ngx.header["Client-Mid"] = headertables["Client-Mid"]
    ngx.header["Client-Machine"] = headertables["Client-Machine"]
    ngx.header["Client-Version"] = headertables["Client-Version"]
    ngx.header["Proto-Ver"] = headertables["Proto-Ver"]
    ngx.header["Proto-Cmd"] = headertables["Proto-Cmd"]
    ngx.header["Content-Encrypt"] = headertables["Content-Encrypt"]
    ngx.header["Content-Seq"] = headertables["Content-Seq"]
    ngx.header["Content-Type"] = "application/json"
end

function _Util.get_from_cache(key)
    local cache_ngx = ngx.shared.my_cache
    local value = cache_ngx:get(key)
    return value
end

function _Util.set_to_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local cache_ngx = ngx.shared.my_cache
    local succ, err, forcible = cache_ngx:set(key, value, exptime)
    return succ
end

function _Util.update_mid(key, value)
    local cache_ngx = ngx.shared.mids
    local succ, err, forcible = cache_ngx:set(key, value, 0)
    return succ
end

function _Util.get_client_version(key)
    local cache_ngx = ngx.shared.mids
    local value = cache_ngx:get(key)
    return value
end

function _Util.write(data)
    ngx.header["Content-Length"] = #data
    ngx.print(data)
end

return _Util
