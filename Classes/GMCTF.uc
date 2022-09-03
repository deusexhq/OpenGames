class GMCTF extends Mutator config(OpenGames);

var() config bool bEnabled;

struct CtfMaps
{
	var() config string	MapName;
	var() config Vector	Team0Location;
	var() config Vector  Team1Location;
};

var() config CtfMaps Maps[64];
var() config bool bFullAuto;
var() config float RequiredDistance;

var ctfTeamManager f1, f0;

//@todo test automatic generation

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
    f0.Texture = Texture'AlarmLightTex7';
    f0.SetTimer(1, True);

    f1 = Spawn(class'ctfTeamManager',,,t1);
    f1.TeamID = 1;
    f1.LightHue = 0;
    f1.Texture = Texture'AlarmLightTex3';
    f1.SetTimer(1, True);
}

function GenerateBases(){
  local PlayerStart s0, s1, fs0, fs1;
  local float dist, longest;
  local int count;
  
  if(bEnabled) ShutdownCTF();
  log("Starting auto-generation...", 'CTF');

  foreach AllActors(class'PlayerStart', s0){
    count++;
    foreach AllActors(class'PlayerStart', s1){
      dist = VSize(s1.Location - s0.Location);
      log("Distance is "$dist, 'CTF');
      if(dist > longest){
        log("New furthest distance recorded.", 'CTF');
        fs0 = s0;
        fs1 = s1;
        longest = dist;
      }
    }
  }
  
  if(count < 2){
    Log("Not enough playerstart objects to generate bases.", 'CTF');
    return;
  }
  
  if(longest < RequiredDistance){
    Log("Bases must be at least"@RequiredDistance@"apart. (Currently"@longest$")");
    return;
  }
  
  Install();
  SetTeam0Loc(fs0.Location);
  SetTeam1Loc(fs1.Location);
  SaveConfig();
  InitializeCTF();
}

function ModifyPlayer(Pawn P) {  
    local Vector Loc;
    Log("Moving player "$p, 'CTF');

    if(P.PlayerReplicationInfo.Team == 0)
      loc = f0.location + (p.CollisionRadius+Default.CollisionRadius+30) * Vector(f0.Rotation) + vect(0,0,1) * 15;
    else
      loc = f1.location + (p.CollisionRadius+Default.CollisionRadius+30) * Vector(f1.Rotation) + vect(0,0,1) * 15;

    DeusExPlayer(P).SetCollision(false, false, false);
    DeusExPlayer(P).bCollideWorld = true;
    DeusExPlayer(P).GotoState('PlayerWalking');
    DeusExPlayer(P).SetLocation(loc);

    
    DeusExPlayer(P).SetCollision(true, true , true);
    DeusExPlayer(P).SetPhysics(PHYS_Walking);
    DeusExPlayer(P).bCollideWorld = true;
    DeusExPlayer(P).GotoState('PlayerWalking');
    DeusExPlayer(P).ClientReStart();
  
   Super.ModifyPlayer(P);
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
  //Log("Called in invalid map.", 'CTF');
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
      Sender.ClientMessage("Mutate commands: ctf, ctf.help, *ctf.resetscores, *ctf.setteam0, *ctf.setteam1, *ctf.stuck, *ctf.enable, *ctf.disable, *ctf.auto");
      Sender.ClientMessage("Commands marked with * require admin.");
    }

    if(MutateString ~= "ctf.resetscores" && DeusExPlayer(Sender).bAdmin){
      ResetScores();
      BroadcastMessage("Scoreboard reset.");
    }

    if(MutateString ~= "ctf.auto" && DeusExPlayer(Sender).bAdmin){
      GenerateBases();
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
  RequiredDistance=500
  bFullAuto=True
}
