# OpenGames

## Install
Drop the files (OpenGames.u, OpenGames.int) in your servers /System folder.

Open your server config file (Usually DeusEx.ini), and find the DeusEx.DeusExGameEngine block.
At the bottom, add the following;
```
ServerPackages=OpenGames
ServerActors=OpenGames.GM
```

Once the server is running, you can change the current mode either in Advanced Options (Options > Open Games > GM) or as in-game commands (Mutate gm ctf/kc/omni/random/off)

## Kill Confirmed
Killing the enemy doesn't give you score. Instead, it drops a symbol that you need to capture. But be quick, it can be stolen! If someone else takes your symbols, they steal your score.

## Omni
Enables both Time and Frags victory condition. Time condition is handled as normal (Highest score at end of time wins), but if a player reaches the Frags limit, they also win and the match ends.

## CTF
Normal scoring is disabled. Pickup the flag from the enemy base, run it to your base to score. Simple!

### Setup
#### Auto
If bFullAuto is enabled, and the map has not been set up yet, it will attempt to automatically generate bases based on distance from PlayerStarts, provided that there is at least two PlayerStarts that are far enough way from eachother. This generated placement is then saved to the config, and can be adjusted by admins as usual using the Manual setup commands below.

#### Manual
In a map that you want to be used for CTF, login as admin, and stand in the place that you want to be the base for either team, then use the command `mutate ctf.setteam0` or `mutate ctf.setteam1`.
Once both teams have a base, you can use `mutate ctf.enable` and restart the map.


## TODO
- [ ] CTF
    - [ ] Live testing
    - [ ] Aesthetics tweaking
- [ ] Omni
    - [ ] Testing
- [ ] KillConfirmed
    - [ ] Testing
- [ ] Big Gun(?) Mode (One OP weapon exists in the world, player that takes it and kills with it enough wins?)
    - [ ] A less shit name
    - [ ] Work on the rules
    - [ ] Start writing
