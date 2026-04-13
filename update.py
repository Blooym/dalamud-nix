import json
import subprocess
import urllib.request

META_URL = "https://kamori.goats.dev/Dalamud/Release/Meta"
OUTPUT = "dalamud-branches.json"


def runtime_ver_to_nix_sdk(runtime_version):
    parts = runtime_version.split(".")
    major, minor = parts[0], parts[1]
    return f"sdk_{major}_{minor}"


def runtime_ver_to_docker_img(runtime_version):
    parts = runtime_version.split(".")
    major, minor = parts[0], parts[1]
    return f"sdk:{major}.{minor}"


def generate_source(branch, info):
    downloadUrl = info["downloadUrl"]
    version = info["assemblyVersion"]
    runtimeVersion = info["runtimeVersion"]

    print(
        f"Generating branch source for {branch} (v{version}) with runtime {runtimeVersion}"
    )
    result = subprocess.check_output(
        [
            "nix",
            "store",
            "prefetch-file",
            "--unpack",
            "--hash-type",
            "sha256",
            "--json",
            downloadUrl,
        ],
        stderr=subprocess.DEVNULL,
        text=True,
    )
    return branch, {
        "version": version,
        "runtimeVersion": runtimeVersion,
        "downloadUrl": downloadUrl,
        "docker": {"dotnetSdkVersion": runtime_ver_to_docker_img(runtimeVersion)},
        "nix": {
            "hash": json.loads(result)["hash"],
            "dotnetSdkVersion": runtime_ver_to_nix_sdk(runtimeVersion),
        },
    }


print(f"Fetching release information from {META_URL}")
with urllib.request.urlopen(META_URL) as r:
    meta = json.load(r)
sources = dict(generate_source(branch, info) for branch, info in meta.items())
with open(OUTPUT, "w") as f:
    json.dump(sources, f, indent=2)
print(f"Written to {OUTPUT}")
