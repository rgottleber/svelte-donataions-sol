import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Fundraiser is Ownable {
    using SafeMath for uint256;

    struct Donation {
        uint256 value;
        uint256 date;
    }
    mapping(address => Donation[]) private _donations;

    event DonationReceived(address indexed donor, uint256 value);
    event Withdraw(uint256 amount);

    string public name;
    string public image;
    string public description;

    address payable public beneficiary;
    address private _owner;

    uint256 public totalDonations;
    uint256 public donationsCount;

    constructor(
        string memory _name,
        string memory _image,
        string memory _description,
        address payable _beneficiary,
        address _custodian
    ) public {
        name = _name;
        image = _image;
        description = _description;
        beneficiary = _beneficiary;
        _owner = _custodian;
    }

    function setBeneficiary(address payable _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function donate() public payable {
        Donation memory donation = Donation({
            value: msg.value,
            date: block.timestamp
        });
        _donations[msg.sender].push(donation);
        totalDonations = totalDonations.add(msg.value);
        donationsCount++;

        emit DonationReceived(msg.sender, msg.value);
    }

    function myDonationsCount() public view returns (uint256) {
        return _donations[msg.sender].length;
    }

    function myDonationsAmount()
        public
        view
        returns (uint256[] memory values, uint256[] memory dates)
    {
        uint256 count = myDonationsCount();
        values = new uint256[](count);
        dates = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            Donation storage donation = _donations[msg.sender][i];
            values[i] = donation.value;
            dates[i] = donation.date;
        }
        return (values, dates);
    }

    function myDonations()
        public
        view
        returns (uint256[] memory values, uint256[] memory dates)
    {
        uint256 count = myDonationsCount();
        values = new uint256[](count);
        dates = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            Donation storage donation = _donations[msg.sender][i];
            values[i] = donation.value;
            dates[i] = donation.date;
        }
        return (values, dates);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        beneficiary.transfer(balance);
        emit Withdraw(balance);
    }

    receive() external payable {
        totalDonations = totalDonations.add(msg.value);
        donationsCount++;
    }
}
