#!/bin/bash


for dir in $(ls -d */)
do 
cd $dir
echo $dir
echo "== ris =="
grep '\[1s\|1s\]' escf-ris.out
echo "=== ris-x =="
grep '\[1s\|1s\]' escf-ris-x.out
diff exspectrum-initial exspectrum-final
# cat exspectrum
echo "=================================================================="
cd ..
done