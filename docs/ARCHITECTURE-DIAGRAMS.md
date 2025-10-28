# Architecture Diagrams - Validated Patterns Toolkit

**Version:** 1.0
**Last Updated:** 2025-10-27

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Component Relationships](#component-relationships)
4. [Data Flow Diagrams](#data-flow-diagrams)
5. [Deployment Topology](#deployment-topology)
6. [Network Architecture](#network-architecture)
7. [Workflow Diagrams](#workflow-diagrams)

---

## Overview

This document provides visual representations of the Validated Patterns Toolkit architecture, showing how components interact and data flows through the system.

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Validated Patterns Toolkit                        │
│                         System Architecture                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         User Layer                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────┐         ┌──────────────────────┐         │
│  │  Pattern Developer   │         │  Pattern Consumer    │         │
│  │  (Development        │         │  (End-User           │         │
│  │   Workflow)          │         │   Workflow)          │         │
│  └──────────────────────┘         └──────────────────────┘         │
│           │                                  │                       │
└───────────┼──────────────────────────────────┼───────────────────────┘
            │                                  │
            ▼                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Ansible Layer                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────────────┐  ┌──────────────────────────┐  │
│  │  Development Roles (6)         │  │  End-User Role (1)       │  │
│  │  ┌──────────────────────────┐  │  │  ┌────────────────────┐ │  │
│  │  │ 1. Prerequisites         │  │  │  │ 3. VP Operator     │ │  │
│  │  │ 2. Common                │  │  │  │    (Wraps all 6)   │ │  │
│  │  │ 4. Deploy                │  │  │  └────────────────────┘ │  │
│  │  │ 5. Gitea                 │  │  │                          │  │
│  │  │ 6. Secrets               │  │  │                          │  │
│  │  │ 7. Validate              │  │  │                          │  │
│  │  └──────────────────────────┘  │  └──────────────────────────┘  │
│  └────────────────────────────────┘                                 │
│                    │                              │                  │
└────────────────────┼──────────────────────────────┼──────────────────┘
                     │                              │
                     ▼                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    OpenShift/Kubernetes Layer                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐  │
│  │  OpenShift       │  │  Validated       │  │  Pattern        │  │
│  │  GitOps          │  │  Patterns        │  │  Applications   │  │
│  │  (ArgoCD)        │  │  Operator        │  │                 │  │
│  └──────────────────┘  └──────────────────┘  └─────────────────┘  │
│           │                      │                      │            │
│           └──────────────────────┴──────────────────────┘            │
│                                  │                                   │
└──────────────────────────────────┼───────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  Compute     │  │  Storage     │  │  Network     │             │
│  │  (Nodes)     │  │  (PVs)       │  │  (SDN)       │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Component Relationships

### Development Workflow Components

```
┌─────────────────────────────────────────────────────────────────────┐
│              Development Workflow Component Diagram                  │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_prerequisites                                 │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ • Validates OpenShift version (4.12+)                      │  │
│  │ • Checks cluster resources (nodes, CPU, memory)            │  │
│  │ • Verifies operators (OpenShift GitOps)                    │  │
│  │ • Tests network connectivity                               │  │
│  │ • Validates RBAC permissions                               │  │
│  │ • Checks storage configuration                             │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_common                                        │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ • Installs rhvp.cluster_utils collection                   │  │
│  │ • Configures Helm repositories                             │  │
│  │ • Deploys clustergroup-chart v0.9.*                        │  │
│  │ • Enables multisource architecture                         │  │
│  │ • Configures ArgoCD integration                            │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_deploy                                        │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ • Creates pattern namespace                                │  │
│  │ • Deploys ArgoCD Application CR                            │  │
│  │ • Configures GitOps sync policy                            │  │
│  │ • Monitors application sync status                         │  │
│  │ • Verifies application health                              │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_gitea (Optional)                              │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ • Creates gitea namespace                                  │  │
│  │ • Deploys Gitea instance                                   │  │
│  │ • Configures repositories                                  │  │
│  │ • Sets up webhooks                                         │  │
│  │ • Creates development users                                │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_secrets                                       │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ • Creates dedicated secrets namespace                      │  │
│  │ • Configures RBAC for secrets access                       │  │
│  │ • Deploys Sealed Secrets operator (optional)               │  │
│  │ • Creates secret templates                                 │  │
│  │ • Validates secret encryption                              │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_validate                                      │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ • Checks ArgoCD application status                         │  │
│  │ • Verifies all pods are running                            │  │
│  │ • Tests application endpoints                              │  │
│  │ • Validates secrets are accessible                         │  │
│  │ • Generates validation report                              │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

### End-User Workflow Components

```
┌─────────────────────────────────────────────────────────────────────┐
│               End-User Workflow Component Diagram                    │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  validated_patterns_operator                                      │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                                                            │  │
│  │  Wraps all 6 development roles into single operator:      │  │
│  │                                                            │  │
│  │  1. Installs Validated Patterns Operator                  │  │
│  │  2. Creates Pattern Custom Resource                       │  │
│  │  3. Operator handles:                                     │  │
│  │     • Prerequisites validation                            │  │
│  │     • Common infrastructure deployment                    │  │
│  │     • Pattern application deployment                      │  │
│  │     • Secrets management                                  │  │
│  │     • Deployment validation                               │  │
│  │  4. Monitors operator deployment                          │  │
│  │  5. Validates pattern deployment                          │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagrams

### Development Workflow Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                  Development Workflow Data Flow                      │
└─────────────────────────────────────────────────────────────────────┘

User
  │
  │ 1. Runs ansible-playbook with development roles
  ▼
Ansible Playbook
  │
  │ 2. Executes validated_patterns_prerequisites
  ▼
OpenShift Cluster
  │
  │ 3. Returns cluster information (version, resources, operators)
  ▼
Ansible (validates prerequisites)
  │
  │ 4. Executes validated_patterns_common
  ▼
Helm + ArgoCD
  │
  │ 5. Deploys clustergroup-chart and configures GitOps
  ▼
OpenShift GitOps (ArgoCD)
  │
  │ 6. Executes validated_patterns_deploy
  ▼
ArgoCD Application CR
  │
  │ 7. ArgoCD syncs from Git repository
  ▼
Git Repository
  │
  │ 8. ArgoCD pulls manifests (k8s YAML, Helm charts, Kustomize)
  ▼
ArgoCD
  │
  │ 9. Applies manifests to cluster
  ▼
OpenShift Cluster
  │
  │ 10. Creates namespaces, deployments, services, routes
  ▼
Pattern Applications (Running)
  │
  │ 11. Executes validated_patterns_validate
  ▼
Validation Report
  │
  │ 12. Returns status to user
  ▼
User (deployment complete)
```

### End-User Workflow Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                   End-User Workflow Data Flow                        │
└─────────────────────────────────────────────────────────────────────┘

User
  │
  │ 1. Edits values-global.yaml and values-hub.yaml
  ▼
Configuration Files
  │
  │ 2. Runs ansible-playbook with VP Operator role
  ▼
Ansible Playbook
  │
  │ 3. Installs Validated Patterns Operator
  ▼
OpenShift Operators
  │
  │ 4. Creates Pattern Custom Resource
  ▼
Pattern CR
  │
  │ 5. VP Operator watches Pattern CR
  ▼
Validated Patterns Operator
  │
  │ 6. Operator installs OpenShift GitOps
  ▼
OpenShift GitOps (ArgoCD)
  │
  │ 7. Operator creates clustergroup Application
  ▼
ArgoCD Application
  │
  │ 8. ArgoCD syncs from Git repository
  ▼
Git Repository
  │
  │ 9. ArgoCD pulls manifests
  ▼
ArgoCD
  │
  │ 10. Applies manifests to cluster
  ▼
OpenShift Cluster
  │
  │ 11. Creates all pattern resources
  ▼
Pattern Applications (Running)
  │
  │ 12. User monitors via ArgoCD UI
  ▼
User (deployment complete)
```

---

## Deployment Topology

### Single Cluster Deployment

```
┌─────────────────────────────────────────────────────────────────────┐
│                   Single Cluster Deployment                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      OpenShift Cluster (Hub)                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Control Plane Nodes (3)                                      │  │
│  │  • API Server                                                 │  │
│  │  • etcd                                                       │  │
│  │  • Controller Manager                                         │  │
│  │  • Scheduler                                                  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Worker Nodes (3+)                                            │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  openshift-gitops namespace                             │ │  │
│  │  │  • ArgoCD Server                                        │ │  │
│  │  │  • ArgoCD Application Controller                        │ │  │
│  │  │  • ArgoCD Repo Server                                   │ │  │
│  │  │  • ArgoCD Redis                                         │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  openshift-operators namespace                          │ │  │
│  │  │  • OpenShift GitOps Operator                            │ │  │
│  │  │  • Validated Patterns Operator (optional)               │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  validated-patterns-secrets namespace                   │ │  │
│  │  │  • Secrets                                              │ │  │
│  │  │  • Sealed Secrets Controller (optional)                 │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  Pattern Application Namespaces                         │ │  │
│  │  │  • reference-app                                        │ │  │
│  │  │  • gitea (optional)                                     │ │  │
│  │  │  • Custom application namespaces                        │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Multi-Cluster Deployment (Hub and Spoke)

```
┌─────────────────────────────────────────────────────────────────────┐
│                  Multi-Cluster Deployment Topology                   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      Hub Cluster                                     │
├─────────────────────────────────────────────────────────────────────┤
│  • OpenShift GitOps (ArgoCD)                                         │
│  • Validated Patterns Operator                                       │
│  • Pattern Management                                                │
│  • Secrets Management                                                │
│  • ACM (Advanced Cluster Management) - optional                      │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ GitOps Sync
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│ Spoke Cluster │     │ Spoke Cluster │     │ Spoke Cluster │
│    (Dev)      │     │   (Staging)   │     │    (Prod)     │
├───────────────┤     ├───────────────┤     ├───────────────┤
│ • ArgoCD      │     │ • ArgoCD      │     │ • ArgoCD      │
│   Agent       │     │   Agent       │     │   Agent       │
│ • Pattern     │     │ • Pattern     │     │ • Pattern     │
│   Apps        │     │   Apps        │     │   Apps        │
│ • Dev Config  │     │ • Staging     │     │ • Prod Config │
│               │     │   Config      │     │               │
└───────────────┘     └───────────────┘     └───────────────┘
```

---

## Network Architecture

### Network Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Network Architecture                            │
└─────────────────────────────────────────────────────────────────────┘

External Users
      │
      │ HTTPS (443)
      ▼
┌─────────────────────────────────────────────────────────────────────┐
│  OpenShift Router (Ingress)                                          │
│  • Routes traffic to services                                        │
│  • TLS termination                                                   │
└─────────────────────────────────────────────────────────────────────┘
      │
      │ Internal routing
      ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Services                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  ArgoCD      │  │  Application │  │  Gitea       │             │
│  │  Service     │  │  Service     │  │  Service     │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
      │                     │                     │
      │ Pod network         │ Pod network         │ Pod network
      ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Pods                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  ArgoCD      │  │  Application │  │  Gitea       │             │
│  │  Pods        │  │  Pods        │  │  Pods        │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
      │                     │                     │
      │ Storage             │ Storage             │ Storage
      ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Persistent Volumes                                                  │
│  • ArgoCD data                                                       │
│  • Application data                                                  │
│  • Gitea data                                                        │
└─────────────────────────────────────────────────────────────────────┘

External Connections:
  │
  ├─► Git Repository (GitHub, GitLab, etc.) - HTTPS (443)
  ├─► Image Registry (Quay, Docker Hub, etc.) - HTTPS (443)
  ├─► Helm Repository - HTTPS (443)
  └─► OperatorHub - HTTPS (443)
```

### Network Policies

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Network Policies                                │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  openshift-gitops namespace                                          │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Ingress Rules:                                               │  │
│  │  • Allow from OpenShift Router                                │  │
│  │  • Allow from same namespace                                  │  │
│  │  • Allow from openshift-monitoring (metrics)                  │  │
│  │                                                               │  │
│  │  Egress Rules:                                                │  │
│  │  • Allow to Kubernetes API                                    │  │
│  │  • Allow to Git repositories (HTTPS)                          │  │
│  │  • Allow to image registries (HTTPS)                          │  │
│  │  • Allow to application namespaces                            │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Application namespaces (e.g., reference-app)                        │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Ingress Rules:                                               │  │
│  │  • Allow from OpenShift Router                                │  │
│  │  • Allow from same namespace                                  │  │
│  │  • Allow from openshift-gitops (ArgoCD)                       │  │
│  │  • Allow from openshift-monitoring (metrics)                  │  │
│  │                                                               │  │
│  │  Egress Rules:                                                │  │
│  │  • Allow to same namespace                                    │  │
│  │  • Allow to validated-patterns-secrets (secrets access)       │  │
│  │  • Allow to external APIs (if needed)                         │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  validated-patterns-secrets namespace                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Ingress Rules:                                               │  │
│  │  • Allow from application namespaces (with RBAC)              │  │
│  │  • Allow from openshift-gitops (ArgoCD)                       │  │
│  │  • Deny all other ingress                                     │  │
│  │                                                               │  │
│  │  Egress Rules:                                                │  │
│  │  • Allow to Kubernetes API                                    │  │
│  │  • Deny all other egress                                      │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Workflow Diagrams

### Development Workflow Sequence

```
┌─────────────────────────────────────────────────────────────────────┐
│              Development Workflow Sequence Diagram                   │
└─────────────────────────────────────────────────────────────────────┘

User          Ansible       OpenShift     ArgoCD        Git Repo
 │               │              │            │              │
 │ Run playbook  │              │            │              │
 ├──────────────>│              │            │              │
 │               │              │            │              │
 │               │ Validate     │            │              │
 │               │ prerequisites│            │              │
 │               ├─────────────>│            │              │
 │               │<─────────────┤            │              │
 │               │   OK         │            │              │
 │               │              │            │              │
 │               │ Deploy       │            │              │
 │               │ common infra │            │              │
 │               ├─────────────>│            │              │
 │               │              │            │              │
 │               │              │ Install    │              │
 │               │              │ ArgoCD     │              │
 │               │              ├───────────>│              │
 │               │              │<───────────┤              │
 │               │<─────────────┤            │              │
 │               │   OK         │            │              │
 │               │              │            │              │
 │               │ Deploy       │            │              │
 │               │ pattern      │            │              │
 │               ├─────────────>│            │              │
 │               │              │            │              │
 │               │              │ Create     │              │
 │               │              │ Application│              │
 │               │              ├───────────>│              │
 │               │              │            │              │
 │               │              │            │ Sync from    │
 │               │              │            │ Git          │
 │               │              │            ├─────────────>│
 │               │              │            │<─────────────┤
 │               │              │            │ Manifests    │
 │               │              │            │              │
 │               │              │<───────────┤              │
 │               │              │ Apply      │              │
 │               │              │ manifests  │              │
 │               │<─────────────┤            │              │
 │               │   OK         │            │              │
 │               │              │            │              │
 │               │ Validate     │            │              │
 │               │ deployment   │            │              │
 │               ├─────────────>│            │              │
 │               │<─────────────┤            │              │
 │<──────────────┤   Report     │            │              │
 │  Complete     │              │            │              │
 │               │              │            │              │
```

### End-User Workflow Sequence

```
┌─────────────────────────────────────────────────────────────────────┐
│               End-User Workflow Sequence Diagram                     │
└─────────────────────────────────────────────────────────────────────┘

User          Ansible    VP Operator   ArgoCD        Git Repo
 │               │            │           │              │
 │ Edit values   │            │           │              │
 │ files         │            │           │              │
 │               │            │           │              │
 │ Run playbook  │            │           │              │
 ├──────────────>│            │           │              │
 │               │            │           │              │
 │               │ Install    │           │              │
 │               │ operator   │           │              │
 │               ├───────────>│           │              │
 │               │<───────────┤           │              │
 │               │   OK       │           │              │
 │               │            │           │              │
 │               │ Create     │           │              │
 │               │ Pattern CR │           │              │
 │               ├───────────>│           │              │
 │               │            │           │              │
 │               │            │ Install   │              │
 │               │            │ GitOps    │              │
 │               │            ├──────────>│              │
 │               │            │<──────────┤              │
 │               │            │           │              │
 │               │            │ Create    │              │
 │               │            │ clustergrp│              │
 │               │            ├──────────>│              │
 │               │            │           │              │
 │               │            │           │ Sync from    │
 │               │            │           │ Git          │
 │               │            │           ├─────────────>│
 │               │            │           │<─────────────┤
 │               │            │           │ Manifests    │
 │               │            │           │              │
 │               │            │<──────────┤              │
 │               │            │ Deploy    │              │
 │               │<───────────┤ complete  │              │
 │<──────────────┤            │           │              │
 │  Complete     │            │           │              │
 │               │            │           │              │
 │ Monitor via   │            │           │              │
 │ ArgoCD UI     │            │           │              │
 │               │            │           │              │
```

---

## Additional Resources

- **[Developer Guide](DEVELOPER-GUIDE.md)** - Development workflow
- **[End-User Guide](END-USER-GUIDE.md)** - Deployment workflow
- **[Ansible Roles Reference](ANSIBLE-ROLES-REFERENCE.md)** - Role details
- **[Deployment Decision Flowchart](DEPLOYMENT-DECISION-FLOWCHART.md)** - Workflow selection
- **[Troubleshooting Guide](TROUBLESHOOTING-COMPREHENSIVE.md)** - Common issues

---

**Document Version:** 1.0
**Last Updated:** 2025-10-27
**Maintained By:** Validated Patterns Toolkit Development Team
