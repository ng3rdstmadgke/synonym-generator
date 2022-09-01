FROM python:3.8-slim-bullseye

RUN apt update

RUN apt install -y locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

RUN mkdir -p /opt/app
WORKDIR /opt/app
COPY app .
CMD ["/bin/sh"]