from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

# 1. Create the QASM file directly (so you don't have to upload it again)
qasm_content = """OPENQASM 2.0;
include "qelib1.inc";
qreg q[4];
x q[0];
x q[3];
"""

with open("P1_little_peak.qasm", "w") as f:
    f.write(qasm_content)

# 2. Load the circuit
qc = QuantumCircuit.from_qasm_file("P1_little_peak.qasm")
print("Circuit Diagram:")
print(qc)

# 3. Simulate to find the Peak Bitstring
simulator = AerSimulator()
qc.measure_all()
transpiled_qc = transpile(qc, simulator)
result = simulator.run(transpiled_qc, shots=1024).result()
counts = result.get_counts()

# 4. Show the Peak Bitstring
print("\nResults:")
sorted_counts = sorted(counts.items(), key=lambda x: x[1], reverse=True)
peak_bitstring = sorted_counts[0][0]
print(f"🏆 Peak Bitstring (The Answer): {peak_bitstring}")

# Visualize
plot_histogram(counts)
plt.show()
