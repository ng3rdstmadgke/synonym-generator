FROM python:3.8-bullseye

RUN apt update

#RUN apt install -y jq less git vim curl wget sudo tmux mecab unidic-mecab libmecab-dev bzip2 nkf
RUN apt install -y jq less git vim curl wget sudo tmux mecab libmecab-dev bzip2 nkf

RUN pip install --upgrade pip

# neologdインストール
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
  cd mecab-ipadic-neologd && \
  ./bin/install-mecab-ipadic-neologd -y -n -p /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd && \
  echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

FROM python:3.8-slim-bullseye

COPY --from=0 /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd

RUN apt update

RUN apt install -y locales -y && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt install -y mecab bash

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir -p /opt/app /opt/tmp
WORKDIR /opt/app
COPY app .
RUN chmod 755 /opt/app/app.sh

EXPOSE 8080
ENTRYPOINT ["/opt/app/app.sh"]