pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template GroupSig () {
    signal input sk;

    signal input pk1;
    signal input pk2;
    signal input pk3;

    // This will be used if we want to be able to reveal and deny the msg
    signal output attestation;

    // Now this proof will be tied to a message which means
    // We can't use the same proof for different messages
    signal input msgHash;

    // MiMCSponge(nInputs, nRounds, nOutputs)
    // the nRounds will define the security bits, it is advisable to be at least 220
    // has one input signal array `ins` and one output signal array `outs`
    component pkGen = MiMCSponge(1, 220, 1);
    pkGen.ins[0] <== sk;
    pkGen.k <== 0; // this is a salt

    signal pk;
    pk <== pkGen.outs[0];

    // Constraint that pk should be one of the given public keys (pk1 or pk2 or pk3)
    // (pk - pk1) * (pk - pk2) * (pk - pk3) === 0;
    // But we need to breakdown the above equation into quadratic expressions
    signal tmp;
    tmp <== (pk - pk1) * (pk - pk2);
    tmp * (pk - pk3) === 0;

    component attestGen = MiMCSponge(2, 220, 1); // inputs are sk and msgHash, and the output will be attestation
    attestGen.ins[0] <== sk;
    attestGen.ins[1] <== msgHash;
    attestGen.k <== 0; // this is just a salt

    attestation <== attestGen.outs[0];
}

component main { public [ pk1, pk2, pk3, msgHash ] } = GroupSig();