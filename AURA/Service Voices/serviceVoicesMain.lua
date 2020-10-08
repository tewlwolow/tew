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

local UISpells = config.UISpells

local serviceRepair=config.serviceRepair
local serviceSpells=config.serviceSpells
local serviceTraining=config.serviceTraining
local serviceSpellmaking=config.serviceSpellmaking
local serviceEnchantment=config.serviceEnchantment
local serviceTravel=config.serviceTravel
local serviceBarter=config.serviceBarter

local trainingFlag = 0
local newVoice, lastVoice = "init", "init"

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
      while newVoice == lastVoice or newVoice == nil do
         newVoice=serviceFeed[math.random(1, #serviceFeed)]
      end
      tes3.removeSound{reference=npcId}
      tes3.say{
      volume=0.9,
      soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
      newVoice..".mp3", reference=npcId
      }
      lastVoice=newVoice
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
            while newVoice == lastVoice or newVoice == nil do
               newVoice=serviceFeed[math.random(1, #serviceFeed)]
            end
            tes3.removeSound{reference=npcId}

            if UISpells then
               tes3.playSound{sound="sprigganmagic", volume=0.6, pitch=1.5}
               debugLog("Opening spell menu sound played.")
            end

            tes3.playSound{sound="Menu Click", reference=npcId}
            tes3.say{
            volume=0.9,
            soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
            newVoice..".mp3", reference=npcId
            }
            lastVoice=newVoice
            debugLog("NPC says a spellmaker comment.")
         else
            serviceGreet(e)
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
            while newVoice == lastVoice or newVoice == nil do
               newVoice=serviceFeed[math.random(1, #serviceFeed)]
            end

            tes3.removeSound{reference=npcId}

            if UISpells then
               tes3.playSound{sound="sprigganmagic", volume=0.6, pitch=1.5}
               debugLog("Opening spell menu sound played.")
            end

            tes3.playSound{sound="Menu Click", reference=npcId}
            tes3.say{
            volume=0.9,
            soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
            newVoice..".mp3", reference=npcId
            }
            lastVoice=newVoice
            debugLog("NPC says a spell vendor comment.")
         else
            serviceGreet(e)
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
            while newVoice == lastVoice or newVoice == nil do
               newVoice=serviceFeed[math.random(1, #serviceFeed)]
            end
            tes3.removeSound{reference=npcId}
            tes3.playSound{sound="Menu Click", reference=npcId}
            tes3.say{
            volume=0.9,
            soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
            newVoice..".mp3", reference=npcId
            }
            lastVoice=newVoice
            debugLog("NPC says a repair comment.")
         else
            serviceGreet(e)
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
      while newVoice == lastVoice or newVoice == nil do
         newVoice=serviceFeed[math.random(1, #serviceFeed)]
      end
      tes3.removeSound{reference=npcId}
      tes3.say{
      volume=0.9,
      soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
      newVoice..".mp3", reference=npcId
      }
      lastVoice=newVoice
      debugLog("NPC says a travel comment.")
   end

end


local function trainingGreet(e)

   local closeButton=e.element:findChild(tes3ui.registerID("MenuServiceTraining_Okbutton"))
   closeButton:register("mouseDown", function()
      tes3.playSound{sound="Menu Click"}
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
      while newVoice == lastVoice or newVoice == nil do
         newVoice=serviceFeed[math.random(1, #serviceFeed)]
      end
      tes3.removeSound{reference=npcId}
      tes3.say{
      volume=0.9,
      soundPath="Vo\\"..raceLet.."\\"..sexLet.."\\"..
      newVoice..".mp3", reference=npcId
      }
      lastVoice=newVoice
      debugLog("NPC says a trainer comment.")
      trainingFlag=1
   end

end

debugLog("Service voices module initialised.")

event.register("uiActivated", spell_repairGreet, {filter="MenuDialog", priority=-10})

if serviceTravel then event.register("uiActivated", travelGreet, {filter="MenuServiceTravel", priority=-10}) end
if serviceBarter then event.register("uiActivated", serviceGreet, {filter="MenuBarter", priority=-10}) end
if serviceTraining then event.register("uiActivated", trainingGreet, {filter="MenuServiceTraining", priority=-10}) end
if serviceEnchantment then event.register("uiActivated", serviceGreet, {filter="MenuEnchantment", priority=-10}) end