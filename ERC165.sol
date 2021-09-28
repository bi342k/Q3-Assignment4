//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//Email: bi342k@hotmail.com


pragma solidity >0.7.0 <0.9.0;

import "./IERC165.sol";

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool){
        return interfaceId == type(IERC165).interfaceId;
    }
}

