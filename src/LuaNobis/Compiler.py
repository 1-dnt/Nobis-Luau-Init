import os
import re

NOBIS_PATH = "Nobis.lua"
if not os.path.isfile(NOBIS_PATH):
    NOBIS_PATH = "LuaNobis/Nobis.lua"

def buscar_archivo_sin_extension(ruta_base):
    carpeta, nombre = os.path.split(ruta_base)
    if carpeta == "":
        carpeta = "."

    if not os.path.isdir(carpeta):
        return None

    for file in os.listdir(carpeta):
        file_no_ext, ext = os.path.splitext(file)
        if file_no_ext == nombre:
            return os.path.join(carpeta, file)

    return None

def procesar_require(ruta):
    archivo = buscar_archivo_sin_extension(ruta)
    if archivo is None:
        archivo = buscar_archivo_sin_extension("LuaNobis/" + ruta)
        if archivo is None:
            return f"-- Error: No se encontró archivo para {ruta}\n"

    with open(archivo, "r", encoding="utf-8") as f:
        lineas = f.readlines()

    if not lineas:
        return ""
    
    primera = lineas[0]
    primera_sin_return = re.sub(r'\breturn \b', '', primera, count=1)

    lineas[0] = primera_sin_return

    return "".join(lineas).rstrip("\n")


def main():
    if not os.path.isfile(NOBIS_PATH):
        print("No se encontró Nobis.lua")
        return

    with open(NOBIS_PATH, "r", encoding="utf-8") as f:
        original = f.readlines()

    resultado = []
    
    patron = re.compile(r'require\s*\(\s*["\'](.*?)["\']\s*\)')

    for linea in original:
        match = patron.search(linea)
        if match:
            ruta = match.group(1)
            contenido = procesar_require(ruta)
            nueva_linea = patron.sub(lambda m: contenido, linea) # Si no usamos lambda los \n se convierten

            resultado.append(nueva_linea + "\n")
        else:
            resultado.append(linea)

    carpeta_actual = os.path.dirname(os.path.abspath(NOBIS_PATH))
    carpeta_superior = os.path.dirname(carpeta_actual)
    destino = os.path.join(carpeta_superior, "init.lua")

    with open(destino, "w", encoding="utf-8") as f:
        f.writelines(resultado)

    print("Init compiled into:", destino)

if __name__ == "__main__":
    main()
