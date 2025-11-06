import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import unicodedata


def slug(text: str) -> str:
    text = text.strip()
    text = unicodedata.normalize("NFKD", text)
    text = "".join(char for char in text if not unicodedata.combining(char))
    text = re.sub(r"[^a-zA-Z0-9_-]+", "_", text).strip("_")
    return text[:80] or "clip"


def extract_texts(data, text_key: str) -> list[str]:
    collected: list[str] = []
    if isinstance(data, list):
        for item in data:
            if isinstance(item, str):
                collected.append(item)
            elif isinstance(item, dict) and text_key in item:
                collected.append(item[text_key])
    elif isinstance(data, dict):
        if text_key in data and isinstance(data[text_key], list):
            for item in data[text_key]:
                if isinstance(item, str):
                    collected.append(item)
                elif isinstance(item, dict) and text_key in item:
                    collected.append(item[text_key])
        else:
            for value in data.values():
                if isinstance(value, list):
                    for item in value:
                        if isinstance(item, str):
                            collected.append(item)
                        elif isinstance(item, dict) and text_key in item:
                            collected.append(item[text_key])
    return [text for text in collected if isinstance(text, str) and text.strip()]


def synthesize_to_mp3(text: str, model_path: str, output_path: str, rate: float = 1.0) -> None:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_wav:
        wav_path = temp_wav.name
    try:
        piper_command = [
            "piper",
            "--model",
            model_path,
            "--length_scale",
            str(1.0 / rate),
            "--output-file",
            wav_path,
        ]
        config_path = f"{model_path}.json"
        if os.path.exists(config_path):
            piper_command.extend(["--config", config_path])
        subprocess.run(
            piper_command,
            input=text.encode("utf-8"),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-i",
                wav_path,
                "-af",
                "loudnorm=I=-18:TP=-1.5:LRA=11,aformat=channel_layouts=mono",
                "-ar",
                "48000",
                "-b:a",
                "64k",
                output_path,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
    finally:
        try:
            os.remove(wav_path)
        except FileNotFoundError:
            pass


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", required=True)
    parser.add_argument("--text-key", default="text")
    parser.add_argument("--model", required=True)
    parser.add_argument("--outdir", required=True)
    parser.add_argument("--prefix", default="")
    parser.add_argument("--rate", type=float, default=1.0)
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    with open(args.json, "r", encoding="utf-8") as file:
        payload = json.load(file)

    texts = extract_texts(payload, args.text_key)
    if not texts:
        print("No texts found. Check --text-key and JSON shape.", file=sys.stderr)
        sys.exit(2)

    seen = set()
    for text in texts:
        base = slug(text)
        if base in seen:
            index = 2
            while f"{base}_{index}" in seen:
                index += 1
            base = f"{base}_{index}"
        seen.add(base)
        output_mp3 = os.path.join(args.outdir, f"{args.prefix}{base}.mp3")
        synthesize_to_mp3(text, args.model, output_mp3, rate=args.rate)
        print(output_mp3)


if __name__ == "__main__":
    main()
