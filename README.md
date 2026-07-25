# Health Knowledge Challenge

A small multiplayer Roblox Studio prototype for health and science communication. Players explore three quiz stations, answer evidence-based health questions, receive immediate explanatory feedback, earn knowledge points, and complete a shared challenge.

## Portfolio relevance

This project demonstrates:

- multiplayer-oriented Roblox/Luau development;
- interactive health and science communication;
- server-authoritative quiz validation;
- scoring, progression, feedback, and built-in leaderboards;
- proximity-based interaction in a generated 3D environment;
- responsive client UI for desktop, gamepad, and mobile interaction;
- a structure suitable for scenario-based usability testing.

## Features

- Three exploration stations: **Immune System**, **Vaccines**, and **Healthy Habits**.
- Fifteen questions with short educational explanations.
- Randomized questions without immediate repetition.
- Fifteen-second answer timer.
- Server-side answer validation and simple anti-spam checks.
- Knowledge score, correct-answer count, and completion state.
- Completion bonus after five correct answers.
- Multiplayer completion announcement.
- Runtime-generated world and UI, so no paid assets are required.

> Educational prototype only. It does not provide medical diagnosis or personal medical advice.

## Repository structure

```text
health-knowledge-challenge/
├── default.project.json
├── src/
│   ├── ReplicatedStorage/HealthKnowledgeChallenge/
│   │   ├── Config.luau
│   │   └── QuestionBank.luau
│   ├── ServerScriptService/
│   │   ├── HealthKnowledgeServer.server.luau
│   │   └── WorldBuilder.server.luau
│   └── StarterPlayer/StarterPlayerScripts/
│       └── HealthKnowledgeClient.client.luau
└── docs/
    ├── CV_BULLETS.md
    ├── MANUAL_STUDIO_SETUP.md
    └── TEST_CHECKLIST.md
```

## Option A: Run with Rojo

1. Install Roblox Studio and Rojo.
2. Open a new **Baseplate** experience in Roblox Studio.
3. Open this repository in a terminal.
4. Run:

```bash
rojo serve
```

5. Connect through the Rojo Studio plugin.
6. Press **Play**. The world, stations, remotes, leaderboard, and UI are created automatically.

## Option B: Manual Roblox Studio setup

Follow [`docs/MANUAL_STUDIO_SETUP.md`](docs/MANUAL_STUDIO_SETUP.md). No external assets are required.

## Multiplayer testing

In Roblox Studio, open the **Test** tab and start a local server with two or more players. Each player has an independent question state and score, while completion announcements are visible to everyone.
