pragma solidity ^0.4.20;

contract BookStore {
    
    address public owner;
    string public name;
    string public ipfsStoreImageAddress;
    string public email;
    uint public inventoryCount;
    
    struct Order {
        uint itemNumber;
        uint quantity;
        string shipAddr1;
        string shipAddr2;
        string shipCity;
        string shipState;
        string shipCountry;
        string shipZip;
        string shipEmail;
        string createdDate;
        string shipDate;
        string transactionNumber;
        uint totalAmount;
    }
    
    struct Item {
        uint number;
        string ipfsItemImageAddress;
        string description;
        uint price;
        uint quantity;
    }
    
    mapping(uint => Order) orders;
    Item[] items;
    
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
    
    constructor(address _storeOwner, string _nameOfStore, string _storeImage, string _storeEmail) public {
        require(_storeOwner != address(0));
        bytes memory storeEMail = bytes(_storeEmail);
        require(storeEMail.length != 0);
       
        
        owner = _storeOwner;
        name = _nameOfStore;
        ipfsStoreImageAddress = _storeImage;
        email = _storeEmail;
        inventoryCount = 0;
    }
    
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    
    function getStoreDetails() public constant returns(string _name,string _email,uint _balance){
        return (name, email, address(this).balance);
    }
    
    /* ------------------------------------ */
    /*             Items                    */
    /* ------------------------------------ */
    
    function addItemInventory(uint number, string ipfsItemImageAddress, string description, uint price, uint quantity) public restricted {
        require(number > 0);
        require(price > 0);
        require(quantity > 0);
        
        Item memory item = Item({
            number: number,
            ipfsItemImageAddress: ipfsItemImageAddress,
            description: description,
            price: price,
            quantity: quantity
        });
        
        items.push(item);
    }
    
    function getItemIndex(uint itemNumber) private view returns(int16){
        for(uint i = 0; i < items.length;i++){
            if(items[i].number == itemNumber){
                return int16(i);
            }
        }
        return -1;
    }
    
    function getItem(uint index) public view returns(uint price, string description, uint quantity){
        return (items[index].price, items[index].description,items[index].quantity);
    }
    
    /* ------------------------------------ */
    /*             Orders                   */
    /* ------------------------------------ */
    function placeOrder(uint itemNumber, uint quantity, string addr1, string addr2, string city, string state, string custEmail, 
        string zip, string country, string createdDate) public payable returns(uint16){
        require(items.length > 0 && itemNumber > 0 && quantity > 0);
        
        require(bytes(addr1).length > 0 && bytes(city).length > 0 && bytes(state).length > 0 &&
            bytes(zip).length > 0 && bytes(country).length > 0);
            
        int16 itemIndex = getItemIndex(itemNumber);
        require(itemIndex >= 0);
        require(items[uint(itemIndex)].quantity > 0 && items[uint(itemIndex)].quantity >= quantity);
        require(msg.value >= (items[uint(itemIndex)].price * quantity));
        
        Order memory order = Order({
            itemNumber: itemNumber,
            quantity: quantity,
            shipAddr1: addr1,
            shipAddr2: addr2,
            shipCity: city,
            shipState: state,
            shipZip: zip,
            shipCountry: country,
            shipEmail: custEmail,
            createdDate: createdDate,
            shipDate: "",
            transactionNumber: "",
            totalAmount: (items[uint(itemIndex)].price * quantity)
        });
        
        uint orderNumber = generateOrderNumber();
        orders[orderNumber] = order;
        items[uint(itemIndex)].quantity  = items[uint(itemIndex)].quantity - quantity;
        return uint16(orderNumber);
    }
    
    function getOrderDetails(uint orderNumber) public view returns( uint itemNumber, uint quantity, string createdDate, string shipDate, string transactionNumber, uint totalAmount){
        
        return (orders[orderNumber].itemNumber, orders[orderNumber].quantity,orders[orderNumber].createdDate, orders[orderNumber].shipDate,orders[orderNumber].transactionNumber,
            orders[orderNumber].totalAmount);
    }
    
    function getOrderShipInfo(uint orderNumber) public view returns(string shipAddr1,string shipAddr2, string shipCity,
        string shipState, string shipCountry, string shipZip, string shipEmail){
            
            return(orders[orderNumber].shipAddr1, orders[orderNumber].shipAddr2, orders[orderNumber].shipCity, orders[orderNumber].shipState, 
                orders[orderNumber].shipCountry, orders[orderNumber].shipZip, orders[orderNumber].shipEmail);
    }
    
    function generateOrderNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(now, block.difficulty, msg.sender)));
    }
}