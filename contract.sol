// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";

//  This is a demo contract designed to benchmark the gas 
//  usage of different uint256 » string conversion algorithms.
//  Medium article  : 
//  Github source   : https://github.com/neznein9/uint-to-string
//  Mumbai contract : 0xb51a3175aCcE7D01bFD0717f9C4BD69a13dF6D3C
contract UintToStringTesting {

    event TestResult(uint256 input, string output, uint256 gas);

    //  Provable Things + Barnabas Ujvari
    //  https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity/65707309#65707309
    function uintToStringProvable(uint256 i) external returns (string memory result, uint256 gasUsed) {
        uint256 startingGas = gasleft();
        result = Algos.uint2strProvable(i);
        uint256 endingGas = gasleft();
        gasUsed = (startingGas - endingGas);
        emit TestResult(i, result, gasUsed);
    }

    //  OpenZepplin
    //  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d6b63a48ba440ad8d551383697db6e5b0ef84137/contracts/utils/Strings.sol#L24
    function uintToStringOZ(uint256 i) external returns (string memory result, uint256 gasUsed) {
        uint256 startingGas = gasleft();
        result = Strings.toString(i);
        uint256 endingGas = gasleft();
        gasUsed = (startingGas - endingGas);
        emit TestResult(i, result, gasUsed);
    }

    //  Mikhail Vladimirov
    //  https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity/71095692#71095692
    function uintToStringMikhail(uint256 i) external returns (string memory result, uint256 gasUsed) {
        uint256 startingGas = gasleft();
        result = Algos.uintToStringMikhail(i);
        uint256 endingGas = gasleft();
        gasUsed = (startingGas - endingGas);
        emit TestResult(i, result, gasUsed);
    }

    //  ABI Encode
    function uintToStringABI(uint256 i) external returns (string memory result, uint256 gasUsed) {
        uint256 startingGas = gasleft();
        result = Algos.uint2strABIEncode(i);
        uint256 endingGas = gasleft();
        gasUsed = (startingGas - endingGas);
        emit TestResult(i, result, gasUsed);
    }
}

library Algos {
    function uint2strProvable(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function uintToStringMikhail (uint x) internal pure returns (string memory s) {
        unchecked {
            if (x == 0) return "0";
            else {
                uint c1 = itoa32 (x % 1e32);
                x /= 1e32;
                if (x == 0) s = string (abi.encode (c1));
                else {
                    uint c2 = itoa32 (x % 1e32);
                    x /= 1e32;
                    if (x == 0) {
                        s = string (abi.encode (c2, c1));
                        c1 = c2;
                    } else {
                        uint c3 = itoa32 (x);
                        s = string (abi.encode (c3, c2, c1));
                        c1 = c3;
                    }
                }
                uint z = 0;
                if (c1 >> 128 == 0x30303030303030303030303030303030) { c1 <<= 128; z += 16; }
                if (c1 >> 192 == 0x3030303030303030) { c1 <<= 64; z += 8; }
                if (c1 >> 224 == 0x30303030) { c1 <<= 32; z += 4; }
                if (c1 >> 240 == 0x3030) { c1 <<= 16; z += 2; }
                if (c1 >> 248 == 0x30) { z += 1; }
                assembly {
                    let l := mload (s)
                    s := add (s, z)
                    mstore (s, sub (l, z))
                }
            }
        }
    }

    function itoa32 (uint x) private pure returns (uint y) {
        unchecked {
            require (x < 1e32);
            y = 0x3030303030303030303030303030303030303030303030303030303030303030;
            y += x % 10; x /= 10;
            y += x % 10 << 8; x /= 10;
            y += x % 10 << 16; x /= 10;
            y += x % 10 << 24; x /= 10;
            y += x % 10 << 32; x /= 10;
            y += x % 10 << 40; x /= 10;
            y += x % 10 << 48; x /= 10;
            y += x % 10 << 56; x /= 10;
            y += x % 10 << 64; x /= 10;
            y += x % 10 << 72; x /= 10;
            y += x % 10 << 80; x /= 10;
            y += x % 10 << 88; x /= 10;
            y += x % 10 << 96; x /= 10;
            y += x % 10 << 104; x /= 10;
            y += x % 10 << 112; x /= 10;
            y += x % 10 << 120; x /= 10;
            y += x % 10 << 128; x /= 10;
            y += x % 10 << 136; x /= 10;
            y += x % 10 << 144; x /= 10;
            y += x % 10 << 152; x /= 10;
            y += x % 10 << 160; x /= 10;
            y += x % 10 << 168; x /= 10;
            y += x % 10 << 176; x /= 10;
            y += x % 10 << 184; x /= 10;
            y += x % 10 << 192; x /= 10;
            y += x % 10 << 200; x /= 10;
            y += x % 10 << 208; x /= 10;
            y += x % 10 << 216; x /= 10;
            y += x % 10 << 224; x /= 10;
            y += x % 10 << 232; x /= 10;
            y += x % 10 << 240; x /= 10;
            y += x % 10 << 248;
        }
    }

    function uint2strABIEncode(uint256 myUint) internal pure returns (string memory str) {
        str = string(abi.encode(myUint));
    }
}
