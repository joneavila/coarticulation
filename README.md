# Comparison of coarticulation of children with and without autism spectrum disorder

## Motivation

Find a prosodic marker of autism spectrum disorder (ASD) that may be used to improve the accuracy and/or timeliness of diagnosis and/or assessment, and/or offer more flexible experimental setups.

## Hypothesis

A lack of intrapersonal synchrony may contribute to the difficulties with verbal
communication that people with ASD experience. [bloch2019](#references) defines
*intrapersonal synchrony* as "the temporal coordination of communication signals
in a socially informative manner". Specifically, people with ASD may have weaker
*coarticulation* compared to their neurotypical (NT) counterparts. [jurafsky2021](#references) defines *coarticulation* as "the movement of
articulators to anticipate the next sound or preserving movement from the last
sound".

## Related work

[gerosa2006](#references) employed two acoustic measures of coarticulation to
study the differences between adult and child speech.
[cychosz2019](#references) validated these measures. These measures require
annotating phonemes.

## Coarticulation measure

To avoid time-consuming annotation, *cepstral flux* can be used as an approximate measure for coarticulation. [ward2021](#references) previously noted that cepstral flux is high when the speaking rate is high and during very creaky regions, is low during silence, and is moderately low during lengthening. If the hypothesis is correct, then this measure should be higher in word boundaries for the ASD group compared to the NT group (more sudden mouth movement for the ASD group).

The algorithm, implemented in `cepstralFluxModified.m`, works as follows: (1) compute the first 13 *mel-frequency cepstral coefficients (MFCCs)* for each window from the input speech signal, (2) compute the sum of the squared differences for each coefficient between consecutive windows, and (3) output the resulting vector of length `N_WINDOWS-1`.

## Data

The [corpus] contains 28 dialogs: 14 ASD dialogs and 14 NT dialogs,
matched for age. Each dialog features an adult researcher and a child from the
ASD or NT group completing a "spot the difference" task. I do not have
permission to share any part of this data.

## Experiment 1: Coarticulation across word boundaries

To attempt to get the word boundaries automatically, I wrote code to isolate the child's speech, transcribe the audio, and align the transcription with the audio. The transcriptions were not accurate, mostly likely due to the pre-trained model not having seen child ASD speech.

Next, I annotated word boundaries manually for two dialogs (`ASD005` and `CNT004`) following loose guidelines: annotate the middle of the first 20 word boundaries that appear in utterances with more than one word, with a maximum of 3 word boundaries per utterance, avoiding unclear word boundaries. I assumed that all word boundaries were 100ms in duration.

A 100ms word boundary translates to 10 10ms windows and in turn 9 differences in
windows to measure for each word boundary. The coarticulation measure was close to zero for all word
boundaries, most
likely due to my decision of avoiding unclear word boundaries and assuming the
same duration for all
word boundaries. With enough
silence between words the coarticulation measure is expected to be near zero.

![plot_boundaries](/images/plot_boundaries.jpg)

I did not adjust the annotations and decided to move on to the next experiment.

## Experiment 2: Coarticulation across all utterances (groups)

I extracted all child utterances for both ASD and NT groups. For each group, I
computed the coarticulation measure of all utterances, then plotted the measures
in a histogram, normalizing bin counts.

![histogram_dialog](/images/histogram_dialog.png)

Bin counts are mostly overlapping, however there are some differences. The NT group tends to have more average coarticulation (red bars in middle), while the ASD group tends to have less coarticulation (blue bars on left). These differences are not significant enough to differentiate the groups with the measure alone. To confirm, I tested a linear regression model. I labeled NT frames as class 0 and ASD frames as class 1. Most if not all predictions were approximately 0.5. Testing different thresholds to assign each prediction to a class, the best MSE was 0.25 which is no better than random.

## Experiment 3: Coarticulation across all utterances, (pairs)

I followed the same steps as Experiment 2, but now for each age-matched pair of ASD child and NT child.

For each histogram there is less overlap when compared to the histogram with all
speakers, but there is no consistent pattern among pairs. The two histograms
below show how bin counts can vary drastically among pairs. Histograms for all
pairs are
in [./histograms/pairs](./histograms/pairs/)

![histogram_pair1](/images/histogram_pair1.png)
![histogram_pair2](/images/histogram_pair2.jpg)

This finding
supports the poor performance of the linear regression model from Experiment 2.

## Experiment 4: MFCCs across all utterances (groups)

I did not use the coarticulation measure for this experiment and instead looked
at the differences in MFCCs between windows directly. I plotted a histogram for
each of the 13 coefficients, using all utterances and comparing both groups.

![histogram_coeff1](/images/histogram_coeff1.jpg)
![histogram_coeff1](/images/histogram_coeff1.jpg)

There is no noticeable pattern in these histograms. For most coefficients it seems that the ASD group tends to have more bin counts near zero. Like Experiment 2, these differences are not significant enough to differentiate the groups with the measure alone. Below are the histograms for the first two coefficients. Histograms for all coefficients are in [./histograms/grouped_MFCCs/](./histograms/grouped_MFCCs/).

## Conclusions

The measures used in my experiments cannot because used to differentiate the ASD and NT groups, at least not for the [corpus]. I do not plan on conducting more experiments focusing on coarticulation but leave these notes for researchers working in this area.

## Source code

- `build_isolated_audio.py` isolates the child or researcher's speech for a dialog by reading annotation intervals from its associated TextGrid file.
- `transcribe_audio.py` Transcribes an audio using Mozilla's DeepSpeech.
- `force_align.py` Aligns transcription and audio using DSAlign.

## References

- (bloch2019) Carola Bloch, Kai Vogeley, Alexandra L. Georgescu, and Christine M. Falter-Wagner. 2019. INTRApersonal Synchrony as Constituent of INTERpersonal Synchrony and Its Relevance for Autism Spectrum Disorder. Front. Robot. AI 6, (2019). DOI:<https://doi.org/10.3389/frobt.2019.00073>
- (cychosz2019) Margaret Cychosz, Jan R. Edwards, Benjamin Munson, and Keith Johnson. 2019. Spectral and temporal measures of coarticulation in child speech. The Journal of the Acoustical Society of America 146, 6 (December 2019), EL516–EL522. DOI:<https://doi.org/10.1121/1.5139201>
- (gerosa2006) M. Gerosa, S. Lee, D. Giuliani, and S. Narayanan. 2006. Analyzing Children’s Speech: An Acoustic Study of Consonants and Consonant-Vowel Transition. In 2006 IEEE International Conference on Acoustics Speech and Signal Processing Proceedings, I–I. DOI:<https://doi.org/10.1109/ICASSP.2006.1660040>
- (jurafsky2021) Dan Jurafsky and James H. Martin. 2021. Speech and Language Processing (Third Edition draft ed.). Retrieved October 29, 2021 from <https://web.stanford.edu/~jurafsky/slp3/>
- (ward2021) Nigel Ward. 2021. Midlevel Prosodic Features Toolkit. Retrieved October 29, 2021 from <https://github.com/nigelgward/midlevel>
