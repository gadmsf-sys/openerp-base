# ======================================
# ETAPA 1: BUILDER
# ======================================
FROM ubuntu:18.04 AS builder
LABEL stage=builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Guayaquil

# ------------------------------
# Sistema + Python + build deps
# ------------------------------
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    python2.7 \
    python2.7-dev \
    python-pip \
    build-essential \
    gcc \
    g++ \
    make \
    postgresql-client \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl1.0-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    zlib1g-dev \
    libcups2-dev \
    python-soappy \
    fontconfig \
    libxrender1 \
    libxtst6 \
    libpng16-16 \
    libssl1.1 \
    xfonts-75dpi \
    xfonts-base \
 && rm -rf /var/lib/apt/lists/*

# Enlaces python
RUN ln -sf /usr/bin/python2.7 /usr/bin/python2 \
 && ln -sf /usr/bin/python2.7 /usr/bin/python

# Pip base
RUN pip install --upgrade pip setuptools wheel

# ------------------------------
# wkhtmltopdf (Qt parcheado)
# ------------------------------
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
 && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb || apt-get -f install -y \
 && rm wkhtmltox_0.12.5-1.bionic_amd64.deb

# ------------------------------
# Dependencias Python (TODAS)
# ------------------------------
RUN pip install \
    psycopg2==2.7.7 \
    pytz \
    pyyaml \
    mako \
    Python-Chart \
    lxml==3.8.0 \
    Pillow==6.2.2 \
    python-dateutil==2.8.2 \
    python-openid==2.2.5 \
    xlrd==1.2.0 \
    reportlab==3.5.59 \
    babel==0.9.6 \
    jinja2==2.6 \
    simplejson==2.1.6 \
    werkzeug==0.6.2 \
    feedparser \
    python-ldap \
    xlwt==1.3.0 \
    xlutils==1.7.1 \
    pycups==1.9.73 \
    requests==2.21.0 \
    suds==0.4 \
    more-itertools==5.0.0 \
    mysql-connector==2.1.7

# ======================================
# ETAPA 2: RUNTIME (imagen final)
# ======================================
FROM ubuntu:18.04 AS runtime
LABEL stage=runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Guayaquil

# ------------------------------
# Librerías runtime (solo necesarias)
# ------------------------------
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    postgresql-client \
    libpq5 \
    libxml2 \
    libxslt1.1 \
    libldap-2.4-2 \
    libsasl2-2 \
    libssl1.1 \
    libjpeg-turbo8 \
    libpng16-16 \
    libfreetype6 \
    zlib1g \
    libcups2 \
    fontconfig \
    libxrender1 \
    libxtst6 \
    xfonts-75dpi \
    xfonts-base \
 && rm -rf /var/lib/apt/lists/*

# ------------------------------
# Copiar Python deps compiladas
# ------------------------------
COPY --from=builder /usr/lib/python2.7/dist-packages \
                    /usr/lib/python2.7/dist-packages
COPY --from=builder /usr/local/lib/python2.7/dist-packages \
                    /usr/local/lib/python2.7/dist-packages

# ------------------------------
# Copiar wkhtmltopdf
# ------------------------------
COPY --from=builder /usr/local/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
COPY --from=builder /usr/local/lib/libwkhtmltox.so* /usr/local/lib/
