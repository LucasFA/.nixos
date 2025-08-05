to create a secret:

- create an entry in secrets.nix
- create the actual secret with `agenix -e testname`
- add the secret to the configuration using something like:

age.secrets.nextcloud = {
  file = ./secrets/secret1.age;
  owner = "nextcloud";
  group = "nextcloud";
};
