#!/bin/bash
# -*- coding: utf-8 -*-

#Author: Zachary W. Hopton

#Use bpe (300 merges) tokenized data to train Fr->En translator
set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

mkdir -p assignments/03/bpe_300

#train translator 
python train.py \
    --data data/en-fr/prepared_bpe300 \
    --source-lang fr \
    --target-lang en \
    --save-dir assignments/03/bpe_300/checkpoints

#Run inference on the test set
python translate.py \
    --data data/en-fr/prepared_bpe300 \
    --dicts data/en-fr/prepared_bpe300 \
    --checkpoint-path assignments/03/bpe_300/checkpoints/checkpoint_last.pt \
    --output assignments/03/bpe_300/bpe300_translations.txt

Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/03/bpe_300/bpe300_translations.txt \
    assignments/03/bpe_300/bpe300_translations.p.txt

#evaluate
cat \
    assignments/03/bpe_300/bpe300_translations.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/03/bpe_300/bpe300_eval.json

