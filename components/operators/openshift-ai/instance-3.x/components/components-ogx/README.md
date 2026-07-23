# components-ogx

## Purpose

This component enables OGX in the DataScienceCluster. OGX provides tooling for building generative AI applications, including Retrieval-Augmented Generation (RAG) and agentic workflows, with support for remote inference, embeddings, and vector database operations.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-ogx
```
