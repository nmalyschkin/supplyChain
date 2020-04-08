var AllRoles = artifacts.require("AllRoles");

contract("AllRoles", function (accounts) {
    it("can set, check and delete roles", async () => {
        const allRoles = await AllRoles.deployed();

        assert.equal(await allRoles.hasRole(accounts[1], 3), false, "account 1 has wrong role");

        await allRoles.setRole(accounts[1], 3);
        assert.equal(await allRoles.hasRole(accounts[1], 3), true, "account 1 has wrong role");

        await allRoles.removeRole(accounts[1], { from: accounts[1] });
        assert.equal(await allRoles.hasRole(accounts[1], 0), true, "account 1 has wrong role");
    });
});
