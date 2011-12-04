require("handler.sendmessagetoplayer")
require("questsystem.base")
module("questsystem.information_runewick_1.trigger27", package.seeall)

local QUEST_NUMBER = 621
local PRECONDITION_QUESTSTATE = 94
local POSTCONDITION_QUESTSTATE = 90

local NPC_TRIGGER_DE = "."
local NPC_TRIGGER_EN = "."
local NPC_REPLY_DE = "Ich sehe den Rauch. Daf�r gibt es noch einen Ring. Nun, n�chste Aufgabe: Wie alt k�nnte man die Frau die die Statue am Schrein der Elara sympolisiert sch�tzen?"
local NPC_REPLY_EN = "I see the smoke, fine. There you have another ring. Now, next task.  How old would you guess is the woman that is symoblized by this statue at Elara's shrine?"

function receiveText(type, text, PLAYER)
    if ADDITIONALCONDITIONS(PLAYER)
    and PLAYER:getType() == Character.player
    and questsystem.base.fulfilsPrecondition(PLAYER, QUEST_NUMBER, PRECONDITION_QUESTSTATE) then
        if PLAYER:getPlayerLanguage() == Player.german then
            NPC_TRIGGER=string.gsub(NPC_TRIGGER_DE,'([ ]+)',' .*');
        else
            NPC_TRIGGER=string.gsub(NPC_TRIGGER_EN,'([ ]+)',' .*');
        end

        foundTrig=false
        
        for word in string.gmatch(NPC_TRIGGER, "[^|]+") do 
            if string.find(text,word)~=nil then
                foundTrig=true
            end
        end

        if foundTrig then
      
            thisNPC:talk(Character.say, getNLS(PLAYER, NPC_REPLY_DE, NPC_REPLY_EN))
            
            HANDLER(PLAYER)
            
            questsystem.base.setPostcondition(PLAYER, QUEST_NUMBER, POSTCONDITION_QUESTSTATE)
        
            return true
        end
    end
    return false
end

function getNLS(player, textDe, textEn)
  if player:getPlayerLanguage() == Player.german then
    return textDe
  else
    return textEn
  end
end


function HANDLER(PLAYER)
    handler.sendmessagetoplayer.sendMessageToPlayer(PLAYER, "Geh zur�ck zu Elsil und teile ihr mit wie alt die Frau die die Statue symbolisiert wirkt.", "Go to Elesil and tell her the age of the woman, symbolised by the statue."):execute()
end

function ADDITIONALCONDITIONS(PLAYER)
return true
end