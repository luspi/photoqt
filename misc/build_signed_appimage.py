import os
import docker
import pwd
import subprocess
import sys
import shutil
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(
                    prog='PhotoQtAppImageBuilder',
                    description='Build and sign appimage')
parser.add_argument('--no-cleanup', action='store_true')
parser.add_argument("--key", default="56DF498D0D53A1C4")
parser.add_argument("--workspace", default="appimage-build")
parser.add_argument("--output", default="./")
args = parser.parse_args()

# ensure the workspace is a SUBFOLDER
if Path(os.path.abspath('./')) not in Path(os.path.abspath(args.workspace)).parents:
    print("ERROR: workspace HAS TO BE a subfolder!")
    sys.exit(1)

# check whether we run as admin (required by docker)
def check_admin():
    if os.geteuid() != 0:
        print("ERROR: This script must be run with administrator privileges.")
        print("Please run it as admin or using sudo.")
        sys.exit(1)

# check whether the gpg key listed above is actually present
def check_gpg_key():

    user = os.environ.get("SUDO_USER", "root")
    home = pwd.getpwnam(user).pw_dir
    gpg_home = os.path.join(home, ".gnupg")

    result = subprocess.run(
        ["gpg",
         "--homedir", gpg_home,
         "--batch",
         "--list-secret-keys",
         args.key],
        capture_output=True,
        text=True)

    if result.returncode != 0 or not result.stdout.strip():
        print(f"ERROR: GPG signing key {args.key} not found.")
        print(f"Expected keyring: {gpg_home}")
        print("Make sure the private signing key is installed for your user.")
        sys.exit(1)

    return gpg_home

# run checks
check_admin()
GPG_HOME = check_gpg_key()

###################################################

# the gitlab ci file
CI_FILE = "../.gitlab-ci.yml"
# the real appimage url (the gitlab ci recipe uses the artefact url itself)
ZSYNC_URL = "https://photoqt.org/downloads/appimages/PhotoQt.AppImage.zsync"

def get_recipe():

    # get recipe
    with open(CI_FILE, encoding="utf-8") as f:
        content = f.read()

    # this will collect the commands
    recipe = []
    marker = None

    # we only start recording the recipe when we hit the start marker
    do_record = False

    for line in content.splitlines():

        stripped = line.strip()

        # start recording
        if stripped == "# start of appimage recipe":
            do_record = True
            continue

        # done recording
        if stripped == "# end of appimage recipe":
            break

        # not yet recording
        if not do_record:
            continue

        # don't include the next line
        if stripped.startswith("# skip for release:"):
            marker = "skip"

        # record the next line (lines starting with "#-" are ONLY used here)
        elif stripped.startswith("-") or stripped.startswith("#-"):

            # don't skip this line...
            if marker != "skip":

                command = stripped[2:].strip()

                # do some basic search/replace
                command = command.replace("zsync|https://gitlab.com/api/v4/projects/312439/jobs/artifacts/master/raw/PhotoQt-nightly.AppImage.zsync?job=appimage", f"zsync|{ZSYNC_URL}")
                command = command.replace("PhotoQt-nightly.AppImage", "PhotoQt.AppImage")
                command = command.replace("GPG_KEY_ID", args.key)

                # record command
                recipe.append(command)

            # reset the marker, it is only used once
            marker = None

    return recipe

# get the list of commands
recipe = get_recipe()

# before entering the list of commands we prepare the docker environment by:
# 1. cleaning the workspace
# 2. make the gpg keys available
# 3. clone photoqt and enter it (as is what happens in the gitlab ci pipeline)
docker_script = (
    "set -ex\n"
    "find /workspace -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +\n"
    "apt update && apt -y install git\n"
    "mkdir -p /root/.gnupg\n"
    "chmod 700 /root/.gnupg\n"
    "cp -a /mnt/host-gnupg/private-keys-v1.d/ /root/.gnupg/\n"
    "cp -a /mnt/host-gnupg/pubring.kbx /root/.gnupg/\n"
    "git clone https://gitlab.com/lspies/photoqt.git /workspace/photoqt\n"
    "cd /workspace/photoqt\n"
    + "\n".join(recipe)
)

# get docker
client = docker.from_env()

# start ubuntu:noble image
container = client.containers.run(
    "ubuntu:noble",
    command=["bash", "-c", docker_script],
    volumes={
        os.path.abspath("appimage-build"): {
            "bind": "/workspace",
            "mode": "rw"
        },
        GPG_HOME: {
            "bind": "/mnt/host-gnupg",
            "mode": "ro"
        }
    },
    working_dir="/workspace",
    detach=True
)

try:

    for log in container.logs(stream=True, follow=True):
        print(log.decode(), end="")

    result = container.wait()
    if result["StatusCode"] != 0:
        raise RuntimeError(f"Build failed with exit code {result['StatusCode']}")

finally:
    # remove container when done
    container.remove(force=True)
    client.close()

# copy resulting AppImage and zsync files out and remove working tree
shutil.copy2(f"{args.workspace}/photoqt/PhotoQt.AppImage", args.output)
shutil.copy2(f"{args.workspace}/photoqt/PhotoQt.AppImage.zsync", args.output)

# clean up if not disabled
if not args.no_cleanup:
    shutil.rmtree(args.workspace)
