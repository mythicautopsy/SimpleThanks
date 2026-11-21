# SimpleThanks

A small, no-fuss addon for **WoW Forever** that thanks players who buff you. Someone gives you a buff, SimpleThanks says thanks for you: with the `/thank` emote, your own custom emote, or a whisper.

Inspired by ThanksForTheBuff and Manners, but deliberately simpler: one options window, a handful of settings, nothing else.

## Features

- **Three ways to say thanks**
  - The standard `/thank` emote, aimed at the player who buffed you
  - A custom emote with your own text
  - A whisper with your own text
- **Your own message**: use `%n` for the player's name and `%s` for the buff's name. Example: `Thanks for the %s, %n!`
- **Cooldown per player** (default 60 seconds), so a player who keeps rebuffing you doesn't get spammed
- **Ignore short buffs** (default: anything under 60 seconds), so heals and quick procs don't trigger a thank-you
- **Ignore party/raid members** if you only want to thank strangers
- **Private chat note** showing who buffed you with what (only you see it)
- **Options window** with a Test button and a Defaults button

## Commands

| Command | What it does |
|---|---|
| `/simplethanks` or `/stb` | Open or close the options window |
| `/stb on` | Turn auto-thanks on |
| `/stb off` | Turn auto-thanks off |

You can also open the options from **Esc → Options → AddOns → SimpleThanks**, or from the addon button on the minimap.

## Install

1. Download the zip and unzip it into `World of Warcraft\_forever_\Interface\AddOns\`, so you end up with `...\AddOns\SimpleThanks\SimpleThanks.toc`.
2. **Fully quit and restart the game.** A `/reload` is not enough the first time, because the game only reads new addon folders on startup.
3. Type `/stb` to open the options.

## Known issues

- **No thanks during combat.** WoW Forever uses the modern addon rules, which hide buff details from addons while you're in combat. Buffs you receive mid-fight are skipped. Most buffs are handed out between pulls, so this rarely matters.
- **No /say option.** The game only lets addons post in /say outdoors in response to a key press or click, so automatic /say messages aren't possible. Emotes and whispers work everywhere.
- The `/thank` emote targets the buffer by their unit. If they've already moved out of range the emote may go out without a name; the custom emote and whisper options always include the name.

## Author

mythicautopsy – The Monsoon Brigade @ Alliance PVE

Source and issues: https://github.com/mythicautopsy/SimpleThanks

Licensed under the MIT License.
