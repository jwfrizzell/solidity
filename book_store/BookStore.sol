pragma solidity ^0.4.20;

contract BookStore {
    
    address public owner;
    string public name;
    string public ipfsStoreImageAddress;
    string public email;
    
    struct Order {
        uint itemNumber;
        uint quantity;
        string shippingInfo;
        string shipEmail;
        string createdDate;
        string shipDate;
        string transactionNumber;
        uint totalAmount;
        uint msgValue;
    }
    
    struct Item {
        uint number;
        string ipfsItemImageAddress;
        string description;
        uint price;
        uint quantity;
    }
    
    mapping(uint => Order) orders;
    mapping(uint => Item) items;
    
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
    
    constructor(address _storeOwner, string _nameOfStore, string _storeImage, string _storeEmail) public {
        require(_storeOwner != address(0));
        require(_storeOwner == msg.sender);
        
        bytes memory storeEMail = bytes(_storeEmail);
        require(storeEMail.length != 0);
       
        owner = _storeOwner;
        name = _nameOfStore;
        ipfsStoreImageAddress = _storeImage;
        email = _storeEmail;
    }
    
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    
    function getStoreDetails() public view returns(
        string _name,
        string _email,
        uint _balance){
            
        return (
                name, 
                email, 
                address(this).balance
               );
    }
    
    /* ------------------------------------ */
    /*             Items                    */
    /* ------------------------------------ */
    
    function addItemInventory(string ipfsItemImageAddress, string description, uint price, uint quantity) public restricted returns(uint64) {
        require(price > 0);
        require(quantity > 0);
        
        uint64 newItemNumber = generateUniqueNumber();
        
        Item memory item = Item({
            number: newItemNumber,
            ipfsItemImageAddress: ipfsItemImageAddress,
            description: description,
            price: price,
            quantity: quantity
        });
        
        items[newItemNumber] = item;
        return newItemNumber;
    }
    
    function adjustInventoryForItem(uint itemNumber, uint qtyToRemove) private {
        items[itemNumber].quantity = qtyToRemove;
    }
    
    function removeItemFromInventory(uint itemNumber)public restricted{
        delete items[itemNumber];
    }
    
    function getItem(uint index) public view returns(
        uint price, 
        string description, 
        uint quantity){
            
        return (
                items[index].price, 
                items[index].description,
                items[index].quantity
               );
    }
    
    /* ------------------------------------ */
    /*             Orders                   */
    /* ------------------------------------ */
    function placeOrder(uint itemNumber, uint quantity, string shippingInfo, string custEmail, string createdDate) public payable returns(uint64){
        require(itemNumber > 0 && quantity > 0);
        
        require(bytes(shippingInfo).length > 0);
            
        Item memory item = items[itemNumber];
        require(item.number >= 0 && item.quantity > 0 && item.quantity >= quantity);
        require(msg.value >= (item.price * quantity));
        
        Order memory order = Order({
            itemNumber: itemNumber,
            quantity: quantity,
            shippingInfo: shippingInfo,
            shipEmail: custEmail,
            createdDate: createdDate,
            shipDate: "",
            transactionNumber: "",
            totalAmount: (item.price * quantity),
            msgValue: msg.value
        });
        
        uint64 orderNumber = generateUniqueNumber();
        orders[orderNumber] = order;
        adjustInventoryForItem(itemNumber, item.quantity - quantity);
        return orderNumber;
    }
    
    function getOrderDetails(uint orderNumber) public view returns( 
        uint itemNumber, 
        uint quantity, 
        string createdDate, 
        string shipDate, 
        string transactionNumber, 
        uint totalAmount,
        string shippingInfo){
        
        return (
                orders[orderNumber].itemNumber, 
                orders[orderNumber].quantity,
                orders[orderNumber].createdDate, 
                orders[orderNumber].shipDate,
                orders[orderNumber].transactionNumber,
                orders[orderNumber].totalAmount,
                orders[orderNumber].shippingInfo
               );
    }
    
    function setTracking(uint orderNumber, string trackingNumber, string shippingDate)public restricted {
        orders[orderNumber].transactionNumber = trackingNumber;
        orders[orderNumber].shipDate = shippingDate;
    }
    
    function removeOrder(uint orderNumber)public restricted {
        delete orders[orderNumber];
    }
    
    /* ------------------------------------ */
    /*             Helper                   */
    /* ------------------------------------ */
    function generateUniqueNumber() private view returns (uint64) {
        return uint64(uint(keccak256(abi.encodePacked(now, block.difficulty, msg.sender))));
    }
    
}