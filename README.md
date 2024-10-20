**As of October 20, 2024, the Cobal API now requires authentication for api usages. Starting from version 0.5, Osmium will require you to set up a custom instance with an API key to continue using the service. This is because i dont want to be classified as a bad actor in the Cobal community. My goal with this project has always been to simplify file downloads on iOS devices via Cobal. For instructions on creating a custom instance, please refer to [this guide](https://github.com/imputnet/cobalt/tree/main/api).**

<img src="https://raw.githubusercontent.com/cranci1/Osmium/main/assets/Untitled.png">

<div align="center">
  
[![Build and Release IPA](https://github.com/cranci1/Osmium/actions/workflows/swift.yml/badge.svg)](https://github.com/cranci1/Osmium/actions/workflows/swift.yml)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%2014.2%2B-orange?logo=apple&logoColor=white)](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%2014.2%2B-red?logo=apple&logoColor=white)
[![Version](https://custom-icon-badges.demolab.com/github/v/release/cranci1/osmium)](https://custom-icon-badges.demolab.com/github/v/release/cranci1/osmium)
[![Commit](https://custom-icon-badges.demolab.com/github/last-commit/cranci1/Osmium)](https://custom-icon-badges.demolab.com/github/last-commit/cranci1/Osmium)

A free iOS mobile client to download publicly accessible items from various known platforms. Using the Cobalt API.

</div>

## Table of Contents

- [Compatibility](#compatibility)
- [Supported Platforms](#supported-platforms)
- [Disclaimer](#disclaimer)
- [Acknowledgements](#acknowledgements)

## Compatibility

Osmium is designed to support every device running iOS/iPadOS 14.2 or later.

> Note: The user experience may vary depending on the specific device model and its performance capabilities, and is heavily influenced by the network download speed!

## Disclaimer

As stated in the [Cobalt API Repository](https://github.com/imputnet/cobalt?tab=readme-ov-file#ethics-and-disclaimer):

```
Cobalt is NOT a piracy tool and cannot be used as such.
It can only download free, publicly accessible content.
Such content can be easily downloaded through any browser's dev tools.
```

Therefore, Osmium **is not a piracy tool** and will never be used as one.

## Supported Platforms

**Osmium** supports any platform supported by the [Cobalt API](https://github.com/imputnet/cobalt?tab=readme-ov-file#supported-services). Below is a list of supported services:

| Service                        | Video + Audio | Only Audio | Only Video | Metadata | Rich File Names |
| :----------------------------- | :-----------: | :--------: | :--------: | :------: | :-------------: |
| bilibili.com & bilibili.tv     | ✅            | ✅         | ✅         | ➖        | ➖              |
| dailymotion                    | ✅            | ✅         | ✅         | ✅        | ✅              |
| instagram posts & reels        | ✅            | ✅         | ✅         | ➖        | ➖              |
| loom                           | ✅            | ❌         | ✅         | ✅        | ➖              |
| ok video                       | ✅            | ❌         | ✅         | ✅        | ✅              |
| pinterest                      | ✅            | ✅         | ✅         | ➖        | ➖              |
| reddit                         | ✅            | ✅         | ✅         | ❌        | ❌              |
| rutube                         | ✅            | ✅         | ✅         | ✅        | ✅              |
| soundcloud                     | ➖            | ✅         | ➖         | ✅        | ✅              |
| streamable                     | ✅            | ✅         | ✅         | ➖        | ➖              |
| tiktok                         | ✅            | ✅         | ✅         | ❌        | ❌              |
| tumblr                         | ✅            | ✅         | ✅         | ➖        | ➖              |
| twitch clips                   | ✅            | ✅         | ✅         | ✅        | ✅              |
| twitter/x                      | ✅            | ✅         | ✅         | ➖        | ➖              |
| vimeo                          | ✅            | ✅         | ✅         | ✅        | ✅              |
| vine archive                   | ✅            | ✅         | ✅         | ➖        | ➖              |
| vk videos & clips              | ✅            | ❌         | ✅         | ✅        | ✅              |
| youtube videos, shorts & music | ✅            | ✅         | ✅         | ✅        | ✅              |

| Emoji   | Meaning                 |
| :-----: | :---------------------- |
| ✅      | Supported               |
| ➖      | Impossible/Unreasonable  |
| ❌      | Not Supported           |

## Acknowledgements

Osmium would not exist without the help of the **Cobalt API**. Special thanks to the developer team of the Cobalt API, [imput](https://github.com/imputnet)
