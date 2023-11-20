Scriptname MantellaListenerScript extends ReferenceAlias

Spell property MantellaSpell auto
MantellaMCM Property mcm auto
int conversationHotkey
bool keyPressed = False

; Package Property MantellaListenAndFollow1 auto
; Package Property MantellaTestPackage auto

event OnInit()
    Game.GetPlayer().AddSpell(MantellaSpell)
    Debug.Notification("Mantella spell added. Please save and reload to activate the mod.")
endEvent


Event OnPlayerLoadGame()
    ;this will reset all data when player loads game so npc-to-npc conversations in .exe gets terminated.
    ResetAllData()
	;this will load the selected hotkey for the conversation press.
	conversationHotkey = MiscUtil.ReadFromFile("mantella/_mantella_conversation_hotkey.txt") as int
	RegisterForKey(conversationHotkey)
    RegisterForKey(36)
    RegisterForkey(37)
EndEvent


Event OnPlayerFastTravelEnd (float afTravelGameTimeHours)
    ;this will reset all data when player travels so npc-to-npc conversations in .exe gets terminated.
    ResetAllData()
EndEvent


Event OnKeyDown(int KeyCode)
    ;added !keyPressed because of entering this function multiple lines on one keystroke
	;this ensures the right key is pressed and only activated while not in menu mode
    If KeyCode == conversationHotkey && !utility.IsInMenuMode() && !keyPressed
        keyPressed = True
		String conversationEndedCheck = "false"
		String currentActor = MiscUtil.ReadFromFile("mantella/_mantella_current_actor.txt") as String
		if	currentActor == ""
				Actor targetRef = (Game.GetCurrentCrosshairRef() as actor)
				if targetRef
					MantellaSpell.cast(Game.GetPlayer(), targetRef)
					Utility.Wait(0.5)
				endIf
		elseif currentActor != ""
			String playerResponse = "False"
			playerResponse = MiscUtil.ReadFromFile("mantella/_mantella_text_input_enabled.txt") as String
			if playerResponse == "True"
				; Debug.Notification("Forcing Conversation Through Hotkey")
				UIExtensions.InitMenu("UITextEntryMenu")
				UIExtensions.OpenMenu("UITextEntryMenu")
				string result = UIExtensions.GetMenuResultString("UITextEntryMenu")
				if result != ""
					MiscUtil.WriteToFile("mantella/_mantella_text_input_enabled.txt", "False", append=False)
					MiscUtil.WriteToFile("mantella/_mantella_text_input.txt", result, append=false)
                    Utility.Wait(0.5) ; 
				endIf
			endIf
        endif
        Utility.Wait(0.5)
        keyPressed = False
    EndIf
    ; if KeyCode == 36 && !utility.IsInMenuMode()
    ;     Debug.Trace("Mantella: Adding package.")
    ;     Actor targetRef = (Game.GetCurrentCrosshairRef() as actor)
    ;     if targetRef
    ;         Debug.Trace("Adding package to " + targetRef.GetDisplayName())
    ;         ActorUtil.AddPackageOverride(targetRef, MantellaTestPackage)
    ;         Utility.Wait(0.5)
    ;         Debug.Trace("Mantella: Package added.")
    ;     endIf
    ; elseif KeyCode == 37 && !utility.IsInMenuMode()
    ;     Debug.Trace("Mantella: Removing package.")
    ;     Actor targetRef = (Game.GetCurrentCrosshairRef() as actor)
    ;     if targetRef
    ;         Debug.Trace("Mantella: Removing package from " + targetRef.GetDisplayName())
    ;         ActorUtil.RemovePackageOverride(targetRef, MantellaTestPackage)
    ;         Utility.Wait(0.5)
    ;         Debug.Trace("Mantella: Package removed.")
    ;     endIf
    ; endIf
endEvent


Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    string itemName = akBaseItem.GetName()
    string itemPickedUpMessage = "The player picked up " + itemName + ".\n"
    
    if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
        ;Debug.MessageBox(itemPickedUpMessage)
        MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", itemPickedUpMessage)
    endIf
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    string itemName = akBaseItem.GetName()
    string itemDroppedMessage = "The player dropped " + itemName + ".\n"
    
    if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
        ;Debug.MessageBox(itemDroppedMessage)
        MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", itemDroppedMessage)
    endIf
endEvent


Event OnSpellCast(Form akSpell)
    string spellCast = (akSpell as form).getname()
    if spellCast
        if spellCast == "Mantella"
            ; Do not save event if Mantella itself is cast
        else
            ;Debug.Notification("The player casted the spell "+ spellCast)
            MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "The player casted the spell " + spellCast + ".\n")
        endIf
    endIf
endEvent


String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    string aggressor = akAggressor.getdisplayname()
    string hitSource = akSource.getname()

    ; avoid writing events too often (continuous spells record very frequently)
    ; if the actor and weapon hasn't changed, only record the event every 5 hits
    if ((hitSource != lastHitSource) && (aggressor != lastAggressor)) || (timesHitSameAggressorSource > 5)
        lastHitSource = hitSource
        lastAggressor = aggressor
        timesHitSameAggressorSource = 0

        if (hitSource == "None") || (hitSource == "")
            ;Debug.MessageBox(aggressor + " punched the player.")
            MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", aggressor + " punched the player.\n")
        else
            ;Debug.MessageBox(aggressor + " hit the player with " + hitSource+".\n")
            MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", aggressor + " hit the player with " + hitSource+".\n")
        endIf
    else
        timesHitSameAggressorSource += 1
    endIf
EndEvent


Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    String currLoc = (akNewLoc as form).getname()
    if currLoc == ""
        currLoc = "Skyrim"
    endIf
    ;Debug.MessageBox("Current location is now " + currLoc)
    MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "Current location is now " + currLoc+".\n")
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    string itemEquipped = akBaseObject.getname()
    ;Debug.MessageBox("The player equipped " + itemEquipped)
    MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "The player equipped " + itemEquipped + ".\n")
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    string itemUnequipped = akBaseObject.getname()
    ;Debug.MessageBox("The player unequipped " + itemUnequipped)
    MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "The player unequipped " + itemUnequipped + ".\n")
endEvent


Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float afPower, bool abSunGazing)
    ;Debug.MessageBox("The player fired an arrow.")
    MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "The player fired an arrow.\n")
endEvent


Event OnSit(ObjectReference akFurniture)
    ;Debug.MessageBox("The player sat down.")
    MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "The player sat down.\n")
endEvent


Event OnGetUp(ObjectReference akFurniture)
    ;Debug.MessageBox("The player stood up.")
    MiscUtil.WriteToFile("mantella/_mantella_in_game_events.txt", "The player stood up.\n")
EndEvent


Event OnDying(Actor akKiller)
    MiscUtil.WriteToFile("mantella/_mantella_end_conversation.txt", "True",  append=false)
EndEvent

Function ResetAllData()
    Int i = 0
    While i < mcm.GET_MANTELLA_MAX_DIALOGUE_COUNT()
        ResetData(i)
        i += 1
    EndWhile
EndFunction

Function ResetData(Int i) 
    miscutil.WriteToFile("mantella\\_mantella_source_actor_id_" + i + ".txt", "", false, false)
    miscutil.WriteToFile("mantella\\_mantella_target_actor_id_" + i + ".txt", "", false, false)
    miscutil.WriteToFile("mantella\\_mantella_source_actor_" + i + ".txt", "", false, false)
    miscutil.WriteToFile("mantella\\_mantella_target_actor_" + i + ".txt", "", false, false)
    MiscUtil.WriteToFile("mantella\\_mantella_source_actor_sex_" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_target_actor_sex_" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_source_actor_race_" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_target_actor_race_" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_source_actor_voice_" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_target_actor_voice_" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_actor_relationship" + i + ".txt", "", append=false)
    MiscUtil.WriteToFile("mantella\\_mantella_end_conversation_" + i + ".txt", "True", append=false)
EndFunction