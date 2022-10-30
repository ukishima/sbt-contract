// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./SbtLib.sol";

contract SbtImp {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event ContractOwnerChanged(address _newOwner);
    event ValidatorChanged(bytes32 _newValidator);

    // 0x731133e9
    function mint(
        address _address,
        uint256 _tokenId,
        uint256 _salt,
        bytes calldata _signature
    ) external {
        bytes32 _messagehash = keccak256(
            abi.encode(msg.sender, _address, _tokenId, _salt)
        );
        require(verify(_messagehash, _signature), "INVALID");
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(sbtstruct.owners[_tokenId] == address(0) ,"MINTED ALREADY");
        sbtstruct.owners[_tokenId] = _address;
        unchecked {
            sbtstruct.balances[_address]++;
        }
        emit Transfer(address(0), _address, _tokenId);
    }

    function burn(uint256 _tokenId) external  {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(msg.sender == sbtstruct.contractOwner,"OWNER ONLY");
        address currentOwner = sbtstruct.owners[_tokenId];
        delete sbtstruct.owners[_tokenId];
        emit Transfer(currentOwner, address(0), _tokenId);
    }

    function setBaseUri(string memory _newBaseURI) external {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(msg.sender == sbtstruct.contractOwner,"OWNER ONLY");
        sbtstruct.baseURI = _newBaseURI;
    } 

    function setContractOwner(address _newContactOwner) external {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(msg.sender == sbtstruct.contractOwner, "OWNER ONLY");
        sbtstruct.contractOwner = _newContactOwner;
        emit ContractOwnerChanged(_newContactOwner);
    }

    function setValidator(bytes32 _newValidator) external {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(msg.sender == sbtstruct.contractOwner, "OWNER ONLY");
        sbtstruct.validator = _newValidator;
        emit ValidatorChanged(_newValidator);
    }

    function getValidator() external view returns (bytes32) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.validator;
    }

    function verify(bytes32 _hash, bytes memory _signature)
        public
        view
        returns (bool)
    {
        require(_signature.length == 65, "INVALID");
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        bytes32 _r;
        bytes32 _s;
        uint8 _v;
        assembly {
            _r := mload(add(_signature, 32))
            _s := mload(add(_signature, 64))
            _v := byte(0, mload(add(_signature, 96)))
        }
        return
            keccak256(abi.encodePacked(ecrecover(_hash, _v, _r, _s))) ==
            sbtstruct.validator;
    }
}
