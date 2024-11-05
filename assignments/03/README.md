# Assignment 3: Improving Low-Resource NMT

In this assignment we use fr-en data from the Tatoeba
corpus and investigate methods for improving low-resource NMT.

Your task is to experiment with techniques for improving
low-resource NMT systems.

## Baseline

The data used to train the baseline model was prepared using
the script `preprocess_data.sh`.
This may be useful if you choose to apply subword
segmentation or a data augmentation method.

Zachary W. Hopton:

## BPE_300

- `./preprocess_bpe.sh` : Adapted the `preprocess_data.sh` to train and apply BPE tokenizer that do 300 merges to the train, val and test corpora instead of word level tokenization. Still carries out truecasing and punctuation normalization as before, then puts data in `../../data/en-fr/preprocessed_bpe300`. The same shell script then binarizes the data with the provided python script and puts the final data in `../../data/en-fr/preprared_bpe300`.

- `./run_bpe300.sh` :  Launches the model training using the data from `../../data/en-fr/preprared_bpe300`. After training, runs inference on the test set, applies post-processing (see next script) and evaluates.

- `./postprocess_bpe300.sh` : This is the same as the provided postprocessing script, but we change the detokenization to account for BPE tokenized output rather than the Moses detokenizer. 

- Model checkpoints, infernece output and evaluation are all saved in the directory `./bpe_300`.

## AUG and AUG_TAG

We began by finding the monolingual English data (`../../data/en-fr/raw/eng_nfi_1.txt`) from the TeDDi corpus (Moran et al., 2022; https://github.com/MorphDiv/TeDDi_sample). We then preprocessed the data and trained an En->Fr back-translation model:

- `./monolingual_en_prep.sh`: Removes meta data from monolingual English data, shuffles sample, and randomly sample 10k lines. Applies truecasing, punctuation normalization, and the same English BPE_300 model we trained above; the preprocessed data is added to `../../data/en-fr/preprocessed_monolingual`. The shell script then binarizes the data and adds it to `../../data/en-fr/preprared_monolingual`. 

- `./run_backtranslator.sh`: This script trains the En->Fr back-translation model then runs inference on the monolingual Bible data from Teddi that was prepared by `./monollingual_en_prep.sh`.

-  Model checkpoints, infernece output and evaluation are all saved in the directory `./backtranslator`. The final 10k lines of back-translated data are in `./backtranslator/backtranslated.fr`.

Once we have the back-translated en-fr data, we prepare the data and train the AUG condition:

- `./preprocess_aug_fr-en.sh`: Here we concatenate the 10k lines of synthetic source and target data to the 10k lines of natural source and target training data, and add the data to `../../data/en-fr/preprocessed_augmented_fr-en`. We then use the same bpe tokenized validation and test set as above, and binarize the whole data set, adding it to `../../data/en-fr/prepared_augmented_fr-en`

- `./run_aug_fr-en.sh`: Here we launch the training of the Fr->En MT model using the synthetically augmented trainin data, then run inference, post-processing and evaluation. 

- Model checkpoints, infernece output and evaluation are all saved in the directory `./aug_fr-en`.

Finally, we prepare the data for the AUG_TAG condition and train another fr->en MT model:

- `./preprocess_aug_tagged.sh`: Here we add the tag '&lt;BT&gt;'  to the source-side (French) synthetic data, then concatenate it to the natural data and preprocess as before, putting the preprocessed data in the directory `../../data/en-fr/preprocessed_augmented_tagged`. We add the tag to the BPE glossary so that it is not segmented. After binarizing the data, we put the final data in the directory `../../data/en-fr/prepared_augmented_tagged`.

- `./run_aug_tagged.sh`: This script trains an Fr->En model using the synthetically augmented training data with tags. It then runs inference on the test set, post-processes the output and evaluates. 

- Model checkpoints, infernece output and evaluation are all saved in the directory `./aug_tagged_fr-en`.


### References

Steven Moran, Christian Bentz, Ximena Gutierrez-Vasques, Olga Pelloni, and Tanja Samardzic. 2022. TeDDi Sample: Text Data Diversity Sample for Language Comparison and Multilingual NLP. In Proceedings of the Thirteenth Language Resources and Evaluation Conference, pages 1150–1158, Marseille, France. European Language Resources Association. Online: https://aclanthology.org/2022.lrec-1.123/