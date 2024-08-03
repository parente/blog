---
date: 2024-08-03
title: Building on Bedrock
excerpt: We started using Amazon Bedrock at work about a year ago to thoughtfully integrate large language models (LLMs) into some of our internal tools and processes. I want to write a series of posts capturing what I've learned from the effort.
---
We started using Amazon Bedrock at work about a year ago to thoughtfully integrate [large language models (LLMs)](https://en.wikipedia.org/wiki/Large_language_model) into some of our internal tools and processes. I want to write a series of posts capturing what I've learned from the effort and to riff on "what-if" alternatives in some places. I expect the result to wander through topics like:

- setting up for happy local development
- abstracting LLM use with the [Bedrock Converse API](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html)
- letting a model call external functions with [Bedrock Tool Use](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html)
- populating and querying [Bedrock Knowledge Bases](https://aws.amazon.com/bedrock/knowledge-bases/)
- structuring larger [Streamlit](https://streamlit.io/) applications for extension and maintenance
- deploying [Slack Bolt](https://slack.dev/bolt-python/) apps to a serverless platform
- single-table design with [pynamodb](https://pynamodb.readthedocs.io/en/stable/) / [DynamoDB](https://aws.amazon.com/dynamodb/)
- provisioning infrastructure with [AWS CDK](https://aws.amazon.com/cdk/) as a Terraform veteran
- observing how the system is working with [AWS X-Ray](https://aws.amazon.com/xray/) as a Datadog adept

You won't go from zero-to-chatbot in 10 minutes reading what I write here. [There are plenty](https://www.google.com/search?q=chat+bot+with+aws+bedrock) of better resources for that. Rather, I hope this series highlights design considerations and ancillary work needed to use LLMs and realize their value.

I have no timeline for publishing, only this entry as a starting point.