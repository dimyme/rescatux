#!/bin/bash
# Rescapp make_source_code script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
#
# Rescapp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescapp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescapp.  If not, see <http://www.gnu.org/licenses/>.

set -x
set -v


# 1 parametre = Git url
# 2 parametre = Git commit
# 3 parametre = Final Tar.gz
function get_Git_Tar_Gz () {
  local GIT_URL="$1"
  local GIT_COMMIT="$2"
  local FINAL_TAR_GZ="$3"
  local TMP_REPO_DIR="git"

  local PRE_FUNCTION_PWD="$(pwd)"

  local GIT_TEMP_FOLDER="$(mktemp -d)"

  cd "${GIT_TEMP_FOLDER}"
  mkdir ${TMP_REPO_DIR}
  git clone "${GIT_URL}" "${TMP_REPO_DIR}"
  cd ${TMP_REPO_DIR}
  git checkout "${GIT_COMMIT}"

  git archive HEAD | gzip > ${FINAL_TAR_GZ}

  cd "${PRE_FUNCTION_PWD}"
  rm -rf "${GIT_TEMP_FOLDER}"


}

RESCATUX_RELEASE_DIR="$(pwd)/rescatux-release"
BASE_FILENAME="rescatux-`head -n 1 VERSION`"
RESCATUX_GIT_COMMIT="$(git rev-parse HEAD)"
git archive HEAD | gzip > "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-main-rescatux-repo-${RESCATUX_GIT_COMMIT}.tar.gz"

# chntpw

CHNTPW_GIT_URL="https://github.com/rescatux/chntpw"
CHNTPW_GIT_COMMIT="chntpw-ng-1.01"
CHNTPW_GIT_NAME="chntpw"

get_Git_Tar_Gz "${CHNTPW_GIT_URL}" "${CHNTPW_GIT_COMMIT}" "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-${CHNTPW_GIT_NAME}-${CHNTPW_GIT_COMMIT}.tar.gz"

# tails-greeter

TAILSGREETER_GIT_URL="https://github.com/rescatux/tails-greeter.git"
TAILSGREETER_GIT_COMMIT="rescatux_0.40b8"
TAILSGREETER_GIT_NAME="tails-greeter"

get_Git_Tar_Gz "${TAILSGREETER_GIT_URL}" "${TAILSGREETER_GIT_COMMIT}" "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-${TAILSGREETER_GIT_NAME}-${TAILSGREETER_GIT_COMMIT}.tar.gz"

# live-build

LIVEBUILD_GIT_URL="https://github.com/rescatux/live-build/"
LIVEBUILD_GIT_COMMIT="rescatux-0.40b7"
LIVEBUILD_GIT_NAME="live-build"

get_Git_Tar_Gz "${LIVEBUILD_GIT_URL}" "${LIVEBUILD_GIT_COMMIT}" "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-${LIVEBUILD_GIT_NAME}-${LIVEBUILD_GIT_COMMIT}.tar.gz"

# boot-repair

PRE_BOOT_REPAIR_CWD="$(pwd)"

BOOT_REPAIR_APT_TEMP_FOLDER="$(mktemp -d)"

mkdir --parents "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/lib/apt/partial"
mkdir --parents "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/lib/dpkg"
touch "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/lib/dpkg/status"
mkdir --parents "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/cache/apt/archives/partial"
mkdir --parents "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc"
mkdir --parents "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt/trusted.gpg.d"


cat << EOF > "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt.sources.list"
deb-src http://ppa.launchpad.net/yannubuntu/boot-repair/ubuntu trusty main
EOF


cat << EOF > "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt.conf"
Dir::State "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/lib/apt";
Dir::State::status "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/lib/dpkg/status";
Dir::Etc::SourceList "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt.sources.list";
Dir::Cache "${BOOT_REPAIR_APT_TEMP_FOLDER}/var/cache/apt";
pkgCacheGen::Essential "none";
Dir::Etc::TrustedParts "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt/trusted.gpg.d";
EOF

cd "${RESCATUX_RELEASE_DIR}/source-code"
apt-key --keyring "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt/trusted.gpg.d/bootrepair.gpg" adv --keyserver keyserver.ubuntu.com --recv-keys 60D8DA0B
apt-get update -c "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt.conf"
apt-get source boot-repair -c "${BOOT_REPAIR_APT_TEMP_FOLDER}/etc/apt.conf"

rm -rf "${BOOT_REPAIR_APT_TEMP_FOLDER}"

cd "${PRE_BOOT_REPAIR_CWD}"