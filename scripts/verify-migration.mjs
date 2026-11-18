import assert from 'node:assert/strict';
import fs from 'node:fs';

const exampleNames = ['migration-ready', 'migration-bridge', 'migration-outage'];

function policy(id, weights, threshold) {
  return {
    id,
    voters: weights.flatMap((weight, i) => weight ? [{id: 'v' + i, weight}] : []),
    threshold,
  };
}

function stage(id, active, unavailable) {
  return {id, active, outages: [{id: 'case', unavailable}]};
}

function quorums(policy) {
  const sets = [];
  for (let mask = 0; mask < 2 ** policy.voters.length; mask++) {
    const chosen = policy.voters.filter((_, i) => mask & (1 << i));
    if (chosen.reduce((total, voter) => total + voter.weight, 0) >= policy.threshold) {
      sets.push(chosen.map(voter => voter.id));
    }
  }
  return sets;
}

function validateWitness(policy, names) {
  const weights = new Map(policy.voters.map(voter => [voter.id, voter.weight]));
  assert.equal(new Set(names).size, names.length);
  assert(names.every(name => weights.has(name)));
  assert(names.reduce((sum, name) => sum + weights.get(name), 0) >= policy.threshold);
}

function validate(request, output) {
  assert.equal(output.stages.length, request.stages.length);
  const policies = new Map(request.policies.map(p => [p.id, p]));
  const possible = new Map(request.policies.map(p => [p.id, quorums(p)]));
  const unique = new Set();
  let firstFailed = null;
  request.stages.forEach((s, i) => {
    const observed = output.stages[i];
    assert.equal(observed.stage, s.id);
    const expected = [];
    const active = request.policies.filter(p => s.active.includes(p.id));
    active.forEach((a, j) => {
      for (const b of active.slice(j)) {
        const key = a.id + ':' + b.id;
        unique.add(key);
        if (possible.get(a.id).some(left =>
          possible.get(b.id).some(right => left.every(id => !right.includes(id))))) {
          expected.push(key);
        }
      }
    });
    const actual = observed.conflicts.map(c => {
      assert(c.left_witness.every(id => !c.right_witness.includes(id)));
      validateWitness(policies.get(c.left_policy), c.left_witness);
      validateWitness(policies.get(c.right_policy), c.right_witness);
      return c.left_policy + ':' + c.right_policy;
    });
    assert.deepEqual(actual.sort(), expected.sort());
    const outages = (s.outages ?? []).map(o => ({
      scenario: o.id,
      capacities: s.active.map(id => {
        const p = policies.get(id);
        const remaining = p.voters
          .filter(voter => !o.unavailable.includes(voter.id))
          .reduce((sum, voter) => sum + voter.weight, 0);
        return {policy: id, remaining, threshold: p.threshold, shortfall: Math.max(0, p.threshold - remaining)};
      }),
    }));
    assert.deepEqual(observed.outages, outages);
    if (expected.length || outages.some(o => o.capacities.some(c => c.shortfall > 0))) {
      firstFailed ??= s.id;
    }
  });
  assert.equal(output.first_failed_stage, firstFailed);
  assert.equal(output.status, firstFailed === null ? 'ready' : 'blocked');
  assert.equal(output.pair_checks, unique.size);
}

function generatedPlans() {
  const binaryPolicies = [];
  for (let mask = 1; mask < 8; mask++) {
    const weights = [0, 1, 2].map(i => (mask >> i) & 1);
    const total = weights.reduce((a, b) => a + b);
    for (let threshold = 1; threshold <= total; threshold++) {
      binaryPolicies.push({weights, threshold});
    }
  }
  const plans = [];
  const ids = ['old', 'bridge', 'new'];
  const make = (models, offset) => ({
    policies: models.map((p, i) => policy(ids[i], p.weights, p.threshold)),
    stages: [
      stage('old-to-bridge', ['old', 'bridge'], []),
      stage('all-live', ['new', 'bridge', 'old'], ['v' + offset]),
      stage('bridge-to-new', ['bridge', 'new'], []),
    ],
  });
  for (const a of binaryPolicies) {
    for (const b of binaryPolicies) {
      for (const c of binaryPolicies) {
        const offset = a.weights.findIndex((weight, i) => weight || b.weights[i] || c.weights[i]);
        plans.push(make([a, b, c], offset));
      }
    }
  }
  assert.equal(plans.length, 1728);
  let seed = 16728;
  function next(max) {
    seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
    return Math.floor(seed / 4294967296 * max);
  }
  for (let i = 0; i < 256; i++) {
    const models = ids.map(() => {
      const weights = Array.from({length: 3}, () => next(5));
      if (weights.every(weight => weight === 0)) weights[0] = 1;
      return {weights, threshold: 1 + next(weights.reduce((a, b) => a + b))};
    });
    const registered = [0, 1, 2].filter(k => models.some(p => p.weights[k]));
    plans.push(make(models, registered[next(registered.length)]));
  }
  return plans;
}

const plans = generatedPlans();

export function verifyMigration(invoke, mode) {
  function batch(items) {
    const r = invoke(['--migration-batch', '-'], JSON.stringify(items));
    assert.equal(r.error, undefined);
    assert.equal(r.status, 0, r.stderr);
    const values = JSON.parse(r.stdout);
    assert.equal(values.length, items.length);
    return values;
  }

  for (let start = 0; start < plans.length; start += 16) {
    const slice = plans.slice(start, start + 16);
    batch(slice).forEach((output, i) => validate(slice[i], output));
  }

  const expectedFirst = [null, 'introduce-bridge', 'maintenance'];
  for (const [i, name] of exampleNames.entries()) {
    const filename = 'examples/' + name + '.json';
    const input = JSON.parse(fs.readFileSync(filename, 'utf8'));
    const r = invoke(['--migration', filename], '');
    assert.equal(r.status, 0, r.stderr);
    const saved = JSON.parse(r.stdout);
    validate(input, saved);
    assert.equal(saved.first_failed_stage, expectedFirst[i]);
  }

  const good = {policies: [policy('one', [1], 1)], stages: [stage('before', ['one'], [])]};
  const bad = [
    null,
    {...good, typo: true},
    {...good, policies: []},
    {...good, policies: [good.policies[0], good.policies[0]]},
    {...good, policies: [{...good.policies[0], voters: [{id: 'v0', weight: 0}]}]},
    {...good, policies: [{...good.policies[0], threshold: 2}]},
    {...good, policies: [{...good.policies[0], voters: [{id: 'a', weight: 1.5}]}]},
    {...good, stages: []},
    {...good, stages: [good.stages[0], good.stages[0]]},
    {...good, stages: [stage('before', ['one', 'one'], [])]},
    {...good, stages: [stage('before', ['other'], [])]},
    {...good, stages: [stage('before', ['one'], ['unknown'])]},
    {...good, stages: [stage('before', ['one'], ['v0', 'v0'])]},
    {...good, stages: [{...good.stages[0], outages: Array(9).fill({id: 'test', unavailable: []})}]},
    {...good, stages: Array.from({length: 17}, (_, i) => stage('s' + i, ['one'], []))},
    {...good, max_steps: 1},
  ];
  for (const input of bad) {
    const results = batch([good, input, good]);
    assert.equal(results[0].status, 'ready');
    assert.equal(results[1].status, 'error');
    assert.deepEqual(results[2], results[0]);
    const single = invoke(['--migration', '-'], JSON.stringify(input));
    assert.equal(single.status, 2);
    assert.equal(single.stdout, '');
  }
  assert.equal(batch([{...good, max_steps: 1}])[0].code, 'limit_exceeded');
  assert.equal(batch([{...good, max_steps: 2}])[0].work_steps, 2);
  assert.deepEqual(batch([]), []);
  for (const input of ['[', '{"stages":[],"stages":[]}', JSON.stringify(Array(17).fill(good))]) {
    const malformed = invoke(['--migration-batch', '-'], input);
    assert.equal(malformed.status, 2);
    assert.equal(malformed.stdout, '');
  }
  console.log('PASS ' + mode + ': ' + plans.length + ' migration plans against independent subset enumeration');
  return {exhaustivePlans: 1728, seededWeightedPlans: 256, malformedItems: bad.length, scenarios: exampleNames};
}
