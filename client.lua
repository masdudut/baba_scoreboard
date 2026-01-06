local isOpen = false

local function requestDataAndSend(action)
  if lib and lib.callback then
    local data = lib.callback.await('qbx_scoreboard_pro:getScoreboardData', false)
    SendNUIMessage({ action = action, payload = data })
    return
  end

  local core
  local ok
  ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
  if not ok or not core then ok, core = pcall(function() return exports['qbx_core']:GetCoreObject() end) end
  if not ok or not core then ok, core = pcall(function() return exports['qbx-core']:GetCoreObject() end) end

  if core and core.Functions and core.Functions.TriggerCallback then
    core.Functions.TriggerCallback('qbx_scoreboard_pro:server:getScoreboardData', function(data)
      SendNUIMessage({ action = action, payload = data })
    end)
  end
end

local function openScoreboard()
  if isOpen then return end
  isOpen = true
  requestDataAndSend("open")
end

local function closeScoreboard()
  if not isOpen then return end
  isOpen = false
  SendNUIMessage({ action = "close" })
end

RegisterCommand('+qbx_scoreboard', function()
  openScoreboard()
end, false)

RegisterCommand('-qbx_scoreboard', function()
  closeScoreboard()
end, false)

RegisterKeyMapping('+qbx_scoreboard', 'Open Scoreboard (Hold)', 'keyboard', 'F10')

CreateThread(function()
  while true do
    if isOpen then
      requestDataAndSend("update")
      Wait(5000)
    else
      Wait(300)
    end
  end
end)
