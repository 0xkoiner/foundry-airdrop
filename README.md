# Airdrop Token Claim with Merkle Proof 🌟

<h3>Features</h3>
• Merkle Proof Verification
  Verifies user eligibility for token claims by checking their inclusion in a predefined Merkle Tree.
• EIP-712 Implementation
  Ensures secure off-chain message signing for a streamlined claiming process.
• ECDSA Support
  Recovers the public key from a user’s signature to authenticate requests.
• Delegate Claim
  Users can delegate the claim process to another account, allowing someone else to call the claim function on their behalf.

<h3>How It Works</h3>
• Eligibility Verification: <br></br>
  The contract uses a Merkle Tree to verify if a user is eligible for the airdrop. Only accounts included in the Merkle Root can claim tokens. <br></br>
• Secure Signing: <br></br>
  Implements the EIP-712 standard for signing and verifying messages off-chain, adding an extra layer of security. <br></br>
• Claim Process: <br></br>
  Eligible users (or their delegates) call the claim function with their Merkle proof and signature to receive their tokens. <br></br>
• Delegated Claims: <br></br>
  Users can authorize another account to claim tokens on their behalf by providing a valid signature and Merkle proof. <br></br>

<h3>Contract Highlights</h3>
• `EIP-712:` Implements structured data signing to secure off-chain messages. <br></br>
• `Merkle Proof:` Validates inclusion in the Merkle Tree for eligibility. <br></br>
• `ECDSA:` Recovers the signer’s public key to authenticate claims. <br></br>
