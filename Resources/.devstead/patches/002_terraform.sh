#!/usr/bin/env bash

# TERRAFORM INSTALLER - Automated Terraform Installation
#sudoInstall=true


# CHECK DEPENDENCIES AND SET LATEST
if ! unzip -h 2&> /dev/null; then
  echo "unzip not installed and required. installing.."
  apt-get -y install unzip
fi

if ! curl -h 2&> /dev/null; then
  echo "curl not installed and required. installing.."
  apt-get -y install curl
fi

#LATEST=$(curl -s https://api.github.com/repos/nodejs/node/releases/latest 2> /dev/null | awk '/tag_name/ {print $2}' | cut -d '"' -f 2 | cut -d 'v' -f 2)
LATEST="0.11.7"

# POPULATE VARIABLES NEEDED TO CREATE DOWNLOAD URL AND FILENAME
if [[ -z "$VERSION" ]]; then
  VERSION=$LATEST
fi
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [[ "$OS" == "linux" ]]; then
  PROC=$(lscpu 2> /dev/null | awk '/Architecture/ {if($2 == "x86_64") {print "amd64"; exit} else {print "386"; exit}}')
  if [[ -z $PROC ]]; then
    PROC=$(cat /proc/cpuinfo | awk '/flags/ {if($0 ~ /lm/) {print "arm64"; exit} else {print "386"; exit}}')
  fi
else
  PROC="amd64"
fi
[[ $PROC =~ arm ]] && PROC="arm"  # terraform downloads use "arm" not full arm type

# CREATE FILENAME AND DOWNLOAD LINK BASED ON GATHERED PARAMETERS
FILENAME="terraform_${VERSION}_${OS}_${PROC}.zip"
LINK="https://releases.hashicorp.com/terraform/${VERSION}/${FILENAME}"
LINKVALID=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "$LINK")

# VERIFY LINK VALIDITY
if [[ "$LINKVALID" != 200 ]]; then
  echo -e "Cannot Install - Download URL Invalid"
  echo -e "\nParameters:"
  echo -e "\tVER:\t$VERSION"
  echo -e "\tOS:\t$OS"
  echo -e "\tPROC:\t$PROC"
  echo -e "\tURL:\t$LINK"
  exit 1
fi

# DETERMINE DESTINATION
BINDIR="/usr/local/bin"
STREAMLINED=true
if [[ -w "/usr/local/bin" ]]; then
  CMDPREFIX=""
else
  CMDPREFIX="sudo "
fi

# CREATE TMPDIR FOR EXTRACTION
TMPDIR=${TMPDIR:-/tmp}
UTILTMPDIR="terraform_${VERSION}"

cd "$TMPDIR" || exit 1
mkdir -p "$UTILTMPDIR"
cd "$UTILTMPDIR" || exit 1

# DOWNLOAD AND EXTRACT
curl -s -o "$FILENAME" "$LINK"
unzip -qq "$FILENAME" || exit 1

# COPY TO DESTINATION
mkdir -p "${BINDIR}" || exit 1
${CMDPREFIX} cp -f terraform "$BINDIR" || exit 1

# CLEANUP AND EXIT
cd "${TMPDIR}" || exit 1
rm -rf "${UTILTMPDIR}"
[[ ! "$STREAMLINED" ]] && echo
echo "Terraform Version ${VERSION} installed to ${BINDIR}"