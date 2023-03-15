class agentsMenuProxy extends Actor;

var GMAgents Host;
var agentsMenu acm;
var agentsClass agentsList[32];

replication
{      
	reliable if (!bDemoRecording && (Role == ROLE_Authority))
		OpenClassMenu, agentsList, ApplyClass;
}

simulated function ApplyClass(DeusExPlayer P, int Index){
    Host.ApplyClass(P, Index);
}

simulated final function OpenClassMenu(){
	local DeusExRootWindow W;

	W = DeusExRootWindow(DeusExPlayer(Owner).RootWindow);
	if (W != None)	{
		acm = agentsMenu(W.InvokeMenuScreen(Class'agentsMenu', true));
		if (acm != None) {
            acm.Host = Self;
            acm.RefreshAgentsList();
        }
	}
}

