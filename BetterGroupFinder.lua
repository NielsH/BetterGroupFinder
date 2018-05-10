-----------------------------------------------------------------------------------------------
-- Client Lua Script for BetterGroupFinder
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "ICComm"
require "ICCommLib"
 
-----------------------------------------------------------------------------------------------
-- BetterGroupFinder Module Definition
-----------------------------------------------------------------------------------------------
local BetterGroupFinder = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local ktTabData = {
  ["ListOfSeekersTab"] = {
    strHeaderLeftLabelText = "Categories and Filter",
  },
  ["CreateSearchEntryTab"] = {
    strHeaderLeftLabelText = "Pick content",
  },
}

local ktCategoriesData = {
  [1] = {
    ["strName"] = "Show All",
    ["bShowCreateSearchEntry"] = false,
    ["ktEntries"] = {},
    ["strIconSprite"] = "IconSprites:Icon_Mission_Scientist_SpecimenSurvey",
  },
  [2] = {
    ["strName"] = "Raids",
    ["bShowCreateSearchEntry"] = true,
    ["strIconSprite"] = "IconSprites:Icon_Mission_Settler_Posse",
    ["ktEntries"] = {
      [1] = "Genetic Archives",
      [2] = "Datascape",
      [3] = "Redmoon Terror",
      [4] = "Custom",
    },
  },
  [3] = {
    ["strName"] = "Dungeons",
    ["bShowCreateSearchEntry"] = true,
    ["strIconSprite"] = "IconSprites:Icon_Mission_Explorer_Explorerdoor",
    ["ktEntries"] = {
      [1] = "Protogames Academy",
      [2] = "Stormtalon's Lair",
      [3] = "Ruins of Kel Voreth",
      [4] = "Skullcano",
      [5] = "Sanctuary of the Swordmaiden",
      [6] = "Ultimate Protogames",
      [7] = "Coldblood Citadel",
      [8] = "Custom",
    },
  },
  [4] = {
    ["strName"] = "Adventures",
    ["bShowCreateSearchEntry"] = true,
    ["strIconSprite"] = "IconSprites:Icon_Mission_Explorer_Vista",
    ["ktEntries"] = {
      [1] = "War of the Wilds",
      [2] = "The Siege of Tempest Refuge",
      [3] = "Crimelords of Whitevale",
      [4] = "The Malgrave Trail",
      [5] = "Bay of Betrayal",
      [6] = "Riot in the Void",
      [7] = "Custom",
    },
  },
  [5] = {
    ["strName"] = "Expeditions",
    ["bShowCreateSearchEntry"] = true,
    ["strIconSprite"] = "charactercreate:sprCharC_Finalize_SkillLevel2",
    ["ktEntries"] = {
      [1] = "Fragment Zero",
      [2] = "Outpost M-13",
      [3] = "Infestation",
      [4] = "Evil from the Ether",
      [5] = "Rage Logic",
      [6] = "Space Madness",
      [7] = "Deep Space Exploration",
      [8] = "Gauntlet",
      [9] = "Custom",
    },
  },
  [6] = {
    ["strName"] = "PvP",
    ["bShowCreateSearchEntry"] = true,
    ["strIconSprite"] = "Contracts:sprContracts_PvP",
    ["ktEntries"] = {
      [1] = "Walatiki Temple",
      [2] = "Daggerstone Pass",
      [3] = "Halls of the Bloodsworn: Reloaded",
      [4] = "Warplot",
      [5] = "Arena - 2v2",
      [6] = "Arena - 3v3",
      [7] = "Arena - 5v5",
      [8] = "Custom",
    },
  },
  [7] = {
    ["strName"] = "Open World and Quests",
    ["bShowCreateSearchEntry"] = true,
    ["strIconSprite"] = "IconSprites:Icon_Mission_Explorer_ClaimTerritory",
    ["ktEntries"] = {
      [1] = "Custom",
    },
  },
}

local tMatchmakerSprites = {
  "matchmaker:Matchmaker_BG_AdventureCrimelords",
  "matchmaker:Matchmaker_BG_AdventureHycrest",
  "matchmaker:Matchmaker_BG_AdventureMalgrave",
  "matchmaker:Matchmaker_BG_AdventureOutpost",
  "matchmaker:Matchmaker_BG_Adventures",
  "matchmaker:Matchmaker_BG_AdventureWaroftheWilds",
  "matchmaker:Matchmaker_BG_Arenas",
  "matchmaker:Matchmaker_BG_Battlegrounds",
  "matchmaker:Matchmaker_BG_BattlegroundsBloodsworn",
  "matchmaker:Matchmaker_BG_BattlegroundsBoneshatter",
  "matchmaker:Matchmaker_BG_BattlegroundsDaggerstone",
  "matchmaker:Matchmaker_BG_BattlegroundsWalatiki",
  "matchmaker:Matchmaker_BG_DungeonKelvoreth",
  "matchmaker:Matchmaker_BG_Dungeons",
  "matchmaker:Matchmaker_BG_DungeonSkullcano",
  "matchmaker:Matchmaker_BG_DungeonStormtalon",
  "matchmaker:Matchmaker_BG_DungeonSwordmaiden",
  "matchmaker:Matchmaker_BG_Expeditions",
  "matchmaker:Matchmaker_BG_RaidDatascape",
  "matchmaker:Matchmaker_BG_ShiphandsDeepSpace",
  "matchmaker:Matchmaker_BG_ShiphandsFragmentZero",
  "matchmaker:Matchmaker_BG_ShiphandsGauntlet",
  "matchmaker:Matchmaker_BG_ShiphandsInfestation",
  "matchmaker:Matchmaker_BG_ShiphandsRageLogic",
  "matchmaker:Matchmaker_BG_ShiphandsSpaceMadness",
  "matchmaker:Matchmaker_BG_Warplots",
}

local ktMessageTypes = {
  ["nMsgTypeId"] = 1,
  -- make sure not to repeat the above value as another value below
  ["SearchEntry"] = {
    ["nId"] = 2,
    ["strSearchEntryId"] = 3,
    ["strTitle"] = 4,
    ["bMiniLvl"] = 5,
    ["strMiniLvl"] = 6,
    ["bHeroism"] = 7,
    ["strHeroism"] = 8,
    ["strDescription"] = 9,
    ["tCategoriesSelection"] = 10,
    ["nTimeStamp"] = 11,
    ["nMemberCount"] = 12,
  },
  ["SplittedMsg"] = {
    ["nId"] = 3,
    ["nCurrItem"] = 2,
    ["nTotalItems"] = 4,
    ["strItemData"] = 5,
    ["strItemId"] = 6,
  },
}

local ktMsgQueue = {}
local ktMsgQueueTimestamps = {}
local ktSearchEntries = {}
local ktSplittedMsgReceived = {}
local bICCommThrottled = false
local nLocalSearchEntriesCount = 0
local nCreateListingsMsgQueueTimerInterval = 5
local nProcessMsgQueueTimerInterval = 10
local nRemoveStaleSearchEntriesTimerInterval = 60

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function BetterGroupFinder:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function BetterGroupFinder:Init()
  local bHasConfigureFunction = false
  local strConfigureButtonText = ""
  local tDependencies = {
    -- "UnitOrPackageName",
  }
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
local function __genOrderedIndex( t )
  local orderedIndex = {}
  for key in pairs(t) do
    table.insert( orderedIndex, key )
  end
  table.sort( orderedIndex )
  return orderedIndex
end

local function orderedNext(t, state)
  -- Equivalent of the next function, but returns the keys in the alphabetic
  -- order. We use a temporary ordered key table that is stored in the
  -- table being iterated.

  local key = nil
  --print("orderedNext: state = "..tostring(state) )
  if state == nil then
    -- the first time, generate the index
    t.__orderedIndex = __genOrderedIndex( t )
    key = t.__orderedIndex[1]
  else
    -- fetch the next value
    for i = 1,table.getn(t.__orderedIndex) do
      if t.__orderedIndex[i] == state then
        key = t.__orderedIndex[i+1]
      end
    end
  end

  if key then
    return key, t[key]
  end

  -- no more value to return, cleanup
  t.__orderedIndex = nil
  return
end

local function orderedPairs(t)
  -- Equivalent of the pairs() function on tables. Allows to iterate
  -- in order
  return orderedNext, t, nil
end

-----------------------------------------------------------------------------------------------
-- BetterGroupFinder OnLoad
-----------------------------------------------------------------------------------------------
function BetterGroupFinder:OnLoad()
    -- load our form file
  self.xmlDoc = XmlDoc.CreateFromFile("BetterGroupFinder.xml")
  self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- BetterGroupFinder OnDocLoaded
-----------------------------------------------------------------------------------------------
function BetterGroupFinder:OnDocLoaded()

  if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
      self.wndMain = Apollo.LoadForm(self.xmlDoc, "BetterGroupFinderForm", nil, self)
    if self.wndMain == nil then
      Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
      return
    end
    
    self.wndMain:Show(false, true)

    -- Register handlers for events, slash commands and timer, etc.
    -- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
    Apollo.RegisterSlashCommand("bgf", "OnBetterGroupFinderOn", self)
    self.json = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage

    -- Do additional Addon initialization here
    self.timerjoinICCommChannel = ApolloTimer.Create(5, false, "JoinICCommChannel", self)
    self.wndListOfSeekersList = self.wndMain:FindChild("ListOfSeekersTab")
    self.wndCreateSearchEntryList = self.wndMain:FindChild("CreateSearchEntryTab")
    self.wndHeaderButtons = self.wndMain:FindChild("HeaderButtons"):GetChildren()
  end
end

-----------------------------------------------------------------------------------------------
-- BetterGroupFinder Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/bgf"
function BetterGroupFinder:OnBetterGroupFinderOn()
  self.wndMain:Invoke() -- show the window

  -- if no header is selected yet show the default one
  local bHeaderIsSelected = false
  for _, btn in pairs(self.wndHeaderButtons) do
    if not bHeaderIsSelected and btn:IsChecked() then
      bHeaderIsSelected = true
      self:OnHeaderBtnCheck(btn, nil, nil)
    end
  end
  if not bHeaderIsSelected then
    self:SelectListOfSeekersHeader()
  end
end

function BetterGroupFinder:RemoveStaleSearchEntries()
  local nCurrTime = os.time()
  local nMaxMsgAge = 1200 -- 20 minutes
  for k, v in pairs(ktSearchEntries) do
    local ktSearchEntryData = ktMessageTypes["SearchEntry"]
    local strSearchEntryId = v[ktSearchEntryData["strSearchEntryId"]]
    if nCurrTime - v[ktSearchEntryData["nTimeStamp"]] > nMaxMsgAge then
      ktSearchEntries[k] = nil
      self:BuildActivitiesList(ktSearchEntries)
    end
  end
end

function BetterGroupFinder:SplitStringByChunk(text, chunkSize)
  local s = {}
  for i=1, #text, chunkSize do
    s[#s+1] = text:sub(i,i+chunkSize - 1)
  end
  return s
end

function BetterGroupFinder:CreateListingsMsgQueue()
  for k, v in pairs(ktSearchEntries) do
    local ktSearchEntryData = ktMessageTypes["SearchEntry"]
    local strSearchEntryId = v[ktSearchEntryData["strSearchEntryId"]]
    local strCharacterName, nListingCount = strSearchEntryId:match("([^|]+)|([^|]+)")
    if GameLib.GetPlayerCharacterName() == strCharacterName then
      if not ktMsgQueue[strSearchEntryId] then
        ktMsgQueue[strSearchEntryId] = {}
        v[ktSearchEntryData["nMemberCount"]] = (GroupLib.GetMemberCount() == 0 and 1) or GroupLib.GetMemberCount()
        v[ktSearchEntryData["nTimeStamp"]] = os.time()
        local sMsgFull = self.json.encode(v, {"keyorder"})
        local tMsgSplitted = self:SplitStringByChunk(sMsgFull, 25)
        local nMsgSplittedCount = #tMsgSplitted
        for nCount, item in orderedPairs(tMsgSplitted) do
          local t = {
            [ktMessageTypes["nMsgTypeId"]] = ktMessageTypes["SplittedMsg"]["nId"],
            [ktMessageTypes["SplittedMsg"]["nCurrItem"]] = nCount,
            [ktMessageTypes["SplittedMsg"]["nTotalItems"]] = nMsgSplittedCount,
            [ktMessageTypes["SplittedMsg"]["strItemData"]] = item,
            [ktMessageTypes["SplittedMsg"]["strItemId"]] = strSearchEntryId,
          }
          ktMsgQueue[strSearchEntryId][nCount] = t
        end
      end
    end
  end
end

function BetterGroupFinder:ProcessMsgQueue()
  k, v = next(ktMsgQueue)
  if k and v then
    item, value = next(v)
    if item and value then
      self:SendMessage(value)
      ktMsgQueue[k][item] = nil
    else
      -- we've processed all items in the queue for this message
      ktMsgQueue[k] = nil
    end
  end
end

function BetterGroupFinder:DisableICCommSelfThrottle()
  bICCommThrottled = false
end

function BetterGroupFinder:EnableICCommSelfThrottle()
  if not bICCommThrottled then
    self:CPrint("Better Group Finder - warning: it's taking a long time for our messages to be sent. We are probably being throttled by the game which prevents the addon from working correctly. Attempting to auto-resolve by stopping sending out messages for a few minutes. If this issue persists try relogging.")
    bICCommThrottled = true
  end
  -- override existing timer if it exists so we have >120 sec of no delayed messages
  self.timerDisableThrottledStatus = ApolloTimer.Create(120, false, "DisableICCommSelfThrottle", self)
end

function BetterGroupFinder:DetectICCommThrottled()
  local currTime = os.time()
  local nSlowICCommMsgs = 0
  for k, v in pairs(ktMsgQueueTimestamps) do
    if currTime - v > nProcessMsgQueueTimerInterval then
      nSlowICCommMsgs = nSlowICCommMsgs + 1
      if nSlowICCommMsgs > 10 then
        -- we're not able to process the queue fast enough. Carbine throttled us, we should stop and wait.
        self:EnableICCommSelfThrottle()
      end
    end
  end
end

function BetterGroupFinder:AssembleICCommMessage(tMsgParts)
  local bStatus, strMessageCombined = pcall(function() return table.concat(tMsgParts) end)
  if bStatus then
    return self.json.decode(strMessageCombined, 1, null, nil)
  else
    return false
  end
end

function BetterGroupFinder:SendMessage(tMessage)
  if not bICCommThrottled then
    local nICCommMsgId = self.channel:SendMessage(self.json.encode(tMessage, {"keyorder"}))
    ktMsgQueueTimestamps[nICCommMsgId] = os.time()
  end
end

function BetterGroupFinder:OnICCommMessageReceived(channel, strMessage, idMessage)
  local message = self.json.decode(strMessage)
  if type(message) ~= "table" then
      return
  end

  if message[ktMessageTypes["nMsgTypeId"]] == ktMessageTypes["SplittedMsg"]["nId"] then
    self:ProcessSplittedMsgReceived(message)
  end
end

function BetterGroupFinder:ProcessSplittedMsgReceived(message)
  local strItemId = message[ktMessageTypes["SplittedMsg"]["strItemId"]]
  local nCurrItem = message[ktMessageTypes["SplittedMsg"]["nCurrItem"]]
  local nTotalItems = message[ktMessageTypes["SplittedMsg"]["nTotalItems"]]
  local strItemData = message[ktMessageTypes["SplittedMsg"]["strItemData"]]
  if not ktSplittedMsgReceived[strItemId] then
    ktSplittedMsgReceived[strItemId] = {}
  end
  ktSplittedMsgReceived[strItemId][nCurrItem] = strItemData
  -- #table is not reliable, we need to count
  local nItemsCount = 0
  for _ in pairs(ktSplittedMsgReceived[strItemId]) do
    nItemsCount = nItemsCount + 1
  end
  if nItemsCount == nTotalItems then
    local ktFullMessageReceived = self:AssembleICCommMessage(ktSplittedMsgReceived[strItemId])
    if not ktFullMessageReceived then
      ktSplittedMsgReceived[strItemId] = nil
      return
    end
    if ktFullMessageReceived[ktMessageTypes["nMsgTypeId"]] == ktMessageTypes["SearchEntry"]["nId"] then
      ktSearchEntries[ktFullMessageReceived[ktMessageTypes["SearchEntry"]["strSearchEntryId"]]] = ktFullMessageReceived
      ktSplittedMsgReceived[strItemId] = nil
    end
  end
end

function BetterGroupFinder:OnICCommSendMessageResult(iccomm, eResult, idMessage)
  if not ktMsgQueueTimestamps[idMessage] or (os.time() - ktMsgQueueTimestamps[idMessage] > 5) then
    -- We're probably being throttled; we received the message result after more than 5 seconds
    -- or we don't even have the message id in our list, indicating it may have been received after a reloadui
    self:EnableICCommSelfThrottle()
  end
  ktMsgQueueTimestamps[idMessage] = nil
end

function BetterGroupFinder:OnICCommThrottled(iccomm, strSender, idMessage)
end

function BetterGroupFinder:JoinICCommChannelFailed()
  self:CPrint("Better Group Finder - warning: Unable to join addons communication channel (ICComm) for over a minute. This usually indicates we hit a wildstar bug that can only be resolved with a relog (not /reloadui).")
end

function BetterGroupFinder:JoinICCommChannel()
  self.timerJoinICCommChannel = nil

  self.channel = ICCommLib.JoinChannel("BetterGroupFinder", ICCommLib.CodeEnumICCommChannelType.Global)
  if not self.channel:IsReady() then
      self.timerJoinICCommChannel = ApolloTimer.Create(3, false, "JoinICCommChannel", self)
      if not self.timerJoinICCommChannelFailed then
        self.timerJoinICCommChannelFailed = ApolloTimer.Create(60, false, "JoinICCommChannelFailed", self)
      end
  else
      self.timerJoinICCommChannel = nil
      self.timerJoinICCommChannelFailed = nil
      self.channel:SetThrottledFunction("OnICCommThrottled", self)
      self.channel:SetReceivedMessageFunction("OnICCommMessageReceived", self)
      self.channel:SetSendMessageResultFunction("OnICCommSendMessageResult", self)
      self.timerCreateListingsMsgQueue = ApolloTimer.Create(nCreateListingsMsgQueueTimerInterval, true, "CreateListingsMsgQueue", self)
      self.timerProcessMsgQueue = ApolloTimer.Create(nProcessMsgQueueTimerInterval, true, "ProcessMsgQueue", self)
      self.timerDetectICCommThrottled = ApolloTimer.Create(nProcessMsgQueueTimerInterval, true, "DetectICCommThrottled", self)
      self.timerRemoveStaleSearchEntries = ApolloTimer.Create(nRemoveStaleSearchEntriesTimerInterval, true, "RemoveStaleSearchEntries", self)
  end
end

function BetterGroupFinder:EnumDestinations(tDestinations)
  local t = {}
  for k, v in pairs(tDestinations) do
    for item, value in pairs(v) do
      if ktCategoriesData[k]["ktEntries"][value] ~= "Custom" then
        table.insert(t, ktCategoriesData[k]["ktEntries"][value])
      end
    end
  end
  return t
end

function BetterGroupFinder:FilterSearchEntriesByCategory(nCategory)
  -- 1 is "Show all" which is a special category that requires no filtering
  if nCategory == 1 then
    return ktSearchEntries
  end
  local ktSearchEntriesFiltered = {}
  for k, v in pairs(ktSearchEntries) do
    if v[ktMessageTypes["nMsgTypeId"]] == ktMessageTypes["SearchEntry"]["nId"] then
      local tCategories = v[ktMessageTypes["SearchEntry"]["tCategoriesSelection"]]
      for nCurrCategory, tCurrCategoryData in pairs(tCategories) do
        if not ktSearchEntriesFiltered[k] and nCurrCategory == nCategory then
          ktSearchEntriesFiltered[k] = v
        end
      end
    end
  end
  return ktSearchEntriesFiltered
end

function BetterGroupFinder:Decode(str)
  if type(str) ~= "string" then
    return nil
  end
  local func = loadstring("return " .. str)
  if not func then
    return nil
  end
  setfenv(func, {})
  local success, value = pcall(func)
  return value
end

function BetterGroupFinder:Serialize(t)
  local type = type(t)
  if type == "string" then
    return ("%q"):format(t)
  elseif type == "table" then
    local tbl = {"{"}
    local indexed = #t > 0
    local hasValues = false
    for k, v in pairs(t) do
      hasValues = true
      table.insert(tbl, indexed and self:Serialize(v) or "[" .. self:Serialize(k) .. "]=" .. self:Serialize(v))
      table.insert(tbl, ",")
    end
    if hasValues then
      table.remove(tbl, #tbl)
    end
    table.insert(tbl, "}")
    return table.concat(tbl)
  end
  return tostring(t)
end

function BetterGroupFinder:Deserialize(str)
  local func = loadstring("return {" .. str .. "}")
  if func then
    setfenv(func, {})
    local succeeded, ret = pcall(func)
    if succeeded then
      return unpack(ret)
    end
  end
  return nil
end

function BetterGroupFinder:CPrint(str)
  ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Command, str, "")
end

-----------------------------------------------------------------------------------------------
-- BetterGroupFinderForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function BetterGroupFinder:OnOK()
  self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function BetterGroupFinder:OnCancel()
  self.wndMain:Close() -- hide the window
end

function BetterGroupFinder:OnHeaderBtnCheck(wndHandler, wndControl, eMouseButton)
  local wndName = wndHandler:GetName()
  for _, btn in pairs(self.wndHeaderButtons) do
    local strBtnName = btn:GetName()
    if strBtnName and strBtnName == wndName then
      if strBtnName == "ListOfSeekersBtn" then
        self:SelectListOfSeekersHeader()
      elseif strBtnName == "CreateSearchEntryBtn" then
        self:SelectCreateSearchEntryHeader()
      end
    end
  end
end

function BetterGroupFinder:SetHeaderLeftText(strText)
  local wndHeaderLeftLabel = self.wndMain:FindChild("HeaderLeftLabel"):SetText(strText)
  self.wndMain:FindChild("ListOfSeekersBtn"):SetCheck(false)
  self.wndMain:FindChild("CreateSearchEntryBtn"):SetCheck(true)
  self.wndMain:FindChild("TabContentRightTopListOfSeekers"):Show(false)
  self.wndMain:FindChild("TabContentRightBottomListOfSeekers"):Show(false)
end

function BetterGroupFinder:SelectListOfSeekersHeader()
  self:SetHeaderLeftText(ktTabData["ListOfSeekersTab"].strHeaderLeftLabelText)
  self.wndMain:FindChild("ListOfSeekersBtn"):SetCheck(true)
  self.wndMain:FindChild("CreateSearchEntryBtn"):SetCheck(false)
  self.wndMain:FindChild("TabContentRightTopListOfSeekers"):Show(true)
  self.wndMain:FindChild("TabContentRightBottomListOfSeekers"):Show(true)
  self.wndMain:FindChild("TabContentRightBottomListOfSeekers"):SetSprite(tMatchmakerSprites[math.random(#tMatchmakerSprites)])
  self.wndMain:FindChild("TabContentListLeft"):DestroyChildren()
  self.wndMain:FindChild("TabContentListLeft"):SetAnchorOffsets(0, 64, 0, 0)
  self.wndMain:FindChild("FilterSettings"):Show(true)
  self.wndMain:FindChild("CreateSearchEntryControlContainer"):Show(false)
  self.wndMain:FindChild("TabContentRightCreateSearchEntry"):Show(false)
  self.wndMain:FindChild("TabContentRight"):SetSprite("")
  self.wndMain:FindChild("TabContentRight"):FindChild("RefreshListOfSeekersBtn"):Show(true)
  self:BuildCategoriesList()
  self:BuildActivitiesList(ktSearchEntries)
end

function BetterGroupFinder:SelectCreateSearchEntryHeader()
  self:SetHeaderLeftText(ktTabData["CreateSearchEntryTab"].strHeaderLeftLabelText)
  self.wndMain:FindChild("CreateSearchEntryBtn"):SetCheck(true)
  self.wndMain:FindChild("ListOfSeekersBtn"):SetCheck(false)
  self.wndMain:FindChild("TabContentListLeft"):DestroyChildren()
  self.wndMain:FindChild("FilterSettings"):Show(false)
  self.wndMain:FindChild("CreateSearchEntryControlContainer"):Show(true)
  self.wndMain:FindChild("TabContentRightCreateSearchEntry"):Show(true)
  self.wndMain:FindChild("TabContentRight"):FindChild("RefreshListOfSeekersBtn"):Show(false)
  self.wndMain:FindChild("TabContentRight"):SetSprite(tMatchmakerSprites[math.random(#tMatchmakerSprites)])
  self:BuildCreateSearchEntriesActivitiesList()
end

function BetterGroupFinder:BuildCategoriesList()
  for nSortOrder, tData in pairs(ktCategoriesData) do
    local wndParent = self.wndMain:FindChild("TabContentListLeft")
    local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "FilterCategoriesBase", wndParent, self)
    local wndCurrItemBtn = wndCurrItem:FindChild("FilterCategoriesBaseBtn")
    local wndCurrItemBtnText = wndCurrItem:FindChild("FilterCategoriesBaseBtnText")
    local wndCurrItemBtnIcon = wndCurrItem:FindChild("FilterCategoriesBaseBtnIcon")
    wndCurrItemBtn:SetData(nSortOrder)
    if nSortOrder == 1 then
      wndCurrItemBtn:SetCheck(true)
      self.wndMain:FindChild("TabContentRight"):FindChild("RefreshListOfSeekersBtn"):SetData(nSortOrder)
    end
    wndCurrItemBtnIcon:SetSprite(tData["strIconSprite"])
    wndCurrItemBtnText:SetText(tData["strName"])
    wndCurrItem:SetData(tData["strName"])
    wndCurrItem:SetAnchorPoints(0, 0, 0, 0)
    local nLeft, nTop, nRight, nBottom = wndCurrItem:GetAnchorOffsets()
    wndCurrItem:SetAnchorOffsets(nLeft, ((nSortOrder - 1) * 57), (nRight - 8), (nSortOrder * 57))
  end
end

function BetterGroupFinder:BuildActivitiesList(ktSearchEntries)
  local wndParent = self.wndMain:FindChild("TabContentRightTopListOfSeekers")
  wndParent:DestroyChildren()
  local i = 1
  for k, v in pairs(ktSearchEntries) do
    if v[ktMessageTypes["nMsgTypeId"]] == ktMessageTypes["SearchEntry"]["nId"] then
      local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "TabContentRightGridItemBase", wndParent, self)
      local wndCurrItemTitleText = wndCurrItem:FindChild("TabContentRightItemBaseBtnTitle")
      local wndCurrItemGroupStatusText = wndCurrItem:FindChild("TabContentRightItemBaseBtnGroupStatusText")
      local wndCurrItemBtn = wndCurrItem:FindChild("TabContentRightItemBaseBtn")
      wndCurrItemTitleText:SetText(v[ktMessageTypes["SearchEntry"]["strTitle"]])
      wndCurrItemGroupStatusText:SetText(v[ktMessageTypes["SearchEntry"]["nMemberCount"]])
      wndCurrItemBtn:SetTooltip(v[ktMessageTypes["SearchEntry"]["strDescription"]])
      wndCurrItem:SetData(v[ktMessageTypes["SearchEntry"]["strSearchEntryId"]])
      wndCurrItemBtn:SetData(v[ktMessageTypes["SearchEntry"]["strSearchEntryId"]])
      local nLeft, nTop, nRight, nBottom = wndCurrItem:GetAnchorOffsets()
      wndCurrItem:SetAnchorOffsets(nLeft, ((i - 1) * 45), (nRight), (i * 45))
      i = i + 1
    end
  end
end

function BetterGroupFinder:BuildCreateSearchEntriesActivitiesList()
  for key, value in orderedPairs(ktCategoriesData) do
    if value["bShowCreateSearchEntry"] then
      local wndParent = self.wndMain:FindChild("TabContentListLeft")
      local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "MatchSelectionParent", wndParent, self)
      local wndCurrItemTitleText = wndCurrItem:FindChild("MatchBtn")
      wndCurrItemTitleText:SetText(value["strName"])
      wndCurrItemTitleText:SetData(key)
      self:BuildCreateSearchEntriesActivity(wndCurrItem, value["ktEntries"])
    end
  end
  self.wndMain:FindChild("TabContentListLeft"):ArrangeChildrenVert(0)
end

function BetterGroupFinder:BuildCreateSearchEntriesActivity(wndParent, tCategories)
  local wndContainer = wndParent:FindChild("MatchEntries")
  local nCount = 0
  for key, value in orderedPairs(tCategories) do
    local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "MatchSelection", wndContainer, self)
    local wndCurrItemTitleText = wndCurrItem:FindChild("MatchBtn")
    wndCurrItemTitleText:SetText(value)
    wndCurrItemTitleText:SetData(key)
    
    nCount = nCount + 1
  end
  local nLeft, nTop, nRight, nBottom = wndParent:GetAnchorOffsets()
  wndParent:SetAnchorOffsets(nLeft, ((nCount - 1) * 45), (nRight), (nCount * 85))
  wndContainer:ArrangeChildrenVert(0)
end

function BetterGroupFinder:OnSubmitSearchEntryBtn( wndHandler, wndControl, eMouseButton )
  local wndSearchEntryData = self.wndMain:FindChild("TabContentRightCreateSearchEntry")
  local strTitle = wndSearchEntryData:FindChild("TabContentRightCreateSearchEntryTitleBox"):GetText()
  local bMiniLvl = wndSearchEntryData:FindChild("iLvlCheckbox"):IsChecked()
  local strMiniLvl = wndSearchEntryData:FindChild("iLvlTextBox"):GetText()
  local bHeroism = wndSearchEntryData:FindChild("HeroismCheckbox"):IsChecked()
  local strHeroism = wndSearchEntryData:FindChild("HeroismTextBox"):GetText()
  local strDescription = wndSearchEntryData:FindChild("DescriptionTextBox"):GetText()
  local tCategoriesSelection = {}
  for _, tCategory in pairs(self.wndMain:FindChild("TabContentListLeft"):GetChildren()) do
    local nCategory = tCategory:FindChild("MatchBtn"):GetData()
    for __, wndCategory in pairs(tCategory:GetChildren()) do
      for ___, wndItem in pairs(wndCategory:GetChildren()) do
        local nMatchData = wndItem:FindChild("MatchBtn"):GetData()
        local bMatchSelected = wndItem:FindChild("SelectMatch"):IsChecked()
        if bMatchSelected then
          if not tCategoriesSelection[nCategory] then
            tCategoriesSelection[nCategory] = {}
          end
          table.insert(tCategoriesSelection[nCategory], nMatchData)
        end
      end
    end
  end

  if string.len(strTitle) < 2 then
    self:CPrint("Better Group Finder: Please use a longer title before submitting your search entry")
    return false
  end

  if string.len(strTitle) > 55 then
    self:CPrint("Better Group Finder: Please use a shorter title before submitting your search entry")
    return false
  end

  if string.len(strMiniLvl) > 3 then
    self:CPrint("Better Group Finder: Mimimum item level may not be more than 3 characters in your search entry")
    return false
  end

  if string.len(strHeroism) > 5 then
    self:CPrint("Better Group Finder: Minimum heroism may not be more than 5 characters in your search entry")
    return false
  end

  if string.len(strDescription) > 140 then
    self:CPrint("Better Group Finder: Description may not be longer than 140 characters in your search entry")
    return false
  end

  -- If you're here trying to increase the limit, please understand that the limit is
  -- due to the ICComm limits. If we allow "unlimited" search entries we simply can't proces them
  -- fast enough without increasing the iccomm send-rate and risk being throttled
  if nLocalSearchEntriesCount >= 3 then
    self:CPrint("Better Group Finder: You may not list more than 3 search entries at the same time")
    return false
  end

  local msgType = ktMessageTypes["SearchEntry"]
  local ktSearchEntry = {
    [ktMessageTypes["nMsgTypeId"]] = msgType["nId"],
    [msgType["strTitle"]] = strTitle,
    [msgType["bMiniLvl"]] = bMiniLvl,
    [msgType["strMiniLvl"]] = strMiniLvl,
    [msgType["bHeroism"]] = bHeroism,
    [msgType["strHeroism"]] = strHeroism,
    [msgType["strDescription"]] = strDescription,
    [msgType["tCategoriesSelection"]] = tCategoriesSelection,
    [msgType["strSearchEntryId"]] = GameLib.GetPlayerCharacterName() .. "|" .. (nLocalSearchEntriesCount + 1),
    [msgType["nTimeStamp"]] = os.time(),
    [msgType["nMemberCount"]] = (GroupLib.GetMemberCount() == 0 and 1) or GroupLib.GetMemberCount()
  }
  -- XXX TODO Removed incrementing the nLocalSearchEntriesCount
  -- This means that search entries will overwrite the previous one.
  -- Once we uncomment this line we must also have a way to manage multiple search entries
  -- And perhaps a better way (or maybe a fixed ICComm in an update (carbine pls)) to communicate
  -- with the other clients. Otherwise the amount of data is simply too much and we get throttle issues
  -- nLocalSearchEntriesCount = nLocalSearchEntriesCount + 1
  ktSearchEntries[ktSearchEntry[msgType["strSearchEntryId"]]] = ktSearchEntry
  self:SelectListOfSeekersHeader()
end

function BetterGroupFinder:OnSearchEntryListBtnCheck( wndHandler, wndControl, eMouseButton )
  local ktSearchEntryData = ktSearchEntries[wndControl:GetData()]
  if not ktSearchEntryData then
    return
  end
  local msgType = ktMessageTypes["SearchEntry"]
  local wndContainer = self.wndMain:FindChild("TabContentRightBottomListOfSeekers"):FindChild("TextContainer")
  local wndButtonsContainer = self.wndMain:FindChild("TabContentRightBottomListOfSeekers"):FindChild("ButtonsContainer")
  local strCharacterName, nListingCount = ktSearchEntryData[msgType["strSearchEntryId"]]:match("([^|]+)|([^|]+)")

  wndContainer:FindChild("Title"):SetText(ktSearchEntryData[msgType["strTitle"]])
  wndContainer:FindChild("Description"):SetText(ktSearchEntryData[msgType["strDescription"]])
  wndContainer:FindChild("LeaderLabel"):FindChild("LeaderLabelText"):SetText(strCharacterName)
  local strDestinations = table.concat(self:EnumDestinations(ktSearchEntryData[msgType["tCategoriesSelection"]]), ",")
  wndContainer:FindChild("DestinationLabel"):FindChild("DestinationLabelText"):SetText(strDestinations)
  wndButtonsContainer:FindChild("RequestInviteBtn"):SetData(ktSearchEntryData[msgType["strSearchEntryId"]])
end

function BetterGroupFinder:OnRequestInviteBtn( wndHandler, wndControl, eMouseButton )
  local strSearchEntryId = wndControl:GetData()
  local strCharacterName, nListingCount = strSearchEntryId:match("([^|]+)|([^|]+)")
  GroupLib.Join(strCharacterName)
end

function BetterGroupFinder:OnSelectFilterCategoriesBaseBtn( wndHandler, wndControl, eMouseButton )
  local nCategory = wndControl:GetData()
  self.wndMain:FindChild("TabContentRight"):FindChild("RefreshListOfSeekersBtn"):SetData(nCategory)
  local ktSearchEntriesFiltered = self:FilterSearchEntriesByCategory(nCategory)
  self:BuildActivitiesList(ktSearchEntriesFiltered)
end

function BetterGroupFinder:OnRefreshListOfSeekersBtn( wndHandler, wndControl, eMouseButton )
  local ktSearchEntriesFiltered = self:FilterSearchEntriesByCategory(wndControl:GetData())
  self:BuildActivitiesList(ktSearchEntriesFiltered)
end

-----------------------------------------------------------------------------------------------
-- BetterGroupFinder Instance
-----------------------------------------------------------------------------------------------
local BetterGroupFinderInst = BetterGroupFinder:new()
BetterGroupFinderInst:Init()
