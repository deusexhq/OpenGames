class GMCTF extends Mutator config(OpenGames);

var() config bool bEnabled;

struct CtfMaps
{
	var() config string	MapName;
	var() config Vector	Team0Location;
	var() config Vector  Team1Location;
};

var() config CtfMaps Maps[64];
var ctfTeamManager f1, f0;

function PreBeginPlay(){
  Super.PreBeginPlay();
  Level.Game.BaseMutator.AddMutator(self);
}

function PostBeginPlay(){
  super.PostBeginPlay();
}

function InitializeCTF(){
    local Vector t0, t1;
    Log("Initializing "$self$"...", 'CTF');

    bEnabled = True;
    DeusExMPGame(Level.Game).bFreezeScores = True;

    t0 = GetTeam0Loc();
    t1 = GetTeam1Loc();

    t0.z += 50;
    t1.z += 50;

    f0 = Spawn(class'ctfTeamManager',,,t0);
    f0.TeamID = 0;
    f0.LightHue = 150;
    f0.SetTimer(1, True);

    f1 = Spawn(class'ctfTeamManager',,,t1);
    f1.TeamID = 1;
    f1.LightHue = 0;
    f1.SetTimer(1, True);
}

function ShutdownCTF(){
  f0.Destroy();
  f1.Destroy();
  bEnabled = False;
  DeusExMPGame(Level.Game).bFreezeScores = False;
}

function Install(){
  local int i;
  if(bValidMap()) return;
  for(i=0;i<32;i++){
    if(Maps[i].MapName == ""){
      Maps[i].MapName = Left(string(Level), InStr(string(Level), "."));
      return;
    }
  }
}

function Vector GetTeam0Loc(){
  local int i;
  for(i=0;i<32;i++){
    if(Left(string(Level), InStr(string(Level), ".")) ~= Maps[i].MapName){
      return Maps[i].Team0Location;
    }
  }
}

function Vector GetTeam1Loc(){
  local int i;
  for(i=0;i<32;i++){
    if(Left(string(Level), InStr(string(Level), ".")) ~= Maps[i].MapName){
      return Maps[i].Team1Location;
    }
  }
}

function SetTeam0Loc(vector NewLoc){
  local int i;
  for(i=0;i<32;i++){
    if(Left(string(Level), InStr(string(Level), ".")) ~= Maps[i].MapName){
      Maps[i].Team0Location = NewLoc;
    }
  }
}

function SetTeam1Loc(vector NewLoc){
  local int i;
  for(i=0;i<32;i++){
    if(Left(string(Level), InStr(string(Level), ".")) ~= Maps[i].MapName){
      Maps[i].Team1Location = NewLoc;
    }
  }
}

function bool bValidMap(){
  local int i;
  for(i=0;i<32;i++){
    if(Left(string(Level), InStr(string(Level), ".")) ~= Maps[i].MapName){
      return True;
    }
  }
  Log("Called in invalid map.", 'CTF');
  return False;
}

function ResetScores(){
  local PlayerReplicationInfo PRI;
	foreach allactors(class'PlayerReplicationInfo',PRI)	{
		PRI.Score = 0;
		PRI.Deaths = 0;
		PRI.Streak = 0;
	}
}

function Mutate(string MutateString, PlayerPawn Sender){
    local ctfFlag f;

    if(MutateString ~= "ctf"){
      Sender.ClientMessage("CTF (Enabled: "@bEnabled@")");
    }

    if(MutateString ~= "ctf.help"){
      Sender.ClientMessage("ctf, ctf.help, *ctf.resetscores, *ctf.setteam0, *ctf.setteam1, *ctf.stuck, *ctf.enable, *ctf.disable");
    }

    if(MutateString ~= "ctf.resetscores" && DeusExPlayer(Sender).bAdmin){
      ResetScores();
      BroadcastMessage("Scoreboard reset.");
    }


    if(MutateString ~= "ctf.setteam0" && DeusExPlayer(Sender).bAdmin){
      Install();
      SetTeam0Loc(Sender.Location);
      BroadcastMessage("Team 0 Base Location for "$Level$" set to "$Sender.Location);
      SaveConfig();
    }

    if(MutateString ~= "ctf.setteam1" && DeusExPlayer(Sender).bAdmin){
      Install();
      SetTeam1Loc(Sender.Location);
      BroadcastMessage("Team 1 Base Location for "$Level$" set to "$Sender.Location);
      SaveConfig();
    }

    if(MutateString ~= "ctf.enable" && DeusExPlayer(Sender).bAdmin){
      if(bEnabled) return;
      bEnabled = True;
      InitializeCTF();
      SaveConfig();
      BroadcastMessage("CTF enabled.");
    }

    if(MutateString ~= "ctf.disable" && DeusExPlayer(Sender).bAdmin){
      if(!bEnabled) return;
      bEnabled = false;
      ShutdownCTF();
      SaveConfig();
      BroadcastMessage("CTF disabled.");
    }

    if(MutateString ~= "ctf.stuck" && DeusExPlayer(Sender).bAdmin){
      foreach AllActors(class'ctfFlag', f){
        f.Destroy();
      }
    }
   	Super.Mutate(MutateString, Sender);
}


defaultproperties
{
}
