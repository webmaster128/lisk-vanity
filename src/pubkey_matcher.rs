use num_bigint::BigInt;
use num_traits::pow;

use derivation::pubkey_to_address;

// largest valid address
pub fn max_address(max_len: usize) -> u64 {
    if max_len >= 20 { 18446744073709551615u64 } else { pow(10u64, max_len) - 1 }
}

pub struct PubkeyMatcher {
    max_address_value: u64,
}

impl PubkeyMatcher {
    pub fn new(max_len: usize) -> PubkeyMatcher {
        assert!(max_len >= 1);

        PubkeyMatcher {
            max_address_value: max_address(max_len),
        }
    }

    pub fn matches(&self, pubkey: &[u8; 32]) -> bool {
        let address = pubkey_to_address(pubkey);
        // longest address: 18446744073709551615 (20 chars)
        //
        // Example max_len = 15
        // Short address: 999999999999999 (15 chars)
        // Strict upper bound = 10^15 = 1000000000000000
        return address <= self.max_address_value
    }

    pub fn estimated_attempts(&self) -> BigInt {
        let number_of_good = BigInt::from(self.max_address_value) + BigInt::from(1);
        return (BigInt::from(1) << 64) / number_of_good;
    }
}

#[cfg(test)]
mod tests {
    // importing names from outer (for mod tests) scope.
    use super::*;

    #[test]
    fn test_max_address() {
        assert_eq!(max_address(2000), 18446744073709551615u64);
        assert_eq!(max_address(200), 18446744073709551615u64);
        assert_eq!(max_address(20), 18446744073709551615u64);
        assert_eq!(max_address(15), 999999999999999u64);
        assert_eq!(max_address(10), 9999999999u64);
        assert_eq!(max_address(2), 99u64);
        assert_eq!(max_address(1), 9u64);
    }

    #[test]
    fn test_estimated_attempts() {
        let matcher_all = PubkeyMatcher::new(10000);
        let estimated = matcher_all.estimated_attempts();
        assert_eq!(estimated, BigInt::from(1));

        // truncate(2^64 / 10^15)
        let matcher_fifteen = PubkeyMatcher::new(15);
        let estimated = matcher_fifteen.estimated_attempts();
        assert_eq!(estimated, BigInt::from(18446));

        // truncate(2^64 / 10^10)
        let matcher_ten = PubkeyMatcher::new(10);
        let estimated = matcher_ten.estimated_attempts();
        assert_eq!(estimated, BigInt::from(1844674407));

        // truncate(2^64 / 10^5)
        let matcher_five = PubkeyMatcher::new(5);
        let estimated = matcher_five.estimated_attempts();
        assert_eq!(estimated, BigInt::from(184467440737095u64));

        // truncate(2^64 / 10^3)
        let matcher_three = PubkeyMatcher::new(3);
        let estimated = matcher_three.estimated_attempts();
        assert_eq!(estimated, BigInt::from(18446744073709551u64));
    }
}