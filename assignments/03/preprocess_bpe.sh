#!/bin/bash
# -*- coding: utf-8 -*-

# Author: Zachary W. Hopton
# Use small, monolingual BPE vocabularies instead of word vocab to tokenize. 

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..
src=fr
tgt=en
data=$base/data/$tgt-$src/

# change into base directory to ensure paths are valid
cd $base

# create preprocessed directory
mkdir -p $data/preprocessed_bpe300/
mkdir -p $data/prepared_bpe300/

# normalize raw data
cat $data/raw/train.$src | perl moses_scripts/normalize-punctuation.perl -l $src  > $data/preprocessed_bpe300/train.$src.p
cat $data/raw/train.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt  > $data/preprocessed_bpe300/train.$tgt.p

# train truecase models
perl moses_scripts/train-truecaser.perl --model $data/preprocessed_bpe300/tm.$src --corpus $data/preprocessed_bpe300/train.$src.p
perl moses_scripts/train-truecaser.perl --model $data/preprocessed_bpe300/tm.$tgt --corpus $data/preprocessed_bpe300/train.$tgt.p

# apply truecase models to splits
cat $data/preprocessed_bpe300/train.$src.p | perl moses_scripts/truecase.perl --model $data/preprocessed_bpe300/tm.$src > $data/preprocessed_bpe300/truecased_train.$src 
cat $data/preprocessed_bpe300/train.$tgt.p | perl moses_scripts/truecase.perl --model $data/preprocessed_bpe300/tm.$tgt > $data/preprocessed_bpe300/truecased_train.$tgt

#Train BPE tokenizers
subword-nmt learn-bpe -s 300 < $data/preprocessed_bpe300/truecased_train.$src  > $data/preprocessed_bpe300/model.$src
subword-nmt learn-bpe -s 300 < $data/preprocessed_bpe300/truecased_train.$tgt  > $data/preprocessed_bpe300/model.$tgt

#Apply BPE tokenizers
subword-nmt apply-bpe -c $data/preprocessed_bpe300/model.$src < $data/preprocessed_bpe300/truecased_train.$src > $data/preprocessed_bpe300/train.$src
subword-nmt apply-bpe -c $data/preprocessed_bpe300/model.$tgt< $data/preprocessed_bpe300/truecased_train.$tgt > $data/preprocessed_bpe300/train.$tgt 

# prepare remaining splits with learned models
for split in valid test tiny_train
do
    cat $data/raw/$split.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/truecase.perl --model $data/preprocessed_bpe300/tm.$src | subword-nmt apply-bpe -c $data/preprocessed_bpe300/model.$src > $data/preprocessed_bpe300/$split.$src
    cat $data/raw/$split.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/truecase.perl --model $data/preprocessed_bpe300/tm.$tgt | subword-nmt apply-bpe -c $data/preprocessed_bpe300/model.$tgt > $data/preprocessed_bpe300/$split.$tgt
done

# remove tmp files
rm $data/preprocessed_bpe300/train.$src.p
rm $data/preprocessed_bpe300/train.$tgt.p

rm $data/preprocessed_bpe300/truecased_train.$src
rm $data/preprocessed_bpe300/truecased_train.$tgt

# preprocess all files for model training
python preprocess.py --target-lang $tgt --source-lang $src --dest-dir $data/prepared_bpe300/ --train-prefix $data/preprocessed_bpe300/train --valid-prefix $data/preprocessed_bpe300/valid --test-prefix $data/preprocessed_bpe300/test --tiny-train-prefix $data/preprocessed_bpe300/tiny_train --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000

echo "done!"