// SPDX-License-Identifier: MIT

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

        sbt.init(
            owner,
            "Wagumi SBT",
            "SBT",
            "example://",
            keccak256(abi.encodePacked(validator))
        );

        bytes4[] memory sigs = new bytes4[](4);
        address[] memory impAddress = new address[](4);
        sigs[0] = bytes4(keccak256("mint(address,uint256,uint256,bytes)"));
        sigs[1] = bytes4(keccak256("setValidator(bytes32)"));
        sigs[2] = bytes4(keccak256("getValidator()"));
        sigs[3] = bytes4(keccak256("setContractOwner(address)"));
        impAddress[0] = address(imp);
        impAddress[1] = address(imp);
        impAddress[2] = address(imp);
        impAddress[3] = address(imp);
        vm.prank(owner);
        sbt.setImplementation(sigs, impAddress);

        address(sbt).call(
            abi.encodeWithSignature("setValidator(address)", validator)
        );
    }

    function testInit() public {
        assertEq(sbt.name(), "Wagumi SBT");
        assertEq(sbt.symbol(), "SBT");
        assertEq(sbt.contractOwner(), owner);
    }

    function testSupportsInterface() public {
        assertEq(sbt.supportsInterface(0x01ffc9a7), true);
        assertEq(sbt.supportsInterface(0x5b5e139f), true);
    }

    function testGetValidator() public {
        (, bytes memory result) = address(sbt).call(
            abi.encodeWithSignature("getValidator()")
        );
        assertEq(keccak256(abi.encodePacked(validator)), bytes32(result));
    }

    function testMint() public {
        bytes32 _messagehash = keccak256(
            abi.encode(validator, address(0xBEEF), uint256(0), uint256(0))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, _messagehash);
        vm.prank(validator);
        address(sbt).call(
            abi.encodeWithSignature(
                "mint(address,uint256,uint256,bytes)",
                address(0xBEEF),
                uint256(0),
                uint256(0),
                abi.encodePacked(r, s, v)
            )
        );
        assertEq(sbt.tokenURI(0), "example://0.json");

        vm.expectRevert(bytes("INVALID"));
        address(sbt).call(
            abi.encodeWithSignature(
                "mint(address,uint256,uint256,bytes)",
                address(0xBEEF),
                uint256(999),
                uint256(999),
                abi.encodePacked(r, s, v)
            )
        );
    }

    function testSetContractOwner() public {
        address newOwner = address(3);
        vm.prank(owner);
        (, bytes memory result) = address(sbt).call(
            abi.encodeWithSignature("setContractOwner(address)", newOwner)
        );
        assertEq(sbt.contractOwner(), newOwner);

        vm.expectRevert(bytes("OWNER ONLY"));
        address(sbt).call(
            abi.encodeWithSignature("setContractOwner(address)", newOwner)
        );
    }
}
