from pathlib import Path
import subprocess
import shlex
import wave
from pipes import quote
import json

from deepspeech import Model
import numpy as np


def convert_samplerate(audio_path, desired_sample_rate):
    sox_cmd = "sox {} --type raw --bits 16 --channels 1 --rate {} --encoding" \
        " signed-integer --endian little --compression 0.0 --no-dither - " \
        .format(quote(audio_path), desired_sample_rate)

    # Split the SoX command using shell-like syntax
    sox_cmd_split = shlex.split(sox_cmd)

    # Run the SoX command, capturing standard error in the result
    # Catch exceptions raised by a non-zero exit status
    try:
        output = subprocess.check_output(sox_cmd_split, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        raise RuntimeError('SoX returned non-zero status: {}'.format(e.stderr))

    return np.frombuffer(output, np.int16)

def words_from_candidate_transcript(metadata):
    word = ""
    word_list = []
    word_start_time = 0
    # Loop through each character
    for i, token in enumerate(metadata.tokens):
        # Append character to word if it's not a space
        if token.text != " ":
            if len(word) == 0:
                # Log the start time of the new word
                word_start_time = token.start_time

            word = word + token.text
        # Word boundary is either a space or the last character in the array
        if token.text == " " or i == len(metadata.tokens) - 1:
            word_duration = token.start_time - word_start_time

            if word_duration < 0:
                word_duration = 0

            each_word = dict()
            each_word["word"] = word
            each_word["start_time"] = round(word_start_time, 4)
            each_word["duration"] = round(word_duration, 4)

            word_list.append(each_word)
            # Reset
            word = ""
            word_start_time = 0

    return word_list

def metadata_json_output(metadata):
    json_result = dict()
    json_result["transcripts"] = [{
        "confidence": transcript.confidence,
        "words": words_from_candidate_transcript(transcript),
    } for transcript in metadata.transcripts]
    return json.dumps(json_result, indent=2)

def speech_to_text(ds_model, audio_path):

    wave_read_obj = wave.open(audio_path, "rb")
    audio_sample_rate = wave_read_obj.getframerate()

    model_sample_rate = ds_model.sampleRate()

    # Resample audio if its sample rate is different than the sample rate
    # expected by the model
    # From DeepSpeech client.py, "Resampling might produce erratic speech
    # recognition"
    if audio_sample_rate != model_sample_rate:
        audio = convert_samplerate(audio_path, model_sample_rate)
    else:
        audio = np.frombuffer(wave_read_obj.readframes(
            wave_read_obj.getnframes()), np.int16)

    metadata = ds_model.sttWithMetadata(audio, 1)
    metadata_json = metadata_json_output(metadata)

    transcription = ds_model.stt(audio)

    return metadata_json, transcription


def transcribe_audio(dir_data, path_audio):

    PATH_MODEL = "deepspeech-models/deepspeech-0.9.3-models.pbmm"
    PATH_SCORER = "deepspeech-models/deepspeech-0.9.3-models.scorer"
    BEAM_WIDTH = 500 # default is 500

    ds_model = Model(PATH_MODEL)
    ds_model.enableExternalScorer(PATH_SCORER)
    ds_model.setBeamWidth(BEAM_WIDTH)

    metadata_json, transcription = speech_to_text(ds_model, path_audio)

    # Write metadata to output file
    path_output_json = f"{dir_data}/{Path(path_audio).stem}.json"
    with open(path_output_json, "w") as file_output:
        file_output.write(metadata_json)
    print("Saved metadata to", path_output_json)

    # Write transcription to output file
    path_output_transcription = f"{dir_data}/{Path(path_audio).stem}.txt"
    with open(path_output_transcription, "w") as file_output:
        file_output.write(transcription)
    print("Saved transcription to", path_output_transcription)
    

if __name__ == "__main__":
    DIR_DATA = "data"
    path_audio = f"{DIR_DATA}/CASD008_092118_short.wav"
    transcribe_audio(DIR_DATA, path_audio)