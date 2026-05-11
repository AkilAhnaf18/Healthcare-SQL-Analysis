import pandas as pd
import sqlite3
import os

# ── 1. Load the CSV ──────────────────────────────────────────────
print("Loading CSV...")
df = pd.read_csv("data/hospital_discharges.csv", low_memory=False)

print(f"✓ Loaded {len(df):,} rows and {len(df.columns)} columns")
print(f"\nColumns found:\n{list(df.columns)}")

# ── 2. Clean column names ─────────────────────────────────────────
# Remove spaces, lowercase everything, replace spaces with underscores
# So "Health Service Area" becomes "health_service_area"
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_", regex=False)
    .str.replace("/", "_", regex=False)
    .str.replace("-", "_", regex=False)
)

print(f"\nCleaned column names:\n{list(df.columns)}")

# ── 3. Connect to SQLite and load ─────────────────────────────────
# This creates the file if it doesn't exist yet
db_path = "data/healthcare.db"
conn = sqlite3.connect(db_path)

print(f"\nLoading into SQLite database...")
df.to_sql(
    name="discharges",        # This becomes your table name
    con=conn,
    if_exists="replace",      # Overwrite if we run this again
    index=False               # Don't write the pandas row index
)

# ── 4. Verify it worked ───────────────────────────────────────────
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM discharges")
row_count = cursor.fetchone()[0]

print(f"✓ Successfully loaded {row_count:,} rows into table 'discharges'")
print(f"✓ Database saved to: {db_path}")

# ── 5. Preview the first few rows ────────────────────────────────
print("\nPreview of first 3 rows:")
preview = pd.read_sql("SELECT * FROM discharges LIMIT 3", conn)
print(preview.to_string())

conn.close()
print("\n✓ Done. Database connection closed.")
