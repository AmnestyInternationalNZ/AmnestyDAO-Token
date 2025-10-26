use cardano/transaction.{InlineDatum, NoDatum, Transaction, placeholder}
use constants.{
  Redeemer, RewardDatum, oracle_verification_key, pkh_from_vk, reward_policy_id,
  reward_token_name,
}
use rewards/oracle_rewards
use tests as t

test oracle_rewards_test_success() {
  // NOTE:These are all the parameters to set up pur test transaction
  // recipient address
  let recipient_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20")

  // script address
  let script_addr =
    t.scriptAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f10")

  // reward datum
  let reward = RewardDatum { recipient_addr, amount: 10 }

  // get oracle pkh
  let oracle_pkh = pkh_from_vk(oracle_verification_key())

  // starting balance
  let starting_asset = t.setAsset(reward_policy_id, reward_token_name, 100)
  // script input
  let oref =
    t.oref(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52", 1)
  let previous_script_output =
    t.output(script_addr, starting_asset, InlineDatum(reward))
  let script_input = t.input(oref, previous_script_output)
  // script outputs
  let script_output =
    t.output(
      script_addr,
      t.setAsset(reward_policy_id, reward_token_name, 90),
      InlineDatum(reward),
    )
  let recipient_output =
    t.output(
      recipient_addr,
      t.setAsset(reward_policy_id, reward_token_name, 10),
      NoDatum,
    )

  // transaction
  let tx =
    Transaction {
      ..placeholder,
      inputs: [script_input],
      outputs: [recipient_output, script_output],
      extra_signatories: [oracle_pkh],
    }

  // redeemer
  let redeemer = Redeemer { recipient_addr, amount: 10 }
  // transaction
  oracle_rewards.oracle_rewards.spend(None, redeemer, oref, tx)
}

test oracle_rewards_test_fail_wrong_signatory() fail {
  // NOTE:These are all the parameters to set up pur test transaction
  // recipient address
  let recipient_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20")

  // script address
  let script_addr =
    t.scriptAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f10")

  // reward datum
  let reward = RewardDatum { recipient_addr, amount: 10 }

  // starting balance
  let starting_asset = t.setAsset(reward_policy_id, reward_token_name, 100)
  // script input
  let oref =
    t.oref(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52", 1)
  let previous_script_output =
    t.output(script_addr, starting_asset, InlineDatum(reward))
  let script_input = t.input(oref, previous_script_output)
  // script outputs
  let script_output =
    t.output(
      script_addr,
      t.setAsset(reward_policy_id, reward_token_name, 90),
      InlineDatum(reward),
    )
  let recipient_output =
    t.output(
      recipient_addr,
      t.setAsset(reward_policy_id, reward_token_name, 10),
      NoDatum,
    )

  // transaction
  let tx =
    Transaction {
      ..placeholder,
      inputs: [script_input],
      outputs: [recipient_output, script_output],
      extra_signatories: ["Not_the_oracle_pkh"],
    }

  // redeemer
  let redeemer = Redeemer { recipient_addr, amount: 10 }
  // transaction
  oracle_rewards.oracle_rewards.spend(None, redeemer, oref, tx)
}

test oracle_rewards_test_fail_no_signatory() fail {
  // NOTE:These are all the parameters to set up pur test transaction
  // recipient address
  let recipient_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20")

  // script address
  let script_addr =
    t.scriptAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f10")

  // reward datum
  let reward = RewardDatum { recipient_addr, amount: 10 }

  // starting balance
  let starting_asset = t.setAsset(reward_policy_id, reward_token_name, 100)
  // script input
  let oref =
    t.oref(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52", 1)
  let previous_script_output =
    t.output(script_addr, starting_asset, InlineDatum(reward))
  let script_input = t.input(oref, previous_script_output)
  // script outputs
  let script_output =
    t.output(
      script_addr,
      t.setAsset(reward_policy_id, reward_token_name, 90),
      InlineDatum(reward),
    )
  let recipient_output =
    t.output(
      recipient_addr,
      t.setAsset(reward_policy_id, reward_token_name, 10),
      NoDatum,
    )

  // transaction
  let tx =
    Transaction {
      ..placeholder,
      inputs: [script_input],
      outputs: [recipient_output, script_output],
      extra_signatories: [],
    }

  // redeemer
  let redeemer = Redeemer { recipient_addr, amount: 10 }
  // transaction
  oracle_rewards.oracle_rewards.spend(None, redeemer, oref, tx)
}

test oracle_rewards_test_fail_wrong_amount() fail {
  // NOTE:These are all the parameters to set up pur test transaction
  // recipient address
  let recipient_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20")

  // script address
  let script_addr =
    t.scriptAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f10")

  // reward datum
  let reward = RewardDatum { recipient_addr, amount: 10 }

  // get oracle pkh
  let oracle_pkh = pkh_from_vk(oracle_verification_key())
  // starting balance
  let starting_asset = t.setAsset(reward_policy_id, reward_token_name, 100)
  // script input
  let oref =
    t.oref(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52", 1)
  let previous_script_output =
    t.output(script_addr, starting_asset, InlineDatum(reward))
  let script_input = t.input(oref, previous_script_output)
  // script outputs
  let script_output =
    t.output(
      script_addr,
      t.setAsset(reward_policy_id, reward_token_name, 90),
      InlineDatum(reward),
    )
  let recipient_output =
    t.output(
      recipient_addr,
      t.setAsset(reward_policy_id, reward_token_name, 20),
      NoDatum,
    )

  // transaction
  let tx =
    Transaction {
      ..placeholder,
      inputs: [script_input],
      outputs: [recipient_output, script_output],
      extra_signatories: [oracle_pkh],
    }

  // redeemer
  let redeemer = Redeemer { recipient_addr, amount: 10 }
  // transaction
  oracle_rewards.oracle_rewards.spend(None, redeemer, oref, tx)
}

test oracle_rewards_test_fail_leaked() fail {
  // NOTE:These are all the parameters to set up pur test transaction
  // recipient address
  let recipient_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20")

  // script address
  let script_addr =
    t.scriptAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f10")

  // leaked address
  let leaked_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f30")

  // reward datum
  let reward = RewardDatum { recipient_addr, amount: 10 }

  // get oracle pkh
  let oracle_pkh = pkh_from_vk(oracle_verification_key())
  // starting balance
  let starting_asset = t.setAsset(reward_policy_id, reward_token_name, 100)
  // script input
  let oref =
    t.oref(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52", 1)
  let previous_script_output =
    t.output(script_addr, starting_asset, InlineDatum(reward))
  let script_input = t.input(oref, previous_script_output)
  // script outputs
  let script_output =
    t.output(
      script_addr,
      t.setAsset(reward_policy_id, reward_token_name, 90),
      InlineDatum(reward),
    )
  let recipient_output =
    t.output(
      recipient_addr,
      t.setAsset(reward_policy_id, reward_token_name, 20),
      NoDatum,
    )
  let leaked_output =
    t.output(
      leaked_addr,
      t.setAsset(reward_policy_id, reward_token_name, 10),
      NoDatum,
    )

  // transaction
  let tx =
    Transaction {
      ..placeholder,
      inputs: [script_input],
      outputs: [recipient_output, script_output, leaked_output],
      extra_signatories: [oracle_pkh],
    }

  // redeemer
  let redeemer = Redeemer { recipient_addr, amount: 10 }
  // transaction
  oracle_rewards.oracle_rewards.spend(None, redeemer, oref, tx)
}

test oracle_rewards_test_fail_wrong_policy_id() {
  // NOTE:These are all the parameters to set up pur test transaction
  // recipient address
  let recipient_addr =
    t.walletAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20")

  // script address
  let script_addr =
    t.scriptAddress(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f10")

  // reward datum
  let reward = RewardDatum { recipient_addr, amount: 10 }

  // get oracle pkh
  let oracle_pkh = pkh_from_vk(oracle_verification_key())

  // starting balance
  let starting_asset = t.setAsset(reward_policy_id, reward_token_name, 100)
  // script input
  let oref =
    t.oref(#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52", 1)
  let previous_script_output =
    t.output(script_addr, starting_asset, InlineDatum(reward))
  let script_input = t.input(oref, previous_script_output)
  // script outputs
  let script_output =
    t.output(
      script_addr,
      t.setAsset(reward_policy_id, reward_token_name, 90),
      InlineDatum(reward),
    )
  let recipient_output =
    t.output(
      recipient_addr,
      t.setAsset(reward_policy_id, reward_token_name, 10),
      NoDatum,
    )

  // transaction
  let tx =
    Transaction {
      ..placeholder,
      inputs: [script_input],
      outputs: [recipient_output, script_output],
      extra_signatories: [oracle_pkh],
    }

  // redeemer
  let redeemer = Redeemer { recipient_addr, amount: 10 }
  // transaction
  oracle_rewards.oracle_rewards.spend(None, redeemer, oref, tx)
}
