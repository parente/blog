---
date: 2025-03-29
title: Model Context Protocol (MCP) Brief
excerpt:
    I've been hearing about Model Context Protocol (MCP) lately. I wrote this brief to connect MCP
    to my knowledge about LLM function calling and my experience implementing tools for Anthropic Claude integrations at work.
---

I've implemented a handful of
[tools](https://docs.anthropic.com/en/docs/build-with-claude/tool-use/overview) for Anthropic Claude
integrations at work: fetching public web page content, invoking Slack APIs, querying Amazon Bedrock
Knowledge Bases. I've been hearing about [Model Context Protocol
(MCP)](https://modelcontextprotocol.io) lately, and haven't had time to grok it's connection to LLM
function calling and my experience.

With a good cup of ☕️ coffee and some time to read and think, I've arrived at the following
understanding in brief.

---

-   Many LLMs support _function calling_ also known as _tool use_ (e.g., [OpenAI](https://platform.openai.com/docs/guides/function-calling), [Anthropic](https://docs.anthropic.com/en/docs/build-with-claude/tool-use/overview), [Llama](https://www.llama.com/docs/model-cards-and-prompt-formats/llama3_2/#code-interpreter)).
-   There's no standard format for function call / tool use instructions across model vendors. Tool
    request and response formats vary.
-   MCP "... provides a standardized framework for managing the execution of function call instructions,
    including tool discovery, invocation, and response handling"[^chan2024dec]
-   [MCP servers](https://modelcontextprotocol.io/examples) host tools for discovery and execution.
-   [MCP clients](https://modelcontextprotocol.io/clients) bridge user interaction with LLMs, and
    LLM interactions with tools on MCP servers. For example:
    -   User: "What's the weather?"
    -   MCP client: List tools available for LLM use
    -   LLM: Weather tool use request in LLM format
    -   MCP client: JSON-RPC call to weather function
    -   MCP server: Response to weather function call
    -   MCP client: Weather tool use response in LLM format
    -   LLM: "The weather is bright and sunny"
-   MCP enables an ecosystem of adapters for existing services (e.g., [https://mcp.so/](https://mcp.so)).
-   MCP uses [JSON-RPC 2.0](https://www.jsonrpc.org/specification) on the wire with support for local (stdio) and remote ([HTTP Server-Sent Events](https://en.wikipedia.org/wiki/Server-sent_events)) transports.[^mcp2025]
-   It supports concepts beyond tools (e.g., [resources](https://modelcontextprotocol.io/docs/concepts/resources), [prompts](https://modelcontextprotocol.io/docs/concepts/prompts)).
-   It fits into existing model broker architectures (e.g., [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/)[^battista2025mar], [Ollama](https://ollama.com/)[^gupta2025mar]).
-   There are security, cost, development, hosting, pricing (and likely other) implications of the
    widespread adoption of MCP.[^li2025mar]

# References

[^chan2024dec]: Chan, P. (2024 Dec 13). [LLM Function-Calling vs. Model Context Protocol (MCP)](https://medium.com/@patc888/function-calling-vs-mcp-model-context-protocol-fc01e9c41eb4). _Patrick Chan on Medium_.
[^mcp2025]: [Transports](https://modelcontextprotocol.io/docs/concepts/transports). (2025 March 29). In _Model Context Protocol_.
[^battista2025mar]: Battista, G. (2025 Mar 19). [Model Context Protocol (MCP) and Amazon Bedrock](https://community.aws/content/2uFvyCPQt7KcMxD9ldsJyjZM1Wp/model-context-protocol-mcp-and-amazon-bedrock). _AWS Community._
[^gupta2025mar]: Gupta, M. (2025 Mar 29). [Model Context Protocol (MCP) using Ollama](https://medium.com/data-science-in-your-pocket/model-context-protocol-mcp-using-ollama-e719b2d9fd7a). _Data Science in Your Pocket_.
[^li2025mar]: Li, Y. (2025 March 20) [A Deep Dive Into MCP and the Future of AI Tooling](https://a16z.com/a-deep-dive-into-mcp-and-the-future-of-ai-tooling/). _Andreesen Horowitz_.
