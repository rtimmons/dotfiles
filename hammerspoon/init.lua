hs.window.animationDuration = 0

local STEP = 100
local F18  = hs.keycodes.map["f18"]

local ACTIONS = {
  [hs.keycodes.map["left"]]  = function(w, f, sf, shift)
    if shift then f.x = sf.x            else f.x = f.x - STEP end
  end,
  [hs.keycodes.map["right"]] = function(w, f, sf, shift)
    if shift then f.x = sf.x + sf.w - f.w else f.x = f.x + STEP end
  end,
  [hs.keycodes.map["up"]]    = function(w, f, sf, shift)
    if shift then f.y = sf.y            else f.y = f.y - STEP end
  end,
  [hs.keycodes.map["down"]]  = function(w, f, sf, shift)
    if shift then f.y = sf.y + sf.h - f.h else f.y = f.y + STEP end
  end,
  [hs.keycodes.map["]"]]     = function(w, f, sf, shift)
    f.w = math.max(STEP, f.w + STEP)
  end,
  [hs.keycodes.map["["]]     = function(w, f, sf, shift)
    f.w = math.max(STEP, f.w - STEP)
  end,
  [hs.keycodes.map["="]]     = function(w, f, sf, shift)
    f.h = math.max(STEP, f.h + STEP)
  end,
  [hs.keycodes.map["-"]]     = function(w, f, sf, shift)
    f.h = math.max(STEP, f.h - STEP)
  end,
}

local m5Down = false

local m5Watcher = hs.eventtap.new(
  { hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp },
  function(e)
    if e:getKeyCode() ~= F18 then return false end
    m5Down = (e:getType() == hs.eventtap.event.types.keyDown)
    return true  -- consume F18 so it never reaches apps
  end
)

local actionWatcher = hs.eventtap.new(
  { hs.eventtap.event.types.keyDown },
  function(e)
    if not m5Down then return false end
    local action = ACTIONS[e:getKeyCode()]
    if not action then return false end
    local w = hs.window.focusedWindow()
    if not w then return true end
    local f  = w:frame()
    local sf = w:screen():frame()
    action(w, f, sf, e:getFlags().shift)
    w:setFrame(f)
    return true  -- consume the key
  end
)

m5Watcher:start()
actionWatcher:start()
