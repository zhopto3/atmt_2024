infile=$1
outfile=$2

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

#De-truecase and remove BPE segmentation in the output
cat $infile | perl moses_scripts/detruecase.perl | sed -r 's/(@@ )|(@@ ?$)//g' > $outfile
