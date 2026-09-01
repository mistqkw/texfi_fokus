#!/usr/bin/env python3
"""Синтезатор пресетов звука окончания сессии.

Файлы в `assets/audio/` — не скачанные семплы, а сгенерированные вот этим
скриптом: чистая математика, никаких чужих прав. Держим его в репозитории,
чтобы набор можно было пересобрать или расширить, не подбирая параметры
заново.

Запуск:  python3 tool/generate_sounds.py
Нужен `lame` или `ffmpeg` в PATH для кодирования в mp3.
"""

import math
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import wave

SAMPLE_RATE = 44100
AMPLITUDE = 0.42

OUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "assets",
    "audio",
)


def square(phase, duty=0.5):
    return 1.0 if (phase % 1.0) < duty else -1.0


def triangle(phase):
    p = phase % 1.0
    return 4.0 * abs(p - 0.5) - 1.0


def noise_lcg(state):
    return (state * 1103515245 + 12345) & 0x7FFFFFFF


def tone(freq, seconds, wave_kind="square", duty=0.5, attack=0.004, release=0.06,
         gain=1.0, vibrato=0.0):
    """Одна нота с трапецией по громкости — щелчков на стыках быть не должно."""
    total = int(SAMPLE_RATE * seconds)
    attack_n = max(1, int(SAMPLE_RATE * attack))
    release_n = max(1, int(SAMPLE_RATE * release))
    out = []
    phase = 0.0
    for i in range(total):
        f = freq
        if vibrato:
            f = freq * (1.0 + vibrato * math.sin(2 * math.pi * 6.0 * i / SAMPLE_RATE))
        phase += f / SAMPLE_RATE
        if wave_kind == "square":
            sample = square(phase, duty)
        elif wave_kind == "triangle":
            sample = triangle(phase)
        else:
            sample = math.sin(2 * math.pi * phase)

        if i < attack_n:
            env = i / attack_n
        elif i > total - release_n:
            env = max(0.0, (total - i) / release_n)
        else:
            env = 1.0
        out.append(sample * env * gain)
    return out


def silence(seconds):
    return [0.0] * int(SAMPLE_RATE * seconds)


def mix(*layers):
    """Складывает дорожки, выравнивая по самой длинной."""
    length = max(len(layer) for layer in layers)
    out = [0.0] * length
    for layer in layers:
        for i, sample in enumerate(layer):
            out[i] += sample
    return out


def write_wav(samples, path):
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = AMPLITUDE / peak
    frames = bytearray()
    for sample in samples:
        value = int(max(-1.0, min(1.0, sample * scale)) * 32767)
        frames += struct.pack("<h", value)
    with wave.open(path, "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(bytes(frames))


def encode_mp3(wav_path, mp3_path):
    if shutil.which("lame"):
        subprocess.run(
            ["lame", "--quiet", "-b", "96", "--resample", "44.1", wav_path, mp3_path],
            check=True,
        )
        return
    if shutil.which("ffmpeg"):
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", wav_path,
             "-codec:a", "libmp3lame", "-b:a", "96k", mp3_path],
            check=True,
        )
        return
    sys.exit("нужен lame или ffmpeg в PATH")


# --- Сами пресеты ---------------------------------------------------------

def arcade_coin():
    """Монетка: короткий скачок вверх и звенящий хвост."""
    return tone(988, 0.06, duty=0.5, release=0.01) + \
        tone(1319, 0.42, duty=0.5, release=0.30, vibrato=0.012)


def level_up():
    """Разгон по мажорному арпеджио — «получилось»."""
    notes = [523, 659, 784, 1047]
    out = []
    for freq in notes[:-1]:
        out += tone(freq, 0.09, duty=0.25, release=0.02)
    out += tone(notes[-1], 0.46, duty=0.25, release=0.32, vibrato=0.010)
    return out


def alarm_beep():
    """Три резких равных гудка — самый настойчивый вариант в наборе."""
    out = []
    for _ in range(3):
        out += tone(1760, 0.11, duty=0.5, release=0.03, gain=1.0)
        out += silence(0.09)
    return out


def soft_chime():
    """Мягкая нисходящая терция на треугольнике — для тихих мест."""
    return mix(
        tone(880, 0.30, wave_kind="triangle", attack=0.02, release=0.20) +
        tone(587, 0.70, wave_kind="triangle", attack=0.02, release=0.55),
        silence(0.30) + tone(1175, 0.60, wave_kind="triangle",
                             attack=0.03, release=0.50, gain=0.35),
    )


def power_down():
    """Спуск вниз: сессия закрылась, машина выключается."""
    out = []
    for freq in (784, 659, 523, 392):
        out += tone(freq, 0.13, duty=0.125, release=0.04)
    out += tone(262, 0.42, duty=0.125, release=0.34)
    return out


PRESETS = {
    "arcade_coin": arcade_coin,
    "level_up": level_up,
    "alarm_beep": alarm_beep,
    "soft_chime": soft_chime,
    "power_down": power_down,
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for name, build in PRESETS.items():
            samples = build()
            wav_path = os.path.join(tmp, name + ".wav")
            mp3_path = os.path.join(OUT_DIR, name + ".mp3")
            write_wav(samples, wav_path)
            encode_mp3(wav_path, mp3_path)
            seconds = len(samples) / SAMPLE_RATE
            print(f"{name}.mp3  {seconds:.2f}s  {os.path.getsize(mp3_path)} B")


if __name__ == "__main__":
    main()
