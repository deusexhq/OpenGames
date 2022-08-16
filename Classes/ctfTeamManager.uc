class ctfTeamManager extends Actor config(OpenGames);

var int TeamID;
var ctfFlag myFlag;
var() config float CaptureDistance;
var() config int FlagCaptureScore;

function Timer(){
    local ctfFlag P, winP;
    local DeusExPlayer dxp;
	local vector dist;
	local float lowestDist;
	lowestDist = CaptureDistance;

    foreach VisibleActors(class'DeusExPlayer', dxp, 50){
        if(dxp.PlayerReplicationInfo.Team == TeamID) dxp.ClientMessage("This is your base.");
        if(dxp.PlayerReplicationInfo.Team != TeamID) dxp.ClientMessage("This is the enemy base.");
    }

	foreach VisibleActors(class'ctfFlag', P, CaptureDistance){
		if(P != None && P.TeamID != TeamID){
			if(vSize(P.Location - Location) < lowestDist){
				winP = P;
				lowestDist = vSize(P.Location - Location);
			}
		}
	}

    // We have a winner, give it to them.
	if(winP != None)
		Capture(winp);

    if(myFlag == None){
        Log("Spawning Flag "$TeamID, 'CTF');
        myFlag = Spawn(class'ctfFlag',,,Location);
        myFlag.TeamID = TeamID;
        Log(TeamID$" "$myFlag.TeamID);
        myFlag.ctfManager = self;
        if(TeamID == 0) myFlag.Skin = Texture'FlagPoleTex4';
        if(TeamID == 1) myFlag.Skin = Texture'FlagPoleTex1';
    }
}

function CheckWin(DeusExPlayer winner){
    if(DeusExMPGame(Level.Game).VictoryCondition ~= "frags" && winner.PlayerReplicationInfo.score > DeusExMPGame(Level.Game).ScoreToWin){
        DeusExMPGame(Level.Game).PreGameOver();
        if(DeathMatchGame(Level.Game)!=None) DeathMatchGame(Level.Game).PlayerHasWon( Winner, Winner, None, " [Capture the Flag]" );
        if(TeamDMGame(Level.Game)!=None) TeamDMGame(Level.Game).TeamHasWon( Winner.PlayerReplicationInfo.Team, Winner, None, " [Capture the Flag]" );
        DeusExMPGame(Level.Game).GameOver();
    }
}

function Capture(ctfFlag flagWinner){
    local DeusExPlayer winp;

    Log("Base "$TeamID$" captured Flag "$flagWinner.TeamID);
    winp = flagWinner.lastFrobber;

    // We have a winner, give it to them.
	if(winP != None){
        SayToTeam(TeamID, "|C32cd32"$GetName(winP)$" captured the flag for your team!");
        SayToEnemyTeam(TeamID, "|C32cd32"$GetName(winP)$" captured your flag for the enemy!");
		winP.PlayerReplicationInfo.Score += FlagCaptureScore;
        CheckWin(winP);
    } else {
        BroadcastMessage("No player to earn the score.");
    }
    flagWinner.Destroy();
}

function SayToTeam(int TeamNum, string Msg){
    local DeusExPlayer p;

    foreach AllActors(class'DeusExPlayer', p){
        if(p.PlayerReplicationInfo.Team == TeamNum) {
            p.ClientMessage(msg, 'TeamSay');
        }
    }
}

function SayToEnemyTeam(int TeamNum, string Msg){
    local DeusExPlayer p;

    foreach AllActors(class'DeusExPlayer', p){
        if(p.PlayerReplicationInfo.Team != TeamNum) {
            p.ClientMessage(msg, 'TeamSay');
        }
    }
}
function string GetName(DeusExPlayer p){return p.PlayerReplicationInfo.PlayerName;}

defaultproperties
{
    FlagCaptureScore=5
    CaptureDistance=150.0
    LightEffect=LE_Disco
    LightBrightness=255
    LightSaturation=50
    LightRadius=20
    DrawType=DT_Mesh
	Mesh=Mesh'DXLogo'
    Drawscale=0.5
    bHidden=False
    Physics=PHYS_Rotating
}