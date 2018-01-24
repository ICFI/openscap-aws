#!/usr/bin/env bash

# Run using docker with the following command
# docker run -v "$(pwd):/src" -it --rm centos:7 /src/build-rpm.sh

# Exit immediately if a command exits with a non-zero status
set -e

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# SCAP Security Guide Version - https://github.com/OpenSCAP/scap-security-guide/releases/
VERSION=0.1.37

# Install rpm creation and validation utilities
yum -y install rpm-build rpmlint

# Tweak default warning when installing files with any other perm than 0644
if [ ! -f ~/.rpmlintrc ]; then
    echo 'setOption("ValidSrcPerms", (0644, 0755 ))' > ~/.rpmlintrc
fi

rm -fr BUILD* RPMS/ SRPMS/

rpmbuild \
    --define "_topdir $(pwd)" \
    --define "_version $VERSION" \
    -ba SPECS/centos/7/openscap-aws.spec

rpmlint SRPMS/*.src.rpm