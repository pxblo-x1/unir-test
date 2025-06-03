import unittest
from unittest.mock import patch
import pytest

from app.calc import Calculator


def mocked_validation(*args, **kwargs):
    return True


@pytest.mark.unit
class TestCalculate(unittest.TestCase):
    def setUp(self):
        self.calc = Calculator()

    def test_add_method_returns_correct_result(self):
        self.assertEqual(4, self.calc.add(2, 2))
        self.assertEqual(0, self.calc.add(2, -2))
        self.assertEqual(0, self.calc.add(-2, 2))
        self.assertEqual(1, self.calc.add(1, 0))

    def test_divide_method_returns_correct_result(self):
        self.assertEqual(1, self.calc.divide(2, 2))
        self.assertEqual(1.5, self.calc.divide(3, 2))

    def test_add_method_fails_with_nan_parameter(self):
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, "2", 2)
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, 2, "2")
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, "2", "2")
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, None, 2)
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, 2, None)
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, object(), 2)
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.add, 2, object())

    def test_divide_method_fails_with_nan_parameter(self):
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.divide, "2", 2)
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.divide, 2, "2")
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.divide, "2", "2")

    def test_divide_method_fails_with_division_by_zero(self):
        self.assertRaisesRegex(TypeError, "No es posible dividir por cero", self.calc.divide, 2, 0)
        self.assertRaisesRegex(TypeError, "No es posible dividir por cero", self.calc.divide, 2, -0)
        self.assertRaisesRegex(TypeError, "No es posible dividir por cero", self.calc.divide, 0, 0)
        self.assertRaisesRegex(TypeError, "Los parámetros deben ser números", self.calc.divide, "0", 0)

    @patch('app.util.validate_permissions', side_effect=mocked_validation, create=True)
    def test_multiply_method_returns_correct_result(self, _validate_permissions):
        self.assertEqual(4, self.calc.multiply(2, 2))
        self.assertEqual(0, self.calc.multiply(1, 0))
        self.assertEqual(0, self.calc.multiply(-1, 0))
        self.assertEqual(-2, self.calc.multiply(-1, 2))

    def test_sqrt_method_returns_correct_result(self):
        self.assertEqual(3, self.calc.sqrt(9))
        self.assertEqual(0, self.calc.sqrt(0))
        self.assertAlmostEqual(1.41421356, self.calc.sqrt(2), places=6)

    def test_sqrt_method_fails_with_negative(self):
        self.assertRaisesRegex(TypeError, "No se puede calcular la raíz cuadrada de un número negativo", self.calc.sqrt, -1)
        self.assertRaisesRegex(TypeError, "El parámetro debe ser un número", self.calc.sqrt, "4")
        self.assertRaisesRegex(TypeError, "El parámetro debe ser un número", self.calc.sqrt, None)

    def test_log10_method_returns_correct_result(self):
        self.assertEqual(0, self.calc.log10(1))
        self.assertEqual(1, self.calc.log10(10))
        self.assertAlmostEqual(2, self.calc.log10(100), places=6)

    def test_log10_method_fails_with_nonpositive(self):
        self.assertRaisesRegex(TypeError, "No se puede calcular el logaritmo en base 10 de un número no positivo", self.calc.log10, 0)
        self.assertRaisesRegex(TypeError, "No se puede calcular el logaritmo en base 10 de un número no positivo", self.calc.log10, -10)
        self.assertRaisesRegex(TypeError, "El parámetro debe ser un número", self.calc.log10, "10")
        self.assertRaisesRegex(TypeError, "El parámetro debe ser un número", self.calc.log10, None)


if __name__ == "__main__":  # pragma: no cover
    unittest.main()
