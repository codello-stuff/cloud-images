#!/usr/bin/env sh

# This scripts runs cleanup operations after preparing a kubernetes node.

set -e

yum clean all -y
