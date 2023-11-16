Scriptname MantellaNpcScript extends Quest  

spell property MantellaNpcSpell auto
Float MeterUnits = 71.0210
Int MAX_DIALOGUE_COUNT = 10
Int MAX_DIALOGUE_TIMEOUT = 300
Int lastPairIndex = 0
Int[] sources
Int[] targets
Int[] initTimes
Int activeDialogCount = 0
Float MinDialogueDistance

Float function Meter(Float Meter)
    return Meter * MeterUnits
endFunction

Event OnInit()
    self.DebugTrace("Initialized")
    sources = new Int[10]
    targets = new Int[10]
    initTimes = new Int[10]

    Init()
    
    while true
        Int i = 0
        Int currentTime = utility.GetCurrentRealTime() as Int
        if currentTime % 10 == 0
            Int npcCount = FindNpcCountInTheArea(Meter(20))
            
            while i < npcCount / 2 && activeDialogCount < 1
                self.DebugTrace("Check. ActiveDialogueCount = " + activeDialogCount + ", NPC Count: " + npcCount)

                actor source = self.FindAvailableActor(game.GetPlayer(), Meter(20))
                if source != none
                    Int sourceId = (source.getactorbase() as form).getformid()

                    If npcCount <= 3
                        MinDialogueDistance = 7.0
                    Else
                        MinDialogueDistance = 1.5
                    EndIf

                    actor target = self.FindTargetActorForDialogue(source, Meter(MinDialogueDistance))
                    if target != none
                        Int targetId = (target.getactorbase() as form).getformid()
                        Int dice = ThrowDice()
                        DebugTrace("Throwing dice: " + source.GetDisplayName() + " - " + target.GetDisplayName() + ": " + (dice as String))
                        if  (dice == 1 || dice == 2)
                            Int pairIndex = (lastPairIndex) % MAX_DIALOGUE_COUNT

                            self.DebugTrace("Initializing Dialogue(" + pairIndex + ") Between " + source.GetDisplayName() + " and " + target.getDisplayName())

                            sources[pairIndex] = sourceId
                            targets[pairIndex] = targetId
                            initTimes[pairIndex] = utility.GetCurrentRealTime() as Int

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
                            if currLoc == ""
                                currLoc = "Skyrim"
                            endIf

                            MiscUtil.WriteToFile("mantella\\_mantella_current_location.txt", currLoc, append=false)

                            lastPairIndex += 1
                            activeDialogCount += 1
                            source.AddSpell(MantellaNpcSpell , true)
                            MantellaNpcSpell .Cast(source as objectreference, target as objectreference)
                        endIf
                    endIf
                endIf
                i += 1
            endWhile
        endIf
        self.ClearSourceTargetArrays()
    endWhile
EndEvent

Function Init()
    InitArray(initTimes, -1)

    Int i = 0
    while i < MAX_DIALOGUE_COUNT
        sources[i] = 0
        targets[i] = 0
        initTimes[i] = -1
        
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
        MiscUtil.WriteToFile("mantella\\_mantella_current_location.txt", "", append=false)

        i += 1
    endWhile
EndFunction

Int Function ThrowDice()
    Return Utility.RandomInt(1,6)
EndFunction

Int function FindNpcCountInTheArea(Float distance)
    Int[] ids = new Int[50]
    Actor center = Game.GetPlayer()
    Int count = 0
    Int i = 0
    while i < 50
        Actor resultActor = game.FindRandomActor(center.X, center.Y, center.Z, distance)
        Int id = (resultActor.getactorbase() as form).getformid()

        if resultActor != center && IsHuman(resultActor) && !CheckInArray(ids, id)
            ids[count] = id
            count += 1
        endIf
        i += 1
    endWhile
    return count
endFunction

actor function FindAvailableActor(actor center, Float distance)
    actor resultActor
    Bool search = true
    Int tryIndex = 0
    while tryIndex < 10 && search
        resultActor = game.FindRandomActor(center.X, center.Y, center.Z, distance)
        search = resultActor == game.GetPlayer() || resultActor == center || !IsAvailableForDialogue(resultActor) || !IsHuman(resultActor)
        tryIndex += 1
    endWhile
    if search
        return none
    else
        return resultActor
    endIf
endFunction

actor function FindTargetActorForDialogue(actor source, Float distance)
    actor resultActor
    Bool search = true
    Int tryIndex = 0
    while tryIndex < 10 && search
        resultActor = self.FindAvailableActor(source, distance)
        search = resultActor == None
        tryIndex += 1
    endWhile
    if search
        return none
    else
        return resultActor
    endIf
endFunction

bool function IsAvailableForDialogue(Actor _actor)
    return _actor != None && !CheckInArray(sources, (_actor.getactorbase() as form).getformid()) && !CheckInArray(targets, (_actor.getactorbase() as form).getformid()) && _actor.GetCurrentScene() == None  && !_actor.IsAlarmed() && !_actor.IsAlerted() && !_actor.IsArrested() && !_actor.IsDead() && !_actor.IsGhost() && !_actor.IsInCombat() && !_actor.IsInKillMove() && !_actor.IsIntimidated() && !_actor.IsSneaking() && !_actor.IsSprinting() && !_actor.IsTrespassing() && !_actor.IsUnconscious() && !_actor.IsHostileToActor(Game.GetPlayer())
endFunction

bool function IsHuman(Actor _actor)
    Faction[] factions = _actor.GetFactions(-128, 127)
    Int i = 0
    While i < factions.Length
        If factions[i].GetName() == "Creature Faction" || factions[i].GetName() == "Prey Faction"
            Return False
        EndIf
        i += 1
    EndWhile
    Return True
endFunction

function ClearSourceTargetArrays()
    Int currentTime = utility.GetCurrentRealTime() as Int
    Int i = 0
    while i < MAX_DIALOGUE_COUNT
        if(initTimes[i] != -1 && currentTime - initTimes[i] > MAX_DIALOGUE_TIMEOUT)
            DebugTrace("Ending Dialogue " + i)
            sources[i] = 0
            targets[i] = 0
            initTimes[i] = -1
            activeDialogCount -= 1
            
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
        endIf
        i += 1
    endWhile
endFunction

function InitArray(Int[] arr, Int val)
    Int i = 0
    While i < arr.Length
        arr[i] = val
        i += 1
    EndWhile
endFunction

Bool function CheckInArray(Int[] array, Int value)
    Int i = 0
    while i < array.length
        if value == array[i]
            return true
        endIf
        i += 1
    endWhile
    return false
endFunction

function DebugTrace(String text)
    debug.Trace("MantellaNpc2Npc: " + text, 0)
endFunction

function DebugMessageBox(String text)
    debug.MessageBox("MantellaNpc2Npc: " + text)
endFunction