import app
import math


class InvalidPermissions(Exception):
    pass


class Calculator:
    def add(self, x, y):
        self.check_types(x, y)
        return x + y

    def substract(self, x, y):
        self.check_types(x, y)
        return x - y

    def multiply(self, x, y):
        if not app.util.validate_permissions(f"{x} * {y}", "user1"):
            raise InvalidPermissions('El usuario no tiene permisos')
        self.check_types(x, y)
        return x * y

    def divide(self, x, y):
        self.check_types(x, y)
        if y == 0:
            raise TypeError("No es posible dividir por cero")
        return x / y

    def power(self, x, y):
        self.check_types(x, y)
        return x ** y

    def sqrt(self, x):
        if not isinstance(x, (int, float)):
            raise TypeError("El parámetro debe ser un número")
        if x < 0:
            raise TypeError("No se puede calcular la raíz cuadrada de un número negativo")
        return math.sqrt(x)

    def log10(self, x):
        if not isinstance(x, (int, float)):
            raise TypeError("El parámetro debe ser un número")
        if x <= 0:
            raise TypeError("No se puede calcular el logaritmo en base 10 de un número no positivo")
        return math.log10(x)

    def check_types(self, x, y):
        if not isinstance(x, (int, float)) or not isinstance(y, (int, float)):
            raise TypeError("Los parámetros deben ser números")


if __name__ == "__main__":  # pragma: no cover
    calc = Calculator()
    result = calc.add(2, 2)
    print(result)
