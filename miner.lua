-- Computercraft script: 

-- Mekanism Digital Miner Automator version 2.1 FIXED
-- ChatBox + Prozent-Updates funktionieren jetzt!
-- Original by MartiNJ409 - https://github.com/martinjanas
 
-- User Settings Area --
Settings = {}
Settings.MAX_CHUNKS = 16 -- The amount of chunks this script will run. (Default 16)
Settings.SEND_TO_CHAT = true -- Set this to false if you don't wish for the chatbox to send serverwide messages about the mining status.

Blocks = {}
Blocks.BLOCK_MINER = "mekanism:digital_miner"
Blocks.BLOCK_ENERGY = "mekanism:quantum_entangloporter" -- Edit this to match your desired block.
Blocks.BLOCK_STORAGE = "mekanism:quantum_entangloporter" -- Edit this to match your desired block.
Blocks.BLOCK_CHUNKLOADER = "chickenchunks:chunk_loader" -- Edit this to match your desired block.
Blocks.BLOCK_CHATBOX = "advancedperipherals:chat_box" -- Edit this only if you are porting to newer/older versions.
-- User Settings Area --

-- Dont touch this if you don't know what you are doing:
GlobalVars = {}
GlobalVars.m_pMiner = nil
GlobalVars.m_pChatBox = nil
GlobalVars.m_bHasChunkLoader = false
GlobalVars.m_bIsChunkyTurtle = false
GlobalVars.m_bHasChatBox = false

function main(i)
   require "utils"

   GlobalVars.m_bIsChunkyTurtle = utils_is_chunky_turtle()

   utils_place_blocks(Blocks, GlobalVars)

   os.sleep(0.15)

   if GlobalVars.m_pMiner then
      GlobalVars.m_pMiner.start()

      local to_mine_cached = GlobalVars.m_pMiner.getToMine()
      
      -- FIXED: Tracking-Variablen damit Nachrichten nur einmal gesendet werden
      local sent_20 = false
      local sent_50 = false
      local sent_70 = false

      while GlobalVars.m_pMiner.isRunning() do
         local to_mine = GlobalVars.m_pMiner.getToMine()
         local seconds = (to_mine * 0.5)

         if GlobalVars.m_pChatBox and Settings.SEND_TO_CHAT then
            -- FIXED: Berechne abgebaute Prozente (nicht verbleibende!)
            local mined = to_mine_cached - to_mine
            local percentage = (mined / to_mine_cached) * 100
            percentage = math.floor(percentage)

            -- FIXED: Sende jede Nachricht nur einmal wenn Prozentsatz erreicht
            if percentage >= 20 and not sent_20 then
               local text = string.format("20%% of Blocks Mined (%d/%d)", mined, to_mine_cached)
               GlobalVars.m_pChatBox.sendMessage(text, "Miner")
               sent_20 = true
               os.sleep(1)
            end

            if percentage >= 50 and not sent_50 then
               local text = string.format("50%% of Blocks Mined (%d/%d)", mined, to_mine_cached)
               GlobalVars.m_pChatBox.sendMessage(text, "Miner")
               sent_50 = true
               os.sleep(1)
            end

            if percentage >= 70 and not sent_70 then
               local text = string.format("70%% of Blocks Mined (%d/%d)", mined, to_mine_cached)
               GlobalVars.m_pChatBox.sendMessage(text, "Miner")
               sent_70 = true
               os.sleep(1)
            end
         end

         -- FIXED: Korrekter Modulo-Check (== 0 fehlte!)
         if to_mine % 5 == 0 then
            local text = string.format("To mine: %d, ETA: %s", to_mine, utils_get_time(seconds))
            print(text)
         end

         if (to_mine == 0) then
            if GlobalVars.m_pChatBox and Settings.SEND_TO_CHAT then
               local text = string.format("Done (%d/%d) rounds", i, Settings.MAX_CHUNKS)
               GlobalVars.m_pChatBox.sendMessage(text, "Miner")
               os.sleep(1)
            end
                
            if i == Settings.MAX_CHUNKS and GlobalVars.m_pChatBox and Settings.SEND_TO_CHAT then
               local text = string.format("Pick me up! I am finished!")
               GlobalVars.m_pChatBox.sendMessage(text, "Miner")
               os.sleep(1)
            end

            utils_destroy_blocks(GlobalVars)

            os.sleep(2)

            utils_go_one_chunk()
         end

         os.sleep(0.5)
      end
   end
end

function setup()
   if fs.exists("utils.lua") then
      fs.delete("utils.lua")
      sleep(1)
   end

   -- FIXED: Nutze deine GitHub-Version mit ChatBox-Fix
   shell.run("wget https://raw.githubusercontent.com/Astrowal/DigitalMinerAutomatization/refs/heads/main/utils.lua")
end

done = false

for i = 1, Settings.MAX_CHUNKS do
   if not done then
      setup()
      done = true
   end

   GlobalVars.m_bIsChunkyTurtle = false
   GlobalVars.m_bHasChunkLoader = false
   GlobalVars.m_bHasChatBox = false
    
   main(i)
end

