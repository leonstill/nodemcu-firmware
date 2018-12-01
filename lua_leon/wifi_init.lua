-- Wifi初始化后调用指定lua文件
--   by leonstill@163.com  2018-11-20
--
-- upvals
local crypto, file, json,  net, node, table, tmr, wifi =
      crypto, file, sjson, net, node, table, tmr, wifi
local error, pcall   = error, pcall 
local loadfile, gc   = loadfile, collectgarbage
local concat, unpack = table.concat, unpack or table.unpack 
local config

local moduleName = ...
local M = {}
_G[moduleName] = M

--------------------------------------------------------------------------------------
-- load config file 'filename' -> config
local load_cfg = function(filename) 
    if file.open(filename, "r") then
        local s; 
        s, config = pcall(json.decode, file.read())
        if not s then print("Invalid configuration:", config) end
        file.close()
    end
    if type(config) ~= "table" then config = {} end
end

-- setup WiFi station mode 
local setup_wifi = function() 
    wifi.setmode(wifi.STATIONAP, false)
    cfg = {}
--    cfg.ssid="Q+"
--    cfg.pwd="WX87223636"
    cfg.ssid=config.ssid
    cfg.pwd=config.password
    cfg.probereq_cb = function(T) 
        print("probe MAC:" .. T.MAC .. "  " .. T.RSSI)
    end

    if(wifi.sta.config(cfg)) then
        print("Leon: WiFi AP started !")
    else
        print("Leon: WiFi AP failed !")
    end
end

local check_wifi = function(fn, blink)
    local ip = wifi.sta.getip()

    if(ip==nil) then
        print("Connecting...")
        pcall(blink, 1)
    else
        tmr.stop(0)
        print("Connected to AP!")
        print("My IP address: " .. ip)

        -- my function
        if fn and file.exists(fn) then
            dofile (fn)
        end
    end
end


--------------------------------------------------------------------------------------
-- 读取配置文件config.json到config中
load_cfg("config.json")
M.config = config
print("config: " .. json.encode(config))

setup_wifi()

M.start = function(filename , blink)
    tmr.alarm(0, 1000, tmr.ALARM_AUTO, function() 
        check_wifi(filename, blink) 
    end)
end

return M

