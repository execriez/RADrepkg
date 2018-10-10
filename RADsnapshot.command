#!/bin/bash
#
# Do an initial scan of the system in order to prime the client transcripts
#
#
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

if ! test -f "${GLB_RADCMDPATH}"/fsdiff
then
  if [ ${GLB_SystemVersionStampAsNumber} -lt 168165376 ]
  then
    echo "Please download and install version 1.13.0 of the Radmind tools from: "
    echo "http://sourceforge.net/projects/radmind/files/radmind/radmind-1.13.0/"
  else
    echo "Please download and install the Radmind tools from: "
    echo "http://sourceforge.net/projects/radmind/"
  fi
  exit 0
fi

# Get radtools version
GLB_RADTOOLSVERSTR=$("${GLB_RADCMDPATH}"/fsdiff -V | head -n1)
GLB_RADTOOLSVERNUM=0
if test -n "${GLB_RADTOOLSVERSTR}"
then
  for num in $(echo ${GLB_RADTOOLSVERSTR}".0.0.0.0" | cut -d"." -f1-4 | tr "." "\n")
  do
    GLB_RADTOOLSVERNUM=$((${GLB_RADTOOLSVERNUM}*256+${num}))
  done
fi

if [ ${GLB_RADTOOLSVERNUM} -eq 0 ] || ( [ ${GLB_SystemVersionStampAsNumber} -lt 168165376 ] && [ ${GLB_RADTOOLSVERNUM} -gt 17629184 ] )
then
  echo "The installed version of Radmind tools doesn't work on this OS."
  if [ ${GLB_SystemVersionStampAsNumber} -lt 168165376 ]
  then
    echo "Please download and install version 1.13.0 from:"
    echo "http://sourceforge.net/projects/radmind/files/radmind/radmind-1.13.0/"
  fi
  printf "Do you want to remove the installed version of RadmindTools? (Y/n):"
  read GLB_YN
  if [ "${GLB_YN}" = "Y" ]
  then
    # Execute everything within HEREDOC_SU2 with escalated privs.
    # It's quoted. You can create new vars, but vars from outside are not available.  
    sudo su root <<'HEREDOC_SU0'
while read LCL_RADTOOLFILE
do
  if test -e ${LCL_RADTOOLFILE}
  then
    # delete the installed radmind tools
    if test -d ${LCL_RADTOOLFILE}
    then
      rm -d ${LCL_RADTOOLFILE}
    else
      rm -f ${LCL_RADTOOLFILE}
    fi
  fi
done << HEREDOCRADTOOLS0
/usr/local/share/man8/radmind.8
/usr/local/share/man8
/usr/local/share/man5/applefile.5
/usr/local/share/man5
/usr/local/share/man1/twhich.1
/usr/local/share/man1/repo.1
/usr/local/share/man1/rash.1
/usr/local/share/man1/lsort.1
/usr/local/share/man1/lmerge.1
/usr/local/share/man1/lfdiff.1
/usr/local/share/man1/lcreate.1
/usr/local/share/man1/lcksum.1
/usr/local/share/man1/lapply.1
/usr/local/share/man1/ktcheck.1
/usr/local/share/man1/fsdiff.1
/usr/local/share/man1
/usr/local/share/man/man8/radmind.8
/usr/local/share/man/man8
/usr/local/share/man/man5/applefile.5
/usr/local/share/man/man5
/usr/local/share/man/man1/twhich.1
/usr/local/share/man/man1/repo.1
/usr/local/share/man/man1/rash.1
/usr/local/share/man/man1/lsort.1
/usr/local/share/man/man1/lmerge.1
/usr/local/share/man/man1/lfdiff.1
/usr/local/share/man/man1/lcreate.1
/usr/local/share/man/man1/lcksum.1
/usr/local/share/man/man1/lapply.1
/usr/local/share/man/man1/ktcheck.1
/usr/local/share/man/man1/fsdiff.1
/usr/local/share/man/man1
/usr/local/share/man
/usr/local/share
/usr/local/sbin/radmind
/usr/local/sbin
/usr/local/bin/twhich
/usr/local/bin/repo
/usr/local/bin/ra.sh
/usr/local/bin/lsort
/usr/local/bin/lmerge
/usr/local/bin/lfdiff
/usr/local/bin/lcreate
/usr/local/bin/lcksum
/usr/local/bin/lapply
/usr/local/bin/ktcheck
/usr/local/bin/fsdiff
/usr/local/bin
/usr/local
/private/var/radmind/preapply
/private/var/radmind/postapply
/private/var/radmind/client
/private/var/radmind/cert
/private/var/radmind
/private/var/db/receipts/edu.umich.radmind.plist
/private/var/db/receipts/edu.umich.radmind.bom
HEREDOCRADTOOLS0
if test -e "/Library/Receipts"
then
  find /Library/Receipts -depth 1 -iname "RadmindTools*" -prune -exec rm -fR "{}" \;
fi
HEREDOC_SU0

  fi

  exit 0
fi

  echo "Creating a known state snapshot of this workstation..."

  GLB_START_EPOCH=$(date -u "+%s")

  # info about this workstation
  GLB_ARCH=$(arch)

  # formulate a name for the base transcript
  GLB_BASETRANSCRIPT="os-Apple-OSX-"$(echo ${GLB_SystemVersionStampAsString}".0.0.0" | cut -d"." -f1-3 | tr "." "v")"v"$(date -r ${GLB_START_EPOCH} "+%Y%m%d%H%M")"-"$(echo ${GLB_SystemVersionStampAsString}".0.0.0" | cut -d"." -f1-2 | tr "." "v")"-"${GLB_ARCH}".T"

  # Execute everything within HEREDOC_SU1 with escalated privs.
  # It's not quoted. You can't create new vars, but vars from outside are available.  
  sudo su root <<HEREDOC_SU1

  mkdir -p ${GLB_RADPATH}/cert
  mkdir -p ${GLB_RADPATH}/client
  mkdir -p ${GLB_RADPATH}/client/labwarden/exc
  mkdir -p ${GLB_RADPATH}/postapply
  mkdir -p ${GLB_RADPATH}/preapply

  # Copy the general negative and exclude files in place
  cp "${GLB_MYPATH}"/Resources/radmind/transcript/*.T ${GLB_RADPATH}/client/
  cp "${GLB_MYPATH}"/Resources/radmind/command/labwarden/exc/*.K ${GLB_RADPATH}/client/labwarden/exc

HEREDOC_SU1



  # Execute everything within HEREDOC_SU2 with escalated privs.
  # It's quoted. You can create new vars, but vars from outside are not available.  
  sudo su root <<'HEREDOC_SU2'

  LCL_START_EPOCH=$(date -u "+%s")

  # path to Radmind support files
  LCL_RADPATH="/private/var/radmind"

  LCL_RADCMDPATH="/tmp/radcmdpath"
  
  # should we backup the existing command file?
  if test -f ${LCL_RADPATH}/client/command.K
  then
    if test -z "$(cat ${LCL_RADPATH}/client/command.K | grep "RADsnapshot command file")"
    then
      cp ${LCL_RADPATH}/client/command.K ${LCL_RADPATH}/client/command-backup-$(date -r ${LCL_START_EPOCH} "+%Y%m%d%H%M").K
    fi
  fi

  # Work out the correct neg and exc files for the OS
  LCL_NEGT=""
  LCL_EXCK=""
  LCL_COUNT=0
  while [  $LCL_COUNT -le $(sw_vers -productVersion | cut -d"." -f2) ]; do
    os_name="10v${LCL_COUNT}"
    
    # get latest neg transcript version for this OS
    sw_name="neg-Apple-OSX"
    sw_ver=$(ls -1 "${LCL_RADPATH}"/client | grep -E "^$sw_name-" | grep -E ".*-$os_name-i386.T$" | grep -oE "([0-9]{1,}(v[0-9]{1,})*(v[0-9A-Za-uw-z]{1,})*)-([0-9]{1,}v[0-9]{1,})-i386.T$" | cut -d"-" -f1 | tr "v" " " | sort -n -t" " -k1 -k2 -k3 -k4 -k5 -k6 | tr " " "v" | tail -n1)
    if test -n "$sw_ver"
    then
      LCL_NEGT=$sw_name-$sw_ver-$os_name-i386.T
    fi

    # get the exclude command name for this OS (if any)
    command_name=$( ls -1 "${LCL_RADPATH}"/client/labwarden/exc | grep -E "^exc-Apple-OSX-"${os_name}"-i386.K$" )
    if test -n "$command_name"
    then
      LCL_EXCK=$command_name
    fi

    LCL_COUNT=$((${LCL_COUNT}+1))
  done
  
  # Create a minimum workstation command file (manifest)
  cat << HEREDOC_FILE1 > ${LCL_RADPATH}/client/command.K
# RADsnapshot command file
n ${LCL_NEGT}
k labwarden/exc/${LCL_EXCK}
HEREDOC_FILE1

  # -- Create a radmind tools transcript --

LCL_RADTOOLSVERSTR=$("${LCL_RADCMDPATH}"/fsdiff -V | head -n1 | tr "." "v")
LCL_RADTOOLSNAMET="app-UMich-RadmindTools-${LCL_RADTOOLSVERSTR}-10v0-i386.T"

# create radtools transcript
rm -f ${LCL_RADPATH}/client/${LCL_RADTOOLSNAMET}
while read LCL_RADTOOLFILE
do
  if test -e ${LCL_RADTOOLFILE}
  then
    "${LCL_RADCMDPATH}"/fsdiff -1 -I ${LCL_RADTOOLFILE} >>${LCL_RADPATH}/client/${LCL_RADTOOLSNAMET}
  fi
done << HEREDOCRADTOOLS1
/Library/Receipts/RadmindTools-1.13.0.pkg
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Archive.bom
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Info.plist
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/PkgInfo
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/background.tiff
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/en.lproj
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/en.lproj/Description.plist
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/License.rtf
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/package_version
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/ReadMe.rtf
/Library/Receipts/RadmindTools-1.13.0.pkg/Contents/Resources/Welcome.rtf
/private/var/db/receipts/edu.umich.radmind.bom
/private/var/db/receipts/edu.umich.radmind.plist
/private/var/radmind
/private/var/radmind/cert
/private/var/radmind/postapply
/private/var/radmind/preapply
/usr/local
/usr/local/bin
/usr/local/bin/fsdiff
/usr/local/bin/ktcheck
/usr/local/bin/lapply
/usr/local/bin/lcksum
/usr/local/bin/lcreate
/usr/local/bin/lfdiff
/usr/local/bin/lmerge
/usr/local/bin/lsort
/usr/local/bin/ra.sh
/usr/local/bin/repo
/usr/local/bin/twhich
/usr/local/sbin
/usr/local/sbin/radmind
/usr/local/share
/usr/local/share/man
/usr/local/share/man/man1
/usr/local/share/man/man1/fsdiff.1
/usr/local/share/man/man1/ktcheck.1
/usr/local/share/man/man1/lapply.1
/usr/local/share/man/man1/lcksum.1
/usr/local/share/man/man1/lcreate.1
/usr/local/share/man/man1/lfdiff.1
/usr/local/share/man/man1/lmerge.1
/usr/local/share/man/man1/lsort.1
/usr/local/share/man/man1/rash.1
/usr/local/share/man/man1/repo.1
/usr/local/share/man/man1/twhich.1
/usr/local/share/man/man5
/usr/local/share/man/man5/applefile.5
/usr/local/share/man/man8
/usr/local/share/man/man8/radmind.8
/usr/local/share/man1
/usr/local/share/man1/fsdiff.1
/usr/local/share/man1/ktcheck.1
/usr/local/share/man1/lapply.1
/usr/local/share/man1/lcksum.1
/usr/local/share/man1/lcreate.1
/usr/local/share/man1/lfdiff.1
/usr/local/share/man1/lmerge.1
/usr/local/share/man1/lsort.1
/usr/local/share/man1/rash.1
/usr/local/share/man1/repo.1
/usr/local/share/man1/twhich.1
/usr/local/share/man5
/usr/local/share/man5/applefile.5
/usr/local/share/man8
/usr/local/share/man8/radmind.8
HEREDOCRADTOOLS1
HEREDOC_SU2

  # Execute everything within HEREDOC_SU2 with escalated privs.
  # It's quoted. You can create new vars, but vars from outside are not available.  
  sudo su root <<'HEREDOC_SU3'

  # path to Radmind support files
  LCL_RADPATH="/private/var/radmind"

  LCL_RADCMDPATH="/tmp/radcmdpath"

  LCL_RADTOOLSVERSTR=$("${LCL_RADCMDPATH}"/fsdiff -V | head -n1 | tr "." "v")
  LCL_RADTOOLSNAMET="app-UMich-RadmindTools-${LCL_RADTOOLSVERSTR}-10v0-i386.T"

  echo "p ${LCL_RADTOOLSNAMET}" >> ${LCL_RADPATH}/client/command.K

  # -- Create a new localised negative transcript --

  LCL_TEMPFILE=$(mktemp /tmp/RADsnapshot.XXXXXX)

  mount | sed -E 's/^.* on //;s/ \([^(]*\)$//' | grep -v '^/$' | while read LCL_MOUNTPOINT
  do
    if test -z "$(${LCL_RADCMDPATH}/twhich -Ir "${LCL_MOUNTPOINT}" | grep -E "^# Negative$")"
    then
      "${LCL_RADCMDPATH}"/fsdiff -1 -I -csha1 "${LCL_MOUNTPOINT}" >> ${LCL_TEMPFILE}
    fi

  done

  rm -f ${LCL_RADPATH}/client/neg-Workstation-LocalFS-1v0v0-10v0-i386.T

  if test -s ${LCL_TEMPFILE}
  then
    cat << HEREDOC_FILE2 > ${LCL_RADPATH}/client/neg-Workstation-LocalFS-1v0v0-10v0-i386.T
# Negative transcript - local workstation specific.
# - This file should be generated on the workstation, prior to any filesystem
# - checks (fsdiff). It should contain negative items specific to the workstation.
# - Specifically, it should contain unusual mount points that you do not want to
# - be traversed during the filesystem check.
#
HEREDOC_FILE2

    "${LCL_RADCMDPATH}"/lsort -I ${LCL_TEMPFILE} >>${LCL_RADPATH}/client/neg-Workstation-LocalFS-1v0v0-10v0-i386.T
  fi
  rm -f ${LCL_TEMPFILE}

HEREDOC_SU3

  # -- Create the base transcript --

  GLB_TEMPFILE=$(mktemp /tmp/tempfile.XXXXXX)

  # Execute everything within HEREDOC_SU4 with escalated privs.
  # It's not quoted. You can't create new vars, but vars from outside are available.  
  sudo su root <<HEREDOC_SU4

  if test -e ${GLB_RADPATH}/client/neg-Workstation-LocalFS-1v0v0-10v0-i386.T
  then
    # Add the local negative transcript to the command file
    echo "n neg-Workstation-LocalFS-1v0v0-10v0-i386.T" > ${GLB_TEMPFILE}
    cat ${GLB_RADPATH}/client/command.K | grep -v "neg-Workstation-LocalFS-" >> ${GLB_TEMPFILE}
    cp ${GLB_TEMPFILE} ${GLB_RADPATH}/client/command.K
    rm -f ${GLB_TEMPFILE}
  fi

  # Create the base transcript (file payload)
  # If you want to enable fsdiff checksums, add the option -csha1
  #"${GLB_RADCMDPATH}"/fsdiff -I -C -o${GLB_RADPATH}/client/${GLB_BASETRANSCRIPT} -% /

  "${GLB_RADCMDPATH}"/fsdiff -I -C -o${GLB_TEMPFILE} -% /
  cat ${GLB_TEMPFILE} | grep -Ev "^- " >${GLB_RADPATH}/client/${GLB_BASETRANSCRIPT}
  rm -f ${GLB_TEMPFILE}

  # Add the base transcript to the command file
  echo "p ${GLB_BASETRANSCRIPT}" >> ${GLB_RADPATH}/client/command.K

HEREDOC_SU4

  echo "Snapshot created in "$(($(date -u "+%s")-${GLB_START_EPOCH}))" seconds:"
  echo ${GLB_RADPATH}/client/${GLB_BASETRANSCRIPT}
  
  rm -f "/tmp/radcmdpath"
  

