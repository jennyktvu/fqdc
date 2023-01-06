import pytest
from myproject import analyze


def test_normal_operation():
    assert analyze.process(3, 5) == 10


def test_invalid_argument():
    with pytest.raises(ValueError):
        analyze.process(-1, -1)
