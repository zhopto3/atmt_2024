#!/bin/bash
# -*- coding: utf-8 -*-

#Author: Zachary W. Hopton

#Use bpe (300 merges) tokenized data to train Fr->En translator. Now includes the augmented train data (backtranslated english bible in train data)
set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

mkdir -p assignments/03/aug_fr-en

#train translator 
python train.py \
    --data data/en-fr/prepared_augmented_fr-en \
    --source-lang fr \
    --target-lang en \
    --save-dir assignments/03/aug_fr-en/checkpoints

# #Run inference on the test set
python translate.py \
    --data data/en-fr/prepared_augmented_fr-en \
    --dicts data/en-fr/prepared_augmented_fr-en \
    --checkpoint-path assignments/03/aug_fr-en/checkpoints/checkpoint_last.pt \
    --output assignments/03/aug_fr-en/aug_fr-en_translations.txt

#Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/03/aug_fr-en/aug_fr-en_translations.txt \
    assignments/03/aug_fr-en/aug_fr-en_translations.p.txt

#evaluate
cat \
    assignments/03/aug_fr-en/aug_fr-en_translations.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/03/aug_fr-en/aug_eval.json