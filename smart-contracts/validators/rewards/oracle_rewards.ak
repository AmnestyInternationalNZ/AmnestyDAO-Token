use aiken/collection/list
use cardano/assets.{quantity_of}
use cardano/transaction.{Datum, Output, OutputReference, Transaction}
use constants.{
  Redeemer, oracle_verification_key, pkh_from_vk, reward_policy_id, reward_token_name,
}

// --------- Main ---------
validator oracle_rewards {
  spend(_d: Option<Datum>, r: Redeemer, _o: OutputReference, tx: Transaction) {
    // check transaction is signed by the oracle
    let signed_by_oracle =
      list.has(tx.extra_signatories, pkh_from_vk(oracle_verification_key()))

    // check that the recipient is receiving the reward
    expect Some(reward_output) =
      list.find(tx.outputs, fn(o: Output) { o.address == r.recipient_addr })

    let must_be_equal_to_amount =
      quantity_of(reward_output.value, reward_policy_id, reward_token_name) == r.amount

    expect Some(script_address) =
      list.find(tx.outputs, fn(o: Output) { o.address != r.recipient_addr })
    // check for leakage
    let leaked =
      tx.outputs
        |> list.filter(
            fn(o: Output) {
              o.address != r.recipient_addr && o.address != script_address.address
            },
          )
        |> list.length

    and {
      signed_by_oracle,
      must_be_equal_to_amount,
      leaked == 0,
    }
  }

  else(_) {
    fail @"invalid redeemer"
  }
}
