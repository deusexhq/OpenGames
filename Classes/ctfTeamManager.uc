class ctfTeamManager extends Actor config(OpenGames);

var int TeamID;
var ctfFlag myFlag;
var() config float CaptureDistance;
var() config int FlagCaptureScore;
var ctfBasePlatform BasePlatform, BasePlatform2;

var int Loops;
var bool bSetupBase;


function Timer(){
    local ctfFlag P, winP;
    local DeusExPlayer dxp;
	local vector dist;
	local float lowestDist;
	local vector Loc;
	Loops++;
	
	if(loops > 2 && !bSetupBase){
        loc = Location;
        loc.z -= 75;
        BasePlatform = Spawn(class'ctfBasePlatform',,,loc);
        BasePlatform2 = Spawn(class'ctfBasePlatform',,,loc);
        if(BasePlatform != None){
            BasePlatform.SetPhysics(PHYS_Rotating);
            BasePlatform.bFixedRotationDir = True;
            BasePlatform.rotationRate.Yaw = 8192;
        }
        
        if(BasePlatform2 != None){
            BasePlatform2.SetPhysics(PHYS_Rotating);
            BasePlatform2.bFixedRotationDir = True;
            BasePlatform2.rotationRate.Yaw = -8192;
        }
        bSetupBase = True;
	}
	
	lowestDist = CaptureDistance;

	foreach VisibleActors(class'ctfFlag', P, CaptureDistance){
		if(P != None && P.TeamID != TeamID){
			if(vSize(P.Location - Location) < lowestDist){
				winP = P;
				lowestDist = vSize(P.Location - Location);
			}
		}
	}

    // We have a winner, give it to them.
	if(winP != None && winP.lastFrobber != None && winP.lastFrobber.PlayerReplicationInfo.Team != winP.TeamID)
		Capture(winp);
		
    if(myFlag == None){
        Log("Spawning Flag "$TeamID, 'CTF');
        myFlag = Spawn(class'ctfFlag',,,Location);
        myFlag.TeamID = TeamID;
        //Log(TeamID$" "$myFlag.TeamID);
        myFlag.ctfManager = self;
        if(TeamID == 0) myFlag.Skin = Texture'FlagPoleTex4';
        if(TeamID == 1) myFlag.Skin = Texture'FlagPoleTex1';
    }
}

function CheckWin(DeusExPlayer winner){
    Log(TeamDMGame(Level.Game).TeamScore[winner.PlayerReplicationInfo.Team]$" "$DeusExMPGame(Level.Game).ScoreToWin);
    if(DeusExMPGame(Level.Game).VictoryCondition ~= "frags" && TeamDMGame(Level.Game).TeamScore[winner.PlayerReplicationInfo.Team] >= DeusExMPGame(Level.Game).ScoreToWin){
        DeusExMPGame(Level.Game).PreGameOver();
        //if(DeathMatchGame(Level.Game)!=None) DeathMatchGame(Level.Game).PlayerHasWon( Winner, Winner, None, " ["$GetName(Winner)$" captured the winning flag]" );
        TeamDMGame(Level.Game).TeamHasWon( Winner.PlayerReplicationInfo.Team, Winner, None, " ["$GetName(Winner)$" captured the winning flag]" );
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

function Destroyed(){
	if ( myFlag != None ){
		myFlag.ctfManager = None;
        myFlag.Destroy();
    }
    
    if(BasePlatform != None) BasePlatform.Destroy();
    if(BasePlatform2 != None) BasePlatform2.Destroy();
	Super.Destroyed();
}

/*    DrawType=DT_Mesh
    Texture=Texture'DeusExDeco.Skins.DXLogoTex1'
	theMesh=Mesh'DXLogo'
	LightEffect=LE_Disco
	*/
	
defaultproperties
{
    bStatic=False
    FlagCaptureScore=5
    CaptureDistance=150.0
    LightType=LT_Steady
    LightBrightness=255
    LightSaturation=50
    LightRadius=40
    Drawscale=0.7
    bHidden=False
    Physics=PHYS_Rotating
    bFixedRotationDir=True
    RotationRate=(Yaw=8192)
}
