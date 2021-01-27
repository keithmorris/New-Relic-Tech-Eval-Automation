#!/usr/bin/env zsh

# delete SE candidate tech assessment environment

# usage:
# ./killenv.sh candidite-directory-name

tarit() {
	tar cavf ${1%/}.tar.xz ${1}
}

archivelab() {
	tarit ${1}
	rm -rf ${1}
	mkdir -p _ARCHIVE
	mv ${1}.tar.xz _ARCHIVE/
}

pushd ${1}
~/bin/terraform destroy -auto-approve
popd
archivelab ${1}
