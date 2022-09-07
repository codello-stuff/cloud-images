#!/usr/bin/env sh

# This script installs the crictl tools. It requires the following environment
# variables:
# - $CRICTL_VERSION: The crio version matching the Kubernetes version (e.g.
#										 1.18.3).

set -e

VERSION="v$CRICTL_VERSION"
yum install -y tar
curl -fsSL https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-$(uname -s)-amd64.tar.gz \
	| tar -xzC /usr/local/bin
