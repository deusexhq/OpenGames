/*
Manager for OpenGames.
*/
class GM extends Mutator config(OpenGames);

enum ELoad
{
    GM_Agents,
	GM_CTF,
	GM_KillConfirmed,
	GM_Omni,
	GM_Random,
    GM_Off
};

var() config ELoad	GMMode;	

function PreBeginPlay(){
	Level.Game.BaseMutator.AddMutator(self);
	Super.PreBeginPlay();
}

function PostBeginPlay(){
    local GMCTF ctf;
    super.PostBeginPlay();

    if (Level.NetMode != NM_Standalone && Role == ROLE_Authority){

        switch(GMMode){
            case GM_Agents:
                Spawn(class'GMAgents');
                break;
            case GM_CTF:
                if(!Level.Game.bTeamGame) {
                    Log("CTF must be started in Team DM.", 'GM');
                    return;
                };
                
                Log("Starting CTF.", 'GM');
                ctf = Spawn(class'GMCTF');
                
                if(!ctf.bValidMap()) {
                    if(ctf.bFullAuto){
                        ctf.GenerateBases();
                    } else {
                        Log("CTF is not set up for this map.", 'GM');  
                    }
                      
                    return;
                }
                ctf.InitializeCTF();
                break;

            case GM_KillConfirmed:
                Log("Starting KC.", 'GM');
                Spawn(class'GMKillConfirmed');
                break;

            case GM_Omni:
                Log("Starting Omni.", 'GM');
                Spawn(class'GMOmni');
                break;

            case GM_Random:
                Log("Random not yet implemented.", 'GM');
                break;

            case GM_Off:
                Log("GM is sleeping.", 'GM');
                break;
        }
    }
    
}

function string GetName(){
    switch(GMMode){
        case GM_Agents:
            return "Agents";
            
        case GM_CTF:
            return "CTF";

        case GM_KillConfirmed:
            return "KillConfirmed";

        case GM_Omni:
            return "Omni";

        case GM_Random:
            return "Random";

        case GM_Off:
            return "OFF";
    }
}

function ChangeMode(string new_gm, bool bRestart){
    switch(new_gm){
        case "agents":
            GMMode = GM_Agents;
            break;
        case "ctf":
            GMMode = GM_CTF;
            break;
        case "kc":
        case "killconfirmed":
            GMMode = GM_KillConfirmed;
            break;
        case "omni":
            GMMode = GM_Omni;
            break;
        case "random":
            GMMode = GM_Random;
            break;
        case "off":
            GMMode = GM_Off;
            break;
    }
    SaveConfig();
    if(bRestart) ConsoleCommand("servertravel restart");
}

function DeusExPlayer GetPlayer(int id){
    local DeusExPlayer P;
    
    foreach AllActors(class'DeusExPlayer', P){
        if(P.PlayerReplicationInfo.PlayerID == id) return P;
    }
}

function Mutate(string MutateString, PlayerPawn Sender){
    local string mstr;
    local DeusExPlayer Target;
    
    if(MutateString ~= "gm"){
        Sender.ClientMessage("GM is currently"@GetName());
        Sender.ClientMessage("Options: agents, ctf, kc, omni, random, off");
    }
    
    if(MutateString ~= "gm.help"){
        Sender.ClientMessage("gm, gm.help, gm.switch <id>, gm.spectate <id>, gmr <mode>, gm <mode>");
    }
    
    if(left(MutateString,10) ~= "gm.switch " && DeusExPlayer(Sender).bAdmin) {
        mstr = Right(MutateString, Len(MutateString) - 10);
        if(mstr != ""){
            Target = GetPlayer(int(mstr));
            if(Target != None){
                if(Target.PlayerReplicationInfo.Team == 0){
                    Target.ChangeTeam(1);
                    BroadcastMessage("|P7Game Manager|P1: "$Target.PlayerReplicationInfo.PlayerName$" was switched to NSF by "$Sender.PlayerReplicationInfo.PlayerName$".");
                } else {
                    Target.ChangeTeam(0);
                    BroadcastMessage("|P7Game Manager|P1: "$Target.PlayerReplicationInfo.PlayerName$" was switched to UNATCO by "$Sender.PlayerReplicationInfo.PlayerName$".");
                }
            } else {
                Sender.ClientMessage("No player found with ID "$mstr);
            }
        } else Sender.ClientMessage("Needs a players ID.");
    }
    
    if(left(MutateString,12) ~= "gm.spectate " && DeusExPlayer(Sender).bAdmin) {
        mstr = Right(MutateString, Len(MutateString) - 12);
        if(mstr != ""){
            Target = GetPlayer(int(mstr));
            if(Target != None){
                Target.GotoState('PlayerSpectating');
                BroadcastMessage("|P7Game Manager|P1: "$Target.PlayerReplicationInfo.PlayerName$" was set to spectate by "$Sender.PlayerReplicationInfo.PlayerName$".");
            } else {
                Sender.ClientMessage("No player found with ID "$mstr);
            }
        } else Sender.ClientMessage("Needs a players ID.");
    }
    
    if(left(MutateString,4) ~= "gmr " && DeusExPlayer(Sender).bAdmin) {
        mstr = Right(MutateString, Len(MutateString) - 4);
        if(mstr != ""){
            Sender.ClientMessage("Setting "$mstr);
            ChangeMode(mstr, True);
            BroadcastMessage("|P7Game Manager|P1: Mode is set to"@GetName()$". Restarting...");
        }
    }

    if(left(MutateString,3) ~= "gm " && DeusExPlayer(Sender).bAdmin) {
        mstr = Right(MutateString, Len(MutateString) - 3);
        if(mstr != ""){
            Sender.ClientMessage("Setting "$mstr);
            ChangeMode(mstr, False);
            BroadcastMessage("|P7Game Manager|P1: Mode is set to"@GetName());
        }
    }

   	Super.Mutate(MutateString, Sender);
}


defaultproperties
{
    GMMode=GM_Off
}
