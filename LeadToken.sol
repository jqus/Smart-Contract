pragma solidity >=0.5.0 <0.6.0-0 <0.6.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint256);

    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
library SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract LeadToken is ERC20Interface {
    // SafeMath
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    mapping(address => address) public whitelist;


    function addwhitelist(address _account) public {
        whitelist[msg.sender] = _account;
    }

    function checkwhitelist(address account) public view returns (address) {
        return whitelist[account];
    }
    
    
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "LeadToken";
        symbol = "MAGC";
        decimals = 18;
        _totalSupply = 180000000000000000000000000;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint256 tokens)
        public
        returns (bool success)
    {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }



    // Junior Rojas - rojasjuniore

     /**
     * @notice _mint will create tokens on the address inputted and then increase the total supply
     *
     * It will also emit an Transfer event, with sender set to zero address (adress(0))
     *
     * Requires that the address that is recieveing the tokens is not zero address
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "DevToken: cannot mint to zero address");

        // Increase total supply
        _totalSupply = _totalSupply.add(amount);

        // Add amount to the account balance using the balance mapping
        balances[account] = balances[account].add(amount);

        // Emit our event to log the action
        emit Transfer(address(0), account, amount);
    }


    /**
     * @notice _burn will destroy tokens from an address inputted and then decrease total supply
     * An Transfer event will emit with receiever set to zero address
     *
     * Requires
     * - Account cannot be zero
     * - Account balance has to be bigger or equal to amount
     */
    function _burn(address account, uint256 amount) internal {
        require(
            account != address(0),
            "DevToken: cannot burn from zero address"
        );
        require(
            balances[account] >= amount,
            "DevToken: Cannot burn more than the account owns"
        );

        // Remove the amount from the account balance
        balances[account] = balances[account].sub(
            amount,
            "DevToken: burn amount exceeds balance"
        );

        // Decrease totalSupply
        _totalSupply = _totalSupply.sub(amount);

        // Emit event, use zero address as reciever
        emit Transfer(account, address(0), amount);
    }

    /**
     * @notice burn is used to destroy tokens on an address
     *
     * See {_burn}
     * Requires
     *   - msg.sender must be the token owner -  onlyOwner
     *
     */
    function burn(address account, uint256 amount)
        public
        returns (bool)
    {
        _burn(account, amount);
        return true;
    }

    /**
     * @notice mint is used to create tokens and assign them to msg.sender
     *
     * See {_mint}
     * Requires 
     *   - msg.sender must be the token owner - onlyOwner
     *
     */
    function mint(address account, uint256 amount)
        public
        
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }
}
