from pathlib import Path
from os import listdir, makedirs, path
from warnings import warn

from textgrid import TextGrid  # https://github.com/kylebgorman/textgrid
from sox import Transformer    # https://github.com/rabitt/pysox

def build_isolated_audio(rel_path_output, rel_path_audio, rel_path_textgrid, tg_tier_name):

    # rel_path_output: Relative path to output .wav file.
    # rel_path_audio: Relative path to input .wav file.
    # rel_path_textgrid: Realtive path to input .TextGrid file.
    # tg_tier_name: TextGrid tier name for speaker.

    SAMPLE_RATE_HZ = 44100

    tfm = Transformer()

    # Read TextGrid from file.
    tg = TextGrid.fromFile(rel_path_textgrid)

    # Read audio from file.
    audio_array = tfm.build_array(rel_path_audio).copy()

    # Tier names are inconsistent; tier name may be "SX" or "SX,".
    potential_tier_names = [tg_tier_name, tg_tier_name+","]
    for potential_tier_name in potential_tier_names:
        intervals = tg.getFirst(potential_tier_name)
        if intervals is not None:
            break
    else:
        warn(f"Tier name matching {potential_tier_names} not found")
        return

    # Silence intervals that do not belong to speaker.
    # Interval marks are always "SX".
    for interval in intervals:

        # Interval belongs to speaker.
        if interval.mark == tg_tier_name:
            continue

        idx_start = int(interval.minTime * SAMPLE_RATE_HZ)
        idx_end = int(interval.maxTime * SAMPLE_RATE_HZ)
        audio_array[idx_start:idx_end] = 0
        
    # Create rel_path_output if it doesn't exist.
    if not path.exists(rel_path_output):
        makedirs(rel_path_output)

    # Save modified audio.
    output_filepath = f"{rel_path_output}/{Path(rel_path_audio).stem}_{tg_tier_name}.wav"
    was_successful = tfm.build_file(output_filepath=output_filepath,
                                    input_array=audio_array,
                                    sample_rate_in=SAMPLE_RATE_HZ)

    if was_successful:
        print(f"Saved audio to {output_filepath}")
    else:
        warn(f"Failed to save audio to {output_filepath}")

def build_isolated_utterances(rel_path_output, rel_path_audio, rel_path_textgrid, tg_tier_name):

    # TODO This function shares enough code to maybe parameterize a single
    # function to handle both utterance and dialog level isolation.

    # rel_path_output: Relative path to output .wav file.
    # rel_path_audio: Relative path to input .wav file.
    # rel_path_textgrid: Realtive path to input .TextGrid file.
    # tg_tier_name: TextGrid tier name for speaker.

    SAMPLE_RATE_HZ = 44100

    tfm = Transformer()

    # Read TextGrid from file.
    tg = TextGrid.fromFile(rel_path_textgrid)

    # Read audio from file.
    audio_array = tfm.build_array(rel_path_audio).copy()

    # Tier names are inconsistent; tier name may be "SX" or "SX,".
    potential_tier_names = [tg_tier_name, tg_tier_name+","]
    for potential_tier_name in potential_tier_names:
        intervals = tg.getFirst(potential_tier_name)
        if intervals is not None:
            break
    else:
        warn(f"Tier name matching {potential_tier_names} not found")
        return

    # Create rel_path_output if it doesn't exist.
    if not path.exists(rel_path_output):
        makedirs(rel_path_output)

    # Build audios from intervals that belong to speaker.
    # Interval marks are always "SX".
    for count, interval in enumerate(intervals):

        # Interval does not belong to speaker.
        if interval.mark != tg_tier_name:
            continue

        idx_start = int(interval.minTime * SAMPLE_RATE_HZ)
        idx_end = int(interval.maxTime * SAMPLE_RATE_HZ)
        utterance_array = audio_array[idx_start:idx_end]
        
        # Save utterance audio.
        output_filepath = f"{rel_path_output}/{Path(rel_path_audio).stem}_{tg_tier_name}_{count}.wav"
        was_successful = tfm.build_file(output_filepath=output_filepath,
                                        input_array=utterance_array,
                                        sample_rate_in=SAMPLE_RATE_HZ)

        if was_successful:
            print(f"Saved audio to {output_filepath}")
        else:
            warn(f"Failed to save audio to {output_filepath}")

if __name__ == "__main__":
    
    # Assume all .wav and .TextGrid are here.
    REL_PATH_NMSU = "nmsu_copy"

    # TextGrid tier names for speakers. "S1" for researcher or "S2" for child.
    TG_TIER_NAMES = ["S1", "S2"]

    for filename in listdir(REL_PATH_NMSU):
        if not filename.endswith(".wav"):
            continue
        
        basename = Path(filename).stem

        rel_path_audio = f"{REL_PATH_NMSU}/{basename}.wav"
        if not path.exists(rel_path_audio):
            warn(f"{rel_path_audio} does not exist")
            continue

        rel_path_textgrid = f"{REL_PATH_NMSU}/{basename}.TextGrid"
        if not path.exists(rel_path_textgrid):
            warn(f"{rel_path_textgrid} does not exist")
            continue

        # Build isolated audio files.
        rel_path_output = "data/isolated"
        for tg_tier_name in TG_TIER_NAMES:
            build_isolated_audio(rel_path_output, rel_path_audio, 
                rel_path_textgrid, tg_tier_name)
        
        # Build isolated utterance audio files.
        rel_path_output = "data/isolated_utterances"
        for tg_tier_name in TG_TIER_NAMES:
            build_isolated_utterances(rel_path_output, rel_path_audio, 
                rel_path_textgrid, tg_tier_name)