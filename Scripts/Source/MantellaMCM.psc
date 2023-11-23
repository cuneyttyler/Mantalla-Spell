ScriptName MantellaMCM extends SKI_ConfigBase

Int NPC_HeaderOptionId
Int NPC_MaxDialogueCountOptionId
Int NPC_EngageFrequencyOptionId
Int NPC_MaxDialogueTimeoutOptionId
Int NPC_RadiusOptionId
Int NPC_DialogueDistanceOptionId
Int FollowPlayerOptionId

GlobalVariable Property MANTELLA_MAX_DIALOGUE_COUNT auto
GlobalVariable Property MANTELLA_MAX_DIALOGUE_TIMEOUT auto
GlobalVariable Property MANTELLA_MAX_RADIUS auto
GlobalVariable Property MANTELLA_MAX_DISTANCE auto
GlobalVariable Property MANTELLA_FOLLOW_PLAYER auto

GlobalVariable Property  MANTELLA_SELECTED_FREQUENCY auto

String[] frequencyList
Int currFrequency = 1

Bool followPlayerState

Event OnConfigInit()
    Debug.Trace("Mantella: MCM Config Initializing.")

    ModName = "Mantella"
    Pages = new String[1]
    Pages[0] = "Settings"

    MANTELLA_MAX_DIALOGUE_COUNT.SetValueInt(10)
    MANTELLA_MAX_DIALOGUE_TIMEOUT.SetValueInt(300)
    MANTELLA_MAX_RADIUS.SetValue(20.0)
    MANTELLA_MAX_DISTANCE.SetValue(2)

    frequencyList = New String[3]
    frequencyList[0] = "Low"
    frequencyList[1] = "Medium"
    frequencyList[2] = "High"

    currFrequency = 1

    MANTELLA_SELECTED_FREQUENCY.SetValueInt(1)

    If MANTELLA_FOLLOW_PLAYER.GetValueInt() == 1
        followPlayerState = True
    Else
        followPlayerState = False
    EndIf
EndEvent

Event OnPageReset(String page)
    If page == ""
        LoadCustomContent("Mantella/Logo.dds")
    EndIf
    If page == "Settings"
        UnloadCustomContent()
        NPC_HeaderOptionid = AddHeaderOption("Npc Dialogue Settings")
        NPC_MaxDialogueCountOptionId = AddSliderOption("Max Dialogue Count", MANTELLA_MAX_DIALOGUE_COUNT.GetValueInt())
        NPC_EngageFrequencyOptionId = AddMenuOption("Engage Frequency", frequencyList[currFrequency])
        NPC_MaxDialogueTimeoutOptionId = AddSliderOption("Max Dialogue Timeout", MANTELLA_MAX_DIALOGUE_TIMEOUT.GetValueInt())
        NPC_RadiusOptionId = AddSliderOption("Player NPC Scan Radius", MANTELLA_MAX_RADIUS.GetValue())
        NPC_DialogueDistanceOptionId = AddSliderOption("Max NPC Dialogue Distance", MANTELLA_MAX_DISTANCE.GetValue())
        FollowPlayerOptionId = AddToggleOption("Follow Player", followPlayerState)
    EndIf
EndEvent

Event OnOptionHighlight(Int optionId)
    If optionId == NPC_HeaderOptionId
        SetInfoText("Options for dialogue between NPCs")
    EndIf
    If optionId == NPC_EngageFrequencyOptionId
        SetInfoText("NPC dialogue engage frequency")
    EndIf
    If optionId == NPC_MaxDialogueTimeoutOptionId
        SetInfoText("The max. number of seconds for a dialogue to end")
    EndIf
    If optionId == NPC_MaxDialogueCountOptionId
        SetInfoText("The max. number of concurrent dialogues that can happen between npcs. Set it to 0 for turning NPC conversations off.")
    EndIf
    If optionId == NPC_RadiusOptionId
        SetInfoText("The radius which determines the distance of search area to find NPCs to talk to each other")
    EndIf
    If optionId == NPC_DialogueDistanceOptionId
        SetInfoText("The max distance between NPCs to initiate a dialogue. This value is multipled by 3 when there are less then 3 NPCs in the environment")
    EndIf
    If optionId == FollowPlayerOptionId
        SetInfoText("NPCs follow player during conversation if checked.")
    EndIf
EndEvent

Event OnOptionSliderOpen(Int optionId)
    If  optionId == NPC_MaxDialogueCountOptionId
        SetSliderDialogStartValue(MANTELLA_MAX_DIALOGUE_COUNT.GetValueInt())
        SetSliderDialogDefaultValue(10)
        SetSliderDialogRange(0, 10)
        SetSliderOptionValue(optionId, MANTELLA_MAX_DIALOGUE_COUNT.GetValueInt())
    EndIf
    If optionId == NPC_MaxDialogueTimeoutOptionId
        SetSliderDialogStartValue(MANTELLA_MAX_DIALOGUE_TIMEOUT.GetValueInt())
        SetSliderDialogDefaultValue(300)
        SetSliderDialogRange(0, 600)
        SetSliderOptionValue(optionId, MANTELLA_MAX_DIALOGUE_TIMEOUT.GetValueInt())
    EndIf
    If optionId == NPC_RadiusOptionId
        SetSliderDialogStartValue(MANTELLA_MAX_RADIUS.GetValue())
        SetSliderDialogDefaultValue(20)
        SetSliderDialogRange(0, 50.0)
        SetSliderOptionValue(optionId, MANTELLA_MAX_RADIUS.GetValue())
    EndIf
    If optionId == NPC_DialogueDistanceOptionId
        SetSliderDialogStartValue(MANTELLA_MAX_DISTANCE.GetValue())
        SetSliderDialogDefaultValue(2)
        SetSliderDialogRange(0, 10.0)
        SetSliderOptionValue(optionId, MANTELLA_MAX_DISTANCE.GetValue())
    EndIf
EndEvent

Event OnOptionSliderAccept(Int optionId, Float value)
    If  optionId == NPC_MaxDialogueCountOptionId
        SetSliderOptionValue(optionId, value)
        MANTELLA_MAX_DIALOGUE_COUNT.SetValueInt(value as Int)
    EndIf
    If optionId == NPC_MaxDialogueTimeoutOptionId
        SetSliderOptionValue(optionId, value)
        MANTELLA_MAX_DIALOGUE_TIMEOUT.SetValueInt(value as Int)
    EndIf
    If optionId == NPC_RadiusOptionId
        SetSliderOptionValue(optionId, value)
        MANTELLA_MAX_RADIUS.SetValue(value)
    EndIf
    If optionId == NPC_DialogueDistanceOptionId
        SetSliderOptionValue(optionId, value)
        MANTELLA_MAX_DISTANCE.SetValue(value)
    EndIf

    SetSliderOptionValue(optionId, value)
EndEvent

Event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}

	If (a_option == NPC_EngageFrequencyOptionId)
		SetMenuDialogStartIndex(currFrequency)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(frequencyList)
    EndIf
EndEvent

Event OnOptionMenuAccept(int a_option, int a_index)
	{Called when the user accepts a new menu entry}

	If (a_option == NPC_EngageFrequencyOptionId)
		currFrequency = a_index
		SetMenuOptionValue(a_option, frequencyList[currFrequency])
        MANTELLA_SELECTED_FREQUENCY.SetValueInt(currFrequency)
    EndIf
EndEvent

Event OnOptionSelect(int optionId)
    If optionId == FollowPlayerOptionId
        followPlayerState = !followPlayerState
        SetToggleOptionValue(optionid, followPlayerState)
    EndIf
EndEvent

Int Function GET_MANTELLA_MAX_DIALOGUE_COUNT()
    Return MANTELLA_MAX_DIALOGUE_COUNT.GetValueInt()
EndFunction

Int Function GET_MANTELLA_MAX_DIALOGUE_TIMEOUT()
    Return MANTELLA_MAX_DIALOGUE_TIMEOUT.GetValueInt()
EndFunction

Float Function GET_MANTELLA_MAX_RADIUS()
    Return MANTELLA_MAX_RADIUS.GetValue()
EndFunction

Float Function GET_MANTELLA_MAX_DISTANCE()
    Return MANTELLA_MAX_DISTANCE.GetValue()
EndFunction

Int Function GET_MANTELLA_SELECTED_FREQUENCY()
    Return MANTELLA_SELECTED_FREQUENCY.GetValueInt()
EndFunction

Bool Function GET_MANTELLA_FOLLOW_PLAYER()
    Return followPlayerState
EndFunction