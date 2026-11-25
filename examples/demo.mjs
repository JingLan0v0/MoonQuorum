import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';

const root = path.resolve(import.meta.dirname, '..');

export function checkDemo(invoke) {
  const review = file => {
    const result = invoke(['--resilience', 'examples/resilience-' + file + '.json']);
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr);
    return JSON.parse(result.stdout);
  };
  const concentrated = review('concentrated');
  assert.equal(concentrated.migration.status, 'ready');
  assert.equal(concentrated.status, 'blocked');
  assert.equal(concentrated.first_failed_stage, 'rollout');
  const cut = concentrated.policies[0];
  assert.equal(cut.minimum_failures, 1);
  assert.deepEqual(cut.witness_domains, ['east']);
  assert.equal(cut.witness_remaining, 2);
  console.log('PASS all single voters tolerate loss, but losing east leaves only 2 of 3 required votes');

  const balanced = review('balanced');
  assert.equal(balanced.status, 'ready');
  assert.equal(balanced.policies[0].minimum_failures, 2);
  assert.equal(balanced.policies[0].worst_remaining, 3);
  console.log('PASS balanced placement survives any single domain failure');

  const stages = review('next-stage');
  assert.equal(stages.migration.first_failed_stage, 'maintenance');
  assert.equal(stages.first_failed_stage, 'coexistence');
  console.log('PASS correlated outage advances the first blocked migration stage');

  const invalid = JSON.parse(fs.readFileSync(path.join(root, 'examples/resilience-concentrated.json'), 'utf8'));
  invalid.failure_domains[1].voters.push('a');
  const rejected = invoke(['--resilience','-'], JSON.stringify(invalid));
  assert.ifError(rejected.error);
  assert.equal(rejected.status, 2);
  assert.equal(rejected.stdout, '');
  assert.match(rejected.stderr, /voter belongs to more than one/);
  console.log('PASS overlapping domain membership is rejected');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const exe = process.platform === 'win32' ? 'moon.exe' : 'moon';
  const installation = [
    process.env.MOON_HOME,
    path.resolve(root, '../MoonBit黑客松/.tools/moonstn-toolchain'),
  ].find(dir => dir && fs.existsSync(path.join(dir, 'bin', exe)));
  if (installation) process.env.MOON_HOME = installation;
  const moon = process.env.MOON_BIN ?? (installation ? path.join(installation, 'bin', exe) : exe);
  const run = (program, args, input) => spawnSync(program, args, {
    cwd: root, input, encoding: 'utf8', timeout: 120000, maxBuffer: 1048576,
  });
  const built = run(moon, ['build', 'cmd/main', '--target', 'js', '--release', '--deny-warn']);
  assert.ifError(built.error);
  assert.equal(built.status, 0, built.stderr);
  const cli = path.join(root, '_build/js/release/build/cmd/main/main.js');
  checkDemo((args, input) => run(process.execPath, [cli, ...args], input));
}
