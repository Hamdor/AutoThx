local f = CreateFrame("Frame", nil, UIParent)
local events = {}

local self_name = ""
local achievement_received = false
local gz_received = false
local enabled = true -- TODO: Make save var

local gz_msgs = {"gz", "gratz", "gratulation"}

---
function print_thanks()
  if enabled ~= true then return end
  if gz_received then
    SendChatMessage("thx", "GUILD")
  end
  gz_received = true
  achievement_earned = false
end

---
function print_gz()
  if enabled ~= true then return end
  idx = math.random(1, #gz_msgs)
  SendChatMessage(gz_msgs[idx], "GUILD")
  achievement_received = false
end

--- Handler for ADDON_LOADED
function events:ADDON_LOADED(name)
  if name ~= "AutoThx" then return end
  local name, realm = UnitName("player"), GetRealmName()
  self_name = name.."-"..realm
end

--- Handler for CHAT_MSG_GUILD_ACHIEVEMENT
function events:CHAT_MSG_GUILD_ACHIEVEMENT(msg_body, name, chat_line_id,
                                           sender_guid)
  -- Filter multiple achivements, we just gratz once. ;-)
  if achievement_received == true then return end
  if name ~= self_name then
    achievement_received = true
    local dur = math.random(7, 20)
    C_Timer.After(dur, print_gz)
  else
    -- Nop
  end
end

--- Handler for ACHIEVEMENT_EARNED
--- @param id id of the gained achievement
function events:ACHIEVEMENT_EARNED(id)
  if achievement_earned == true then return end
  achievement_earned = true
  gz_received = false
  local dur = math.random(25, 35)
  C_Timer.After(dur, print_thanks)
end

--- Handler for CHAT_MSG_GUILD
function events:CHAT_MSG_GUILD(msg, author, msg_lang, chat_line_id, sender_guid)
  if author == self_name then return end
  words = {}
  for word in msg:gmatch("%w+") do table.insert(words, word) end
  for _, word in pairs(words) do
    if word == "gz" or word == "gratz" or word == "gratulation" or
       word == "ckwunsch" or word == "ckwunsch!" or word == "gw" or
       word == "GZ" or word == "gratuliere" then
      gz_received = true
    end
  end
end

f:SetScript("OnEvent", function(self, event, ...)
  events[event](self, ...)
end);

for k, _ in pairs(events) do
  f:RegisterEvent(k)
end

--- Handle console commands
local function CommandHandler(msg, editbox)
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
  if cmd == "enable" then
    enabled = true
    print("AutoThx enabled.")
  elseif cmd == "disable" then
    enabled = false
    print("AutoThx disabled.")
  elseif cmd == "state" then
    print("AutoThx is "..(enabled == true and "enabled." or "disabled."))
  else
    print("Syntax: /autothx (enable|disable|state)");
  end
end
SLASH_AUTOTHX1 = '/autothx'
SlashCmdList["AUTOTHX"] = CommandHandler
