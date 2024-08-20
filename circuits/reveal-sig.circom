pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template RevealSigner () {
    signal input sk;
    signal input pk;
    signal input msgHash;
    signal input attestation;

    // prove that PubKeyGen(sk) === pk
    component pkGen = MiMCSponge(1, 220, 1);
    pkGen.ins[0] <== sk;
    pkGen.k <== 0;
    pk === pkGen.outs[0];

    // prove that Hash(sk, msg) === attestation
    component attestGen = MiMCSponge(2, 220, 1);
    attestGen.ins[0] <== sk;
    attestGen.ins[1] <== msgHash;
    attestGen.k <== 0;
    attestation === attestGen.outs[0];
}

component main { public [ pk, msgHash, attestation ] } = RevealSigner();