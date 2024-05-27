// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";

//  This is a demo contract designed to benchmark the gas 
//  usage of different uint256 » string conversion algorithms.
//  Medium article  : https://neznein9.medium.com/the-fastest-way-to-convert-uint256-to-string-in-solidity-b880cfa5f377
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

    function uintToStringSaturn(uint256 i) external returns (string memory result, uint256 gasUsed) {
        uint256 startingGas = gasleft();
        result = Algos.uintToStringSaturn(i);
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

    function uintToStringSaturn(uint256 x) internal pure returns (string memory s) {
        if (x != 0) {
            unchecked {
                // Handle numbers with less than 31 digits
                if (x < 1e31) { 
                    uint256 c1 = itoa31(x);
                    assembly {
                        s := mload(0x40) // Get the free memory pointer for storing the result
                        let z := shr(248, c1) // Extract the number of digits stored in the highest byte of c1
                        mstore(s, z) // Store the length of the string
                        mstore(add(s, 32), shl(sub(256, mul(z, 8)), c1)) // Store the digit bytes shifted to the correct position
                        mstore(0x40, add(s, 64)) // Update the free memory pointer
                    }
                }
                // Handle numbers with 31 to 62 digits
                else if (x < 1e62) {
                    uint256 c1 = itoa31(x);
                    uint256 c2 = itoa31(x / 1e31);
                    assembly {
                        s := mload(0x40) // Get the free memory pointer for storing the result
                        let z := shr(248, c2) // Extract the number of digits stored in the highest byte of c2
                        mstore(s, add(z, 31)) // Store the length of the string (z digits of c2 + 31 digits of c1)
                        mstore(add(s, 32), shl(sub(256, mul(z, 8)), c2)) // Store the digit bytes of c2 shifted to the correct position
                        mstore(add(s, add(32, z)), shl(8, c1)) // Store the digit bytes of c1 shifted to the correct position
                        mstore(0x40, add(s, 96)) // Update the free memory pointer
                    }
                }
                // Handle numbers with more than 62 digits
                else {
                    uint256 c1 = itoa31(x);
                    uint256 c2 = itoa31(x / 1e31);
                    uint256 c3 = itoa31(x / 1e62);
                    assembly {
                        s := mload(0x40) // Get the free memory pointer for storing the result
                        let z := shr(248, c3) // Extract the number of digits stored in the highest byte of c3
                        mstore(s, add(z, 62)) // Store the length of the string (z digits of c3 + 62 digits of c2 and c1)
                        mstore(add(s, 32), shl(sub(256, mul(z, 8)), c3)) // Store the digit bytes of c3 shifted to the correct position
                        mstore(add(s, add(32, z)), shl(8, c2)) // Store the digit bytes of c2 shifted to the correct position
                        mstore(add(s, add(63, z)), shl(8, c1)) // Store the digit bytes of c1 shifted to the correct position
                        mstore(0x40, add(s, 128)) // Update the free memory pointer
                    }
                }
            }
        }
        else {
            return "0"; // Handle the case where the input is zero
        }
    }

    /// @notice Helper function for UInt256 Conversion
    /// @param x The uint256 value to convert
    /// @return y The string representation of the uint256 value as a

    /// @notice Helper function to convert a uint256 to its string representation
    /// @param x The uint256 value to convert
    /// @return y The string representation of the uint256 value
    function itoa31 (uint256 x) private pure returns (uint256 y) {
        unchecked {
            // Initialize the byte sequence with 0x30 (ASCII '0') and a leading byte for zero count
            y = 0x0030303030303030303030303030303030303030303030303030303030303030
                // Convert the number into ASCII digits and place them in the correct position
                + (x % 10)
                + ((x / 1e1 % 10) << 8)
                + ((x / 1e2 % 10) << 16);

            // Use checkpoints to reduce unnecessary divisions and modulo operations
            if (x < 1e3) {
                if (x < 1e1) return y += 1 << 248; // One digit
                if (x < 1e2) return y += 2 << 248; // Two digits
                return y += 3 << 248; // Three digits
            }

            y += ((x / 1e3 % 10) << 24)
                + ((x / 1e4 % 10) << 32)
                + ((x / 1e5 % 10) << 40);

            if (x < 1e6) {
                if (x < 1e4)  return y += 4 << 248; // Four digits
                if (x < 1e5)  return y += 5 << 248; // Five digits
                return  y += 6 << 248; // Six digits
            }

            y += ((x / 1e6 % 10) << 48)
                + ((x / 1e7 % 10) << 56)
                + ((x / 1e8 % 10) << 64);

            if (x < 1e9) {
                if (x < 1e7) return y += 7 << 248; // Seven digits
                if (x < 1e8) return y += 8 << 248; // Eight digits
                return y += 9 << 248; // Nine digits
            }

            y += ((x / 1e9 % 10) << 72)
                + ((x / 1e10 % 10) << 80)
                + ((x / 1e11 % 10) << 88);

            if (x < 1e12) {
                if (x < 1e10) return y += 10 << 248; // Ten digits
                if (x < 1e11) return y += 11 << 248; // Eleven digits
                return y += 12 << 248; // Twelve digits
            }

            y += ((x / 1e12 % 10) << 96)
                + ((x / 1e13 % 10) << 104)
                + ((x / 1e14 % 10) << 112);

            if (x < 1e15) {
                if (x < 1e13) return y += 13 << 248; // Thirteen digits
                if (x < 1e14) return y += 14 << 248; // Fourteen digits
                return y += 15 << 248; // Fifteen digits
            }

            y += ((x / 1e15 % 10) << 120)
                + ((x / 1e16 % 10) << 128)
                + ((x / 1e17 % 10) << 136);

            if (x < 1e18) {
                if (x < 1e16) return y += 16 << 248; // Sixteen digits
                if (x < 1e17) return y += 17 << 248; // Seventeen digits
                return y += 18 << 248; // Eighteen digits
            }

            y += ((x / 1e18 % 10) << 144)
                + ((x / 1e19 % 10) << 152)
                + ((x / 1e20 % 10) << 160);

            if (x < 1e21) {
                if (x < 1e19) return y += 19 << 248; // Nineteen digits
                if (x < 1e20) return y += 20 << 248; // Twenty digits
                return y += 21 << 248; // Twenty-one digits
            }

            y += ((x / 1e21 % 10) << 168)
                + ((x / 1e22 % 10) << 176)
                + ((x / 1e23 % 10) << 184);

            if (x < 1e24) {
                if (x < 1e22) return y += 22 << 248; // Twenty-two digits
                if (x < 1e23) return y += 23 << 248; // Twenty-three digits
                return y += 24 << 248; // Twenty-four digits
            }

            y += ((x / 1e24 % 10) << 192)
                + ((x / 1e25 % 10) << 200)
                + ((x / 1e26 % 10) << 208);

            if (x < 1e27) {
                if (x < 1e25) return y += 25 << 248; // Twenty-five digits
                if (x < 1e26) return y += 26 << 248; // Twenty-six digits
                return y += 27 << 248; // Twenty-seven digits
            }

            y += ((x / 1e27 % 10) << 216)
                + ((x / 1e28 % 10) << 224)
                + ((x / 1e29 % 10) << 232);

            if (x < 1e30) {
                if (x < 1e28) return y += 28 << 248; // Twenty-eight digits
                if (x < 1e29) return y += 29 << 248; // Twenty-nine digits
                return y += 30 << 248; // Thirty digits
            }

            y += (x / 1e30 % 10) << 240; 
            return y += 31 << 248; // Thirty-one digits
        }
    }
}
