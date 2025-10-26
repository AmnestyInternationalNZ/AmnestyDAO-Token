## AmnestyDAO Smart Contracts (Aiken)

This package contains two on-chain components and their tests:
- `validators/governance/soulbound_governance.ak`: a minting policy for governance “soulbound” tokens minted into a vault.
- `validators/rewards/oracle_rewards.ak`: a spending validator authorizing reward distribution, gated by an oracle signature.

Supporting types/utilities live in `lib/constants.ak` and `lib/tests.ak`.

### Contracts overview

- Soulbound Governance (minting policy)
  - Parameterized by `PolicyParams { treasury: VerificationKeyHash, vault_hash: ScriptHash }`.
  - On `Mint { recipient }`, enforces:
    - The transaction is signed by the treasury key baked into the policy parameters.
    - At least one output is locked by the vault script (`vault_hash`).
    - The vault output carries an inline `VaultDatum` whose `owner` equals the `recipient` in the redeemer.
  - `Burn` is currently disabled (always fails).

- Oracle Rewards (spending validator)
  - Enforces:
    - The transaction is signed by the oracle public key hash derived from `oracle_verification_key()`.
    - The intended `recipient_addr` receives exactly `amount` of the configured `reward_policy_id`/`reward_token_name`.
    - No leakage: there are no additional outputs to third-party addresses aside from the recipient and one “change-back” output.

### What the current tests cover

- Governance minting policy tests: `validators/governance/soulbound_governance_test.ak`
  - `soulbound_mint_success`: Mints 10 governance tokens to the vault; signed by treasury; vault datum `owner` equals the redeemer `recipient`. Expected to pass.
  - `soulbound_mint_fail_not_signed_by_treasury` (fail): Missing treasury signature. Expected to fail.
  - `soulbound_mint_fail_not_to_vault` (fail): Tokens are sent to a non-vault address. Expected to fail.
  - `soulbound_mint_fail_not_recipient_owner` (fail): Vault datum `owner` does not match the redeemer `recipient`. Expected to fail.

- Rewards validator tests: `validators/rewards/oracle_rewards_test.ak`
  - `oracle_rewards_test_success`: Oracle-signed transfer of 10 reward tokens to the `recipient_addr`, with script change-back and no leakage. Expected to pass.
  - `oracle_rewards_test_fail_wrong_signatory` (fail): Extra signatory is not the oracle. Expected to fail.
  - `oracle_rewards_test_fail_no_signatory` (fail): No oracle signature. Expected to fail.
  - `oracle_rewards_test_fail_wrong_amount` (fail): Recipient receives an amount different from `redeemer.amount`. Expected to fail.
  - `oracle_rewards_test_fail_leaked` (fail): An additional third-party output (leak) is present. Expected to fail.
  - `oracle_rewards_test_fail_wrong_policy_id`: Named as a negative test, but currently uses the configured policy id and is not marked `fail`, so it effectively duplicates the success path. See “Limitations” below.

### Current limitations and gaps

- Governance minting policy
  - Does not assert that `tx.mint` only contains tokens under this policy id. An attacker could mint under multiple policy ids in the same transaction. This needs to be confirmed with design the exact governance tokens expected to be minted under this policy.
  - Does not constrain the minted quantity; any amount is permitted as long as other conditions hold. 
  - Only checks that there exists a vault-locked output with the correct datum; does not require exactly one or restrict additional non-vault outputs.
  - `Burn` is unimplemented (always false). If governance ever needs to revoke tokens, a safe burn path should be designed.
  - Naming: `vault_verification_key` in `constants.ak` is used as a script hash in tests; make sure a real vault ScriptHash is used for deployment (see notes below).

- Rewards validator
  - Leakage detection assumes a single non-recipient output belongs to the script (“change-back”). If multiple script outputs exist, logic may be brittle.
  - Does not assert `quantity_of(tx.mint, reward_policy_id, reward_token_name) == 0`; without this, minting could fake balances in outputs.
  - Does not verify that the consumed script input carried at least `amount` of the reward token or that the remaining script output decreased exactly by `amount`.
  - The “wrong policy id” test does not actually substitute a wrong policy id and is not marked `fail`.

- Constants and configuration
  - Placeholders in `lib/constants.ak` must be replaced with production values:
    - `reward_policy_id` and `reward_token_name`
    - `soulbound_governance_token_policy_id` and `soulbound_governance_token_name`
    - `treasury_verification_key`
    - `oracle_verification_key()` bytes (the PK is hashed to a PKH inside the validator)
    - `vault_hash` (ScriptHash) for the governance vault

### Recommendations for future improvements

- Governance minting policy
  - Enforce that all minted assets belong to this policy id and, optionally, to a fixed token name.
  - Constrain the exact minted amount per transaction according to business rules.
  - Require exactly one vault output (or a clearly bounded set) and assert no unintended extra recipients.
  - Implement a carefully controlled `Burn` branch, or explicitly document that burning is impossible and design migration paths accordingly.

- Rewards validator
  - Strengthen leakage checks: compute and compare the exact script address, and allow an explicit set of permissible outputs only.
  - Assert no net mint of the reward asset: `quantity_of(tx.mint, reward_policy_id, reward_token_name) == 0`.
  - Check that the input being spent carries sufficient reward balance and that the script change-back decreases by `amount`.
  - Expand negative tests: wrong policy id, wrong token name, multiple script outputs, multi-asset edge cases.

- Testing & quality
  - Add property-based tests/fuzzing for addresses, amounts, and output shapes.
  - Use golden tests for datums/redeemers serialization if produced off-chain.

### Build and test

install aiken by running `aiken` in your terminal

```sh
aiken build
```

Run all tests:

```sh
aiken check
```

You should see something like this 

<img width="948" height="759" alt="image" src="https://github.com/user-attachments/assets/f7c2a072-6d99-4804-9d5f-f548554de640" />


### Configuration

Set your network and other config in `aiken.toml`:

```toml
[config.default]
network_id = 1 # 0=Testnet (legacy), 1=Mainnet, 2=Preprod, 3=Preview, etc.
```

Alternatively, provide conditional environment modules under `env/`.

### Deployment notes (important)

- Replace all placeholder constants in `lib/constants.ak` with real values before building artifacts.
- For the governance policy, bake the correct `PolicyParams` at compile time: set the treasury VKH and the vault script hash. Ensure you are using a ScriptHash (not a VKH) for `vault_hash`.
- Ensure the vault script used in production actually enforces the soulbound semantics you expect for holding governance tokens.
- Verify the oracle key: `oracle_verification_key()` must be the exact verification key bytes used to derive the expected PKH on-chain.
- After building, distribute the resulting `plutus.json` or compiled scripts to your off-chain tooling for address derivation and transaction building.
- Always stage on a public test network (e.g., Preview/Preprod), run end-to-end tests, and only then deploy to Mainnet.
