-- window.lua

local gui = require("gui_core")

local Window = {}
Window.__index = Window

function Window:new(x, y, w, h, title)
    local o = setmetatable({}, self)
    o.x, o.y, o.w, o.h = x, y, w, h
    o.title = title or "Window"
    o.elements = {}
    o.drag = false
    o.dragOffX, o.dragOffY = 0, 0
    o.closed = false
    return o
end

function Window:add(elem)
    table.insert(o.elements, elem)
end

function Window:addElement(elem)
    table.insert(self.elements, elem)
end

function Window:draw()
    -- рамка
    term.setBackgroundColor(colors.gray)
    for yy = self.y, self.y + self.h - 1 do
        term.setCursorPos(self.x, yy)
        term.write(string.rep(" ", self.w))
    end

    -- заголовок
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(self.x, self.y)
    term.write(string.rep(" ", self.w))
    term.setCursorPos(self.x + 1, self.y)
    term.setTextColor(colors.white)
    term.write(self.title)

    -- кнопка закрытия [X]
    term.setCursorPos(self.x + self.w - 3, self.y)
    term.setTextColor(colors.red)
    term.write("[X]")

    -- содержимое
    local ox, oy = self.x, self.y + 1
    for _, e in ipairs(self.elements) do
        e:updateHover(gui.events, ox, oy)
        e:draw(ox, oy)
    end
end

function Window:handleEvents()
    for _, e in ipairs(gui.events) do
        local name = e[1]

        if name == "mouse_click" then
            local _, btn, mx, my = table.unpack(e)

            -- клик по заголовку
            if my == self.y and mx >= self.x and mx < self.x + self.w then
                -- клик по [X]
                if mx >= self.x + self.w - 3 then
                    self.closed = true
                    return
                end
                gui.bringToFront(self)
                self.drag = true
                self.dragOffX = mx - self.x
                self.dragOffY = my - self.y
            end

            -- клик по содержимому
            local ox, oy = self.x, self.y + 1
            for _, el in ipairs(self.elements) do
                if el.check then
                    el:check(gui.events, ox, oy)
                end
            end
        end

        if name == "mouse_up" then
            self.drag = false
        end

        if name == "mouse_drag" and self.drag then
            local _, _, mx, my = table.unpack(e)
            self.x = mx - self.dragOffX
            self.y = my - self.dragOffY
        end
    end
end

-------------------------------------------------
-- ЭЛЕМЕНТЫ
-------------------------------------------------

local Element = gui.Element

local Button = setmetatable({}, Element)
Button.__index = Button

function Button:new(x, y, w, h, label, onClick)
    local o = Element.new(self, x, y, w, h)
    o.label = label
    o.onClick = onClick
    return o
end

function Button:draw(ox, oy)
    local bg = self.hover and colors.lightGray or colors.gray
    self:drawBase(bg, ox, oy)
    term.setTextColor(colors.white)
    term.setCursorPos(ox + self.x + math.floor((self.w - #self.label)/2),
                      oy + self.y + math.floor(self.h/2))
    term.write(self.label)
end

function Button:check(events, ox, oy)
    for _, e in ipairs(events) do
        if e[1] == "mouse_click" then
            local _, _, mx, my = table.unpack(e)
            mx, my = mx - ox, my - oy
            if self:contains(mx, my) and self.onClick then
                self.onClick()
            end
        end
    end
end

local Checkbox = setmetatable({}, Element)
Checkbox.__index = Checkbox

function Checkbox:new(x, y, label)
    local o = Element.new(self, x, y, #label + 4, 1)
    o.label = label
    o.value = false
    return o
end

function Checkbox:draw(ox, oy)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(ox + self.x, oy + self.y)
    term.write("[" .. (self.value and "x" or " ") .. "] " .. self.label)
end

function Checkbox:check(events, ox, oy)
    for _, e in ipairs(events) do
        if e[1] == "mouse_click" then
            local _, _, mx, my = table.unpack(e)
            mx, my = mx - ox, my - oy
            if self:contains(mx, my) then
                self.value = not self.value
            end
        end
    end
end

local TextField = setmetatable({}, Element)
TextField.__index = TextField

function TextField:new(x, y, w)
    local o = Element.new(self, x, y, w, 1)
    o.text = ""
    o.focus = false
    return o
end

function TextField:draw(ox, oy)
    term.setBackgroundColor(self.focus and colors.blue or colors.black)
    term.setTextColor(colors.white)
    local shown = self.text
    if #shown > self.w then
        shown = shown:sub(#shown - self.w + 1)
    end
    term.setCursorPos(ox + self.x, oy + self.y)
    term.write(shown .. string.rep(" ", self.w - #shown))
end

function TextField:check(events, ox, oy)
    for _, e in ipairs(events) do
        local name = e[1]
        if name == "mouse_click" then
            local _, _, mx, my = table.unpack(e)
            mx, my = mx - ox, my - oy
            self.focus = self:contains(mx, my)
        elseif self.focus and name == "char" then
            self.text = self.text .. e[2]
        elseif self.focus and name == "key" and e[2] == keys.backspace then
            self.text = self.text:sub(1, -2)
        end
    end
end

return {
    Window = Window,
    Button = Button,
    Checkbox = Checkbox,
    TextField = TextField,
}