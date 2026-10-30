---
name: skill-02-multi-agent-orchestration-coala
description: Three-stage AI development pipeline (Model 1 Architect, Model 2 Execution Orchestrator, Model 3 Execution Team), idea maturation per dimension, context-budget scheduling, and 4-part task contracts.
---

# SKILL 02: Multi-Agent Development Pipeline & Orchestration (CoALA Framework)

> **File Path:** `02_Skills/SKILL_02_Multi_Agent_Orchestration_CoALA.md`  
> **Trigger:** When maturing raw software ideas (Model 1 Architect), decomposing complex architectures into multi-model execution plans (Model 2 Orchestrator), or assigning tasks across AI models (Cursor, Claude, Local LLMs).  
> **Sources:** `Development Team\Model 1 - Architect\*` and `Development Team\Model 2 - Execution Orchestrator\*`.

---

## 1. The 3-Stage AI Pipeline Architecture

1. **Model 1 — Architect:** Takes a raw idea, matures it dimension-by-dimension through targeted questions, applies the Technical Judgment Filter (`SKILL_01`), and outputs a complete Architecture Document. Never writes implementation code.
2. **Model 2 — Execution Orchestrator:** Takes the finished Architecture Document, inventories resources, estimates token/context loads, splits work safely, and outputs an Execution Schedule + 4-Part Contracts. Never alters architecture or writes code.
3. **Model 3 — Execution Team:** The roster of executor models (varying by capability tier, effort level, and thinking toggle) that build, test, and package each work unit.

Each role's memory is organized using the **CoALA 4-Group Cognitive Architecture**:
- **A — Procedural:** Core system prompt and step-by-step skills.
- **B — Semantic:** Distilled, timeless patterns (`knowledge-base.md` / `knowledge-second-brain.md`, `user-profile.md`, and volatile `reference-model-landscape.md`).
- **C — Episodic:** Timestamped `experience-log.md` of real proposals, operator feedback, and outcomes (a pattern must recur here before promotion to Semantic memory).
- **D — Eval:** Synthetic regression checks (`eval-scenarios.md`) and worked behavioral references (`canonical-examples.md`).

---

## 2. Stage 1 Rules: Idea Intake & Per-Dimension Maturation (Model 1)

1. **Non-Negotiable Sequencing Principle:** Never jump straight to a full architecture in the first message of a new project, regardless of how long or confident the opening prompt is.
2. **Assess Maturity Per Dimension (Not as One Global Verdict):**
   Evaluate each dimension independently as **Raw** (unaddressed), **Narrative Gap** (flow described, but "if/error" edge cases left open), or **Clear**:
   - Core purpose & mechanism
   - User flow / interaction model
   - Conditional behavior & edge cases (e.g., duplicate filenames, non-matching inputs, file-still-writing locks)
   - Scale & destination (personal script vs. long-term unattended service vs. public release)
   - Deployment environment / region (ask region *only* if locale/residency actually affects the stack)
   - Explicit constraints (budget, hardware VRAM, access limits)
3. **Targeted Maturation Questions:**
   - Do **not** re-ask about dimensions that are already clear.
   - For **Raw** dimensions: ask 2–3 high-leverage questions that directly shape the architecture.
   - For **Narrative Gaps**: name each specific conditional gap and offer an explicit delegation choice (*"Decide now with a stated default, or give 2–3 examples and delegate the rest to me"*).

---

## 3. Stage 2 Rules: Task Decomposition & Context-Budget Scheduling (Model 2)

1. **Decompose by Context Boundary & Interface Stability:**
   - Divide work based on what a single executor can hold in working context without quality degradation—not by human job titles.
   - **Interface Stability Test:** Only split two components if the interface/contract between them is already fixed. If the interface is undecided, make "defining the interface" its own preliminary unit—or assign the combined unit to a higher-tier model rather than forcing a premature split.
2. **Parallel-Independent vs. Sequential-Coupled:**
   - **Parallel-Independent:** Units share no mutable state and only need upstream final outputs. Safe to fan out to isolated executors.
   - **Sequential-Coupled:** Units share state or require the upstream executor's continuous reasoning trace (most non-trivial coding). Hand off full context in sequence; never parallelize continuous reasoning.
3. **Token & Context Budget Estimation (4 Components + Safe Threshold):**
   - Estimate per unit: `Input Load` + `Output Load` + `Tool-Call Overhead` (full tool output size × expected calls) + `Retry/Failure Buffer` + `Orchestration Handoff Overhead`.
   - Schedule against a **Safe Threshold** meaningfully below the hard context ceiling to prevent mid-unit degradation or lossy auto-compaction.
   - Plan explicit **Handoff Notes** (completed items, derived formulas/rules written explicitly, remaining checklist, modified external files) for units approaching the threshold.
4. **Tier & Effort Routing:**
   - Mechanical, well-specified units -> lowest sufficient model tier, low effort, thinking `OFF`.
   - Novel synthesis, diagnostic forensics, or unresolved trade-offs -> high-tier model, high effort, thinking `ON`.
   - Always check `Last Verified` dates on model specs and free-tier API providers (Google AI Studio, NVIDIA NIM, Groq, Mistral, OpenRouter) before routing.

---

## 4. The Mandatory 4-Part Executor Contract & Completion Report

Never hand off a task to an executor model without all four contract sections and the required completion report format:

### Four-Part Contract:
1. **Objective:** Concrete definition of what "done" means.
2. **Output Format:** Exact file structure, deliverable shape, and encoding requirements.
3. **Tool & Source Guidance:** Exact files, directories, MCP connectors (e.g., Desktop Commander), or APIs authorized for this unit (minimal viable toolset).
4. **Task Boundary:** What is explicitly out of scope. Hitting the boundary or finishing the objective means **STOP and report**—never silently expand scope.

### Required Completion Report Format:
- **Status:** Literal one-word verdict (`DONE`, `PARTIAL`, or `BLOCKED`).
- **Findings (Tagged by Evidence Level):** Every claim tagged as `Measured`, `Derived`, `Inferred`, or `Not Proven`.
- **What Was Built/Changed:** Concrete list of created/modified files.
- **Tests Run & Results:** Actual verification executed (never "should work").
- **Known Limitations & Recommended Next Step.**
