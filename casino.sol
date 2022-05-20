pragma solidity ^0.8.0;

contract casino {
    address public owner;
    uint256 private minimumBet;
    uint256 private totalBet;
    uint256 private numberofBets;
    uint256 private maxAmountOfBets = 100;
    address[] Players;
    mapping(address => bool) isIn;
    struct Player {
        uint256 amountBet;
        uint256 numberSeleceted;
    }
    mapping(address => Player) data;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(uint256 _minimumBet) {
        require(_minimumBet != 0, "not 0");
        minimumBet = _minimumBet;
        owner = msg.sender;
    }

    function bet(uint256 _numberSelected) public payable {
        require(numberofBets < maxAmountOfBets);
        require(isIn[msg.sender] != true);
        require(msg.value >= minimumBet);
        require(0 < _numberSelected && _numberSelected <= 10);
        data[msg.sender] = Player(msg.value, _numberSelected);
        isIn[msg.sender]= true;
        numberofBets++;
        Players.push(msg.sender);
        totalBet += msg.value;
        if (numberofBets >= maxAmountOfBets) {
            uint256 win = _generateRandomNumber();
            _distributePrizes(win);
        }
    }

    function _distributePrizes(uint256 numberWinner) internal {
        address[100] memory winners;
        uint256 count = 0;
        for (uint256 i = 0; i < Players.length; i++) {
            address dPlayer = Players[i];
            if (data[dPlayer].numberSeleceted == numberWinner) {
                winners[count] = dPlayer;
                count++;
            }
            delete data[data];
            delete isIn[dPlayer];
            uint256 premio = totalBet / winners.length;
        }
        delete Players;
        totalBet = 0;
        numberofBets = 0;

        for (uint256 j = 0; j < count; j++) {
            if (winners[j] != address(0)) {
                payable(winners[j]).transfer(premio);
            }
        }
    
    }

    function _generateRandomNumber() internal view returns (uint256) {
        uint256 numberGenerated = (block.number % 10) + 1;
        return numberGenerated;
    }

    function kill() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    fallback() external payable {
        revert();
    }
}
