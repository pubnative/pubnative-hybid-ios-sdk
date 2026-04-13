#!/usr/bin/env node
/**
 * NGSDK Rebranding Audit — Conformity score for release gate.
 *
 * Scans NGSDK.xcframework for HyBid/Pubnative/PNLite references and computes
 * a conformity score (0–100). Exits 0 if score >= threshold, 1 otherwise.
 *
 * Usage:
 *   node audit-conformity.js [path-to-NGSDK.xcframework]
 *   node audit-conformity.js --min-score 90 [path]
 *   node audit-conformity.js --json [path]   # machine-readable for CI
 *
 * Score: 100 = no findings. Deductions: critical 15, high 5, medium 1 each.
 * Default --min-score 100 (release passes only with zero findings).
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const readFile = promisify(fs.readFile);
const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);

// --- Config: terms that must not appear in NGSDK output (case-insensitive)
const AUDIT_TERMS = /hybid|pubnative|pnlite|pubnative-lite|PubnativeLite|HyBid|PNLite/gi;

// File extensions we scan (text files only)
const TEXT_EXTENSIONS = /\.(swiftinterface|abi\.json|h|m|swift|js|plist|strings|xib|storyboard|yml)$/i;

// Severity by file type (public API / symbols / other)
const CRITICAL_EXT = /\.(swiftinterface|abi\.json)$/i;
const HIGH_EXT = /\.(h|m|swift)$/i;

// Penalty per finding: score = max(0, 100 - penalty)
const PENALTY = { critical: 15, high: 5, medium: 1 };

const DEFAULT_TARGET = path.join(__dirname, '..', 'NGSDK.xcframework');
const MAX_FINDINGS_PER_SEVERITY = 30;
const SNIPPET_MAX_LEN = 200;
const SNIPPET_DISPLAY_LEN = 120;

/**
 * Classify severity of a finding by file path.
 * Critical = public API surface; High = source/symbols; Medium = other text.
 */
function getSeverity(filePath) {
  if (CRITICAL_EXT.test(filePath)) return 'critical';
  if (HIGH_EXT.test(filePath)) return 'high';
  return 'medium';
}

/**
 * Recursively collect all scannable text files under dir (matching TEXT_EXTENSIONS).
 * Returns absolute paths; base is used to build relative path for reporting.
 */
async function collectFiles(dir, base = '') {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];

  for (const e of entries) {
    const rel = base ? `${base}/${e.name}` : e.name;
    const fullPath = path.join(dir, e.name);

    if (e.isDirectory()) {
      files.push(...(await collectFiles(fullPath, rel)));
    } else if (e.isFile() && TEXT_EXTENSIONS.test(e.name)) {
      files.push(fullPath);
    }
  }

  return files;
}

/**
 * Count all files under dir (any extension). Used to report "X scannable of Y total".
 */
async function countAllFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  let count = 0;
  for (const e of entries) {
    const fullPath = path.join(dir, e.name);
    if (e.isDirectory()) {
      count += await countAllFiles(fullPath);
    } else if (e.isFile()) {
      count += 1;
    }
  }
  return count;
}

/**
 * Test if a line contains any audit term (resets regex so multiple calls are safe).
 */
function lineHasAuditTerm(line) {
  const re = new RegExp(AUDIT_TERMS.source, 'gi');
  return re.test(line);
}

/**
 * Scan a single file for audit terms; returns array of findings.
 */
async function scanFile(filePath, rootPath) {
  const relPath = path.relative(rootPath, filePath);
  let text;

  try {
    text = await readFile(filePath, 'utf8');
  } catch {
    return [];
  }

  const findings = [];
  const lines = text.split(/\r?\n/);

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (!lineHasAuditTerm(line)) continue;

    const snippet = line.trim().slice(0, SNIPPET_MAX_LEN);
    if (!snippet) continue;

    findings.push({
      path: relPath,
      lineNum: i + 1,
      snippet,
      severity: getSeverity(relPath),
    });
  }

  return findings;
}

/**
 * Run full audit on rootPath (xcframework directory).
 */
async function runAudit(rootPath) {
  const absRoot = path.resolve(rootPath);
  const [files, totalFiles] = await Promise.all([
    collectFiles(absRoot),
    countAllFiles(absRoot),
  ]);
  const allFindings = [];

  for (const fp of files) {
    const findings = await scanFile(fp, absRoot);
    allFindings.push(...findings);
  }

  const bySeverity = {
    critical: allFindings.filter((f) => f.severity === 'critical'),
    high: allFindings.filter((f) => f.severity === 'high'),
    medium: allFindings.filter((f) => f.severity === 'medium'),
  };

  const critical = bySeverity.critical.length;
  const high = bySeverity.high.length;
  const medium = bySeverity.medium.length;
  const penalty =
    critical * PENALTY.critical + high * PENALTY.high + medium * PENALTY.medium;
  const score = Math.max(0, Math.min(100, 100 - penalty));
  const uniqueFiles = new Set(allFindings.map((f) => f.path)).size;

  return {
    target: absRoot,
    totalScanned: files.length,
    totalFiles,
    findings: allFindings,
    bySeverity,
    critical,
    high,
    medium,
    uniqueFiles,
    penalty,
    score,
  };
}

/**
 * Parse CLI args: --min-score N, --json, and optional path.
 */
function parseArgs() {
  const args = process.argv.slice(2);
  let minScore = 100;
  let json = false;
  let target = null;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--min-score' && args[i + 1] != null) {
      minScore = parseInt(args[i + 1], 10);
      i++;
    } else if (args[i] === '--json') {
      json = true;
    } else if (!args[i].startsWith('--')) {
      target = args[i];
    }
  }

  return {
    minScore: Number.isNaN(minScore) ? 100 : minScore,
    json,
    target: path.resolve(target || DEFAULT_TARGET),
  };
}

/**
 * Print findings for one severity section (shared for Critical/High/Medium).
 */
function printFindingsSection(title, findings, maxList) {
  console.log(`--- ${title} ---`);
  if (findings.length === 0) {
    console.log('  (none)');
    return;
  }
  findings.slice(0, maxList).forEach((f) => {
    console.log(`  ${f.path}:${f.lineNum}`);
    const oneLine = f.snippet.replace(/\n/g, ' ').slice(0, SNIPPET_DISPLAY_LEN);
    console.log(`    ${oneLine}`);
  });
  if (findings.length > maxList) {
    console.log(`  ... and ${findings.length - maxList} more`);
  }
  console.log('');
}

// Human-readable list of which extensions we scan (for report)
const SCANNED_EXTENSIONS_DESC = '.swiftinterface, .abi.json, .h, .m, .swift, .js, .plist, .strings, .xib, .storyboard, .yml';

/**
 * Human-readable report to stdout.
 */
function printReport(result, minScore) {
  const { score, penalty, critical, high, medium, totalScanned, totalFiles, uniqueFiles, bySeverity, target } = result;
  const passed = score >= minScore;

  console.log('');
  console.log(`  Score: ${score}/100  (threshold: ${minScore})  ${passed ? 'PASS' : 'FAIL'}`);
  console.log(`  Penalty: ${penalty}  (critical×15 + high×5 + medium×1  →  score = max(0, 100 − penalty))`);
  console.log('');
  console.log(`NGSDK rebranding audit: ${target}`);
  console.log(`  Scanned ${totalScanned} file(s) of ${totalFiles} total (only ${SCANNED_EXTENSIONS_DESC}).`);
  console.log(`  Findings: ${result.findings.length} in ${uniqueFiles} file(s).  Critical: ${critical}  |  High: ${high}  |  Medium: ${medium}`);
  console.log('');

  // Warn when xcframework has no public API files (headers / swiftinterface) — audit may be incomplete
  if (totalScanned > 0 && bySeverity.critical.length === 0 && bySeverity.high.length === 0) {
    console.log('  ⚠️  No .h, .swiftinterface, .m or .swift files found. Framework may be built without public headers/module stability; audit only covered plist/yml/etc.');
    console.log('');
  }

  printFindingsSection('Critical (public API / .swiftinterface, .abi.json)', bySeverity.critical, MAX_FINDINGS_PER_SEVERITY);
  printFindingsSection('High (symbols / .h, .m, .swift)', bySeverity.high, MAX_FINDINGS_PER_SEVERITY);
  printFindingsSection('Medium (other text files: .js, .plist, .xib, etc.)', bySeverity.medium, MAX_FINDINGS_PER_SEVERITY);

  if (passed) {
    console.log('Result: PASS — score meets threshold.');
  } else {
    console.log('Result: FAIL — score below threshold. Fix findings above for release.');
  }
}

/**
 * Emit JSON result for CI (no extra keys like findings list to keep payload small).
 */
function printJson(result, minScore) {
  const passed = result.score >= minScore;
  const payload = {
    score: result.score,
    minScore,
    passed,
    critical: result.critical,
    high: result.high,
    medium: result.medium,
    totalFindings: result.findings.length,
    uniqueFiles: result.uniqueFiles,
    totalScanned: result.totalScanned,
    totalFiles: result.totalFiles,
    target: result.target,
  };
  console.log(JSON.stringify(payload, null, 0));
}

async function main() {
  const { minScore, json: outputJson, target } = parseArgs();

  if (!fs.existsSync(target)) {
    console.error('audit-conformity: path not found:', target);
    process.exit(2);
  }

  const st = await stat(target);
  if (!st.isDirectory()) {
    console.error('audit-conformity: not a directory (expected NGSDK.xcframework):', target);
    process.exit(2);
  }

  const result = await runAudit(target);
  const passed = result.score >= minScore;

  if (outputJson) {
    printJson(result, minScore);
  } else {
    printReport(result, minScore);
  }

  process.exit(passed ? 0 : 1);
}

main().catch((err) => {
  console.error('audit-conformity:', err.message);
  process.exit(2);
});
