-- Motion Sensor
-- This script will provide a service to turn lights on and off via the motion sensor component
-- The service will wait for incoming messages and act accordingly
-- Requires: block:motion_sensor

local component = require("component")
local event = require("event")
local sides = require("sides")

-- Component Verification

if not component.isAvailable("motion_sensor") then
  io.stderr:write("This program requires a block:motion_sensor that must be connected to the computer.\n")
  return 1
end

local motion_sensor = component.motion_sensor

if not component.isAvailable("redstone") then
    io.stderr:write("This program requires a redstone card or redstone I/O block.\n")
    return 1
end

local rs = component.redstone

-- Intro

print("****************************")
print("* Motion Controlled Lights *")
print("****************************")

print("Watching for motion....")


-- Start Service
local stopMe = false
local running = false

while not stopMe do

  local _, address, relativeX, relativeY, relativeZ, entityName = event.pull("motion")

  print("address: " .. address)
  print("relativeX: " .. relativeX)
  print("relativeY: " .. relativeY)
  print("relativeZ: " .. relativeZ)
  print("entityName: " .. entityName)
  
  if not running and entityName then
    rs.setOutput(sides.right, 10)
    rs.setOutput(sides.left, 10)
    rs.setOutput(sides.front, 10)
    rs.setOutput(sides.back, 10)
    running = true
    entityName = nil
  end

  if running and entityName then
    rs.setOutput(sides.right, 0)
    rs.setOutput(sides.left, 0)
    rs.setOutput(sides.front, 0)
    rs.setOutput(sides.back, 0)
    running = false
    entityName = nil
  end
  
  -- sleep until the user interrupts the program with CTRL + C
  event.listen("interrupted", function() stopMe = true; end)
  os.sleep(0.5)
end
