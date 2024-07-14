from gtts import gTTS
import os
import time
import requests

# Directorio donde se encuentran los archivos de texto
directorio_texto = 'C:/Users/EUCLID/Desktop/Directorio/62_Generacion_Pedidos/archivos_txt/'

# Directorio donde se guardarán los archivos de audio
directorio_audio = 'C:/Users/EUCLID/Desktop/Directorio/62_Generacion_Pedidos/archivos_audio/'

# Verifica si el directorio para los archivos de audio existe, si no, créalo
if not os.path.exists(directorio_audio):
    os.makedirs(directorio_audio)

# Función para convertir texto en voz con reintentos
def convertir_texto_a_voz(texto, archivo_audio, reintentos=3, espera=5):
    for intento in range(reintentos):
        try:
            # Convierte el texto en voz utilizando gTTS
            tts = gTTS(text=texto, lang='es')
            # Guarda el archivo de audio
            tts.save(archivo_audio)
            print(f'Archivo de audio generado: {archivo_audio}')
            return
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 429:
                print(f'Error 429 (Too Many Requests): Has alcanzado el límite de solicitudes. Esperando más tiempo. Intento {intento + 1} de {reintentos}')
                time.sleep(espera * (intento + 1))  # Espera incremental
            else:
                print(f'Error HTTP inesperado: {e}. Intento {intento + 1} de {reintentos}')
                time.sleep(espera)
        except requests.exceptions.RequestException as e:
            print(f'Error al conectar con el servicio de Google: {e}. Intento {intento + 1} de {reintentos}')
            time.sleep(espera)
        except Exception as e:
            print(f'Error inesperado al intentar generar el archivo de audio: {e}. Intento {intento + 1} de {reintentos}')
            time.sleep(espera)
    print(f'Error: No se pudo generar el archivo de audio después de {reintentos} intentos')

# Itera sobre cada archivo de texto en el directorio
for archivo_texto in os.listdir(directorio_texto):
    if archivo_texto.endswith('.txt'):
        try:
            # Define el archivo de audio
            archivo_audio = os.path.join(directorio_audio, os.path.splitext(archivo_texto)[0] + '.mp3')
            
            # Verifica si el archivo de audio ya existe
            if os.path.exists(archivo_audio):
                print(f'El archivo de audio ya existe: {archivo_audio}')
                continue
            
            # Lee el contenido del archivo de texto
            with open(os.path.join(directorio_texto, archivo_texto), 'r', encoding='latin1') as f:
                texto = f.read()
            
            # Convierte el texto en voz con reintentos
            convertir_texto_a_voz(texto, archivo_audio)
        except FileNotFoundError as e:
            print(f'Error: El archivo {archivo_texto} no fue encontrado: {e}')
        except IOError as e:
            print(f'Error de E/S al procesar el archivo {archivo_texto}: {e}')
        except Exception as e:
            print(f'Error procesando el archivo {archivo_texto}: {e}')

