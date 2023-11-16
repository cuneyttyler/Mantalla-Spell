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

Topic MantellaNpcSourceDialogueLine
Topic MantellaNpcTargetDialogueLine

ReferenceAlias SourceRef
ReferenceAlias TargetRef

Int MAX_DIALOGUE_COUNT = 10

event OnEffectStart(Actor target, Actor caster)
    ; these three lines below is to ensure that no leftover Mantella effects are running
    MiscUtil.WriteToFile("mantella\\" + "_mantella_end_conversation.txt", "True",  append=false)
    Utility.Wait(0.5)
    MiscUtil.WriteToFile("mantella\\" + "_mantella_end_conversation.txt", "False",  append=false)
    
    MiscUtil.WriteToFile("_mantella_skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
    
    Utility.Wait(0.5)

    ; Start
    Int dialogueIndex = FindIndex(caster)
    
    Init(dialogueIndex)

    SourceRef.ForceRefTo(caster)
    TargetRef.ForceRefTo(target)

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
            
            DebugTrace("Saying line " + caster.GetDisplayName())

            subtitle = MiscUtil.ReadFromFile("mantella\\" + "_mantella_subtitle_" + dialogueIndex + ".txt") as String
            
            ; MantellaNpcSubtitles.SetInjectTopicAndSubtitleForSpeaker(caster, MantellaNpcSourceDialogueLine, subtitle)
            caster.Say(MantellaNpcSourceDialogueLine, abSpeakInPlayersHead=false)

            ; Set sayLine back to False once the voiceline has been triggered
            MiscUtil.WriteToFile("mantella\\" + "_mantella_say_line_source_" + dialogueIndex + ".txt", "False",  append=false)
        endIf

        if sayLineTarget == "True"
            Utility.Wait(0.5) ; Wait for audio file to be registered

            DebugTrace("Saying line " + target.GetDisplayName())

            subtitle = MiscUtil.ReadFromFile("mantella\\" + "_mantella_subtitle_" + dialogueIndex + ".txt") as String
            
            ; MantellaNpcSubtitles.SetInjectTopicAndSubtitleForSpeaker(target, MantellaNpcTargetDialogueLine, subtitle)
            target.Say(MantellaNpcTargetDialogueLine, abSpeakInPlayersHead=false)

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
endEvent

Function Init(Int dialogueIndex)
    If dialogueIndex == 0
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine1
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine1
        SourceRef = SourceRef1
        TargetRef = TargetRef1
    EndIf
    If dialogueIndex == 1
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine2
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine2
        SourceRef = SourceRef2
        TargetRef = TargetRef2
    EndIf
    If dialogueIndex == 2
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine3
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine3
        SourceRef = SourceRef3
        TargetRef = TargetRef3
    EndIf
    If dialogueIndex == 3
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine4
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine4
        SourceRef = SourceRef4
        TargetRef = TargetRef4
    EndIf
    If dialogueIndex == 4
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine5
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine5
        SourceRef = SourceRef5
        TargetRef = TargetRef5
    EndIf
    If dialogueIndex == 5
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine6
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine6
        SourceRef = SourceRef6
        TargetRef = TargetRef6
    EndIf
    If dialogueIndex == 6
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine7
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine7
        SourceRef = SourceRef7
        TargetRef = TargetRef7
    EndIf
    If dialogueIndex == 7
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine8
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine8
        SourceRef = SourceRef8
        TargetRef = TargetRef8
    EndIf
    If dialogueIndex == 8
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine9
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine9
        SourceRef = SourceRef9
        TargetRef = TargetRef9
    EndIf
    If dialogueIndex == 9
        MantellaNpcSourceDialogueLine = MantellaNpcSourceDialogueLine10
        MantellaNpcTargetDialogueLine = MantellaNpcTargetDialogueLine10
        SourceRef = SourceRef10
        TargetRef = TargetRef10
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
    debug.Trace("MantellaNpc:MagicEffect: " + text, 0)
endFunction

function DebugMessageBox(String text)
    debug.MessageBox("MantellaNpc:MagicEffect: " + text)
endFunction