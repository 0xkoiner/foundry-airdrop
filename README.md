# Airdrop Token Claim with Merkle Proof 🌟

<h3>Features</h3>
* Merkle Proof Verification
  Verifies user eligibility for token claims by checking their inclusion in a predefined Merkle Tree.
* EIP-712 Implementation
  Ensures secure off-chain message signing for a streamlined claiming process.
* ECDSA Support
  Recovers the public key from a user’s signature to authenticate requests.
* Delegate Claim
  Users can delegate the claim process to another account, allowing someone else to call the claim function on their behalf.

<h3>How It Works</h3>
* Eligibility Verification:
  The contract uses a Merkle Tree to verify if a user is eligible for the airdrop. Only accounts included in the Merkle Root can claim tokens.
* Secure Signing:
  Implements the EIP-712 standard for signing and verifying messages off-chain, adding an extra layer of security.
* Claim Process:
  Eligible users (or their delegates) call the claim function with their Merkle proof and signature to receive their tokens.
* Delegated Claims:
  Users can authorize another account to claim tokens on their behalf by providing a valid signature and Merkle proof.

<h3>Contract Highlights</h3>
- `EIP-712:` Implements structured data signing to secure off-chain messages.
- `Merkle Proof:` Validates inclusion in the Merkle Tree for eligibility.
- `ECDSA:` Recovers the signer’s public key to authenticate claims.
