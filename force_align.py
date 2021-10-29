from pathlib import Path
from subprocess import run


def force_align(dir_data, path_audio, path_transcription):

    ALPHABET = "alphabet.txt"
    STT_MODEL_DIR = "deepspeech-models"

    path_tlog = f"{dir_data}/{Path(path_audio).stem}.tlog"
    path_aligned = f"{dir_data}/{Path(path_audio).stem}.aligned"

    cmd = f"python DSAlign-master/align/align.py --audio {path_audio} " \
        f"--script {path_transcription} --alphabet {ALPHABET} --tlog " \
        f"{path_tlog} --aligned {path_aligned} " \
        f"--stt-model-dir {STT_MODEL_DIR} --output-pretty --force"
    run(cmd)
