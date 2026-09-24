#!/usr/bin/env python3
# Python 3 port - 2026-09-11.
"""Compile complexes.jsonl into a Magma-readable discovery catalog.

Run from the repository root:
    python3 tools/build_complex_catalog.py

Default input:  complexes.jsonl
Default output: library/complex-catalog.m

No JSON module is required; this contains the same small JSON parser used by
build_web_catalog.py.
"""

import getopt
import os
import sys


class JSONError(Exception):
    pass


class JSONParser(object):
    def __init__(self, text):
        self.text = text
        self.n = len(text)
        self.i = 0

    def parse(self):
        self._ws()
        v = self._value()
        self._ws()
        if self.i != self.n:
            raise JSONError("extra data at character %d" % (self.i + 1))
        return v

    def _ws(self):
        while self.i < self.n and self.text[self.i] in " \t\r\n":
            self.i += 1

    def _value(self):
        self._ws()
        if self.i >= self.n:
            raise JSONError("unexpected end of input")
        c = self.text[self.i]
        if c == '{':
            return self._object()
        if c == '[':
            return self._array()
        if c == '"':
            return self._string()
        if c == '-' or ('0' <= c <= '9'):
            return self._number()
        if self.text.startswith("true", self.i):
            self.i += 4
            return True
        if self.text.startswith("false", self.i):
            self.i += 5
            return False
        if self.text.startswith("null", self.i):
            self.i += 4
            return None
        raise JSONError("unexpected character at %d" % (self.i + 1))

    def _object(self):
        d = {}
        self.i += 1
        self._ws()
        if self.i < self.n and self.text[self.i] == '}':
            self.i += 1
            return d
        while 1:
            self._ws()
            if self.i >= self.n or self.text[self.i] != '"':
                raise JSONError("expected object key")
            k = self._string()
            self._ws()
            if self.i >= self.n or self.text[self.i] != ':':
                raise JSONError("expected ':'")
            self.i += 1
            d[k] = self._value()
            self._ws()
            if self.i >= self.n:
                raise JSONError("unterminated object")
            if self.text[self.i] == '}':
                self.i += 1
                return d
            if self.text[self.i] != ',':
                raise JSONError("expected ',' or '}'")
            self.i += 1

    def _array(self):
        a = []
        self.i += 1
        self._ws()
        if self.i < self.n and self.text[self.i] == ']':
            self.i += 1
            return a
        while 1:
            a.append(self._value())
            self._ws()
            if self.i >= self.n:
                raise JSONError("unterminated array")
            if self.text[self.i] == ']':
                self.i += 1
                return a
            if self.text[self.i] != ',':
                raise JSONError("expected ',' or ']' ")
            self.i += 1

    def _string(self):
        self.i += 1
        out = []
        while self.i < self.n:
            c = self.text[self.i]
            self.i += 1
            if c == '"':
                return ''.join(out)
            if c != '\\':
                out.append(c)
                continue
            if self.i >= self.n:
                raise JSONError("unterminated escape")
            e = self.text[self.i]
            self.i += 1
            table = {'"':'"','\\':'\\','/':'/','b':'\b','f':'\f','n':'\n','r':'\r','t':'\t'}
            if e in table:
                out.append(table[e])
            elif e == 'u':
                raw = self.text[self.i:self.i+4]
                if len(raw) != 4:
                    raise JSONError("short unicode escape")
                self.i += 4
                code = int(raw, 16)
                out.append(chr(code))
            else:
                raise JSONError("invalid escape")
        raise JSONError("unterminated string")

    def _number(self):
        start = self.i
        if self.text[self.i] == '-':
            self.i += 1
        while self.i < self.n and self.text[self.i].isdigit():
            self.i += 1
        return int(self.text[start:self.i])


def mstr(s):
    return '"' + s.replace('\\','\\\\').replace('"','\\"') + '"'


def mints(a):
    return '[' + ','.join([str(int(x)) for x in a]) + ']'


def mstrings(a):
    return '[' + ','.join([mstr(x) for x in a]) + ']'


def mcircles(circles):
    return '[' + ','.join([mints(c) for c in circles]) + ']'


def mcomponents(components):
    return '[' + ','.join([mcircles(c['circles']) for c in components]) + ']'


def usage():
    sys.stdout.write("usage: build_complex_catalog.py [--input complexes.jsonl] [--output library/complex-catalog.m]\n")


def main(argv):
    input_path = 'complexes.jsonl'
    output_path = os.path.join('library', 'complex-catalog.m')

    try:
        opts, args = getopt.getopt(argv, '', ['input=', 'output=', 'help'])
    except getopt.GetoptError:
        sys.stderr.write(str(sys.exc_info()[1]) + "\n")
        usage()
        return 2

    for k, v in opts:
        if k == '--input':
            input_path = v
        elif k == '--output':
            output_path = v
        elif k == '--help':
            usage()
            return 0

    if args:
        usage()
        return 2

    rows = []
    fh = open(input_path, 'r')
    line_no = 0

    for raw in fh:
        line_no += 1
        raw = raw.strip()
        if not raw:
            continue
        try:
            r = JSONParser(raw).parse()
        except Exception:
            raise RuntimeError('%s line %d: %s' % (input_path, line_no, sys.exc_info()[1]))

        for key in ['id', 'q', 'components']:
            if key not in r:
                raise RuntimeError('line %d missing %s' % (line_no, key))

        components = r['components']
        if not isinstance(components, list) or len(components) == 0:
            raise RuntimeError('%s has no components' % r['id'])

        web_ids = []
        circle_count = 0
        component_circle_counts = []

        for c in components:
            if not isinstance(c, dict):
                raise RuntimeError('%s has a non-object component' % r['id'])
            if 'webID' not in c or 'circles' not in c:
                raise RuntimeError('%s component missing webID or circles' % r['id'])
            web_ids.append(c['webID'])
            component_circle_counts.append(len(c['circles']))
            circle_count += len(c['circles'])

        # Component order is not part of the complex.  Store a sorted copy as
        # a cheap isomorphism signature while preserving serializedComponents
        # exactly as supplied for reconstruction of the representative.
        sorted_web_ids = web_ids[:]
        sorted_web_ids.sort()
        sorted_counts = component_circle_counts[:]
        sorted_counts.sort()

        r['_componentWebIDs'] = sorted_web_ids
        r['_componentCircleCounts'] = sorted_counts
        r['_circleCount'] = circle_count
        rows.append(r)

    fh.close()

    outdir = os.path.dirname(output_path)
    if outdir and not os.path.isdir(outdir):
        os.makedirs(outdir)

    out = open(output_path, 'w')
    out.write('/* Auto-generated from complexes.jsonl. Do not edit by hand. */\n')
    out.write('complexCatalogRF := recformat<id,q,circleCount,componentCount,componentWebIDs,componentCircleCounts,serializedComponents>;\n')
    out.write('complexCatalog := [\n')

    for i, r in enumerate(rows):
        comma = ''
        if i + 1 < len(rows):
            comma = ','
        out.write('  rec<complexCatalogRF | id := %s, q := %d, circleCount := %d, componentCount := %d, componentWebIDs := %s, componentCircleCounts := %s, serializedComponents := %s>%s\n' % (
            mstr(r['id']), int(r['q']), int(r['_circleCount']), len(r['components']),
            mstrings(r['_componentWebIDs']), mints(r['_componentCircleCounts']),
            mcomponents(r['components']), comma))

    out.write('];\n')
    out.close()

    sys.stdout.write('Wrote %d complex catalog records to %s\n' % (len(rows), output_path))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
