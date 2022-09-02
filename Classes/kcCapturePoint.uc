Class kcCapturePoint extends DeusExDecoration config (OpenGames);

var DeusExPlayer Killer, Victim;
var bool bTaken;
var float aliveTime;
var bool bCritical;

var() config int BaseScoreGain, ScoreGainDeny, ScoreGainSteal;

function Tick(float deltatime){
	local DeusExPlayer P, winP;
	local vector dist;
	local float lowestDist;
  
    //Foolproofing to make sure it never triggers twice.
    if(bTaken) return;

    super.Tick(deltatime);

    aliveTime += deltatime;

    // Give it a little cooldown after spawning before it can be taken
    // Preventing any weird timing hickups with the victim being able to confirm themselves as they die.
    if(aliveTime <= 3.0) return;

    if(Killer == None) {
        BroadcastMessage("|P2A killer has fled the battle and their kill has been removed.");
        Destroy();
    }

    if(Victim == None) {
        BroadcastMessage("|P2A victim has fled the battle and their death has been confirmed.");
        if(Killer != None) killer.PlayerReplicationInfo.Score += BaseScoreGain;
        Destroy();
    }
    // Find nearest player if multiple are close-by.
	lowestDist = 1024;

	foreach VisibleActors(class'DeusExPlayer', P, 100){
		if(P != None && !P.IsInState('Dying') && P.Health > 0){
			if(vSize(P.Location - Location) < lowestDist){
				winP = P;
				lowestDist = vSize(P.Location - Location);
			}
		}
	}

    // We have a winner, give it to them.
	if(winP != None)
		Capture(winp);
	
}

function CheckWin(DeusExPlayer winner){
    if(DeusExMPGame(Level.Game).VictoryCondition ~= "frags" && winner.PlayerReplicationInfo.score > DeusExMPGame(Level.Game).ScoreToWin){
        DeusExMPGame(Level.Game).PreGameOver();
        if(DeathMatchGame(Level.Game)!=None) DeathMatchGame(Level.Game).PlayerHasWon( Winner, Victim, Victim, " [Kill Confirmed]" );
        if(TeamDMGame(Level.Game)!=None) TeamDMGame(Level.Game).TeamHasWon( Winner.PlayerReplicationInfo.Team, Winner, Victim, " [Kill Confirmed]" );
        DeusExMPGame(Level.Game).GameOver();
    }
}

function Capture(DeusExPlayer winner){
    bTaken = True;
    if(winner == victim){
        BroadcastMessage("|Cffd700"$GetName(winner)@"has denied their death by "$GetName(killer)$".");
        winner.PlayerReplicationInfo.Score += ScoreGainDeny;

    } else if(winner == killer){
        BroadcastMessage("|Cadff2f"$GetName(winner)@"has confirmed their kill of "$GetName(victim)$".");
        victim.PlayerReplicationInfo.Deaths += 1;
        winner.PlayerReplicationInfo.Score += BaseScoreGain;

    } else if(Level.Game.bTeamGame) {
        if(winner.PlayerReplicationInfo.Team == victim.PlayerReplicationInfo.Team) {
            BroadcastMessage("|Cadff2f"$GetName(winner)@"has confirmed their teammate ("$GetName(Killer)$")'s kill of "@GetName(victim)@".");
            victim.PlayerReplicationInfo.Deaths += 1;
            winner.PlayerReplicationInfo.Score += BaseScoreGain;
        } else {
            BroadcastMessage("|Cffd700"$GetName(winner)@"has denied their teammate ("$GetName(victim)$")'s death by "@GetName(killer)@".");
            winner.PlayerReplicationInfo.Score += ScoreGainDeny;
        }
    } else {
        BroadcastMessage("|Ccd5c5c"$GetName(winner)@"has stolen "$GetName(killer)$"'s kill of "$GetName(victim)$".");
        victim.PlayerReplicationInfo.Deaths += 1;
        winner.PlayerReplicationInfo.Score += ScoreGainSteal;
    }
    CheckWin(winner);
    Destroy();
}

function string GetName(DeusExPlayer p){return p.PlayerReplicationInfo.PlayerName;}

defaultproperties
{
     ScoreGainSteal=2
     ScoreGainDeny=1
     BaseScoreGain=3
     bInvincible=True
     HitPoints=100
     ItemName="Confirm Kill"
     bPushable=False
     bHighlight=False
     LightBrightness=100
     Physics=PHYS_Rotating
     Lighttype=LT_Steady
     LightRadius=10
     Ambientglow=255
     LightSaturation=255
	 Drawscale=0.50
	 Fatness=140
	 style=sty_translucent
	 bBlockPlayers=False
	 DrawType=DT_Mesh
	 Mesh=Mesh'DXLogo'
     CollisionRadius=5.000000
     CollisionHeight=1.000000
     bFixedRotationDir=True
     RotationRate=(Yaw=8192)
}
