#!/bin/bash
# -*- coding: utf-8 -*-

# Author: Zachary W. Hopton
# Append backtranslated bible data to original training data, add <BT> tags, and binarize.
# To use for back translation

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

DATA=./data/en-fr
mkdir -p $DATA/preprocessed_augmented_tagged

#Concatenate natural and backtranslated train data; add <BT> tag to backtranslated source data
#src (fr)
sed 's/^/<BT> /' assignments/03/backtranslator/backtranslated.fr | cat - $DATA/preprocessed_bpe300/train.fr | sed -r 's/(@@ )|(@@ ?$)//g' > $DATA/preprocessed_augmented_tagged/train.p.fr

#tgt(en)
cat $DATA/preprocessed_monolingual/test.en $DATA/preprocessed_bpe300/train.en  > $DATA/preprocessed_augmented_tagged/train.en

#retokenize, but add <BT> to glossary to avoid segmentation 

subword-nmt apply-bpe -c $DATA/preprocessed_bpe300/model.fr --glossaries "<BT>" < $DATA/preprocessed_augmented_tagged/train.p.fr > $DATA/preprocessed_augmented_tagged/train.fr

#binarize the data set and use the same val and test data as the original bpe model 
python preprocess.py --target-lang en --source-lang fr --dest-dir $DATA/prepared_augmented_tagged --train-prefix $DATA/preprocessed_augmented_tagged/train --valid-prefix $DATA/preprocessed_bpe300/valid --test-prefix $DATA/preprocessed_bpe300/test --tiny-train-prefix $DATA/preprocessed_bpe300/tiny_train --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000