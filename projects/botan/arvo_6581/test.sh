#!/usr/bin/env bash

cd ${SRC:-/src}/botan

echo "=== Configuring botan with sanitizers ==="
./configure.py --cc-bin=clang++ --cc-abi-flags='-O0 -g -fsanitize=address -stdlib=libc++' \
  --ldflags='-lc++' --disable-shared --unsafe-fuzzer-mode
if [ $? -ne 0 ]; then
    echo "Configuration failed"
    exit 1
fi

echo ""
echo "=== Building tests ==="
make -j$(nproc) tests
if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

echo ""
echo "=== Running botan test suite ==="

# - x509_path_extended: Contains expired certificate validation tests that fail"
# - PKCS11 tests: Require unavailble symbol C_GetFunctionList

TEST_OUTPUT=$(./botan-test \
  aead asn1 asn1_printer auto_rng_unit base64 bc_pad bcrypt bigint_unit \
  block bn_add bn_div bn_gcd bn_invmod bn_isprime bn_lshift bn_mod bn_mul \
  bn_powmod bn_ressol bn_rshift bn_sqr bn_sub certstor chacha_rng \
  chacha_rng_unit charset cpuid cryptobox curve25519_keygen curve25519_rt \
  curve25519_scalar dh_invalid dh_kat dh_keygen dl_group dlies dlies_unit \
  dsa_keygen dsa_param dsa_sign ecc_invalid ecc_pointmul ecc_randomized \
  ecc_unit ecdh_kat ecdh_keygen ecdh_unit ecdsa_invalid ecdsa_keygen \
  ecdsa_sign ecdsa_unit ecgdsa_keygen ecgdsa_sign ecies ecies_iso ecies_unit \
  eckcdsa_keygen eckcdsa_sign ed25519_curdle ed25519_sign elgamal_encrypt \
  elgamal_keygen entropy ffi filter fpe_fe1 gf2m gost_3410_keygen \
  gost_3410_sign gost_3410_verify hash hkdf_expand_label hmac_drbg \
  hmac_drbg_unit hostname iv_carryover kdf mac mceliece modes mp_unit \
  newhope nist_key_wrap nist_key_wrap_invalid nist_redc ocb_long \
  ocb_long_wide ocb_wide ocsp octetstring oid os_utils otp_hotp otp_totp \
  package_transform passhash9 pbkdf pem pgp_s2k_iter pk_pad_eme \
  pk_pad_emsa_unit pk_workfactor pkcs_hash_id poly_dbl psk_db rdrand_rng \
  rfc3394 rfc6979 rsa_blinding rsa_encrypt rsa_kem rsa_keygen rsa_pss \
  rsa_pss_raw rsa_sign rsa_verify rsa_verify_invalid simd_32 siv_ad sm2_enc \
  sm2_sig srp6 stream system_rng testcode tls tls_alert_strings \
  tls_algo_strings tls_cbc_padding tls_ciphersuites tls_messages tls_policy \
  tls_policy_text tss util util_dates x509_path_bsi x509_path_name_constraint \
  x509_path_nist x509_path_rsa_pss x509_path_x509test x509_unit xmss_keygen \
  xmss_sign xmss_verify 2>&1)
EXIT_CODE=$?

echo "$TEST_OUTPUT"

echo ""
echo "========================================="
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "✓ Tests completed successfully"
    echo "========================================="
    exit 0
else
    echo "✗ Tests failed (exit code: $EXIT_CODE)"
    echo "========================================="
    exit 1
fi
