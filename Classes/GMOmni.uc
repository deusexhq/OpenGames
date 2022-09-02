class GMOmni extends Mutator config(OpenGames);

var() config bool bEnabled;

function PreBeginPlay(){
  Super.PreBeginPlay();
  Level.Game.BaseMutator.AddMutator(self);
}

function PostBeginPlay(){
    super.PostBeginPlay();

    if(bEnabled){
      DeusExMPGame(Level.Game).VictoryCondition = "Time";
    }
}

function CheckWin(DeusExPlayer winner){
    if(winner.PlayerReplicationInfo.score > DeusExMPGame(Level.Game).ScoreToWin){
        DeusExMPGame(Level.Game).PreGameOver();
        if(DeathMatchGame(Level.Game)!=None) DeathMatchGame(Level.Game).PlayerHasWon( Winner, Winner, None, " [Won by score limit]" );
        if(TeamDMGame(Level.Game)!=None) TeamDMGame(Level.Game).TeamHasWon( Winner.PlayerReplicationInfo.Team, Winner, None, " [Won by score limit]" );
        DeusExMPGame(Level.Game).GameOver();
    }
}

function ScoreKill(Pawn Killer, Pawn Other){
  local DeusExPlayer dxp, victim;
  local kcCapturePoint cpt;
  local Vector SpawnLoc;

  if(bEnabled) {
    dxp = DeusExPlayer(Killer);
    victim = DeusExPlayer(Other);
    
    if(dxp != None && victim != None && dxp != victim){
      CheckWin(dxp);
    }
  }

  super.ScoreKill(Killer, Other); 	
}

function Mutate(string MutateString, PlayerPawn Sender){
    local ctfFlag f;

    if(MutateString ~= "omni"){
      Sender.ClientMessage("omni (Enabled: "@bEnabled@")");
    }

    if(MutateString ~= "omni.help"){
      Sender.ClientMessage("omni, omni.help, *omni.enable, *omni.disable");
    }

    if(MutateString ~= "omni.enable" && DeusExPlayer(Sender).bAdmin){
      if(bEnabled) return;
      bEnabled = True;
      DeusExMPGame(Level.Game).VictoryCondition = "Time";
      SaveConfig();
      BroadcastMessage("omni enabled.");
    }

    if(MutateString ~= "omni.disable" && DeusExPlayer(Sender).bAdmin){
      if(!bEnabled) return;
      bEnabled = false;
      DeusExMPGame(Level.Game).VictoryCondition = DeusExMPGame(Level.Game).Default.VictoryCondition;
      SaveConfig();
      BroadcastMessage("omni disabled.");
    }
   	Super.Mutate(MutateString, Sender);
}


defaultproperties
{
}
