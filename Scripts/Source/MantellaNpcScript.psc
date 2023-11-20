Scriptname MantellaNpcScript extends Quest  

Spell Property MantellaNpcSpell auto
MantellaMCM Property mcm auto

String engageProbability = "Medium"
Float MeterUnits = 71.0210

Actor[] sourceActors
Actor[] targetActors
Int[] sources
Int[] targets
Int[] initTimes

Int lastPairIndex = 0
Int activeDialogCount = 0
Float MaxDialogueDistance

String[] HUMAN_RACES
String[] VAMPIRE_RACES

Cell currentCell

; Package Property MantellaListenAndFollow1 auto

Float Function Meter(Float Meter)
    Return Meter * MeterUnits
EndFunction

Event OnInit()
    self.DebugTrace("Initialized")
    sourceActors = new Actor[20]
    targetActors = new Actor[20]
    sources = new Int[20]
    targets = new Int[20]
    initTimes = new Int[20]
    HUMAN_RACES = new String[10]
    VAMPIRE_RACES = new String[10]

    Init()
    
    While true
        Int i = 0
        Int currentTime = GetCurrentTime()
        If True
            Int npcCount = FindNpcCountInTheArea(Meter(mcm.GET_MANTELLA_MAX_RADIUS()))
            
            While i < npcCount && activeDialogCount < mcm.GET_MANTELLA_MAX_DIALOGUE_COUNT() && !self.CheckCellChange()
                DebugTrace("Check. ActiveDialogueCount = " + activeDialogCount + ", NPC Count: " + npcCount)

                ; DebugTrace("==== MCM VALUES ====")
                ; DebugTrace("MANTELLA_MAX_DIALOGUE_COUNT: " + mcm.GET_MANTELLA_MAX_DIALOGUE_COUNT())
                ; DebugTrace("MANTELLA_MAX_DIALOGUE_TIMEOUT: " + mcm.GET_MANTELLA_MAX_DIALOGUE_TIMEOUT())
                ; DebugTrace("MANTELLA_MAX_RADIUS: " + mcm.GET_MANTELLA_MAX_RADIUS())
                ; DebugTrace("MANTELLA_MAX_DISTANCE: " + mcm.GET_MANTELLA_MAX_DISTANCE())
                ; DebugTrace("MANTELLA_SELECTED_FREQUENCY: " + mcm.GET_MANTELLA_SELECTED_FREQUENCY())
                ; DebugTrace("====================")

                actor source = self.FindAvailableActor(game.GetPlayer(), Meter(mcm.GET_MANTELLA_MAX_RADIUS()))
                If source != none
                    Int sourceId = (source.getactorbase() as form).getformid()

                    If npcCount <= 3
                        MaxDialogueDistance = mcm.GET_MANTELLA_MAX_DISTANCE() * 3
                    Else
                        MaxDialogueDistance = mcm.GET_MANTELLA_MAX_DISTANCE()
                    EndIf

                    actor target = self.FindTargetActorForDialogue(source, Meter(MaxDialogueDistance))
                    If target != none
                        Int targetId = (target.getactorbase() as form).getformid()
                        Int dice = ThrowDice()
                        DebugTrace("Throwing dice: " + source.GetDisplayName() + " - " + target.GetDisplayName() + ": " + (dice as String))

                        Bool condition = False
                        If mcm.GET_MANTELLA_SELECTED_FREQUENCY() == 0
                            condition = dice == 1
                        EndIf
                        If mcm.GET_MANTELLA_SELECTED_FREQUENCY() == 1
                            condition = dice <= 3
                        EndIf
                        If mcm.GET_MANTELLA_SELECTED_FREQUENCY() == 2
                            condition = dice <= 6
                        EndIf
                        If  condition
                            Int pairIndex = (lastPairIndex) % mcm.GET_MANTELLA_MAX_DIALOGUE_COUNT()

                            self.DebugTrace("Initializing Dialogue(" + pairIndex + ") Between " + source.GetDisplayName() + " and " + target.getDisplayName())
                            ; Debug.Notification("Initializing Dialogue(" + pairIndex + ") Between " + source.GetDisplayName() + " and " + target.getDisplayName())

                            sourceActors[pairIndex] = source
                            targetActors[pairIndex] = target
                            sources[pairIndex] = sourceId
                            targets[pairIndex] = targetId
                            initTimes[pairIndex] = GetCurrentTime()

                            miscutil.WriteToFile("mantella\\_mantella_source_actor_id_" + pairIndex + ".txt", sourceId as String, false, false)
                            miscutil.WriteToFile("mantella\\_mantella_target_actor_id_" + pairIndex + ".txt", targetId as String, false, false)
                            miscutil.WriteToFile("mantella\\_mantella_source_actor_" + pairIndex + ".txt", source.GetDisplayName(), false, false)
                            miscutil.WriteToFile("mantella\\_mantella_target_actor_" + pairIndex + ".txt", target.GetDisplayName(), false, false)
                            
                            String sourceSex = source.getleveledactorbase().getsex()
                            MiscUtil.WriteToFile("mantella\\_mantella_source_actor_sex_" + pairIndex + ".txt", sourceSex, append=false)

                            String targetSex = target.getleveledactorbase().getsex()
                            MiscUtil.WriteToFile("mantella\\_mantella_target_actor_sex_" + pairIndex + ".txt", targetSex, append=false)

                            String sourceRace = source.getrace()
                            MiscUtil.WriteToFile("mantella\\_mantella_source_actor_race_" + pairIndex + ".txt", sourceRace, append=false)

                            String targetRace = target.getrace()
                            MiscUtil.WriteToFile("mantella\\_mantella_target_actor_race_" + pairIndex + ".txt", targetRace, append=false)

                            String sourceVoiceType = source.GetVoiceType()
                            MiscUtil.WriteToFile("mantella\\_mantella_source_actor_voice_" + pairIndex + ".txt", sourceVoiceType, append=false)

                            String targetVoiceType = target.GetVoiceType()
                            MiscUtil.WriteToFile("mantella\\_mantella_target_actor_voice_" + pairIndex + ".txt", targetVoiceType, append=false)

                            String relationship = source.getrelationshiprank(target)
                            MiscUtil.WriteToFile("mantella\\_mantella_actor_relationship_" + pairIndex + ".txt", relationship, append=false)

                            MiscUtil.WriteToFile("mantella\\_mantella_end_conversation_" + pairIndex + ".txt", "False", append=false)

                            String currLoc = (source.GetCurrentLocation() as form).getname()
                            If currLoc == ""
                                currLoc = "Skyrim"
                            EndIf

                            MiscUtil.WriteToFile("mantella\\_mantella_current_location.txt", currLoc, append=false)
                                                        
                            lastPairIndex += 1
                            activeDialogCount += 1
                            source.AddSpell(MantellaNpcSpell, true)
                            MantellaNpcSpell .Cast(source as objectreference, target as objectreference)
                            ; DebugTrace("Adding package to " + target.GetDisplayName())
                            ; ActorUtil.RemovePackageOverride(target,MantellaListenAndFollow1)
                            ; ActorUtil.AddPackageOverride(target,MantellaListenAndFollow1)
                            ; DebugTrace("Follow package added to " + target.GetDisplayName())
                        EndIf
                    EndIf
                EndIf
                i += 1
            EndWhile
        EndIf
        self.ClearSourceTargetArrays()
    EndWhile
EndEvent

Function Init()
    InitArray(sources, 0)
    InitArray(targets, 0)
    InitArray(initTimes, -1)
    
    Int i = 0
    While i < mcm.GET_MANTELLA_MAX_DIALOGUE_COUNT()  
        ResetData(i)
        i += 1
    EndWhile

    HUMAN_RACES[0] = "Argonian"
    HUMAN_RACES[1] = "Breton"
    HUMAN_RACES[2] = "Dark Elf"
    HUMAN_RACES[3] = "High Elf"
    HUMAN_RACES[4] = "IMPERIAL"
    HUMAN_RACES[5] = "Khajit"
    HUMAN_RACES[6] = "Nord"
    HUMAN_RACES[7] = "Orc"
    HUMAN_RACES[8] = "Redguard"
    HUMAN_RACES[9] = "Wood Elf"

    VAMPIRE_RACES[0] = "Argonian Vampire"
    VAMPIRE_RACES[1] = "Breton Vampire"
    VAMPIRE_RACES[2] = "Dark Elf Vampire"
    VAMPIRE_RACES[3] = "High ElfV ampire"
    VAMPIRE_RACES[4] = "IMPERIAL Vampire"
    VAMPIRE_RACES[5] = "Khajit Vampire"
    VAMPIRE_RACES[6] = "Nord Vampire"
    VAMPIRE_RACES[7] = "Orc Vampire"
    VAMPIRE_RACES[8] = "Redguard Vampire"
    VAMPIRE_RACES[9] = "Wood Elf Vampire"

    currentCell = Game.GetPlayer().GetParentCell()
EndFunction

Int Function ThrowDice()
    Return Utility.RandomInt(1,6)
EndFunction

Bool Function CheckCellChange()
    Cell playerCell = Game.GetPlayer().GetParentCell()
    If playerCell != currentCell
        currentCell = playerCell
        ResetAllData()
        Return True
    Else
        Return False
    EndIf
EndFunction

Int Function FindNpcCountInTheArea(Float distance)
    Int[] ids = new Int[50]
    Actor center = Game.GetPlayer()
    Int count = 0
    Int i = 0
    While i < 50
        Actor resultActor = game.FindRandomActor(center.X, center.Y, center.Z, distance)
        Int id = (resultActor.getactorbase() as form).getformid()
        If resultActor != center && (IsHuman(resultActor) || IsVampire(resultActor)) && !CheckInArray(ids, id)
            ids[count] = id
            count += 1
        EndIf
        i += 1
    EndWhile
    Return count
EndFunction

Actor Function FindAvailableActor(actor center, Float distance)
    Actor resultActor
    Bool search = true
    Int tryIndex = 0
    While tryIndex < 20 && search
        resultActor = game.FindRandomActor(center.X, center.Y, center.Z, distance)
        search = resultActor == game.GetPlayer() || resultActor == center || !IsAvailableForDialogue(resultActor) || (!IsHuman(resultActor) && !IsVampire(resultActor))
        tryIndex += 1
    EndWhile
    If search
        Return none
    Else
        Return resultActor
    EndIf
EndFunction

Actor Function FindTargetActorForDialogue(actor source, Float distance)
    Actor resultActor
    Bool search = true
    Int tryIndex = 0
    While tryIndex < 20 && search
        resultActor = self.FindAvailableActor(source, distance)
        search = resultActor == None
        tryIndex += 1
    EndWhile
    If search
        Return none
    Else
        Return resultActor
    EndIf
EndFunction

Bool Function IsAvailableForDialogue(Actor _actor)
    Return _actor != None && !CheckInArray(sources, (_actor.getactorbase() as form).getformid()) && !CheckInArray(targets, (_actor.getactorbase() as form).getformid()) && _actor.GetCurrentScene() == None  && _actor.GetSleepState() < 3 && !_actor.IsAlarmed() && !_actor.IsAlerted() && !_actor.IsArrested() && !_actor.IsDead() && !_actor.IsGhost() && !_actor.IsInCombat() && !_actor.IsInKillMove() && !_actor.IsIntimidated() && !_actor.IsSneaking() && !_actor.IsSprinting() && !_actor.IsTrespassing() && !_actor.IsUnconscious() && !_actor.IsHostileToActor(Game.GetPlayer())
EndFunction

Bool Function IsHuman(Actor _actor)
    Return CheckInStringArray(HUMAN_RACES, _actor.GetRace().GetName())
EndFunction

Bool Function IsVampire(Actor _actor)
    Return CheckInStringArray(Vampire_RACES, _actor.GetRace().GetName())
EndFunction

Bool Function IsDragon(Actor _actor)
    Return _actor.GetRace().GetName() == "Dragon"
EndFunction

Function ClearSourceTargetArrays()
    Int currentTime = GetCurrentTime()
    Int i = 0
    String endConversation
    While i < mcm.GET_MANTELLA_MAX_DIALOGUE_COUNT()
        endConversation = MiscUtil.ReadFromFile("mantella\\_mantella_end_conversation_" + i + ".txt")

        DebugTrace(initTimes[i] + ", " + currentTime + ", " + mcm.GET_MANTELLA_MAX_DIALOGUE_TIMEOUT())
        If initTimes[i] != -1 && ((currentTime - initTimes[i] > mcm.GET_MANTELLA_MAX_DIALOGUE_TIMEOUT()) || endConversation == "True")
            DebugTrace("Ending Dialogue " + i)
            sources[i] = 0
            targets[i] = 0
            initTimes[i] = -1
            activeDialogCount -= 1
            
            ResetData(i)

            ; Debug.Trace("Removing package override from " + targetActors[i].GetDisplayName())
            ; ActorUtil.RemovePackageOverride(targetActors[i],MantellaListenAndFollow1)
            ; Debug.Trace("Removed package override from " + targetActors[i].GetDisplayName())
            sourceActors[i] = None
            targetActors[i] = None
        EndIf
        i += 1
    EndWhile
EndFunction

Int Function GetCurrentTime()
    Float currentGameTime = Utility.GetCurrentGameTime()

    Return ((currentGameTime * 10000) as Int)
EndFunction

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

Function InitArray(Int[] arr, Int val)
    Int i = 0
    While i < arr.Length
        arr[i] = val
        i += 1
    EndWhile
EndFunction

Bool Function CheckInArray(Int[] array, Int value)
    Int i = 0
    While i < array.length
        If value == array[i]
            Return true
        EndIf
        i += 1
    EndWhile
    Return false
EndFunction

Bool Function CheckInStringArray(String[] array, String value)
    Int i = 0
    While i < array.length
        ; DebugTrace(array[i] + ", " + value)
        If value == array[i]
            Return true
        EndIf
        i += 1
    EndWhile
    Return false
EndFunction

Function DebugTrace(String text)
    Debug.Trace("Mantella: " + text, 0)
EndFunction

Function DebugMessageBox(String text)
    Debug.MessageBox("Mantella: " + text)
EndFunction