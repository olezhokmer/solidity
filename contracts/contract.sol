pragma solidity >=0.7.3;
// pragma solidity ^0.8.2;

contract ContractLogic {
    
    enum BetValue { Red, Green, Black }
    
    struct Player {
        bytes32 name;
        uint ballance;
        bool active;
        bytes32 secret;
        uint wins;
        uint losses;
    }
    struct Bet {
        bytes32 name;
        BetValue betOn;
        uint amount;
    }

    struct Game {
        uint gameIndex;
        BetValue color;
        uint currentTime;
    }
    uint lastGameIndex = 0;
    address private casinoOwner;
    mapping(bytes32 => Player) private players;
    mapping(uint => Game) private games;
    mapping(BetValue => uint) private koefMapping;
    uint private variants;
    uint private initialBallance;
    Bet[] bets;

    constructor(uint variantsNumber, uint initialPlayerBallance) public {
        variants = variantsNumber;
        initialBallance = initialPlayerBallance;
        casinoOwner = msg.sender;
        updateKoefMapping();
    }

    function updateKoefMapping() private {
        koefMapping[BetValue.Black] = 2;
        koefMapping[BetValue.Red] = 2;
        koefMapping[BetValue.Green] = initialBallance;
    }

    function getResultColor(uint result) pure private returns (BetValue) {
        if (result == 0) {
            return BetValue.Green;
        } else if (result % 2 == 0) {
            return BetValue.Red;
        } else {
            return BetValue.Black;
        }
    }

    function getPlayer(bytes32 playerName, bytes32 secret)
        playerNotExists(playerName) 
        secretValid(playerName, secret) 
        public view 
    {
        players[playerName];
    }

    function spin() public returns (BetValue) {
        uint result = random(variants);
        BetValue color = getResultColor(result);
        uint koef = koefMapping[color];
        for (uint i = 0; i < bets.length; i++) {
            Bet storage currentBet = bets[i];
            if (currentBet.betOn == color) {
                players[currentBet.name].ballance = players[currentBet.name].ballance + (currentBet.amount * koef);
                players[currentBet.name].wins = players[currentBet.name].wins + 1;
            } else {
                players[currentBet.name].losses = players[currentBet.name].losses + 1;
            }
        }
        games[lastGameIndex] = Game({
            gameIndex: lastGameIndex,
            color: color,
            currentTime: block.timestamp
        });
        lastGameIndex = lastGameIndex + 1;
        delete bets;
        return color;
    }

    function createPlayer(bytes32 playerName, bytes32 secret) 
        playerExists(playerName) 
    public returns (bytes32) {
        players[playerName] = Player({
            name: playerName,
            ballance: initialBallance,
            secret: secret,
            active: true,
            wins: 0,
            losses: 0
        });
        return playerName;
    }

    modifier playerExists(bytes32 playerName) {
        require(
            players[playerName].name != playerName,
            'Player with this name already exists.'
        );
        _;
    }

    modifier playerNotExists(bytes32 playerName) {
        require(
            players[playerName].name == playerName,
            'Player with this name does not exist.'
        );
        _;
    }

    modifier secretValid(bytes32 playerName, bytes32 secret) {
        require(
            players[playerName].secret == secret,
            'Secret phrase is not valid.'
        );
        _;
    }

    modifier enoughBallance(bytes32 playerName, uint amount) {
        require(
            players[playerName].ballance >= amount,
            'Ballance is too low.'
        );
        _;
    }

    function placeBet(bytes32 playerName, bytes32 secret, BetValue betOn, uint amount)
        playerNotExists(playerName) secretValid(playerName, secret) enoughBallance(playerName, amount) 
        public returns (bool)
    {
        bets.push(Bet({
            name: playerName,
            betOn: betOn,
            amount: amount
        }));
        players[playerName].ballance = players[playerName].ballance - amount;
        return true;
    }

    function increaseBallance(bytes32 playerName, bytes32 secret, uint amount) 
    playerNotExists(playerName) 
    secretValid(playerName, secret)
    public returns (uint) {
        uint newBallance = players[playerName].ballance + amount;
        players[playerName].ballance = newBallance;
        return newBallance;
    }

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender))) % number;
    }
}