const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const docs = fs.readFileSync(path.join(root, 'SYSTEM_DOCUMENTATION.md'), 'utf8');
for (const marker of ['docs-check: lab3-infrastructure', 'aws-toolkit', 'ap-southeast-2', 'destroy']) {
  assert(docs.includes(marker), `Missing documentation: ${marker}`);
}
for (const file of ['main.tf', 'variables.tf', 'outputs.tf']) {
  assert(docs.includes(file), `Undocumented Terraform file: ${file}`);
  assert(fs.existsSync(path.join(root, 'terraform-aws-lab', file)), `Missing ${file}`);
}
console.log('docs-check: PASS');
