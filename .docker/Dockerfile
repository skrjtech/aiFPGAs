FROM ubuntu:20.04

SHELL [ "/bin/bash", "-c" ]

# 初期環境設定 ---------------------------------------------------------------------------------------------------------------

# 応答対策
ENV DEBIAN_FRONTEND=noninteractive
# 日本語の対応化
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:
# タイムゾーン
ENV TZ=Asia/Tokyo
# カラー化(Console)
ENV TERM=xterm-256color

# 初期環境設定 ---------------------------------------------------------------------------------------------------------------

# パッケージ更新
RUN apt update && apt upgrade -y
RUN apt-get update && apt-get upgrade -y
# 必要なパッケージ
RUN apt install -y sudo curl wget vim gcc g++ make cmake locales
# RUN dpkg --add-architecture i386
# RUN apt update
# RUN apt install -y libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 libxft2:i386 libxext6:i386
# RUN apt install -y build-essential libx11-dev libxft-dev libxext-dev libncurses5 libncurses5-dev lib32z1 lib32stdc++6
# RUN apt-get install -y \
# wget \
# unzip \
# libx11-6 \
# libxext6 \
# libxft2 \
# libxpm4 \
# libxrender1 \
# libxt6 \
# libxtst6 \
# libglib2.0-0 \
# libsm6 \
# libxau6 \
# libxdmcp6 \
# libxcomposite1 \
# libxdamage1 \
# libxfixes3 \
# libxi6 \
# libxinerama1 \
# libxrandr2 \
# libxres1 \
# libxss1 \
# libxtst6 \
# libfontconfig1 \
# libgl1-mesa-glx \
# libgl1-mesa-dri \
# libglu1-mesa \
# libncurses5 \
# libtinfo5 \
# libpng16-16 \
# libjpeg8 \
# libfreetype6 \
# libuuid1 \
# libgtk2.0-0 \
# libcanberra-gtk-module \
# libatk1.0-0 \
# libcairo2 \
# libpango-1.0-0 \
# libpangocairo-1.0-0 \
# libgdk-pixbuf2.0-0 \
# libxv1 

RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    libxext6 \
    libxft2 \ 
    libxrender1 \
    libglib2.0-0 \
    libsm6 \
    libx11-xcb1 \
    libpng16-16 \
    libfontconfig1 \
    xz-utils \
    libudev1 \
    libgconf-2-4 \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Tab補完を使用可能にしてくれる魔法の言葉
# RUN apt install -y bash-completion && source /etc/bash_completion  && echo "source /etc/bash_completion" >> ~/.bashrc

# 時刻同期
RUN apt install -y tzdata && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN rm -rf /var/lib/apt/lists/*
RUN apt update && apt upgrade -y
RUN apt-get update && apt-get upgrade -y

# ユーザーの作成
ARG GID=1000
ARG UID=1000
ARG USERNAME=aifpga
RUN groupadd -g $GID -o ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -G sudo -o -s /bin/bash ${USERNAME} && echo "${USERNAME}:${USERNAME}" | chpasswd && \
    usermod --shell /bin/bash ${USERNAME} && \
    # sudo を　パスワードなしで実行
    usermod -aG sudo ${USERNAME} && \ 
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    usermod --uid ${UID} ${USERNAME} && groupmod --gid ${GID} ${USERNAME}

# 作業場構築
RUN mkdir -p /Workspace && chown -R ${USERNAME}:${USERNAME} /Workspace

USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN echo "source /etc/bash_completion" >> ~/.bashrc
RUN bash -c "touch /home/${USERNAME}/.sudo_as_admin_successful"

# 業場移動
WORKDIR /Workspace

# ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6:/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
ARG QUARTUS_DIR=/home/${USERNAME}/Quartus
ARG QUARTUS_DISABLED="quartus_help,quartus_update,modelsim_ase,modelsim_ae"
COPY ./Quartus ${QUARTUS_DIR}

# RUN ${QUARTUS_DIR}/setup.sh --mode unattended --accept_eula 1 --installdir ${QUARTUS_DIR} --disable-components ${QUARTUS_DISABLED}
# RUN rm -rf ./Quartus && chmod -R a+rx ${QUARTUS_DIR}

# ENV LD_LIBRARY_PATH=${QUARTUS_DIR}/quartus/linux64:${LD_LIBRARY_PATH}
# ENV LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1:${LD_PRELOAD}

CMD [ "/bin/bash" ]