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

function WipeLastMessages()
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
        if msg == "raidlist" then 
            StaticPopup_Show ("A2D_RaidgroupNames")
        elseif msg == "guildchatfix" then 
            WipeLastMessages()
        else
            print("Unknown command: " .. msg)
            A2DSlashCmdListHelp()
        end
    end
end

function A2DSlashCmdListHelp()
    print("The following commands are available:")
    print("raidlist")
    print("guildchatfix")
end