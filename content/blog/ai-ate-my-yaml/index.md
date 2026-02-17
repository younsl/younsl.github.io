---
title: "ai ate my yaml"
date: 2026-01-16T23:00:00+09:00
lastmod: 2026-01-16T23:00:00+09:00
description: "Honest reflections on job market decline and career strategies for DevOps Engineers in the AI era"
tags: ["career", "devops", "ai"]
---

![People waiting in line](./1.jpg)

<small>Photo by [The New York Public Library](https://unsplash.com/ko/%EC%82%AC%EC%A7%84/%EC%A4%84%EC%9D%84-%EC%84%A0-%EC%82%AC%EB%9E%8C%EB%93%A4%EC%9D%98-%ED%9A%8C%EC%83%89%EC%A1%B0-%EC%82%AC%EC%A7%84-Q0_u7YwXqh0) on Unsplash</small>

## Overview

I used to mass-produce Kubernetes manifests all day. Mass producing of YAML was my job security. Then one day, a developer typed a single prompt into Claude and got a perfect Deployment with HPA, PDB, and anti-affinity rules in 10 seconds.

That YAML took me 30 minutes to write. AI ate it in 10 seconds.

This isn't a sci-fi story. It's happening right now. This post is an honest look at what's changing for DevOps Engineers and how to stay relevant when AI is coming for your manifests.

## Facing Reality

### DevOps Tasks AI Is Already Replacing

Let's be honest. AI is already performing a significant portion of DevOps work faster and more accurately than humans.

| Task Area | AI Replacement Risk | Current Status |
|-----------|---------------------|----------------|
| YAML/Manifest Writing | High | Copilot, Claude instantly generate Kubernetes manifests, Terraform HCL |
| Troubleshooting | Medium-High | AI analyzes error logs and suggests solutions |
| Documentation | High | Auto-generates Runbooks and READMEs |
| Monitoring Setup | Medium | Generates Prometheus rules, Grafana dashboard JSON |
| CI/CD Pipelines | Medium | Auto-writes GitHub Actions, GitLab CI workflows |
| Security Scanning | Medium-High | Analyzes vulnerabilities and suggests fix code |

```bash
# This used to take 30 minutes
kubectl get pods -o yaml > pod.yaml
vim pod.yaml  # manual editing

# Now it's just one prompt to AI
"Create a Kubernetes deployment with 3 replicas,
resource limits, liveness probe, and anti-affinity rules"
```

### Reality in Numbers

- **Job Postings Decline**: Job postings dropped to 72% of their mid-2022 peak by April 2024 [1]
- **Team Size Reduction**: Over 60% of DevOps teams reduced release times with AI tools, operating with fewer people [2]
- **Entry-Level Hiring Down**: Entry-level tech hiring decreased 25% year-over-year in 2024 [3]

This is reality. Denying or avoiding it won't change anything.

[1]: https://newsletter.pragmaticengineer.com/p/state-of-the-tech-market-in-2025 "The Pragmatic Engineer - State of the Tech Market 2025"
[2]: https://about.gitlab.com/topics/devops/the-role-of-ai-in-devops/ "GitLab - The Role of AI in DevOps"
[3]: https://www.cio.com/article/4062024/demand-for-junior-developers-softens-as-ai-takes-over.html "CIO - Demand for junior developers softens as AI takes over"

### It's Not Just DevOps

This isn't a DevOps-only phenomenon. It's hitting software engineers across the board. US programmer employment dropped 27.5% between 2023 and 2025 [6]. Big Tech entry-level hiring fell 25% year-over-year [7].

Juniors are hit the hardest. According to the Federal Reserve Bank of New York, CS grads now have a 6.1% unemployment rate—higher than philosophy majors (3.2%) [8]. 70% of hiring managers believe AI can do intern-level work, and 57% trust AI output more than junior developers' work [7].

[8]: https://www.entrepreneur.com/business-news/college-majors-with-the-lowest-unemployment-rates-report/491781 "Entrepreneur - College Majors With the Lowest Unemployment Rates"

Seniors are relatively safer. "AI doesn't make the tough calls on architecture, compliance, or security."

[6]: https://www.understandingai.org/p/new-evidence-strongly-suggest-ai "Understanding AI - New evidence strongly suggests AI is killing jobs"
[7]: https://spectrum.ieee.org/ai-effect-entry-level-jobs "IEEE Spectrum - AI Shifts Expectations for Entry Level Jobs"

## Areas AI Struggles to Replace

That said, not everything is being replaced. There are clear areas where AI still falls short.

### 1. Architecture Decision-Making

```
"Should this service use EKS or ECS?"
```

AI can list the pros and cons of both services, but it cannot make holistic decisions considering your team's capabilities, existing infrastructure, cost structure, security requirements, migration costs, and 3-year expansion plans.

### 2. Judgment in Incident Response

It's Friday at 6 PM, and an unknown incident occurs in production.

- Rollback immediately or push a hotfix?
- When and how to notify stakeholders?
- What's the business impact?
- How to isolate the blast radius?

Quick judgment and communication in these situations remain a human domain.

### 3. Cross-Team Collaboration and Persuasion

```
Dev Team: "The deployment pipeline is too slow, speed it up"
Security Team: "We need to add vulnerability scanning steps"
Management: "Cut infrastructure costs by 30%"
```

Satisfying all three requirements simultaneously while persuading each team and finding common ground—this is a uniquely human capability that AI cannot replace.

### 4. Understanding Legacy Systems

Undocumented Jenkins pipelines from 2015, Ansible scripts written by someone who left the company, 10-year-old on-premises systems. AI is powerless without context. Understanding organizational history and tacit knowledge remains a competitive advantage.

## Career Strategy

### Short-Term Strategy (1-2 Years)

**1. Embrace AI as a Tool**

Accept AI as a tool, not a competitor. Integrate Claude, ChatGPT, and GitHub Copilot into your daily work.

Even Linus Torvalds, known for his uncompromising stance on code quality, has shifted his perspective. In 2024, he dismissed 90% of AI as hype and refused to let AI touch the Linux kernel. But by January 2026, he released [AudioNoise](https://github.com/torvalds/AudioNoise) on GitHub, openly acknowledging AI assistance for the Python visualizer portion [4]. At Open Source Summit Korea 2025, he stated that while "vibe coding" may be horrible for maintenance, it's a great way for new people to get excited about computers [5].

[4]: https://itsfoss.com/news/linus-torvalds-vibe-coding/ "It's FOSS - Even Linux Creator Linus Torvalds is Using AI to Code"
[5]: https://www.techradar.com/pro/even-ai-skeptic-linus-torvalds-is-getting-involved-in-vibe-coding-so-could-this-herald-a-new-dawn-for-linux-probably-not "TechRadar - Linus Torvalds quietly used AI coding"

New workflow with AI:

1. Generate drafts with AI (Terraform, YAML, Scripts)
2. Human reviews and adds context
3. Generate test cases with AI
4. Human decides on production deployment

One DevOps Engineer who uses AI well is more productive than three who don't.

**2. From T-Shaped to Pi-Shaped**

```
Traditional T-Shape:
        DevOps (deep)
           |
-----------+-----------
Broad tech knowledge (shallow)

New Pi-Shape:
    DevOps    +    Business Domain
       |               |
-------+---------------+-------
      Broad tech knowledge
```

DevOps skills alone aren't enough. Go deep into one of FinOps, Security, Data Engineering, or business domain knowledge.

**3. Strengthen Communication Skills**

The value of coding ability is declining, but the value of these skills is rising:

- Explaining technical decisions to non-developers
- Coordinating interests across multiple teams
- Communicating calmly during incidents

### Mid-to-Long-Term Strategy (3-5 Years)

**1. Expand into Platform Engineering**

DevOps automated repetitive ops tasks through CI/CD pipelines, IaC, and configuration management. Platform Engineering takes this further by productizing that automation—treating internal tools as products with developers as customers. It requires deep understanding of organizational workflows, team dynamics, and developer pain points—context that AI cannot acquire on its own. Building Internal Developer Platforms (IDP) and improving Developer Experience (DX) are roles AI struggles to replace.

```
DevOps Engineer
      ↓
Platform Engineer
      ↓
- Build IDPs like Backstage, Port
- Design Golden Paths
- Define developer productivity metrics
- Operate self-service platforms
```

**2. AI/ML Infrastructure Specialist**

While AI is replacing many jobs, paradoxically, more people are needed to operate AI infrastructure.

- GPU cluster operations (NVIDIA GPU Operator, MIG)
- ML pipeline infrastructure (Kubeflow, MLflow, Ray)
- LLM serving infrastructure (vLLM, TensorRT-LLM)
- Vector DB operations (Milvus, Pinecone, Weaviate)

**3. Deepen SRE Expertise**

Evolve from simple operations to designing system reliability.

- Design and execute Chaos Engineering
- Build SLO/SLI-based decision frameworks
- Design large-scale distributed system architectures
- Find the balance between cost optimization and performance

## Practical Advice

### Anxiety Is Natural

Honestly, I'm anxious too. I'm constantly coding in collaboration with AI (Claude Opus 4.5 + Thinking Mode), but I seriously wonder if I'll still be doing this job in five years.

It builds Grafana dashboards effortlessly, and even the really complex Helm chart configuration issues I occasionally encounter get solved after just a few exchanges. Looking at AWS laying off hundreds of employees from its sales, marketing, and global services teams in 2025 [9], no one is safe anymore.

Five years ago, writing Kubernetes YAML well was a competitive advantage. Now AI does it better. But if you're consumed by anxiety, you can't adapt to change.

[9]: https://www.cnbc.com/2025/07/17/amazon-web-services-has-some-layoffs.html "CNBC - Amazon cuts some jobs in cloud computing unit as layoffs continue"

### Things You Can Do Right Now

Actions you can take starting today:

- [ ] Actively adopt AI tools (Claude, Copilot) in your work
- [ ] Document one technical decision this week
- [ ] Keep communication logs during the next incident response
- [ ] Deep dive into one business domain knowledge area in your current team
- [ ] Read one article about Platform Engineering

### Pitfalls to Avoid

1. **Complacency thinking "AI has limitations, I'll be fine"**: Don't underestimate AI's pace of advancement.
2. **Collecting certifications**: Even with CKA and AWS SA Pro, AI knows more. Real problem-solving experience matters more than certifications.
3. **Chasing new tools only**: ArgoCD, Flux, Crossplane... Learning new tools is important, but fundamental problem-solving ability matters more.
4. **Struggling alone**: Join communities and talk with people who share the same concerns.

## Conclusion

DevOps Engineers in the AI era are undoubtedly going through difficult times. Skills that were once valuable are rapidly declining in value, and the job market is shrinking.

But this is both a crisis and an opportunity. Those who use AI as a tool while focusing on areas AI struggles to replace—architecture decision-making, organizational collaboration, business understanding, incident response judgment—will be recognized for even greater value.

In the end, it's not the strongest species that survives, but the one most adaptable to change.

> "The future belongs to those who learn more skills and combine them in creative ways."
> — Robert Greene

## References

- [Platform Engineering on Kubernetes](https://www.manning.com/books/platform-engineering-on-kubernetes)
- [The Future of DevOps in the Age of AI](https://thenewstack.io/the-future-of-devops-in-the-age-of-ai/)
- [Google SRE Books](https://sre.google/books/)
- [Thoughtworks Technology Radar](https://www.thoughtworks.com/radar)
