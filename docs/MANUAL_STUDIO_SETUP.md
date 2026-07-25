# Manual Roblox Studio Setup

Use this method when you do not want to install Rojo.

## 1. Create the shared package

In **ReplicatedStorage**:

1. Create a Folder named `HealthKnowledgeChallenge`.
2. Inside it, create a ModuleScript named `Config` and paste the contents of:
   `src/ReplicatedStorage/HealthKnowledgeChallenge/Config.luau`
3. Create another ModuleScript named `QuestionBank` and paste the contents of:
   `src/ReplicatedStorage/HealthKnowledgeChallenge/QuestionBank.luau`

## 2. Create the server scripts

In **ServerScriptService**:

1. Create a Script named `WorldBuilder` and paste the contents of:
   `src/ServerScriptService/WorldBuilder.server.luau`
2. Create a Script named `HealthKnowledgeServer` and paste the contents of:
   `src/ServerScriptService/HealthKnowledgeServer.server.luau`

## 3. Create the client script

In **StarterPlayer > StarterPlayerScripts**:

1. Create a LocalScript named `HealthKnowledgeClient`.
2. Paste the contents of:
   `src/StarterPlayer/StarterPlayerScripts/HealthKnowledgeClient.client.luau`

## 4. Test

1. Press **Play**.
2. Walk to a station.
3. Press **E** or use the displayed touch/gamepad control.
4. Answer questions and confirm the leaderboard updates.
5. Use the **Test** tab to launch a local server with at least two players.

The server creates the `Remotes` folder automatically, and the world builder creates the entire environment at runtime.
