"""
Basic tests for WoeUSB-ng
"""

import sys
import os

# Add the parent directory to sys.path to import WoeUSB
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import WoeUSB.miscellaneous as miscellaneous


def test_version():
    """Test that version is defined"""
    assert hasattr(miscellaneous, '__version__')
    assert isinstance(miscellaneous.__version__, str)
    assert len(miscellaneous.__version__) > 0


def test_version_format():
    """Test that version follows semantic versioning pattern"""
    version = miscellaneous.__version__
    parts = version.split('.')
    assert len(parts) >= 2  # At least major.minor
    assert all(part.isdigit() for part in parts[:2])  # Major and minor are digits
