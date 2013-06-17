#!/bin/sh
# Created by mmiyaji on 2013-06-18.
# Copyright (c) 2013  ruhenheim.org. All rights reserved.
PREFIX=/usr/bin
PYTHON_PATH="$(which python)"
TARGET=icat
usage () {
    echo
    echo "Usage: [sudo] `basename $0` [options]"
    echo
    echo "Options (see top of install.sh for complete list):"
    echo
    echo "--with-python=/full/path/to/python"
    echo "  Path to the Python that you wish to use with icat."
    echo
    exit 1
}

for option
do
    optarg=`expr "x$option" : 'x[^=]*=\(.*\)'`
    case $option in
        --with-python=* | -with-python=* | --withpython=* | -withpython=* )
            if [ "$optarg" ]; then
                PYTHON_PATH="$optarg"
            else
                continue
            fi
            ;;

        -prefix=* | --prefix=*)
            PREFIX=`expr "x$option" : "x-*prefix=\(.*\)"`
            ;;

        *)
            # case $option in
            # esac
            usage
        ;;
    esac
done


echo "checking system config.."
echo "python path.. " $PYTHON_PATH
echo

if [ "$PYTHON_PATH" ]
then
    ARGP=$($PYTHON_PATH -c "import argparse" 2>&1)
    if [ "$ARGP" ]
    then
        echo "Error..\t\"argparse\" python module does not found . Please use python 2.7 or later."
        exit 1
    else
        echo "OK.....\tfound \"argparse\" python module."
    fi
    ARGP=$($PYTHON_PATH -c "from PIL import Image" 2>&1)
    if [ "$ARGP" ]
    then
        echo "Error..\t\"Image\" python module does not found . Please install PIL or pillow python module."
        exit 1
    else
        echo "OK.....\tfound \"Image\" python module."
    fi
else
    echo "required python2.7 or later"
    exit 1
fi

cat $TARGET.tmp | awk 'NR>1 {print}' > tmp.txt
echo "#!$PYTHON_PATH" > $TARGET.tmp
cat tmp.txt >> $TARGET.tmp
rm tmp.txt
chmod 755 $TARGET.tmp
cp $TARGET.tmp $PREFIX/$TARGET
rm $TARGET.tmp
echo
echo "Installed $TARGET to $PREFIX/$TARGET"
