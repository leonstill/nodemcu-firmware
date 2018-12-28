-- sendtemp.lua
-- 检查温度并上报服务器
--   by leonstill@163.com  2018-11-28
local json = sjson

m_dis={}
function dispatch(m,t,pl)
    print(t .. ":" .. (pl or "nil"))
	if pl~=nil and m_dis[t] then
		m_dis[t](m,pl)
	end
end

function topic1func(m,pl)
	print("get1: "..pl)
end

m_dis["/topic1"]=topic1func

-- init mqtt client with logins, keepalive timer 120sec
local m = mqtt.Client("nodemcu_temp02", 60, "liang", "peng")

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)

m:on("connect", function(client) 
    print("connected , heap size:"..node.heap()) 
end)
m:on("offline", function(client) print ("offline") end)

-- on publish message receive event
m:on("message", dispatch)

-- for TLS: m:connect("192.168.11.118", secure-port, 1)
m:connect("114.215.120.146", 1883, 0, function(client)
        print("client connected")
        local data = { time=rtctime.get() }
        client:publish("/login", json.encode(data), 1, 0, function(client) end)
        -- Calling subscribe/publish only makes sense once the connection
        -- was successfully established. You can do that either here in the
        -- 'connect' callback or you need to otherwise make sure the
        -- connection was established (e.g. tracking connection status or in
        -- m:on("connect", function)).

        -- subscribe topic with qos = 0
        --client:subscribe({["/topic"]=0, ["/blink"]=0}, function(client) print("subscribe success") end)
        -- publish a message with data = hello, QoS = 0, retain = 0

        tmr.alarm(1, 2000, tmr.ALARM_AUTO, function() 

            local data = get_temp() or {}
            if(data ~= nil) then
                --pcall(LFS.blink, 1)
                client:publish("/temp", json.encode(data), 0, 0, function(client) end)
            end
        end)

    end, 
    function(client, reason)
        print("failed reason: " .. reason)
    end)

--m:close();
-- you can call m:connect again

------------------------------------------------------------------
-- get temperature
get_temp = function() 
    pin = 5
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
        -- Integer firmware using this example
        -- print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
        --     math.floor(temp),
        --     temp_dec,
        --     math.floor(humi),
        --     humi_dec
        -- ))

        -- Float firmware using this example
        --print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        return { temp = temp, humi = humi }

    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
    return nil
end        
