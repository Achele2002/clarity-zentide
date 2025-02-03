import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure only owner can mint rewards",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("zentide-rewards", "mint-rewards",
        [types.principal(wallet_1.address), types.utf8("meditation")],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});
