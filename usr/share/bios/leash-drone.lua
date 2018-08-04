-- Leash Drone v0.2
-- This drone bios will fly to a position and leash an animal
-- Requires Leash Upgrade and Navigation Upgrade

-- proxyFor
-- Loads a component
local function proxyFor(name, required)
  local address = component and component.list(name)()
  if not address and required then
    error("missing component '" .. name .. "'")
  end
  return address and component.proxy(address) or nil
end

-- Assign our requirements
local drone = proxyFor("drone", true)
local nav = proxyFor("navigation", true)
local modem = proxyFor("modem", true)
local leash = proxyFor("leash")
--local invctrl = proxyFor("inventory_controller")

-- Colors used to indicate different states of operation.
local colorCharing = 0xFFCC33
local colorSearching = 0x66CC66
local colorDelivering = 0x6699FF

-- Keep track of our own position
-- relative to our starting position.
local px, py, pz = 0, 0, 0

-- Move
-- Move drone to a specific offset from our current position
local function moveTo(x, y, z)
  if type(x) == "table" then
    x, y, z = x[1], x[2], x[3]
  end
  local rx, ry, rz = x - px, y - py, z - pz
  drone.move(rx, ry, rz)
  while drone.getOffset() > 0.5 or drone.getVelocity() > 0.5 do
    computer.pullSignal(0.5)
  end
  px, py, pz = x, y, z
end


-- Recharge
local function recharge()
  drone.setLightColor(colorCharing)
  moveTo(0, 0, 0)
  if computer.energy() < computer.maxEnergy() * 0.1 then
    while computer.energy() < computer.maxEnergy() * 0.9 do
      computer.pullSignal(1)
    end
  end
  drone.setLightColor(colorSearching)
end

-- Scan an entire square-block
-- and attempt leashing an unknown entity
local function attemptLeashing(area, outPort)
    local square = 1
    local nsquare = 0

    -- Positive
    while tonumber(square) <= tonumber(area) do
        nsquare = 0 - square

        local height = 2

        moveTo(square, height, 0)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. tostring(square) .. " " .. tostring(height) .. " " .. "0"))
        leash.leash(0)

        moveTo(nsquare, height, 0)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. tostring(nsquare) .. " " .. tostring(height) .. " " .. "0"))
        leash.leash(0)

        moveTo(0, height, square)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. 0 .. " " .. tostring(height) .. " " .. tostring(square)))
        leash.leash(0)

        moveTo(0, height, nsquare)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. 0 .. " " .. tostring(height) .. " " .. tostring(nsquare)))
        leash.leash(0)

        moveTo(square, height, square)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. tostring(square) .. " " .. tostring(height) .. " " .. tostring(square)))
        leash.leash(0)

        moveTo(nsquare, height, nsquare)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. tostring(nsquare) .. " " .. tostring(height) .. " " .. tostring(nsquare)))
        leash.leash(0)

        moveTo(nsquare, height, square)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. tostring(nsquare) .. " " .. tostring(height) .. " " .. tostring(square)))
        leash.leash(0)

        moveTo(square, height, nsquare)
        modem.broadcast(tonumber(outPort), tostring("NAVIGATION : " .. tostring(square) .. " " .. tostring(height) .. " " .. tostring(nsquare)))
        leash.leash(0)

        square = square + 1
    end
end

-- Communication ports
local inPort = 321
local outPort = 123
local strength = 100

-- Open our listening inPort
modem.open(inPort)

-- Main program loop
while true do
  recharge()
  local msg, _, from, port, _, command, param = computer.pullSignal()
  modem.setStrength(strength)

  if tostring(command) == "unleash" then
    leash.unleash()
  else
    attemptLeashing(command, outPort)
    modem.broadcast(tonumber(outPort), "finished")
    --modem.close(inPort)
  end
end
