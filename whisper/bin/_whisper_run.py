#!/usr/bin/env python3
"""whisperx: mlx-whisper ASR (GPU/ANE) + MPS diarization/alignment for Apple Silicon."""

import gc
import os
import sys
import warnings

warnings.filterwarnings("ignore")

# mlx-community model to use for ASR.
# large-v3-turbo:    same weights as CTranslate2 baseline, no quality tradeoff
# large-v3-turbo-q4: 4-bit quantised, ~2x faster, minor quality tradeoff on noisy/accented audio
ASR_MODEL = "mlx-community/whisper-large-v3-turbo"


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <audio_file> <hf_token>", file=sys.stderr)
        sys.exit(1)

    audio_path = sys.argv[1]
    hf_token = sys.argv[2]
    output_dir = os.path.dirname(os.path.abspath(audio_path))

    import torch
    import mlx_whisper
    import whisperx
    from whisperx.diarize import DiarizationPipeline, assign_word_speakers
    from whisperx.utils import get_writer

    torch_device = "mps" if torch.backends.mps.is_available() else "cpu"
    print(f"[whisper] ASR: mlx {ASR_MODEL.split('/')[-1]}  |  align+diarize: {torch_device}", file=sys.stderr)

    # ASR via Apple MLX — runs on GPU/ANE, same model weights as large-v3-turbo
    result = mlx_whisper.transcribe(
        audio_path,
        path_or_hf_repo=ASR_MODEL,
        word_timestamps=True,
    )
    language = result.get("language", "en")
    segments = result["segments"]
    gc.collect()

    # Load raw audio for alignment
    audio = whisperx.load_audio(audio_path)

    # Alignment: wav2vec2 on MPS
    align_model, align_metadata = whisperx.load_align_model(
        language_code=language,
        device=torch_device,
    )
    result = whisperx.align(segments, align_model, align_metadata, audio, torch_device)
    del align_model
    gc.collect()

    # Diarization: pyannote on MPS
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
