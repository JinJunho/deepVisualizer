#!/bin/bash
# Usage parse_log.sh caffe.log
# It creates the following two text files, each containing a table:
#     caffe.log.test (columns: '#Iters Seconds TestAccuracy TestLoss')
#     caffe.log.train (columns: '#Iters Seconds TrainingLoss LearningRate')


# get the dirname of the script
DIR="$( cd "$(dirname "$0")" ; pwd -P )"

if [ "$#" -lt 1 ]
then
echo "Usage parse_log.sh /path/to/your.log"
exit
fi
LDIR=`dirname $1`
LOG=`basename $1`
sed -n '/Iteration .* Testing net/,/Iteration *. loss/p' $1 > $LDIR/aux.txt
sed -i '/Waiting for data/d' $LDIR/aux.txt
sed -i '/prefetch queue empty/d' $LDIR/aux.txt
sed -i '/Iteration .* loss/d' $LDIR/aux.txt
sed -i '/Iteration .* lr/d' $LDIR/aux.txt
sed -i '/Train net/d' $LDIR/aux.txt
grep 'Iteration ' $LDIR/aux.txt | sed  's/.*Iteration \([[:digit:]]*\).*/\1/g' > $LDIR/aux0.txt
grep 'Test net output #0' $LDIR/aux.txt | awk '{print $11}' > $LDIR/aux1.txt
grep 'Test net output #1' $LDIR/aux.txt | awk '{print $11}' > $LDIR/aux2.txt

# Extracting elapsed seconds
# For extraction of time since this line contains the start time
grep '] Solving ' $1 > $LDIR/aux3.txt
grep 'Testing net' $1 >> $LDIR/aux3.txt
$DIR/extract_seconds.py $LDIR/aux3.txt $LDIR/aux4.txt

# Generating
echo '#Iters Seconds TestAccuracy TestLoss'> $LDIR/$LOG.test
paste $LDIR/aux0.txt $LDIR/aux4.txt $LDIR/aux1.txt $LDIR/aux2.txt | column -t >> $LDIR/$LOG.test
rm $LDIR/aux.txt $LDIR/aux0.txt $LDIR/aux1.txt $LDIR/aux2.txt $LDIR/aux3.txt $LDIR/aux4.txt

# For extraction of time since this line contains the start time
grep '] Solving ' $1 > $LDIR/aux.txt
grep ', loss = ' $1 >> $LDIR/aux.txt
grep 'Iteration ' $LDIR/aux.txt | sed  's/.*Iteration \([[:digit:]]*\).*/\1/g' > $LDIR/aux0.txt
grep ', loss = ' $1 | awk '{print $9}' > $LDIR/aux1.txt
grep ', lr = ' $1 | awk '{print $9}' > $LDIR/aux2.txt

# Extracting elapsed seconds
$DIR/extract_seconds.py $LDIR/aux.txt $LDIR/aux3.txt

# Generating
echo '#Iters Seconds TrainingLoss LearningRate'> $LDIR/$LOG.train
paste $LDIR/aux0.txt $LDIR/aux3.txt $LDIR/aux1.txt $LDIR/aux2.txt | column -t >> $LDIR/$LOG.train
rm $LDIR/aux.txt $LDIR/aux0.txt $LDIR/aux1.txt $LDIR/aux2.txt $LDIR/aux3.txt
