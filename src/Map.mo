import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Buckets "Buckets";

actor Map {
  type Bucket = Buckets.Bucket;

  let numBuckets = 4;
  let buckets : [var ?Bucket] = Array.init(numBuckets, null);
  stable let savedBuckets : [var ?(actor{})] = Array.init(numBuckets, null);

  /*
  * Upgrade logic
  */ 
  system func preupgrade () {
    for (i in buckets.keys()) {
      savedBuckets[i] := buckets[i];
    }
  };

  public func upgradeBuckets() : async () {
    for (i in savedBuckets.keys()) {
      ignore do ? {
        let oldBucket = savedBuckets[i]!;
        buckets[i] := ?(await (system Buckets.Bucket)(#upgrade oldBucket)()); // dynamic upgrade!
      }
    }
  };

  /*
  * Version 1 methods: get and put
  */ 
  public func get(key : Nat) : async ?Text {
    do ? {
      let index = key % numBuckets;
      let bucket = buckets[index]!;
      (await bucket.get(key))!
    }
  };

  public func put(key : Nat, value : Text) : async () {
    let index = key % numBuckets;
    let bucket = 
      switch (buckets[index]) {
        case null {
          // provision some cycles for new bucket
          let cycles = Cycles.balance()/(numBuckets + 1);
          Cycles.add(cycles); 

          // dynamically spawn a new Bucket canister!
          let newBucket = await Buckets.Bucket(); 
          buckets[index] := ?newBucket;
          newBucket;
        };
        case (?bucket) bucket;
      };
    await bucket.put(key, value);
  };

  /*
  * Version 2 methods: clear
  */ 

  // UNCOMMENT BELOW FOR NEW FEATURES

  // public func clear() : async () {
  //   for (bucket in buckets.vals()) {
  //     ignore do ? {
  //       await bucket!.clear();
  //     }
  //   }
  // };
};

