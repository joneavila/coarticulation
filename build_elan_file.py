from pathlib import Path
from pympi.Elan import Eaf
import json


def build_elan_file(dir_data, path_audio, path_tlog1, path_tlog2):

    TIER_ID1 = "S1"
    TIER_ID2 = "S2"

    # Construct a new .eaf file
    eaf = Eaf()

    # Add the audio
    eaf.add_linked_file(path_audio)

    # Read aligner log files for the transcriptions and timestamps and add
    # them as annotations
    for (path_tlog, tier_id) in zip([path_tlog1, path_tlog2], [TIER_ID1,
                                    TIER_ID2]):

        # Add tiers for the transcription
        eaf.add_tier(tier_id)

        with open(path_tlog) as log_file:
            log_data = json.load(log_file)
        for item in log_data:
            start_time = int(item["start"])
            end_time = int(item["end"])
            transcript = item["transcript"]
            eaf.add_annotation(tier_id, start_time, end_time, transcript)

    # Save .eaf
    path_output = f"{dir_data}/{Path(path_audio).stem}.eaf"
    eaf.to_file(path_output)
    print("Saved annotation file to", path_output)
