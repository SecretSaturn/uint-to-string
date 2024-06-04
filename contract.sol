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


    /// @notice Helper function to convert a uint256 to its string representation
    /// @param x The uint256 value to convert
    /// @return y The string representation of the uint256 value
    function itoa31 (uint256 x) private pure returns (uint256 y) {
        unchecked {
            // Initialize the byte sequence with 0x30 (ASCII '0') and a leading byte for zero count
            y = 0x0030303030303030303030303030303030303030303030303030303030303030
                // Convert the number into ASCII digits and place them in the correct position
                + (x % 10)
                + ((x / 1e1 % 10) << 8);

            // 16-1 digits
            if (x < 1e16) {
                // 8-1 digits
                if (x < 1e8) {
                    // 4-1 digits
                    if (x < 1e4) {
                        // 2-1 digits
                        if (x < 1e2) {
                            // 1 digit
                            if (x < 1e1) {
                                return y += 1 << 248;
                            }
                            // 2 digits
                            else {
                                return y += 2 << 248;
                            }
                        }
                        // 3 digits
                        else if(x < 1e3) {
                            return y += ((x * 0x290) & (0xf << 16)) | (3 << 248);
                        }
                        // 4 digits
                        else {
                            return y += ((x / 1e2 % 10) << 16)
                                      + ((x * 0x418a) & (0xf << 24)) | (4 << 248);
                        }
                    }
                    // 6-5 digits
                    else {
                        y += ((x / 1e2 % 10) << 16)
                           + ((x / 1e3 % 10) << 24);

                        // 6-5 digits
                        if (x < 1e6) {
                            // 5 digits
                            if (x < 1e5) {
                                return y += ((x * 0x68db9) & (0xf << 32)) | (5 << 248);
                            }
                            // 6 digits
                            else {
                                return y += ((x / 1e4 % 10) << 32)
                                          + ((x * 0xa7c5ad) & (0xf << 40)) | (6 << 248);
                            }
                        }
                        // 7 digits
                        else {
                            y += ((x / 1e4 % 10) << 32)
                               + ((x / 1e5 % 10) << 40);

                            if(x < 1e7) {
                                return y += ((x * 0x10c6f7a1) & (0xf << 48)) | (7 << 248);
                            }
                            // 8 digits
                            else {
                                return y += ((x / 1e6 % 10) << 48)
                                          + ((x * 0x1ad7f29ac) & (0xf << 56)) | (8 << 248);
                            }
                        }
                    }
                }
                // 16-9 digits
                else {
                    y += ((x / 1e2 % 10) << 16)
                       + ((x / 1e3 % 10) << 24)
                       + ((x / 1e4 % 10) << 32)
                       + ((x / 1e5 % 10) << 40)
                       + ((x / 1e6 % 10) << 48)
                       + ((x / 1e7 % 10) << 56);

                    // 12-9 digits
                    if (x < 1e12) {
                        // 10-9 digits
                        if (x < 1e10) {
                            // 9 digits
                            if (x < 1e9) {
                                return y += ((x * 0x2af31dc462) & (0xf << 64)) | (9 << 248);
                            }
                            // 10 digits
                            else {
                                return y += ((x / 1e8 % 10) << 64)
                                        + ((x * 0x44b82fa09b6) & (0xf << 72)) | (10 << 248);
                            }
                        }
                        // 11 digits
                        else if (x < 1e11) {
                            return y += ((x / 1e8 % 10) << 64)
                                    + ((x / 1e9 % 10) << 72)
                                    + ((x * 0x6df37f675ef7) & (0xf << 80)) | (11 << 248);
                        }
                        // 12 digits
                        else {
                            return y += ((x / 1e8 % 10) << 64)
                                    + ((x / 1e9 % 10) << 72)
                                    + ((x / 1e10 % 10) << 80)
                                    + ((x * 0xafebff0bcb24b) & (0xf << 88)) | (12 << 248);
                        }
                    }
                    // 16-13 digits
                    else {
                        y += ((x / 1e8 % 10) << 64)
                           + ((x / 1e9 % 10) << 72)
                           + ((x / 1e10 % 10) << 80)
                           + ((x / 1e11 % 10) << 88);

                        // 14-13 digits
                        if (x < 1e14) {
                            // 13 digits
                            if (x < 1e13) {
                                return y += ((x * 0x119799812dea112) & (0xf << 96)) | (13 << 248);
                            }
                            // 14 digits
                            else {
                                return y += ((x / 1e12 % 10) << 96)
                                        + ((x * 0x1c25c268497681c3) & (0xf << 104)) | (14 << 248);
                            }
                        }
                        // 16-15 digits
                        else {
                            y += ((x / 1e12 % 10) << 96)
                               + ((x / 1e13 % 10) << 104);

                            // 15 digits
                            if(x < 1e15) {
                                return y += ((x * 0x2d09370d42573603e) & (0xf << 112)) | (15 << 248);
                            }
                            // 16 digits
                            else {
                                return y += ((x / 1e14 % 10) << 112)
                                          + ((x * 0x480ebe7b9d58566c88) & (0xf << 120)) | (16 << 248);
                            }
                        }
                    }
                }
            }
            // 31-17 digits
            else {
                y += ((x / 1e2 % 10) << 16)
                   + ((x / 1e3 % 10) << 24)
                   + ((x / 1e4 % 10) << 32)
                   + ((x / 1e5 % 10) << 40)
                   + ((x / 1e6 % 10) << 48)
                   + ((x / 1e7 % 10) << 56)
                   + ((x / 1e8 % 10) << 64);

                y += ((x / 1e9 % 10) << 72)
                   + ((x / 1e10 % 10) << 80)
                   + ((x / 1e11 % 10) << 88)
                   + ((x / 1e12 % 10) << 96)
                   + ((x / 1e13 % 10) << 104)
                   + ((x / 1e14 % 10) << 112)
                   + ((x / 1e15 % 10) << 120);

                // 24-17 digits
                if (x < 1e24) {
                    // 20-17 digits
                    if (x < 1e20) {
                        // 18-17 digits
                        if (x < 1e18) {
                            // 17 digits
                            if (x < 1e17) {
                                return y += ((x * 0x734aca5f6226f0ada62) & (0xf << 128)) | (17 << 248);
                            }
                            // 18 digits
                            else {
                                return y += ((x / 1e16 % 10) << 128)
                                          + ((x * 0xb877aa3236a4b44909bf) & (0xf << 136)) | (18 << 248);
                            }
                        }
                        // 20-19 digits
                        else {
                            y += ((x / 1e16 % 10) << 128)
                               + ((x / 1e17 % 10) << 136);

                            // 19 digits
                            if (x < 1e19) {
                                return y += ((x * 0x12725dd1d243aba0e75fe7) & (0xf << 144)) | (19 << 248);
                            }
                            // 20 digits
                            else {
                                return y += ((x / 1e18 % 10) << 144)
                                          + ((x * 0x1d83c94fb6d2ac34a5663d4) & (0xf << 152)) | (20 << 248);
                            }
                        }
                    }
                    // 24-21 digits
                    else {
                        y += ((x / 1e16 % 10) << 128)
                            + ((x / 1e17 % 10) << 136)
                            + ((x / 1e18 % 10) << 144)
                            + ((x / 1e19 % 10) << 152);

                        // 22-21 digits
                        if (x < 1e22) {
                            // 21 digits
                            if (x < 1e21) {
                                return y += ((x * 0x2f394219248446baa23d2ec8) & (0xf << 160)) | (21 << 248);
                            }
                            // 22 digits
                            else {
                                return y += ((x / 1e20 % 10) << 160)
                                          + ((x * 0x4b8ed0283a6d3df769fb7e0b8) & (0xf << 168)) | (22 << 248);
                            }
                        }
                        // 24-23 digits
                        else {
                            y += ((x / 1e20 % 10) << 160)
                               + ((x / 1e21 % 10) << 168);

                            // 23 digits
                            if (x < 1e23) {
                                return y += ((x * 0x78e480405d7b9658a99263458a) & (0xf << 176)) | (23 << 248);
                            }
                            // 24 digits
                            else {
                                return y += ((x / 1e22 % 10) << 176)
                                          + ((x * 0xc16d9a0095928a2775b7053c0f2) & (0xf << 184)) | (24 << 248);
                            }
                        }
                    }
                }
                // 31-25 digits
                else {
                    y += ((x / 1e16 % 10) << 128)
                        + ((x / 1e17 % 10) << 136)
                        + ((x / 1e18 % 10) << 144)
                        + ((x / 1e19 % 10) << 152)
                        + ((x / 1e20 % 10) << 160)
                        + ((x / 1e21 % 10) << 168)
                        + ((x / 1e22 % 10) << 176)
                        + ((x / 1e23 % 10) << 184);

                    // 28-25 digits
                    if (x < 1e28) {
                        // 26-25 digits
                        if (x < 1e26) {
                            // 25 digits
                            if (x < 1e25) {
                                return y += ((x * 0x1357c299a88ea76a58924d52ce4f3) & (0xf << 192)) | (25 << 248);
                            }
                            // 26 digits
                            else {
                                return y += ((x / 1e24 % 10) << 192)
                                          + ((x * 0x1ef2d0f5da7dd8aa27507bb7b07ea5) & (0xf << 200)) | (26 << 248);
                            }
                        }
                        // 28-27 digits
                        else {
                            y += ((x / 1e24 % 10) << 192)
                               + ((x / 1e25 % 10) << 200);

                            // 27 digits
                            if (x < 1e27) {
                                return y += ((x * 0x318481895d962776a54d92bf80caa07) & (0xf << 208)) | (27 << 248);
                            }
                            // 28 digits
                            else {
                                return y += ((x / 1e26 % 10) << 208)
                                          + ((x * 0x4f3a68dbc8f03f243baf513267aa9a3f) & (0xf << 216)) | (28 << 248);
                            }
                        }
                    }
                    // 31-29
                    else {
                        y += ((x / 1e24 % 10) << 192)
                           + ((x / 1e25 % 10) << 200)
                           + ((x / 1e26 % 10) << 208)
                           + ((x / 1e27 % 10) << 216);

                        // 30-29 digits
                        if (x < 1e30) {
                            // 29 digits
                            if (x < 1e29) {
                                return y += ((x * 0x7ec3daf941806506c5e54eb70c4429fe4) & (0xf << 224)) | (29 << 248);
                            }
                            // 30 digits
                            else {
                                return y += ((x / 1e28 % 10) << 224)
                                          + ((x * 0xcad2f7f5359a3b3e096ee45813a0433060) & (0xf << 232)) | (30 << 248);
                            }
                        }
                        // 31 digits
                        else {
                            return y += ((x / 1e28 % 10) << 224)
                                      + ((x / 1e29 % 10) << 232)
                                      + ((x / 1e30 % 10) << 240) | (31 << 248);
                        }
                    }
                }
            }
        }
    }
}
