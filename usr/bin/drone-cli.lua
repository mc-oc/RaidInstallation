-- Leash Drone Client
-- Requires: Wireless Card

-- Requirements
local component = require("component")
local shell = require("shell")

-- Remote requirements
local event = require("event")

if not component.modem then
  io.stderr:write("This program requires a modem.\n")
  return 1
end
local m = component.modem


local term = require 'term'
local gpu = component.getPrimary 'gpu'

--          text                   color          palette color? (true or false) (optional)
-- Takes ( 'some string to color', number_color, [isPaletteColor] )
local function cWrite( text, fgc, pIndex )
	local old_fgc, isPalette = gpu.getForeground()
	pIndex = ( type( pIndex ) == 'boolean' ) and pIndex or false
	gpu.setForeground( fgc, pIndex )
	term.write( text )
	gpu.setForeground( old_fgc, isPalette )
end

local function log(type, message)
    cWrite('[', 0xFFFFFF)
    cWrite(type, 0x7CFC00)
    cWrite('] : ' .. tostring(message), 0xFFFFFF)
end

-- Configurations
local inPort = 123
local outPort = 321
local strength = 100

-- Arguments
local args, options = shell.parse(...)

local bc_listener = args[1]
local area = args[2]

if not area or not bc_listener then
  print("Usage: drone-cli <monitor_messages> <area_size>\n")
  print("Examples")
  print("-----------")
  print("  drone-cli yes 5")
  print("  drone-cli 1 5")
  print("  drone-cli 1 unleash")
  print("  drone-cli no 10")
  print("  drone-cli 0 10")
  print("  drone-cli 0 unleash")
  return 1
end

-- Usage:
cWrite('*************************\n', 0x7CFC00)
cWrite('*   ', 0x7CFC00)
cWrite('Drone Client v0.1', 0xFFFFFF)
cWrite('   *\n', 0x7CFC00)
cWrite('*************************\n\n', 0x7CFC00)

log('LOG', 'WIRELESS => Signal strength is ' .. tostring(strength) .. '\n')
m.setStrength(tonumber(strength))

if area == 'unleash' then
    log('LOG', 'WIRELESS => Unleashing\n')
    return 1
end

log('LOG', 'NETWORKING : Initializing drone for a ' .. tostring(area) .. ' square block area\n')
m.broadcast(tonumber(outPort), tostring(area))

-- Monitor drone broadcast messages
if bc_listener == "yes" or bc_listener == "1" then
    log('LOG', 'NETWORKING : Port open for broadcast message\n')
    m.open(inPort)

    local no_resp_cnt = 1

    while true do
        local _, _, from, port, _, message = event.pull(5, "modem_message")

        if message == nil then
            message = "No response"
            no_resp_cnt = no_resp_cnt + 1
        end

        if no_resp_cnt >= 10 then
            log('LOG', 'NETWORKING : Assuming connection lost, killing\n')
            break
        end

        log('DRONE', tostring(message) .. '\n')

        if message == "finished" then
            log('LOG', 'NAVIGATION : Drone run complete\n')
            m.close(inPort)
            log('LOG', 'NETWORKING : Port closed\n')
            break
        end
    end
end