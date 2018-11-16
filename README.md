# LSP for Semantic Language

Based on https://code.visualstudio.com/docs/extensions/example-language-server.

## Versions
- 1.0.2 — Fix Project Creator

## Functionality

This Language Server works for Semantic Language (.sl) file. It has the following language features:

- Diagnostics regenerated on each file change or configuration change
- Command `SL: Create Project` for project initialization of workspace folder

It also includes an End-to-End test.

## Structure

```
.
├── client // Language Client
│   ├── src
│   │   └── extension.ts // Language Client entry point
├── package.json // The extension manifest.
└── server // Language Server
    └── src
        └── server.ts // Language Server entry point
```

## Running the Sample

- Run `npm install` in this folder. This installs all necessary npm modules in both the client and server folder
- Open VS Code on this folder.
- Press Ctrl+Shift+B to compile the client and server.
- Switch to the Debug viewlet.
- Select `Launch Client` from the drop down.
- Run the lauch config.
- If you want to debug the server as well use the launch configuration `Attach to Server`
- In the [Extension Development Host] instance of VSCode, open a document in 'semanticlanguage' language mode.
  - Syntax Error handling

## Working with grammar

- You need to use `dotnet run` to work with generated parser in folder `csharp`
- Back-end based on C#, ANTLR and .Net Core

## Developing the grammar

- You can use `Antlr4 Code Generator` extension from NuGet
- With Antlr, you can use command `antlr4-csharp-4.6.5-complete.jar -visitor -listener -package SemanticLanguageGrammar -o SemanticLanguageGrammar -Dlanguage=CSharp_v4_5 SLGrammar.g4` in Command Prompt(Windows)
