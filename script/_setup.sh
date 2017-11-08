#!/bin/bash

# This contains repo-specific setup. It is called by `./script/setup`

cur_dir="$(pwd)"
root_checkout_dir="./subrepos"

repo_infos=(
# "repo_name           repo_url                                              branch_name        pull_request_url"
  "rhaptos.cnxmlutils  https://github.com/Connexions/rhaptos.cnxmlutils.git  rng-fixes          https://github.com/Connexions/rhaptos.cnxmlutils/pull/157"
  "cnxml               https://github.com/Connexions/cnxml.git               add-textbook-html  https://github.com/Connexions/cnxml/pull/157"
)


for __git_info in "${repo_infos[@]}"; do
  read -r repo_name repo_url branch_name pull_request_url <<< "${__git_info}"

  if [[ ! -d "${root_checkout_dir}/${repo_name}/.git/" ]]; then
    do_progress_quiet "Cloning ${root_checkout_dir}/${repo_name}" \
      git clone "${repo_url}" "${root_checkout_dir}/${repo_name}/"
  fi

  do_progress_quiet "Checking out ${pull_request_url} (${branch_name}) in ${root_checkout_dir}" \
    cd "${root_checkout_dir}/${repo_name}/" && git checkout "${branch_name}" && git pull && cd "${cur_dir}"
done
