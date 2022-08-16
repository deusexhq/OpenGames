//=============================================================================
// FlagPole.
//=============================================================================
class ctfFlag extends DeusExDecoration config (OpenGames);

var int Ctr;
var int TeamID;
var() config int RespawnSeconds;
var Vector lastLocation;
var DeusExPlayer lastFrobber;

var ctfTeamManager ctfManager;

function PostBeginPlay(){
    SetTimer(1, True);
    super.PostBeginPlay();
}

function Drop(vector newVel){
    bPushable=False;
    super.Drop(newVel);
}

function Landed(vector HitNormal){
    bPushable=False;
    super.Landed(HitNormal);
}
function Frob(Actor Frobber, Inventory frobWith) {
    local DeusExPlayer p;

    p = DeusExPlayer(Frobber);
    if(p != None) {
        lastFrobber = p;
        if(P.PlayerReplicationInfo.Team != TeamID) p.ClientMessage("Take the flag to your base!");
        if(P.PlayerReplicationInfo.Team == TeamID) p.ClientMessage("Protect the flag!");
        bPushable=True;
        P.GrabDecoration();
    }
    super.Frob(Frobber, frobWith);
}

function bool NearHome(){
    local ctfTeamManager tm;
    foreach VisibleActors(class'ctfTeamManager', tm, 150){
        if(tm.TeamID == TeamID) return True;
    }

    return False;
}

function Timer(){
    if(Location == lastLocation && !NearHome()){
        Ctr += 1;
        Log("Flag "$TeamID$": "$Ctr, 'CTF');
        if(Ctr > RespawnSeconds){
            Log("Flag "$TeamID$" moved back home.", 'CTF');
            BroadcastMessage("|Cdaa520Flag "$TeamID$" has respawned.");
            Destroy();
        }
    }

    if(lastLocation != Location) Ctr = 0;


    lastLocation = Location;
}

function Destroyed(){
	if ( ctfManager != None )
		ctfManager.myFlag = None;

	Super.Destroyed();
}


defaultproperties
{
     RespawnSeconds=10
     FragType=Class'DeusEx.WoodFragment'
     ItemName="Flag"
     bInvincible=True
     Mesh=LodMesh'DeusExDeco.FlagPole'
     CollisionRadius=17.000000
     CollisionHeight=56.389999
     Mass=40.000000
     Buoyancy=30.000000
     bPushable=False
}
