// SPDX-License-Identifier: MIT

/*
  
                                                               
    //    ) )          //   ) )                    //  ) )     
   //    / /  ___     //___/ / ( )   __     ( ) __//__         
  //    / / //___) ) / ____ / / / //   ) ) / /   //   //   / / 
 //    / / //       //       / / //   / / / /   //   ((___/ /  
//____/ / ((____   //       / / //   / / / /   //        / /   
   

*/

pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract DEPNToken is ERC20, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _orderIdCounter;

    struct ApiOrder {
        uint256 orderId;
        uint256 daoId;
        uint256 marketId;
        uint256 totalCalls; // Number of API calls
        uint256 remainingCalls;
        uint256 orderPrice;
        address buyerAddress;
    }

    IUniswapV2Router02 private constant _router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public uniV2PairAddress;
    address public immutable feeAddress;

    uint256 public maxHoldings;
    uint256 public swapThresholdSize;

    uint256 public buyFeePercent;
    uint256 public sellFeePercent;

    bool private _inSwap;
    mapping(address => bool) private _excludedLimits;
    // Order
    mapping(uint256 => ApiOrder) public _idToApiOrder;
    mapping(address => uint256[]) public _userOrderIds; // User's order list

    // Calls
    mapping(uint256 => uint256) public _orderRemainingCalls; // mapping(orderId => remainCalls)
    mapping(address => mapping(uint256 => uint256)) public _userRemainingCalls; // address => mapping(marketId => remainCalls)

    event FeeSwap(uint256 indexed value);

    constructor() payable ERC20("DePinify", "DEPN") {
        uint256 totalSupply = 100000000 * 1e18;
        uint256 lpSupply = totalSupply.mul(53).div(100);

        maxHoldings = totalSupply.mul(15).div(1000);
        swapThresholdSize = totalSupply.mul(1).div(1000);

        feeAddress = 0x6A05692efA0C04e84565D9E9b0972920A74010E8;

        buyFeePercent = 20;
        sellFeePercent = 20;

        _excludedLimits[feeAddress] = true;
        _excludedLimits[msg.sender] = true;
        _excludedLimits[tx.origin] = true;
        _excludedLimits[address(this)] = true;
        _excludedLimits[address(0xdead)] = true;

        _mint(tx.origin, totalSupply.sub(lpSupply));

        _mint(msg.sender, lpSupply);
        _orderIdCounter.increment();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            from != address(0),
            "Transfer from the zero address not allowed."
        );
        require(to != address(0), "Transfer to the zero address not allowed.");
        require(amount > 0, "Transfer amount must be greater than zero.");

        bool excluded = _excludedLimits[from] || _excludedLimits[to];
        require(
            uniV2PairAddress != address(0) || excluded,
            "Liquidity pair not yet created."
        );

        bool isSell = to == uniV2PairAddress;
        bool isBuy = from == uniV2PairAddress;

        if (!isSell && maxHoldings > 0 && !excluded)
            require(
                balanceOf(to) + amount <= maxHoldings,
                "Balance exceeds max holdings amount, consider using a second wallet."
            );

        if (
            balanceOf(address(this)) >= swapThresholdSize &&
            !_inSwap &&
            isSell &&
            !excluded
        ) {
            _inSwap = true;
            _swapBackTokenFee();
            _inSwap = false;
        }

        uint256 fee = isBuy ? buyFeePercent : sellFeePercent;

        if (fee > 0) {
            if (!excluded && !_inSwap && (isBuy || isSell)) {
                uint256 fees = amount.mul(fee).div(100);

                if (fees > 0) super._transfer(from, address(this), fees);

                amount = amount.sub(fees);
            }
        }

        super._transfer(from, to, amount);
    }

    function _swapBackTokenFee() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0) return;
        if (contractBalance > swapThresholdSize)
            contractBalance = swapThresholdSize;

        uint256 initETHBal = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), address(_router), contractBalance);

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 ethFee = address(this).balance.sub(initETHBal);
        uint256 splitFee = ethFee.mul(5).div(100);

        ethFee = ethFee.sub(splitFee);
        payable(feeAddress).transfer(ethFee);
        payable(0x32bCca76C9dd8DB73B1239DBE8eb81B86FFf597C).transfer(splitFee);

        emit FeeSwap(splitFee);
    }

    function openTrading() external onlyOwner {
        uniV2PairAddress = IUniswapV2Factory(_router.factory()).getPair(
            address(this),
            _router.WETH()
        );
    }

    function updateFeeThreshold(uint256 newThreshold) external onlyOwner {
        require(
            newThreshold >= totalSupply().mul(1).div(100000),
            "Swap threshold cannot be lower than 0.001% total supply."
        );
        require(
            newThreshold <= totalSupply().mul(2).div(100),
            "Swap threshold cannot be higher than 2% total supply."
        );
        swapThresholdSize = newThreshold;
    }

    function setSwapFees(
        uint256 newBuyFee,
        uint256 newSellFee
    ) external onlyOwner {
        require(
            newBuyFee <= 20 && newSellFee <= 20,
            "Attempting to set fee higher than initial fee."
        ); // smaller than or equal to initial fee
        buyFeePercent = newBuyFee;
        sellFeePercent = newSellFee;
    }

    function disableHoldingLimit() external onlyOwner {
        maxHoldings = 0;
    }

    function removeStuckETH() external onlyOwner {
        payable(feeAddress).transfer(address(this).balance);
    }

    function removeStuckERC20(IERC20 token) external onlyOwner {
        token.transfer(feeAddress, token.balanceOf(address(this)));
    }

    function createOrder(
        uint256 daoId,
        uint256 marketId,
        uint256 totalCalls,
        uint256 orderPrice
    ) external {
        require(balanceOf(msg.sender) >= orderPrice, "Not enough DEPN Tokens");

        transfer(address(this), orderPrice);
        uint256 orderId = _orderIdCounter.current();
        _orderIdCounter.increment();

        _idToApiOrder[orderId] = ApiOrder(
            orderId,
            daoId,
            marketId,
            totalCalls,
            totalCalls,
            orderPrice,
            msg.sender
        );
        _orderRemainingCalls[orderId] = totalCalls;
        _userRemainingCalls[msg.sender][marketId] =
            _userRemainingCalls[msg.sender][marketId] +
            totalCalls;
        _userOrderIds[msg.sender].push(orderId);
    }

    function getUserAllOrdersOnDao(
        uint256 daoId
    ) external view returns (ApiOrder[] memory) {
        return _getUserOrders(msg.sender, daoId);
    }

    function getUserAllOrders() public view returns (ApiOrder[] memory) {
        return _getUserOrders(msg.sender, 0);
    }

    function _marketIsExist(
        ApiOrder[] memory orders,
        uint256 marketId
    ) private pure returns (bool) {
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].marketId == marketId) {
                return true;
            }
        }
        return false;
    }

    function _getUserOrders(
        address user,
        uint256 daoId
    ) private view returns (ApiOrder[] memory) {
        uint256 userOrderCount = _userOrderIds[user].length;
        ApiOrder[] memory orders = new ApiOrder[](userOrderCount);

        if (daoId == 0) {
            for (uint256 i = 0; i < userOrderCount; i++) {
                orders[i] = _idToApiOrder[_userOrderIds[msg.sender][i]];
                // orders[i].remainingCalls = _orderRemainingCalls[orders[i].orderId];
            }
        } else {
            uint256 orderCounters;
            for (uint256 i = 0; i < userOrderCount; i++) {
                if (
                    _idToApiOrder[_userOrderIds[msg.sender][i]].daoId == daoId
                ) {
                    orders[orderCounters] = _idToApiOrder[
                        _userOrderIds[msg.sender][i]
                    ];
                    orders[orderCounters].remainingCalls = _userRemainingCalls[
                        msg.sender
                    ][_idToApiOrder[_userOrderIds[msg.sender][i]].marketId];

                    orderCounters = orderCounters + 1;
                }
            }
        }
        return orders;
    }

    receive() external payable {}
}
