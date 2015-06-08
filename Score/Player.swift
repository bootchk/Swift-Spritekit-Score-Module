
import Foundation
import MultipeerConnectivity

class Player {
  /*
  Players knows name and score.
  Not responsible for view of score.
  */

  var peer: MCPeerID
  var score = 0
  var name: String {
    return peer.displayName
  }
  
  
  init(peer: MCPeerID ) {
    self.peer = peer
  }
  
  func reset() {
    println("Player.reset \(self.name)")
    score = 0
  }
  
  
  func addScore(amount: Int) {
    println("addScore \(amount) to \(self.name)")
    assert(amount > 0)
    score += amount
  }

}