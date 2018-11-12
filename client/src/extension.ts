/* --------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import * as path from 'path';
const fs = require('fs');

import { workspace, ExtensionContext, commands } from 'vscode';
import * as vscode from 'vscode';

import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions,
	TransportKind
} from 'vscode-languageclient';
import { Script } from 'vm';

let client: LanguageClient; 

export async function activate(context: ExtensionContext) {

	context.subscriptions.push(vscode.commands.registerCommand('terminalTest.createAndSend', async () => {
		const terminal = vscode.window.createTerminal('SL Diagnostic Terminal');
		let path_ext: string = context.extensionPath;
		terminal.sendText(`cd ${path_ext}; cd csharp; dotnet restore; dotnet run`);
	}));

	vscode.window.showInformationMessage("Language server of SL is starting...");
	await vscode.commands.executeCommand('terminalTest.createAndSend');

	// The server is implemented in node
	let serverModule = context.asAbsolutePath(
		path.join('server', 'out', 'server.js')
	);
	// The debug options for the server
	// --inspect=6009: runs the server in Node's Inspector mode so VS Code can attach to the server for debugging
	let debugOptions = { execArgv: ['--nolazy', '--inspect=6009'] };

	// If the extension is launched in debug mode then the debug server options are used
	// Otherwise the run options are used
	let serverOptions: ServerOptions = {
		run: { module: serverModule, transport: TransportKind.ipc },
		debug: {
			module: serverModule,
			transport: TransportKind.ipc,
			options: debugOptions
		}
	};

	// Options to control the language client
	let clientOptions: LanguageClientOptions = {
		// Register the server for plain text documents
		documentSelector: [{ scheme: 'file', language: 'semanticlanguage' }],
		synchronize: {
			// Notify the server about file changes to '.clientrc files contained in the workspace
			fileEvents: workspace.createFileSystemWatcher('**/.clientrc')
		}
	};

	// Create the language client and start the client.
	client = new LanguageClient(
		'languageServerExample',
		'Language Server Example',
		serverOptions,
		clientOptions
	);
	
	client.start();
	
	let v = vscode.commands.registerCommand('ext.InitProject', 
	() => {
		
		const options: vscode.OpenDialogOptions = {
			canSelectMany: false,
			canSelectFolders: true,
			canSelectFiles: false,
			openLabel: 'Choose project folder',
			defaultUri: vscode.workspace.workspaceFolders[0].uri
	    };
   
	    vscode.window.showOpenDialog(options).then(fileUri => {
			if (fileUri && fileUri[0]) 
			{
				let dir : string = fileUri[0].fsPath;
				let pfile : string = path.join(dir, "Main.sl");
				
				fs.writeFile(pfile,'module Main\nstart\n\toutput \"Hello World!\";\nend Main.', "utf-8", 
					(err) => {if(err) throw err; console.log("Project was created");
				});
				
				if(!fs.existsSync(pfile)) 
				{
					vscode.window.showInformationMessage(`SL Project Created, Main file = ${pfile}`);
					
					vscode.workspace.openTextDocument(pfile).then((a: vscode.TextDocument) => {
						vscode.window.showTextDocument(a, 1, false);
					});
				}
				else 
				{
					vscode.window.showErrorMessage('Project Error');
				}
		    }
	    });
	});
	context.subscriptions.push(v);
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}
