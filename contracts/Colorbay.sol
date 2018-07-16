pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol'; //StandardToken、Pausable
import 'openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol'; //StandardToken、Ownable
import 'openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol'; //BasicToken


/**
 * @title Colorbay Token
 * @dev Global digital painting asset platform token.
 */
contract Colorbay is PausableToken, MintableToken, BurnableToken {
    using SafeMath for uint256;

    string public name = "Colorbay Token";
    string public symbol = "CLB";
    uint256 public decimals = 18;
    uint256 INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    event UpdatedTokenInformation(string name, string symbol);

    //"1000000000","Colorbay","CLB"
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    
    /**
     * @dev Update the symbol.
     * @param _tokenSymbol The symbol name.
     */
    function setTokenInformation(string _tokenName, string _tokenSymbol) public onlyOwner {
        name = _tokenName;
        symbol = _tokenSymbol;
        emit UpdatedTokenInformation(name, symbol);
    }

    function() public payable {
      revert(); //if ether is sent to this address, send it back.
    }

    /**
     * @dev mint timelocked tokens
     */
    function mintTimelocked(address _to, uint256 _amount, uint256 _releaseTime)
        onlyOwner canMint returns (TokenTimelock) {

        TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
        mint(timelock, _amount);

        return timelock;
    }



}

