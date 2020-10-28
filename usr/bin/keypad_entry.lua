local component = require("component")

keypad = require("component").os_keypad
event = require("event")

local pin = "1234"
local keypadInput = ""

local sides = require("sides")
local open = "open"
local close = "close"

-- set this to true if you want to run the script as daemon
local runScriptInBackground = false

if not component.isAvailable("redstone") then
    io.stderr:write("This program requires a redstone card or redstone I/O block.\n")
    return 1
end

local rs = component.redstone

function updateDisplay()
    local displayString = ""
    for i=1,#keypadInput do
        displayString = displayString .. "*"
    end

    keypad.setDisplay(displayString, 7)
end

function checkPin()
    if keypadInput == pin then
        keypad.setDisplay("granted", 2)
        rs.setOutput(sides.right, 10)
        rs.setOutput(sides.left, 10)
        rs.setOutput(sides.front, 10)
        rs.setOutput(sides.back, 10)
        rs.setOutput(sides.bottom, 10)
        os.sleep(1)
        rs.setOutput(sides.right, 0)
        rs.setOutput(sides.left, 0)
        rs.setOutput(sides.front, 0)
        rs.setOutput(sides.back, 0)
        rs.setOutput(sides.bottom, 0)
    else
        keypad.setDisplay("denied", 4)
        rs.setOutput(sides.right, 0)
        rs.setOutput(sides.left, 0)
        rs.setOutput(sides.front, 0)
        rs.setOutput(sides.back, 0)
        rs.setOutput(sides.bottom, 0)
    end
    keypadInput = ""
    os.sleep(1)
end

function keypadEvent(eventName, address, button, button_label)
    print("button pressed: " .. button_label)

    if button_label == "*" then
        -- remove last character from input cache
        keypadInput = string.sub(keypadInput, 1, -2)
    elseif button_label == "#" then
        -- check the pin when the user confirmed the input
        checkPin()
    else
        -- add key to input cache if none of the above action apply
        keypadInput = keypadInput .. button_label
    end

    updateDisplay()
end

-- listen to keypad events
event.listen("keypad", keypadEvent)

-- clear keypad display
keypad.setDisplay("")


if not runScriptInBackground then
    -- sleep until the user interrupts the program with CTRL + C
    local stopMe = false
    event.listen("interrupted", function() stopMe = true; end)
    while not stopMe do os.sleep(0.1) end

    -- ignore keypad events on exit
    event.ignore("keypad", keypadEvent)

    -- show that the keypad is inactive
    keypad.setDisplay("inactive", 6)
end
