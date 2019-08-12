FROM ubuntu:19.04

# Install packages for the following steps
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates=20190110 \
    perl=5.28.1-6 \
    unzip=6.0-22ubuntu1 \
    wget=1.20.1-1ubuntu4 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install TeX live
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -P /tmp -nv \
  && mkdir /tmp/install-tl-unx \
  && tar xvf /tmp/install-tl-unx.tar.gz -C /tmp \
  && printf "%s\n" \
      "selected_scheme scheme-basic" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/texlive.profile \
  && INSTALL_TL=$(find /tmp -name "install-tl*" -maxdepth 1 -printf '%f\n' | sort | head -n 1) \
  && /tmp/"${INSTALL_TL}"/install-tl \
    -no-gui \
    -repository http://mirror.ctan.org/systems/texlive/tlnet/ \
    -profile=/tmp/texlive.profile \
  && rm -rf /tmp/install-tl* /tmp/texlive.profile
ENV PATH="/usr/local/texlive/2019/bin/x86_64-linux:${PATH}"

# setup LuaTeX
RUN tlmgr update --self \
  && tlmgr update --all \
  && tlmgr install \
    collection-basic \
    collection-fontsrecommended \
    collection-langjapanese \
    collection-latex \
    collection-latexextra \
    collection-latexrecommended \
    collection-luatex \
    dvipdfmx \
    latexmk

# install font
RUN wget https://github.com/adobe-fonts/source-han-serif/raw/release/SubsetOTF/SourceHanSerifJP.zip -P /tmp -nv \
  && wget https://github.com/adobe-fonts/source-han-sans/raw/release/SubsetOTF/SourceHanSansJP.zip -P /tmp -nv \
  && mkdir -p /usr/local/texlive/texmf-local/fonts/opentype/adobe \
  && unzip /tmp/SourceHanSerifJP.zip -d /usr/local/texlive/texmf-local/fonts/opentype/adobe/ \
  && unzip /tmp/SourceHanSansJP.zip -d /usr/local/texlive/texmf-local/fonts/opentype/adobe/ \
  && rm -f /tmp/*.zip \
  && mktexlsr
