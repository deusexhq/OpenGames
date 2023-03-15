class agentsMenu extends MenuUIScreenWindow;

var MenuUIScrollAreaWindow winScroll;
var MenuUIListWindow lstClasses;
var agentsMenuProxy Host;


event InitWindow(){
    local Window W;

    Super.InitWindow();

    /*if (actionButtons[2].btn != None)
    if ((Player == None) || (Player.PlayerReplicationInfo == None) || !Player.PlayerReplicationInfo.bAdmin)
    actionButtons[2].btn.SetSensitivity(false);*/

    winClient.SetBackground(Texture'DeusExUI.MaskTexture');
    winClient.SetBackgroundStyle(DSTY_Modulated);

    W = winClient.NewChild(Class'Window');
    W.SetSize(ClientWidth, ClientHeight);
    W.SetBackground(Texture'DeusExUI.MaskTexture');
    W.SetBackgroundStyle(DSTY_Modulated);
    W.Lower();

    /*CreateLabel(8, 7, l_lmap);
    LeadingMap = CreateLabel(16, 20, "");
    LeadingMap.SetWidth(180);

    CreateLabel(236, 7, l_cvote);
    CurrentVote = CreateLabel(244, 20, "");
    CurrentVote.SetWidth(180);*/

    winScroll = CreateScrollAreaWindow(winClient);
    winScroll.SetPos(236, 40);
    winScroll.SetSize(196, 192);

    lstClasses = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
    lstClasses.EnableMultiSelect(false);
    lstClasses.EnableAutoExpandColumns(false);
    lstClasses.EnableAutoSort(false);
    lstClasses.SetNumColumns(2);
    lstClasses.SetColumnType(0, COLTYPE_String);
    lstClasses.SetColumnType(1, COLTYPE_String);
    lstClasses.SetSortColumn(0, false, false);  //case insensitive
    lstClasses.SetColumnWidth(0, 180);
    lstClasses.HideColumn(1);

    bTickEnabled = true;
}


final function MenuUISmallLabelWindow CreateLabel(int X, int Y, string S){
    local MenuUISmallLabelWindow W;

    W = MenuUISmallLabelWindow(winClient.NewChild(Class'MenuUISmallLabelWindow'));
    W.SetPos(X, Y);
    W.SetText(S);
    W.SetWordWrap(false);

    return W;
}

/*
//do not change this cleanup code
event DestroyWindow()
{
bTickEnabled = false;

Player = DeusExPlayer(GetPlayerPawn());
if ((Player != None) && !Player.bDeleteMe)
 {
 if (ViewPort(Player.Player) != None)
  {
  Player.ClientMessage(l_help1);
  Player.ClientMessage(l_help2);
  }
 foreach Player.allactors(class'DXL', PlayerVote)
  if (PlayerVote.Owner == Player)
   PlayerVote.MVM = None;
 }

PlayerVote = None;
Super.DestroyWindow();
}*/


function RefreshAgentsList(){
    local int I, C;

    lstClasses.DeleteAllRows();
    
    for (I = 0; I < 32; I++){
        if (Host.agentsList[I] != None) {
            Log(Host.agentsList[I], 'Agents');
            lstClasses.AddRow(Host.agentsList[I] $ ";" $ I);
            C++;
        }
    }
    
    //if (C > 0) lstClasses.Sort();

}


event bool ListRowActivated(window W, int R)
{
    if ((W == lstClasses)) {
        Host.ApplyClass(DeusExPlayer(GetPlayerPawn()), int(lstClasses.GetField(R, 1)));
        return true;
    }

    return Super.ListRowActivated(W, R);
}


event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat){
    if ((key == IK_Enter) && (iState == IST_Release))   {
        root.PopWindow();
        return True;
    }

    return Super.RawKeyPressed(key, iState, bRepeat);
}

/*
function ProcessAction(String S)
{
    Super.ProcessAction(S);
    if (S == "NOVOTE")
    {
    PlayerVote.ClientSetVote(-1);
    CurrentVote.SetText("");
    }
    else if (S == "TRAVEL")
    {
    if (bListDone && (lstMaps.GetSelectedRow() != 0))
    {
    Player.SwitchLevel(lstMaps.GetField(lstMaps.GetSelectedRow(), 0));  //server checks for admin
    actionButtons[2].btn.SetSensitivity(false);
    }
    }
}*/


defaultproperties
{
bUsesHelpWindow=False
actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
Title="Agents Menu"
ClientWidth=440
ClientHeight=244
}
