#/bin/bash
set -e
set -x

DIR=`dirname "$0"`

for file in $(cat $DIR/file_list.txt); do
	echo $file
	cp -r ~/$file $DIR
done
