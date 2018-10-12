FROM ubuntu:xenial-20180808

ENV LANG C.UTF-8
RUN mkdir -p /dist

RUN apt-get update && \
    apt-get install -y wget apt-utils software-properties-common && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
    apt-add-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-add-repository -y 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main' && \
    apt-get update && \
    apt-get install -y git ssh tar gzip ca-certificates \
        ninja-build fish maven unzip \
        clang-7 lldb-7 lld-7 libfuzzer-7-dev libc++-7-dev libc++abi-7-dev libomp-7-dev \
        gcc-7-multilib g++-7-multilib

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

# Set up clang symlinks
RUN ln -s /usr/bin/clang-7 /usr/bin/clang
RUN ln -s /usr/bin/ld.lld-7 /usr/bin/ld.lld
RUN ln -s /usr/bin/lldb-7 /usr/bin/lldb

# Install modern cmake
ADD https://cmake.org/files/v3.13/cmake-3.13.0-rc1-Linux-x86_64.sh /dist/cmake-3.13.0-rc1-Linux-x86_64.sh
RUN sh /dist/cmake-3.13.0-rc1-Linux-x86_64.sh --prefix=/usr/local --skip-license

# Install Android SDK and NDK
# SDK Tools 26.1.1 (September 2017)
ADD https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip /dist/sdk-tools-linux-4333796.zip
# NDK r18 (September 2018)
ADD https://dl.google.com/android/repository/android-ndk-r18-linux-x86_64.zip /dist/android-ndk-r18-linux-x86_64.zip
RUN mkdir -p /usr/local/opt/android-sdk /usr/local/opt/android-ndk
RUN unzip -q -o /dist/sdk-tools-linux-4333796.zip -d /usr/local/opt/android-sdk
# Install SDK Build Tools 28.0.3 (September 2018)
RUN yes | /usr/local/opt/android-sdk/tools/bin/sdkmanager \
    build-tools;28.0.3 \
    extras;android;m2repository \
    extras;google;m2repository \
    platforms;android-26 \
    platforms;android-28 \
    tools
RUN yes | /usr/local/opt/android-sdk/tools/bin/sdkmanager --licenses
# Install NDK in temp directory first, then move to target location
RUN unzip -q -o /dist/android-ndk-r18-linux-x86_64.zip -d /tmp && \
    mv -f /tmp/android-ndk-r18/* /usr/local/opt/android-ndk/ && \
    rm -rf /tmp/android-ndk-r18/

ENV ANDROID_HOME /usr/local/opt/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV ANDRDOID_NDK /usr/local/opt/android-ndk
ENV ANDROID_NDK_HOME $ANDROID_NDK
ENV ANDROID_NDK_ROOT $ANDROID_NDK

ENV PATH $ANDROID_NDK:$ANDROID_NDK/build/tools:$ANDROID_NDK/simpleperf:$PATH
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH

# Add rust (experimental)
ADD https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init /dist/rustup-init
RUN chmod +x /dist/rustup-init && \
    /dist/rustup-init -y --default-toolchain nightly

ENV PATH ~/.cargo/bin:$PATH

RUN rustup self update && \
    rustup update && \
    rustup toolchain add stable && \
    rustup target add armv7-linux-androideabi aarch64-linux-android wasm32-unknown-unknown && \
    rustup component add clippy-preview llvm-tools-preview rls-preview rust-analysis rustfmt-preview && \
    cargo install cargo-edit cargo-watch cargo-bloat cargo-asm cargo-expand cargo-graph cargo-vendor cargo-web cargo-release

RUN rm -rf /dist
