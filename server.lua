local function getCore()
  local ok, core

  ok, core = pcall(function() return exports['qbx_core']:GetCoreObject() end)
  if ok and core then return core end

  ok, core = pcall(function() return exports['qbx-core']:GetCoreObject() end)
  if ok and core then return core end

  ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
  if ok and core then return core end

  if QBX then return QBX end
  if QBCore then return QBCore end

  return nil
end

local Core = getCore()

local TRACKED_JOBS = {
  police = true,
  ambulance = true,
  mechanic = true,
  taxi = true,
  burger = true,
}

local function getPlayer(src)
  if Core and Core.Functions and Core.Functions.GetPlayer then
    return Core.Functions.GetPlayer(src)
  end
  return nil
end

local function getAllPlayers()
  if Core and Core.Functions and Core.Functions.GetQBPlayers then
    return Core.Functions.GetQBPlayers()
  end

  if Core and Core.Functions and Core.Functions.GetPlayers then
    local ids = Core.Functions.GetPlayers()
    local players = {}
    for _, src in pairs(ids) do
      players[src] = getPlayer(src)
    end
    return players
  end

  return {}
end

local function countJobsOnline()
  local counts = {}
  for jobName, _ in pairs(TRACKED_JOBS) do
    counts[jobName] = 0
  end

  local players = getAllPlayers()
  for _, ply in pairs(players) do
    if ply and ply.PlayerData and ply.PlayerData.job and ply.PlayerData.job.name then
      local j = ply.PlayerData.job.name
      if TRACKED_JOBS[j] then
        counts[j] = (counts[j] or 0) + 1
      end
    end
  end

  return counts
end

local function buildData(source)
  local Player = getPlayer(source)
  if not Player then return nil end

  local pd = Player.PlayerData or {}
  local money = pd.money or {}

  local salary = (pd.job and pd.job.payment) or 0

  local fullname = GetPlayerName(source)
  if pd.charinfo and pd.charinfo.firstname and pd.charinfo.lastname then
    fullname = (pd.charinfo.firstname .. " " .. pd.charinfo.lastname)
  end

  return {
    id = source,
    name = fullname,
    jobLabel = (pd.job and pd.job.label) or "Unemployed",
    jobName  = (pd.job and pd.job.name) or "unemployed",
    cash = money.cash or 0,
    bank = money.bank or 0,
    salary = salary,

    expLevel = 0,
    craftingLevel = 0,
    drugsLevel = 0,

    counters = countJobsOnline()
  }
end

if lib and lib.callback then
  lib.callback.register('qbx_scoreboard_pro:getScoreboardData', function(source)
    return buildData(source)
  end)
else
  if not (Core and Core.Functions and Core.Functions.CreateCallback) then
    print("^1[qbx_scoreboard_pro]^7 Callback system tidak ditemukan (ox_lib / qb-core).")
    return
  end

  Core.Functions.CreateCallback('qbx_scoreboard_pro:server:getScoreboardData', function(source, cb)
    cb(buildData(source))
  end)
end
