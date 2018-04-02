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
  ["Show All"] = 1,
  ["Raids"] = 2,
  ["Dungeons"] = 3,
  ["Adventures"] = 4,
  ["Expeditions"] = 5,
  ["PvP"] = 6,
  ["Quests and Events"] = 7,
  ["Open World"] = 8,
}

local ktCategoriesToActivities = {
  ["Raids"] = {
    ["Genetic Archives"] = {
    },
    ["Datascape"] = {
    },
    ["Redmoon Terror"] = {
    },
  },
  ["Dungeons"] = {
    ["Placeholder"] = {
    },
    ["Placeholder 2"] = {
    },
  },
  ["Adventures"] = {
    ["Placeholder"] = {
    },
    ["Placeholder 2"] = {
    },
  },
  ["Expeditions"] = {
    ["Placeholder"] = {
    },
    ["Placeholder 2"] = {
    },
  },
  ["PvP"] = {
    ["Placeholder"] = {
    },
    ["Placeholder 2"] = {
    },
  },
  ["Quests and Events"] = {
    ["Placeholder"] = {
    },
    ["Placeholder 2"] = {
    },
  },
  ["Open World"] = {
    ["Placeholder"] = {
    },
    ["Placeholder 2"] = {
    },
  },
}

local ktCategoriesToSprite = {
  ["Show All"] = "IconSprites:Icon_Mission_Scientist_SpecimenSurvey",
  ["Raids"] = "IconSprites:Icon_Mission_Settler_Posse",
  ["Dungeons"] = "IconSprites:Icon_Mission_Explorer_Explorerdoor",
  ["Adventures"] = "IconSprites:Icon_Mission_Explorer_Vista",
  ["Expeditions"] = "charactercreate:sprCharC_Finalize_SkillLevel2",
  ["PvP"] = "Contracts:sprContracts_PvP",
  ["Quests and Events"] = "matchmaker:ContentType_Quest",
  ["Open World"] = "CRB_InterfaceMenuList:spr_InterfaceMenuList_SilverFlagStretch",
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
  self.wndMain:FindChild("TabContentListLeft"):SetAnchorOffsets(0, 0, 0, 0)
  self.wndMain:FindChild("FilterSettings"):Show(false)
  self.wndMain:FindChild("TabContentRightCreateSearchEntry"):Show(true)
  self.wndMain:FindChild("TabContentRight"):SetSprite(tMatchmakerSprites[math.random(#tMatchmakerSprites)])
  self:BuildCreateSearchEntriesActivitiesList()
end

function BetterGroupFinder:BuildCategoriesList()
  for eCategoryType, nSortOrder in orderedPairs(ktCategoriesData) do
    local wndParent = self.wndMain:FindChild("TabContentListLeft")
    local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "FilterCategoriesBase", wndParent, self)
    local wndCurrItemBtnText = wndCurrItem:FindChild("FilterCategoriesBaseBtnText")
    local wndCurrItemBtnIcon = wndCurrItem:FindChild("FilterCategoriesBaseBtnIcon")
    wndCurrItemBtnIcon:SetSprite(ktCategoriesToSprite[eCategoryType])
    wndCurrItemBtnText:SetText(eCategoryType)
    wndCurrItem:SetData(eCategoryType)
    wndCurrItem:SetAnchorPoints(0, 0, 0, 0)
    local nLeft, nTop, nRight, nBottom = wndCurrItem:GetAnchorOffsets()
    wndCurrItem:SetAnchorOffsets(nLeft, ((nSortOrder - 1) * 60), (nRight - 8), (nSortOrder * 60))
  end
end

function BetterGroupFinder:BuildActivitiesList()
  local i = 1
  while i < 20 do
    local wndParent = self.wndMain:FindChild("TabContentRightTopListOfSeekers")
    local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "TabContentRightGridItemBase", wndParent, self)
    local wndCurrItemTitleText = wndCurrItem:FindChild("TabContentRightItemBaseBtnTitle")
    local wndCurrItemGroupStatusText = wndCurrItem:FindChild("TabContentRightItemBaseBtnGroupStatusText")
    local wndCurrItemBtn = wndCurrItem:FindChild("TabContentRightItemBaseBtn")
    wndCurrItemTitleText:SetText("title iter - " .. i)
    wndCurrItemGroupStatusText:SetText(i .. "/∞")
    wndCurrItemBtn:SetTooltip("Looking for awesome players to pew pew! - iter " .. i)
    local nLeft, nTop, nRight, nBottom = wndCurrItem:GetAnchorOffsets()
    wndCurrItem:SetAnchorOffsets(nLeft, ((i - 1) * 45), (nRight), (i * 45))
    i = i + 1
  end
end

function BetterGroupFinder:BuildCreateSearchEntriesActivitiesList()
  for key, value in orderedPairs(ktCategoriesData) do
    if value ~= 1 then
      local wndParent = self.wndMain:FindChild("TabContentListLeft")
      local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "MatchSelectionParent", wndParent, self)
      local wndCurrItemTitleText = wndCurrItem:FindChild("MatchBtn")
      wndCurrItemTitleText:SetText(key)
      self:BuildCreateSearchEntriesActivity(wndCurrItem, key)
    end
  end
  self.wndMain:FindChild("TabContentListLeft"):ArrangeChildrenVert(0)
end

function BetterGroupFinder:BuildCreateSearchEntriesActivity(wndParent, strCategory)
  local wndContainer = wndParent:FindChild("MatchEntries")
  local nCount = 0
  for key, value in orderedPairs(ktCategoriesToActivities[strCategory]) do
    local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "MatchSelection", wndContainer, self)
    local wndCurrItemTitleText = wndCurrItem:FindChild("MatchBtn")
    wndCurrItemTitleText:SetText(key)
    
    nCount = nCount + 1
  end
  local nLeft, nTop, nRight, nBottom = wndParent:GetAnchorOffsets()
  wndParent:SetAnchorOffsets(nLeft, ((nCount - 1) * 45), (nRight), (nCount * 82))
  wndContainer:ArrangeChildrenVert(0)
end


-----------------------------------------------------------------------------------------------
-- BetterGroupFinder Instance
-----------------------------------------------------------------------------------------------
local BetterGroupFinderInst = BetterGroupFinder:new()
BetterGroupFinderInst:Init()
