FROM python:3.6.10-alpine3.11
  
RUN echo -e "http://mirrors.aliyun.com/alpine/v3.11/main\nhttp://mirrors.aliyun.com/alpine/v3.11/community" > /etc/apk/repositories
RUN apk update && apk add --no-cache  nginx mariadb nodejs-npm git build-base  supervisor  bash
RUN apk add --no-cache --virtual .build-deps  openssl-dev gcc musl-dev python3-dev libffi-dev openssh-client make \
    && mkdir /etc/supervisor.d

RUN git clone git://github.com/linyup/HLY_WebsiteGuide.git --depth=1 /HLY_WebsiteGuide && cd /HLY_WebsiteGuide && git pull
#RUN cd /HLY_WebsiteGuide/websitefronted && npm i --registry=https://registry.npm.taobao.org && npm run build
RUN cd /HLY_WebsiteGuide/websitefronted && npm install -g cnpm --registry=https://registry.npm.taobao.org && cnpm install &&  npm run build

RUN pip config set global.index-url https://pypi.mirrors.ustc.edu.cn/simple/  && pip install --upgrade pip && pip install --no-cache-dir -r /HLY_WebsiteGuide/requirements.txt \
    && pip install --no-cache-dir gunicorn \
    && apk del .build-deps

ADD websiteguide.ini /etc/supervisor.d/websiteguide.ini
ADD default.conf /etc/nginx/conf.d/default.conf
ADD entrypoint.sh /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["sh", "/entrypoint.sh"]
