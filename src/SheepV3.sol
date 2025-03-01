// SPDX-License-Identifier: MIT

//In crypto, there are so many sheep, they follow the trends of few, make bad choices with only a patch of sweet green grass in sight. 
//Trolls haunt the bribges, yanking our fellows under to be devoured -- where's the biggest Gruff when needed. 

//This token has a very special mechanic built into it. It restricts the transferability to the number of token holders in an attempt
//to stop single holders from accumulating a massive herd of sheep, and if they do, it's harder to transfer them

//The Deployer of this smart contract accepts no obligations or responsibilities for the consequences, either positive or negative, of individuals that interact with it. 
//USE AT YOUR OWN RISK


pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Sheep is Context, IERC20, IERC20Metadata {


    // changed to internal to allow overridden _transfer() to modify it
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances; 

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "src/interfaces/IGasERC20.sol";

contract SHEEP is ERC20Sheep, Ownable2Step {

    constructor(address _wGasToken,address _pol) ERC20Sheep("The_Herd_Mentality", "SHEEP") {
        wGasToken = _wGasToken;
        POL = _pol;
        
    }
    
    bool public pastured = true;
    bool public saleStarted = false;

    uint256 public preMinted = 0;

    uint256 public constant ONE_WEEK = 604800; //this is the delay on retrieving the LPs
    address public wolf;
    
    uint256 public constant mintPrice = 1; // 1 means 1 wGAS token for 1 SHEEP
    uint256 public constant teamCut = 50; // 50 = 5%
    uint256 public constant maxPreMint = 2_000_000e18;

    address public immutable wGasToken;

    address public immutable POL; // address to send the tokens that are going to be used as POL

    function mintForFee() public payable{
        require(msg.value > 0, "0 tokens");
        IGasERC20(wGasToken).deposit{
            value: msg.value
        }();
        _mintForFee(msg.value);
    }

    function mintForFee(uint amount) public{
        require(amount > 0, "0 tokens");
        IERC20(wGasToken).transferFrom(msg.sender,address(this), amount);
        _mintForFee(amount);
    }

    function _mintForFee(uint256 _amount) private {
        require(pastured,"You are to late");
        require(saleStarted,"Sheep nor ready yet");
        require(preMinted + _amount <= maxPreMint,"No more sheep in the market");

        uint mintFee = _amount * mintPrice;
        uint teamFee = mintFee * teamCut / 1000;

        IERC20(wGasToken).transfer(POL, mintFee- teamFee);
        IERC20(wGasToken).transfer(owner(), teamFee);

        uint polToMint = _amount - (teamCut * _amount / 1000);

        preMinted += _amount;

        _mint(msg.sender, _amount);
        _mint(POL,polToMint);
    }

    ///////////////////////////////////////
    /////SHEPPARD FUNCTIONS////////////////
    ///////////////////////////////////////

    /// @notice This function is set once. It sets the sheep free to be traded
    function takeOutOfPasture() public onlyOwner{
        pastured = false;
    }

    function startSale() public onlyOwner {
        saleStarted = true;
    }
   
    /// @notice This function will setup the filters for the eat the sheep burn function
    function buildTheFarm(address _wolf) public onlyOwner {
        require(wolf == address(0), "the farm is already built");
        wolf = _wolf;
    }

    ///////////////////////////////////////
    ////////WOLF FUNCTIONS/////////////////
    ///////////////////////////////////////

    function eatSheep(address _victim, uint256 _amount, address _owner,uint256 _mintPercent) public {
        require(msg.sender == wolf, "only wolves can eat sheep"); // wolf is deciding if it can eat from the specific address
        _burn(_victim, _amount);
        if(_mintPercent != 0) {
            _mint(_owner, (_amount * _mintPercent / 100));
        }
    }
    
    function burnSheep(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }

    ///////////////////////////////////////
    ////////STANDARDS MODIFICATIONS////////
    ///////////////////////////////////////
    
    /// @notice In order to send sheep to others, including swaps, you need to send <= the herdSize.
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "Sheep don't come from nothing");
        require(to != address(0), "This is a dangerous place for sheep to go");
        require(to != address(this), "You cant send sheep back to mom");
        require(!pastured,"!pastured");
   
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "You dont have enough sheep to slaughter this many");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);        
    }
}