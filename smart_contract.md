# Smart contract (pseudocode) — demo

Goal: escrow deposit and automatic refund when ride ends.

// Pseudocode (Solidity-like)

contract RideEscrow {
    struct Ride { address user; uint256 deposit; uint256 start; uint256 duration; bool closed; }
    mapping(bytes32 => Ride) public rides;

    function startRide(bytes32 rideId, uint256 duration) public payable {
        require(msg.value > 0, "deposit required");
        rides[rideId] = Ride(msg.sender, msg.value, block.timestamp, duration, false);
    }

    function endRide(bytes32 rideId) public {
        Ride storage r = rides[rideId];
        require(!r.closed, "already closed");
        require(msg.sender == r.user, "only user can end");
        uint256 refund = r.deposit; // demo: full refund
        r.closed = true;
        payable(r.user).transfer(refund);
    }

    // Admin / operator hooks could release partial refunds if needed.
}

Notes:
- In production use audited contracts and proper access control.
- Use stablecoin ERC-20 like USDT/USDC via allowance/transferFrom for cross-border payments.
