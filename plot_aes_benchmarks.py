import pandas as pd
import matplotlib.pyplot as plt

# Load CSV
df = pd.read_csv("aes_benchmark_results.csv")

# Split algorithm into key size and mode
df[["cipher", "key_size", "mode"]] = df["algorithm"].str.extract(r"(AES)-(\d+)-([A-Z0-9]+)")
df["key_size"] = df["key_size"].astype(int)

# Drop original algorithm column
df.drop(columns=["algorithm"], inplace=True)

# Reorder columns
cols = ["cipher", "key_size", "mode"] + [col for col in df.columns if col not in ["cipher", "key_size", "mode"]]
df = df[cols]

# Melt for long-form plotting
df_melted = df.melt(id_vars=["cipher", "key_size", "mode"], var_name="block_size", value_name="ops")
df_melted["block_size"] = df_melted["block_size"].str.replace("bytes", "").astype(int)

# Sort for nice plot order
df_melted.sort_values(by=["key_size", "mode", "block_size"], inplace=True)

# Filter only AES-128 variants
key_sizes = [128, 192, 256]
for key_size in key_sizes:
    df_128 = df_melted[df_melted["key_size"] == key_size]

# Plot
    plt.figure(figsize=(12, 8))
    for mode, group in df_128.groupby("mode"):
        label = f"AES-128-{mode}"
        plt.plot(group["block_size"], group["ops"], marker='o', label=label)

    plt.xscale("log", base=2)
    plt.xticks([16, 64, 256, 1024, 8192, 16384], labels=["16", "64", "256", "1024", "8192", "16384"])
    plt.xlabel("Block Size (bytes)")
    plt.ylabel("Operations in 3 seconds")
    plt.title(f"AES-{key_size} Performance by Mode and Block Size")
    plt.grid(True, which="both", linestyle="--", linewidth=0.5)
    plt.legend(loc="best", fontsize="small")
    plt.tight_layout()
    plt.savefig(f"aes_{key_size}_plot.png")
    plt.show()
