# Coder.com Workspace Template for Xen Orchestra (XOA)

## Overview
This repo contains a Terraform template for [coder.com](https://coder.com/) to setup VMs as dev environments on xcp-ng hosts. It dynamically configures virtual machines (VMs) with user-defined resources, installs necessary software, and provides a seamless development environment.

## Features
- Deploys a VM on Xen Orchestra (XOA) from a specified template
- Select pool and host among available ones on XOA
- Configures VM settings like CPU, memory, disk, and networking
- Installs user-specified packages
- Supports custom user setup scripts
- Automatically starts a [coder.com](https://coder.com/) agent
- Optionally installs VS Code Server
- Provides metadata links to the VM and related resources

Most of the resources and settings can be defined by the template creator, as well as the developer creating their workspace.

This template handles
- Changing non-critical variables on the fly (memory, cpu, network)
- Starting, stopping and deleting workspaces cleanly

## Prerequisites
Ensure you have the following:
- A running Xen Orchestra (XOA) instance
- Terraform installed
- A valid Xen Orchestra API token
- A [coder.com](https://coder.com/) environment set up
