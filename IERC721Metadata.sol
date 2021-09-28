//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//Email: bi342k@hotmail.com


pragma solidity >0.7.0 <0.9.0;

import "./IERC721.sol";

interface IERC721Metadata is IERC721{
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function tokenURI(uint256 tokenID) external view returns (string memory);
    
}