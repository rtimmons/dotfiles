#!/usr/bin/env python3
"""whisperx with CPU ASR + MPS diarization/alignment for Apple Silicon."""

import gc
import os
import sys
import warnings

warnings.filterwarnings("ignore")


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <audio_file> <hf_token>", file=sys.stderr)
        sys.exit(1)

    audio_path = sys.argv[1]
    hf_token = sys.argv[2]
    output_dir = os.path.dirname(os.path.abspath(audio_path))

    import torch
    import whisperx
    from whisperx.diarize import DiarizationPipeline, assign_word_speakers
    from whisperx.utils import get_writer

    torch_device = "mps" if torch.backends.mps.is_available() else "cpu"
    print(f"[whisper] ASR: cpu/float32  |  align+diarize: {torch_device}", file=sys.stderr)

    # CTranslate2 only supports cpu/cuda; float32 is fastest on Apple Silicon (ARM NEON)
    model = whisperx.load_model(
        "large-v3-turbo",
        device="cpu",
        compute_type="float32",
        threads=12,
        vad_method="pyannote",
        vad_options={"chunk_size": 30, "vad_onset": 0.500, "vad_offset": 0.363},
        use_auth_token=hf_token,
    )
    audio = whisperx.load_audio(audio_path)
    result = model.transcribe(audio, batch_size=32)
    language = result.get("language", "en")
    del model
    gc.collect()

    # Alignment: PyTorch wav2vec2, runs on MPS
    align_model, align_metadata = whisperx.load_align_model(
        language_code=language,
        device=torch_device,
    )
    result = whisperx.align(
        result["segments"],
        align_model,
        align_metadata,
        audio,
        torch_device,
    )
    del align_model
    gc.collect()

    # Diarization: pyannote pipeline, runs on MPS (was the NNPACK CPU bottleneck)
    diarize_model = DiarizationPipeline(token=hf_token, device=torch_device)
    diarize_segments = diarize_model(audio_path)
    result = assign_word_speakers(diarize_segments, result)

    result["language"] = language

    writer = get_writer("srt", output_dir)
    writer(result, audio_path, {
        "highlight_words": False,
        "max_line_count": None,
        "max_line_width": None,
    })


if __name__ == "__main__":
    main()
