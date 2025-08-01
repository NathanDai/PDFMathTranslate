FROM ghcr.nju.edu.cn/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app


EXPOSE 7860

ENV PYTHONUNBUFFERED=1
ENV UV_DEFAULT_INDEX="https://mirrors.aliyun.com/pypi/simple"

# Download all required fonts
ADD "https://github.com/satbyy/go-noto-universal/releases/download/v7.0/GoNotoKurrent-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifCN-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifTW-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifJP-Regular.ttf" /app/
ADD "https://github.com/timelic/source-han-serif/releases/download/main/SourceHanSerifKR-Regular.ttf" /app/

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
     apt-get install --no-install-recommends -y libgl1 libglib2.0-0 libxext6 libsm6 libxrender1 && \
     rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN uv pip install --system --no-cache -r pyproject.toml && babeldoc --version && babeldoc --warmup

COPY . .

RUN uv pip install --system --no-cache . && uv pip install --system --no-cache -U "babeldoc<0.3.0" "pymupdf<1.25.3" "pdfminer-six==20250416" && babeldoc --version && babeldoc --warmup

RUN mkdir -p /.config
RUN chmod 777 /.config
RUN mkdir -p /.config/PDFMathTranslate
RUN chmod 777 /.config/PDFMathTranslate

RUN echo '{"USE_MODELSCOPE":"0","translators":[{"name":"deepl","envs":{"DEEPL_AUTH_KEY":""}}],"PDF2ZH_VFONT":"","ENABLED_SERVICES":["DeepL"],"HIDDEN_GRADIO_DETAILS":true,"PDF2ZH_LANG_FROM":"English","PDF2ZH_LANG_TO":"Simplified Chinese","NOTO_FONT_PATH":"/app/SourceHanSerifCN-Regular.ttf"}' > /.config/PDFMathTranslate/config.json
RUN chmod 777 /.config/PDFMathTranslate/config.json

CMD ["pdf2zh", "-i", "--config", "/.config/PDFMathTranslate/config.json"]

