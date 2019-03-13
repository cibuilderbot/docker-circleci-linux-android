FROM ubuntu:xenial-20180808

# SDK Tools 26.1.1 (September 2017)
# NDK r19b (February 2019)
# Install modern cmake
# Install Android SDK and NDK
# Install SDK Build Tools 28.0.3 (September 2018)
# Install NDK in temp directory first, then move to target location

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl apt-utils software-properties-common && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
    apt-add-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-add-repository -y 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main' && \
    apt-get update && \
    apt-get install -y git ssh tar gzip bzip2 xz-utils ca-certificates \
        ninja-build fish maven unzip \
        clang-7 lldb-7 lld-7 libfuzzer-7-dev libc++-7-dev libc++abi-7-dev libomp-7-dev \
        gcc-7-multilib g++-7-multilib \
        libssl-dev \
        ruby-full build-essential patch ruby-dev zlib1g-dev liblzma-dev \
        doxygen gnupg && \
    gem install nokogiri && \    
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /dist && \
    wget -O /dist/cmake-3.14.0-rc4-Linux-x86_64.sh https://cmake.org/files/v3.14/cmake-3.14.0-rc4-Linux-x86_64.sh && \
    wget -O /dist/sdk-tools-linux-4333796.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    wget -O /dist/android-ndk-r19b-linux-x86_64.zip https://dl.google.com/android/repository/android-ndk-r19b-linux-x86_64.zip && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get -y install nodejs && \
    sh /dist/cmake-3.14.0-rc4-Linux-x86_64.sh --prefix=/usr/local --skip-license && \
    mkdir -p /usr/local/opt/android-sdk /usr/local/opt/android-ndk && \
    unzip -q -o /dist/sdk-tools-linux-4333796.zip -d /usr/local/opt/android-sdk && \
    yes | /usr/local/opt/android-sdk/tools/bin/sdkmanager \
        "build-tools;28.0.3" \
        "extras;android;m2repository" \
        "extras;google;m2repository" \
        "platforms;android-26" \
        "platforms;android-28" \
        tools && \
    yes | /usr/local/opt/android-sdk/tools/bin/sdkmanager --licenses && \
    unzip -q -o /dist/android-ndk-r19b-linux-x86_64.zip -d /tmp && \
    mv -f /tmp/android-ndk-r19b/* /usr/local/opt/android-ndk/ && \
    rm -rf /tmp/android-ndk-r19b/ && \
    rm -rf /dist && \
    npm install -g tap-xunit-testname-ctrlchars@2.3.1

ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre \
    ANDROID_HOME=/usr/local/opt/android-sdk \
    ANDROID_SDK_HOME=/usr/local/opt/android-sdk \
    ANDROID_SDK_ROOT=/usr/local/opt/android-sdk \
    ANDRDOID_NDK=/usr/local/opt/android-ndk \
    ANDROID_NDK_HOME=/usr/local/opt/android-ndk \
    ANDROID_NDK_ROOT=/usr/local/opt/android-ndk \
    PATH=~/.cargo/bin:/usr/local/opt/android-sdk/tools:/usr/local/opt/android-sdk/tools/bin:/usr/local/opt/android-ndk:/usr/local/opt/android-ndk/build/tools:/usr/local/opt/android-ndk/simpleperf:$PATH
