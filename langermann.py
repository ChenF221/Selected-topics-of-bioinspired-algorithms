import numpy as np

def langermann(x, m=5, a=None, b=None, c=None):
    """
    Función de Langermann para dos variables.

    :param x: Lista o array de dos elementos [x1, x2]
    :param m: Número de términos en la suma (por defecto 5)
    :param a: Array de valores 'a_i' (por defecto valores fijos)
    :param b: Array de valores 'b_i' (por defecto valores fijos)
    :param c: Array de valores 'c_i' (por defecto valores fijos)
    :return: Valor de la función Langermann en el punto dado
    """
    x1, x2 = x

    # Valores por defecto si no se proporcionan a, b y c
    if a is None:
        a = np.array([3, 5, 2, 1, 7])
    if b is None:
        b = np.array([5, 2, 1, 4, 9])
    if c is None:
        c = np.array([1, 2, 5, 2, 3])
    
    # Asegurarse de que las listas tienen longitud m
    a = np.array(a[:m])
    b = np.array(b[:m])
    c = np.array(c[:m])
    
    # Calcular el valor de la función Langermann
    result = 0
    for i in range(m):
        dist = (x1 - a[i]) ** 2 + (x2 - b[i]) ** 2
        result += c[i] * np.exp(-dist / np.pi) * np.cos(np.pi * dist)
    
    return -result


x = [2, 1]
resultado = langermann(x)
print(f"Resultado de la función Langermann en {x} es: {resultado:.12f}")
