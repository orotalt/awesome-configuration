-- Quake like console on top
-- Similar to:
--   http://git.sysphere.org/awesome-configs/tree/scratch/drop.lua

-- But uses a different implementation. The main difference is that we
-- are able to detect the Quake console from its name
-- (QuakeConsoleNeedsUniqueName by default).

-- If you have a rule like "awful.client.setslave" for your terminals,
-- ensure you use an exception for
-- QuakeConsoleNeedsUniqueName. Otherwise, you may run into problems
-- with focus.

local setmetatable = setmetatable
local string = string
local awful  = require("awful")
local capi   = { mouse = mouse,
		 screen = screen,
		 client = client,
		 timer = timer }

-- I use a namespace for my modules...
module("vbe/quake")

local QuakeConsole = {}

-- Display
function QuakeConsole:display()
   -- First, we locate the terminal
   local client = nil
   local i = 0
   for c in awful.client.cycle(function (c)
				  -- c.name may be changed!
				  return (c.instance == self.name or c.role == self.name)
			       end) do
      client = c
      client:tags({})
      break
   end

   if not client and not self.visible then
      -- The terminal is not here yet but we don't want it yet. Just do nothing.
      return
   end

   if not client then
      -- The client does not exist, we spawn it
      awful.util.spawn(self.terminal .. " " .. string.format(self.argname, self.name))
      return
   end

   -- Comptute size
   local geom = capi.screen[capi.mouse.screen].workarea
   local width, height = self.width, self.height
   if width  <= 1 then width = geom.width * width end
   if height <= 1 then height = geom.height * height end
   local x, y
   if     self.horiz == "left"  then x = geom.x
   elseif self.horiz == "right" then x = geom.width + geom.x - width
   else   x = geom.x + (geom.width - width)/2 end
   if     self.vert == "top"    then y = geom.y
   elseif self.vert == "bottom" then y = geom.height + geom.y - height
   else   y = geom.y + (geom.height - height)/2 end

   -- Resize
   awful.client.floating.set(client, true)
   client.border_width = 0
   client.size_hints_honor = false
   client:geometry({ x = x, y = y, width = width, height = height })

   -- Sticky and on top
   client.ontop = true
   client.above = true
   client.skip_taskbar = true
   client.sticky = true

   -- This is not a normal window, don't apply any specific keyboard stuff
   client:buttons({})
   client:keys({})

   -- Toggle display
   if self.visible then
      client.hidden = false
      client:raise()
      capi.client.focus = client
   else
      client.hidden = true
   end
end

-- Create a console
function QuakeConsole:new(config)
   -- The "console" object is just its configuration.

   -- The application to be invoked is:
   --   config.terminal .. " " .. string.format(config.argname, config.name)
   config.terminal = config.terminal or "xterm" -- application to spawn
   config.name     = config.name     or "QuakeConsoleNeedsUniqueName" -- window name
   config.argname  = config.argname  or "-name %s"     -- how to specify window name

   -- If width or height <= 1 this is a proportion of the workspace
   config.height   = config.height   or 0.25	       -- height
   config.width    = config.width    or 1	       -- width
   config.vert     = config.vert     or "top"	       -- top, bottom or center
   config.horiz    = config.horiz    or "center"       -- left, right or center

   config.visible  = config.visible or false -- Initially, not visible

   local console = setmetatable(config, { __index = QuakeConsole })
   capi.client.add_signal("manage",
			  function(c)
			     if (c.instance == console.name or c.role == console.name) then
				console:display()
			     end
			  end)
   capi.client.add_signal("unmanage",
			  function(c)
			     if (c.instance == console.name or c.role == console.name) then
				console.visible = false
			     end
			  end)

   -- "Reattach" currently running QuakeConsole. This is in case awesome is restarted.
   local reattach = capi.timer { timeout = 0 }
   reattach:add_signal("timeout",
		       function()
			  reattach:stop()
			  console:display()
		       end)
   reattach:start()
   return console
end

-- Toggle the console
function QuakeConsole:toggle()
   self.visible = not self.visible
   self:display()
end

setmetatable(_M, { __call = function(_, ...) return QuakeConsole:new(...) end })
