---
title: "OMSCS Part 3: First Semester Experience and AOS"
date: 2026-01-19
description: "How OMSCS works and my experience with Advanced Operating Systems"
tags: ["OMSCS", "Georgia Tech", "Computer Science", "Education", "Master's degree", "Operating Systems", "Distributed Systems"]
categories: ["Education"]
series: ["OMSCS"]
---

*[Part 1: Program Overview](/posts/omscs-part-1/) | [Part 2: Admission Experience](/posts/omscs-part-2/)*

Welcome back! In this post I'll cover how the program is organized and talk about my first course - Advanced Operating Systems. I'm a massive procrastinator, so I've accumulated quite a bit of material. Originally I wanted to cover all the courses I've taken so far in one post, but realized it would be way too long. I'll write about 3 more courses in the next one.

## How the Program Works

### Onboarding After Admission

All new students are automatically enrolled in a mini-course where the program director Dr. Joyner briefly explains everything: what's expected from students, how the learning process works, what's important to know from the start. So if you get in, you'll definitely understand what's expected of you.

### Course Registration and Time Tickets

Next comes what might be the trickiest part - course registration.

OMSCS students use the same system as all other Georgia Tech students, but not all courses are available to OMSCS. You can only register for courses once your **Time Ticket** time arrives. Registration is split into phases - there are 2 in total. New students can only register in the second phase, when most seats are already taken. The Time Ticket times are pretty convenient for EET timezone, so you won't have to wake up in the middle of the night to register.

These Time Tickets are assigned automatically, and the time depends on how many courses a student has already completed. The longer you've been studying, the better your chances of getting into a course - assuming you don't miss your Time Ticket window.

### Seats, Waitlists, and FFF

Most courses have limited seats, but there are a few courses with unlimited capacity, so the situation where you can't register for anything at all is practically impossible.

Some seats are reserved for the **waitlist**. If you couldn't register for a course directly, you can add yourself to this queue. The first person in line gets limited time to use their opportunity to register. If they don't take it, the opportunity passes to the next person.

Before classes start there's "Free For All Friday", now called "Free For All !Friday" because it actually happens on Thursday. During FFAF all reservations are lifted, and you can often snag a spot bypassing the waitlist.

Because of this system, it's entirely possible you won't get into the course you want in your first semester because all seats are taken. You need to be prepared for this and have a plan B.

There's one course that's nearly impossible to get into unless it's one of your last semesters: **Intro to Graduate Algorithms**. This happens because this course is required for graduation, and almost all seats are reserved for "graduating" students. Although I've heard stories of people getting in during their first semester through FFAF.

### Canvas, Ed Discussion, Lectures, and Assignments

A bit about how the learning process is organized.

You're added to the course in **Canvas** and to the forum on **Ed Discussion**. Lectures are often all available at once and are located in Canvas and/or Ed. There's also always a separate reading list of recommended papers on the topic.

**Ed Discussion** is where most communication between instructors and students happens, as well as collaboration between students. I've seen many times how students posted questions and got explanations from both Teaching Assistants and other students. If you prefer live interaction, there are weekly office hours where you can talk to the professor and TAs. They're not always at convenient times, but they're recorded so you can watch them later. To be honest, I never really used this and never attended, only watched the first one in my first semester. The point is that the situation where you're completely lost with nowhere to get help is very unlikely. With some effort and time investment, you can get much more out of a course than just watched lectures.

At the beginning of the semester there's always a post where everyone introduces themselves - it's a good way to grow your LinkedIn network with people from around the world. From my experience, most students are from English-speaking countries, mostly the US (what a surprise).

Availability of labs/assignments depends on the course, but usually they open gradually throughout the semester.

The number of exams depends on the course, but often there are two: **midterm** and **final**.

Deadlines are taken seriously: some instructors don't accept late submissions at all, while others give a short extension with a possible point penalty.

A bit before mid-semester comes the withdrawal deadline. Before this time you can drop a course, and there won't even be a record in your transcript that you took it. After this date, if you leave the course, you'll have a W in your transcript.

### Academic Integrity

What was unusual for me is that they take academic integrity VERY seriously here. They constantly emphasize this and actually monitor it.

I've witnessed situations where people got caught taking labs from the internet or generating them with LLMs. With LLMs, the problem isn't that it's obvious the code was generated, but that the LLM generated code based on what was available online, and they caught people specifically for plagiarism. The sanctions look roughly like this:

- 1st violation: 0 on the assignment/exam, inability to receive an A for the course, and inability to drop the course
- 2nd violation: removed from the course
- 3rd violation: expelled from the program

It might seem strange - why is the inability to drop a course even a punishment? The logic is that this way a student can't just exit the course right after a sanction and "reset" the consequences. Otherwise, the first violation would cost almost nothing - at most you'd have to take another semester to catch up.

This approach has its pros and cons. The obvious pro is that it increases the diploma's value, since most students actually completed the program rather than cheating their way through it. The con is that the same assignment, which might be quite limited and specific, is given to a large number of people over several years. I like to overthink things, and my concern here is that, as I understand it, there's always a chance that someone's thought process and problem-solving style will overlap with yours, so there's a chance of false positive plagiarism detection. Fortunately, this hasn't happened to me, but if you go to the subreddit, you'll see plenty of posts where people swear they were falsely accused of plagiarism.

Despite the above, the situation isn't that bad because there's always a review process where students are given the chance to prove their innocence.

### How Exams Work (Proctoring)

Exams are organized similarly to IELTS.

Usually you have a week or, for example, Friday plus the weekend to complete an exam. So you can choose a convenient time for yourself. The exam must be taken in a quiet room alone.

For closed-notes exams, before starting you need to scan the room to show that you're really alone and that there's nothing in the room that could help you. You also need to scan your passport so another person can't take the exam for you.

During the exam, audio from your microphone, video from your camera, and your screen are recorded. Usually no one is watching you live, but the system flags suspicious moments that an instructor might review later. The exam itself can last 2.5 hours, which is an incredible challenge for fans of short funny videos on the internet.

## The Actual Learning

### Fall 2024 - Advanced Operating Systems (AOS)

I got lucky and registered for the course I wanted. I chose **Advanced Operating Systems** because:

1. I'd like to think I know my way around operating systems, and this is an easy way to get into the groove through a topic I'm already familiar with.
2. Usually many people take this course after Graduate Introduction to Operating Systems, so relatively few new students compete for seats in AOS.

You might think this course is about operating systems, but that's only partially true) I'd call it Introduction to Distributed Systems. Here's what's actually covered:

The course starts with a short refresher on basic things - what an OS is, how virtual memory works, cache, multithreading, and so on. Basically everything that's taught in OS during undergrad. After that came a homework where you had to answer several questions, and a simple C multithreading lab so people could understand if they're even ready for this course. The questions are mostly basic, like:

> Explain all the actions from the time a process incurs a page fault to the time it resumes execution. Assume that this is the only runnable process in the entire system.

but there were also interesting ones, like:

> Explain page coloring and how it may be used in memory management by an operating system.

The concept of `page coloring` was new to me. Turns out the only more-or-less active kernel that uses it is FreeBSD.

Next is the first serious topic - **OS Structures**. Here they examine three approaches to kernel structure: [SPIN](https://www.cs.cornell.edu/people/egs/papers/spin-sigops94.pdf), [Exokernel](https://pdos.csail.mit.edu/6.828/2008/readings/engler95exokernel.pdf), and [L3 Microkernel](https://www.cse.iitd.ac.in/~sbansal/os/previous_years/2014/bib/liedtke95micro.pdf). Generally quite interesting, especially considering that microkernel architecture is still alive and used in QNX, which is one of the main choices when you need an RTOS. There was also a very instructive story about how optimization affects software: until a certain point, microkernels were considered slow because in [Mach](https://www.cs.cmu.edu/afs/cs/project/mach/public/www/mach.html) from Carnegie Mellon, border crossing took about 900 CPU cycles. But at some point Liedtke took on the challenge and optimized it in his L3 OS down to 123 cycles. Even though Mach was written by far from stupid people. After that, microkernels were no longer considered slow)

Next topic - **Virtualization**. This covers CPU, Memory, and Device Virtualization. Full Virtualization ([VMware](https://www.usenix.org/legacy/event/osdi02/tech/full_papers/waldspurger/waldspurger.pdf)) and Paravirtualization ([Xen](https://www.cl.cam.ac.uk/research/srg/netos/papers/2003-xensosp.pdf)) are compared. This module has the first C lab using libvirt. It consists of 2 parts: vCPU scheduler and memory coordinator for guest OSes. I really liked this lab because there's no obvious best deterministic solution. You need to come up with a heuristic so the solution works well enough across several different scenarios.

After that - **Parallel Systems**, the largest module in the course. There's a lot here. It starts with Symmetric Multiprocessor (SMP) and how memory consistency and cache coherence are implemented. Then various possible ways to implement spinlocks and barriers on UMA and NUMA. Next subtopic is implementation and optimization of [Remote Procedure Call (RPC)](https://people.eecs.berkeley.edu/~prabal/resources/osprelim/BAL%2B90.pdf), followed by various scheduling approaches. This large topic concludes with a discussion of how to optimize an OS specifically for Shared Memory Multiprocessor with a large number of CPUs using [Tornado](https://www.usenix.org/legacy/events/osdi99/full_papers/gamsa/gamsa.pdf) as an example. The main idea is to minimize the number of global objects in the kernel protected by a mutex, replacing them with local replicas.

Next is **Distributed Systems**. You can't talk about this without mentioning Lamport. This is the person who invented LaTeX, Paxos, TLA+ and received the Turing Award in 2013 for contributions to distributed computing. His paper ["Time, Clocks, and the Ordering of Events in a Distributed System"](https://lamport.azurewebsites.net/pubs/time-clocks.pdf) from 1978 is the foundation of this entire module. The main idea: in a distributed system there's no global time, so you need another way to determine what happened before and what happened after. Hence the *happened-before* relationship and logical clocks. All of this exists to achieve distributed consensus. As a bonus, they also cover distributed mutual exclusion. Fun fact: Lamport's algorithm for this requires at least 3(N-1) messages per lock, where N is the number of processes. After this, they talk about [Active Networks](https://www.cs.princeton.edu/courses/archive/fall04/cos461/papers/active_network_arch.pdf), a concept from the 90s where routers don't just forward packets but can execute code. The 90s were a long time ago, but Active Networks can be considered one of the conceptual predecessors of SDN, although architecturally they differ significantly. Nowadays almost everything is Software Defined, even cars.

These two topics have a corresponding second lab. In it you need to implement several SMP barriers using OpenMP and several Distributed Memory barriers using MPI. All of this needs to be benchmarked, and you write a report explaining the results. The cool thing about this lab is that you get access to PACE - Georgia Tech's cluster, where you run jobs on multiple machines inside the cluster through [SLURM](https://slurm.schedmd.com/overview.html).

Then some archaeology called **Distributed Objects and Middleware**: Spring OS (not to be confused with Spring Framework), Java RMI, Enterprise JavaBeans. Not a very useful module in my opinion, since all of this is already dead.

After that - **Distributed Subsystems**, applications of distributed systems. There are 3 submodules here. The first is about [Global Memory Systems](https://pages.cs.wisc.edu/~remzi/Classes/739/Spring2004/Papers/gms.pdf). In short, the idea is to swap not to local storage but to RAM of another machine connected via LAN. As you can tell, this was invented long before SSDs. You might think this is a long-dead idea, but I looked it up, and this idea became the foundation for [disaggregated memory](https://arxiv.org/pdf/2305.03943), which is now used in HPC clusters. The next submodule is called [Distributed Shared Memory](https://ocw.mit.edu/courses/6-824-distributed-computer-systems-engineering-spring-2006/1e9343e624755efb0d5cbecb5abfb19a_treadmarks.pdf), about how you can implicitly present physical memory on different nodes as a single logical address space to a program, hiding explicit communication. The pros are obvious, I think. The cons - you can hang on a memory access waiting for memory from the other end of the cluster. And the last submodule is about implementing a distributed filesystem.

Around this point you had to do the third lab. In it you need to implement something like a store using gRPC with a threadpool. Generally an interesting lab that's essentially preparation for the final lab. Also interesting: at the time I was working on it, the latest gRPC versions weren't supported, so asynchronous communication couldn't be implemented through callbacks, which meant I had to use [CompletionQueue](https://grpc.io/grpc/cpp/classgrpc_1_1_completion_queue.html). And the approach here is quite interesting. Each operation has a `void*` tag. In this tag you usually need to pass some dynamically created object via `new`, so in subsequent operations you can access it by the tag as a pointer, because you usually need to store some information associated with this chain of calls. It ends up being a state machine with manual memory management.

Next is **Failures and Recovery**: [LRVM](https://people.eecs.berkeley.edu/~prabal/teaching/resources/eecs582/satya93lrvm.pdf), [RioVista](https://web.eecs.umich.edu/virtual/papers/lowell97.pdf), [QuickSilver](https://people.eecs.berkeley.edu/~prabal/resources/osprelim/HMS%2B88.pdf). This module is about how to do transactions and recovery of virtual memory at the OS level with relatively low overhead.

After that - **Internet Scale Computing**, split into 3 submodules. The first is general, about how to manage resources of a large service and about replication vs partitioning. The second module is about Google's legendary [MapReduce](https://research.google/pubs/mapreduce-simplified-data-processing-on-large-clusters/). I don't know what to add here, so if you don't know what it is, better look it up. The third submodule is about Content Delivery Networks (CDN) using [Coral DHT](https://www.cs.cmu.edu/~srini/15-744/S08/papers/coral-nsdi04.pdf). This is also a very cool and still relevant technology that's actively used by, for example, streaming services.

This module has a corresponding final fourth lab. In it you need to implement a simplified version of MapReduce based on gRPC. The simplification is that workers run on a single host and can use a shared filesystem. The original MapReduce implementation uses [Google File System (GFS)](https://research.google/pubs/the-google-file-system/), which is itself a great example of software engineering.

Then a brief return to operating systems called **Real-Time and Multimedia**. In this module they examine [TS-Linux](https://www.usenix.org/legacy/event/osdi02/tech/full_papers/goel/goel.pdf) and Persistent Temporal Streams, but in practice most of the topic comes down to ideas for implementing real-time scheduling.

And finally some **Security** - [Saltzer and Schroeder's design principles](http://web.mit.edu/Saltzer/www/publications/protection/) and [Andrew File System](https://www.andrew.cmu.edu/course/15-440/assets/READINGS/howard1988-tocs.pdf).

That's it for the lectures. A couple words about tests. The course has 3 closed-notes tests: Test 1 (Lessons 1-4), Test 2 (Lessons 5-7), Test 3/Final (Lessons 8-11). Each test has a 3-day window (Friday + weekend). The interesting part is that on Friday they reveal 80% of the questions, so if you want, you can prepare well.

A special feature of the course is a reading list of ~30 academic papers. Reading everything isn't required, but you need to write summaries for two papers. Personally I only read 3: MapReduce - because I needed it for the lab, and 2 for summaries:

1. [Using Processor-Cache Affinity Information in Shared-Memory Multiprocessor Scheduling](https://www.computer.org/csdl/journal/td/1993/02/l0131/13rRUwhHcQq) (1993) - the title speaks for itself)
2. [The Multikernel: A New OS Architecture for Scalable Multicore Systems](https://www.sigops.org/s/conferences/sosp/2009/papers/baumann-sosp09.pdf) (2009). This one is more interesting. It describes an actually existing OS called [Barrelfish](https://barrelfish.org/), developed at ETH Zürich, whose idea is to be able to work on heterogeneous cores. Imagine: you have a cluster with x86, ARM, and RISC-V, and you run a single OS on top of it.

What can I say about this course. I found it interesting, and I think that's what matters most) The labs were especially interesting for me. If you want to watch the lectures, they're freely available online. The cons I can point out are covering outdated technologies, but as they say, a university is not a trade school. Sometimes it's useful to look at things from a purely academic/theoretical perspective, especially considering how some technologies can get a second life - like how Global Memory Systems was reborn as disaggregated memory with the demand for LLM training.

I really wanted to get an A because it gives access to the course Systems Design for Cloud Computing (SDCC). SDCC is a logical continuation of AOS, with the same professor. The main topic of this course is implementing MapReduce, but in full form. In the end I got an A, but I still haven't taken SDCC because it requires attending meetings that are held at night Kyiv time. It's the only course I know of in OMSCS that isn't fully asynchronous.

## Summary

The first semester turned out to be intense. AOS was a good choice for starting - challenging enough to be interesting, but not so much that it would be impossible alongside a full-time job. On [OMSCentral](https://www.omscentral.com/courses/advanced-operating-systems/reviews), AOS is rated by students at an average difficulty of 4/5.

Because I'm really bad at time management, I kept putting everything off until the last moment. Since test deadlines were around 8 AM Monday, I took tests several times at 1 AM fueled by massive doses of caffeine. The situation with labs was roughly the same. I want to note that this isn't because the workload is extraordinarily heavy, but purely due to my inability to manage time (there were weeks when I did nothing at all for studying). So if you consistently do something several times a week without long breaks, you'll have no problems combining it with a full-time job.

## What's Next?

In the next part I'll talk about three more courses: Software Analysis and Testing, High Performance Computing, and High Performance Computer Architecture. Stay tuned! Hopefully the gap between parts will be less than a year this time)
