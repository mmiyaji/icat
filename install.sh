#!/bin/sh
# Created by mmiyaji on 2013-06-18.
# Copyright (c) 2013  ruhenheim.org. All rights reserved.
PREFIX=/usr
BINARY_DIR=bin
PYTHON_PATH="$(which python)"
TARGET=icat
INSTALL_MODE=1
usage () {
    echo
    echo "Usage: [sudo] `basename $0` [options]"
    echo
    echo "Options (see top of install.sh for complete list):"
    echo
    echo "-h | --help"
    echo "  Display this message."
    echo
    echo "--with-python=/full/path/to/python"
    echo "  Path to the Python that you wish to use with icat."
    echo "  default:  /usr/bin/python "
    echo
    echo "--prefix=/full/path/to/install"
    echo "  Path to the install directoey that you wish to use with icat."
    echo "  default:  /usr "
    echo
    echo "test"
    echo "  module check mode. \"icat\" does not install in this time."
    echo
    exit 1
}

for option
do
    optarg=`expr "x$option" : 'x[^=]*=\(.*\)'`
    case $option in
        -h | --help)
            usage
            exit 0
            ;;

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
            case $option in
                test)
                    echo "running test mode."
                    INSTALL_MODE=0
                    ;;
                *)
                    usage
                    ;;
            esac
        ;;
    esac
done


echo "checking system config.."
echo "python path..\t" $PYTHON_PATH
echo "prefix.......\t" $PREFIX
echo "install to...\t" $PREFIX/$BINARY_DIR
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

if [ $INSTALL_MODE == 1 ]
then
    cat $TARGET | awk 'NR>1 {print}' > tmp.txt
    echo "#!$PYTHON_PATH" > $TARGET.tmp
    cat tmp.txt >> $TARGET.tmp
    rm tmp.txt
    chmod 755 $TARGET.tmp
    mv $TARGET.tmp $PREFIX/$BINARY_DIR/$TARGET
    echo
    echo "Installed $TARGET to $PREFIX/$BINARY_DIR/$TARGET"
else
    echo "test finished."
fi
