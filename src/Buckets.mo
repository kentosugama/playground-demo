import Nat "mo:base/Nat";
import Map "mo:base/RBTree";

actor class Bucket() {
  // KV store that represents this bucket
  var map = Map.RBTree<Nat, Text>(Nat.compare);
  stable var tree : Map.Tree<Nat, Text> = #leaf;

  /*
  * Upgrade logic
  */
  system func preupgrade () {
    tree := map.share();
  };

  system func postupgrade() {
    for ((key, value) in Map.iter<Nat, Text>(tree, #fwd)) {
      map.put(key, value);
    }
  };

  /*
  * Version 1 methods
  */ 
  public func get(key : Nat) : async ?Text {
    map.get(key);
  };

  public func put(key : Nat, value : Text) : async () {
    map.put(key, value);
  };

  // UNCOMMENT BELOW FOR VERSION 2 FEATURES :)

  // public func clear() : async () {
  //   map := Map.RBTree<Nat, Text>(Nat.compare);
  // };
};

