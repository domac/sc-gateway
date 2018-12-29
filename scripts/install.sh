#! /bin/sh

# /usr/local/openresty/nginx/logs/nginx.pid

function create_dirs()
{
    mkdir -p /data/logs/sc_gateway
    mkdir -p /data/svr/sc-gateway    
}

function start_nginx()
{
    nginx -c /etc/openresty/conf/nginx.conf
}

function stop_nginx()
{
    nginx -s quit
}

function reload_nginx()
{
    nginx -s reload
}