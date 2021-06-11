FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# Android SDK

ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/30.0.2"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"

RUN dpkg --add-architecture i386 && \
    apt-get update -yqq && \
    apt-get install -y curl expect git libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 openjdk-8-jdk wget unzip vim make && \
    apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools
COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmdline-tools;latest"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "build-tools;30.0.2"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platform-tools"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platforms;android-30"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "system-images;android-30;google_apis;x86_64"

# Proguard

WORKDIR /opt/android-sdk-linux/tools/proguard/lib

RUN wget https://github.com/Guardsquare/proguard/releases/download/v7.0.1/proguard-7.0.1.zip
RUN unzip proguard-7.0.1.zip && rm -rf proguard-7.0.1.zip
RUN rm -f *.jar
RUN mv proguard-7.0.1/lib/*.jar ./ && rm -rf proguard-7.0.1

# Android NDK

ENV NDK_HOME=/opt/android-ndk-r12b

WORKDIR /opt/

RUN curl -fsSL -o android-ndk-r12b.zip https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip
RUN unzip android-ndk-r12b.zip && rm -f android-ndk-r12b.zip

WORKDIR /
