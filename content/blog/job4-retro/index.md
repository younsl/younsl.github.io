---
title: "job4 retro"
date: 2026-01-27T00:10:00+09:00
lastmod: 2026-01-27T00:10:00+09:00
description: "A retrospective on my 2 years and 6 months as a DevOps Engineer at job4"
draft: false
keywords: []
tags: ["retrospective", "devops", "career"]
---

![Silhouette of a person walking with a laptop](1.jpg)
<small>Photo by [Sebastian Schuster](https://unsplash.com/photos/silhouette-of-a-person-walking-with-a-laptop-UsMUD005Fbk) on Unsplash</small>

## Overview

It's been almost 3 years since my [last retrospective](/blog/retrospective-2022/) in December 2022. Time flies, but memories linger with mixed emotions.

I worked as a DevOps Engineer at job4 for 2 years and 6 months, from May 2023 to December 2025.

I learned a lot and grew, but I also have regrets. Here's an honest look at what went well, what I learned, and what didn't work out.

## Duration and Background

**Period**: May 2023 - December 2025 (2 years and 6 months)

**Role**: DevOps Engineer

**What I Did**: Cloud infra, CI/CD pipelines, legacy cleanup, monitoring and logging

## The Good

### 1. Growth Through Legacy Cleanup

job4 had a lot of old systems. Fixing them taught me a lot. I analyzed problems, found solutions, and grew my skills.

Key work included: (1) moving EC2 servers to Kubernetes, (2) turning raw YAML and kubectl commands into Helm charts, and (3) refactoring messy Terraform code into clean modules.

This work let me learn new tech and apply it in real projects. I got better at solving problems and designing systems.

### 2. Stable Routine

Work was predictable. I could plan my time well and use free hours for learning.

Few surprises meant less stress. This made it easy to keep going long-term.

## Lessons Learned

### 1. Tech Debt Needs Time and People

Legacy was a chance to grow, but also my biggest pain. There was so much old code that fixes never ended. Most of my time went to keeping old systems alive, not building new things.

Tech debt kept piling up. We didn't have enough time or people to fix it. This hurt the team's output and morale.

**Lesson**: Tech debt is real. Plan time and resources to pay it down, or it will slow you down forever.

### 2. What Real MSA Looks Like

The company said we had microservices. We didn't. No service mesh. Each Ingress made its own ALB.

We ended up with 40+ ALBs to manage by hand. More complexity, no MSA benefits. Just more work.

Deployment was worse. True MSA means teams deploy on their own. But DevOps had to approve every deploy. Every week, one DevOps engineer spent 2 hours on deploys—3 hours on bad days. Services weren't independent, so wrong deploy order broke things. This broke the core MSA rules: independent deploys and loose coupling.

Without a service mesh, cluster admins burned out. Developers had to code Rate Limiting and Circuit Breaker themselves. Changing a rate limit? Redeploy the whole app. When the API Gateway hit rate limits, finding the problem was hard. A service mesh would have shown it clearly. Instead, issues were spread across services, so root cause took forever to find. The sad part? No one saw the need for better tools. When I suggested changes, I heard "We don't need that" or "That's overkill."

Routing, security, and costs were all inefficient. We talked about fixing it, but nothing changed.

**Lesson**: MSA isn't just splitting code. You need service mesh, independent deploys, and loose coupling. Without these, you get the complexity without the benefits.

### 3. Toil Kills Motivation

I often felt like a factory worker. DevOps spent all day on deploy tickets. Review, approve, run. Repeat. It was mechanical, not creative.

[Google's SRE book](https://sre.google/sre-book/eliminating-toil/) says keep toil under 50% of your time. Use the rest for automation and improvements. We failed this completely. Most time went to tickets and manual deploys. No time to fix the real problems.

Days passed processing tickets. Then weeks. My motivation dropped steadily.

**Lesson**: Automate repetitive work. If toil takes over, you lose time to improve and people lose motivation.

## The Not-So-Good

### 1. Politics Over Tech

Every company has politics. job4 had too much. Relationships mattered more than good tech choices.

People picked safe options, not best options. Certain voices always won, even with bad ideas. This killed innovation and motivation.

### 2. No Care for People

This hurt the most. The company didn't care about employees.

One example: the company merged two office floors into one to cut fixed costs. During construction, we still had to work there. Everyone had to wear dust masks while working. Noise, dust, bad air. No concern for our health or comfort. This showed how the company viewed us.

This wasn't just one case. It was the culture. Short-term savings mattered more than people. That mindset will hurt the company long-term.

## Conclusion

My 2 years and 6 months at job4 helped me grow technically. But I also learned hard lessons about culture and management.

I cleaned up legacy systems and got better at solving problems. But politics, poor treatment of employees, and endless tech debt held me back.

I learned that culture matters as much as skills. Software is built by people. Good teamwork makes all the difference. Great tools mean nothing without trust and respect.

Two months into my new job (job5), I'm impressed by how different things are. The positive contrast keeps inspiring me. All good—just don't ask about Friday rush hour in Seongsu with all the tourists.
