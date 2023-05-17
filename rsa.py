from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP


def get_keys(size):
    if size < 1024: size = 1024
    priKey = RSA.generate(size)
    pubKey = priKey.publickey()
    return pubKey, priKey


def encrypt(pubKey, msg):
    msg = msg.encode()
    encryptor = PKCS1_OAEP.new(pubKey)
    encrypted = encryptor.encrypt(msg)
    return encrypted


def decrypt(priKey, encrypted):
    decryptor = PKCS1_OAEP.new(priKey)
    decrypted = decryptor.decrypt(encrypted)
    return decrypted


if __name__ == '__main__':
    pubKey, priKey = get_keys(128)
    enc_aeskey = encrypt(pubKey, 'Hello World!')
    print('Encrypted:', enc_aeskey)
    dec_aeskey = decrypt(priKey, enc_aeskey)
    print('Decrypted:', dec_aeskey)
