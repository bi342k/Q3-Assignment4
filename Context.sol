//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//Email: bi342k@hotmail.com


pragma solidity >0.7.0 <0.9.0;

abstract contract Context{
    
    function _msgSender() internal view virtual returns(address){
        return msg.sender;
    }
    
    function _msgData() internal view virtual returns(bytes memory callData){
        return msg.data;
    }
    
}