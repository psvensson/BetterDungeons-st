# BetterDungeons-st
A port of the Better Dungeons JS package to Smalltalk (https://github.com/slayerbeing/better-dungeons)

# Installing
If using Squeak, please install the Metacella package from Tools->Monticello Browser.
```Smalltalk
Metacello new
    repository: 'github://psvensson/Easystar-st:master';
    baseline: 'Easystar';
    load
```    
# Usage
```Smalltalk
| dungeon cells |
d := BetterDungeon new.
"Returns an Array with Points that represent the walls of the dungeon"
cells := d getMapCells.
```

