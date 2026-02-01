!pip install qiskit qiskit-aer

from google.colab import files
from qiskit import QuantumCircuit
from qiskit.quantum_info import Statevector
import numpy as np

# 1. Upload 'P2_small_bump.qasm' if you haven't already
print("Please upload 'P2_small_bump.qasm':")
uploaded = files.upload()
filename = next(iter(uploaded))

# 2. Load the circuit
qc = QuantumCircuit.from_qasm_file(filename)
print(f"Loaded circuit with {qc.num_qubits} qubits.")

# 3. Run Statevector Simulation
# This calculates the exact amplitude of every possible state
print("Calculating Statevector (this may take a few seconds)...")
state = Statevector.from_instruction(qc)
probabilities = state.probabilities()

# 4. Find the Peak
# We find the index with the highest probability and convert it to a bitstring
max_index = np.argmax(probabilities)
peak_bitstring = format(max_index, f'0{qc.num_qubits}b')
max_probability = probabilities[max_index]

print(f"\n🏆 Peak Bitstring: {peak_bitstring}")
print(f"Probability: {max_probability:.4f}")
