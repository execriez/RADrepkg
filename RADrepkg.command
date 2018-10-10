#!/bin/bash
#
# Package up the files and folders as defined by radmind transcript
# Usage:
#   RADrepkg [transcript [title id version minsystem arch pkgname]]
#
# Mark J Swift
GLB_VERSTAG="1.0.10"

[ 1 -eq 1 ];GLB_TRUE=$?
[ 1 -ne 1 ];GLB_FALSE=$?

# Full souce of this script
GLB_MYSOURCE="${0}"

# Path to this script
GLB_MYPATH="$(dirname "${GLB_MYSOURCE}")"

# Filename of this script
GLB_MYSCRIPT="$(basename "${GLB_MYSOURCE}")"

# Filename without extension
GLB_MYNAME="$(basename "${GLB_MYSOURCE}" | sed "s/\.[^\.]*$//g")"

# Get user name
GLB_USERNAME="$(whoami)"

# Get system info
GLB_SystemVersionStampAsString=$(sw_vers -productVersion)
GLB_SystemVersionStampAsNumber=0
for num in $(echo ${GLB_SystemVersionStampAsString}".0.0.0.0" | cut -d"." -f1-4 | tr "." "\n")
do
  GLB_SystemVersionStampAsNumber=$((${GLB_SystemVersionStampAsNumber}*256+${num}))
done

GLB_SystemMajorVersion=$(echo ${GLB_SystemVersionStampAsString}".0.0.0.0" | cut -d"." -f1-2)

if [ ${GLB_SystemVersionStampAsNumber} -lt 168099840 ]
then
  GLB_DSdefaultLocalNode="/NetInfo/DefaultLocalNode"
else
  GLB_DSdefaultLocalNode="."
fi

# Check if user is an admin (returns "yes" or "no")
GLB_ISADMIN=$(dseditgroup -o checkmember -m "${GLB_USERNAME}" -n "${GLB_DSdefaultLocalNode}" admin | cut -d" " -f1) 

# change directory to where this script is running
cd "${GLB_MYPATH}"

# here we go...
echo "${GLB_MYNAME} version ${GLB_VERSTAG}"

if [ ${GLB_ISADMIN} = "no" ]
then
  echo "Sorry, this script can only be run as an administrator."
  exit 0
fi

# path to Radmind support files
GLB_RADPATH="/private/var/radmind"

GLB_RADCMDPATH="${GLB_MYPATH}"/bin
if ! test -f "${GLB_RADCMDPATH}"/fsdiff
then
  GLB_RADCMDPATH="/usr/local/bin"
fi

ln -sf "${GLB_RADCMDPATH}" /tmp/radcmdpath

GLB_RADCMDPATH="/tmp/radcmdpath"

if ! test -e /usr/bin/pkgbuild
then
  # We must be running an early system
  echo "You are running an OS that doesn't include pkgbuild."

  if ! test -e "${GLB_MYPATH}"/bin/PackageMaker.app
  then
    echo "You need to download a copy of PackageMaker.app"
    echo "Unfortunately, this can only be obtained by installing XCode."
    echo "You may want to do this on a test machine, then copy the application from"
    echo "/Developer/Applications/Utilities/ into RADrepkg/bin/"

    case ${GLB_SystemMajorVersion} in
    10.4)
      echo "DO THIS:"
      echo "1. Browse to https://developer.apple.com/downloads/"
      echo "2. Log in using your Apple ID"
      echo "3. Under categories, deselect everything except Developer Tools"
      echo "4. Type 'xcode 2.5' into the search box."
      echo "5. Download 'Xcode 2.5 Developer Tools' (902.91 MB)."
      echo "6. Install XCode."
      echo "7. Copy PackageMaker.app into RADrepkg/bin/"
      ;;

    10.5)
      echo "DO THIS:"
      echo "1. Browse to https://developer.apple.com/downloads/"
      echo "2. Log in using your Apple ID"
      echo "3. Under categories, deselect everything except Developer Tools"
      echo "4. Type 'xcode 3.1.4' into the search box."
      echo "5. Download 'Xcode 3.1.4 Developer Tools' (993.04 MB)."
      echo "6. Install XCode."
      echo "7. Copy PackageMaker.app into RADrepkg/bin/"
      ;;

    10.6)
      echo "DO THIS:"
      echo "1. Browse to https://developer.apple.com/downloads/"
      echo "2. Log in using your Apple ID"
      echo "3. Under categories, deselect everything except Developer Tools"
      echo "4. Type 'xcode 3.2.6' into the search box."
      echo "5. Download 'Xcode 3.2.6 and iOS SDK for Snow Leopard' (4.14 GB)."
      echo "6. Install XCode."
      echo "7. Copy PackageMaker.app into RADrepkg/bin/"
      ;;

    esac

    exit 0
  fi
fi

GLB_NPARAMS=$#
if [ $GLB_NPARAMS -eq 0 ]
then
  GLB_DOCFILE="${GLB_MYPATH}"/snapshotdiff.T
  GLB_NPARAMS=1
else
  GLB_DOCFILE="${1}"
fi

# check if file exists
if ! ( test -r "${GLB_DOCFILE}" )
then
  echo "File not found:${GLB_DOCFILE}"
  GLB_NPARAMS=0
fi

# --------------------------------
# quit on bad parameter 

if [[ $GLB_NPARAMS -ne 1 ]] && [[ $GLB_NPARAMS -ne 7 ]]
then
  echo "This script builds an installable package from a radmind transcript or command file."
  echo "Usage"
  echo "  ${GLB_MYNAME} [[transcript] title id version minsystem arch pkgname]"
  echo
  GLB_DOCFILE=$(find /private/var/radmind/client \( -iname "*.K" \) -or \( -iname "*.T" \) | tail -n1)
  if test -n "${GLB_DOCFILE}"
  then
    echo "The following is a list of known transcripts/commands on this client..."
    find /private/var/radmind/client \( -iname "*.K" \) -or \( -iname "*.T" \)
    echo
  fi
  if test -z "${GLB_DOCFILE}"
  then
    GLB_DOCFILE="${GLB_MYPATH}"/snapshotdiff.T
  fi
  echo "This script should be passed a radmind transcript or command as a parameter for example..."
  echo "'${GLB_MYSOURCE}' '${GLB_DOCFILE}'"
  echo
  exit 0
fi

echo "processing ${GLB_DOCFILE}"

GLB_ESCR=$(echo "a" | tr "a" "\015")

GLB_RADPATH="/private/var/radmind"
GLB_RADTPATH=${GLB_RADPATH}/client
GLB_RADKPATH=${GLB_RADPATH}/client

GLB_DOCNAME=$(basename "${GLB_DOCFILE}" | tr "." "\n" | head -n1)
GLB_DOCEXT=$(basename "${GLB_DOCFILE}" | tr "." "\n" | tail -n1 | tr [a-z] [A-Z])

# Create a temporary directory
#GLB_MYTMPDIR=$(mktemp -dt "${GLB_DOCNAME}.XXXXXX")

GLB_MYTMPDIR="${GLB_MYPATH}/${GLB_DOCNAME}.$$"
mkdir -p "${GLB_MYTMPDIR}"

case ${GLB_DOCEXT} in
K)
  # Merge command file into a single transcript
  cd ${GLB_RADTPATH}
  ${GLB_RADCMDPATH}/lmerge -IT $("${GLB_MYPATH}"/bin/RADexplodeK.sh "${GLB_DOCFILE}" | tail -r | grep "^p " | cut -d" " -f2 | tr "\n" " ") "${GLB_MYTMPDIR}"/${GLB_DOCNAME}.T
  if [ $? -ne 0 ]
  then
    ${GLB_RADCMDPATH}/lmerge -T $("${GLB_MYPATH}"/bin/RADexplodeK.sh "${GLB_DOCFILE}" | tail -r | grep "^p " | cut -d" " -f2 | tr "\n" " ") "${GLB_MYTMPDIR}"/${GLB_DOCNAME}.T
  fi
  ;;
  
T)
  cp "${GLB_DOCFILE}" "${GLB_MYTMPDIR}"/${GLB_DOCNAME}.T
  ;;
  
*)
  echo "Unknown file extension '${GLB_DOCEXT}'"
  echo
  rm -fR "${GLB_MYTMPDIR}"
  exit 0  
  ;;
  
esac

cd "${GLB_MYTMPDIR}"
GLB_DOCFILE="${GLB_MYTMPDIR}"/${GLB_DOCNAME}.T

# Get package options

if [ ${GLB_NPARAMS} -eq 7 ]
then
  MAIN_PKGTITLE="${2}"
  MAIN_PKGIDENTIFIER=${3}
  MAIN_PKGVERSION=${4}
  MAIN_MINSYSTEM=${5}
  MAIN_ARCH=${6}
  GLB_PKGNAME="${7}"

else
  # Check if the name conforms to my transcript naming convention:
  # Type-Vendor-Product[-ProductDesc]-Version-MinSystem-Architecture.T
  # eg app-Google-GoogleChrome-39v0v2171v99-10v6-i386.T

  MAIN_TEMP=$(echo ${GLB_DOCNAME}.${GLB_DOCEXT} | grep -E "^(apl|app|dat|dvr|lic|pdv|ptr|sdv|tdv)(-[0-9A-Za-z_]*)*-([0-9]{1,}(v[0-9]{1,})*(v[0-9A-Za-uw-z]{1,})*)-([0-9]{1,}v[0-9]{1,})-(i386|ppc).T$")
  if test -n "${MAIN_TEMP}"
  then
    # Deduce the required info from the transcript name

    GLB_PKGNAME=$(echo ${GLB_DOCNAME} | sed -E "s/-([0-9]{1,}(v[0-9]{1,})*(v[0-9A-Za-uw-z]{1,})*)-([0-9]{1,}v[0-9]{1,})-(i386|ppc)$//")

    MAIN_PKGIDENTIFIER="com.github.execriez.radrepkg.${GLB_PKGNAME}"

    MAIN_PKGTITLE=$(echo ${GLB_PKGNAME} | cut -d "-" -f2- | tr "-" " ")

    MAIN_TEMP=$(echo ${GLB_DOCNAME} | grep -oE "([0-9]{1,}(v[0-9]{1,})*(v[0-9A-Za-uw-z]{1,})*)-([0-9]{1,}v[0-9]{1,})-(i386|ppc)$")

    MAIN_PKGVERSION=$(echo ${MAIN_TEMP} | cut -d"-" -f1)
    GLB_PKGNAME=${GLB_PKGNAME}-${MAIN_PKGVERSION}
    MAIN_PKGVERSION=$(echo ${MAIN_PKGVERSION}| tr "v" ".")

    MAIN_MINSYSTEM=$(echo ${MAIN_TEMP} | cut -d"-" -f2 | tr "v" ".")

    MAIN_ARCH=$(echo ${MAIN_TEMP} | cut -d"-" -f3)


  else
    MAIN_DFLT="Selective Files"
    printf "Enter a title for the installer package (e.g. ${MAIN_DFLT}):"
    read MAIN_PKGTITLE
    if test -z "${MAIN_PKGTITLE}"
    then
      MAIN_PKGTITLE=${MAIN_DFLT}
    fi

    MAIN_DFLT="com.github.execriez.radrepkg.${GLB_DOCNAME}"
    printf "Enter package identifier (e.g. ${MAIN_DFLT}):"
    read MAIN_PKGIDENTIFIER
    if test -z "${MAIN_PKGIDENTIFIER}"
    then
      MAIN_PKGIDENTIFIER=${MAIN_DFLT}
    fi

    MAIN_DFLT="1.0.0"
    printf "Enter package version (e.g. ${MAIN_DFLT}):"
    read MAIN_PKGVERSION
    if test -z "${MAIN_PKGVERSION}"
    then
      MAIN_PKGVERSION=${MAIN_DFLT}
    fi

    MAIN_DFLT=${GLB_SystemMajorVersion}
    printf "Enter minimum system requirements (e.g. ${MAIN_DFLT}):"
    read MAIN_MINSYSTEM
    if test -z "${MAIN_MINSYSTEM}"
    then
      MAIN_MINSYSTEM=${MAIN_DFLT}
    fi

    MAIN_DFLT=$(arch)
    printf "Enter required architecture (e.g. ${MAIN_DFLT}):"
    read MAIN_ARCH
    if test -z "${MAIN_ARCH}"
    then
      MAIN_ARCH=${MAIN_DFLT}
    fi

    MAIN_DFLT="${GLB_DOCNAME}.pkg"
    printf "Enter a name for the installer file (e.g. ${MAIN_DFLT}):"
    read GLB_PKGNAME
    if test -z "${GLB_PKGNAME}"
    then
      GLB_PKGNAME=${MAIN_DFLT}
    fi

  fi
fi

# Package filename without extension
GLB_PKGNAME="$(basename "${GLB_PKGNAME}" | sed "s/\.[^\.]*$//g")"

MAIN_FAUXROOT="${GLB_MYTMPDIR}"/${GLB_PKGNAME}
mkdir -p "${MAIN_FAUXROOT}"

# Fix transcript for SIP on OSX 10.11
if test -e "${GLB_MYPATH}"/bin/RadmindTfix4SIP.sh
then
  "${GLB_MYPATH}"/bin/RadmindTfix4SIP.sh "${GLB_DOCFILE}"
fi

# list all files/directories , excluding negatives
cat "${GLB_DOCFILE}" | grep -v "^-" | cut -f1 | cut -d" " -f2- | cut -d" " -f1 | sed "s|[ ]*$||" | sort -u > "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt

# list parent directories
cat "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt | sed 's|/[^/]*$||;s|/$||;/^\s*$/d' | sort -u > "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-dir.txt

# build the full hierarhy
while test -s "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-dir.txt
do
  cat "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-dir.txt >>"${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt
  sed -i .bak "s|/[^/]*$||;/^\s*$/d" "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-dir.txt
done
rm -f "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-dir.txt
rm -f "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-dir.txt.bak

# sort and include only unique items - then unescape escaped characters
cp "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-tmp.txt
cat "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-tmp.txt | sort -u | sed "s|\\\b| |g" | sed "s|\\\r|""${GLB_ESCR}""|g" | sed "s|\\\\\\\|\\\|g" > "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt

rm -f "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-tmp.txt

echo "building package ${MAIN_PKGIDENTIFIER} version ${MAIN_PKGVERSION}"

printf "This installation package was created using RADrepkg.\nhttps://github.com/execriez/RADrepkg/\n\n" >"${GLB_MYPATH}"/resources/PKG-Resources/ReadMe.txt

# Commented out because there's a bug in 10.10 where installer crashes if given a large readme
#printf "The following files will be installed:\n\n" >>"${GLB_MYPATH}"/resources/PKG-Resources/ReadMe.txt
#cat "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt >>"${GLB_MYPATH}"/resources/PKG-Resources/ReadMe.txt

sudo su root <<USERSUEND1

echo "copying files"
cat "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-files.txt | pax -r -w -d -p e "${MAIN_FAUXROOT}"

if ! test -e /usr/bin/pkgbuild
then
  if [ ${GLB_SystemVersionStampAsNumber} -lt 168099840 ]
  then
    # OS 10.4, use Packagemaker v2.1.1

cat << PLISTEND1 > "${GLB_MYTMPDIR}"/Description.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>IFPkgDescriptionTitle</key>
  <string>${MAIN_PKGTITLE}</string>
</dict>
</plist>
PLISTEND1

cat << PLISTEND2 > "${GLB_MYTMPDIR}"/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>${MAIN_PKGIDENTIFIER}</string>
  <key>CFBundleShortVersionString</key>
  <string>${MAIN_PKGVERSION}</string>
  <key>IFPkgFlagAllowBackRev</key>
  <true/>
  <key>IFPkgFlagAuthorizationAction</key>
  <string>AdminAuthorization</string>
  <key>IFPkgFlagBackgroundAlignment</key>
  <string>topleft</string>
  <key>IFPkgFlagBackgroundScaling</key>
  <string>none</string>
  <key>IFPkgFlagDefaultLocation</key>
  <string>/</string>
  <key>IFPkgFlagFollowLinks</key>
  <true/>
  <key>IFPkgFlagInstallFat</key>
  <true/>
  <key>IFPkgFlagIsRequired</key>
  <false/>
  <key>IFPkgFlagOverwritePermissions</key>
  <false/>
  <key>IFPkgFlagRelocatable</key>
  <false/>
  <key>IFPkgFlagRestartAction</key>
  <string>NoRestart</string>
  <key>IFPkgFlagRootVolumeOnly</key>
  <false/>
  <key>IFPkgFlagUpdateInstalledLanguages</key>
  <false/>
</dict>
</plist>
PLISTEND2

    "${GLB_MYPATH}"/bin/PackageMaker.app/Contents/MacOS/PackageMaker -build -f "${MAIN_FAUXROOT}" -r "${GLB_MYPATH}"/resources/PKG-Resources -i "${GLB_MYTMPDIR}"/Info.plist -d "${GLB_MYTMPDIR}"/Description.plist -p "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg

  else

    # OS 10.5 use PackageMaker 3.0.3 - OS 10.6 use PackageMaker 3.0.4

    "${GLB_MYPATH}"/bin/PackageMaker.app/Contents/MacOS/PackageMaker --verbose --root "${MAIN_FAUXROOT}" --id "${MAIN_PKGIDENTIFIER}" --version "${MAIN_PKGVERSION}" --title "${MAIN_PKGTITLE}" --resources "${GLB_MYPATH}"/resources/PKG-Resources --target "10.5" --no-recommend --no-relocate --out "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg

    if test -e "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg
    then

      # un-archive the pkg contents
      pkgutil --expand "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg
      rm -fR "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg

      # -- add options for title, background, licence & readme --
      awk '/<\/installer-script>/ && c == 0 {c = 1; print "<background file=\"background.jpg\" mime-type=\"image/jpg\" />\n<welcome file=\"Welcome.txt\"/>\n<license file=\"License.txt\"/>\n<readme file=\"ReadMe.txt\"/>"}; {print}' "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg/Distribution > "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg/DistributionNew
      cp "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg/DistributionNew "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg/Distribution
      rm -f "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg/DistributionNew

      # re-archive the pkg contents
      pkgutil --flatten "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg
      rm -fR "${GLB_MYTMPDIR}"/${GLB_PKGNAME}-pkg

    fi

  fi

else
  # OS 10.7 and later, use pkgbuild

  pkgbuild --root ${MAIN_FAUXROOT} --identifier ${MAIN_PKGIDENTIFIER} --version ${MAIN_PKGVERSION} --ownership preserve --install-location / "${GLB_MYTMPDIR}"/${GLB_PKGNAME}.pkg
      
  # -- Create requirements.plist file --

  cat << PLISTEND3 > "${GLB_MYTMPDIR}"/requirements.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>os</key>
  <array>
    <string>${MAIN_MINSYSTEM}</string>
  </array>
  <key>arch</key>
  <array>
    <string>${MAIN_ARCH}</string>
  </array>
</dict>
</plist>
PLISTEND3

  # -- Synthesise a temporary distribution.plist file --
  productbuild --synthesize --product "${GLB_MYTMPDIR}"/requirements.plist --package "${GLB_MYTMPDIR}"/${GLB_PKGNAME}.pkg "${GLB_MYTMPDIR}"/temp.plist

  # -- add options for title, background, licence & readme --
  awk '/<\/installer-gui-script>/ && c == 0 {c = 1; print "<title>'"${MAIN_PKGTITLE}"'</title>\n<background file=\"background.jpg\" mime-type=\"image/jpg\" />\n<welcome file=\"Welcome.txt\"/>\n<license file=\"License.txt\"/>\n<readme file=\"ReadMe.txt\"/>"}; {print}' "${GLB_MYTMPDIR}"/temp.plist > "${GLB_MYTMPDIR}"/distribution.plist

  # -- build the final package --
  cd "${GLB_MYTMPDIR}"
  productbuild --distribution distribution.plist --resources "${GLB_MYPATH}"/resources/PKG-Resources "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg

fi

echo "removing temporary files"
rm -fR "${MAIN_FAUXROOT}"

chown ${GLB_USERNAME} "${GLB_MYPATH}"/${GLB_PKGNAME}.pkg

USERSUEND1

rm -f "${GLB_MYPATH}"/resources/PKG-Resources/ReadMe.txt

# -- remove remaining temporary files --
rm -fR "${GLB_MYTMPDIR}"
rm -f /tmp/radcmdpath

echo "done"
