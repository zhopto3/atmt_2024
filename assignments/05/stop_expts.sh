#!/bin/bash
# -*- coding: utf-8 -*-

#Author: Zachary W. Hopton

#Run experiments to test different beam sizes 

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

mkdir -p assignments/05/stop_expts

#Do all experiments with k=3

##DEFAULT stop criterion with K=3##

# Run inference with the best model from exercise 3: BPE_300 + Synthetic back translations + tags indicating synthetic data
{ time python translate_beam.py \
    --data data/en-fr/prepared_augmented_tagged \
    --dicts data/en-fr/prepared_augmented_tagged \
    --checkpoint-path assignments/03/aug_tagged_fr-en/checkpoints/checkpoint_last.pt \
    --output assignments/05/stop_expts/3_out_default.txt \
    --beam-size 3; } 2> assignments/05/stop_expts/3_default.log

#Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/05/stop_expts/3_out_default.txt \
    assignments/05/stop_expts/3_out_default.p.txt

#evaluate
cat \
    assignments/05/stop_expts/3_out_default.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/05/stop_expts/3_default_eval.json

# ##CONSTANT stop criterion with K=3##
{ time python translate_beam.py \
    --data data/en-fr/prepared_augmented_tagged \
    --dicts data/en-fr/prepared_augmented_tagged \
    --checkpoint-path assignments/03/aug_tagged_fr-en/checkpoints/checkpoint_last.pt \
    --output assignments/05/stop_expts/3_out_constant.txt \
    --beam-size 3 \
    --stop_criterion constant; } 2> assignments/05/stop_expts/3_constant.log

#Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/05/stop_expts/3_out_constant.txt \
    assignments/05/stop_expts/3_out_constant.p.txt

#evaluate
cat \
    assignments/05/stop_expts/3_out_constant.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/05/stop_expts/3_constant_eval.json

##PRUNING stop criterion with K=3##

{ time python translate_beam.py \
    --data data/en-fr/prepared_augmented_tagged \
    --dicts data/en-fr/prepared_augmented_tagged \
    --checkpoint-path assignments/03/aug_tagged_fr-en/checkpoints/checkpoint_last.pt \
    --output assignments/05/stop_expts/3_out_pruning.txt \
    --beam-size 3 \
    --stop_criterion pruning; } 2> assignments/05/stop_expts/3_pruning.log

#Run post processing
bash assignments/03/postprocess_bpe300.sh \
    assignments/05/stop_expts/3_out_pruning.txt \
    assignments/05/stop_expts/3_out_pruning.p.txt

#evaluate
cat \
    assignments/05/stop_expts/3_out_pruning.p.txt \
    | sacrebleu data/en-fr/raw/test.en > assignments/05/stop_expts/3_pruning_eval.json