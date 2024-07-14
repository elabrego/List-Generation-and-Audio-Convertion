# Cargar las librer?as necesarias
library(readxl)
library(dplyr)
library(ggplot2)
library(writexl)

# Leer el archivo de Excel
SURTIDO <- read_excel("C:/Users/EUCLID/Desktop/Directorio/62_Generacion_Pedidos/PRUEBA_SURTIDO.xlsx")

# Verificar los nombres de las columnas
print(names(SURTIDO))

# Obtener las tiendas ?nicas
tiendas <- unique(SURTIDO$ID_TIENDA)

# Definir funci?n para generar listados
generar_listado <- function(tienda) {
  # Filtrar los datos para la tienda actual
  data_tienda <- SURTIDO %>% filter(ID_TIENDA == tienda)
  
  # Crear el contenido del listado
  listado <- data_tienda %>%
    mutate(Descripcion = paste("Se necesitan", CANTIDAD, "articulos del tipo", ID_ARTICULO, ART)) %>%
    select(Descripcion)
  
  # Crear el gr?fico de texto
  listado_texto <- paste(listado$Descripcion, collapse = "\n")
  p <- ggplot() +
    annotate("text", x = 0.5, y = seq_along(listado$Descripcion), label = listado$Descripcion, size = 5, hjust = 0.5, vjust = 0.5, color = "black") +
    theme_void() +
    labs(title = paste("Listado de articulos para la tienda", tienda)) +
    theme(
      plot.title = element_text(hjust = 0.5, color = "black", size = 14, face = "bold"),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(20, 20, 20, 20)
    )
  
  # Ajustar el tama?o del gr?fico
  height <- max(4, nrow(listado) * 0.3 + 2)
  
  # Guardar el gr?fico como archivo .png
  ggsave(filename = paste0("tienda_", tienda, ".png"), plot = p, width = 8, height = height)
}

# Generar listados para todas las tiendas
for (tienda in tiendas) {
  generar_listado(tienda)
}

# Define la funci?n para generar el listado de texto para cada tienda
generar_listado_texto_por_tienda <- function(SURTIDO) {
  # Obt?n la lista de tiendas ?nicas
  tiendas <- unique(SURTIDO$ID_TIENDA)
  
  # Itera sobre cada tienda y genera un archivo de texto para cada una
  for (tienda in tiendas) {
    # Filtra los datos para la tienda actual
    data_tienda <- SURTIDO %>% filter(ID_TIENDA == tienda)
    
    # Crea el contenido del listado
    listado <- data_tienda %>%
      mutate(Descripcion = paste("Se necesitan", CANTIDAD, "articulos del tipo", ID_ARTICULO, ART)) %>%
      select(Descripcion)
    
    # Crea el texto del listado
    texto <- paste("Listado de articulos para la tienda", tienda, ":\n", paste(listado$Descripcion, collapse = "\n"))
    
    # Guarda el texto en un archivo temporal
    archivo_texto <- paste0("tienda_", tienda, ".txt")
    writeLines(texto, archivo_texto)
    
    # Imprime la ruta del archivo de texto generado
    print(paste("Archivo de texto generado para la tienda", tienda, ":", archivo_texto))
  }
}

# Llama a la funci?n para generar el listado de texto por tienda
generar_listado_texto_por_tienda(SURTIDO)
