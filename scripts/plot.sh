LDIR=`dirname $1`
LBASE=`basename $1`
for i in 0 1 2 3 4 5 6 7 
do
  python /data/git/deepVisualizer/scripts/progress_plot.py $i $LDIR/$i.png $1 
done

