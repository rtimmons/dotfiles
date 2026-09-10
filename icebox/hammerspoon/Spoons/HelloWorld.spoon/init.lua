local obj = {}
obj.__index = obj

obj.name = "HelloWorld"
obj.version = "1.0"
obj.author = "Ryan Timmons"
obj.license = "MIT"

function obj:init() end

function obj:start()
    hs.hotkey.bind({"cmd", "alt"}, "W", function()
        hs.notify.new({title = "Hammerspoon", informativeText = "Hello World"}):send()
    end)
end

return obj
