# pylint: disable=no-else-return
def convert_to_number(operand):
    try:
        if isinstance(operand, (int, float)):
            return operand
        if not isinstance(operand, str):
            raise TypeError("El operando no se puede convertir a número")
        if "." in operand:
            return float(operand)
        return int(operand)
    except Exception:
        raise TypeError("El operando no se puede convertir a número")


def InvalidConvertToNumber(operand):
    try:
        if "." in operand:
            return (float(operand))

        return int(operand)

    except ValueError:
        raise TypeError("El operando no se puede convertir a número")


def validate_permissions(operation, user):
    print(f"checking permissions of {user} for operation {operation}")
    return user == "user1"
