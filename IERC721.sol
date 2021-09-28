//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//email: bi342k@hotmail.com

pragma solidity >0.7.0 <0.9.0;

import "./IERC165.sol";

interface IERC721 is IERC165{
    
    //events declaration
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenID);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenID);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    //view functions required for output for IERC721
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenID) external view returns (address owner);
    function getApproved(uint256 tokenID) external view returns (address operator);
    function isApprovedForAll(address owner, address operatpr) external view returns(bool);
    
    
    //transaction functions required for IERC721
    function transferFrom(address from, address to, uint256 tokenID) external;
    function safeTransferFrom(address from, address to, uint256 tokenID) external;
    function safeTransferFrom(address from, address to, uint256 tokenID, bytes memory data) external;
    function approve (address to, uint256 tokenID) external;
    function setApprovalForAll (address operator, bool approved) external;
    
}