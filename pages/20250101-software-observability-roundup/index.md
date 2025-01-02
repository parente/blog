---
date: 2025-01-02
title: A Software Observability Roundup
excerpt:
    I spent some time recently catching up on my #to-read saves in Obsidian. More than a few
    of these were blog posts from 2024 about software observability. Talk of "redefining observability",
    "observability 2.0", and "try Honeycomb" had caught my eye in a few spaces,
    and so I had been hoarding links on the topic. After spending a few days immersing myself in those
    articles and branching out to others, I decided to write this bullet-form roundup.
---

I spent some time recently catching up on my `#to-read` saves in Obsidian. More than a few of these
were blog posts from 2024 about _software observability_. Talk of "redefining observability",
"observability 2.0", and "try [Honeycomb](https://honeycomb.io)" had caught my eye in a few spaces,
and so I had been hoarding links on the topic.

After spending a few days immersing myself in those articles and branching out to others, I decided
to write this bullet-form roundup:

1. for myself, as a way of solidifying my current understanding
2. in public, as a way to invite corrections and improvements (drop a [comment](#userComments) below
   or [@parente.dev on Bluesky](https://bsky.app/profile/parente.dev)!)
3. with my colleagues in mind, as a new way to approach and discuss an ever-green question:

**As our [issue space](https://www.thorn.org/research/state-of-the-issue/) changes and grows, and
[our solutions](https://www.thorn.org/solutions/) adapt and scale in response, what (else) should we
do today so that we can readily address unknown-unknowns tomorrow?**

---

# Overview

The seventeen [references](#references) I surveyed offer perspectives on observability as it
pertains both to software systems and organizations around them. They cover what observability is,
what problems it solves, how it is and should be implemented. There's alignment from the
authors on the state of affairs, learned best practices, and a direction in which the industry
should head. Shared terminology and goals are works in progress.

# Origins

-   According to control theory, _observability_ is a measure of how well internal states of a
    system can be inferred from knowledge of its external outputs.[^wikipedia2022]
-   The discipline of software engineering (distributed computing, site reliability engineering, et
    al) has not settled on a single definition. One that stays close to the control theory original
    is that _software observability_ measures how well a system's state can be understood from the
    obtained telemetry.[^wikipedia2022]
-   Metrics, logs, and traces caught on as the three kinds of telemetry required to observe a
    software system&mdash;the so-called "three pillars of observability."
    -   ... perhaps because they helped build a shared vocabulary at the 2017 Distributed Tracing
        Summit.[^bourgon2017]
    -   ... perhaps because they _do_ provide a comprehensive way for engineers to _monitor_ systems
        for _known_ problems and hint at where the issue lies.[^parker2024]
    -   ... perhaps because solutions for monitoring systems using metrics, logs, and traces are
        what vendors had to sell.[^majors2024aug]

# Problems and Limitations

-   The task of analyzing disjoint metrics, logs, and trace data falls on humans when using
    three-pillar systems designed primarily for monitoring.[^sigelman2021a]
    -   Moving beyond investigation of known-knowns is difficult without data and tooling designed
        to support correlations and experimentation.[^weakly2024oct]
    -   Use of monitoring tools leads to org reliance on the intuition of a few system experts
        resulting in cognitive costs and bus-factor risks. Low visibility slows development and
        reduces team confidence.[^majors2024jan]
    -   Using CloudWatch logs, CloudWatch metrics, and X-Ray traces together, for example, requires
        users to infer answers to questions from their mental model of the system, incomplete data,
        disparate views, and reading of code.[^tane2024dec]
-   The three-pillar data model constrains the types of questions that can be asked and answered,
    with an almost exclusive focus on engineering concerns. Even mature observability programs will
    struggle to answer questions of greater interest and value _to the business_[^parker2024], such
    as:
    -   What's the relationship between system performance and conversions, by funnel stage, broken
        down by geo, device, and intent signals?
    -   What's our cost of goods sold per request, per customer, with real-time pricing data of
        resources?
    -   How much does each marginal API request to our enterprise data endpoint cost in terms of
        availability for lower-tiered customers? Enough to justify automation work?
-   There are many sources of truth when disparate formats (metrics, logs, traces) and/or tools are
    in play, with decisions made at write-time about how the data will be used in the future.
    [^majors2024nov]
-   The value of metrics, logs, and (un-sampled) traces does not scale with the costs required to
    collect, transfer, and store them.[^sigelman2021a] As the bill goes up, the value stays constant
    at best, and more likely _decreases_.[^majors2024jan]
    -   Logs get noisier and get slower to search with greater volume.
    -   Custom metrics require more forethought and auditing as the set grows over time.
-   "At the end, the three pillars of observability do not exist. It's not something we should be
    relying on."[^tane2024dec]

    -   The coexistence of metrics, logging, and tracing is not _observability_. They are
        _telemetry_ useful in _monitoring_ systems.[^sigelman2021b]

<a name="better-practices"></a>

# Better Practices

-   Instrument applications to emit "wide events" (or "canonical logs" or "structured logs") as your
    telemetry data.

    -   Wide events have high-dimensionality (many attributes) and attributes with high-cardinality
        (many possible unique values) making them context-rich (everything about the event is
        attached to it).[^tane2024sept]
    -   "High-dimensionality" roughly equates with **hundreds** of attributes at present. Metadata
        about hosts, pods, builds, requests, responses, users, customers, timing, errors, teams,
        services, versions, third-party vendors, etc. are all fair game.[^morrell2024]

-   Have a single source of truth which stores the wide events as they are emitted.

    -   Do no aggregation at write-time. Make decisions at read-time about how to query and use the
        data.[^majors2024nov] [^tane2024sept]
    -   Wide events from a service continuously handling 1000 requests per second&mdash;about 1 million
        events per day&mdash;can compress to about 80 MB in columnar formats like Parquet and cost
        pennies to retain for a few months in typical object stores.[^morrell2024]
    -   Custom metrics are effectively infinite as costs no longer increase linearly (thanks to
        columnar data storage) and the ability to cross-correlate increases as more event attributes
        are added. Intelligent sampling can control volume costs associated with these structured
        events when scale demands it.[^majors2024jan]
    -   Storing event data in one place lends itself to the application of AI-tools which are good
        at correlating and summarizing[^burmistrov2024], perhaps continually in the
        background.[^tane2024dec]

-   Adopt exploratory tooling that lets you explore quickly and cheaply query that data about
    emergent behaviors, new questions, unknown unknowns.

    -   Proper tooling allows engineers to investigate any system, regardless of their experience
        with it or its complexity, in a methodical and objective manner.[^majors2022]
    -   The waterfall view of traces, root spans, nested spans, and the like _is_ not sufficient.
        Users need the ability to "dig" into data however they deem necessary.[^burmistrov2024]
    -   You will never ask the same question twice. Something is different since you last asked
        it.[^weakly2024mar]
    -   There is a natural tension between a system’s scalability and its feature set. You can
        afford much powerful observability features at scales orders of magnitude smaller than
        Google.[^sigelman2021a]

# Looking Forward

-   Confusion abounds about what observability really is[^burmistrov2024] to the point that folks
    are actively redefining it[^weakly2024mar] [^parker2024] or versioning it[^majors2024aug]
    [^weakly2024dec] to improve clarity.

    -   "Pretty much everything in business is about asking questions and forming hypotheses, then
        testing them." That's observability.[^parker2024]
    -   The cognitive systems engineering definition of observability&mdash;feedback that provides
        insight into a process and refers to the work needed to extract meaning from available
        data&mdash;may be a better starting point for software engineering.[^weakly2024mar]
    -   "Observability is the process through which one develops the ability to ask meaningful questions,
        get useful answers, and act effectively on what you learn." It is not a tooling problem but
        rather a strategic capability akin to business intelligence.[^weakly2024mar]
    -   "Observability 2.0 has one source of truth, wide structured log events, from which you can
        _derive_ all the other data types." The benefit to the full software development lifecycle,
        the cost model, and the adoption by a critical mass of developers make observability 2.0
        inevitable.[^majors2024nov]
    -   "Observability 1.0 gave us lots of useful answers, observability 2.0 gives us the potential
        to ask meaningful questions, and observability 3.0 is going to give us the ability to act
        effectively on what we learn."[^weakly2024dec]

-   There is consensus on the direction in which software observability should head: toward the
    [better practices](#better-practices) mentioned earlier. Discussion continues to establish
    shared language and goals.

    -   "Observability 3.0 will be measured by the value that non-engineering functions in the
        business are able to get from it."[^weakly2024dec]
    -   "The success of Observability 2.0 will be measured by how well engineering teams can
        understand their decisions and describe what they do in the language of the
        business."[^majors2024dec]

<a name="references"></a>

# References

[^wikipedia2022]:
    [Observability
    (software)](<https://en.wikipedia.org/w/index.php?title=Observability_(software)&oldid=1225628905>).
    (2024, May 24). In _Wikipedia_.

[^bourgon2017]:
    Bourgon, P. (2017, February 21). [Metrics, tracing, and
    logging](https://peter.bourgon.org/blog/2017/02/21/metrics-tracing-and-logging.html). _Peter
    Bourgon's Blog_.

[^parker2024]:
    Parker, A. (2024, March 29). [Re-Redefining
    Observability](https://www.aparker.io/post/3leq2g72z7r2t). _Austin Parker's Blog_.

[^majors2024aug]:
    Majors, C. (2024, August 7). [Is It Time To Version Observability? (Signs Point To
    Yes)](https://charity.wtf/2024/08/07/is-it-time-to-version-observability-signs-point-to-yes/).
    _charity.wtf_.

[^sigelman2021a]:
    Sigelman, B. (2021, February 4). [Debunking the 'Three Pillars of Observability'
    Myth](https://softwareengineeringdaily.com/2021/02/04/debunking-the-three-pillars-of-observability-myth/).
    _Software Engineering Daily_.

[^weakly2024oct]:
    Weakly, H. (2024, October 3). [The 4 Evolutions of Your Observability
    Journey](https://thenewstack.io/the-4-evolutions-of-your-observability-journey/). _The New
    Stack_.

[^sigelman2021b]:
    Sigelman, B. (2021, February 4). [Observability Won’t Replace Monitoring (Because
    It
    Shouldn’t)](https://thenewstack.io/observability-wont-replace-monitoring-because-it-shouldnt/).
    _The New Stack_.

[^majors2024jan]:
    Majors, C. (2024, January 24). [The Cost Crisis in Observability
    Tooling](https://www.honeycomb.io/blog/cost-crisis-observability-tooling). _Honeycomb Blog_.

[^tane2024dec]:
    Tane, B. & Galbraith, K. (2024, December 6). [Observing Serverless Applications
    (SVS212)](https://youtu.be/mPbI3Qxdocc) [Conference presentation]. AWS re:Invent 2024 Las Vegas,
    Nevada, United States.

[^majors2024nov]:
    Majors, C. (2024, November 19). [There Is Only One Key Difference Between
    Observability 1.0 and
    2.0](https://www.honeycomb.io/blog/one-key-difference-observability1dot0-2dot0). _Honeycomb
    Blog_.

[^tane2024sept]:
    Tane, B. (2024, September 8). [Observability Wide Events
    101](https://boristane.com/blog/observability-wide-events-101/). _Boris Tane's Blog_.

[^morrell2024]:
    Morrell, J. (2024, October 22). [A Practitioner's Guide to Wide
    Events](https://jeremymorrell.dev/blog/a-practitioners-guide-to-wide-events/). _Jeremy Morrell's
    Blog_.

[^majors2022]:
    Majors, C., Fong-Jones, L., & Miranda, G. (2022, May 6). [Observability Engineering:
    Achieving production
    excellence](https://learning.oreilly.com/library/view/observability-engineering/9781492076438/).
    O’Reilly Media, Inc.

[^burmistrov2024]:
    Burmistrov, I. (2024, February 15). [All you need is Wide Events, not "Metrics,
    Logs and Traces"](https://isburmistrov.substack.com/p/all-you-need-is-wide-events-not-metrics).
    _A Song Of Bugs And Patches_.

[^weakly2024mar]:
    Weakly, H. (2024, March 15). [Redefining
    Observability](https://hazelweakly.me/blog/redefining-observability/). _Hazel Weakly's Blog_.

[^weakly2024dec]:
    Weakly, H. (2024, December 9). [The Future of Observability: Observability
    3.0](https://hazelweakly.me/blog/the-future-of-observability-observability-3-0/). _Hazel
    Weakly's Blog_.

[^majors2024dec]:
    Majors, C. (2024, December 20). [On Versioning Observabilities (1.0, 2.0,
    3.0…10.0?!?)](https://charity.wtf/2024/12/20/on-versioning-observabilities-1-0-2-0-3-0-10-0/).
    _charity.wtf_.
