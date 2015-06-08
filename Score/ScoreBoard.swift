
import Foundation
import SpriteKit
import MultipeerConnectivity


public class ScoreBoard {
  /*
  Responsibility:
  - show scores
  - understand different formats for GameMode
  - own gameClock and highScore
  
  */
  
  var delegate : SKScene!
  var view : SKLabelNode!
  var gameLimitScore : Int!
  var gameClock : GameClock!
  let highScore = HighScore()
  let playerManager : PlayerManager!
  let scorePrefix = ""  // No prefix label on view
  
  public init(delegate: SKScene,
      myMCPeerID: MCPeerID,
      gameLimitScore: Int
    ) {
    println("init scoreboard")
    self.delegate = delegate
    
    playerManager = PlayerManager(maxPlayers: 2, myMCPeerID: myMCPeerID)
    self.gameLimitScore = gameLimitScore
    findView(delegate)  // view must precede addPlayer
    assert(view != nil)
    self.gameClock = GameClock(view: self.view)  // not plugged in or reset
  }
  
  private func initClockSprite() {
    gameClock.pluginToScene(self.delegate)
    // Don't reset until startp playing: continue to show previous score
    // gameClock.reset()
    gameClock.stop()
  }
  
  
  
  // MARK: GameMode
  
  public var isSolitary : Bool {
      let result = playerManager.isSinglePlayer
      println("isSolitary \(result)")
      return result
  }
  public var isScoreByCount: Bool { return !isSolitary }
  
  //public var isFoo: Bool { return true }
  //public var isTwoPlayerCooperative: Bool { return false }
  // TODO: future: two players cooperative use clock
  

  
  // MARK: state changes of the game
  
  public func toScoring() {
    // Round ended on this side, waiting for faults and judge.
    // Only necessary for solitaire: stop clock
    gameClock.stop()
  }
  public func toScoringReceived() {
    // Other side  (opponent) has decided to start scoring
    // TODO: currently gameClock not used for two-player cooperative
  }
  
  public func endScoring() {
    // Judge finished scoring, round is reset but not started
  }
  
  public func toPlaying() {
    // New round started
    // clock used for solitaire
    gameClock.reset()
    gameClock.startOrContinue()
  }
  
  
  // MARK: two-player score change while playing
  
  public func addScore(amount: Int, gameRole: GameRole) {
    playerManager.players[gameRole]!.addScore(amount)
    updateView()
  }

  
  public func resetScores() {
    /*
    This knows what a score is for different gameModes.
    The clock is 'score' for Solitary or 2-player cooperative.
    2-player cooperative uses player's scores.
    */
    println("Scoreboard.resetScores()")
    
    // Reset player scores even for solitary, doesn't hurt
    for (name, player) in playerManager.players {
      player.reset()
    }
    
    if isSolitary {
      self.initClockSprite()
      // Game clock doesn't start until first touch
    }
    else {
      gameClock.unPlug(self.delegate)
    }
    
    updateView()
  }
  
  public var gameEndingRoleByCount : GameRole? {
    /*
    If game over, losing GameRole, else game not over return nil.
    */
    assert(!isSolitary, "solitary scored by time")
    var result : GameRole?
    
    /*
    Iteration over players.
    TODO: for multiplayer, this should return the player, since all players would have same gameRole.
    Assert that even for multiplayer, at most one player is score against and exceeds gameLimit.
    Assuming there are not two faults at exact same NSTimeInterval.
    */
    for (role, player) in playerManager.players {
      if player.score >= gameLimitScore {
        result = role
        break
      }
    }
    return result
  }
  
  
  // MARK: view
  
  private func findView(delegate: SKScene) {
    // find score view within delegate
    // fails hard if view not exist in sks
    view = delegate.childNodeWithName("scoreboard") as! SKLabelNode
  }
  
  
  private func updateView() {
    // Update view of model.  Depends on GameMode
    var text = ""
    if isScoreByCount {
      text = scoreTextFromCounts
    }
    else {
      text = formattedGameTime
    }
    view.text = text
  }
  
  
  private var scoreTextFromCounts : String {
    /*
    Simple concatenation of score value
    Score with self first, canonical real world way of saying score without naming players.
    i.e. 0-0 instead of Home 0 Visitor 0
    */
    
    var scoreString = ""
    if playerManager.isSinglePlayer { // Can't call game.isSolitary yet???
      scoreString = scorePrefix + String(playerManager.players[.me]!.score)
    }
    else {
      scoreString = scorePrefix + String(playerManager.players[.me]!.score) + " " + String(playerManager.players[.opponent]!.score)
    }
    return scoreString
  }
  
  
  
  // MARK: delegation to gameClock and highScore
  // GameClock is only object to know how to format times
  
  public var formattedHighScore : String { return gameClock.formattedTimeInterval(highScore.recordTimeSolitary) }
  public var formattedGameTime : String { return gameClock.formattedGameTime }
  public func formattedTimeInterval(timeInterval: NSTimeInterval) -> String { return gameClock.formattedTimeInterval(timeInterval) }
  
  public func checkAndRecordTimeRecordSet() -> Bool {
    return highScore.checkAndRecordTimeRecordSet(gameClock.timeInterval())
  }
  
  // MARK: delegation to PlayerManager
  // Adding or deleting a player resets scores, game must restart
  public func addPlayer(peer: MCPeerID) {
    playerManager.addPlayer(peer)
    resetScores()
  }
  public func deletePlayer(peer: MCPeerID) {
    playerManager.deletePlayer(peer)
    resetScores()
  }
  public func existsPlayer(peer: MCPeerID) -> Bool { return playerManager.existsPlayer(peer) }
  
}


