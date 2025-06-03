import unittest
import pytest

from app import util


@pytest.mark.unit
class TestUtil(unittest.TestCase):
    def test_convert_to_number_correct_param(self):
        self.assertEqual(4, util.convert_to_number("4"))
        self.assertEqual(0, util.convert_to_number("0"))
        self.assertEqual(0, util.convert_to_number("-0"))
        self.assertEqual(-1, util.convert_to_number("-1"))
        self.assertAlmostEqual(4.0, util.convert_to_number("4.0"), delta=0.0000001)
        self.assertAlmostEqual(0.0, util.convert_to_number("0.0"), delta=0.0000001)
        self.assertAlmostEqual(0.0, util.convert_to_number("-0.0"), delta=0.0000001)
        self.assertAlmostEqual(-1.0, util.convert_to_number("-1.0"), delta=0.0000001)

    def test_convert_to_number_invalid_type(self):
        self.assertRaisesRegex(TypeError, "El operando no se puede convertir a número", util.convert_to_number, "")
        self.assertRaisesRegex(TypeError, "El operando no se puede convertir a número", util.convert_to_number, "3.h")
        self.assertRaisesRegex(TypeError, "El operando no se puede convertir a número", util.convert_to_number, "s")
        self.assertRaisesRegex(TypeError, "El operando no se puede convertir a número", util.convert_to_number, None)
        self.assertRaisesRegex(TypeError, "El operando no se puede convertir a número", util.convert_to_number, object())
