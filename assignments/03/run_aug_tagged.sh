#!/bin/bash
# -*- coding: utf-8 -*-

#Author: Zachary W. Hopton

#Use bpe (300 merges) tokenized data to train Fr->En translator. Now includes the augmented train data (backtranslated english bible in train data)
#In this run, augmented train data has <BT> tag on the input
set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

mkdir -p assignments/03/aug_tagged_fr-en

#train translator 
python train.py \
    --data data/en-fr/prepared_augmented_tagged \
    --source-lang fr \
    --target-lang en \
    --save-dir assignments/03/aug_tagged_fr-en/checkpoints

# #Run inference on the test set
python translate.py \
    --data data/en-fr/prepared_augmented_tagged \
    --dicts data/en-fr/prepared_augmented_tagged \
    --checkpoint-path assignments/03/aug_tagged_fr-en/checkpoints/checkpoint_last.pt \
    --output assignments/03/aug_tagged_fr-en/aug_tagged_translations.txt

#Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/03/aug_tagged_fr-en/aug_tagged_translations.txt \
    assignments/03/aug_tagged_fr-en/aug_tagged_translations.p.txt

#evaluate
cat \
    assignments/03/aug_tagged_fr-en/aug_tagged_translations.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/03/aug_tagged_fr-en/aug_tagged_eval.json