import os
import hashlib

################################################
#
# HOW TO USE
#
# This required the private key to be stores next to this file (can be found in password manager)
# Both files need to be in the parent directory where all the folders of the compiled extensions liea
#
################################################

# generate sha256 of some path
def sha256_checksum(filepath, block_size=65536):
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for block in iter(lambda: f.read(block_size), b""):
            sha256.update(block)
    return sha256.hexdigest()

# iterate over dir and create hashes of all files
def collect_all_checksums_to_first_subdir(root_dir):
    
    # Get all subdirectories
    subdirs = [os.path.join(root_dir, d) for d in sorted(os.listdir(root_dir))
               if os.path.isdir(os.path.join(root_dir, d))]

    # if there are no subdirs, skip. This shouldn't really ever be the case
    if not subdirs:
        print("No subdirectories found.")
        return

    # This is where we store the result
    output_path = os.path.join(root_dir, "manifest.txt")

    # open the output manifest file
    with open(output_path, "w", encoding="utf-8") as out_file:

        # Walk through all directories recursively
        for dirpath, dirnames, filenames in os.walk(root_dir):

            for filename in filenames:

                # if the file is to be skipped
                if filename.endswith(".so") or filename == "manifest.txt" or filename == "manifest.txt.sig":
                    continue

                # egnerate and store result
                filepath = os.path.join(dirpath, filename)
                checksum = sha256_checksum(filepath)
                rel_path = os.path.relpath(filepath, root_dir)
                out_file.write(f"{rel_path}:{checksum}\n")

    # sign manifest
    command = f"openssl dgst -sha256 -sign private_rsa.pem -out {output_path}.sig {output_path}"
    os.popen(command)

    print(f"All checksums written to {output_path} and signed")

# find all subdirs in the current cwd
subdirs = [os.path.join(os.getcwd(), d) for d in sorted(os.listdir(os.getcwd())) if os.path.isdir(os.path.join(os.getcwd(), d))]

# treat all extension individually
for d in subdirs:
    collect_all_checksums_to_first_subdir(d)
