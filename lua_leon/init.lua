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
            wifi.start("task.lua", LFS.blink)
        else 
            LFS.blink(3, 150) 
        end
    end
  end)
