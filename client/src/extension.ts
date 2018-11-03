/* --------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import * as path from 'path';
import * as vscode from 'vscode';
const fs = require('fs');
import { workspace, ExtensionContext } from 'vscode';

import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions,
	TransportKind
} from 'vscode-languageclient';

let client: LanguageClient; 

export function activate(context: ExtensionContext) {

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
	
	let v = vscode.commands.registerCommand('ext.CreateProject', 
	() => {
		let projectName : string = 'project';

		let dir : string = "C:/" + projectName ;
		let pfile : string = dir + "/" + "Main.sl";

		if(!fs.existsSync(dir) && fs.mkdirSync(dir)){};

		fs.writeFile(pfile,'module Main\nstart\n\toutput \"Hello World!\";\nend Main.', "utf-8", 
			(err) => {if(err) throw err; console.log("Project was created");
		});
		
		if(!fs.existsSync(pfile)) 
		{
			vscode.window.showInformationMessage('SL Project Created');
		}
		else 
		{
			vscode.window.showErrorMessage('Project Error');
		}
	});
	context.subscriptions.push(v);
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}
