//=============================================================================
// FlagPole.
//=============================================================================
class ctfFlag extends DeusExDecoration config (OpenGames);

var int Ctr;
var int TeamID;
var() config int RespawnSeconds, MaxTimeAway;
var int TimeAway;
var Vector lastLocation;
var DeusExPlayer lastFrobber;
var DeusExPlayer CarriedBy;
var() config int senseRadius;

var ctfTeamManager ctfManager;

function PostBeginPlay(){
    SetTimer(1, True);
    super.PostBeginPlay();
}

function Drop(vector newVel){
    bPushable = False;
    CarriedBy = None;
    super.Drop(newVel);
}

function Landed(vector HitNormal){
    bPushable = False;
    CarriedBy = None;
    super.Landed(HitNormal);
}

function GiveToPlayer(DeusExPlayer P){
    lastFrobber = p;
    if(P.PlayerReplicationInfo.Team != TeamID) p.ClientMessage("Take the flag to your base!");
    if(P.PlayerReplicationInfo.Team == TeamID) p.ClientMessage("Protect the flag!");
    bPushable=True;
    P.PutInHand(None);
    CarriedBy = p;
    P.GrabDecoration();
}

function Frob(Actor Frobber, Inventory frobWith) {
    local DeusExPlayer p;

    p = DeusExPlayer(Frobber);
    if(p != None) {
        GiveToPlayer(p);
    }
    super.Frob(Frobber, frobWith);
}

function DeusExPlayer NearPlayer(){
    local DeusExPlayer tm;
    foreach VisibleActors(class'DeusExPlayer', tm, senseRadius){
        return tm;
    }

    return None;
}

function bool NearHome(){
    local ctfTeamManager tm;
    foreach VisibleActors(class'ctfTeamManager', tm, senseRadius){
        if(tm.TeamID == TeamID) return True;
    }

    return False;
}

function Timer(){
    local DeusExPlayer nearby;
    
    if(NearHome() && TimeAway > 0) TimeAway = 0;
    
    if(!NearHome()){
        TimeAway++;
        if(TimeAway >= MaxTimeAway){
            Log("Flag "$TeamID$" moved back home.", 'CTF');
            BroadcastMessage("|Cdaa520Flag "$TeamID$" has respawned.");
            Destroy();
        }
    }
    
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

    /*if(CarriedBy != None) return;

    nearby = NearPlayer();

    if(nearby != None){
        if(nearby.PlayerReplicationInfo.Team == TeamID && !NearHome()){
            SetLocation(Location + (nearby.CollisionRadius+Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15);
            GiveToPlayer(nearby);
        }

        if(nearby.PlayerReplicationInfo.Team != TeamID){
            SetLocation(Location + (nearby.CollisionRadius+Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15);
            GiveToPlayer(nearby);
        }
    }*/
}

function Bump( actor Other ){
    local DeusExPlayer P;

    if(CarriedBy != None) return;

    P = DeusExPlayer(Other);

    if(P != None){
        GiveToPlayer(P);
    }
}

function Destroyed(){
	if ( ctfManager != None )
		ctfManager.myFlag = None;

	Super.Destroyed();
}


defaultproperties
{
     RespawnSeconds=10
     senseRadius=150
     FragType=Class'DeusEx.WoodFragment'
     ItemName="Flag"
     bInvincible=True
     Mesh=LodMesh'DeusExDeco.FlagPole'
     CollisionRadius=17.000000
     CollisionHeight=56.389999
     Mass=40.000000
     Buoyancy=30.000000
     bPushable=False
     MaxTimeAway=120
}
