-- Variables
local A2DMailDatabase = {};

-- Frames
local A2DMailFrame = CreateFrame("FRAME", "FooAddonFrame");
A2DMailFrame:SetFrameStrata("BACKGROUND")
A2DMailFrame:SetWidth(128) -- Set these to whatever height/width is needed 
A2DMailFrame:SetHeight(64) -- for your Texture
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
A2DMailFrameTextPlayerName:SetHeight(1) 
A2DMailFrameTextPlayerName:SetPoint("TOP", 0, -10)
A2DMailFrameTextPlayerName.text = A2DMailFrameTextPlayerName:CreateFontString(nil,"ARTWORK") 
A2DMailFrameTextPlayerName.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
A2DMailFrameTextPlayerName.text:SetPoint("CENTER",0,0)
A2DMailFrameTextPlayerName.text:SetText("Debug1")

local A2DMailFrameTextGold = CreateFrame("Frame",nil,A2DMailFrame)
A2DMailFrameTextGold:SetWidth(1) 
A2DMailFrameTextGold:SetHeight(1) 
A2DMailFrameTextGold:SetPoint("CENTER", 0, 5)
A2DMailFrameTextGold.text = A2DMailFrameTextGold:CreateFontString(nil,"ARTWORK") 
A2DMailFrameTextGold.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
A2DMailFrameTextGold.text:SetPoint("CENTER",0,0)
A2DMailFrameTextGold.text:SetText("Debug1")

local function A2DHandleNextMailClick(self, button, down)
    local name = A2DMailFrameTextPlayerName.text:GetText();
    local sum = A2DMailFrameTextGold.text:GetText();

    A2D_SendMail(name, sum, "A2D - Mailing");

    A2D_PopulateNextMailRecipient();
end

local A2DMailFrameSendNextButton = CreateFrame("Button", "A2DMailFrameSendNextButton", A2DMailFrame, "OptionsButtonTemplate");
A2DMailFrameSendNextButton:SetPoint("BOTTOM", 0, 5)
A2DMailFrameSendNextButton:SetText("Send")
A2DMailFrameSendNextButton:SetScript("OnClick", A2DHandleNextMailClick)

A2DMailFrame:RegisterEvent("MAIL_CLOSED");
A2DMailFrame:RegisterEvent("MAIL_SHOW");
local function A2DEventHandler(self, event, ...)
    if event == "MAIL_SHOW" then
        if (#A2DMailDatabase > 0) then 
            A2DMailFrame:Show()
        end
    elseif event == "MAIL_CLOSED" then
        A2DMailFrame:Hide()
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

function A2D_SendMail(name, amount, subject)
    local silver = amount * 100;
    local copper = silver * 100;

    SetSendMailMoney(copper);
    SendMail(name, subject, "debug");

    DEFAULT_CHAT_FRAME:AddMessage("Sent " .. amount .. " gold to " .. name .. ".", 1, 1, 0)
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

function A2D_debug()
    if #A2DMailDatabase == 0 then
        print ('Empty db');
    else
        for i = 1, #A2DMailDatabase do
            local player = A2DMailDatabase [i];
            local eq = string.find(player, '=');
            local charName = player:sub(0, eq-1);
            local sum = player:sub(eq+1, #player);

            print('charName: ' .. charName);
            print('sum: ' .. sum);
        end
    end
end

function A2D_PopulateNextMailRecipient()
    if(#A2DMailDatabase > 0) then
        local player = table.remove(A2DMailDatabase, #A2DMailDatabase);
        local eq = string.find(player, '=');
        local charName = player:sub(0, eq-1);
        local sum = player:sub(eq+1, #player);
    
        A2DMailFrameTextPlayerName.text:SetText(charName)
        A2DMailFrameTextGold.text:SetText(sum)
    else
        A2DMailFrame:Hide()
    end
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
            A2DMailDatabase = {};
            local data = self.editBox:GetText();
            for player in data:gmatch("([^;]+)") do
                table.insert(A2DMailDatabase, player);
            end
            print ('Successfully imported ' .. #A2DMailDatabase .. ' characters into database');
            A2D_PopulateNextMailRecipient();
        end
    end,
    EditBoxOnEnterPressed = function(self)
        A2DMailDatabase = {};
        local data = self:GetText();
        for player in data:gmatch("([^;]+)") do
            table.insert(A2DMailDatabase, player);
        end
        print ('Successfully imported ' .. #A2DMailDatabase .. ' characters into database');
        A2D_PopulateNextMailRecipient();

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