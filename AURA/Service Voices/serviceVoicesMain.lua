local serviceVoicesData = require("tew\\AURA\\Service Voices\\serviceVoicesData")
local config = require("tew\\AURA\\config")
local debugLogOn=config.debugLogOn
local modversion = require("tew\\AURA\\version")
local version = modversion.version

local raceNames=serviceVoicesData.raceNames
local commonVoices=serviceVoicesData.commonVoices
local travelVoices=serviceVoicesData.travelVoices
local spellVoices=serviceVoicesData.spellVoices
local trainingVoices=serviceVoicesData.trainingVoices

local serviceRepair=config.serviceRepair
local serviceSpells=config.serviceSpells
local serviceTraining=config.serviceTraining
local serviceSpellmaking=config.serviceSpellmaking
local serviceEnchantment=config.serviceEnchantment
local serviceTravel=config.serviceTravel
local serviceBarter=config.serviceBarter

local trainingFlag = 0

local function debugLog(string)
   if debugLogOn then
      mwse.log("[AURA "..version.."] SV: "..string)
   end
end

local function serviceGreet(e)

   local npcId=tes3ui.getServiceActor(e)
   local raceId=npcId.object.race.id
   local raceLet, sexLet
   local serviceFeed={}

   if npcId.object.female then
      debugLog("Female NPC found.")
      sexLet="f"
   else
      sexLet="m"
      debugLog("Male NPC found.")
   end

   for k, v in pairs(raceNames) do
      if raceId==k then
         raceLet=v
      end
   end

   for kRace, _ in pairs(commonVoices) do
      if kRace==raceLet then
         for kSex, _ in pairs(commonVoices[kRace]) do
            if kSex==sexLet then
               for _, voice in pairs(commonVoices[kRace][kSex]) do
                  table.insert(serviceFeed, voice)
               end
            end
         end
      end
   end

   if serviceFeed[1] then
      tes3.say{
      volume=1.0,
      soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
      serviceFeed[math.random(1, #serviceFeed)]..".mp3", reference=npcId
      }
      debugLog("NPC says a service comment.")
   end
end

local function spell_repairGreet(e)
   local element=e.element

   if serviceSpellmaking then
      local function saySpell()
         local npcId=tes3ui.getServiceActor(e)
         local raceId=npcId.object.race.id
         local raceLet, sexLet
         local serviceFeed={}

         if npcId.object.female then
            debugLog("Female NPC found.")
            sexLet="f"
         else
            sexLet="m"
            debugLog("Male NPC found.")
         end

         for k, v in pairs(raceNames) do
            if raceId==k then
               raceLet=v
            end
         end

         for kRace, _ in pairs(spellVoices) do
            if kRace==raceLet then
               for kSex, _ in pairs(spellVoices[kRace]) do
                  if kSex==sexLet then
                     for _, voice in pairs(spellVoices[kRace][kSex]) do
                        table.insert(serviceFeed, voice)
                     end
                  end
               end
            end
         end

         if serviceFeed[1] then
            tes3.say{
            volume=1.0,
            soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
            serviceFeed[math.random(1, #serviceFeed)]..".mp3", reference=npcId
            }
            debugLog("NPC says a spellmaker comment.")
         end
      end

      local spellsButton=element:findChild(tes3ui.registerID("MenuDialog_service_spellmaking"))

      spellsButton:register("mouseDown", saySpell)
   end


   if serviceSpells then
      local function saySpell()
         local npcId=tes3ui.getServiceActor(e)
         local raceId=npcId.object.race.id
         local raceLet, sexLet
         local serviceFeed={}

         if npcId.object.female then
            debugLog("Female NPC found.")
            sexLet="f"
         else
            sexLet="m"
            debugLog("Male NPC found.")
         end

         for k, v in pairs(raceNames) do
            if raceId==k then
               raceLet=v
            end
         end

         for kRace, _ in pairs(spellVoices) do
            if kRace==raceLet then
               for kSex, _ in pairs(spellVoices[kRace]) do
                  if kSex==sexLet then
                     for _, voice in pairs(spellVoices[kRace][kSex]) do
                        table.insert(serviceFeed, voice)
                     end
                  end
               end
            end
         end

         if serviceFeed[1] then
            tes3.say{
            volume=1.0,
            soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
            serviceFeed[math.random(1, #serviceFeed)]..".mp3", reference=npcId
            }
            debugLog("NPC says a spell vendor comment.")
         end
      end

      local spellsButton=element:findChild(tes3ui.registerID("MenuDialog_service_spells"))

      spellsButton:register("mouseDown", saySpell)
   end

   if serviceRepair then
      local function sayRepair()
         local npcId=tes3ui.getServiceActor(e)
         local raceId=npcId.object.race.id
         local raceLet, sexLet
         local serviceFeed={}

         if npcId.object.female then
            debugLog("Female NPC found.")
            sexLet="f"
         else
            sexLet="m"
            debugLog("Male NPC found.")
         end

         for k, v in pairs(raceNames) do
            if raceId==k then
               raceLet=v
            end
         end

         for kRace, _ in pairs(commonVoices) do
            if kRace==raceLet then
               for kSex, _ in pairs(commonVoices[kRace]) do
                  if kSex==sexLet then
                     for _, voice in pairs(commonVoices[kRace][kSex]) do
                        table.insert(serviceFeed, voice)
                     end
                  end
               end
            end
         end

         if serviceFeed[1] then
            tes3.say{
            volume=1.0,
            soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
            serviceFeed[math.random(1, #serviceFeed)]..".mp3", reference=npcId
            }
            debugLog("NPC says a repair comment.")
         end
      end

      local repairButton=element:findChild(tes3ui.registerID("MenuDialog_service_repair"))

      repairButton:register("mouseDown", sayRepair)
   end
end

local function travelGreet(e)

   local npcId=tes3ui.getServiceActor(e)
   local raceId=npcId.object.race.id
   local raceLet, sexLet
   local serviceFeed={}

   if npcId.object.female then
      debugLog("Female NPC found.")
      sexLet="f"
   else
      sexLet="m"
      debugLog("Male NPC found.")
   end

   for k, v in pairs(raceNames) do
      if raceId==k then
         raceLet=v
      end
   end

   for kRace, _ in pairs(travelVoices) do
      if kRace==raceLet then
         for kSex, _ in pairs(travelVoices[kRace]) do
            if kSex==sexLet then
               for _, voice in pairs(travelVoices[kRace][kSex]) do
                  table.insert(serviceFeed, voice)
               end
            end
         end
      end
   end

   if serviceFeed[1] then
      tes3.say{
      volume=1.0,
      soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
      serviceFeed[math.random(1, #serviceFeed)]..".mp3", reference=npcId
      }
      debugLog("NPC says a travel comment.")
   else
      serviceGreet()
   end

end


local function trainingGreet(e)

   local closeButton=e.element:findChild(tes3ui.registerID("MenuServiceTraining_Okbutton"))
   closeButton:register("mouseDown", function()
      trainingFlag=0
   end)

   if trainingFlag==1 then return end

   local npcId=tes3ui.getServiceActor(e)
   local raceId=npcId.object.race.id
   local raceLet, sexLet
   local serviceFeed={}

   if npcId.object.female then
      debugLog("Female NPC found.")
      sexLet="f"
   else
      sexLet="m"
      debugLog("Male NPC found.")
   end

   for k, v in pairs(raceNames) do
      if raceId==k then
         raceLet=v
      end
   end

   for kRace, _ in pairs(trainingVoices) do
      if kRace==raceLet then
         for kSex, _ in pairs(trainingVoices[kRace]) do
            if kSex==sexLet then
               for _, voice in pairs(trainingVoices[kRace][kSex]) do
                  table.insert(serviceFeed, voice)
               end
            end
         end
      end
   end

   if serviceFeed[1] then
      tes3.say{
      volume=1.0,
      soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
      serviceFeed[math.random(1, #serviceFeed)]..".mp3", reference=npcId
      }
      debugLog("NPC says a trainer comment.")
   else
      serviceGreet()
   end
   trainingFlag=1

end

debugLog("[AURA] Service voices module initialised.")

event.register("uiActivated", spell_repairGreet, {filter="MenuDialog"})

if serviceTravel then event.register("uiActivated", travelGreet, {filter="MenuServiceTravel"}) end
if serviceBarter then event.register("uiActivated", serviceGreet, {filter="MenuBarter"}) end
if serviceTraining then event.register("uiActivated", trainingGreet, {filter="MenuServiceTraining"}) end
if serviceEnchantment then event.register("uiActivated", serviceGreet, {filter="MenuEnchantment"}) end