# SimpleThanks

Shared WoW Forever rules: ../CLAUDE.md (if present locally).

Thanks players who buff you: `/thank` emote, custom emote, or whisper.
Deliberately simple: one options window, a handful of settings.

## Files
- `Core.lua` — defaults (`ns.defaults`), UNIT_AURA watching, thank logic, slash.
- `Options.lua` — options window (built on first open) and Settings panel entry.
- `CHANGELOG.md` — shipped via `.pkgmeta` `manual-changelog`. Add an entry for
  every release: `## x.y.z (YYYY-MM-DD)` then bullets.

## SavedVariables `SimpleThanksDB`
- Keys mirror `ns.defaults`: enabled, mode ("EMOTE"|"CUSTOM"|"WHISPER"),
  message (`%n` = player, `%s` = buff), cooldown (60), minDuration (60),
  ignoreGroup, printToChat. New settings go in `ns.defaults` first.

## Behaviour to keep
- No combat log on Forever: watch UNIT_AURA on the player, and do nothing in
  combat (aura data is secret there).
- Per-player cooldown in `lastThanked`; ignore buffs shorter than minDuration.
- Send chat via `C_ChatInfo.SendChatMessage` with fallback. No /say mode.
- Keep it simple: push back if a feature would add a second window or a
  settings maze.

## Slash: `/simplethanks`, `/stb` — toggles window; `on`, `off`.
