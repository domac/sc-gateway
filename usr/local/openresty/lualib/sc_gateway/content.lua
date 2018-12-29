local _util = require "sc_gateway.util"
-- ngx.log(ngx.ERR, "content by gateway")
_util.set_headers()
-- local ret = "7777"
-- _util.write(ret)
ngx.exec("@connsc")
-- local _config = require "sc_gateway.config"
-- local ret = _config["ret_ok"]
-- _util.write(ret)
-- ngx.exit(200)
