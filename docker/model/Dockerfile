FROM python:3.8-bullseye

RUN apt update

RUN apt install locales -y && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt install -y jq less git vim curl wget sudo tmux mecab unidic-mecab libmecab-dev bzip2 nkf

RUN pip install --upgrade pip

# neologdインストール
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
  cd mecab-ipadic-neologd && \
  ./bin/install-mecab-ipadic-neologd -y -n && \
  echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir -p /opt/app /opt/tmp
WORKDIR /opt/app
COPY app .

EXPOSE 8080
ENTRYPOINT ["/opt/app/app.sh"]