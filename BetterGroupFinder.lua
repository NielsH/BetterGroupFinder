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
  ["SubmitSearchEntry"] = {
    ["nId"] = 1,
    ["nSearchEntryId"] = 2,
    ["strTitle"] = 3,
    ["bMiniLvl"] = 4,
    ["strMiniLvl"] = 5,
    ["bHeroism"] = 6,
    ["strHeroism"] = 7,
    ["strDescription"] = 8,
    ["tCategoriesSelection"] = 9,
    ["nTimeStamp"] = 10,
  },
}

local ktMsgQueue = {}
local ktSearchEntries = {}
local nLocalSearchEntriesCount = 0

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

function BetterGroupFinder:SendMessage()
  local tMessage = {
    testkey1 = "testvalue1",
    testkey2 = "testvalue2",
  }
  self.channel:SendMessage(self:Serialize(tMessage))
end

function BetterGroupFinder:OnICCommMessageReceived(channel, strMessage, idMessage)
  local message = self:Decode(strMessage)
  if type(message) ~= "table" then
      return
  end
  self:CPrint(idMessage .. " - " .. strMessage)
  rover = Apollo.GetAddon("Rover")
  rover:AddWatch("msg", self:Deserialize(strMessage), 0)
end

function BetterGroupFinder:OnICCommSendMessageResult(iccomm, eResult, idMessage)
  self:CPrint("DEBUG - OnICCommSendMessageResult")
end

function BetterGroupFinder:OnICCommThrottled(iccomm, strSender, idMessage)
  self:CPrint("DEBUG - OnICCommThrottled")
end

function BetterGroupFinder:JoinICCommChannel()
  self:CPrint("debug 1")
  self.timerJoinICCommChannel = nil

  self.channel = ICCommLib.JoinChannel("BetterGroupFinder", ICCommLib.CodeEnumICCommChannelType.Global)
  if not self.channel:IsReady() then
      self:CPrint("debug 2")
      self.timerJoinICCommChannel = ApolloTimer.Create(3, false, "JoinICCommChannel", self)
  else
      self:CPrint("debug 3")
      self.timerJoinICCommChannel = ApolloTimer.Create(3, false, "SendMessage", self)
      self.channel:SetReceivedMessageFunction("OnICCommMessageReceived", self)
      self.channel:SetSendMessageResultFunction("OnICCommSendMessageResult", self)
      self.channel:SetThrottledFunction("OnICCommThrottled", self)
  end
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
  self.wndMain:FindChild("TabContentListLeft"):DestroyChildren()
  self.wndMain:FindChild("TabContentListLeft"):SetAnchorOffsets(0, 64, 0, 0)
  self.wndMain:FindChild("FilterSettings"):Show(true)
  self.wndMain:FindChild("CreateSearchEntryControlContainer"):Show(false)
  self.wndMain:FindChild("TabContentRightCreateSearchEntry"):Show(false)
  self.wndMain:FindChild("TabContentRight"):SetSprite("")
  self:BuildCategoriesList()
  self:BuildActivitiesList()
end

function BetterGroupFinder:SelectCreateSearchEntryHeader()
  self:SetHeaderLeftText(ktTabData["CreateSearchEntryTab"].strHeaderLeftLabelText)
  self.wndMain:FindChild("CreateSearchEntryBtn"):SetCheck(true)
  self.wndMain:FindChild("ListOfSeekersBtn"):SetCheck(false)
  self.wndMain:FindChild("TabContentListLeft"):DestroyChildren()
  self.wndMain:FindChild("FilterSettings"):Show(false)
  self.wndMain:FindChild("CreateSearchEntryControlContainer"):Show(true)
  self.wndMain:FindChild("TabContentRightCreateSearchEntry"):Show(true)
  self.wndMain:FindChild("TabContentRight"):SetSprite(tMatchmakerSprites[math.random(#tMatchmakerSprites)])
  self:BuildCreateSearchEntriesActivitiesList()
end

function BetterGroupFinder:BuildCategoriesList()
  for nSortOrder, tData in pairs(ktCategoriesData) do
    local wndParent = self.wndMain:FindChild("TabContentListLeft")
    local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "FilterCategoriesBase", wndParent, self)
    local wndCurrItemBtnText = wndCurrItem:FindChild("FilterCategoriesBaseBtnText")
    local wndCurrItemBtnIcon = wndCurrItem:FindChild("FilterCategoriesBaseBtnIcon")
    wndCurrItemBtnIcon:SetSprite(tData["strIconSprite"])
    wndCurrItemBtnText:SetText(tData["strName"])
    wndCurrItem:SetData(tData["strName"])
    wndCurrItem:SetAnchorPoints(0, 0, 0, 0)
    local nLeft, nTop, nRight, nBottom = wndCurrItem:GetAnchorOffsets()
    wndCurrItem:SetAnchorOffsets(nLeft, ((nSortOrder - 1) * 60), (nRight - 8), (nSortOrder * 60))
  end
end

function BetterGroupFinder:BuildActivitiesList()
  local wndParent = self.wndMain:FindChild("TabContentRightTopListOfSeekers")
  wndParent:DestroyChildren()
  local i = 1
  for k, v in pairs(ktSearchEntries) do
    if v[ktMessageTypes["nMsgTypeId"]] == ktMessageTypes["SubmitSearchEntry"]["nId"] then
      local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "TabContentRightGridItemBase", wndParent, self)
      local wndCurrItemTitleText = wndCurrItem:FindChild("TabContentRightItemBaseBtnTitle")
      local wndCurrItemGroupStatusText = wndCurrItem:FindChild("TabContentRightItemBaseBtnGroupStatusText")
      local wndCurrItemBtn = wndCurrItem:FindChild("TabContentRightItemBaseBtn")
      wndCurrItemTitleText:SetText(v[ktMessageTypes["SubmitSearchEntry"]["strTitle"]])
      wndCurrItemGroupStatusText:SetText("n/a")
      wndCurrItemBtn:SetTooltip(v[ktMessageTypes["SubmitSearchEntry"]["strDescription"]])
      wndCurrItem:SetData(v[ktMessageTypes["SubmitSearchEntry"]["nSearchEntryId"]])
      local nLeft, nTop, nRight, nBottom = wndCurrItem:GetAnchorOffsets()
      wndCurrItem:SetAnchorOffsets(nLeft, ((i - 1) * 45), (nRight), (i * 45))
      i = i + 1
    end
  end
  SendVarToRover("ktSearchEntries", ktSearchEntries, 0)
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

  local msgType = ktMessageTypes["SubmitSearchEntry"]
  local ktSearchEntry = {
    [ktMessageTypes["nMsgTypeId"]] = msgType["nId"],
    [msgType["strTitle"]] = strTitle,
    [msgType["bMiniLvl"]] = bMiniLvl,
    [msgType["strMiniLvl"]] = strMiniLvl,
    [msgType["bHeroism"]] = bHeroism,
    [msgType["strHeroism"]] = strHeroism,
    [msgType["strDescription"]] = strDescription,
    [msgType["tCategoriesSelection"]] = tCategoriesSelection,
    [msgType["nSearchEntryId"]] = GameLib.GetPlayerCharacterName() .. "|" .. (nLocalSearchEntriesCount + 1),
    [msgType["nTimeStamp"]] = os.time(),
  }
  nLocalSearchEntriesCount = nLocalSearchEntriesCount + 1
  table.insert(ktSearchEntries, ktSearchEntry)

end


-----------------------------------------------------------------------------------------------
-- BetterGroupFinder Instance
-----------------------------------------------------------------------------------------------
local BetterGroupFinderInst = BetterGroupFinder:new()
BetterGroupFinderInst:Init()
