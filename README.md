# OpenCTF - Capture the Flag mutator

## Install
Drop the files (OpenCTF.u, OpenGames.int) in your servers /System folder.

Open your server config file (Usually DeusEx.ini), and find the DeusEx.DeusExGameEngine block.
At the bottom, add the following;
```
ServerPackages=OpenCTF
ServerActors=OpenCTF.ctf
```

## Setup
In a map that you want to be used for CTF, login as admin, and stand in the place that you want to be the base for either team, then use the command `mutate ctf.setteam0` or `mutate ctf.setteam1`.
Once both teams have a base, you can use `mutate ctf.enable` and restart the map.

## Gameplay
Normal scoring is disabled. Pickup the flag from the enemy base, run it to your base to score. Simple!