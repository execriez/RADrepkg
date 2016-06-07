#!/bin/bash
#
# Compare current filesystem to the initial snapshot and create a diff transcript
#
#
#
# Mark J Swift
GLB_VERSTAG="1.0.7"

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

    # check if snapshot file exists
    if ! ( test -r "${GLB_RADPATH}/client/command.K" )
    then
      echo "Snapshot file not found - please run RADsnapshot.command first."
      exit 0
    fi

    echo "Checking for differences compared to the snapshot file. "

    GLB_START_EPOCH=$(date -u "+%s")

    # -- Create a new localised negative transcript --

    # Execute everything within HEREDOC_SU2 with escalated privs.
    # It's quoted. You can create new vars, but vars from outside are not available.  
    sudo su root <<'HEREDOC_SU2'

    # start afresh
    rm -f ${LCL_RADPATH}/client/neg-Workstation-LocalFS-1v0v0-10v0-i386.T

    # path to Radmind support files
    LCL_RADPATH="/private/var/radmind"

    LCL_RADCMDPATH="/tmp/radcmdpath"

    LCL_TEMPFILE=$(mktemp /tmp/RADdiff.XXXXXX)

    mount | sed -E 's/^.* on //;s/ \([^(]*\)$//' | grep -v '^/$' | while read LCL_MOUNTPOINT
    do
      if test -z "$(${LCL_RADCMDPATH}/twhich -Ir "${LCL_MOUNTPOINT}" | grep -E "^# Negative$")"
      then
        "${LCL_RADCMDPATH}"/fsdiff -1 -I -csha1 "${LCL_MOUNTPOINT}" >> ${LCL_TEMPFILE}
      fi

    done

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

HEREDOC_SU2

    GLB_TEMPFILE=$(mktemp /tmp/tempfile.XXXXXX)

    # Execute everything within HEREDOC_SU3 with escalated privs.
    # It's not quoted. You can't create new vars, but vars from outside are available.  
sudo su root <<HEREDOC_SU3

    if test -e ${GLB_RADPATH}/client/neg-Workstation-LocalFS-1v0v0-10v0-i386.T
    then
      # Add the local negative transcript to the command file
      echo "n neg-Workstation-LocalFS-1v0v0-10v0-i386.T" > ${GLB_TEMPFILE}
      cat ${GLB_RADPATH}/client/command.K | grep -v "neg-Workstation-LocalFS-" >> ${GLB_TEMPFILE}
      cp ${GLB_TEMPFILE} ${GLB_RADPATH}/client/command.K
      rm -f ${GLB_TEMPFILE}
    fi

    # If you want to enable fsdiff checksums, add the option -csha1
    #"${GLB_RADCMDPATH}"/fsdiff -I -C -o"${GLB_MYPATH}"/snapshotdiff.T -% /

    # Create the diff file
    "${GLB_RADCMDPATH}"/fsdiff -I -C -o${GLB_TEMPFILE} -% /
    
    # I'm not interested in negative changes
    cat ${GLB_TEMPFILE} | grep -Ev "^- " >"${GLB_MYPATH}"/snapshotdiff.T
    rm -f ${GLB_TEMPFILE}
    
    # If the SIP fixer script is available, use it
    if test -e "${GLB_MYPATH}"/bin/RadmindTfix4SIP.sh
    then
      "${GLB_MYPATH}"/bin/RadmindTfix4SIP.sh "${GLB_MYPATH}"/snapshotdiff.T 
    fi

    chown ${GLB_USERNAME} "${GLB_MYPATH}"/snapshotdiff.T
HEREDOC_SU3

    echo "Diff created in "$(($(date -u "+%s")-${GLB_START_EPOCH}))" seconds:"
    echo "${GLB_MYPATH}"/snapshotdiff.T
    
    rm -f /tmp/radcmdpath
    

