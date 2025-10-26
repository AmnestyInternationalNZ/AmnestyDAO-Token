use aiken/collection/list
use cardano/transaction.{InlineDatum, Output, Transaction}
use constants.{
  Burn, Mint, MintRedeemer, PolicyParams, VaultDatum, is_locked_by_script,
}

/// Minting policy
validator soulbound_governance(params: PolicyParams) {
  mint(redeemer: MintRedeemer, _p, self: Transaction) {
    let Transaction { outputs, extra_signatories, .. } = self

    when redeemer is {
      Mint { recipient } -> {
        // must be signed by treasury
        let signed_by_treasury = list.has(extra_signatories, params.treasury)

        // must go to soulbound vault
        expect Some(vault_output) =
          list.find(
            outputs,
            fn(o) { is_locked_by_script(o, params.vault_hash) },
          )
        // get output datum
        expect InlineDatum(d) = vault_output.datum
        expect v: VaultDatum = d

        and {
          v.owner == recipient,
          signed_by_treasury?,
        }
      }

      Burn -> False
    }
  }

  else(_) {
    fail
  }
}
