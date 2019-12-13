FROM ubuntu:xenial-20180808

# SDK Tools 26.1.1 (September 2017)
# NDK r19b (February 2019)
# Maven 3.6.1
# Install modern cmake
# Install Android SDK and NDK
# Install GCloud CLI
# Install SDK Build Tools 28.0.3 (September 2018)
# Install NDK in temp directory first, then move to target location

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl apt-utils software-properties-common && \
    apt-get install -y openjdk-8-jdk ant ca-certificates-java && \
    update-ca-certificates -f && \
    rm -rf /var/cache/oracle-jdk8-installer && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
    apt-add-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-add-repository -y ppa:git-core/ppa && \
    apt-add-repository -y 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main' && \
    apt-add-repository -y ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y git ssh tar gzip bzip2 xz-utils ca-certificates \
        ninja-build fish unzip \
        clang-7 lldb-7 lld-7 libfuzzer-7-dev libc++-7-dev libc++abi-7-dev libomp-7-dev \
        gcc-8-multilib g++-8-multilib \
        libssl-dev \
        ruby2.6 ruby2.6-dev ruby-switch build-essential patch zlib1g-dev liblzma-dev \
        doxygen gnupg golang && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-8 && \
    update-alternatives --config gcc && \
    ruby-switch --set ruby2.6 && \
    echo "Fetching and installing latest GCloud as of 24th of April" && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y && \
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
        tools \
        platform-tools && \
    yes | /usr/local/opt/android-sdk/tools/bin/sdkmanager --licenses && \
    unzip -q -o /dist/android-ndk-r19b-linux-x86_64.zip -d /tmp && \
    mv -f /tmp/android-ndk-r19b/* /usr/local/opt/android-ndk/ && \
    rm -rf /tmp/android-ndk-r19b/ && \
    rm -rf /dist && \
    npm install -g tap-xunit-testname-ctrlchars@2.3.1 && \
    wget https://www-us.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-*.tar.gz -C /usr/local/opt && \
    ln -s /usr/local/opt/apache-maven-3.6.1 /usr/local/opt/maven && \
    mkdir -p ~/.gradle && \
    echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties && \
    echo "android.builder.sdkDownload=false" >> ~/.gradle/gradle.properties && \
    wget 'https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz' -P /tmp && \
    tar xf /tmp/gcc-arm-*.tar.xz -C /usr/local/opt && \
    ln -s /usr/local/opt/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf /usr/local/opt/gcc-arm

ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    M2_HOME=/usr/local/opt/maven \
    MAVEN_HOME=/usr/local/opt/maven \
    ANDROID_HOME=/usr/local/opt/android-sdk \
    ANDROID_SDK_HOME=/usr/local/opt/android-sdk \
    ANDROID_SDK_ROOT=/usr/local/opt/android-sdk \
    ANDRDOID_NDK=/usr/local/opt/android-ndk \
    ANDROID_NDK_HOME=/usr/local/opt/android-ndk \
    ANDROID_NDK_ROOT=/usr/local/opt/android-ndk \
    PATH=~/.cargo/bin:/usr/local/opt/android-sdk/tools:/usr/local/opt/android-sdk/tools/bin:/usr/local/opt/android-ndk:/usr/local/opt/android-ndk/build/tools:/usr/local/opt/android-ndk/simpleperf:/usr/local/opt/maven/bin:/usr/local/opt/gcc-arm/bin:$PATH
