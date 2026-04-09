import re

# Read your Verilog file
with open('sbox.v', 'r') as f:
    text = f.read()

# Find all the hex patterns (e.g., 8'h00: out = 8'h63;)
matches = re.findall(r"8'h([0-9a-fA-F]{2}):\s*out\s*=\s*8'h([0-9a-fA-F]{2});", text)

# Write to CSV in decimal format
with open('sbox.csv', 'w') as f:
    f.write("Input_Dec,Output_Dec\n")
    for m in matches:
        in_dec = int(m[0], 16)
        out_dec = int(m[1], 16)
        f.write(f"{in_dec},{out_dec}\n")

print("Successfully created sbox.csv!")
