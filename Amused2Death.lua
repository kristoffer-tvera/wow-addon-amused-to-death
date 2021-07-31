-- Variables
local A2DMailDatabase = {};
local hasPopulatedInitialRecipientInBatch = false;
local A2DMailFrameTextHeight = 12;
local A2DMailFrameHeight = 70;

-- Frames
local A2DMailFrame = CreateFrame("FRAME", "FooAddonFrame");
A2DMailFrame:SetFrameStrata("BACKGROUND")
A2DMailFrame:SetWidth(180) -- Set these to whatever height/width is needed 
A2DMailFrame:SetHeight(A2DMailFrameHeight) -- for your Texture
A2DMailFrame:SetMovable(true)
A2DMailFrame:EnableMouse(true)
A2DMailFrame:RegisterForDrag("LeftButton")
A2DMailFrame:SetScript("OnDragStart", A2DMailFrame.StartMoving)
A2DMailFrame:SetScript("OnDragStop", A2DMailFrame.StopMovingOrSizing)

local A2DMailFrameTexture = A2DMailFrame:CreateTexture("ARTWORK")
A2DMailFrameTexture:SetAllPoints(A2DMailFrame)
A2DMailFrameTexture:SetColorTexture(0.5, 0, 0.5, 0.75)
A2DMailFrame.texture = A2DMailFrameTexture
A2DMailFrame:SetPoint("CENTER",0,0)
A2DMailFrame:Hide()

local A2DMailFrameTextPlayerName = CreateFrame("Frame",nil,A2DMailFrame)
A2DMailFrameTextPlayerName:SetWidth(1) 
A2DMailFrameTextPlayerName:SetHeight(14) 
A2DMailFrameTextPlayerName:SetPoint("TOPLEFT", 0, 0)
A2DMailFrameTextPlayerName.text = A2DMailFrameTextPlayerName:CreateFontString(nil,"ARTWORK") 
A2DMailFrameTextPlayerName.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
A2DMailFrameTextPlayerName.text:SetPoint("TOPLEFT", 5, -5)
A2DMailFrameTextPlayerName.text:SetText("Debug1")

local A2DMailFrameTextGold = CreateFrame("Frame",nil,A2DMailFrame)
A2DMailFrameTextGold:SetWidth(1) 
A2DMailFrameTextGold:SetHeight(A2DMailFrameTextHeight) 
A2DMailFrameTextGold:SetPoint("TOPRIGHT", 0, 0)
A2DMailFrameTextGold.text = A2DMailFrameTextGold:CreateFontString(nil,"ARTWORK") 
A2DMailFrameTextGold.text:SetFont("Fonts\\ARIALN.ttf", A2DMailFrameTextHeight, "OUTLINE")
A2DMailFrameTextGold.text:SetPoint("TOPRIGHT",-5,-5)
A2DMailFrameTextGold.text:SetText("Debug1")

local A2DMailFrameSendNextButton = CreateFrame("Button", "A2DMailFrameSendNextButton", A2DMailFrame, "OptionsButtonTemplate");
A2DMailFrameSendNextButton:SetPoint("TOP", 0, -25)
A2DMailFrameSendNextButton:SetText("Send")

local A2DMailFrameTextNext = CreateFrame("Frame",nil,A2DMailFrame)
A2DMailFrameTextNext:SetWidth(1) 
A2DMailFrameTextNext:SetHeight(A2DMailFrameTextHeight) 
A2DMailFrameTextNext:SetPoint("TOP", 0, -60)
A2DMailFrameTextNext.text = A2DMailFrameTextNext:CreateFontString(nil,"ARTWORK") 
A2DMailFrameTextNext.text:SetFont("Fonts\\ARIALN.ttf", A2DMailFrameTextHeight, "OUTLINE")
A2DMailFrameTextNext.text:SetPoint("CENTER", 0, 0)
A2DMailFrameTextNext.text:SetText("Debug1\nDebug2")

local function A2D_SendMail(name, amount, subject)
    local silver = amount * 100;
    local copper = silver * 100;

    SetSendMailMoney(copper);
    local mailMessages = {"xQcL", "Yukela was here", "If we kill it on this pull, Dumble buys us a planet.", "For services rendred in honor of the queen", "Bribe, dont tell anyone", "Hush-money", "Untraceable money from illicit activity", "Vi Von", "Morgoth stood in fire", "I'm sending YOU more gold than all the others, dont tell anyone", "I some times like awake at night and wonder how it all started."};
    local mailMessage = mailMessages[ math.random( #mailMessages ) ]

    SendMail(name, subject, mailMessage);

    DEFAULT_CHAT_FRAME:AddMessage("Sent " .. amount .. " gold to " .. name .. ".", 1, 1, 0)
end

local A2D_MailInProgress = false;
local function A2DHandleNextMailClick(self, button, down)
    local name = A2DMailFrameTextPlayerName.text:GetText();
    local sum = A2DMailFrameTextGold.text:GetText();

    A2D_SendMail(name, sum, "A2D - Mailing");
    A2DMailFrameSendNextButton:SetEnabled(false);
    A2D_MailInProgress = true;
end
A2DMailFrameSendNextButton:SetScript("OnClick", A2DHandleNextMailClick)

A2DMailFrame:RegisterEvent("MAIL_CLOSED");
A2DMailFrame:RegisterEvent("MAIL_SHOW");
A2DMailFrame:RegisterEvent("MAIL_SEND_SUCCESS");
A2DMailFrame:RegisterEvent("MAIL_FAILED");
local function A2DEventHandler(self, event, ...)
    if event == "MAIL_SHOW" then
        if (#A2DMailDatabase > 0) then 
            if not hasPopulatedInitialRecipientInBatch then
                A2D_PopulateNextMailRecipient()
            end

            A2DMailFrame:Show()
        end
    elseif event == "MAIL_CLOSED" then
        A2DMailFrame:Hide()
    elseif event == "MAIL_SEND_SUCCESS" and A2D_MailInProgress then
        A2D_PopulateNextMailRecipient();
        A2DMailFrameSendNextButton:SetEnabled(true);
        A2D_MailInProgress = false;
    elseif event == "MAIL_FAILED" and A2D_MailInProgress then
        A2DMailFrameSendNextButton:SetEnabled(true);
        A2D_MailInProgress = false;
    end
end
A2DMailFrame:SetScript("OnEvent", A2DEventHandler);

-- Functions
function A2D_WipeLastMessages()
    local guildClubId = C_Club.GetGuildClubId();
    local lastMessageId = C_Club.GetMessageRanges(guildClubId, "1")[1].newestMessageId;

	local lastMessages = C_Club.GetMessagesBefore(guildClubId, "1", lastMessageId, 50);
    for key,message in pairs(lastMessages) do
        if not message.destroyed then
            pcall (C_Club.DestroyMessage, guildClubId, "1", message.messageId);
        end
    end
end

SLASH_A2D1 = "/a2d"
function SlashCmdList.A2D(msg, editbox)
	if msg == nil or msg == '' then
        A2DSlashCmdListHelp()
    else
        msg = string.lower(msg)

        if msg == "raidlist" then 
            StaticPopup_Show ("A2D_RaidgroupNames")
        elseif msg == "guildchatfix" then 
            A2D_WipeLastMessages()
        elseif msg == "mail" then 
            StaticPopup_Show ("A2D_MailDataImport")
        elseif msg == "reset" then 
            A2DMailDatabase = {};
            print('Successfully reset mail database');
        else
            print("Unknown command: " .. msg)
            A2DSlashCmdListHelp()
        end
    end
end

function A2DSlashCmdListHelp()
    print("The following commands are available:")
    print("raidlist -- Brings up the list of everyone in the raid")
    print("mail -- Import data to mail-database")
    print("reset -- Resets the mail-database")
    print("guildchatfix  -- Wipes last 50 msg from gchat")
end

-- function A2D_debug()
--     if #A2DMailDatabase == 0 then
--         print ('Empty db');
--     else
--         for i, player in ipairs(A2DMailDatabase) do
--             print (player)
--         end
--     end
-- end

function A2D_PopulateNextMailRecipient()
    hasPopulatedInitialRecipientInBatch = true;
    if(#A2DMailDatabase > 0) then
        local player = table.remove(A2DMailDatabase, #A2DMailDatabase);
        local eq = string.find(player, '=');
        local charName = player:sub(0, eq-1);
        local sum = player:sub(eq+1, #player);
    
        A2DMailFrameTextPlayerName.text:SetText(charName)
        A2DMailFrameTextGold.text:SetText(sum)

        local heightIndex = 1;

        if (#A2DMailDatabase > 0) then
            local next = 'Next up:';

            for i = #A2DMailDatabase, 1, -1 do
                player = A2DMailDatabase[i]
                local eq = string.find(player, '=');
                local charName = player:sub(0, eq-1);
                local sum = player:sub(eq+1, #player);

                next = next .. '\n' .. charName .. ': ' .. sum .. 'g';
                heightIndex = heightIndex + 1;
            end

            A2DMailFrameTextNext.text:SetText(next);
        else 
            A2DMailFrameTextNext.text:SetText('Final mail');
        end

        local frameHeight = A2DMailFrameTextHeight * heightIndex;
        A2DMailFrameTextNext:SetHeight(frameHeight);
        local totalFrameHeight = A2DMailFrameHeight + frameHeight;
        A2DMailFrame:SetHeight(totalFrameHeight);
        
    else
        hasPopulatedInitialRecipientInBatch = false;
        A2DMailFrame:Hide()
    end
end

local function GetSumForPlayer(character)
    for i = 1, #A2DMailDatabase do
        local player = A2DMailDatabase [i];
        local eq = string.find(player, '=');
        local charName = player:sub(0, eq-1);
        if character == charName then
            return tonumber(player:sub(eq+1, #player)), i
        end
    end

    return 0, -1;
end

local function AppendDataToDb(data)
    --A2DMailDatabase = {};
    for player in data:gmatch("([^;]+)") do

        local eq = string.find(player, '=');
        local charName = player:sub(0, eq-1);
        local sum = tonumber(player:sub(eq+1, #player));
        local oldSum, index = GetSumForPlayer(charName);

        if oldSum == 0 then
            table.insert(A2DMailDatabase, player);
        else
            sum = sum + oldSum;
            local result = charName .. '=' .. sum;
            A2DMailDatabase[index] = result;
        end
    end
    print ('Successfully imported ' .. #A2DMailDatabase .. ' characters into database');
    -- A2D_PopulateNextMailRecipient();
end

-- Popup Dialogs
StaticPopupDialogs["A2D_RaidgroupNames"] = {
    text = "Current raid team",
    button1 = OKAY,
    OnShow = function (self, data)
        if(self.editBox) then

            local names = {}

            if IsInRaid() then
                for i=1,GetNumGroupMembers() do
					if(UnitExists('raid'..i)) then
						tinsert(names,(UnitName('raid'..i)))
					end
                end
            elseif IsInGroup() then
                for i=1,GetNumGroupMembers() do
					if(UnitExists('party'..i)) then
						tinsert(names,(UnitName('party'..i)))
					end
                end
                tinsert(names, (UnitName("player")))
            else
                tinsert(names, (UnitName("player")))
            end

            sort(names)

            if table.getn(names) == 0 then
                tinsert(names, (UnitName("player")))
            end

            self.editBox:SetText(table.concat(names, ","))
        end
    end,
    EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
    end,
    EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
	end,
    hasEditBox = 1,
    hasWideEditBox = 1,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

StaticPopupDialogs["A2D_MailDataImport"] = {
    text = "Paste website payment data",
    button1 = OKAY,
    OnShow = function (self, data)
    end,
    OnAccept = function(self)
        if(self.editBox) then
            local data = self.editBox:GetText();
            AppendDataToDb(data);
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local data = self:GetText();
        AppendDataToDb(data);
		self:GetParent():Hide();
		ClearCursor();
    end,
    EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
	end,
    hasEditBox = 1,
    hasWideEditBox = 1,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}
