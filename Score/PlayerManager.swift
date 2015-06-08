
import Foundation
import MultipeerConnectivity


class PlayerManager {
  /*
  Manage dictionary of Player
  Invariant: includes self player
  
  Note distinction between connecteeRole (invitor or invitee) and gameRole (self or opponent)
  */
  
  var players = [GameRole : Player]()
  var isSinglePlayer : Bool { return players.count == 1 }
  var maxPlayers : Int
  var myMCPeerID: MCPeerID
  
  init(maxPlayers: Int, myMCPeerID: MCPeerID) {
    self.maxPlayers = maxPlayers
    self.myMCPeerID = myMCPeerID
  }
  
  func addPlayer(peer: MCPeerID) {
    /*
    Called when:
    - game startup for .me
    - connected to .opponent
    
    A player may be in the middle of a solitary game when they accept an invitation.
    So any new player resets the score for all players.
    */
    println("Scoreboard.addPlayer \(peer.displayName)")
    if players.count >= self.maxPlayers  {
      // Should not happen since we stop advertising when max is reached.
      NSLog("Too many players")
    }
    else if existsPlayer(peer) {
      NSLog("adding player already exists peer")
    }
    else {
      addPlayerInGameRole(peer)
      // Caller should: scoreBoard.resetScores()
    }
  }
  
  private func addPlayerInGameRole(peer: MCPeerID) {
    // Add player in appropriate role.
    assert(!existsPlayer(peer))
    
    let playerName = peer.displayName
    println("Scoreboard.addPlayerInGameRole \(playerName)")
    
    if peer == self.myMCPeerID {
      players[.me] = Player(peer: peer)
    }
    else {
      println("Adding opponent \(playerName)")
      // TODO: feedbackManager.onAddOpponent(playerName)
      players[.opponent] = Player(peer: peer)
    }
  }
  
  func deletePlayer(peer: MCPeerID) {
    // Player disconnected
    println("Deleted player \(peer.displayName)")
    assert(peer != self.myMCPeerID, "Can only delete opponent")
    assert(existsPlayer(peer))
    // Max two player: doesn't matter what displayName is, it is opponent
    let deletedPlayer = players.removeValueForKey(.opponent)
    if deletedPlayer == nil {
      NSLog("Failed to delete player")
    }
    // Caller should: scoreBoard.resetScores()
    // game is reset elsewhere
    
    // Max two player game => delete leaves one
    assert(players.count == 1)
  }
  
  
  internal func existsPlayer(peer: MCPeerID ) -> Bool {
    /*
    Is peer already a player?
    !!! Note we don't check displayName.
    A device may crash and rejoin the game with same displayName but new, unique peerID.
    */
    var result = false
    if let existingMe = players[.me] {
      if existingMe.peer == peer {
        result = true
      }
    }
    if let existingOpponent = players[.opponent] {
      if existingOpponent.peer == peer {
        result = true
      }
    }
    return result
  }
}