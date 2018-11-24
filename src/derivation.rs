use std::convert::TryFrom;

use bip39::{Mnemonic, MnemonicType, Language};
use ed25519_dalek::{PublicKey, SecretKey};
use sha2::{Digest,Sha256,Sha512};

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
pub enum GenerateKeyType {
    // Lisk, RISE, Shift etc.
    LiskPassphrase,
    PrivateKey,
}

fn ed25519_privkey_to_pubkey(sec: &[u8; 32]) -> [u8; 32] {
    let secret_key = SecretKey::from_bytes(sec).unwrap();
    let public_key = PublicKey::from_secret::<Sha512>(&secret_key);
    public_key.to_bytes()
}

pub fn entropy_to_lisk_passphrase(entropy: &[u8; 16]) -> String {
    let mnemonic = Mnemonic::from_entropy(entropy, MnemonicType::Type12Words, Language::English, "").unwrap();
    mnemonic.get_string()
}

pub fn cut_last_16(indata: &[u8; 32]) -> &[u8; 16] {
    <&[u8; 16]>::try_from(&indata[16..32]).unwrap()
}

pub fn secret_to_pubkey(key_material: [u8; 32], generate_key_type: GenerateKeyType) -> [u8; 32] {
    match generate_key_type {
        GenerateKeyType::LiskPassphrase => {
            let mnemonic = entropy_to_lisk_passphrase(cut_last_16(&key_material));
            let hash = Sha256::digest(mnemonic.as_bytes());
            let hash_with_right_length = <&[u8; 32]>::try_from(&hash[0..32]).unwrap();
            ed25519_privkey_to_pubkey(hash_with_right_length)
        },
        GenerateKeyType::PrivateKey => ed25519_privkey_to_pubkey(&key_material),
    }
}

pub fn pubkey_to_address(pubkey: &[u8; 32]) -> u64 {
    let hash = Sha256::digest(pubkey);
    let first_eight_bytes = <&[u8; 8]>::try_from(&hash[0..8]).unwrap();
    return u64::from_le_bytes(*first_eight_bytes);
}

#[cfg(test)]
mod tests {
    // importing names from outer (for mod tests) scope.
    use super::*;

    #[test]
    fn test_ed25519_secret_to_pubkey() {
        // TEST 1 from https://tools.ietf.org/html/rfc8032#section-7.1
        let mut privkey = [0u8; 32];
        privkey.copy_from_slice(
            &hex::decode("9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60")
                .unwrap(),
        );
        let mut expected_pubkey = [0u8; 32];
        expected_pubkey.copy_from_slice(
            &hex::decode("d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")
                .unwrap(),
        );
        assert_eq!(ed25519_privkey_to_pubkey(&privkey), expected_pubkey);
    }

    #[test]
    fn test_entropy_to_lisk_passphrase() {
        // https://github.com/iov-one/iov-core/blob/v0.9.1/packages/iov-crypto/src/bip39.spec.ts#L13
        let mut entropy = [0u8; 16];

        entropy.copy_from_slice(
            &hex::decode("00000000000000000000000000000000").unwrap(),
        );
        assert_eq!(
            entropy_to_lisk_passphrase(&entropy),
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        );

        entropy.copy_from_slice(
            &hex::decode("7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f").unwrap(),
        );
        assert_eq!(
            entropy_to_lisk_passphrase(&entropy),
            "legal winner thank year wave sausage worth useful legal winner thank yellow"
        );

        entropy.copy_from_slice(
            &hex::decode("80808080808080808080808080808080").unwrap(),
        );
        assert_eq!(
            entropy_to_lisk_passphrase(&entropy),
            "letter advice cage absurd amount doctor acoustic avoid letter advice cage above"
        );

        entropy.copy_from_slice(
            &hex::decode("ffffffffffffffffffffffffffffffff").unwrap(),
        );
        assert_eq!(
            entropy_to_lisk_passphrase(&entropy),
            "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong"
        );
    }

    #[test]
    fn test_secret_to_pubkey_from_privkey() {
        // TEST 1 from https://tools.ietf.org/html/rfc8032#section-7.1
        let mut privkey = [0u8; 32];
        privkey.copy_from_slice(
            &hex::decode("9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60")
                .unwrap(),
        );
        let mut expected_pubkey = [0u8; 32];
        expected_pubkey.copy_from_slice(
            &hex::decode("d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")
                .unwrap(),
        );
        assert_eq!(
            secret_to_pubkey(privkey, GenerateKeyType::PrivateKey),
            expected_pubkey
        );
    }

    #[test]
    fn test_pubkey_to_address() {
        // https://testnet-explorer.lisk.io/address/6076671634347365051L
        let mut pubkey = [0u8; 32];
        pubkey.copy_from_slice(
            &hex::decode("f4852b270f76dc8b49bfa88de5906e81d3b001d23852f0e74ba60cac7180a184")
                .unwrap(),
        );
        assert_eq!(
            pubkey_to_address(&pubkey),
            6076671634347365051u64
        );
    }
}
