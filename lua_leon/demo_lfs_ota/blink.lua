-- This module is only for operating the one led (pin:1) on NodeMCU bordard 
-- leonstill@163.com
-- 2018.12.01 16:00

local t, i = ...

led_switch = function(light)
    local pin = 0
    gpio.mode(pin, gpio.OUTPUT)
    if(light==0) then
        gpio.write(pin, gpio.HIGH)
    else
        gpio.write(pin, gpio.LOW)
    end
end

led_blink = function(times, interval)
    led_switch(1)
    led_switch(0)  
    times = times - 1
    if(times>0) then
        tmr.alarm(6, interval, tmr.ALARM_AUTO, function()
            led_switch(1)
            --for i=1,100 do end
            led_switch(0)  
            times = times - 1
            if (times<=0) then
                tmr.unregister(6)
            end
        end)
    end
end

led_blink(t,i)
