//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//email: bi342k@hotmail.com

pragma solidity >0.7.0 <0.9.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
    
}