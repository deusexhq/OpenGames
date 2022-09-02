class GM extends Mutator config(OpenGames);

enum ELoad
{
	GM_CTF,
	GM_KillConfirmed,
	GM_Omni,
	GM_Random,
    GM_Off
};

var() config ELoad	GMMode;	

function PreBeginPlay(){
  Super.PreBeginPlay();
  Level.Game.BaseMutator.AddMutator(self);
}

function PostBeginPlay(){
    local GMCTF ctf;
    super.PostBeginPlay();

    if (Level.NetMode != NM_Standalone && Role == ROLE_Authority){

        switch(GMMode){
            case GM_CTF:
                if(!Level.Game.bTeamGame) {
                    Log("CTF must be started in Team DM.", 'GM');
                    return;
                };
                
                Log("Starting CTF.", 'GM');
                ctf = Spawn(class'GMCTF');
                
                if(!ctf.bValidMap()) {
                    Log("CTF is not set up for this map.", 'GM');    
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

function Mutate(string MutateString, PlayerPawn Sender){
    local string new_gm;

    if(MutateString ~= "gm"){
        Sender.ClientMessage("GM is currently"@GMMode);
    }
    if(left(MutateString,3) ~= "gm " && DeusExPlayer(Sender).bAdmin) {
        new_gm = Left(Right(MutateString, Len(MutateString) - 3),InStr(MutateString," "));
        if(new_gm != ""){
            switch(new_gm){
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
            Sender.ClientMessage("GM set to"@GMMode);

        }
    }

   	Super.Mutate(MutateString, Sender);
}


defaultproperties
{
    GMMode=GM_Off
}