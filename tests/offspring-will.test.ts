
import { describe, expect, it } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

/*
  The test below is an example. To learn more, read the testing documentation here:
  https://docs.hiro.so/stacks/clarinet-js-sdk
*/

describe("example tests", () => {
  it("ensures simnet is well initalised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  // it("shows an example", () => {
  //   const { result } = simnet.callReadOnlyFn("counter", "get-counter", [], address1);
  //   expect(result).toBeUint(0);
  // });
});

describe("Non-existent offspring-wallet", () => {
  it("Get non-existent offspring-wallet, return none", () => {
    const contractSource = simnet.callReadOnlyFn("offspring-will", "get-offspring-wallet", [Cl.principal(address1)], address1);
    expect(contractSource.result).toBeNone;
  })
})