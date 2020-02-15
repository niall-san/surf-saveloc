# surf-saveloc
Sourcemod plugin to help with surf/bhop practice. Allows for saving location with velocity and replaying. Multiple locations can be saved, and all locations can be accessed by everyone, much like KSF's system.
Based on horsefeathers' [tm-saveloc](https://ksfclan.com/forum/showthread.php?4174-saveloc-plugin-(SourceMod)).

## Commands
```
sm_saveloc
sm_tele <location num>
```

## ConVars - config file in `cfg/sourcemod/`
* `saveloc_maxlocations` - Maximum number of save locations. Set to -1 to disable limit and 0 to disable saveloc entirely.
* `saveloc_chattat` - Tag to use before all output in chat.
