# K Auctions

## ⚠️This is an experimental addon and is a heavy work in progress

This addon is still in its infancy and under active development. Right now, it's a bare bones placeholder. It's enough to prove the concept and get the update pipeline flowing, but over time, it will evolve into a fully featured tool that:

*   Pulls live auction house data for multiple realms
*   Builds an in game price database
*   Delivers dynamic configuration to fine tune how data is displayed in your UI

What to Expect Now

*   Limited or placeholder functionality
*   Rapid updates as core systems are implemented
*   Features may appear, break, or change without warning

What's Coming Later

*   Smarter auction price tracking
*   More customization for data views
*   Polished UI integration

If you enjoy testing bleeding‑edge builds and don't mind the occasional rough edge, your feedback now can help shape the final experience.

***

## 📦 Installing

This addon is currently in the experimental stage and requires manual setup. Please follow these steps exactly to ensure it installs and updates correctly.


### 1. Download the Addon

If you are viewing this page on the **CurseForge website**, click the **Download** button in the top‑right of this page.


### 2. Extract and Copy

1.  Open (or extract) the downloaded ZIP file.
2.  Inside, locate the folder named `KAuctions`
3.  Copy this entire folder to your World of Warcraft addons directory. On a default Windows installation, that folder is located at:

```
C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns
```

If you installed WoW in a custom location, navigate to that directory instead.

**Note:** If you’re unsure where your AddOns folder is, open the CurseForge app, go to your **World of Warcraft** mods list, click the ⋯ menu in the top‑right, and choose **"Open AddOns Folder."** This will open the folder location directly in your file browser.


### 3. Verify Folder Structure

After copying the folder in the zip to your addons folder, the addons folder layout should look like this:

```
C:\
└── Program Files (x86)\
    └── World of Warcraft\
        └── _retail_\
            └── Interface\
                └── AddOns\
                    ├── KAuctions\
                    │   ├── KAuctions.toc
                    │   ├── (other KAuctions addon files)
                    ├── Details\
                    │   ├── Details.toc
                    │   └── (other Details addon files)
                    ├── WeakAuras\
                    │   ├── WeakAuras.toc
                    │   └── (other WeakAuras addon files)
                    └── (other addon folders)
```


### 4. Scan for Addons in CurseForge

Open the CurseForge app, go to your World of Warcraft mods list, click the ⋯ menu in the top‑right, and choose "Scan addons folder." When asked, confirm that you would like to proceed with the scan.

Wait a few moments until the scan completes. It'll give you a small notification at the bottom of the app.


### 5. Confirm Detection

Check that **KAuctions** now appears in your addon list.  
**⚠️ If you skip this step, the addon will not be updateable and your auction data will become outdated.**


### 6. Launch WoW

Start (or restart) WoW. If you're already in game, you can also just `/reload` your UI or log out and back in.

Then hover over any item that can be sold on the auction house to verify that auction prices are showing.