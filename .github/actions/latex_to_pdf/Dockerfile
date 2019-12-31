FROM paperist/alpine-texlive-ja

RUN \
  apk add wget && \
  tlmgr option --repository=http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/ && \
  tlmgr update --self && \
  tlmgr install newtx boondox kastrup tex-gyre mweights

ADD entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
