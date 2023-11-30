const BLOCK_SIZE: usize = 64;

const BLOCK_BYTES: usize = BLOCK_SIZE / 8;

pub fn feistel_round<F>(
    left: &[u8; BLOCK_BYTES / 2],
    right: &[u8; BLOCK_BYTES / 2],
    key: &[u8; BLOCK_BYTES / 2],
    round_func: &F,
) -> [u8; BLOCK_BYTES / 2]
where
    F: Fn(&[u8; BLOCK_BYTES / 2], &[u8; BLOCK_BYTES / 2]) -> [u8; BLOCK_BYTES / 2],
{
    let mut new_left = [0u8; BLOCK_BYTES / 2];
    new_left.copy_from_slice(left);

    let round_output = round_func(right, key);

    for (i, byte) in round_output.into_iter().enumerate() {
        new_left[i] ^= byte;
    }

    new_left
}

pub fn feistel_encrypt<F>(
    block: &[u8; BLOCK_BYTES],
    keys: &Vec<&[u8; BLOCK_BYTES / 2]>,
    round_func: &F,
) -> [u8; BLOCK_BYTES]
where
    F: Fn(&[u8; BLOCK_BYTES / 2], &[u8; BLOCK_BYTES / 2]) -> [u8; BLOCK_BYTES / 2],
{
    let mut left = [0u8; BLOCK_BYTES / 2];
    let mut right = [0u8; BLOCK_BYTES / 2];

    left.copy_from_slice(&block[..BLOCK_BYTES / 2]);
    right.copy_from_slice(&block[BLOCK_BYTES / 2..]);

    for key in keys {
        let new_left = feistel_round(&left, &right, key, round_func);

        left = right;
        right = new_left;
    }

    let mut output = [0u8; BLOCK_BYTES];
    output[..BLOCK_BYTES / 2].copy_from_slice(&right);
    output[BLOCK_BYTES / 2..].copy_from_slice(&left);
    output
}

pub fn feistel_decrypt<F>(
    block: &[u8; BLOCK_BYTES],
    keys: &Vec<&[u8; BLOCK_BYTES / 2]>,
    round_func: &F,
) -> [u8; BLOCK_BYTES]
where
    F: Fn(&[u8; BLOCK_BYTES / 2], &[u8; BLOCK_BYTES / 2]) -> [u8; BLOCK_BYTES / 2],
{
    feistel_encrypt(block, &keys.iter().cloned().rev().collect(), round_func)
}
