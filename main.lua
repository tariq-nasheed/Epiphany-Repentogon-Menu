local Mod = Epiphany

local CMenuPlayers = {
	[1] =  { name = "ISAAC",      cside = Mod.PlayerType.ISAAC },
	[2] =  { name = "MAGDALENE",  cside = Mod.PlayerType.MAGDALENE },
	[3] =  { name = "CAIN",       cside = Mod.PlayerType.CAIN },
	[4] =  { name = "JUDAS",      cside = Mod.PlayerType.JUDAS },
	[5] =  { name = "BLUEBABY",   cside = nil },
	[6] =  { name = "EVE",        cside = nil },
	[7] =  { name = "SAMSON",     cside = Mod.PlayerType.SAMSON },
	[8] =  { name = "AZAZEL",     cside = nil },
	[9] =  { name = "LAZARUS",    cside = nil },
	[10] = { name = "EDEN",       cside = Mod.PlayerType.EDEN },
	[11] = { name = "LOST",       cside = Mod.PlayerType.LOST },
	[12] = { name = "LILITH",     cside = nil },
	[13] = { name = "KEEPER",     cside = Mod.PlayerType.KEEPER },
	[14] = { name = "APOLLYON",   cside = nil },
	[15] = { name = "FORGOTTEN",  cside = nil },
	[16] = { name = "BETHANY",    cside = nil },
	[17] = { name = "JACOB",      cside = nil }
}

local CharacterMenuType = {
	MENU_ASIDE = 0,
	MENU_BSIDE = 1,
	MENU_CSIDE = 2
}


local CMenuState = {
	IsInMenu = false,
	MenuType = -1,
	NextMenuType = -1,
	CharID = -1,
	swapHeld = false
}


function Mod.SwapToCSide()
	Isaac.SetIcon("tarnished.ico")

	local anim = CharacterMenu.GetBigCharPageSprite():GetAnimation()
	CharacterMenu.GetCharacterPortraitSprite():Load("gfx/ui/main menu/CharacterPortraitsCSide.anm2", true)
	CharacterMenu.GetBigCharPageSprite():Load("gfx/ui/main menu/CharacterMenuCSide.anm2", true)
	CharacterMenu.GetBigCharPageSprite():Play(anim)
end


function Mod.SwapFromCSide()
	--CharacterMenu.SetSelectedCharacterID(CMenuState.CharID)
end


Mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
	if MenuManager.GetActiveMenu() == MainMenuType.CHARACTER then
		CMenuState.IsInMenu = true
		if CMenuState.MenuType == -1 then
			CMenuState.MenuType = CharacterMenu.GetSelectedCharacterMenu()
		end
		if CMenuState.NextMenuType == -1 then
			CMenuState.NextMenuType = CMenuState.MenuType
		end

		if CharacterMenu.GetBGSprite():GetAnimation() == "SwapOut" and CharacterMenu.GetBGSprite():GetFrame() == 0 then
			CMenuState.NextMenuType = CMenuState.MenuType + 1
			if CMenuState.NextMenuType == CharacterMenuType.MENU_CSIDE then
				CharacterMenu.SetSelectedCharacterMenu(0) -- so it gets set to 1 (tainted menu) during SwapIn animation
			end

			if CMenuState.NextMenuType > CharacterMenuType.MENU_CSIDE then
				CMenuState.NextMenuType = CharacterMenuType.MENU_ASIDE
			end
		end

		if CharacterMenu.GetBGSprite():GetAnimation() == "SwapIn" and CharacterMenu.GetBGSprite():GetFrame() == 0 then
			if CMenuState.MenuType == CharacterMenuType.MENU_CSIDE then
				Mod.SwapFromCSide()
			end
			if CMenuState.NextMenuType == CharacterMenuType.MENU_CSIDE then
				Mod.SwapToCSide()
			end
			CMenuState.MenuType = CMenuState.NextMenuType
		end

		CMenuState.CharID = CharacterMenu.GetSelectedCharacterID()
		CMenuState.swapHeld = Input.IsButtonPressed(Keyboard.KEY_E, 0)
	end
end)

Mod:AddCallback(ModCallbacks.MC_PRE_RENDER, function()
	if Isaac.GetPlayer() then CMenuState.IsInMenu = false end
	if CMenuState.IsInMenu == true and MenuManager.GetActiveMenu() == MainMenuType.CHARACTER and CMenuState.MenuType == CharacterMenuType.MENU_CSIDE then
		local char_id = CharacterMenu.GetSelectedCharacterID()
		local custom_char_status = nil
		if CharacterMenu.GetSelectedCharacterID() > 17 then
			custom_char_status = CharacterMenu.GetIsCharacterUnlocked()
		end
		for i = 1, 17, 1 do
			local info = CMenuPlayers[i]
			if info then
				CharacterMenu.SetSelectedCharacterID(i)
				if Mod:GetAchievement("CHARACTER_" .. info.name) == 0 then
					--print(string.format("UNLOCKED: TARNISHED %s", info.name))
					CharacterMenu.SetIsCharacterUnlocked(false)
				else
					--print(string.format("LOCKED: TARNISHED %s", info.name))
					CharacterMenu.SetIsCharacterUnlocked(true)
				end
			else
				print("character not supported")
			end
		end
		CharacterMenu.SetSelectedCharacterID(char_id)
		if custom_char_status then CharacterMenu.SetIsCharacterUnlocked(custom_char_status) end
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
	if not continued and CMenuState.MenuType == CharacterMenuType.MENU_CSIDE then
		local info = CMenuPlayers[CMenuState.CharID]
		if info then
			print(CMenuState.CharID)
			print(info.cside)
			local player = Isaac.GetPlayer()
			Mod:LoadMenuCharacter(player, info.cside)
		end
	end
end)