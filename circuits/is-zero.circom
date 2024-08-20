pragma circom 2.0.3;

template IsZero () {
    signal input x;

    signal mulInv;

    mulInv <-- x == 0 ? 0 : 1 / x;
    
    // Returns 0 if the value is not zero
    signal output out;
    out <== mulInv * x - 1;
    x * out === 0;
}

component main = IsZero();