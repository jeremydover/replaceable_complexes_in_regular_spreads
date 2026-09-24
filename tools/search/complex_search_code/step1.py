# Python 3 compatible.
# Run from the repository root:
#
#     python3 tools/search/complex_search_code/step1.py 7
#
# Reads:
#
#     webs.jsonl
#     complexes.jsonl
#
# Writes:
#
#     tools/search/complex_search_code/step1.out

import sys
import re


WEB_FILE = "webs.jsonl"
COMPLEX_FILE = "complexes.jsonl"

COMPLEX_ID_RE = re.compile(r"^complex-(\d+)-(\d+)$")


#
# Minimal JSON parser.
#
# Supports exactly the standard JSON types needed by these files:
# objects, arrays, strings, integers, true, false, null.
#
class JSONParser:

    def __init__(self, text):
        self.text = text
        self.n = len(text)
        self.i = 0

    def error(self, message):
        raise ValueError(
            "%s at character %d" % (message, self.i)
        )

    def skip_space(self):
        while self.i < self.n and self.text[self.i] in " \t\r\n":
            self.i += 1

    def parse(self):
        self.skip_space()
        value = self.parse_value()
        self.skip_space()

        if self.i != self.n:
            self.error("extra data after JSON value")

        return value

    def parse_value(self):
        self.skip_space()

        if self.i >= self.n:
            self.error("unexpected end of input")

        c = self.text[self.i]

        if c == "{":
            return self.parse_object()

        if c == "[":
            return self.parse_array()

        if c == "\"":
            return self.parse_string()

        if c == "-" or ("0" <= c <= "9"):
            return self.parse_integer()

        if self.text[self.i:self.i + 4] == "true":
            self.i += 4
            return True

        if self.text[self.i:self.i + 5] == "false":
            self.i += 5
            return False

        if self.text[self.i:self.i + 4] == "null":
            self.i += 4
            return None

        self.error("unexpected token")

    def parse_object(self):
        result = {}

        if self.text[self.i] != "{":
            self.error("expected '{'")

        self.i += 1
        self.skip_space()

        if self.i < self.n and self.text[self.i] == "}":
            self.i += 1
            return result

        while 1:
            self.skip_space()

            if self.i >= self.n or self.text[self.i] != "\"":
                self.error("expected object key")

            key = self.parse_string()

            self.skip_space()

            if self.i >= self.n or self.text[self.i] != ":":
                self.error("expected ':' after object key")

            self.i += 1

            value = self.parse_value()
            result[key] = value

            self.skip_space()

            if self.i >= self.n:
                self.error("unexpected end of object")

            if self.text[self.i] == "}":
                self.i += 1
                return result

            if self.text[self.i] != ",":
                self.error("expected ',' or '}' in object")

            self.i += 1

    def parse_array(self):
        result = []

        if self.text[self.i] != "[":
            self.error("expected '['")

        self.i += 1
        self.skip_space()

        if self.i < self.n and self.text[self.i] == "]":
            self.i += 1
            return result

        while 1:
            result.append(self.parse_value())

            self.skip_space()

            if self.i >= self.n:
                self.error("unexpected end of array")

            if self.text[self.i] == "]":
                self.i += 1
                return result

            if self.text[self.i] != ",":
                self.error("expected ',' or ']' in array")

            self.i += 1

    def parse_string(self):
        if self.text[self.i] != "\"":
            self.error("expected string")

        self.i += 1
        chars = []

        while self.i < self.n:

            c = self.text[self.i]
            self.i += 1

            if c == "\"":
                return "".join(chars)

            if c != "\\":
                chars.append(c)
                continue

            if self.i >= self.n:
                self.error("unfinished string escape")

            esc = self.text[self.i]
            self.i += 1

            if esc == "\"":
                chars.append("\"")
            elif esc == "\\":
                chars.append("\\")
            elif esc == "/":
                chars.append("/")
            elif esc == "b":
                chars.append("\b")
            elif esc == "f":
                chars.append("\f")
            elif esc == "n":
                chars.append("\n")
            elif esc == "r":
                chars.append("\r")
            elif esc == "t":
                chars.append("\t")
            elif esc == "u":
                #
                # The IDs and numerical data in these files are ASCII.
                # Handle basic \uXXXX escapes anyway.
                #
                if self.i + 4 > self.n:
                    self.error("bad unicode escape")

                digits = self.text[self.i:self.i + 4]
                self.i += 4

                try:
                    code = int(digits, 16)
                except ValueError:
                    self.error("bad unicode escape")

                if code < 128:
                    chars.append(chr(code))
                else:
                    self.error("non-ASCII unicode escape not supported")
            else:
                self.error("bad string escape")

        self.error("unterminated string")

    def parse_integer(self):
        start = self.i

        if self.text[self.i] == "-":
            self.i += 1

        if self.i >= self.n or not ("0" <= self.text[self.i] <= "9"):
            self.error("bad integer")

        while (
            self.i < self.n
            and "0" <= self.text[self.i] <= "9"
        ):
            self.i += 1

        token = self.text[start:self.i]

        try:
            return int(token)
        except ValueError:
            self.error("bad integer")


def parse_json(text):
    return JSONParser(text).parse()


def read_jsonl(path):

    try:
        f = open(path, "r")
    except IOError:
        print("ERROR: Cannot open %s" % path)
        sys.exit(1)

    line_number = 0

    while 1:
        line = f.readline()

        if not line:
            break

        line_number += 1
        line = line.strip()

        if not line:
            continue

        try:
            record = parse_json(line)
        except Exception as e:
            print("ERROR: %s:%d: invalid JSON" % (
                path,
                line_number
            ))
            print(e)
            f.close()
            sys.exit(1)

        if not isinstance(record, dict):
            print("ERROR: %s:%d: record is not an object" % (
                path,
                line_number
            ))
            f.close()
            sys.exit(1)

        yield line_number, record

    f.close()


def magma_sequence(obj):

    if isinstance(obj, list):
        parts = []

        for x in obj:
            parts.append(magma_sequence(x))

        return "[" + ",".join(parts) + "]"

    if isinstance(obj, int) and not isinstance(obj, bool):
        return str(obj)

    raise TypeError(
        "Unsupported value in circle data: %r" % (obj,)
    )


def magma_string(s):

    s = s.replace("\\", "\\\\")
    s = s.replace("\"", "\\\"")

    return "\"" + s + "\""


def load_replaceable_webs(q):

    webs = []

    for line_number, record in read_jsonl(WEB_FILE):

        if "q" not in record:
            print("ERROR: %s:%d has no q field" % (
                WEB_FILE,
                line_number
            ))
            sys.exit(1)

        if record["q"] != q:
            continue

        if "replaceability" not in record:
            continue

        if "hemi" not in record["replaceability"]:
            continue

        if not record["replaceability"]["hemi"]:
            continue

        if "invariants" not in record:
            continue

        if "t" not in record["invariants"]:
            continue

        if record["invariants"]["t"] != 2:
            continue

        if "id" not in record:
            print("ERROR: %s:%d has no id field" % (
                WEB_FILE,
                line_number
            ))
            sys.exit(1)

        if "circles" not in record:
            print("ERROR: %s:%d has no circles field" % (
                WEB_FILE,
                line_number
            ))
            sys.exit(1)

        web_id = record["id"]
        circles = record["circles"]

        webs.append((web_id, circles))

    return webs


def first_available_complex_id(q):

    used = {}

    for line_number, record in read_jsonl(COMPLEX_FILE):

        if "q" not in record:
            print("ERROR: %s:%d has no q field" % (
                COMPLEX_FILE,
                line_number
            ))
            sys.exit(1)

        if "id" not in record:
            print("ERROR: %s:%d has no id field" % (
                COMPLEX_FILE,
                line_number
            ))
            sys.exit(1)

        record_q = record["q"]
        complex_id = record["id"]

        match = COMPLEX_ID_RE.match(complex_id)

        if match is None:
            print("ERROR: %s:%d: bad complex ID: %s" % (
                COMPLEX_FILE,
                line_number,
                complex_id
            ))
            print("Expected complex-<q>-<digits>")
            sys.exit(1)

        id_q = int(match.group(1))

        #
        # int() strips leading zeroes.
        #
        id_number = int(match.group(2))

        if id_q != record_q:
            print("ERROR: %s:%d: q mismatch" % (
                COMPLEX_FILE,
                line_number
            ))
            print("    record q = %d" % record_q)
            print("    ID = %s" % complex_id)
            print("    ID q = %d" % id_q)
            sys.exit(1)

        if id_number < 1:
            print("ERROR: invalid complex ID number: %s" % (
                complex_id
            ))
            sys.exit(1)

        if record_q == q:

            if id_number in used:
                print("ERROR: duplicate complex number %d for q=%d" % (
                    id_number,
                    q
                ))
                sys.exit(1)

            used[id_number] = 1

    candidate = 1

    while candidate in used:
        candidate += 1

    return candidate


def write_magma(q, webs, next_complex_id, output_path):

    try:
        f = open(output_path, "w")
    except IOError:
        print("ERROR: Cannot create %s" % output_path)
        sys.exit(1)

    f.write("// Replaceable webs for q = %d\n" % q)
    f.write("// Generated from %s\n" % WEB_FILE)
    f.write(
        "// WebCircles[i] and WebIDs[i] refer to the same web.\n"
    )
    f.write("\n")

    f.write("q:=%d;\n\n" % q)

    f.write("WebCircles := [\n")

    i = 0

    while i < len(webs):

        web_id = webs[i][0]
        circles = webs[i][1]

        if i < len(webs) - 1:
            comma = ","
        else:
            comma = ""

        f.write(
            "    %s%s // %s\n" % (
                magma_sequence(circles),
                comma,
                web_id
            )
        )

        i += 1

    f.write("];\n\n")

    f.write("WebIDs := [\n")

    i = 0

    while i < len(webs):

        web_id = webs[i][0]

        if i < len(webs) - 1:
            comma = ","
        else:
            comma = ""

        f.write(
            "    %s%s\n" % (
                magma_string(web_id),
                comma
            )
        )

        i += 1

    f.write("];\n\n")

    f.write(
        "NextComplexID := %d;\n\n" % next_complex_id
    )

    f.write(
        "assert #WebCircles eq #WebIDs;\n"
    )

    f.close()


def usage():

    print("Usage:")
    print("    python3 tools/search/complex_search_code/step1.py q")
    print()
    print("Example:")
    print("    python3 tools/search/complex_search_code/step1.py 7")


def main():

    if len(sys.argv) != 2:
        usage()
        sys.exit(1)

    try:
        q = int(sys.argv[1])
    except ValueError:
        print("ERROR: q must be an integer")
        sys.exit(1)

    if q < 2:
        print("ERROR: q must be at least 2")
        sys.exit(1)

    output_path = "tools/search/complex_search_code/step1.out"

    webs = load_replaceable_webs(q)

    next_complex_id = first_available_complex_id(q)

    write_magma(
        q,
        webs,
        next_complex_id,
        output_path
    )

    print("q =", q)
    print("Replaceable webs:", len(webs))
    print("First available complex ID number:", next_complex_id)
    print("Wrote", output_path)


if __name__ == "__main__":
    main()
