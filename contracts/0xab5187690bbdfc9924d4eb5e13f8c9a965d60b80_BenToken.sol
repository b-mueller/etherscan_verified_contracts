pragma solidity ^0.4.20;

contract BenToken {
    string public name=&quot;BenToken&quot;;
    string public symbol=&quot;BenCoin&quot;;
    uint8 public decimals=8;

    /* This creates an array with all balances */
    mapping (address =&gt; uint256) public balanceOf;

        /* Initializes contract with initial supply tokens to the creator of the contract */
    function constrcutor() public {
        balanceOf[msg.sender] = 10000;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] &gt;= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value &gt;= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender] -= _value;                    // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
    }
}