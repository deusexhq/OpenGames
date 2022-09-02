# OpenGames

## Install
Drop the files (OpenGames.u, OpenGames.int) in your servers /System folder.

Open your server config file (Usually DeusEx.ini), and find the DeusEx.DeusExGameEngine block.
At the bottom, add the following;
```
ServerPackages=OpenGames
ServerActors=OpenGames.GM
```

Once the server is running, you can change the current mode either in Advanced Options (Options > Open Games > GM) or as in-game commands (Mutate gm ctf/kc/omno/random/off)

## Kill Confirmed
### Gameplay
Killing the enemy doesn't give you score. Instead, it drops a symbol that you need to capture. But be quick, it can be stolen!

## CTF
### Setup
In a map that you want to be used for CTF, login as admin, and stand in the place that you want to be the base for either team, then use the command `mutate ctf.setteam0` or `mutate ctf.setteam1`.
Once both teams have a base, you can use `mutate ctf.enable` and restart the map.

### Gameplay
Normal scoring is disabled. Pickup the flag from the enemy base, run it to your base to score. Simple!