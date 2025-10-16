use aiken/crypto.{ScriptHash, VerificationKeyHash}
use aiken/primitive/bytearray
use cardano/address.{Address, Script, VerificationKey}
use cardano/transaction.{Output}

pub type MintRedeemer {
  /// Mint soulbound tokens to `recipient`.
  Mint { recipient: VerificationKeyHash }
  /// Recipient burns soulbound tokens.
  Burn
}

pub type Redeemer {
  recipient_addr: Address,
  // who to pay
  amount: Int,
}

pub type RewardDatum {
  recipient_addr: Address,
  // who to pay
  amount: Int,
}

/// Datum expected by the vault script
pub type VaultDatum {
  owner: VerificationKeyHash,
}

/// Parameters baked into the minting policy at compile time/deploy time
pub type PolicyParams {
  /// Only this key can mint (treasury)
  treasury: VerificationKeyHash,
  /// The vault script hash where the token must live
  vault_hash: ScriptHash,
}
// oracle verification key hash
pub fn pkh_from_vk(vk: ByteArray) -> VerificationKeyHash {
  crypto.blake2b_224(vk)
}

/// Returns true if an output is locked by the given ScriptHash
pub fn is_locked_by_script(out: Output, script_hash: ScriptHash) -> Bool {
  when out.address.payment_credential is {
    Script(hash) -> hash == script_hash
    VerificationKey(_) -> False
  }
}

// how much of the reward token
pub const reward_policy_id: ByteArray =
  #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50" // TODO: change this to the actual reward policy id

pub const reward_token_name: ByteArray =
  #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f51" // TODO: change this to the actual reward token name

pub const vault_verification_key: ByteArray =
  #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f21"

pub fn oracle_verification_key() -> ByteArray {
  bytearray.from_int_big_endian(
    0x1f01bef4910289ae22d886bd4f045293425be4d35a6658d220f508061ca82fc0,
    32,
  )
}

// Treasury verification key used to authorize minting of soulbound tokens
pub const treasury_verification_key: ByteArray =
  #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f20"

pub const soulbound_governance_token_name: ByteArray =
  #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f51"

pub const soulbound_governance_token_policy_id: ByteArray =
  #"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
