use cardano/assets as assets
use cardano/transaction.{InlineDatum, Transaction, placeholder}
use constants.{
  Mint, PolicyParams, VaultDatum, soulbound_governance_token_policy_id, soulbound_governance_token_name,
  treasury_verification_key, vault_verification_key,
}
use governance/soulbound_governance
use tests as t

test soulbound_mint_success() {
  let vault_addr = t.scriptAddress(vault_verification_key)
  let recipient_keyhash =
    #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f21"

  let params =
    PolicyParams { treasury: treasury_verification_key, vault_hash: vault_verification_key }

  let vaultDatum = VaultDatum { owner: recipient_keyhash }

  // Outputs: mint 10 token to the vault with the recipient as the owner
  let vault_output =
    t.output(
      vault_addr,
      t.setAsset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      InlineDatum(vaultDatum),
    )

  // Transaction includes mint of +1 and is signed by treasury
  let tx =
    Transaction {
      ..placeholder,
      outputs: [vault_output],
      mint: assets.from_asset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      extra_signatories: [treasury_verification_key],
    }

  let mint_redeemer = Mint { recipient: recipient_keyhash }

  soulbound_governance.soulbound_governance.mint(
    params,
    mint_redeemer,
    soulbound_governance_token_policy_id,
    tx,
  )?
}

test soulbound_mint_fail_not_signed_by_treasury() fail {
  let vault_addr = t.scriptAddress(vault_verification_key)
  let recipient_pkh =
    #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f21"

  let params =
    PolicyParams { treasury: treasury_verification_key, vault_hash: vault_verification_key }

  let vaultDatum = VaultDatum { owner: recipient_pkh }

  // Outputs: mint 10 token to the vault with the recipient as the owner
  let vault_output =
    t.output(
      vault_addr,
      t.setAsset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      InlineDatum(vaultDatum),
    )

  // Transaction includes mint of +10 but is NOT signed by treasury
  let tx =
    Transaction {
      ..placeholder,
      outputs: [vault_output],
      mint: assets.from_asset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      extra_signatories: [],
    }

  let mint_redeemer = Mint { recipient: recipient_pkh }

  soulbound_governance.soulbound_governance.mint(
    params,
    mint_redeemer,
    soulbound_governance_token_policy_id,
    tx,
  )
}

test soulbound_mint_fail_not_to_vault() fail {
  let recipient_pkh =
    #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f21"
  let recipient_addr = t.walletAddress(recipient_pkh)

  let params =
    PolicyParams { treasury: treasury_verification_key, vault_hash: vault_verification_key }

  // Wrong owner in the vault datum (does not match redeemer.recipient)
  let vaultDatum = VaultDatum { owner: recipient_pkh }

  // Outputs: mint 10 token to the vault but with wrong owner set in datum
  let vault_output =
    t.output(
      recipient_addr,
      t.setAsset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      InlineDatum(vaultDatum),
    )

  // Transaction is signed by treasury but delivers to vault with wrong owner
  let tx =
    Transaction {
      ..placeholder,
      outputs: [vault_output],
      mint: assets.from_asset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      extra_signatories: [treasury_verification_key],
    }

  let mint_redeemer = Mint { recipient: recipient_pkh }

  soulbound_governance.soulbound_governance.mint(
    params,
    mint_redeemer,
    soulbound_governance_token_policy_id,
    tx,
  )
}

test soulbound_mint_fail_not_recipient_owner() fail {  
  let vault_addr = t.scriptAddress(vault_verification_key)
  let recipient_keyhash =
    #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f21"
  let not_recipient_keyhash =
    #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f22"

  let params =
    PolicyParams { treasury: treasury_verification_key, vault_hash: vault_verification_key }

  let vaultDatum = VaultDatum { owner: not_recipient_keyhash }

  // Outputs: mint 10 token to the vault with the recipient as the owner
  let vault_output =
    t.output(
      vault_addr,
      t.setAsset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      InlineDatum(vaultDatum),
    )

  // Transaction includes mint of +1 and is signed by treasury
  let tx =
    Transaction {
      ..placeholder,
      outputs: [vault_output],
      mint: assets.from_asset(soulbound_governance_token_policy_id, soulbound_governance_token_name, 10),
      extra_signatories: [treasury_verification_key],
    }

  let mint_redeemer = Mint { recipient: recipient_keyhash }

  soulbound_governance.soulbound_governance.mint(
    params,
    mint_redeemer,
    soulbound_governance_token_policy_id,
    tx,
  )?
}


