#!/bin/bash
# -*- coding: utf-8 -*-

# Author: Zachary W. Hopton
# Preprocess monolingual english data from TeDDi (https://github.com/MorphDiv/TeDDi_sample/tree/master/Corpus/English_eng/non-fiction/written)
# To use for back translation

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

DATA=./data/en-fr
mkdir -p $DATA/preprocessed_monolingual

# Get rid of header text and the column of line numbers
tail -n +18 $DATA/raw/eng_nfi_1.txt | sed 's/^[0-9]\{8\}[[:space:]]//g' > $DATA/preprocessed_monolingual/mono_full.en

#Select 10k lines (so we balance with the training data)
sort -R $DATA/preprocessed_monolingual/mono_full.en | head -n 10000 > $DATA/preprocessed_monolingual/mono_samp.en 

#Normalize punctuation with the english punct normalizer and do true casing (using the truecasing and punct norm models we already trained)
cat $DATA/preprocessed_monolingual/mono_samp.en | perl moses_scripts/normalize-punctuation.perl -l en | perl moses_scripts/truecase.perl --model $DATA/preprocessed_bpe300/tm.en> $DATA/preprocessed_monolingual/test.en.p

#BPE Tokenize with the model we already learned 
subword-nmt apply-bpe -c $DATA/preprocessed_bpe300/model.en < $DATA/preprocessed_monolingual/test.en.p > $DATA/preprocessed_monolingual/test.en


python preprocess.py --target-lang fr --source-lang en --dest-dir $DATA/prepared_monolingual --train-prefix $DATA/preprocessed_bpe300/train --valid-prefix $DATA/preprocessed_bpe300/valid --test-prefix $DATA/preprocessed_monolingual/test --tiny-train-prefix $DATA/preprocessed_bpe300/tiny_train --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000