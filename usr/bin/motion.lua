-- Motion Sensor
-- This script will provide a service to turn lights on and off via the motion sensor component
-- The service will wait for incoming messages and act accordingly
-- Requires: block:motion_sensor

local component = require("component")
local event = require("event")

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

while not stopMe do

  local _, address, relativeX, relativeY, relativeZ, entityName = event.pull("motion")

  print("address: " .. address)
  print("relativeX: " .. relativeX)
  print("relativeY: " .. relativeY)
  print("relativeZ: " .. relativeZ)
  print("entityName: " .. entityName)
  
  if running == on then
    rs.setOutput(side, 15)
  end

  if running == off then
    rs.setOutput(side, 0)
  end
  
  -- sleep until the user interrupts the program with CTRL + C
  local stopMe = false
  event.listen("interrupted", function() stopMe = true; end)
  while not stopMe do os.sleep(0.1) end
end
