#!/usr/bin/env bash

set -uxo pipefail

LATEST_URL='https://github.com/cli/cli/releases/latest'
latest_version=$(curl -w "%{url_effective}\n" -I -L -s -S ${LATEST_URL} -o /dev/null | awk -F/ '{print $NF}')

freshen=0
gh_path=$(which gh)
if  [[ $? -ne 0 ]]; then
   freshen=1
   gh_path="${HOME}/.local/bin/gh"
else
   gh_version="v$(gh --version | head -1 | cut -d' ' -f 3)"
   if [[ ${gh_version} != ${latest_version} ]]; then
      freshen=1
   fi
fi

if [[ $freshen == 1 ]]; then
   artifact="gh_${latest_version:1}_linux_amd64.tar.gz"
   stage_dir=$(mktemp -d)
   url="https://github.com/cli/cli/releases/download/${latest_version}/${artifact}"
   curl ${url} -L -o "${stage_dir}/${artifact}"
   pushd "${stage_dir}"
   tar xvfz "${artifact}"
   cp gh_${latest_version:1}_linux_amd64/bin/gh ${gh_path}
   rm -r ${stage_dir}
fi
