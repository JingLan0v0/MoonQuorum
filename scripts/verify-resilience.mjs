import assert from 'node:assert/strict';
import {checkDemo} from '../examples/demo.mjs';

function validate(req, report) {
  assert.equal(report.policies.length, req.policies.length);
  const risk = new Map();
  for (const [i, p] of req.policies.entries()) {
    const actual = report.policies[i];
    assert.equal(actual.policy, p.id);
    assert.equal(actual.threshold, p.threshold);
    let minimum = Infinity;
    let worst = Infinity;
    for (let mask = 0; mask < 2 ** req.failure_domains.length; mask++) {
      const removed = req.failure_domains.filter((_, index) => mask & (1 << index));
      const voters = new Set(removed.flatMap(d => d.voters));
      const left = p.voters.filter(v => !voters.has(v.id)).reduce((sum, v) => sum + v.weight, 0);
      if (left < p.threshold) minimum = Math.min(minimum, removed.length);
      if (removed.length === req.max_domain_failures) worst = Math.min(worst, left);
    }
    assert.equal(actual.minimum_failures, minimum);
    assert.equal(actual.worst_remaining, worst);
    assert.equal(new Set(actual.witness_domains).size, minimum);
    for (const id of actual.witness_domains) assert(req.failure_domains.some(d => d.id === id));
    const lost = new Set(req.failure_domains.filter(d => actual.witness_domains.includes(d.id)).flatMap(d => d.voters));
    const remaining = p.voters.filter(v => !lost.has(v.id)).reduce((sum, v) => sum + v.weight, 0);
    assert.equal(actual.witness_remaining, remaining);
    assert(remaining < p.threshold);
    risk.set(p.id, worst < p.threshold);
  }
  const first = req.stages.find(s =>
    s.id === report.migration.first_failed_stage || s.active.some(id => risk.get(id)));
  assert.equal(report.first_failed_stage, first?.id ?? null);
  assert.equal(report.status, first ? 'blocked' : 'ready');
}

function generated() {
  let seed = 28415;
  const draw = n => {
    seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
    return Math.floor(seed / 4294967296 * n);
  };
  return Array.from({length: 256}, (_, i) => {
    const ids = Array.from({length: 3 + draw(4)}, (_, j) => 'v' + j);
    const domainCount = 1 + draw(ids.length);
    const failure_domains = ids.slice(0, domainCount).map((v, j) => ({id: 'd' + j, voters: [v]}));
    for (const v of ids.slice(domainCount)) failure_domains[draw(domainCount)].voters.push(v);
    const policies = ['old','next'].map((id, j) => {
      const selected = j === 0 ? ids : ids.filter((_, k) => k === i % ids.length || draw(2));
      const voters = selected.map(id => ({id, weight: 1 + draw(9)}));
      const total = voters.reduce((s, v) => s + v.weight, 0);
      return {id, voters, threshold: 1 + draw(total)};
    });
    return {policies, failure_domains, max_domain_failures: draw(domainCount + 1),
      stages: [{id:'before',active:['old']},{id:'joint',active:['old','next']},{id:'after',active:['next']}]};
  });
}

function verifyExactNumbers(invoke) {
  const inputs = [];
  for (const coefficient of [0n, 1n, 2n, -1n, 31n, 1000n, 1001n, 10000n]) {
    for (const exponent of [-4, -3, -2, -1, 0, 1, 2, 3]) {
      const base = 10n ** BigInt(Math.abs(exponent));
      const validInteger = exponent >= 0 || coefficient % base === 0n;
      const exact = exponent >= 0 ? coefficient * base : coefficient / base;
      const valid = validInteger && exact >= 0n && exact <= 1000n;
      inputs.push({token: coefficient + 'e' + exponent, expected: valid ? Number(exact) : null});
    }
  }
  const requests = inputs.map(({token}) =>
    '{"members":[{"id":"a","left_weight":' + token + ',"right_weight":1},{"id":"b","left_weight":1,"right_weight":1}],"left_threshold":1,"right_threshold":1}');
  const response = invoke(['--batch','-'], '[' + requests.join(',') + ']');
  assert.ifError(response.error);
  assert.equal(response.status, 0, response.stderr);
  const out = JSON.parse(response.stdout);
  assert.equal(out.length, inputs.length);
  inputs.forEach(({token,expected},i) => {
    if (expected === null) assert.equal(out[i].code, 'invalid_input', token);
    else assert.equal(out[i].left_available_weight, expected + 1, token);
  });
  return inputs.length;
}

export function verifyResilience(invoke, mode) {
  checkDemo(invoke);
  const requests = generated();
  function runBatch(items) {
    const result = invoke(['--resilience-batch','-'], JSON.stringify(items));
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr);
    const response = JSON.parse(result.stdout);
    assert.equal(response.length, items.length);
    return response;
  }
  for (let i = 0; i < requests.length; i += 16) {
    const chunk = requests.slice(i,i+16);
    runBatch(chunk).forEach((result,j) => validate(chunk[j], result));
  }
  const good = requests[0];
  const invalid = [
    {...good,failure_domains:[]},
    {...good,max_domain_failures:good.failure_domains.length+1},
    {...good,failure_domains:[{id:'missing',voters:[good.policies[0].voters[0].id]}]},
    {...good,failure_domains:[{id:'unknown',voters:['ghost']}]},
    {...good,failure_domains:[{id:'empty',voters:[]}]},
    {...good,max_steps:1},
  ];
  for (const bad of invalid) {
    const [a,b,c] = runBatch([good,bad,good]);
    assert.equal(b.status,'error');
    assert.deepEqual(a,c);
    assert.notEqual(a.status,'error');
  }
  assert.equal(invoke(['--resilience-batch','-'],JSON.stringify(Array(17).fill(good))).status,2);
  const numberCases=verifyExactNumbers(invoke);
  console.log('PASS ' + mode + ': 256 independent failure-domain models and ' + numberCases + ' exact number comparisons');
  return {domainModels:requests.length,integerCases:numberCases,invalidDomainCases:invalid.length};
}
