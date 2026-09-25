[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2FLucasFA%2F.nixos)](https://garnix.io/repo/LucasFA/.nixos)

# Firewall documented ports:

hplip: 5353/udp
KDE connect: 1714-1764/udp,tcp

# Colmena deployment

`colmena apply` deploys the managed servers (`server-nuc1` and `server-node804`) over SSH as
`lucasfa`. The server role allows the wheel user to use passwordless sudo, which Colmena needs
for non-interactive activation.

The Slimbook is configured for local deployment and is skipped by the normal apply command:

```console
colmena apply-local --sudo
```

To preview or deploy the remote servers, run:

```console
colmena apply dry-activate
colmena apply
```

`server-hp-omen` remains available as a NixOS configuration but is not currently managed by
Colmena.
