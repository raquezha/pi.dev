# Python AGY SDK Observability Setup Guide

This guide walks you through setting up a zero-dependency, local-first HTML trace visualizer for Python agents built using the **Google Antigravity (AGY) SDK**. 

It uses the SDK's lifecycle hook system to log session details, turns, tool calls, and outputs an identical premium dark-themed interactive HTML trace page (`trace.html`) directly to the project root directory on shutdown.

---

## 🛠️ Step 1: Add the Observability Script to Your Project

1. Copy the helper class code from [scripts/html_observability.py](file:///Users/raquezha/RQZ/personal/pi.dev/scripts/html_observability.py) and save it as `html_observability.py` in your agent's project root or library folder.

> [!NOTE]
> The module is self-contained and only requires the standard python library (`json`, `time`, `os`) and the `google.antigravity` SDK imports.

---

## 🚀 Step 2: Register Hooks in Your Agent Configuration

Import the class, instantiate it with your project configuration, and register its hook handlers inside your `LocalAgentConfig`.

Here is a complete integration example:

```python
import asyncio
from google.antigravity import Agent, LocalAgentConfig
from html_observability import HTMLObservability

async def main():
    # 1. Initialize the HTML trace logger
    observer = HTMLObservability(
        project_name="my-antigravity-python-agent",
        output_dir="." # Directory where trace.html will be generated
    )

    # 2. Register hooks into the local agent configuration
    config = LocalAgentConfig(
        model="google/gemini-2.0-flash", # or any other model
        hooks=observer.get_hooks(),      # registers start, end, tool, and error hooks
        # ... your other tool declarations and parameters ...
    )

    # 3. Initialize and run your agent as normal
    async with Agent(config) as agent:
        print("Agent is active. Type your query...")
        response = await agent.chat("Calculate the sum of prime numbers between 1 and 50.")
        print(f"Agent Response: {response}")

    # On session exit, trace.html is written out automatically!

if __name__ == "__main__":
    asyncio.run(main())
```

---

## 📊 Step 3: Inspect Your Traces

When the python execution block exits (i.e. exiting the `async with Agent(config)` context), the session teardown handler will write `trace.html` to your designated folder:

```text
📊 [Trace] Observability report generated:
👉 file:///path/to/your/project/trace.html
```

Open this file in your web browser (Chrome, Safari, etc.) to explore your agent session metrics and interactive timeline cards!

> [!TIP]
> Just like the TypeScript version, the generated report is **100% self-contained** and can be attached to GitHub pull requests, shared via Slack, or archived in Jira tickets.
