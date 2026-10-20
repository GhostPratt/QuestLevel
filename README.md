# QuestLevel

A tiny addon for WoW 3.3.5a (ChromieCraft) that shows each quest's level in the quest log.

Every quest in the log list is displayed as `[72] Quest Name` instead of just `Quest Name`.
Headers (zone names) are untouched, and the existing difficulty coloring, `(Complete)` /
`(Daily)` tags and tracking check marks keep working.

## Commands

- `/questlevel` or `/ql` — toggle the level prefix on or off (saved between sessions).

## How it works

It hooks Blizzard's `QuestLog_Update` and rewrites the title text of each list button,
then calls Blizzard's own `QuestLogTitleButton_Resize` so the text fits the row. If the
game's colorblind mode is on, Blizzard already adds the same prefix, so the addon steps
aside to avoid showing the level twice.
