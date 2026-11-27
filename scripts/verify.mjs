import fs from 'node:fs';
import {createHash} from 'node:crypto';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {verifyMigration} from './verify-migration.mjs';
import {verifyResilience} from './verify-resilience.mjs';
const root=path.resolve(import.meta.dirname,'..');
process.chdir(root);
const summary=path.join(root,'_build/verification-summary.json');
fs.mkdirSync(path.dirname(summary),{recursive:true});fs.rmSync(summary,{force:true});
const candidates=[process.env.MOON_HOME,path.resolve(root,'../.tools/moonstn-toolchain'),path.resolve(root,'../MoonBit黑客松/.tools/moonstn-toolchain')].filter(Boolean);
const installation=candidates.find(p=>fs.existsSync(path.join(p,'bin',process.platform==='win32'?'moon.exe':'moon')));
if(installation)process.env.MOON_HOME=installation;
const moon=process.env.MOON_BIN || (installation?path.join(installation,'bin',process.platform==='win32'?'moon.exe':'moon'):'moon');
function run(cmd,args,options={}){const r=spawnSync(cmd,args,{cwd:root,encoding:'utf8',timeout:120000,maxBuffer:16*1024*1024,...options});assert.equal(r.error,undefined);assert.equal(r.status,0,r.stderr||r.stdout);return r.stdout;}
const pin = JSON.parse(fs.readFileSync('toolchain.json', 'utf8'));
const versions = run(moon, ['version', '--all']);
assert.equal(versions.match(/^moon (\S+)/m)?.[1], pin.moon, 'Use the pinned moon');
assert.equal(versions.match(/^moonc (\S+)/m)?.[1], pin.moonc, 'Use the pinned moonc');
assert.equal(process.versions.node, pin.node_tested, 'Use the pinned Node.js');
const sourceCommit = fs.existsSync('.git') ? run('git', ['rev-parse', 'HEAD']).trim() : null;
function verifyCiCheckout() {
  if (process.env.GITHUB_ACTIONS !== 'true') return;
  assert.equal(sourceCommit, process.env.GITHUB_SHA, 'Verify the intended CI commit');
  assert.equal(run('git', ['rev-parse', 'HEAD']).trim(), sourceCommit, 'CI HEAD changed');
  assert.equal(run('git', ['status', '--porcelain']).trim(), '', 'CI checkout must be clean');
}
verifyCiCheckout();
run(moon,['fmt','--check']);run(moon,['check','--target','js','--deny-warn']);run(moon,['info','--target','js']);
const reports=[];
const cases=[];
function sum(ms,mask,field){return ms.reduce((n,m,i)=>n+((mask>>i)&1?m[field]:0),0);}
// Independent oracle: enumerate every pair of subsets, never reuse the DP recurrence.
function expected(req){const n=req.members.length;let intersecting=true;
 for(let a=0;a<2**n;a++)for(let b=0;b<2**n;b++){
  if(!(a&b)&&sum(req.members,a,'left_weight')>=req.left_threshold&&sum(req.members,b,'right_weight')>=req.right_threshold)intersecting=false;
 }
 return intersecting?'intersecting':'disjoint';
}
function validate(req,out){
 assert.equal(out.status,expected(req));
 const active=req.members.filter(m=>!(req.unavailable||[]).includes(m.id));
 const a=active.reduce((s,m)=>s+m.left_weight,0),b=active.reduce((s,m)=>s+m.right_weight,0);
 assert.equal(out.left_available_weight,a);assert.equal(out.right_available_weight,b);
 assert.equal(out.left_available,a>=req.left_threshold);assert.equal(out.right_available,b>=req.right_threshold);
 if(out.status==='disjoint'){
  const left=out.left_witness,right=out.right_witness;
  for(const xs of [left,right]){assert.equal(new Set(xs).size,xs.length);assert(xs.every(x=>req.members.some(m=>m.id===x)));}
  assert(!left.some(x=>right.includes(x)));
  assert(req.members.filter(m=>left.includes(m.id)).reduce((s,m)=>s+m.left_weight,0)>=req.left_threshold);
  assert(req.members.filter(m=>right.includes(m.id)).reduce((s,m)=>s+m.right_weight,0)>=req.right_threshold);
 }
}
for(let code=0;code<729;code++){
 let x=code;const members=[];
 for(let i=0;i<3;i++){members.push({id:`n${i}`,left_weight:x%3,right_weight:Math.floor(x/3)%3});x=Math.floor(x/9);}
 const left=members.reduce((s,m)=>s+m.left_weight,0),right=members.reduce((s,m)=>s+m.right_weight,0);
 for(let a=1;a<=left;a++)for(let b=1;b<=right;b++)cases.push({members,left_threshold:a,right_threshold:b,unavailable:members.filter((_,i)=>(code>>i)&1).map(m=>m.id)});
}
assert.equal(cases.length,6561);
for(const mode of ['debug','release']){
 const flags=mode==='release'?['--release']:[];
 assert.equal(run(moon,['run','examples/migration','--target','js','--deny-warn',...flags]).trim(),'PASS migration API: isolated outage shortfall in joint stage');
 const units=run(moon,['test','--target','js','--deny-warn',...flags]);process.stdout.write(units);
 assert.equal(run(moon,['run','examples/library','--target','js','--deny-warn',...flags]).trim(),'PASS public API: disjoint witness and outage analysis');
 const cli=path.join(root,`_build/js/${mode}/build/cmd/main/main.js`);
 fs.rmSync(cli, {force:true});
 run(moon,['build','cmd/main','--target','js','--deny-warn',...flags]);
 const artifact=fs.readFileSync(cli);
 assert(artifact.length > 0, 'CLI build produced an empty artifact');
 const cliSha256=createHash('sha256').update(artifact).digest('hex');
 const invoke=(args,input)=>spawnSync(process.execPath,['--max-old-space-size=192',cli,...args],{input,encoding:'utf8',timeout:15000,maxBuffer:4*1024*1024});
 const batch=reqs=>{const r=invoke(['--batch','-'],JSON.stringify(reqs));assert.equal(r.error,undefined);assert.equal(r.status,0,r.stderr);return JSON.parse(r.stdout);};
 for(let start=0;start<cases.length;start+=64){const reqs=cases.slice(start,start+64),out=batch(reqs);assert.equal(out.length,reqs.length);out.forEach((v,i)=>validate(reqs[i],v));}
 console.log(`PASS ${mode}: 6561 weighted-policy cases against exhaustive subset pairs`);
 const good={members:[{id:'a',left_weight:1,right_weight:1}],left_threshold:1,right_threshold:1};
 const bad=[null,{}, {...good,unknown:1},{...good,left_threshold:0},{...good,left_threshold:2},{...good,right_threshold:0},{...good,max_steps:0},{...good,max_steps:1},{...good,max_steps:1.5},{...good,unavailable:['x']},{...good,unavailable:['a','a']},{...good,members:[]},{...good,members:[{id:'bad id',left_weight:1,right_weight:1}]},{...good,members:[{id:'a',left_weight:1.5,right_weight:1}]},{...good,members:[{id:'a',left_weight:1e100,right_weight:1}]},{...good,members:[good.members[0],good.members[0]]},{...good,members:Array.from({length:33},(_,i)=>({id:`n${i}`,left_weight:1,right_weight:1}))},{...good,members:Array.from({length:5},(_,i)=>({id:`n${i}`,left_weight:1000,right_weight:1000}))}];
 for(const req of bad){const out=batch([good,req,good]);assert.deepEqual(out[0],out[2]);assert.equal(out[0].status,'intersecting');assert.equal(out[1].status,'error');}
 const transport=['{"members":[],"members":[]}', '[', '['.repeat(17)+'0'+']'.repeat(17),' '.repeat(1048577),'"'+'x'.repeat(257)+'"',JSON.stringify(Array(65).fill(good))];
 for(const input of transport){const r=invoke(['--batch','-'],input);assert.equal(r.status,2);assert.equal(r.stdout,'');assert(r.stderr.length>0);}
 const utf=invoke(['-'],Buffer.from([0xff]));assert.equal(utf.status,2);assert.equal(utf.stdout,'');
 const bom=invoke(['-'],'\ufeff'+JSON.stringify(good));assert.equal(bom.status,0,bom.stderr);
 assert.deepEqual(batch([]),[]);
 for(const args of [[],['--unknown'],['x','y'],['missing-file.json']]){const r=invoke(args,'');assert.equal(r.status,2);assert.equal(r.stdout,'');}
 assert.equal(invoke(['--version'],'').stdout.trim(),'0.3.2');
 assert(invoke(['--help'],'').stdout.includes('moon-quorum'));
 const fd=fs.openSync(path.join(root,'moon.mod'),'r');try{assert.equal(spawnSync(process.execPath,[cli,'--version'],{stdio:['ignore',fd,'pipe'],encoding:'utf8',timeout:15000}).status,2);}finally{fs.closeSync(fd);}
 for(const name of ['read-write','rollout','maintenance']){const req=JSON.parse(fs.readFileSync(`examples/${name}.json`,'utf8')),r=invoke([`examples/${name}.json`],'');assert.equal(r.status,0,r.stderr);validate(req,JSON.parse(r.stdout));}
 // Exact work boundary at the maximum supported table size.
 const large={members:Array.from({length:32},(_,i)=>({id:`n${i}`,left_weight:128,right_weight:128})),left_threshold:4096,right_threshold:4096};
 const result=batch([{...large,max_steps:32*4097-1},{...large,max_steps:32*4097}]);assert.equal(result[0].code,'limit_exceeded');assert.equal(result[1].status,'intersecting');
 const migration=verifyMigration(invoke,mode);
 const resilience=verifyResilience(invoke,mode);
 reports.push({mode,migration,resilience,cliSha256,unitTests:units.trim(),exhaustivePolicyCases:cases.length,invalidBatchItems:bad.length,transportRejects:transport.length+1,scenarios:['read-write','rollout','maintenance']});
 console.log(`PASS ${mode}: limits, batch isolation, I/O and three scenarios`);
}
verifyCiCheckout();
const receipt = {status:'passed', recordedAt:new Date().toISOString(), sourceCommit, toolchain:pin, reports};
fs.writeFileSync(summary + '.tmp', JSON.stringify(receipt, null, 2) + '\n');
fs.renameSync(summary + '.tmp', summary);
