#!/usr/bin/env python

"""Unit tests for M2Crypto.BIO.File.

Copyright (c) 1999-2002 Ng Pheng Siong. All rights reserved."""

import os, sys
try:
    import unittest2 as unittest
except ImportError:
    import unittest

import M2Crypto
from M2Crypto.BIO import File, openfile

class FileTestCase(unittest.TestCase):

    def setUp(self):
        self.data = 'abcdef' * 64
        if sys.platform != 'win32':
            self.fname = os.tmpnam()
        else:
            import tempfile
            self.fname = tempfile.mktemp()

    def tearDown(self):
        try:
            os.close(self.fd)
        except OSError:
            pass

    def test_openfile_rb(self):
        # First create the file using Python's open().
        f = open(self.fname, 'wb')
        f.write(self.data)
        f.close()
        # Now open the file using M2Crypto.BIO.openfile().
        f = openfile(self.fname, 'rb')
        data = f.read(len(self.data))
        f.close()
        self.assertEqual(data, self.data)

    def test_openfile_wb(self):
        # First create the file using M2Crypto.BIO.openfile().
        f = openfile(self.fname, 'wb')
        f.write(self.data)
        f.close()
        # Now open the file using Python's open().
        f = open(self.fname, 'rb')
        data = f.read(len(self.data))
        f.close()
        self.assertEqual(data, self.data)

    def test_closed(self):
        f = openfile(self.fname, 'wb')
        f.write(self.data)
        f.close()
        with self.assertRaises(IOError):
            f.write(self.data)

    def test_use_pyfile(self):
        # First create the file.
        f = open(self.fname, 'wb')
        f2 = File(f)
        f2.write(self.data)
        f2.close()
        # Now read the file.
        f = open(self.fname, 'rb')
        data = f.read(len(self.data))
        f.close()
        self.assertEqual(data, self.data)


def suite():
    # Python 2.2 warns that os.tmpnam() is unsafe.
    try:
        import warnings
        warnings.filterwarnings('ignore')
    except ImportError:
        pass
    return unittest.makeSuite(FileTestCase)


if __name__ == '__main__':
    unittest.TextTestRunner().run(suite())
