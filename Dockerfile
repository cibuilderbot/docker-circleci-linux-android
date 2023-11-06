FROM ubuntu:xenial-20180808

# Android SDK Command-line Tools 3.0
# NDK r21b
# Maven 3.6.1
# Install modern cmake
# Install Android SDK and NDK
# Install GCloud CLI
# Install SDK Build Tools 31.0.0

ARG ndkVersion=21.1.6352462
ARG sdkRoot=/usr/local/opt/android-sdk
ARG ndkRoot=$sdkRoot/ndk/$ndkVersion
    
ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    M2_HOME=/usr/local/opt/maven \
    MAVEN_HOME=/usr/local/opt/maven \
    ANDROID_HOME=$sdkRoot \
    ANDROID_SDK_HOME=$sdkRoot \
    ANDROID_SDK_ROOT=$sdkRoot \
    ANDROID_NDK=$ndkRoot \
    ANDROID_NDK_HOME=$ndkRoot \
    ANDROID_NDK_ROOT=$ndkRoot \
    PATH=~/.cargo/bin:$sdkRoot/tools:$sdkRoot/tools/bin:$ndkRoot:$ndkRoot/build/tools:$ndkRoot/simpleperf:/usr/local/opt/maven/bin:/usr/local/opt/gcc-arm/bin:$PATH

RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y --no-install-recommends wget curl apt-utils software-properties-common && \
    apt-add-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-17-jdk ant ca-certificates-java && \
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
    gem install nokogiri -v 1.13.10 && \
    Y | gcloud components install beta \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /dist && \
    wget -O /dist/cmake-3.17.0-Linux-x86_64.sh https://cmake.org/files/v3.17/cmake-3.17.0-Linux-x86_64.sh && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get -y install nodejs && \
    sh /dist/cmake-3.17.0-Linux-x86_64.sh --prefix=/usr/local --skip-license && \
    wget -O /dist/commandlinetools-linux-6858069.zip https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip && \
    unzip -q -o /dist/commandlinetools-linux-6858069.zip -d /dist && \
    mkdir -p $sdkRoot/cmdline-tools/latest && \
    mv /dist/cmdline-tools/* $sdkRoot/cmdline-tools/latest && \
    rm -rf /dist && \
    yes | $sdkRoot/cmdline-tools/latest/bin/sdkmanager \
        "build-tools;33.0.0" \
        "build-tools;33.0.1" \
        "extras;android;m2repository" \
        "extras;google;m2repository" \
        "platforms;android-33" \
        "platforms;android-34" \
        "ndk;$ndkVersion" \
        tools && \
    yes | $sdkRoot/cmdline-tools/latest/bin/sdkmanager --licenses && \
    npm install -g appcenter-cli && \
    npm install -g tap-xunit-testname-ctrlchars@2.3.1 && \
    wget https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-*.tar.gz -C /usr/local/opt && \
    ln -s /usr/local/opt/apache-maven-3.6.3 /usr/local/opt/maven && \
    mkdir -p ~/.gradle && \
    echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties && \
    echo "android.builder.sdkDownload=false" >> ~/.gradle/gradle.properties && \
    echo "androidNdkVersion=$ndkVersion" >> ~/.gradle/gradle.properties && \
    wget 'https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz' -P /tmp && \
    tar xf /tmp/gcc-arm-*.tar.xz -C /usr/local/opt && \
    ln -s /usr/local/opt/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf /usr/local/opt/gcc-arm
