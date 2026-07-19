# Layerset GCP GKE Cluster Management

Kaptain layerset combining strict GitHub flow quality enforcement with the GCP
GKE cluster management image build layer.

Composes these layers in order:

1. **layer-github-flow-strict** - strict GitHub flow quality enforcement.
2. **layer-gcp-gke-cluster-management** - GKE cluster management image build
   orchestration via the `postVersionsAndNaming` hook.

## Compatibility contract

The source layerset selects
`layer-gcp-gke-cluster-management:[1.1.0,2.0)`. This is a compatibility range,
not an exact pin: `1.1.0` is the first layer version that guarantees consumer
mode for final-package builds, later compatible `1.x` releases remain eligible,
and `2.x` is excluded.

The first layerset release intended to carry that guarantee is `1.1.0`. It has
not been published yet. Until both compatible `1.1.0` releases exist,
downstream final-package consumers must not claim that the contract is
available.

`version.txt` is the authoritative layerset release version. The root
`KaptainPM.yaml` uses Kaptain's custom `file-pattern-match` strategy with
`useSourceVersionExact: true` and a three-part limit. This makes the first
publication exactly `1.1.0`; it cannot silently become `1.0.1` through
git-auto versioning.

After `1.1.0` is published, every later release requires a deliberate
three-part bump to `version.txt`. Exact mode rejects a version whose tag already
exists, so maintainers update the source version in the same reviewed change
that is intended to produce the next layerset release.

After publication, downstream final-package consumers use:

```yaml
- ghcr.io/ikuw-consulting/layerset/layerset-gcp-gke-cluster-management:[1.1.0,2.0)
```

That downstream range deliberately excludes layerset `1.0.x`, whose management
layer can still start its own derived-image build.

Run `bash scripts/validate-compatibility-contract.sh` to validate these source
and downstream boundaries locally. CI runs that validation first, then invokes
the Kaptain `layer-and-layerset-build` reusable workflow pinned to `1.1.46`.

## Documentation

1. `layer-gcp-gke-cluster-management`
2. `image-gcp-gke-cluster-management`
