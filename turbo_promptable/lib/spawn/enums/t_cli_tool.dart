enum ConfigSource {
  local,
  global,
  none,
}

enum TCliTool {
  claude,
  codex,
  cursor,
  ;

  String spawn({
    required String request,
    String? conversationId,
    String? systemPromptPath,
    String? systemPrompt,
    String? tools,
    bool yolo = true,
    String? model,
    bool headless = true,
    ConfigSource mcpsConfigSource = ConfigSource.none,
  }) {
    final pConversation = conversationId != null ? ' ${resume(conversationId)}' : '';
    final pSystemPrompt = systemPrompt != null ? ' ${this.systemPrompt(systemPrompt)}' : '';
    final pSystemPromptFile = systemPromptPath != null
        ? ' ${systemPromptFile(systemPromptPath)}'
        : '';
    final pTools = tools != null ? ' ${this.tools(tools)}' : '';
    final pYolo = '${yolo ? ' ${this.yolo}' : ''}';
    final pModel = model != null ? ' ${this.model(model)}' : '';
    final pHeadless = headless && this.headless != null ? ' ${this.headless}' : '';
    final pMcpsConfig = mcpsConfig(source: mcpsConfigSource);
    return '$command'
        '$pConversation'
        '$pSystemPrompt'
        '$pSystemPromptFile'
        '$pTools'
        '$pYolo'
        '$pModel'
        '$pHeadless'
        '$pMcpsConfig'
        '$request';
  }

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

  String get yolo {
    switch (this) {
      case TCliTool.claude:
        return '--dangerously-skip-permissions';
      case TCliTool.codex:
        return '--yolo --ask-for-approval never';
      case TCliTool.cursor:
        return '--yolo --force';
    }
  }

  String model(String? value) {
    switch (this) {
      case TCliTool.claude:
        return '--model $value';
      case TCliTool.codex:
        return '--model $value';
      case TCliTool.cursor:
        return '--model $value';
    }
  }

  String resume(String conversationId) {
    switch (this) {
      case TCliTool.claude:
        return '--conversation $conversationId';
      case TCliTool.codex:
        return 'resume $conversationId';
      case TCliTool.cursor:
        return '--resume=$conversationId';
    }
  }

  String tools(String tools) {
    switch (this) {
      case TCliTool.claude:
        return '--tools $tools';
      case TCliTool.codex:
        return '';
      case TCliTool.cursor:
        return '';
    }
  }

  String systemPrompt(String value) {
    switch (this) {
      case TCliTool.claude:
        return '--system-prompt '
            '''$value''';
      case TCliTool.codex:
      case TCliTool.cursor:
        return '<System>$value</System>';
    }
  }

  String systemPromptFile(String path) {
    switch (this) {
      case TCliTool.claude:
        return '--system-prompt-file $path';
      case TCliTool.codex:
      case TCliTool.cursor:
        return '<System>@$path</System>';
    }
  }

  String? get headless {
    switch (this) {
      case TCliTool.claude:
        return '--disable-slash-commands -p';
      case TCliTool.codex:
        return 'exec';
      case TCliTool.cursor:
        return '-p';
    }
  }

  String mcpsConfig({
    required ConfigSource source,
  }) {
    switch (this) {
      case TCliTool.claude:
        switch (source) {
          case ConfigSource.local:
            return '--strict-mcp-config --mcp-config $mcpsPath';
          case ConfigSource.global:
            return '';
          case ConfigSource.none:
            return '--strict-mcp-config';
        }
      case TCliTool.codex:
        return '';
      case TCliTool.cursor:
        return '';
    }
  }

  String get homePath {
    switch (this) {
      case TCliTool.claude:
        return '.claude';
      case TCliTool.codex:
        return '.codex';
      case TCliTool.cursor:
        return '.cursor';
    }
  }

  String get mcpsPath {
    switch (this) {
      case TCliTool.claude:
        return '.mcp.json';
      case TCliTool.codex:
        return '$homePath/mcp.json';
      case TCliTool.cursor:
        return '$homePath/mcp.json';
    }
  }

  String get commandsPath {
    switch (this) {
      case TCliTool.claude:
        return '$homePath/commands';
      case TCliTool.codex:
        return '$homePath/prompts';
      case TCliTool.cursor:
        return '$homePath/commands';
    }
  }

  String get subAgentsPath {
    switch (this) {
      case TCliTool.claude:
        return '$homePath/agents';
      case TCliTool.codex:
        return '$homePath/agents';
      case TCliTool.cursor:
        return '$homePath/agents';
    }
  }

  String get skillsPath {
    switch (this) {
      case TCliTool.claude:
        return '$homePath/skills';
      case TCliTool.codex:
        return '$homePath/skills';
      case TCliTool.cursor:
        return '$homePath/skills';
    }
  }

  String get sourcesOverrideFlag {
    switch (this) {
      case TCliTool.claude:
        return '--setting-sources';
      case TCliTool.codex:
        return '';
      case TCliTool.cursor:
        return '--sources';
    }
  }
}
