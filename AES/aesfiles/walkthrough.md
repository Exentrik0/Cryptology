# AES-256 Hardware Implementation Log

This log chronicles the testing, debugging, and verification steps taken to harden the AES-256 Verilog implementation, specifically preparing it for synchronous power side-channel analysis and fault injection on the ChipWhisperer CW305 FPGA.

## 1. Testbench Inception & Clock Synchronization
To properly prepare the repository for ChipWhisperer clock-glitching (which relies fundamentally on synchronous clock edge timing violations), we introduced a strict 100MHz clock structure to all module simulations, even purely combinational ones.

*   **`tb_add_round_key.sv`**: Created a testbench validating the bitwise XOR logic against Round 0 plaintext data.
*   **`tb_sub_bytes.sv`**: Created a testbench testing the 16 parallel S-Box instantiations. FIPS-197 vectors perfectly matched the Galois Field transformation.

## 2. Data Formatting (`make_csv.py` & `sbox.csv`)
The raw Hexadecimal table in `sbox.v` is difficult to analyze manually. We created a lightweight Python script (`make_csv.py`) that successfully mapped out the 256 entries into decimal format inside `sbox.csv` for easier human verification.

## 3. Top-level Validation Testbenches
We created testbenches for the complex sequential controllers and derived-key generators:
*   **`tb_aes_round.sv`**: Created to verify the entire SubBytes -> ShiftRows -> MixColumns -> AddRoundKey pipeline loop.
*   **`tb_aes_controller.sv`**: Modeled the FSM that tracks the 14 rounds. *Discovered a race condition bug where the `done` pulse disappeared before being sampled.*
*   **`tb_key_expansion.sv`**: Passed a 256-bit Master Key. Verified all 15 Round Keys against the math standard. We successfully demonstrated that the AES-256 specific rotation/unrotated rules for `SubWord` generation were perfectly configured.

## 4. Architectural Fix: Pipeline Double-Registering
> [!WARNING]
> We discovered a massive architectural misalignment in `aes_round.v`. 

Previously, `aes_round.v` registered its output into a flip-flop (`state_out <= next_state`). Because `aes_top.sv` *also* captured the output into a flip-flop (`state_reg <= round_output`), the system mathematically took 2 clock cycles per encryption round.

However, the controller assumes a pipeline of 1 clock cycle per round. Because the keys advanced every 1 cycle while the math advanced every 2 cycles, the Master Key fell structurally out of sync with the data. 

**The Fix:**
We "flattened" `aes_round.v` by removing its flip-flops altogether.
1. Stripped `reg` off `state_out` and `round_done`.
2. Changed the bottom block to `assign state_out = next_state` and `assign round_done = 1'b1;`.

The module now behaves efficiently as a pure combinational block spanning exactly 1 clock cycle bounded by `aes_top.sv` registers.

## 5. Self-Checking Automations (`testbench.sv`)
> [!TIP]
> We added a self-checking assertion to the ultimate trace file.

Instead of manually reading trailing hex strings, we appended an explicit verification block at the end of `testbench.sv` (around line 122) to directly compare the generated output against the FIPS 197 NIST standard AES-256 target vector: `128'h8ea2b7ca516745bfeafc49904b496089`.

## 6. SystemVerilog Compilation Flags
We corrected compiler errors by standardizing the test execution commands:
1. Forced the top module using `-s [module_name]` to prevent `iverilog` from hanging on port-only modules.
2. Included the `-g2012` flag when compiling `aes_top.sv` because `iverilog` rejects SystemVerilog unpacked array outputs (`[127:0] state [0:14]`) without IEEE 1800-2012 support enabled.
