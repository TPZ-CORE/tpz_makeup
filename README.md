# TPZ-CORE Makeup

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory : https://github.com/TPZ-CORE/tpz_inventory

# Installation

1. When opening the zip file, open `tpz_makeup-main` directory folder and inside there will be another directory folder which is called as `tpz_makeup`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_makeup` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.
   
# Known Bugs

1. Modifying makeup overlays and eyebrows resets the **Hair Overlays** for the female characters. By doing `reloadskin` command, the character eyebrows and hair overlays are fixed (Hair Overlays is not something important or used by many female characters, its very rare to be used eitherway).

2. There are sometimes that can destroy some makeup, groom or lifestyles when doing changes. By doing `reloadskin` command everything fixes but i have done many checks and attemps to avoid that (thats why you will see the face refreshing because the game-engine attempts to destroy them).
