// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SplitBillOptimized {

    struct Group {
        string name;
        address[] members;
        mapping(address => bool) isMember;
        mapping(address => mapping(address => int256)) balances;
    }

    uint public groupCount;
    mapping(uint => Group) public groups;

    // Create group
    function createGroup(string memory _name) public {
        Group storage g = groups[groupCount];
        g.name = _name;
        g.members.push(msg.sender);
        g.isMember[msg.sender] = true;
        groupCount++;
    }

    // Add member
    function addMember(uint _groupId, address _member) public {
        Group storage g = groups[_groupId];

        // ✅ Prevent non-members from adding users
        require(g.isMember[msg.sender], "Not a member");

        // ✅ Prevent adding duplicate members
        require(!g.isMember[_member], "Already member");

        g.members.push(_member);
        g.isMember[_member] = true;
    }

    // Add expense
    function addExpense(
        uint _groupId,
        address[] memory _participants
    ) public payable {
        Group storage g = groups[_groupId];

        // ✅ Ensure only group members can add expenses
        require(g.isMember[msg.sender], "Not a member");

        // ✅ Prevent zero ETH transactions
        require(msg.value > 0, "No ETH");

        // ✅ Prevent empty participant list
        require(_participants.length > 0, "No participants");

        uint share = msg.value / _participants.length;

        for (uint i = 0; i < _participants.length; i++) {
            address p = _participants[i];

            // ✅ Ensure all participants are valid group members
            require(g.isMember[p], "Participant not member");

            if (p != msg.sender) {
                g.balances[p][msg.sender] += int256(share);
            }
        }

        // 💡 Note: Any division remainder stays with the payer (rounding handled implicitly)
    }

    // View balance
    function getBalance(
        uint _groupId,
        address from,
        address to
    ) public view returns (int256) {
        return groups[_groupId].balances[from][to];
    }

    // Batch settle optimized payments
    function settleOptimized(
        uint _groupId,
        address[] calldata payees,
        uint[] calldata amounts
    ) external payable {

        // Ensure arrays match in size
        require(payees.length == amounts.length, "Mismatch");

        Group storage g = groups[_groupId];

        // Ensure only group members can settle debts
        require(g.isMember[msg.sender], "Not a member");

        uint total = 0;

        for (uint i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }

        // Ensure exact ETH is sent (prevents over/under payment)
        require(msg.value == total, "Incorrect ETH sent");

        for (uint i = 0; i < payees.length; i++) {
            address to = payees[i];
            uint amount = amounts[i];

            // Prevent sending to invalid address
            require(to != address(0), "Invalid address");

            // Ensure payee is a group member
            require(g.isMember[to], "Payee not member");

            // Prevent paying more than owed
            require(g.balances[msg.sender][to] >= int256(amount), "Exceeds debt");

            g.balances[msg.sender][to] -= int256(amount);

            // Safe ETH transfer using call
            (bool success, ) = payable(to).call{value: amount}("");
            require(success, "Transfer failed");
        }
    }

    // Get members
    function getMembers(uint _groupId) public view returns (address[] memory) {
        return groups[_groupId].members;
    }
}