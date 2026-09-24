#!/usr/bin/env python3
"""Python 3 Magma regression harness for complex-models.jsonl.

No third-party modules are required. Run from the dataset root:

    python tests/test_complex_models.py

or:

    python tests/test_complex_models.py --magma magma.exe

For each record in complex-models.jsonl, the harness:
  1. loads the asserted source implementation;
  2. constructs the complex from the stored instance parameters;
  3. reconstructs the asserted reference complex from complexes.jsonl; and
  4. verifies direct conjugacy under PGammaL(2,q^2) with Magma IsConjugate.

One Magma script is generated per model assertion under
.test-harness/complex-models/generated so every assertion is independently
rerunnable and inspectable.
"""

import getopt
import json
import os
import re
import shlex
import subprocess
import sys
import time

RESULT_PREFIX = "HARNESS_RESULT "


# ---------------------------------------------------------------------------
# JSON parsing
# ---------------------------------------------------------------------------

JSONError = json.JSONDecodeError


def json_loads(text):
    return json.loads(text)


# ---------------------------------------------------------------------------
# Dataset parsing / validation
# ---------------------------------------------------------------------------

def read_jsonl(path):
    records = []
    with open(path, 'r', encoding='utf-8') as fh:
        for line_number, raw in enumerate(fh, 1):
            line = raw.strip()
            if not line:
                continue
            try:
                value = json_loads(line)
            except JSONError as exc:
                raise ValueError("%s:%d: invalid JSON: %s" % (path, line_number, exc))
            if not isinstance(value, dict):
                raise ValueError("%s:%d: expected a JSON object" % (path, line_number))
            records.append(value)
    return records


def index_unique(records, key, path):
    result = {}
    for record in records:
        if key not in record:
            raise ValueError("%s: record is missing required key %r: %r" % (path, key, record))
        value = record[key]
        if not isinstance(value, str):
            raise ValueError("%s: %r must be a string: %r" % (path, key, record))
        if value in result:
            raise ValueError("%s: duplicate %s %r" % (path, key, value))
        result[value] = record
    return result


def read_file(path):
    with open(path, 'r', encoding='utf-8') as fh:
        return fh.read()


def write_file(path, text):
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(text)


def mkdir_p(path):
    if not os.path.isdir(path):
        os.makedirs(path)


def magma_string(value):
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'


def magma_literal(value):
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, str):
        return magma_string(value)
    if isinstance(value, list):
        return "[" + ",".join([magma_literal(item) for item in value]) + "]"
    if value is None:
        raise TypeError("null instance values are not supported as Magma arguments")
    raise TypeError("unsupported instance value for Magma: %r" % (value,))


def magma_int_sequence(values):
    return "[" + ",".join([str(int(x)) for x in values]) + "]"


def magma_circle_sequence(circles):
    return "[" + ",".join([magma_int_sequence(circle) for circle in circles]) + "]"


def implementation_signature(root, source_id, implementation_path):
    path = os.path.join(root, implementation_path)
    text = read_file(path)
    function_name = source_id + "Implementation"
    pattern = re.compile(r"\b%s\s*:=\s*function\s*\(([^)]*)\)" % re.escape(function_name),
                         re.IGNORECASE | re.MULTILINE)
    match = pattern.search(text)
    if not match:
        raise ValueError("%s: cannot find %s:=function(...)" % (path, function_name))

    raw_parameters = match.group(1).strip()
    # Magma optional parameters begin after ':', e.g. function(q,b:alt:=false).
    # Model instance records describe the ordinary positional source parameters;
    # optional implementation switches are deliberately not part of this harness.
    if ':' in raw_parameters:
        raw_parameters = raw_parameters.split(':', 1)[0].strip()

    if raw_parameters:
        parameters = [p.strip() for p in raw_parameters.split(',')]
    else:
        parameters = []
    for p in parameters:
        if not p:
            raise ValueError("%s: malformed parameter list for %s" % (path, function_name))
    return function_name, parameters


def safe_slug(text):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", text)


class TestCase(object):
    pass


# ---------------------------------------------------------------------------
# Magma generation
# ---------------------------------------------------------------------------

def build_script(case):
    arguments = [magma_literal(case.instance[name]) for name in case.parameters]
    call = "%s(%s)" % (case.function_name, ','.join(arguments))
    reference_circles = magma_circle_sequence(case.reference_circles)

    return '''/* Auto-generated complex model regression test.
   model #%d: complex=%s, source=%s
   Exact assertion: candidate and catalog reference must be conjugate as whole circle sets.
*/
q := %d;
load "library/web-discovery.m";
load %s;

referenceSerialized := %s;
referenceComplex := {};
referenceOK := true;
for seq in referenceSerialized do
    c := webDiscoverySerializedCircle(seq);
    if not c in circles then
        referenceOK := false;
    else
        Include(~referenceComplex,c);
    end if;
end for;

print "HARNESS_BEGIN complex=%s source=%s";

if not referenceOK or #referenceComplex ne #referenceSerialized then
    print "%sREFERENCE_FAILED";
else
    candidateLambdaS := %s;
    if Type(candidateLambdaS) eq RngIntElt then
        print "%sCONSTRUCTION_FAILED";
    else
        candidateComplex := WebToCSet(candidateLambdaS);
        flag, conjugator := IsConjugate(G,CSet,candidateComplex,referenceComplex);
        if flag then
            print "%sPASS";
        else
            print "%sFAIL";
        end if;
    end if;
end if;
''' % (case.number, case.complex_id, case.source_id,
       case.q, magma_string(case.implementation_path), reference_circles,
       case.complex_id, case.source_id,
       RESULT_PREFIX, call, RESULT_PREFIX,
       RESULT_PREFIX, RESULT_PREFIX)

def prepare_cases(root, generated_dir):
    complexes_path = os.path.join(root, "complexes.jsonl")
    sources_path = os.path.join(root, "sources.jsonl")
    models_path = os.path.join(root, "complex-models.jsonl")

    complexes = index_unique(read_jsonl(complexes_path), "id", complexes_path)
    sources = index_unique(read_jsonl(sources_path), "id", sources_path)
    models = read_jsonl(models_path)

    mkdir_p(generated_dir)
    signature_cache = {}
    cases = []

    number = 0
    for model in models:
        number += 1
        if "complex" not in model or "source" not in model or "instance" not in model:
            raise ValueError("%s: model #%d is missing complex/source/instance" % (models_path, number))

        complex_id = model["complex"]
        source_id = model["source"]
        instance = model["instance"]

        if not isinstance(complex_id, str) or complex_id not in complexes:
            raise ValueError("%s: model #%d references unknown complex %r" %
                             (models_path, number, complex_id))
        if not isinstance(source_id, str) or source_id not in sources:
            raise ValueError("%s: model #%d references unknown source %r" %
                             (models_path, number, source_id))
        if not isinstance(instance, dict):
            raise ValueError("%s: model #%d instance must be an object" % (models_path, number))

        complex_record = complexes[complex_id]
        q = complex_record.get("q")
        if not isinstance(q, int) or q < 2:
            raise ValueError("%s: complex %r has invalid q %r" %
                             (complexes_path, complex_id, q))

        components = complex_record.get("components")
        if not isinstance(components, list) or not components:
            raise ValueError("%s: complex %r has no components" %
                             (complexes_path, complex_id))

        reference_circles = []
        seen_circles = {}
        for component_number, component in enumerate(components):
            if not isinstance(component, dict):
                raise ValueError("%s: complex %r component %d is not an object" %
                                 (complexes_path, complex_id, component_number + 1))
            web_id = component.get("webID")
            if not isinstance(web_id, str) or not web_id:
                raise ValueError("%s: complex %r component %d has no webID" %
                                 (complexes_path, complex_id, component_number + 1))
            circles = component.get("circles")
            if not isinstance(circles, list) or not circles:
                raise ValueError("%s: complex %r component %d has no circles" %
                                 (complexes_path, complex_id, component_number + 1))
            for circle in circles:
                if not isinstance(circle, list) or not circle:
                    raise ValueError("%s: complex %r has malformed serialized circle %r" %
                                     (complexes_path, complex_id, circle))
                key = tuple(circle)
                if key in seen_circles:
                    raise ValueError("%s: complex %r repeats serialized circle %r" %
                                     (complexes_path, complex_id, circle))
                seen_circles[key] = 1
                reference_circles.append(circle)

        source = sources[source_id]
        implementation_path = source.get("implementation")
        if not isinstance(implementation_path, str):
            raise ValueError("%s: source %r has no implementation path" %
                             (sources_path, source_id))
        if not os.path.isfile(os.path.join(root, implementation_path)):
            raise ValueError("%s: implementation does not exist: %s" %
                             (sources_path, implementation_path))

        if source_id not in signature_cache:
            signature_cache[source_id] = implementation_signature(root, source_id, implementation_path)
        function_name, parameters = signature_cache[source_id]

        missing = [name for name in parameters if name not in instance]
        extra = [name for name in instance.keys() if name not in parameters]
        if missing or extra:
            pieces = []
            if missing:
                pieces.append("missing " + ", ".join(missing))
            if extra:
                pieces.append("extra " + ", ".join(extra))
            raise ValueError("%s: model #%d (%s/%s) instance/signature mismatch: %s" %
                             (models_path, number, complex_id, source_id, "; ".join(pieces)))

        if "q" in instance and instance["q"] != q:
            raise ValueError("%s: model #%d (%s/%s) instance q=%r but complex q=%r" %
                             (models_path, number, complex_id, source_id, instance["q"], q))

        script_name = "%04d-%s-%s.m" % (number, safe_slug(complex_id), safe_slug(source_id))
        case = TestCase()
        case.number = number
        case.complex_id = complex_id
        case.source_id = source_id
        case.q = q
        case.instance = instance
        case.reference_circles = reference_circles
        case.implementation_path = implementation_path
        case.function_name = function_name
        case.parameters = parameters
        case.script_path = os.path.join(generated_dir, script_name)
        write_file(case.script_path, build_script(case))
        cases.append(case)

    return cases, complexes, sources


# ---------------------------------------------------------------------------
# Magma execution
# ---------------------------------------------------------------------------

def run_case(root, case, magma_command):
    script = read_file(case.script_path)
    start = time.time()
    try:
        proc = subprocess.Popen(magma_command,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT,
                                cwd=root,
                                text=True)
        output = proc.communicate(script)[0]
        returncode = proc.returncode
    except OSError as exc:
        return "HARNESS_ERROR", str(exc), time.time() - start, None

    elapsed = time.time() - start
    status = "NO_RESULT"
    for line in output.splitlines():
        if line.startswith(RESULT_PREFIX):
            status = line[len(RESULT_PREFIX):].strip()
    if status == "NO_RESULT" and returncode != 0:
        status = "MAGMA_ERROR"
    return status, output, elapsed, returncode


def output_tail(output, line_count):
    parts = output.rstrip().splitlines()
    return "\n".join(parts[-line_count:])


def shell_quote(text):
    # Only for display; execution uses argv and does not invoke a shell.
    if re.match(r'^[A-Za-z0-9_./:=+-]+$', text):
        return text
    return "'" + text.replace("'", "'\\''") + "'"


USAGE = """Usage: python tests/test_complex_models.py [options]

Options:
  --root DIR             dataset root (default: current directory)
  --magma COMMAND        Magma command/executable (default: magma)
  --generated-dir DIR    generated .m directory
  --generate-only        generate scripts but do not run Magma
  --fail-fast            stop after first non-PASS result
  --complex ID               test only this complex ID (repeatable)
  --source ID            test only this source ID (repeatable)
  --show-passing-output  show output for passing tests too
  -h, --help             show this help

There is deliberately no per-test timeout, preserving the behavior of the
earlier TP25 harness.
"""


def main(argv):
    root = os.getcwd()
    magma = "magma"
    generated_dir = None
    generate_only = False
    fail_fast = False
    wanted_complexes = []
    wanted_sources = []
    show_passing_output = False

    try:
        opts, args = getopt.getopt(argv, "h", ["help", "root=", "magma=", "generated-dir=",
                                              "generate-only", "fail-fast", "complex=", "source=",
                                              "show-passing-output"])
    except getopt.GetoptError as exc:
        sys.stderr.write(str(exc) + "\n")
        sys.stderr.write(USAGE)
        return 2

    if args:
        sys.stderr.write("Unexpected positional arguments: %s\n" % " ".join(args))
        return 2

    for opt, value in opts:
        if opt in ("-h", "--help"):
            sys.stdout.write(USAGE)
            return 0
        elif opt == "--root":
            root = value
        elif opt == "--magma":
            magma = value
        elif opt == "--generated-dir":
            generated_dir = value
        elif opt == "--generate-only":
            generate_only = True
        elif opt == "--fail-fast":
            fail_fast = True
        elif opt == "--complex":
            wanted_complexes.append(value)
        elif opt == "--source":
            wanted_sources.append(value)
        elif opt == "--show-passing-output":
            show_passing_output = True

    root = os.path.abspath(root)
    if generated_dir is None:
        generated_dir = os.path.join(root, ".test-harness", "complex-models", "generated")
    else:
        generated_dir = os.path.abspath(generated_dir)

    try:
        cases, complexes, sources = prepare_cases(root, generated_dir)
    except (IOError, OSError, ValueError, TypeError) as exc:
        sys.stderr.write("Harness setup failed: %s\n" % exc)
        return 2

    if wanted_complexes:
        unknown = [x for x in wanted_complexes if x not in complexes]
        if unknown:
            sys.stderr.write("Unknown --complex value(s): %s\n" % ", ".join(unknown))
            return 2
        cases = [case for case in cases if case.complex_id in wanted_complexes]

    if wanted_sources:
        unknown = [x for x in wanted_sources if x not in sources]
        if unknown:
            sys.stderr.write("Unknown --source value(s): %s\n" % ", ".join(unknown))
            return 2
        cases = [case for case in cases if case.source_id in wanted_sources]

    print("Loaded %d complexes, %d sources, %d selected complex-model tests." % (len(complexes), len(sources), len(cases)))
    print("Generated Magma scripts: %s" % generated_dir)

    if generate_only:
        return 0

    magma_command = shlex.split(magma)
    if not magma_command:
        sys.stderr.write("--magma produced an empty command\n")
        return 2
    if "-b" not in magma_command:
        magma_command.append("-b")

    print("Magma command: %s" % " ".join([shell_quote(part) for part in magma_command]))
    print()

    counts = {}
    failed = False
    total = len(cases)

    ordinal = 0
    for case in cases:
        ordinal += 1
        label = "[%03d/%03d] %s <- %s" % (ordinal, total, case.complex_id, case.source_id)
        status, output, elapsed, returncode = run_case(root, case, magma_command)
        counts[status] = counts.get(status, 0) + 1
        print("%s: %s (%.2fs)" % (label, status, elapsed))

        if status != "PASS" or show_passing_output:
            tail = output_tail(output, 24)
            if tail:
                print("--- Magma output ---")
                print(tail)
                print("--------------------")
            if returncode not in (None, 0):
                print("Magma exit code: %s" % returncode)

        if status != "PASS":
            failed = True
            if fail_fast:
                break

    print()
    print("Summary:")
    statuses = sorted(counts.keys())
    for status in statuses:
        print("  %-20s %d" % (status, counts[status]))

    if failed:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
