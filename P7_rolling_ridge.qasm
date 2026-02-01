from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
import networkx as nx
import itertools

# Load the large circuit
qc = QuantumCircuit.from_qasm_file("/content/P7_rolling_ridge.qasm")

# Step 1: Build qubit interaction graph
G = nx.Graph()
for q in range(qc.num_qubits):
    G.add_node(q)

# Use modern Qiskit API to get qubit indices
for instr in qc.data:
    qubits = instr.qubits  # tuple of Qubit objects
    if len(qubits) > 1:  # multi-qubit gate
        for i in range(len(qubits)):
            for j in range(i + 1, len(qubits)):
                G.add_edge(qc.qubits.index(qubits[i]), qc.qubits.index(qubits[j]))

# Find connected components → independent subcircuits
subcircuits = list(nx.connected_components(G))
print(f"Found {len(subcircuits)} independent subcircuits.")

# Step 2: Simulate each subcircuit separately
sim = AerSimulator(method="statevector")  # fast for small subcircuits
sub_results = []

for sc in subcircuits:
    qubit_list = sorted(sc)

    # Create a subcircuit manually
    sub_qc = QuantumCircuit(len(qubit_list))

    qubit_map = {q: i for i, q in enumerate(qubit_list)}  # old->new qubit index

    # Copy only gates involving these qubits
    for instr, qargs, cargs in qc.data:
        qubits_in_instr = [qc.qubits.index(q) for q in qargs]
        if all(q in qubit_list for q in qubits_in_instr):
            # Map qubits to new subcircuit indices
            new_qargs = [sub_qc.qubits[qubit_map[q]] for q in qubits_in_instr]
            sub_qc.append(instr, new_qargs)

    # Add measurements
    sub_qc.measure_all()

    # Transpile & run
    tqc = transpile(sub_qc, sim, optimization_level=3)
    res = sim.run(tqc, shots=1).result()
    counts = res.get_counts()
    sub_results.append(counts)

# Step 3: Recombine subcircuit outputs classically
final_counts = {}
for prod in itertools.product(*[list(c.keys()) for c in sub_results]):
    bitstring = ''.join(prod)  # concatenate subcircuit strings
    final_counts[bitstring] = 1  # since shots=1 for each subcircuit

# Step 4: Extract the most probable 46-bit string
answer = max(final_counts, key=final_counts.get)

print("\nFinal Answer (46-bit string):")
print(answer)
print("Length:", len(answer))
