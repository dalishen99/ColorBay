pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath 
{

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**

  /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
   * @dev Adds two numbers, throws on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
  
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable 
{
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
  
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable 
{
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpauseunpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic 
{
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic 
{
  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic 
{
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken 
{

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable 
{

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint256 _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

}


/**
 * @title Frozenable Token
 * @dev Illegal address that can be frozened.
 */
contract FrozenableToken is Ownable 
{
    
    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address indexed to, bool frozen);

    modifier whenNotFrozen(address _who) {
      require(!frozenAccount[msg.sender] && !frozenAccount[_who]);
      _;
    }

    function freezeAccount(address _to, bool _freeze) public onlyOwner {
        require(_to != address(0));
        frozenAccount[_to] = _freeze;
        emit FrozenFunds(_to, _freeze);
    }

}


/**
 * @title Colorbay Token
 * @dev Global digital painting asset platform token.
 * @author colorbay.org 
 */
contract Colorbay is PausableToken, FrozenableToken 
{

    string public name = "Colorbay Token";
    string public symbol = "CLB";
    uint256 public decimals = 18;
    uint256 INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    /**
     * @dev Initializes the total release
     */
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    /**
     * if ether is sent to this address, send it back.
     */
    function() public payable {
        revert();
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public whenNotFrozen(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenNotFrozen(_from) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }        
    
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------
// SafeMath ERC20Basic ERC20 Ownable

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}


contract TokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;
  
    ERC20Basic token;
    uint256 public stageStep = 30;
    uint256 planCount = 0;
    uint256 payPool = 0;
    
    // holder plans
    struct Plan {
      address beneficiary; // beneficiary of tokens after they are released
      uint256 startTime;
      uint256 locktoTime;
      uint256 releaseStages;
      uint256 endTime;
      uint256 totalToken;
      uint256 releasedAmount;
      bool revocable;
      bool isRevoked;
      string remark;
    }
    
    mapping (address => Plan) public plans;
    
    event Released(address beneficiary, uint256 amount);
    event Revoked();
    event AddPlan(address indexed beneficiary, uint256 startTime, uint256 locktoTime, uint256 releaseStages, uint256 endTime, uint256 totalToken, uint256 releasedAmount, bool isRevoked, string remark);
    
    /**
     * @param token ERC20 token which is being vested
     */
    constructor(address _token) public {
        token = ERC20Basic(_token);
    }
    
    /**
     * @dev Add a holder plan
     */
    function addPlan(address _beneficiary, uint256 _startTime, uint256 _locktoTime, uint256 _releaseStages, uint256 totalToken, bool _revocable, string _remark='') public returns (bool) {
        require(_beneficiary != address(0));
        require(!plans[_beneficiary]);
        require(_startTime > 0 && _locktoTime > 0 && _releaseStages > 0 && totalToken > 0);
        require(_locktoTime > block.timestamp && _locktoTime > _startTime);

        require(token.balanceOf(this) >= payPool.add(totalToken));
        payPool = payPool.add(totalToken);
        
        uint endTime = releaseStages.mul(stageStep).mul(86400).add(_locktoTime);
        plans[_beneficiary] = Plan(_beneficiary, _startTime, _locktoTime, _releaseStages, endTime, totalToken, 0, _revocable, false, _remark);
        planCount = planCount.add(1);
        emit AddPlan(_beneficiary, _startTime, _locktoTime, _releaseStages, endTime, totalToken, 0, _revocable, false, _remark);
        return true;
    }
    
    /**
    * @notice Transfers vested tokens to beneficiary.
    */
    function release() public {
        require(plans[msg.sender] != 0);
        require(!plans[msg.sender].isRevoked);
        
        uint256 unreleased = releasableAmount();
        require(unreleased > 0);
        
        plans[msg.sender].releasedAmount = plans[msg.sender].releasedAmount.add(unreleased);
        
        token.safeTransfer(msg.sender, unreleased);
        emit Released(msg.sender, unreleased);
    }
    
    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function releasableAmount() public view returns (uint256) {
        require(plans[msg.sender] != 0);
        return vestedAmount().sub(plans[msg.sender].releasedAmount);
    }

    /**
     * @dev Calculates the amount that has already vested.
     */
    function vestedAmount() public view returns (uint256) {
        require(plans[msg.sender] != 0);
        
        uint256 totalBalance = 0;

        if (block.timestamp <= plans[msg.sender].locktoTime || (block.timestamp > plans[msg.sender].endTime && plans[msg.sender].totalToken == plans[msg.sender].releasedAmount) || plans[msg.sender].isRevoked) {
            return totalBalance;
        }
        
        uint256 totalTime = plans[msg.sender].endTime.sub(plans[msg.sender].locktoTime);
        uint256 totalToken = plans[msg.sender].totalToken;
        uint256 releaseStages = plans[msg.sender].releaseStages;
        uint256 passedTime = block.timestamp.sub(plans[msg.sender].locktoTime);
        
        
        uint256 unitStageTime = totalTime.div(releaseStages);
        uint256 currStage = passedTime.div(unitStageTime);
        uint256 unitToken = totalToken.div(releaseStages);
        
        if(currStage > 0 && releaseStages == currStage) {
            totalBalance = totalToken.sub(plans[msg.sender].releasedAmount);
        } elseif(currStage > 0) {
            totalBalance = unitToken.mul(currStage);
        }
        
        return totalBalance;
        
    }
    
    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
     */
    function revoke(address _beneficiary) public onlyOwner {
        require(plans[_beneficiary] != 0);
        require(plans[_beneficiary].revocable]);
        require(!plans[_beneficiary].isRevoked);
    
        uint256 totalToken = plans[_beneficiary].totalToken;
    
        uint256 unreleased = revokeableAmount(token);
        uint256 refund = totalToken.sub(unreleased);
    
        plans[_beneficiary].isRevoked = true;
    
        token.safeTransfer(owner, refund);
        emit Revoked(_beneficiary, refund);
    }
    
    /**
     * @dev Calculates the amount that recoverable token.
     */
    function revokeableAmount(address _beneficiary) public view returns (uint256) {
        require(plans[_beneficiary] != 0);
        require(plans[_beneficiary].revocable]);
        require(!plans[_beneficiary].isRevoked);
        
        uint256 totalBalance = 0;

        if (block.timestamp > plans[_beneficiary].endTime) {
            return totalBalance;
        } elseif (block.timestamp <= plans[_beneficiary].locktoTime) {
            return plans[_beneficiary].totalToken;
        } else {
            uint256 totalTime = plans[_beneficiary].endTime.sub(plans[_beneficiary].locktoTime);
            uint256 totalToken = plans[_beneficiary].totalToken;
            uint256 passedTime = block.timestamp.sub(plans[_beneficiary].locktoTime);
            uint256 releasedAmount = totalToken.mul(passedTime.div(totalTime));
            totalBalance = totalToken.sub(releasedAmount);
        }
        return totalBalance;
    }
  
}

