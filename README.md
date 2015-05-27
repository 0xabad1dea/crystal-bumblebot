# Bumblebot

Bumblebot is an artificial friend who plays Pokemon Crystal. Bumblebot is not a speedrun bot. She's the exact opposite
of a speedrun bot, really. She means well.

## Alpha

As of writing this readme, Bumblebot can pick random locations and attempt to reach them, will attempt to interact with
objects, and can TPP-spam her way through battles.
She does not yet have sufficient infrastructure to run the game's story.

## How to run Bumble

You need a copy of an English Pokemon Crystal rom, and the [bizhawk](http://tasvideos.org/BizHawk.html) emulator for Windows.
At any point after booting the game, go to Tools->Lua Console, and from the resulting window, click the folder icon to open,
and then choose `main.lua` from the folder containing Bumblebot. She should start automatically from any point.

In the text entry box of the Lua console, you can enter `human = true` to disable any button pressing on Bumblebot's part,
and `human = false` to resume her routing.

## Warning

I consider this repository a personal art project and while you of course may fork it, patches as a general rule are not
being sought.

In particular I am extremely uninterested in anything that boils down to "I wanted to show off that I know that your Lua
is not 100% perfectly idiomatic or 100% perfectly efficient." This behavior will result in blocks, bans, and bees. _Bees._
