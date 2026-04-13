enum TCliTool {
  claude,
  codex,
  cursor,
  ;

  String get command {
    switch (this) {
      case TCliTool.claude:
        return 'claude';
      case TCliTool.codex:
        return 'codex';
      case TCliTool.cursor:
        return 'agent';
    }
  }

  String get yoloFlag {
    switch (this) {
      case TCliTool.claude:
        return '--dangerously-skip-permissions';
      case TCliTool.codex:
        return '--yolo';
      case TCliTool.cursor:
        return '--yolo';
    }
  }

  String get systemPromptFlag {
    switch (this) {
      case TCliTool.claude:
        return '--system-prompt';
      case TCliTool.codex:
        return '--system';
      case TCliTool.cursor:
        return '--system';
    }
  }

  String get bareMcpFlag {
    switch (this) {
      case TCliTool.claude:
        return '--strict-mcp-config';
      case TCliTool.codex:
        return '--bare-mcp';
      case TCliTool.cursor:
        return '--bare-mcp';
    }
  }

  String get mcpConfigFlag {
    switch (this) {
      case TCliTool.claude:
        return '--mcp-config';
      case TCliTool.codex:
        return '--mcp-config';
      case TCliTool.cursor:
        return '--mcp-config';
    }
  }

  String get homeFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '.claude';
      case TCliTool.codex:
        return '.codex';
      case TCliTool.cursor:
        return '.cursor';
    }
  }

  String get mcpFilePath {
    switch (this) {
      case TCliTool.claude:
        return '.mcp.json';
      case TCliTool.codex:
        return '$homeFolderPath/mcp.json';
      case TCliTool.cursor:
        return '$homeFolderPath/mcp.json';
    }
  }

  String get promptFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '$homeFolderPath/commands';
      case TCliTool.codex:
        return '$homeFolderPath/prompts';
      case TCliTool.cursor:
        return '$homeFolderPath/commands';
    }
  }

  String get agentsFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '$homeFolderPath/agents';
      case TCliTool.codex:
        return '$homeFolderPath/agents';
      case TCliTool.cursor:
        return '$homeFolderPath/agents';
    }
  }

  String get skillsFolderPath {
    switch (this) {
      case TCliTool.claude:
        return '$homeFolderPath/skills';
      case TCliTool.codex:
        return '$homeFolderPath/skills';
      case TCliTool.cursor:
        return '$homeFolderPath/skills';
    }
  }

  String get sourcesOverrideFlag {
    switch (this) {
      case TCliTool.claude:
        return '--setting-sources';
      case TCliTool.codex:
        return '--sources';
      case TCliTool.cursor:
        return '--sources';
    }
  }
}
