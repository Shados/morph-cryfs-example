# Morph + CryFS Example

This repository serves as a minimal-ish example of how you could use
[CryFS](https://github.com/cryfs/cryfs) to keep encrypted secrets in the same
repository as [Morph](https://github.com/DBCDK/morph) deployment configuration
files, and decrypt them on the fly at deploy-time.

## Files
- `bin`: Contains some helpers to pin Morph and nixpkgs revisions, and to wrap
  `morph` usage with loading and unloading a CryFS mount
- `decrypted-shell.nix`: An override of `shell.nix` adding automated `cryfs`
  mount and unmount to the Nix `shellHook`
- `deployments`: Contains the actual Morph deployment configuration files
- `modules`: Contains Nix expressions potentially shared across multiple
  deployments
- `pins`: Contains JSON files describing pinned source revisions
- `pubkeys`: Contains public keyfiles used in the deployments
- `secrets`: An encrypted CryFS directory

## Setup
The example deployment uses two secrets: one private SSH key which `morph` uses
to access the example host, and one hashed Linux password file to use on the
example host.

The CryFS directory is encrypted with the passphrase ``YJ@^K"eE2J7o3R`;``.

You probably would not want to use a single deployment-wide ssh key in
an actual project, if only for auditability reasons, but it's an option
nonetheless. Doing so does have the downside of requiring the CryFS directory
be decrypted on all Morph `deploy` commands, not solely on
`upload-secrets`/`--upload-secrets` usage.

## Usage Examples

### Build the Example System
This doesn't require decrypting the secrets, as nothing is being deployed or
uploaded.
```bash
./bin/enter-morph-shell
morph build deployments/example.nix
```

### Deploy the Example System
```bash
./bin/cry-morph deploy --upload-secrets deployments/example.nix switch
```
The `cry-morph` wrapper will prompt for the CryFS passphrase as appropriate,
and unmount it once done.

### Add a New Secret
```bash
./bin/enter-decrypted-morph-shell
cp /some/secret/file ./secrets/decrypted/a_secret
```
The `enter-decrypted-morph-shell` wrapper will prompt for the CryFS passphrase
as appropriate, and unmount it once done.
