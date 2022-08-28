from typing import Callable, Iterator
import unicodedata
from settings import logger


def clean_text() -> Callable[[str], str]:
    """nfkc正規化とか"""
    def clean(text: str) -> str:
        normalized = unicodedata.normalize("NFKC", text.strip())
        return normalized
    return clean


def read_sentences(file: str, clean: Callable[[str], str]) -> Iterator[str]:
    cnt = 0
    with open(file) as fh:
        while True:
            cnt = cnt + 1
            line = fh.readline()
            if not line:
                break
            for sentence in clean(line).split("。"):
                if sentence.strip():
                    yield sentence