#!/bin/bash
# -*- coding: utf-8 -*-

# Author: Zachary W. Hopton
# Append backtranslated bible data to original training data and binarize.
# To use for back translation

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

DATA=./data/en-fr
mkdir -p $DATA/preprocessed_augmented_fr-en

#Concatenate natural and backtranslated train data
#src (fr)
cat $DATA/preprocessed_bpe300/train.fr assignments/03/backtranslator/backtranslated.fr > $DATA/preprocessed_augmented_fr-en/train.fr

#tgt(en)
cat $DATA/preprocessed_bpe300/train.en $DATA/preprocessed_monolingual/test.en > $DATA/preprocessed_augmented_fr-en/train.en

#binarize the data set and use the same val and test data as the original bpe model 
python preprocess.py --target-lang en --source-lang fr --dest-dir $DATA/prepared_augmented_fr-en --train-prefix $DATA/preprocessed_augmented_fr-en/train --valid-prefix $DATA/preprocessed_bpe300/valid --test-prefix $DATA/preprocessed_bpe300/test --tiny-train-prefix $DATA/preprocessed_bpe300/tiny_train --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000