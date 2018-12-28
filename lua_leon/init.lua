-- when somthing wrong in lua scripts and a dead loop happens, we could remove this file
-- by sending the command 'file.remote("init.lua")' to NodeMCU while it is booting
-- in the first second!
-- by leon(leonstill@163.com) 2018.12.02

-------------------------------------------------------------------------------
-- GPIO init 
-- 当使用node.dsleep()时，需要将管脚pin0和RST相连接，此时不要设置pin0（，或设置pin0为INPUT模式），否则会无限重启！
--gpio.mode(0, gpio.INPUT)
--gpio.mode(0, gpio.OUTPUT)
--gpio.write(0, gpio.HIGH)

-------------------------------------------------------------------------------
-- init adc for vcc
if adc.force_init_mode(adc.INIT_ADC)
then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

print("System voltage (mV):", adc.read(0))

-------------------------------------------------------------------------------
-- init timezone and sntp sync
tz = require('tz')
tz.setzone('Chongqing')
-- https://nodemcu.readthedocs.io/en/latest/en/modules/sntp/#sntp.sync()
-- 不需要明确调用rtctime.set()，因为当使能rtctime模块后，会自动调用。
sntp.sync(nil, function(now)
    local tm = rtctime.epoch2cal(now + tz.getoffset(now))
    print(string.format("SNTP server sync time: %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
  end, function() 
    print("SNTP server sync failed!")
  end
)


-------------------------------------------------------------------------------
-- init flash
if node.flashindex() == nil then 
  node.flashreload('flash.img') 
end
-- LFS.blink ~= nil and LFS.blink or function(t, i) print("blink " .. t .. " with ".. i) end

tmr.alarm(0, 1000, tmr.ALARM_SINGLE,
  function()
    local fi=node.flashindex
    local result = pcall(fi and fi'_init')
    print("LFS._init " .. (result and "ok" or "failed") )
    --local led_blink = node.flashindex('blink') or function() end
    if LFS then
        if result then
            local wifi = require("wifi_init");
            wifi.start("task.lua")
        else
            LFS.blink(3, 150)
        end
    end
  end)
