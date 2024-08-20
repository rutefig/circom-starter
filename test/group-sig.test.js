const hre = require("hardhat");
const { assert } = require("chai");
const { buildMimcSponge } = require("circomlibjs");

describe.only("group sig circuit", () => {
  let circuit;
  let mimc;

  const mimcKey = 0;
  const mimcNumOutputs = 1;
  const sampleInput = {
    sk: "42",
    pk1: "10002",
    pk2: "10644022205700269842939357604110603061463166818082702766765548366499887869490",
    pk3: "28837",
    msgHash: "1234567890",
  };
  const sanityCheck = true;

  before(async () => {
    mimc = await buildMimcSponge();
    circuit = await hre.circuitTest.setup("group-sig");
  });

  it("produces a witness with valid constraints", async () => {
    const witness = await circuit.calculateWitness(sampleInput, sanityCheck);
    await circuit.checkConstraints(witness);
  });

  it("has expected witness values", async () => {
    const witness = await circuit.calculateLabeledWitness(
      sampleInput,
      sanityCheck
    );

    // Asserting input values
    assert.propertyVal(witness, "main.sk", sampleInput.sk);
    assert.propertyVal(witness, "main.pk1", sampleInput.pk1);
    assert.propertyVal(witness, "main.pk2", sampleInput.pk2);
    assert.propertyVal(witness, "main.pk3", sampleInput.pk3);
    assert.propertyVal(witness, "main.msgHash", sampleInput.msgHash);

    // Assert intermediate values
    // tmp = (pk - pk1) * (pk - pk2)
    // Because pk = pk2, tmp = 0
    assert.propertyVal(witness, "main.tmp", "0");

    assert.property(witness, "main.attestation");

    // TODO: Assert intermediate Mimc values
  });

  it("has the correct output", async () => {
    // TODO: check why this is passing even with wrong expected value
    const mimcResult = mimc.multiHash([sampleInput.sk, sampleInput.msgHash], mimcKey, mimcNumOutputs);
    const expected = { attestation: mimc.F.toObject(mimcResult) };
    const witness = await circuit.calculateWitness(sampleInput, sanityCheck);
    await circuit.assertOut(witness, expected);
  });
});
