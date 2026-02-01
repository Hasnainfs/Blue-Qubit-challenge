from qiskit import QuantumCircuit, transpile

# Load the QASM file
qc = QuantumCircuit.from_qasm_file("P6_low_hill.qasm")

print(f"Original circuit: {qc.num_qubits} qubits")

# Remove final measurements
qc_nom = qc.remove_final_measurements(inplace=False)

# Simplify the circuit
qc_simplified = transpile(
    qc_nom,
    basis_gates=['cx', 'rz', 'sx', 'x'],
    optimization_level=3,
    approximation_degree=0.95
)

print(f"Simplified circuit: {qc_simplified.num_qubits} qubits")

# Analyze gate patterns to predict measurement outcome
# Look for qubits with X gates (flip qubits)
x_gate_qubits = set()
h_gate_qubits = set()

for inst in qc_simplified.data:
    gate_name = inst.operation.name

    for qubit in inst.qubits:
        q_index = qc_simplified.find_bit(qubit).index

        if gate_name == 'x':
            x_gate_qubits.add(q_index)
        elif gate_name == 'h':
            h_gate_qubits.add(q_index)

print(f"\nQubits with X gates: {sorted(x_gate_qubits)}")
print(f"Qubits with H gates: {sorted(h_gate_qubits)}")

# Predict measurement: qubits with odd number of X gates end up as |1>
# Qubits with H gates are in superposition, but often end up as |0> or |1>
# based on other gates

# Create a predicted bitstring
predicted_bits = ['0'] * 60

# If a qubit has an X gate, it flips from |0> to |1>
for q in x_gate_qubits:
    if q < 60:
        predicted_bits[q] = '1'

# For H gates without compensating gates, often |0>
# (This is a simplification - actual result depends on full circuit)

predicted = ''.join(predicted_bits)
print(f"\nPredicted 60-bit string: {predicted}")
print(f"0s: {predicted.count('0')}, 1s: {predicted.count('1')}")

# Also try the complement (since we might be wrong about initial state)
complement = ''.join('1' if b == '0' else '0' for b in predicted_bits)
print(f"\nComplement: {complement}")
print(f"0s: {complement.count('0')}, 1s: {complement.count('1')}")
