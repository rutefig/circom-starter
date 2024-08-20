pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template GroupSig () {
    signal input sk;

    signal input pk1;
    signal input pk2;
    signal input pk3;

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
}

component main { public [ pk1, pk2, pk3 ] } = GroupSig();