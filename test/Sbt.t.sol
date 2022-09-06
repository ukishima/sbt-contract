// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../Sbt.sol";
import "../SbtImp.sol";

contract SbtTest is Test {
    address owner = address(420);
    address validator;
    Sbt internal sbt;
    SbtImp internal imp;

    function setUp() public {
        validator = vm.addr(1);

        sbt = new Sbt();
        imp = new SbtImp();

        bytes4[] memory sigs = new bytes4[](3);
        address[] memory impAddress = new address[](3);
        sigs[0] = bytes4(0x731133e9);
        impAddress[0] = address(imp);
        vm.prank(address(0));
        sbt.setImplementation(sigs, impAddress);
    }

    function testInit() public {
        sbt.init(owner, "Wagumi SBT", "SBT", "example://", validator);
        assertEq(sbt.name(), "Wagumi SBT");
        assertEq(sbt.symbol(), "SBT");
    }

    function testMint() public {
        bytes32 _messagehash = keccak256(
            abi.encode(msg.sender, address(0xBEEF), uint256(0), uint256(0))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, _messagehash);
        console.log(v);
        address(sbt).call(
            abi.encodeWithSignature(
                "mint(address,uint256,uin256,bytes)",
                address(0xBEEF),
                uint256(0)
            )
        );
        // sbt.mint(address(0xBEEF), 1337);

        // assertEq(sbt.balanceOf(address(0xBEEF)), 1);
        // assertEq(sbt.ownerOf(1337), address(0xBEEF));
    }
}
