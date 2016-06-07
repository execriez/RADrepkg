#!/bin/bash
#
# Break a nested command file down into its component transcript files
# Usage:
#   RADexplodeK.sh commandfile
#
# Mark J Swift
GLB_VERSTAG="1.0.6"

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

# change directory to where this script is running
cd "${GLB_MYPATH}"

# here we go...

GLB_RADPATH="${GLB_MYPATH}"

GLB_NPARAMS=$#
if [ ${GLB_NPARAMS} -eq 0 ]
then
  echo "${GLB_MYNAME} version ${GLB_VERSTAG}"
  echo "Usage: ${GLB_MYSCRIPT} somecommandfile.K"
  exit 0

else
  GLB_DOCFILE="${1}"

fi

if test -n $(echo ${GLB_DOCFILE} | grep ".*/radmind/client/.*\.T$")
then
  GLB_RADPATH=$(echo ${GLB_DOCFILE} | sed "s|/radmind/client/.*|/radmind|")
  GLB_RADTPATH=${GLB_RADPATH}/client
  GLB_RADKPATH=${GLB_RADPATH}/client
else
  if test -n $(echo ${GLB_DOCFILE} | grep ".*/transcript/.*\.T$")
  then
    GLB_RADPATH=$(echo ${GLB_DOCFILE} | sed "s|/transcript/.*||")
  else
    if test -n $(echo ${GLB_DOCFILE} | grep ".*/command/.*\.K$")
    then
      GLB_RADPATH=$(echo ${GLB_DOCFILE} | sed "s|/command/.*||")
    fi
  fi
  if test -n "${GLB_RADPATH}"
  then
    GLB_RADTPATH=${GLB_RADPATH}/transcript
    GLB_RADKPATH=${GLB_RADPATH}/command
  else
    echo "Error, cannot work out where the Radmind files are stored"
  fi
fi


# Filename extension
GLB_DOCEXT=$(basename "${GLB_DOCFILE}" | grep -Eo "\.[^.]*$" | tr -d ".")

# check if file exists
if ! ( test -r "${GLB_DOCFILE}" )
then
  echo "# MISSING ${GLB_DOCFILE}"

else
  case "${GLB_DOCEXT}" in
  T)
    echo "p $(basename "${GLB_DOCFILE}")"
    ;;

  *)
    # process Command file (Software catalog)
    GLB_XFLG=${GLB_FALSE}
    while read GLB_WHOLELINE
    do
      # extract command
      GLB_COMMAND=$(echo "${GLB_WHOLELINE}" | cut -d" " -f1)
      GLB_REMAINDER=$(echo "${GLB_WHOLELINE}" | cut -d" " -f2-)

      case ${GLB_COMMAND} in
      k)
        GLB_TKNAME=$(echo "${GLB_REMAINDER}" | cut -d" " -f1)
        GLB_REMAINDER=$(echo "${GLB_REMAINDER}" | cut -d" " -f2-)
        "${GLB_MYSOURCE}" "${GLB_RADKPATH}/${GLB_TKNAME}"
        ;;
      p)
        GLB_TKNAME=$(echo "${GLB_REMAINDER}" | cut -d" " -f1)
        GLB_REMAINDER=$(echo "${GLB_REMAINDER}" | cut -d" " -f2-)
        echo "p ${GLB_TKNAME}"
        ;;
      n)
        GLB_TKNAME=$(echo "${GLB_REMAINDER}" | cut -d" " -f1)
        GLB_REMAINDER=$(echo "${GLB_REMAINDER}" | cut -d" " -f2-)
        echo "n ${GLB_TKNAME}"
        ;;
      x)
        if [ ${GLB_XFLG} -eq ${GLB_FALSE} ]
        then
          echo "# The following command file contains excludes"
          echo "k $(echo ${GLB_DOCFILE} | sed "s|${GLB_RADKPATH}/||")"
          GLB_XFLG=${GLB_TRUE}
        fi
        ;;
      esac

    done < "${GLB_DOCFILE}"
    ;;

  esac

fi

