#!/bin/bash

copr_name="$1"

specs=(*.spec)
spec="${specs[0]}"

mkdir -p sources rpms
spectool -g "$spec" -C sources

mock_dist=$(mock --offline --shell "rpm --eval 'DIST:%{dist}'" | grep '^DIST:' | cut -d: -f2)
srpm_name=$(rpmspec -q --srpm -D "dist $mock_dist" --queryformat '%{NEVR}.src.rpm\n' "$spec" | grep 'src\.rpm$')

mock --buildsrpm --sources "$PWD/sources" --spec "$PWD/$spec" --resultdir "$PWD/rpms"

if [ -n "$copr_name" ]; then
    copr build "$copr_name" "rpms/$srpm_name"
else
    mock --rebuild "rpms/$srpm_name" --resultdir "$PWD/rpms"
fi
