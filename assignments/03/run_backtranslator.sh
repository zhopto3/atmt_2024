#!/bin/bash
# -*- coding: utf-8 -*-

#Author: Zachary W. Hopton

#Use bpe (300 merges) tokenized data to train Fr->En translator
set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

# mkdir -p assignments/03/backtranslator

#train translator 
# python train.py \
#     --data data/en-fr/prepared_bpe300 \
#     --source-lang en \
#     --target-lang fr \
#     --save-dir assignments/03/backtranslator/checkpoints

#Run inference on the monolingual en data, using greedy translation
python translate_backtranslated.py \
    --data data/en-fr/prepared_monolingual \
    --dicts data/en-fr/prepared_monolingual \
    --checkpoint-path assignments/03/backtranslator/checkpoints/checkpoint_last.pt \
    --output assignments/03/backtranslator/backtranslated.fr

# #Run post processing
# bash assignments/03/postprocess_bpe300.sh \
#     assignments/03/bpe_300/bpe300_translations.txt \
#     assignments/03/bpe_300/bpe300_translations.p.txt

