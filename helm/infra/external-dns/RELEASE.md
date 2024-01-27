### Added

- Added RBAC for Traefik to ClusterRole. ([#3325](https://github.com/kubernetes-sigs/external-dns/pull/3325)) [@ThomasK33](https://github.com/thomask33)
- Added support for init containers. ([#3325](https://github.com/kubernetes-sigs/external-dns/pull/3838)) [@calvinbui](https://github.com/calvinbui)

### Changed

- Disallowed privilege escalation in container security context and set the seccomp profile type to `RuntimeDefault`. ([#3689](https://github.com/kubernetes-sigs/external-dns/pull/3689)) [@nrvnrvn](https://github.com/nrvnrvn)
- Updated _ExternalDNS_ OCI image version to [v0.13.6](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.13.6). ([#3917](https://github.com/kubernetes-sigs/external-dns/pull/3917)) [@stevehipwell](https://github.com/stevehipwell)

### Removed

- Removed RBAC rule for already removed `contour-ingressroute` source. ([#3764](https://github.com/kubernetes-sigs/external-dns/pull/3764)) [@johngmyers](https://github.com/johngmyers)
