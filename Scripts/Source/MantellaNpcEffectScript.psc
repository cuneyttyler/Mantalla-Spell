Scriptname MantellaNpcEffectScript extends activemagiceffect  

Topic property MantellaNpcSourceDialogueLine1 auto
Topic property MantellaNpcTargetDialogueLine1 auto
Topic property MantellaNpcSourceDialogueLine2 auto
Topic property MantellaNpcTargetDialogueLine2 auto
Topic property MantellaNpcSourceDialogueLine3 auto
Topic property MantellaNpcTargetDialogueLine3 auto
Topic property MantellaNpcSourceDialogueLine4 auto
Topic property MantellaNpcTargetDialogueLine4 auto
Topic property MantellaNpcSourceDialogueLine5 auto
Topic property MantellaNpcTargetDialogueLine5 auto
Topic property MantellaNpcSourceDialogueLine6 auto
Topic property MantellaNpcTargetDialogueLine6 auto
Topic property MantellaNpcSourceDialogueLine7 auto
Topic property MantellaNpcTargetDialogueLine7 auto
Topic property MantellaNpcSourceDialogueLine8 auto
Topic property MantellaNpcTargetDialogueLine8 auto
Topic property MantellaNpcSourceDialogueLine9 auto
Topic property MantellaNpcTargetDialogueLine9 auto
Topic property MantellaNpcSourceDialogueLine10 auto
Topic property MantellaNpcTargetDialogueLine10 auto

ReferenceAlias property SourceRef1 auto
ReferenceAlias property TargetRef1 auto
ReferenceAlias property SourceRef2 auto
ReferenceAlias property TargetRef2 auto
ReferenceAlias property SourceRef3 auto
ReferenceAlias property TargetRef3 auto
ReferenceAlias property SourceRef4 auto
ReferenceAlias property TargetRef4 auto
ReferenceAlias property SourceRef5 auto
ReferenceAlias property TargetRef5 auto
ReferenceAlias property SourceRef6 auto
ReferenceAlias property TargetRef6 auto
ReferenceAlias property SourceRef7 auto
ReferenceAlias property TargetRef7 auto
ReferenceAlias property SourceRef8 auto
ReferenceAlias property TargetRef8 auto
ReferenceAlias property SourceRef9 auto
ReferenceAlias property TargetRef9 auto
ReferenceAlias property SourceRef10 auto
ReferenceAlias property TargetRef10 auto

GlobalVariable property MANTELLA_SOURCE_SAY_LINE_1 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_2 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_3 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_4 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_5 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_6 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_7 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_8 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_9 auto
GlobalVariable property MANTELLA_SOURCE_SAY_LINE_10 auto

GlobalVariable property MANTELLA_TARGET_SAY_LINE_1 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_2 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_3 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_4 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_5 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_6 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_7 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_8 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_9 auto
GlobalVariable property MANTELLA_TARGET_SAY_LINE_10 auto

GlobalVariable MANTELLA_SOURCE_SAY_LINE
GlobalVariable MANTELLA_TARGET_SAY_LINE

; Package Property MantellaListenAndFollow1 auto
; Package Property MantellaListenAndFollow2 auto
; Package Property MantellaListenAndFollow3 auto
; Package Property MantellaListenAndFollow4 auto
; Package Property MantellaListenAndFollow5 auto
; Package Property MantellaListenAndFollow6 auto
; Package Property MantellaListenAndFollow7 auto
; Package Property MantellaListenAndFollow8 auto
; Package Property MantellaListenAndFollow9 auto
; Package Property MantellaListenAndFollow10 auto

Topic MantellaNpcSourceDialogueLine
Topic MantellaNpcTargetDialogueLine

ReferenceAlias SourceRef
ReferenceAlias TargetRef

; Package MantellaListenAndFollow

Int MAX_DIALOGUE_COUNT = 10

event OnEffectStart(Actor target, Actor caster)
    MiscUtil.WriteToFile("_mantella__skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
    
    Utility.Wait(0.5)

    ; Start
    Int dialogueIndex = FindIndex(caster)
    
    Init(dialogueIndex)

    ; these three lines below is to ensure that no leftover Mantella effects are running
    MiscUtil.WriteToFile("mantella\\" + "_mantella_end_conversation_" + dialogueIndex + ".txt", "True",  append=false)
    Utility.Wait(0.5)
    MiscUtil.WriteToFile("mantella\\" + "_mantella_end_conversation_" + dialogueIndex + ".txt", "False",  append=false)
    
    SourceRef.ForceRefTo(caster)
    TargetRef.ForceRefTo(target)

    ; AddFollowPackage(target)
    ; DebugTrace("Follow package added to " + TargetRef.GetActorRef().GetDisplayName())

    int Time
    Time = GetCurrentHourOfDay()
    MiscUtil.WriteToFile("mantella\\" + "_mantella_in_game_time.txt", Time, append=false)

    String sayLineSource = "False"
    String sayLineTarget = "False"
    String playerResponse = "False"
    String subtitle = ""
    String endConversation = "False"
    String sayFinalLine = "False"

    ; Wait for first voiceline to play to avoid old conversation playing
    Utility.Wait(0.5)

    If dialogueIndex == -1
        DebugTrace("Returning from magic effect because index couldn't be found.")
        Return
    EndIf
    
    ; Start conversation
    While endConversation == "False"
        sayLineSource = MiscUtil.ReadFromFile("mantella\\" + "_mantella_say_line_source_" + dialogueIndex + ".txt") as String
        sayLineTarget = MiscUtil.ReadFromFile("mantella\\" + "_mantella_say_line_target_" + dialogueIndex + ".txt") as String
        
        if sayLineSource == "True"
            Utility.Wait(0.5) ; Wait for audio file to be registered
            
            DebugTrace("Saying line " + caster.GetDisplayName() + "(" + dialogueIndex + ")")

            subtitle = MiscUtil.ReadFromFile("mantella\\" + "_mantella_subtitle_" + dialogueIndex + ".txt") as String
            
            ; This set of global variables is because of the subtype of topic causes characters to say these lines on related events.
            MANTELLA_SOURCE_SAY_LINE.SetValueInt(1)
            Utility.Wait(0.25)
            MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(caster, MantellaNpcSourceDialogueLine, subtitle)
            caster.Say(MantellaNpcSourceDialogueLine, abSpeakInPlayersHead=false)
            Utility.Wait(0.25)
            MANTELLA_SOURCE_SAY_LINE.SetValueInt(0)

            ; Set sayLine back to False once the voiceline has been triggered
            MiscUtil.WriteToFile("mantella\\" + "_mantella_say_line_source_" + dialogueIndex + ".txt", "False",  append=false)
        endIf

        if sayLineTarget == "True"
            Utility.Wait(0.5) ; Wait for audio file to be registered

            DebugTrace("Saying line " + target.GetDisplayName() + "(" + dialogueIndex + ")")

            subtitle = MiscUtil.ReadFromFile("mantella\\" + "_mantella_subtitle_" + dialogueIndex + ".txt") as String
            
            ; This set of global variables is because of the subtype of topic causes characters to say these lines on related events.
            MANTELLA_TARGET_SAY_LINE.SetValueInt(1)
            Utility.Wait(0.25)
            MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(target, MantellaNpcTargetDialogueLine, subtitle)
            target.Say(MantellaNpcTargetDialogueLine, abSpeakInPlayersHead=false)
            Utility.Wait(0.25)
            MANTELLA_TARGET_SAY_LINE.SetValueInt(0)

            ; Set sayLine back to False once the voiceline has been triggered
            MiscUtil.WriteToFile("mantella\\" + "_mantella_say_line_target_" + dialogueIndex + ".txt", "False",  append=false)
        endIf

        String exe_error = MiscUtil.ReadFromFile("mantella\\" + "_mantella_error_check_" + dialogueIndex + ".txt") as String
        if exe_error == "True"
            Debug.Notification("Error with Mantella.exe. Please check MantellaSoftware/logging.log")
            MiscUtil.WriteToFile("mantella\\" + "_mantella_error_check_" + dialogueIndex + ".txt", "False",  append=false)
        endIf

        ; Update time (this may be too frequent)
        Time = GetCurrentHourOfDay()
        MiscUtil.WriteToFile("mantella\\" + "_mantella_in_game_time.txt", Time, append=false)

        if sayFinalLine == "True"
            endConversation = "True"
        endIf

        ; Wait for Python / the script to give the green light to end the conversation
        sayFinalLine = MiscUtil.ReadFromFile("mantella\\" + "_mantella_end_conversation_" + dialogueIndex + ".txt") as String
    endWhile

    
    ; RemoveFollowPackage(target)
    Reset(dialogueIndex)
endEvent

function Reset(Int dialogueIndex)
    MiscUtil.WriteToFile("mantella/_mantella_end_conversation_" + dialogueIndex + ".txt", "True",  append=false)
    MiscUtil.WriteToFile("mantella/_mantella_source_actor_" + dialogueIndex + ".txt", "",  append=false)
    MiscUtil.WriteToFile("mantella/_mantella_source_actor_id_" + dialogueIndex + ".txt", "",  append=false)
    MiscUtil.WriteToFile("mantella/_mantella_target_actor_" + dialogueIndex + ".txt", "",  append=false)
    MiscUtil.WriteToFile("mantella/_mantella_target_actor_id_" + dialogueIndex + ".txt", "",  append=false)
    MiscUtil.WriteToFile("mantella/_mantella_say_line_source_" + dialogueIndex + ".txt", "False",  append=false)
    MiscUtil.WriteToFile("mantella/_mantella_say_line_target_" + dialogueIndex + ".txt", "False",  append=false)
endFunction

Function AddFollowPackage(Actor source)
    ; ActorUtil.AddPackageOverride(source, MantellaListenAndFollow1)
EndFunction

Function RemoveFollowPackage(Actor _actor)
    ; ActorUtil.RemovePackageOverride(_actor, MantellaListenAndFollow)
EndFunction

Function Init(Int dialogueIndex)
    If dialogueIndex == 0
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine1
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine1
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_1
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_1
        SourceRef = SourceRef1
        TargetRef = TargetRef1
        ; MantellaListenAndFollow = MantellaListenAndFollow1
    EndIf
    If dialogueIndex == 1
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine2
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine2
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_2
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_2
        SourceRef = SourceRef2
        TargetRef = TargetRef2
        ; MantellaListenAndFollow = MantellaListenAndFollow2
    EndIf
    If dialogueIndex == 2
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine3
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine3
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_3
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_3
        SourceRef = SourceRef3
        TargetRef = TargetRef3
        ; MantellaListenAndFollow = MantellaListenAndFollow3
    EndIf
    If dialogueIndex == 3
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine4
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine4
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_4
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_4
        SourceRef = SourceRef4
        TargetRef = TargetRef4
        ; MantellaListenAndFollow = MantellaListenAndFollow4
    EndIf
    If dialogueIndex == 4
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine5
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine5
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_5
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_5
        SourceRef = SourceRef5
        TargetRef = TargetRef5
        ; MantellaListenAndFollow = MantellaListenAndFollow5
    EndIf
    If dialogueIndex == 5
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine6
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine6
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_6
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_6
        SourceRef = SourceRef6
        TargetRef = TargetRef6
        ; MantellaListenAndFollow = MantellaListenAndFollow6
    EndIf
    If dialogueIndex == 6
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine7
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine7
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_7
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_7
        SourceRef = SourceRef7
        TargetRef = TargetRef7
        ; MantellaListenAndFollow = MantellaListenAndFollow7
    EndIf
    If dialogueIndex == 7
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine8
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine8
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_8
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_8
        SourceRef = SourceRef8
        TargetRef = TargetRef8
        ; MantellaListenAndFollow = MantellaListenAndFollow8
    EndIf
    If dialogueIndex == 8
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine9
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine9
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_9
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_9
        SourceRef = SourceRef9
        TargetRef = TargetRef9
        ; MantellaListenAndFollow = MantellaListenAndFollow9
    EndIf
    If dialogueIndex == 9
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine10
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine10
        MANTELLA_SOURCE_SAY_LINE = MANTELLA_SOURCE_SAY_LINE_10
        MANTELLA_TARGET_SAY_LINE = MANTELLA_TARGET_SAY_LINE_10
        SourceRef = SourceRef10
        TargetRef = TargetRef10
        ; MantellaListenAndFollow = MantellaListenAndFollow10
    EndIf
EndFunction

Int Function FindIndex(Actor source)
    Int i = 0
    While i < MAX_DIALOGUE_COUNT
        String name = MiscUtil.ReadFromFile("mantella\\" + "_mantella_source_actor_" + i + ".txt") as String
        If name == source.GetDisplayName()
            Return i
        EndIf
        i += 1
    EndWhile

    Return -1
EndFunction

int function GetCurrentHourOfDay()
    float Time = Utility.GetCurrentGameTime()
    Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
    Time *= 24 ; Convert from fraction of a day to number of hours
    int Hour = Math.Floor(Time) ; Get whole hour
    return Hour
endFunction


function SplitSubtitleIntoParts(String subtitle)
    String[] subtitles = PapyrusUtil.StringSplit(subtitle, ",")
    int subtitleNo = 0
    while (subtitleNo < subtitles.Length)
        Debug.Notification(subtitles[subtitleNo])
        subtitleNo += 1
    endwhile
endFunction

function DebugTrace(String text)
    debug.Trace("Mantella:MagicEffect: " + text, 0)
endFunction

function DebugMessageBox(String text)
    debug.MessageBox("Mantella:MagicEffect: " + text)
endFunction