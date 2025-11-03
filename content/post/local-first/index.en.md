+++
title = "Local-First - Collaboration + Ownership, The Next Generation Software Development Paradigm"
date = 2025-11-03T13:52:10+10:00
categories = ["insight"]
tags = ["local-first", "heptabase"]
draft = false
showToc = true
summary = ""
+++

{{< figure
  src="/post/local-first/cover.jpg"
  alt="Cover image"
  caption="Streets of Melbourne. Photo by author"
>}}

I came across an article published in 2019 by independent research lab [Ink & Switch](https://www.inkandswitch.com/) titled "[Local-first software: You own your data, in spite of the cloud](https://www.inkandswitch.com/essay/local-first/)". After reading it, I was deeply moved and inspired. Here I'll share a brief summary and my thoughts.

Looking at the modern software ecosystem, you'll notice it's completely different from ten years ago. Instead of applications installed on your computer, more and more software is delivered as web services. Most of our computer time is now spent inside a browser.

Over the past decade or so, the software industry has undergone a paradigm shift—from traditional desktop software to web services. This brought better cross-platform support, instant access without installation, and seamless cross-device experiences. Most importantly, it made **real-time multi-user collaboration** possible.

Iconic examples include how Microsoft Word, PowerPoint, and Adobe Illustrator are gradually being replaced by Google Docs, Canvas, and Figma. These services support real-time collaboration, saving the mental overhead of emailing files back and forth. More importantly, they allow multiple people to edit simultaneously without conflicts.

However, the shift from desktop software to web services has also introduced the following problems:

1. **Speed**: Every operation needs to interact with a remote data center. Even checking a box requires waiting for network latency.

2. **Network dependency**: Whether it's your data or the software that manipulates it, the only "source of truth" is stored in a remote data center. When you lose network connection or the server goes down, you can't continue working.

3. **Loss of ownership**: You no longer **own** your files—you just have credentials that **grant access** to them, and the service provider can revoke that access at any time.

Here's an insightful summary from the article:

> The cloud gives us collaboration, but old-fashioned apps give us ownership. Can't we have the best of both worlds?

Software that achieves this is what the article proposes as **local-first software**.

## Seven Ideals of Local-First

The article defines local-first as: prioritizing local storage and local networks, giving users complete ownership while still enjoying the user experience of cloud services.

It proposes seven specific ideals:

1. **Speed**: Your data is on your device, all operations complete instantly, syncing with other devices in the background.

2. **Multi-device**: Your data should be accessible and editable across multiple devices.

3. **Offline functionality**: When the network is unavailable, you should still have full access to single-device functionality.

4. **Real-time collaboration**: Ability to work simultaneously with others while avoiding or resolving conflicts.

5. **Longevity**: If the company goes out of business, can users still open their data? After 100 years, will this data still be readable?

6. **Security and privacy**: User data should default to existing only on the user's own devices, avoiding the surveillance, hacking, and data misuse issues that come with centralized servers.

7. **Ownership**: Do you fully own your data? If your account is suspended by the company or a court, can you still use it?

Below is an excerpt from the article's evaluation of existing software, services, and technologies against these seven ideals:

✓ Good — Partial ✗ Bad

|  | Speed | Multi-device | Offline | Collaboration | Longevity | Privacy | Ownership |
|---|---|---|---|---|---|---|---|
| Files + email attachments | ✓ | — | ✓ | ✗ | ✓ | — | ✓ |
| Files + cloud sync | ✓ | — | — | ✗ | ✓ | — | ✓ |
| Google Docs | — | ✓ | — | ✓ | — | ✗ | — |
| Web apps | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| Most mobile apps | ✓ | — | ✓ | ✗ | — | ✗ | ✗ |
| Git+GitHub | ✓ | — | ✓ | — | ✓ | — | ✓ |

- **Files + email / cloud sync**: Actually works quite well. You have complete file ownership and smooth operation on your own computer. The only issue is that when collaborating with others, you need to send files back and forth and constantly rename them (`report_1.docs`, `report_2.docx`, `report_final_4.docx`).\
   Cloud sync somewhat solves the file-sending hassle, but when the same file is modified in two places simultaneously, resolving conflicts becomes very difficult.

- **Google Docs / typical web apps**: Cross-device usage and multi-user collaboration are possible, but without internet, you can't do anything. You also need to worry about losing your work due to account suspension or other reasons.

- **Most mobile apps**: Although they're programs downloaded to your phone, most features rely on server functionality. Without internet, you can't even open videos you posted yourself.

- **Git+GitHub**: Git is the go-to tool for managing code versions and multi-user collaboration in the software industry. It perfectly meets the needs of software development. However, it's primarily designed for plain text files (code) and has a steep learning curve for everyday use by ordinary people.

   But its design—especially how each endpoint has complete data and how it uses edit history for conflict comparison and recovery—is very worth learning from.

What technology can meet all seven of these conditions? In the article, the lab team discovered a promising foundational technology: [Conflict-free Replicated Data Types (CRDTs)](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type).

## Understanding CRDTs

CRDTs were proposed in 2011 in a [computer science journal](https://pages.lip6.fr/Marc.Shapiro/papers/RR-7687.pdf). It's a data structure that enables multiple computers to collaborate while automatically resolving conflicts. CRDTs don't just store the final state of data—they also preserve the complete change history, and by replaying the history, you can arrive at the same final state.

Taking text editing as an example, suppose the original string is:

```plain
1234567890
```

A inserts a 0 after 3:

```plain
1230456789
```

B (from the original string) removes 8:

```plain
12345679
```

When the computer tries to merge these two operations, it finds that none of the characters after 123 match up. Traditionally, we'd use more advanced string comparison algorithms to resolve this, but if we know the modification history, we just need to apply each change to get the conflict-resolved result:

```plain
123456789   -> original string
1230456789  -> insert 0 after 3
123045679   -> remove 8
```

If there's a conflict that truly can't be automatically resolved, CRDTs can also provide more accurate and localized comparison information for the application or user to resolve.

This simple case might not show the value clearly, but anyone who has used cloud file sync knows how troublesome and tricky it is when two computers modify the same file. Comparison based solely on results is difficult, which is why simple file/state synchronization can't implement local-first.

Therefore, with CRDTs as the foundation, we can solve cross-device data conflict issues and develop systems that can both operate offline and collaborate with others.

## Case Study: Heptabase

{{< figure src="/post/local-first/heptabase.webp" alt="Heptabase Screenshot" caption="Heptabase product screenshot, from official website" >}}

[Heptabase](https://heptabase.com/) is a subscription-based note-taking and knowledge base software founded by Taiwanese, dedicated to helping **anyone make sense of complex topics**. I've been using it for a year and a half and absolutely love it. It has profoundly changed how I learn and helped me build a more sustainable and deep knowledge system.

What I enjoy most about using Heptabase is its smooth user experience—each device can operate independently, cross-device syncing doesn't create conflicts, and this year they added real-time multi-user collaboration.

I used to use Notion but couldn't stand the long loading times every time I opened it. Later I returned to the embrace of plain text markdown, syncing markdown files with Nextcloud. However, the tree structure of computer files isn't suitable for building complex knowledge systems. It wasn't until I discovered Heptabase that I found a tool that truly fit my needs.

It was also while researching how to develop such systems, using Heptabase's architecture as a prototype, that I discovered the local-first concept. I'm not sure if this was one of their original design philosophies, but in my experience using it, it satisfies many of these ideals.

Below I evaluate Heptabase using the seven local-first ideals:

✓ Good — Partial ✗ Bad

1. ✓ **Speed**: Complete data locally, opens immediately (under 2 seconds)

2. ✓ **Multi-device**: Works across computers, phones, tablets, and web

3. ✓ **Offline functionality**: Still able to fully access and modify all data offline, including writing cards and editing whiteboards

4. ✓ **Real-time collaboration**: Supports simultaneous editing of the same whiteboard with others

5. — **Longevity**: Heptabase is proprietary subscription software—you can't use it without paying. However, data is backed up daily on your own device in markdown and JSON formats, so it can still be parsed with other software.

6. — **Security and privacy**: Heptabase maintains a copy of your data on servers to facilitate syncing, and currently doesn't offer end-to-end encryption.~~Users can choose not to enable syncing, but then can't enjoy cross-device functionality.~~ This option was removed in a [recent update (v1.75.8)](https://wiki.heptabase.com/changelog).

7. — **Ownership**: Users have all data in markdown and JSON, but without the Heptabase software itself, it's not as easy to use—though technically it can be parsed yourself.

Overall, Heptabase demonstrates how local-first architecture can be implemented in a product with excellent user experience and make it one of the product's core selling points.

## The Coming of the Next Era

The internet went from one-way transmission in web1 to user-generated content in web2, and now to the web3 movement that returns ownership to users. However, application development still predominantly uses server-centric web apps.

The local-first and CRDTs architecture can add multi-user collaboration and cross-device functionality while preserving user sovereignty. Whether it's family photo albums, notes, expense tracking, or fitness logs, everything can be collaborated on with others in a more private and secure way. Such applications are like **app3**—they will be the application development paradigm of the future generation.

## References

* Martin Kleppmann, Adam Wiggins, Peter van Hardenberg, Mark McGranaghan. (April 2019). Local-first software. You own your data, in spite of the cloud. *Ink & Switch*. https://www.inkandswitch.com/essay/local-first/
* Marc Shapiro, Nuno Preguiça, Carlos Baquero, Marek Zawirski. (2011). Conflict-free Replicated Data Types. *French Institute for Research in Computer Science and Automation*. https://pages.lip6.fr/Marc.Shapiro/papers/RR-7687.pdf
