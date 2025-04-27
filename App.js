
const contractAddress = "0x340dad9C19485CeC4dC76F86b7B06dB3Ec15D257";


const abi = [
    "function contribute() external payable",
    "function withdrawFunds() external",
    "function requestRefund() external",
    "function checkBalance() external view returns (uint256)",
    "function getGoal() external view returns (uint256)",
    "function getTotalRaised() external view returns (uint256)",
    "function getDeadline() external view returns (uint256)",
    "function getTimeLeft() external view returns (uint256)",
    "function getContractInfo() external view returns (address,uint256,uint256,uint256,uint256)",
    "function getCampaignStatus() external view returns (string memory)"
];

let provider;
let signer;
let contract;

async function connectWallet() {
    if (window.ethereum) {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddress, abi, signer);
        alert("Wallet Connected ✅");
    } else {
        alert("Please install MetaMask!");
    }
}

async function contribute() {
    const amount = document.getElementById("amount").value;
    if (!amount) return alert("Enter amount to contribute!");

    const tx = await contract.contribute({ value: ethers.utils.parseEther(amount) });
    await tx.wait();
    alert("Contribution Successful 🎉");
}

async function withdrawFunds() {
    try {
        const tx = await contract.withdrawFunds();
        await tx.wait();
        alert("Funds Withdrawn Successfully ✅");
    } catch (error) {
        alert(`Withdraw Failed ❌\n${error.reason || error.message}`);
    }
}

async function requestRefund() {
    try {
        const tx = await contract.requestRefund();
        await tx.wait();
        alert("Refund Issued ✅");
    } catch (error) {
        alert(`Refund Failed ❌\n${error.reason || error.message}`);
    }
}

async function fetchCampaignInfo() {
    const [owner, goal, raised, balance, deadline] = await contract.getContractInfo();
    const status = await contract.getCampaignStatus();
    const timeLeft = await contract.getTimeLeft();

    document.getElementById("info").innerHTML = `
        <p><b>Owner:</b> ${owner}</p>
        <p><b>Goal:</b> ${ethers.utils.formatEther(goal)} ETH</p>
        <p><b>Total Raised:</b> ${ethers.utils.formatEther(raised)} ETH</p>
        <p><b>Contract Balance:</b> ${ethers.utils.formatEther(balance)} ETH</p>
        <p><b>Deadline:</b> ${new Date(deadline * 1000).toLocaleString()}</p>
        <p><b>Time Left:</b> ${timeLeft} seconds</p>
        <p><b>Campaign Status:</b> ${status}</p>
    `;
}
