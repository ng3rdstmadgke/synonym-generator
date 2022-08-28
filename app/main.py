import sys
import MeCab
from gensim.models import word2vec

import utils
from settings import get_env, logger

def train():
    env = get_env()
    tagger = MeCab.Tagger("-d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd")
    #https://not e.com/doki_ouki/n/nbf6f2ae00039

    include_word_class_set = set(["名詞", "形容詞", "動詞"])
    exclude_word_class_fine_set = set(["数", "非自立", "代名詞","接尾"])

    logger.info("形態素解析: 開始")
    with open(env.wakati_file, "w") as writer:
        for line in utils.read_sentences(env.data_file, utils.clean_text()):
            node = tagger.parseToNode(line)
            while node:
                surface = node.surface
                feature = node.feature.split(",")
                origin = feature[-3]
                word_class = feature[0]
                word_class_fine = feature[1]
                if (word_class in include_word_class_set):
                    if (word_class_fine not in exclude_word_class_fine_set):
                        writer.write(f"{origin} ")
                node = node.next
            writer.write("\n")

    # モデル作成の進捗状況を標準出力するためのlogger
    logger.info("コーパス作成: 開始")
    sentences = word2vec.Text8Corpus(env.wakati_file)
    logger.info("モデル作成: 開始")
    model = word2vec.Word2Vec(
        sentences=sentences,
        vector_size=100,
        window=5,
        min_count=5,
        hs=0,
        negative=5,
        epochs=5,
        workers=2,
    )
    logger.info("モデル保存: 開始")
    model.wv.save_word2vec_format(env.model_file, binary=True)
    pass


logger.info(sys.argv)
mode = sys.argv[1]
if mode == "train":
    logger.info("[MODE] train")
    train()
elif mode == "test":
    logger.info("[MODE] test")
    pass
else:  # serve
    logger.info("[MODE] serve")
    import serve
