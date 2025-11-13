import os
import hashlib

def sha256_checksum(filepath, block_size=65536):
    """Compute SHA-256 checksum of a file."""
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for block in iter(lambda: f.read(block_size), b""):
            sha256.update(block)
    return sha256.hexdigest()

def collect_all_checksums_to_first_subdir(root_dir):
    """Compute checksums for all files and write them to a single file in the first subdirectory."""
    # Get all subdirectories
    subdirs = [os.path.join(root_dir, d) for d in sorted(os.listdir(root_dir))
               if os.path.isdir(os.path.join(root_dir, d))]

    if not subdirs:
        print("No subdirectories found.")
        return

    # First subdirectory (alphabetically)
    output_path = os.path.join(root_dir, "manifest.txt")

    with open(output_path, "w", encoding="utf-8") as out_file:
        # Walk through all directories recursively
        for dirpath, dirnames, filenames in os.walk(root_dir):
            for filename in filenames:
                if filename.endswith(".so") or filename == "manifest.txt" or filename == "manifest.txt.sig":
                    continue  # skip shared object files

                filepath = os.path.join(dirpath, filename)
                try:
                    checksum = sha256_checksum(filepath)
                    rel_path = os.path.relpath(filepath, root_dir)
                    out_file.write(f"{rel_path}:{checksum}\n")
                except (OSError, PermissionError) as e:
                    print(f"Skipping {filepath}: {e}")

    # sign manifest
    command = f"openssl dgst -sha256 -sign private_rsa.pem -out {output_path}.sig {output_path}"
    os.popen(command)

    print(f"All checksums written to {output_path} and signed")

if __name__ == "__main__":

    subdirs = [os.path.join(os.getcwd(), d) for d in sorted(os.listdir(os.getcwd()))
               if os.path.isdir(os.path.join(os.getcwd(), d))]

    for d in subdirs:
        collect_all_checksums_to_first_subdir(d)
