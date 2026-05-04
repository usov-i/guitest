-- gui_core.lua

local gui = {}

gui.events = {}
gui.windows = {}
gui.activeWindow = nil

function gui.poll()
    gui.events = {}
    while true do
        local e = { os.pullEventRaw() }
        table.insert(gui.events, e)
        if e[1] ~= "mouse_drag" then break end
    end
end

function gui.addWindow(win)
    table.insert(gui.windows, win)
    gui.activeWindow = win
end

function gui.removeWindow(win)
    for i, w in ipairs(gui.windows) do
        if w == win then
            table.remove(gui.windows, i)
            if gui.activeWindow == win then
                gui.activeWindow = gui.windows[#gui.windows]
            end
            return
        end
    end
end

function gui.bringToFront(win)
    for i, w in ipairs(gui.windows) do
        if w == win then
            table.remove(gui.windows, i)
            table.insert(gui.windows, win)
            gui.activeWindow = win
            return
        end
    end
end

function gui.draw()
    term.setBackgroundColor(colors.black)
    term.clear()
    for _, w in ipairs(gui.windows) do
        w:draw()
    end
end

-- базовый элемент
local Element = {}
Element.__index = Element

function Element:new(x, y, w, h)
    local o = setmetatable({}, self)
    o.x, o.y, o.w, o.h = x, y, w, h
    o.hover = false
    return o
end

function Element:contains(mx, my)
    return mx >= self.x and mx < self.x + self.w
       and my >= self.y and my < self.y + self.h
end

function Element:updateHover(events, ox, oy)
    self.hover = false
    for _, e in ipairs(events) do
        if e[1] == "mouse_move" then
            local _, mx, my = table.unpack(e)
            mx, my = mx - ox, my - oy
            if self:contains(mx, my) then
                self.hover = true
            end
        end
    end
end

function Element:drawBase(bg, ox, oy)
    term.setBackgroundColor(bg)
    for yy = self.y, self.y + self.h - 1 do
        term.setCursorPos(self.x + ox, yy + oy)
        term.write(string.rep(" ", self.w))
    end
end

gui.Element = Element

return gui