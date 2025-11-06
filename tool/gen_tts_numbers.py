import argparse
import os
import subprocess
import tempfile

UNITS = {
    1: "uno",
    2: "dos",
    3: "tres",
    4: "cuatro",
    5: "cinco",
    6: "seis",
    7: "siete",
    8: "ocho",
    9: "nueve",
}

PREDEFINED = {
    1: "uno",
    2: "dos",
    3: "tres",
    4: "cuatro",
    5: "cinco",
    6: "seis",
    7: "siete",
    8: "ocho",
    9: "nueve",
    10: "diez",
    11: "once",
    12: "doce",
    13: "trece",
    14: "catorce",
    15: "quince",
    16: "dieciséis",
    17: "diecisiete",
    18: "dieciocho",
    19: "diecinueve",
    20: "veinte",
    21: "veintiuno",
    22: "veintidós",
    23: "veintitrés",
    24: "veinticuatro",
    25: "veinticinco",
    26: "veintiséis",
    27: "veintisiete",
    28: "veintiocho",
    29: "veintinueve",
}

TENS = {
    30: "treinta",
    40: "cuarenta",
    50: "cincuenta",
    60: "sesenta",
    70: "setenta",
    80: "ochenta",
    90: "noventa",
}


def spanish_number_map() -> dict[int, str]:
    numbers: dict[int, str] = dict(PREDEFINED)
    for base, word in TENS.items():
        numbers[base] = word
        for unit in range(1, 10):
            value = base + unit
            if value > 100:
                break
            numbers[value] = f"{word} y {UNITS[unit]}"
    numbers[100] = "cien"
    return dict(sorted(numbers.items()))


def synthesize(model_path: str, text: str, output_path: str, rate: float) -> None:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_wav:
        wav_path = temp_wav.name
    try:
        command = [
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
            command.extend(["--config", config_path])
        subprocess.run(
            command,
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
    parser = argparse.ArgumentParser(description="Generate Spanish number TTS (1-100).")
    parser.add_argument("--model", required=True, help="Path to Piper ONNX model.")
    parser.add_argument(
        "--outdir",
        required=True,
        help="Directory where MP3 files will be written.",
    )
    parser.add_argument(
        "--rate",
        type=float,
        default=0.85,
        help="Speech rate (1.0 = default speed).",
    )
    parser.add_argument(
        "--prefix",
        default="num_",
        help="Filename prefix (default: num_).",
    )
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    for number, text in spanish_number_map().items():
        filename = f"{args.prefix}{number:03d}.mp3"
        path = os.path.join(args.outdir, filename)
        synthesize(args.model, text, path, args.rate)
        print(f"{number}: {path}")


if __name__ == "__main__":
    main()
