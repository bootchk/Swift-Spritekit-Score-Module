
ScoreBoard Swift Module

Copyright 2015 Lloyd Konneker

Released under MIT license.

A pure-Swift module for a scoreboard in SpriteKit game.
Game is solitary or two-player.
Solitary scoreboard is a game clock.
Two-player scoreboard is an int count for each player.
Scoreboard displays itself in an SKLabel in a delegate SKScene (often the game playing scene.)
Keeps a high score for solitary in NSUserDefaults.

Players identified by MCPeerID (it depends on MultipeerConnectivity, but you could modify for other methods of connecting to remote players, or even two-players on the same device.)

Gameclock is driven by ticks from the SKScene simulation.  When the SKView or SKScene is paused, the clock pauses.

Working, but not very general yet.  Example code.

To build, just open the .xcodeproj and choose Build.  Not very useful to build, it doesn't have any test harness or example app.

To incorporate into a project as a module:
1. add a target to your main project, choose "Cocoa Touch Framework", and enter name e.g. "Score".
Also choose to "Embed ..." the framework in your main app target.
Expect a "Score" group to be added to your project (and for various other automagic changes in your project configuration.)
2.  Add Files to the Score group of your project and choose the source code files from Score project download.
(You don't need to copy the files to your project, you can leave them where you downloaded them.)

To call, "import Score", instantiate a ScoreBoard object, and call the public API methods.
The public classes are ScoreBoard and GameRole.
