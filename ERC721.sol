//SPDX-License-Identifier: MIT
//Created by Muhammad Irfan
//Email: bi342k@hotmail.com

import "./IERC721.sol";
//import "./Library.sol";
import "./Address.sol";
import "./Strings.sol";
import "./Context.sol";
import "./IERC721Metadata.sol";
import "./ERC165.sol";
import "./IERC721Receiver.sol";

pragma solidity >0.7.0 <0.9.0;

contract ERC721 is IERC721, Context, IERC721Metadata, ERC165, IERC721Receiver {
    //Library function for string and address is delcared
    using Address for *;
    using Strings for *;
    
    //Variable declaration
    string private _name;
    string private _symbol;
    string private _BaseURI;
    address private contractOwner;
    uint8 private constant maxSupply = 100;
    uint256 private startTime;
    uint256 private stopTime;
    uint256 private tokenCounter;

    
    //mapping declaration
    mapping (uint256 => address) private _owners;   //from token ID to owner
    mapping (address => uint256) private _balances;   //owner address to token count
    mapping (uint256 => address) private _tokenApprovals;   //Token ID to approved address
    mapping (address => mapping(address => bool)) private _operatorApprovals;   //Owner to operator approvals
    mapping (uint256 => uint256) private _tokenPrice; //set token price of each token
    // mapping (uint256 => string) private _tokenURI; //set each token uri
    
    //create constructor
    constructor (string memory name_, string memory symbol_, string memory BaseURI_){
        _name = name_;
        _symbol = symbol_;
        contractOwner = _msgSender();
        startTime = block.timestamp + ((1/(24*60)) * 1 days);
        stopTime = startTime + (30 * 1 days);
        _BaseURI = BaseURI_;
        tokenCounter = 0;
    }
    
    //Modifier declaration
    modifier onlyOwner(){
        address sender = _msgSender();
        require (sender == contractOwner, "ERC721: You are not owner of contract");
        _;
    }
    
    //check support of interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool){
        return
        interfaceId == type(IERC721).interfaceId || 
        interfaceId == type(IERC721Metadata).interfaceId ||
        super.supportsInterface(interfaceId);
    }
    
    //set base URI and token URI
    function setBaseURI(string memory BaseURI_) public onlyOwner(){
        _BaseURI = BaseURI_;
    }
        function _baseURI() internal view returns (string memory){
        return _BaseURI;
    }
    
    //  //view functions required for output for IERC721
    function balanceOf(address owner) public view virtual override returns (uint256){
        require(owner != address(0),"No address mentioned");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenID) public view virtual override returns (address){
        address tokenOwner = _owners[tokenID];
        require (tokenOwner != address(0), "Wrong token ID");
        return tokenOwner;
    }
    function getApproved(uint256 tokenID) public view virtual override returns (address){
        require (_exist(tokenID), "Wrong token ID or token not exist");
        return _tokenApprovals[tokenID];
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns(bool){
        return _operatorApprovals[owner][operator];
    }
    function name() public view virtual override returns(string memory){
        return _name;
    }
    function symbol() public view virtual override returns(string memory){
        return _symbol;
    }
    function tokenURI(uint256 tokenID) public view virtual override returns (string memory){
        require (_exist(tokenID), "Wrong tokenID");
        string memory baseURI = _BaseURI;
        string memory TokenURI = bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenID.toString())) : "";
        return TokenURI;
    }
    function _getTokenPrice(uint256 tokenID) public view virtual returns(uint256 Ether){
        return _tokenPrice[tokenID];
    }
    function getContractBalance() public view returns (uint256 Ethers){
        return address(this).balance;
    }
    
    //transaction functions required for IERC721
    function approve (address to, uint256 tokenID) public virtual override{
        address tokenOwner = _owners[tokenID];
        require (to != address(0), "Receipent not specified");
        require(tokenOwner != to, "Can not approve to yourself");
        require(_msgSender() == tokenOwner || isApprovedForAll(tokenOwner,_msgSender()),"No approval or owner");
        _approve(to, tokenID);
    }
    function setApprovalForAll (address operator, bool approved) public virtual override{
        require(operator != _msgSender(), "cannot approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function transferFrom(address from, address to, uint256 tokenID) public virtual override{
        require (_isAppprovedOrOwner(from, tokenID), "no approval or not an owner");
        _transfer(from, to, tokenID);
    }
    function safeTransferFrom(address from, address to, uint256 tokenID) public virtual override{
        safeTransferFrom(from, to, tokenID, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenID, bytes memory data) public virtual override{
        require (_isAppprovedOrOwner(_msgSender(), tokenID), "Not owner or spender");
        _safeTransfer(from, to, tokenID, data);
    }
    function _setTokenPrice(uint256 tokenID, uint256 _price) public virtual onlyOwner returns(bool){
        require(_exist(tokenID), "Wrong token id or token not exist");
        _tokenPrice[tokenID] = _price;
        return true;
    }
    function purchaseToken(uint256 tokenID) public payable {
        require(block.timestamp >= startTime, "Sale has not yet started");
        require(block.timestamp <= stopTime, "Sale of token has been stoped");
        address from = ownerOf(tokenID);
        require(_msgSender() != address(0) && _msgSender() != address(this) && _msgSender() != from,"Error can to sale");
        require(_exist(tokenID), "token not exist");
        uint256 currentPrice = _tokenPrice[tokenID];
        require((msg.value)/(10**18) >= currentPrice, "Transfer amount is less than toke price");
        require (_isAppprovedOrOwner(from, tokenID), "no approval or not an owner");
        _transfer(from, _msgSender(), tokenID);
        emit Transfer(from, _msgSender(), tokenID);
    }
    
    //IERC721Receiver interface implemented
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual override returns (bytes4){}

    function _checkOnERC721Received(address from, address to, uint256 tokenID, bytes memory data) private returns(bool){
        if(to.isContract()){
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenID, data) returns (bytes4 retval){
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason){
                if (reason.length == 0){
                    revert("transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert (add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    
    //helper/data varification functions
    function _exist(uint256 tokenID) internal view virtual returns (bool){
        return _owners[tokenID] != address(0);
    }
    function _approve(address to, uint256 tokenID) internal virtual {
        _tokenApprovals[tokenID] = to;
        emit Approval(ownerOf(tokenID), to, tokenID);
    }
    function _isAppprovedOrOwner(address spender, uint256 tokenID) internal virtual returns(bool){
        require(_exist(tokenID),"Token not exist");
        address tokenOwner = _owners[tokenID];
        bool isApproved = (spender == tokenOwner || spender == getApproved(tokenID) || isApprovedForAll(tokenOwner, spender));
        return isApproved;
    }
    function _transfer(address from, address to, uint256 tokenID) internal virtual {
        require (_owners[tokenID] == from, "There is no token owner");
        require (to != address(0), "Specify reeipent address");
        
        _beforeTokenTransfer(_msgSender(), to, tokenID);
        _approve(address(0), tokenID); //clear approval of tokenID
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenID] = to;
        
        emit Transfer(from, to, tokenID);
    }
    function _safeTransfer(address from, address to, uint256 tokenID, bytes memory data) internal virtual{
        require (_exist(tokenID), "Token not exist");
        require (to !=address(0), "No address for receipent");
        _transfer (from, to, tokenID);
        require(_checkOnERC721Received(from, to, tokenID, data), "Transfer to non ERC721Receiver impletation");
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
    
    //Minting and burning functions

    function mint(uint256 tokenID, uint256 _price) external onlyOwner {
        address from = contractOwner;
        _safeMint(from, tokenID, _price);
    }
    
    function _safeMint(address to, uint256 tokenID, uint256 _price) internal virtual {
        _safeMint(to, tokenID, _price, "");
    }
    function _safeMint(address to, uint256 tokenID, uint256 _price, bytes memory data) internal virtual {
        _mint(to, tokenID, _price);
        require(_checkOnERC721Received(address(0), to, tokenID, data), "Minting to non ERC721Receiver implementer");
    }
    function _mint(address to, uint256 tokenID, uint256 _price) internal virtual {
        require(to != address(0), "No address given");
        require (!_exist(tokenID), "Token already minted");
        require (tokenCounter <= maxSupply, "Limit expired. No more minting allowed");
        
        _beforeTokenTransfer(_msgSender(), to, tokenID);
        _balances[to] += 1;
        _owners[tokenID] = to;
        tokenCounter += 1;
        _tokenPrice[tokenID] = _price;
        
        emit Transfer(_msgSender(), to, tokenID);
    }
    function burn(uint256 tokenID) public virtual {
        require(_isAppprovedOrOwner(_msgSender(), tokenID), "Not owner nor approved");
        _burn(tokenID);
    }
    function _burn(uint256 tokenID) internal virtual {
        address tokenOwner = _owners[tokenID];
        require (_msgSender() == tokenOwner, "you are not owner of the token");
        _beforeTokenTransfer(_msgSender(), address(0), tokenID);
        
        _approve(address(0), tokenID); //clear approval
        _balances[tokenOwner] -= tokenID;
        
        emit Transfer(tokenOwner, address(0), tokenID);
        
        
    }
    
    
}

// function _setTokenURI(uint256 tokenID, string memory baseURI_) internal virtual {
    //         require(!_exist(tokenID), "Can not set uri for already existing tokens");
    //         _tokenURI[tokenID] = string(abi.encodePacked(baseURI_, tokenID.toString())) ;
    // }  