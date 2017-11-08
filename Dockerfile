############################################################ 
# Dockerfile to build run Android Appium tests
############################################################ 

FROM ubuntu:16.04
MAINTAINER Wimpie Nortje

# Build settings
ENV GRADLE_VER=3.3 \ 
    SDK_VER=3859397

# Environment variables 
ENV ANDROID_HOME=/opt/android-sdk-linux \
    PATH=$PATH:/opt/gradle-${GRADLE_VER}/bin \ 
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install APT packages
## 32 bit libs are for Android tools like aapt which are only available as 32b
RUN dpkg --add-architecture i386 \
 && apt-get update && apt-get install -y \
      libc6:i386 \   
      openjdk-8-jdk \
      npm \
      nodejs-legacy \
      build-essential \
      ruby-dev \
      rubygems \
      xvfb \
      git \
      unzip \
      wget \
      less \
      nano \
      netcat \
 && rm -rf /var/lib/apt/lists/*

# Install npm modules
RUN npm install -g n appium \
 && n lts

# Install ruby gems
RUN gem install --no-document \
        bundler \
        cucumber \
        geocode \
        appium_lib \
        appium_console \
        byebug \
        touch_action \
        builder

WORKDIR /opt

# Fetch Android SDK and Gradle
## Enable on DockerHub:
RUN wget --output-document=sdk-tools-linux-${SDK_VER}.zip \
          --quiet https://dl.google.com/android/repository/sdk-tools-linux-${SDK_VER}.zip && \
     wget --output-document=gradle-${GRADLE_VER}-bin.zip \
          --quiet https://services.gradle.org/distributions/gradle-${GRADLE_VER}-bin.zip
  
## Enable on local:
# COPY sdk-tools-linux-${SDK_VER}.zip gradle-${GRADLE_VER}-bin.zip ./

# Install Android SDK to /opt/android-sdk-linux
RUN mkdir $ANDROID_HOME && \
    unzip sdk-tools-linux-${SDK_VER}.zip -d $ANDROID_HOME && \
    rm sdk-tools-linux-${SDK_VER}.zip && \
    pkgs="platforms;android-17 \
          platforms;android-18 \
          platforms;android-19 \
          platforms;android-20 \
          platforms;android-21 \
          platforms;android-22 \
          platforms;android-23 \
          platforms;android-24 \
          platforms;android-25 \
          platforms;android-26 \
          build-tools;26.0.1 \
          platform-tools \
          extras;android;m2repository \
          extras;google;m2repository \
          "; \
    for p in $pkgs; do \
        echo y | $ANDROID_HOME/tools/bin/sdkmanager "$p"; \
    done

# Install Gradle to /opt/gradle-${GRADLE_VER}
RUN unzip gradle-${GRADLE_VER}-bin.zip && rm gradle-${GRADLE_VER}-bin.zip

WORKDIR /tmp
