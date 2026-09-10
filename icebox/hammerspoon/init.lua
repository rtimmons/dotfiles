hs.window.animationDuration = 0

local STEP = 100
local F17  = hs.keycodes.map["f17"]
local F18  = hs.keycodes.map["f18"]

local MOVE_ACTIONS = {
  [hs.keycodes.map["left"]]  = function(w, f, sf, shift)
    if shift then f.x = sf.x             else f.x = f.x - STEP end
  end,
  [hs.keycodes.map["right"]] = function(w, f, sf, shift)
    if shift then f.x = sf.x + sf.w - f.w else f.x = f.x + STEP end
  end,
  [hs.keycodes.map["up"]]    = function(w, f, sf, shift)
    if shift then f.y = sf.y             else f.y = f.y - STEP end
  end,
  [hs.keycodes.map["down"]]  = function(w, f, sf, shift)
    if shift then f.y = sf.y + sf.h - f.h else f.y = f.y + STEP end
  end,
}

local RESIZE_ACTIONS = {
  [hs.keycodes.map["left"]]  = function(w, f) f.w = math.max(STEP, f.w - STEP) end,
  [hs.keycodes.map["right"]] = function(w, f) f.w = math.max(STEP, f.w + STEP) end,
  [hs.keycodes.map["up"]]    = function(w, f) f.h = math.max(STEP, f.h - STEP) end,
  [hs.keycodes.map["down"]]  = function(w, f) f.h = math.max(STEP, f.h + STEP) end,
}

local m4Down = false
local m5Down = false

local modWatcher = hs.eventtap.new(
  { hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp },
  function(e)
    local kc   = e:getKeyCode()
    local down = (e:getType() == hs.eventtap.event.types.keyDown)
if kc == F17 then m4Down = down; return true end
    if kc == F18 then m5Down = down; return true end
    return false
  end
)

local actionWatcher = hs.eventtap.new(
  { hs.eventtap.event.types.keyDown },
  function(e)
    if not m5Down then return false end
    local w = hs.window.focusedWindow()
    if not w then return true end
    local f  = w:frame()
    local sf = w:screen():frame()
    if m4Down then
      local action = RESIZE_ACTIONS[e:getKeyCode()]
      if not action then return false end
      action(w, f)
    else
      local action = MOVE_ACTIONS[e:getKeyCode()]
      if not action then return false end
      action(w, f, sf, e:getFlags().shift)
    end
    w:setFrame(f)
    return true
  end
)

local watchers = { modWatcher, actionWatcher }

local function startWatchers()
  for _, w in ipairs(watchers) do w:start() end
end

local function guardWatchers()
  for _, w in ipairs(watchers) do
    if not w:isEnabled() then w:start() end
  end
end

local caffWatcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.systemDidWake
  or event == hs.caffeinate.watcher.screensDidUnlock then
    m4Down = false
    m5Down = false
    startWatchers()
  end
end)
caffWatcher:start()

local guardTimer = hs.timer.new(10, guardWatchers)
guardTimer:start()

startWatchers()
