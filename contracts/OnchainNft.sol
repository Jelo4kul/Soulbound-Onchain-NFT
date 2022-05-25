// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./HelperLibrary.sol";

/**
 * @title A Soulbound Onchain NFT Contract
 * @author Jelo
 * @notice A soulbound NFT that can't be transferred after mint. 
 *         It updates based on the amount of EXP tokens a user has.
 *         If a user has more than 100 EXP tokens, it shows only 100.
 */
contract OnchainNft is ERC721 {

    // -- States --
    IERC20 expErc20;
    address private owner;
    uint256 private currentTokenId;
    mapping(address => bool) private soulboundedAccounts;
    uint256[4] private levels = [25, 50, 75, 100];
    string[4] private  level_colors = ["#FFEC02", "#F6CE94", "#DEDDE3", "#8F1A44"];

    //  -- Modifiers --
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Sets the address of Ethernaut's ERC20 token during deployment
     * @param _expErc20 Address of the ERC20 token
    */
    constructor(IERC20 _expErc20) ERC721("Ethernaut Experience Point", "EthernautEXP") {
        expErc20 = _expErc20;
        owner = msg.sender;
    }

    /**
     * @dev Mint new tokens
    */
    function mintExp() public returns(uint256) {
        require(balanceOf(msg.sender) == 0, "Can't mint more than 1 token");
        currentTokenId += 1;
        _safeMint(msg.sender, currentTokenId);
        _disableTransfer(msg.sender);
        return currentTokenId;
    }

    /**
     * @dev Returns the tokenURI of a given tokenID
     * @param _tokenId An NFT's token ID
     * @return Returns a string that contains the tokenURI
    */
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory name = string(abi.encodePacked("Ethernaut EXP #", HelperLibrary.toString(_tokenId)));
        string memory description = "Ethernaut NFT is an onchain NFT that updates based on the amount of EXP token a wallet address owns";
        string memory image = generateBase64Image(_tokenId);
        return string(
            abi.encodePacked("data:application/json;base64,", HelperLibrary.encode(bytes(abi.encodePacked('{"name":"', name, '", ',  '"description":"', description, '", ', '"image":"', "data:image/svg+xml;base64,", image, '"}'))))
        );
    }

    /**
     * @dev A function that generates a base64 encoded version of an image
     * @param _tokenId The token Id of the NFT
     * @return Returns a string that contains the base64 encoding of a given image
    */
    function generateBase64Image(uint256 _tokenId) private view returns (string memory) {
        return HelperLibrary.encode(bytes(string(abi.encodePacked(
'<svg width="160" height="191" viewBox="0 0 160 191" fill="none" xmlns="http://www.w3.org/2000/svg">',
'<path opacity="0.3" fill-rule="evenodd" clip-rule="evenodd" d="M79.4702 1.59547C69.2602 16.3221 40.87 40.5373 0 30.7285V132.45C0 138.102 2.96689 151.099 14.8344 157.881C21.48 163.127 43.6426 176.894 79.4702 190.333V190.729C79.6471 190.663 79.8237 190.597 80 190.531C80.1763 190.597 80.3529 190.663 80.5298 190.728V190.333C116.357 176.894 138.52 163.127 145.166 157.881C157.033 151.099 160 138.102 160 132.45V30.7285C119.13 40.5373 90.7398 16.3222 80.5298 1.59549V0C80.36 0.267843 80.1833 0.53977 80 0.815474C79.8167 0.539776 79.64 0.267856 79.4702 1.93438e-05V1.59547Z" fill="',level_colors[getLevel(userBalance(_tokenId))],'"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M80.106 12.8796C70.9169 26.1336 45.3658 47.9273 8.58278 39.0993V130.649C8.58278 135.735 11.253 147.433 21.9338 153.536C27.9148 158.258 47.8611 170.649 80.106 182.743V183.099C80.2652 183.04 80.4241 182.981 80.5828 182.922C80.7414 182.981 80.9004 183.04 81.0596 183.099V182.743C113.304 170.649 133.251 158.258 139.232 153.536C149.913 147.433 152.583 135.735 152.583 130.649V39.0993C115.8 47.9273 90.2486 26.1336 81.0596 12.8796V11.4437C80.9067 11.6848 80.7478 11.9295 80.5828 12.1776C80.4178 11.9295 80.2588 11.6848 80.106 11.4437V12.8796Z" fill="#652A09"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M80.4026 18.5696C89.3875 31.529 114.371 52.8384 150.336 44.2066V133.722C150.336 138.695 147.726 150.133 137.282 156.101C131.434 160.718 111.931 172.833 80.4026 184.658V185.007C80.2469 184.949 80.0915 184.891 79.9364 184.833C79.7813 184.891 79.6259 184.949 79.4702 185.007V184.658C47.9419 172.833 28.4388 160.718 22.5907 156.101C12.1473 150.133 9.53642 138.695 9.53642 133.722V44.2066C45.502 52.8384 70.4854 31.529 79.4702 18.5696V17.1656C79.6197 17.4013 79.7751 17.6405 79.9364 17.8832C80.0978 17.6405 80.2532 17.4013 80.4026 17.1656V18.5696Z" fill="#A34A0B"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M82.4048 27.8812C89.9508 38.7653 110.933 56.662 141.139 49.4126V124.592C141.139 128.769 138.946 138.375 130.175 143.387C125.264 147.265 108.884 157.44 82.4048 167.372V167.664C82.274 167.616 82.1435 167.567 82.0132 167.518C81.883 167.567 81.7524 167.616 81.6217 167.664V167.372C55.1425 157.44 38.7627 147.265 33.8511 143.387C25.0802 138.375 22.8874 128.769 22.8874 124.592V49.4126C53.0933 56.662 74.0757 38.7653 81.6217 27.8812V26.702C81.7472 26.9 81.8777 27.1009 82.0132 27.3047C82.1487 27.1009 82.2793 26.9 82.4048 26.702V27.8812Z" fill="#CB8B50"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M9.53642 49.5894V129.907C9.53642 134.88 12.1473 146.318 22.5907 152.286C28.4388 156.903 47.9419 169.018 79.4702 180.844V181.192C79.6259 181.134 79.7813 181.076 79.9364 181.018L80.1194 181.087C80.2137 181.122 80.3081 181.157 80.4026 181.192V180.844C111.931 169.018 131.434 156.903 137.282 152.286C147.726 146.318 150.336 134.88 150.336 129.907V49.5894H9.53642Z" fill="#5D1F03"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M82.4048 27.8812C89.9508 38.7653 110.933 56.662 141.139 49.4126V124.592C141.139 128.769 138.946 138.375 130.175 143.387C125.264 147.265 108.884 157.44 82.4048 167.372V167.664C82.274 167.616 82.1435 167.567 82.0132 167.518C81.883 167.567 81.7524 167.616 81.6217 167.664V167.372C55.1425 157.44 38.7627 147.265 33.8511 143.387C25.0802 138.375 22.8874 128.769 22.8874 124.592V49.4126C53.0933 56.662 74.0757 38.7653 81.6217 27.8812V26.702C81.7472 26.9 81.8777 27.1009 82.0132 27.3047C82.1487 27.1009 82.2793 26.9 82.4048 26.702V27.8812Z" fill="#BC6002"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M140.382 49.6574C136.294 51.309 131.257 52.0077 125.124 51.4967C106.4 49.9364 87.7711 41.7059 80.106 27.0304C80.3724 26.6718 80.6254 26.3193 80.865 25.9739V24.7947C80.9905 24.9927 81.121 25.1936 81.2565 25.3974C81.392 25.1936 81.5225 24.9927 81.6481 24.7947V25.9739C89.194 36.858 110.176 54.7547 140.382 47.5053V49.6574Z" fill="#D87920"/>',
'<path fill-rule="evenodd" clip-rule="evenodd" d="M22.8874 49.6574C26.9759 51.309 32.013 52.0077 38.1457 51.4967C56.8694 49.9364 75.4986 41.7059 83.1638 27.0304C82.8974 26.6718 82.6443 26.3193 82.4048 25.9739V24.7947C82.2793 24.9927 82.1488 25.1936 82.0133 25.3974C81.8778 25.1936 81.7472 24.9927 81.6217 24.7947V25.9739C74.0757 36.858 53.0933 54.7547 22.8874 47.5053V49.6574Z" fill="#D87920"/>',
'<rect x="149.716" y="40.053" width="1.90728" height="13.351" transform="rotate(51.7449 149.716 40.053)" fill="#D87920"/>',
'<rect width="1.90728" height="15.042" transform="matrix(-0.493532 0.869728 0.869728 0.493532 10.4777 40.053)" fill="#D87920"/>',
'<path d="M9.53641 41.9603L22.7505 50.0662H9.53642L9.53641 41.9603Z" fill="#5D1F03"/>',
'<path d="M150.539 41.9603L141.139 50.0662H150.539L150.539 41.9603Z" fill="#5D1F03"/>',
'<path d="M116.344 48.6358L120.159 47.6821L119.205 150.676L116.344 151.629L118.252 150.676V81.0051L116.344 48.6358Z" fill="white" fill-opacity="0.2"/>',
'<path d="M114.437 49.5894L118.252 48.6358V152.583H114.437H117.298L116.344 81.9588L114.437 49.5894Z" fill="#5D1F03"/>',
'<path d="M61.9868 42.9139L64.8477 43.8676L64.8477 61.0332H62.3046H63.5762L62.3046 48.3179L61.9868 42.9139Z" fill="#5D1F03"/>',
'<path d="M57.2461 160.801L53.404 161.107L57.2729 101.086L61.0795 101.331L58.2245 101.147L56.5476 141.988L57.2461 160.801Z" fill="#5D1F03"/>',
'<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="',level_colors[getLevel(userBalance(_tokenId))],'">',HelperLibrary.toString(numberToDisplay(_tokenId)),'</text>',
  '<style> text{font-size: 40pt; font-weight: 800;}</style></svg>'
))));
    } 

    /**
     * @dev The number of EXP tokens to display on tue NFT
     * @param _tokenId The token Id of the NFT
     * @return Returns the number to be displayed
    */
    function numberToDisplay(uint256 _tokenId) private view returns (uint256) {
        uint256 balance = userBalance(_tokenId);
        return balance == 0 ? 0 : balance > 100 ? 100 : balance;
    }

    /**
     * @dev Gets the EXP balance of a given user.
     * @param _tokenId The token Id of the user's NFT that will be used to get the user's address.
     * @return _balance The user's balance.
    */
    function userBalance(uint256 _tokenId) private view returns (uint _balance) {
        _balance = expErc20.balanceOf(ownerOf(_tokenId))/(10**18);
    }

    /**
     * @dev Get the corresponding level of a user, given the user's EXP balance
     * @param _balance The user's EXP balance
     * @return Returns The the user's level
    */
    function getLevel(uint _balance) private view returns(uint256) {
        for(uint i = 0; i < levels.length; i++) {
            if(_balance <= levels[i]){
                return i;
            }
        }
        //
        revert();
    }

    /**
     * @dev Disables the transfer feature of a soulbounded account
     * @param _account Account to check
    */
    function _disableTransfer(address _account) private {
        soulboundedAccounts[_account] = true;
    }

     /**
     * @dev Overriden in order to disable transfer
     */
    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual override {
        require(_canTransfer(owner), "Transfer Disabled");
        super._transfer(_from, _to, _tokenId);
    }


    /**
     * @dev Return if the _account can transfer out tokens(soulbounded) or not
     * @param _account Account to check
     * @return False if the account is soulbounded 
    */
    function _canTransfer(address _account) private view returns(bool) {
        return !soulboundedAccounts[_account];
    }

}