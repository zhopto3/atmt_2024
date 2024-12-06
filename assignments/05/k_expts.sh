#!/bin/bash
# -*- coding: utf-8 -*-

#Author: Zachary W. Hopton

#Run experiments to test different beam sizes 

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

mkdir -p assignments/05/k_expts

#Use k=1, should be equivalent to greedy search

#Run inference with the best model from exercise 3: BPE_300 + Synthetic back translations + tags indicating synthetic data
python translate_beam.py \
    --data data/en-fr/prepared_augmented_tagged \
    --dicts data/en-fr/prepared_augmented_tagged \
    --checkpoint-path assignments/03/aug_tagged_fr-en/checkpoints/checkpoint_last.pt \
    --output assignments/05/k_expts/1_out.txt \
    --beam-size 1

#Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/05/k_expts/1_out.txt \
    assignments/05/k_expts/1_out.p.txt

#evaluate
cat \
    assignments/05/k_expts/1_out.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/05/k_expts/1_eval.json

#Start at k=5 and then go up to 25 by step size 5
for ((k=5; k<26; k=k+5))
do
    #Run inference with the best model from exercise 3: BPE_300 + Synthetic back translations + tags indicating synthetic data
    python translate_beam.py \
        --data data/en-fr/prepared_augmented_tagged \
        --dicts data/en-fr/prepared_augmented_tagged \
        --checkpoint-path assignments/03/aug_tagged_fr-en/checkpoints/checkpoint_last.pt \
        --output assignments/05/k_expts/${k}_out.txt \
        --beam-size $k
    
    #Run post processing
    bash assignments/03/postprocess_bpe300.sh \
        assignments/05/k_expts/${k}_out.txt \
        assignments/05/k_expts/${k}_out.p.txt

    #evaluate
    cat \
        assignments/05/k_expts/${k}_out.p.txt \
        | sacrebleu data/en-fr/raw/test.en > assignments/05/k_expts/${k}_eval.json


done
