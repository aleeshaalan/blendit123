pragma solidity ^0.4.11;

import "./Owned.sol";

contract MarketPlace is Owned {

  // Custom types
  struct Land {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;
    
  }

  //mapping for land selling and buying
  mapping(uint => Land) public lands;
  uint landCounter;
  uint ethCounter=9183;
  
  //mapping to check whether to show land
  mapping(uint =>bool) public isAllowToDisplay;
  
  //funtion to allow display
  function allowToDisplay(uint _id) public
  {
      isAllowToDisplay[_id]=true;
  }
  
  //funtion to disallow display
  function disallowToDisplay(uint _id) public
  {
      isAllowToDisplay[_id]=false;
  }

  //events
  event sellLandEvent(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
    );

  event buyLandEvent(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
    );

  event returnLandEvent(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
    );
  
  function sellLand(string _name, string _description, uint256 _price) public {
            // a new land
            landCounter++;
            _price=_price/ethCounter;
        
            //store this land
            lands[landCounter] = Land(
                landCounter,
                msg.sender,
                0x0,
                _name,
                _description,
                _price
              );
        
            
            emit sellLandEvent(landCounter, msg.sender, _name, _price);
  }

  
  function getNumberOfLands() public constant returns (uint) {
         return landCounter;
  }

  
  function getLandsForSale() public constant returns (uint[]) {
            if(landCounter == 0) {
              return new uint[](0);
            }
        
            uint[] memory landIds = new uint[](landCounter);
        
            uint numberOfLandsForSale = 0;
            for (uint i = 1; i <= landCounter; i++) {
              if (lands[i].buyer == 0x0) {
                landIds[numberOfLandsForSale] = lands[i].id;
                numberOfLandsForSale++;
              }
            }
        
            uint[] memory forSale = new uint[](numberOfLandsForSale);
            for (uint j = 0; j < numberOfLandsForSale; j++) {
              forSale[j] = landIds[j];
            }
            return (forSale);
  }
  
  //get Lands sold
    function getLandsSold() public constant returns (uint[]) {
            if(landCounter == 0) {
                    return new uint[](0);
            }
        
            uint[] memory landSoldIds = new uint[](landCounter);
        
            uint numberOfLandsSold = 0;
            for (uint i = 1; i <= landCounter; i++) {
              if (lands[i].buyer != 0x0) {
                landSoldIds[numberOfLandsSold] = lands[i].id;
                numberOfLandsSold++;
              }
            }
        
            uint[] memory forReturn = new uint[](numberOfLandsSold);
            for (uint j = 0; j < numberOfLandsSold; j++) {
              forReturn[j] = landSoldIds[j];
            }
            return (forReturn);
  }

  function buyLand(uint _id) payable public {
            // we check whether there is at least one land
            require(landCounter > 0);
        
            // we check whether the land exists
            require(_id > 0 && _id <= landCounter);
        
            // we retrieve the land
            Land storage land = lands[_id];
        
            // we check whether the land has not already been sold
            require(land.buyer == 0x0);
        
            // we don't allow the seller to buy his/her own land
            require(land.seller != msg.sender);
        
            // we check whether the value sent corresponds to the land price
            //require(land.price == msg.value);
        
            // keep buyer's information
            land.buyer = msg.sender;
        
            // the buyer can buy the land
            land.seller.transfer(msg.value);
        
           
            emit buyLandEvent(_id, land.seller, land.buyer, land.name, land.price);
    }
    
    //funtion to return the land
    function returnLand(uint _id) public {
            // we check whether there is at least one land
            require(landCounter > 0);
        
            // we check whether the land exists
            require(_id > 0 && _id <= landCounter);
        
            // we retrieve the land
            Land storage land = lands[_id];
        
            // we check whether the land has  already been sold the same person
            require(land.buyer == msg.sender);
        
            // we don't allow the seller to buy his/her own land
            //require(land.seller != msg.sender);
        
            // we check whether the value sent corresponds to the land price
            //require(land.price == msg.value);
            
            // keep buyer's information
            land.buyer = 0x0;
        
           
            emit returnLandEvent(_id, land.seller, land.buyer, land.name, land.price);
    } 

  //kill the smart contract
  function kill() public onlyOwner {
             selfdestruct(owner);
  }
}
