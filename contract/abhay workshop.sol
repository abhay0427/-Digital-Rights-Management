// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalRightsManagement {
    address public owner;

    struct DigitalAsset {
        uint256 id;
        string title;
        string metadataURI;
        address creator;
        address currentOwner;
        bool isLicensed;
    }

    uint256 private nextAssetId = 1;
    mapping(uint256 => DigitalAsset) public assets;
    mapping(address => uint256[]) public ownerAssets;

    event AssetRegistered(uint256 indexed id, address indexed creator, string title);
    event AssetTransferred(uint256 indexed id, address indexed from, address indexed to);
    event LicenseGranted(uint256 indexed id, address indexed licensee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyAssetOwner(uint256 assetId) {
        require(msg.sender == assets[assetId].currentOwner, "Not asset owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerAsset(string memory title, string memory metadataURI) external {
        uint256 assetId = nextAssetId++;
        assets[assetId] = DigitalAsset(assetId, title, metadataURI, msg.sender, msg.sender, false);
        ownerAssets[msg.sender].push(assetId);

        emit AssetRegistered(assetId, msg.sender, title);
    }

    function transferOwnership(uint256 assetId, address newOwner) external onlyAssetOwner(assetId) {
        require(newOwner != address(0), "Invalid address");

        assets[assetId].currentOwner = newOwner;
        ownerAssets[newOwner].push(assetId);

        emit AssetTransferred(assetId, msg.sender, newOwner);
    }

    function grantLicense(uint256 assetId, address licensee) external onlyAssetOwner(assetId) {
        require(!assets[assetId].isLicensed, "Already licensed");

        assets[assetId].isLicensed = true;

        emit LicenseGranted(assetId, licensee);
    }

    function getAssetsByOwner(address assetOwner) external view returns (uint256[] memory) {
        return ownerAssets[assetOwner];
    }

    function getAssetDetails(uint256 assetId) external view returns (
        uint256 id,
        string memory title,
        string memory metadataURI,
        address creator,
        address currentOwner,
        bool isLicensed
    ) {
        DigitalAsset memory asset = assets[assetId];
        return (
            asset.id,
            asset.title,
            asset.metadataURI,
            asset.creator,
            asset.currentOwner,
            asset.isLicensed
        );
    }
}
