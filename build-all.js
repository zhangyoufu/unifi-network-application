'use strict';

module.exports = async ({github, context, core, require}) => {
	const fs = require('fs');
	const YAML = require('yaml');
	const file = fs.readFileSync('version.yml', 'utf8');
	const versions = YAML.parse(file);
	for await (const record of versions) {
		console.log(`Processing version ${record.version}`);
		const request = {
			owner: context.repo.owner,
			repo: context.repo.repo,
			workflow_id: 'build.yml',
			ref: context.ref,
			inputs: {
				version: record.version,
				url: record.url instanceof Array ? record.url[0] : record.url,
				md5: record.checksum.md5,
				sha256: record.checksum.sha256,
			},
		};
		core.debug(request);
		await github.actions.createWorkflowDispatch({
			owner: context.repo.owner,
			repo: context.repo.repo,
			workflow_id: 'build.yml',
			ref: context.ref,
			inputs: {
				version: record.version,
				url: record.url instanceof Array ? record.url[0] : record.url,
				md5: record.checksum.md5,
				sha256: record.checksum.sha256,
			},
		}).catch(error => error).then(response => {
			core.debug(response);
			if (response.status !== 204) {
				core.setFailed(`create workflow_dispatch received status code ${response.status}`);
			}
		});
	}
};
