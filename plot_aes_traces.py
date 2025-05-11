import pandas as pd
import glob

def parse_flat_trace(filename):
    data = {}
    with open(filename, "r") as f:
        for line in f:
            parts = line.strip().rsplit(maxsplit=1)
            if len(parts) == 2 and parts[1].isdigit():
                func = parts[0]
                time_ns = int(parts[1])
                data[func] = time_ns
    return pd.Series(data, name=filename)

# Collect all trace files
trace_64B_files = sorted(glob.glob("out/trace_64B_*.out"))
trace_16B_files = sorted(glob.glob("out/trace_16B_*.out"))

# Parse and stack into DataFrames
df_64B_runs = pd.DataFrame([parse_flat_trace(f) for f in trace_64B_files]).fillna(0).astype(int)
df_16B_runs = pd.DataFrame([parse_flat_trace(f) for f in trace_16B_files]).fillna(0).astype(int)

# Compute mean per function across runs
df_64B_avg = df_64B_runs.sum(axis=0)
df_16B_avg = df_16B_runs.sum(axis=0)

# Combine into a comparison DataFrame
df = pd.concat([df_64B_avg, df_16B_avg], axis=1)
df.columns = ["64B", "16B"]

# Fill missing values with 0 and convert to int
df = df.fillna(0).astype(int)

# Compute comparisons
df["% change (16B vs 64B)"] = ((df["16B"] - df["64B"]) / df["64B"].replace(0, 1)) * 100
df["rel change (16B vs 64B)"] = df["16B"] - df["64B"]

# Sort by relative change
df = df.sort_values(by="rel change (16B vs 64B)", ascending=False)

# Output
print("=== Summary of relative change ===")
print(df.sum())

print("\n=== Top 20 differences ===")
print(df.head(20))

df.to_csv("trace_comparison_averaged.csv")
