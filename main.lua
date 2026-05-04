local gui = require("gui_core")
local winlib = require("window")

term.setBackgroundColor(colors.black)
term.clear()

local win1 = winlib.Window:new(3, 2, 30, 10, "First Window")
local win2 = winlib.Window:new(10, 6, 30, 10, "Second Window")

local logY = 19
local function log(msg)
    term.setCursorPos(1, logY)
    term.setBackgroundColor(colors.black)
    term.clearLine()
    term.setTextColor(colors.green)
    term.write(msg)
end

local btn1 = winlib.Button:new(2, 1, 12, 3, "Press", function()
    log("Button in Window 1")
end)

local chk1 = winlib.Checkbox:new(2, 5, "Checkbox")
local txt1 = winlib.TextField:new(2, 7, 20)

win1:addElement(btn1)
win1:addElement(chk1)
win1:addElement(txt1)

local btnClose2 = winlib.Button:new(2, 1, 16, 3, "Close Window 2", function()
    gui.removeWindow(win2)
    log("Second window closed")
end)

local chk2 = winlib.Checkbox:new(2, 5, "Flag")
local txt2 = winlib.TextField:new(2, 7, 20)

win2:addElement(btnClose2)
win2:addElement(chk2)
win2:addElement(txt2)

gui.addWindow(win1)
gui.addWindow(win2)

while true do
    gui.poll()

    for i = #gui.windows, 1, -1 do
        local w = gui.windows[i]
        w:handleEvents()
        if w.closed then
            gui.removeWindow(w)
        end
    end

    gui.draw()

    if #gui.windows == 0 then
        log("All windows closed. Exit.")
        break
    end

    sleep(0)
end