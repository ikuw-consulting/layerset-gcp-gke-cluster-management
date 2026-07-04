# Layerset GCP GKE Cluster Management

Kaptain layerset combining strict GitHub flow quality enforcement with the GCP
GKE cluster management image build layer.

Composes these layers in order:

1. **layer-github-flow-strict** - strict GitHub flow quality enforcement.
2. **layer-gcp-gke-cluster-management** - GKE cluster management image build
   orchestration via the `postVersionsAndNaming` hook.

## Documentation

1. `layer-gcp-gke-cluster-management`
2. `image-gcp-gke-cluster-management`
