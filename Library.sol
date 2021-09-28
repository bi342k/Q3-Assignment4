//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//Email: bi342k@hotmail.com


pragma solidity >0.7.0 <0.9.0;

library myLibrary {
    
    function toString(uint256 value) internal pure returns (string memory) {
       
        if (value == 0) {
            return "0";
        }
       
        uint256 temp = value;
        uint256 digits;
       
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
       
        bytes memory buffer = new bytes(digits);
       
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
       
        return string(buffer);
    }
    
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        
        assembly {
            size := extcodesize(account)
        }
        
        return size > 0;
    }
    
}