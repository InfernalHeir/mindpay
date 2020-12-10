const Mindpay = artifacts.require("Mindpay.sol");

module.exports = async (deployer,accounts) => {
    const name = "MINDPAY";
    const symbol = "MIND";
    const supply = web3.utils.toWei("500000");
    await deployer.deploy(Mindpay, name,symbol,supply);
}