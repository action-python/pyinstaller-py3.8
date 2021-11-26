#!/bin/bash -i

# Fail on errors.
set -e

# Make sure .bashrc is sourced
. /root/.bashrc

# Allow the workdir to be set using an env var.
# Useful for CI pipiles which use docker for their build steps
# and don't allow that much flexibility to mount volumes

# Run autorun.sh file
if [ -f $7 ]; then
    bash $7
fi # [ -f $7 ]

SRCDIR=$1

PYPI_URL=$2

PYPI_INDEX_URL=$3

WORKDIR=${SRCDIR:-.}

SPEC_FILE=${4:-*.spec}

TYPE=amd64

FILE_DIR=dist/linux/$TYPE

python -m pip install --upgrade pip wheel setuptools

#
# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.
#
if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    mkdir -p /root/.pip
    echo "[global]" > /root/.pip/pip.conf
    echo "index = $PYPI_URL" >> /root/.pip/pip.conf
    echo "index-url = $PYPI_INDEX_URL" >> /root/.pip/pip.conf
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /root/.pip/pip.conf

    echo "Using custom pip.conf: "
    cat /root/.pip/pip.conf
fi

cd $WORKDIR

if [ -f $5 ]; then
    pip install -r $5
fi # [ -f $5 ]

pyinstaller --clean -y --dist $FILE_DIR --workpath /tmp $SPEC_FILE

chown -R --reference=. $FILE_DIR

FILES_COUNT=`ls $FILE_DIR | wc -l`

if [ $FILES_COUNT = 1 ]
then
    DEF_FILE_NAME=`ls $FILE_DIR`
fi

RENAME=${6:-$DEF_FILE_NAME}

if [ $DEF_FILE_NAME != $RENAME ]
then
    mv $FILE_DIR/$DEF_FILE_NAME $FILE_DIR/$RENAME
fi

echo "$RENAME"
echo "$WORKDIR/$FILE_DIR/$RENAME"

if [ $FILES_COUNT = 1 ]
then
    echo "::set-output name=location::$WORKDIR/$FILE_DIR/$RENAME"
    echo "::set-output name=filename::$RENAME"
    echo "::set-output name=content_type::$(file --mime-type $FILE_DIR/$RENAME | awk '//{ print $2 }')"
else
    echo "::set-output name=location::$WORKDIR/$FILE_DIR"
    echo "::set-output name=filename::NULL"
    echo "::set-output name=content_type::NULL"
fi
