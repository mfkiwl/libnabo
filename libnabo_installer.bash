#!/bin/bash
# =================================================================================================
#
# Install libnabo
#
# Usage:
#   $ bash libnabo_installer.bash [<optional flag>]
#
# Arguments:
#   --install-path </dir/abs/path/>     The directory where to install libnabo (absolute path)
#                                           (default location defined in the .env)
#   --repository-version 1.1.2         Install libnabo release tag version (default to master branch latest)
#   --compile-test                      Compile the libnabo unit-test
#   --generate-doc                      Generate the libnabo doxygen documentation
#                                           in /usr/local/share/doc/libnabo/api/html/index.html
#   --cmake-build-type RelWithDebInfo   The type of cmake build: None Debug Release RelWithDebInfo MinSizeRel
#                                           (default to RelWithDebInfo)
#   --build-system-CI-install           Set special configuration for CI/CD build system:
#                                           skip the git clone install step and assume the repository is already
#                                           pulled and checkout on the desired branch
#   --test-run                          CI/CD build system Test-run mode
#   -h, --help                          Get help
#
# Note:
#   - this script required package: g++, make, cmake, build-essential, git and all libnabo dependencies
#   - execute `libnabo_dependencies_installer.bash` first
#
# =================================================================================================
PARAMS="$@"

MSG_DIMMED_FORMAT="\033[1;2m"
MSG_ERROR_FORMAT="\033[1;31m"
MSG_END_FORMAT="\033[0m"

function nabo::install_libnabo(){

  # ....path resolution logic......................................................................
  NABO_ROOT="$(dirname "$(realpath "$0")")"

  cd "${NABO_ROOT}" || exit 1

  # ....Load environment variables from file.......................................................
  # . . Source NABO environment variables  . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
  if [[ -f .env.libnabo ]]; then
   set -o allexport && source .env.libnabo && set +o allexport
  else
   echo -e "${MSG_ERROR_FORMAT}[NABO ERROR]${MSG_END_FORMAT} .env.libnabo unreachable. Cwd $(pwd)" 1>&2
   exit 1
  fi

  # . . Source NBS dependencies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
  cd "${NBS_PATH}" || exit 1
  source import_norlab_build_system_lib.bash

  # . . Source NABO-build-system environment variables . . . . . . . . . . . . . . . . . . . . . ..
  cd "${NABO_BUILD_SYSTEM_PATH}" || exit 1
  if [[ -f .env ]]; then
   set -o allexport && source .env && set +o allexport
  else
   echo -e "${MSG_ERROR_FORMAT}[NABO ERROR]${MSG_END_FORMAT} .env unreachable. Cwd $(pwd)" 1>&2
   exit 1
  fi

  # ====Begin======================================================================================
  norlab_splash "${NBS_SPLASH_NAME}" "https://github.com/${NBS_REPOSITORY_DOMAIN:?err}/${NBS_REPOSITORY_NAME:?err}"
  export SHOW_SPLASH_ILU=false

  # ....Install general dependencies...............................................................
  cd "${NABO_PATH:?err}"/build_system/ubuntu || exit 1

  # shellcheck disable=SC2068
  source nabo_install_libnabo_ubuntu.bash ${PARAMS[@]}

  print_msg_done "Libnabo install script completed. Have fun"
}

# ::::Main:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # This script is being run, ie: __name__="__main__"
  nabo::install_libnabo
else
  # This script is being sourced, ie: __name__="__source__"
  echo -e "${MSG_ERROR_FORMAT}[NABO ERROR]${MSG_END_FORMAT} Execute this script in a subshell i.e.: $ bash libnabo_installer.bash" 1>&2
  exit 1
fi
