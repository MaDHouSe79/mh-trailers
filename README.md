<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
  <a href="https://github.com/MaDHouSe79/mh-trailers/issues">
    <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-trailers"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-trailers/watchers">
    <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-trailers"/> 
  </a> 
  <a href="https://github.com/MaDHouSe79/mh-trailers/network/members">
    <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-trailers"/> 
  </a>  
  <a href="https://github.com/MaDHouSe79/mh-trailers/stargazers">
    <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-trailers?color=white"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-trailers/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/MaDHouSe79/mh-trailers?color=black"/> 
  </a>      
</p>

<p align="center">
  <img alig src="https://github-profile-trophy.vercel.app/?username=MaDHouSe79&margin-w=15&column=6" />
</p>

# My Youtube Channel and Discord
- [Subscribe](https://www.youtube.com/c/@MaDHouSe79) 
- [Discord](https://discord.gg/vJ9EukCmJQ)

# MH-Trailers (QB/ESX)
- Support QB/ESX Framework
- Transport all your vehicles with trailers. 
- Trailer rent shop build in.

## QB Dependencies
- qb-target
- qb-input

## ESX Dependencies
- ox_lib
- ox_target

# Support (QB/ESX)
- ox_lib
- ox_target

## 🎥 Video 👊😁👍
[Watch the video](https://www.youtube.com/watch?v=D1MGNhh1p8E)

# NOTE fxmanifest.lua
- don't forget to edit `fxmanifest.lua` to your server needs.

# ESX fxmanifest.lua
```conf
shared_scripts {
    '@es_extended/imports.lua', -- only if you use esx framework
    '@ox_lib/init.lua',         -- only if you use ex_lib
    'core/mconfig.lua',
    'core/locale.lua',
    'core/vehicles.lua',
    'locales/*.lua',
    'config.lua',
}
```

# QBCore fxmanifest.lua
```conf
shared_scripts {
    --'@es_extended/imports.lua', -- only if you use esx framework
    '@ox_lib/init.lua',         -- only if you use ex_lib
    'core/mconfig.lua',
    'core/locale.lua',
    'core/vehicles.lua',
    'locales/*.lua',
    'config.lua',
}
```

# QBX fxmanifest.lua
```conf
shared_scripts {
    --'@es_extended/imports.lua', -- only if you use esx framework
    '@ox_lib/init.lua',         -- only if you use ex_lib
    'core/mconfig.lua',
    'core/locale.lua',
    'core/vehicles.lua',
    'locales/*.lua',
    'config.lua',
}
```

# QB/QBX Server.cfg
```conf
ensure mapmanager
ensure chat
ensure spawnmanager
ensure sessionmanager
ensure basic-gamemode
ensure hardcap
ensure baseevents
ensure oxmysql

ensure ox_lib

# QBCore & Extra stuff
ensure qb-core
ensure [qb]

ensure ox_target

ensure [standalone]
ensure [voice]
ensure [defaultmaps]

ensure mh-trailers
```

# ESX Server.cfg
```conf
ensure chat
ensure spawnmanager
ensure hardcap
ensure oxmysql
ensure bob74_ipl

ensure ox_lib
# ESX Legacy Core
# ----------
ensure [core]

# ESX Addons
# ----------
ensure PolyZone
ensure mh-trailers

ensure [standalone]
ensure [esx_addons]

# Additional Resource
# -------------------
ensure pma-voice
```

# How it works
- Everyting works with the target eye.
- First you look with target to the trailer, then you get a few options, 
- fist use ramp down than use platform down, you can now put vehicles on the top of this platform, 
- then you lock the vehicles by looking to the trailer and use again the target, and then you can raise the platform.
- With this the all top vehicles will be locked automaticly.
- When you have raised the top platform, you can then use the lower platform.
- which it in this order and it should work fine.

# My trailers does not work
- Make sure you add the right trailer hash key in the config file
- same for the vehicles
- make sure all settings in the config are correct.

# NOTE for ignore vehicles.
- What this does is, it ignore the vehicle you tow the trailer with,
- if you don't add this vehicle hash in the ignore vehicle in the config file things does wrong and the truck will also be stuck on the trailer,
- so don't forget this part cause i'm not going to help you fixing your issues if you don't read this file.

# Adding new trailers
- Make sure you add all settings in the config file correctly.
- cause i'm not going to help adding more trailers, cause it's not that hard to do.

# Trailers does not spawn for esx
- you need to add the trailers in the vehicles table in your database before it can spawn.
```sql
INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES ('tr2', "tr2", 200000, 'trailers');
INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES ('trailersmall', "trailersmall", 100000, 'trailers');
INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES ('boattrailer', "boattrailer", 10000, 'trailers');
INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES ('trflat', "trflat", 200000, 'trailers');
INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES ('pjtrailer', "pjtrailer", 200000, 'trailers');
```

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
