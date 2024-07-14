# List-Generation-and-Audio-Convertion
Code in R and Python, to convert a table to an image, and then converting in a .mp3 file

## Description

This project includes two scripts, one in R and one in Python. The R script generates item listings by store, saves the results as text files and graphs in PNG format. The Python script converts these text files into audio files using gTTS.

## Installation

To run these scripts, you need to have R and Python installed on your system.

### R

1. Install R from [CRAN](https://cran.r-project.org/).
2. Install the necessary dependencies:
    ```R
    install.packages(c("readxl", "dplyr", "ggplot2", "writexl"))
    ```

### Python

1. Install Python from [python.org](https://www.python.org/).
2. Install the necessary dependencies:
    ```bash
    pip install gtts requests
    ```

## Usage

### R Script

The R script `generate_listings.R` reads an Excel file with the stock data, generates listings by store, and saves the results as text files and graphs in PNG format.

#### Example Code

```r
# Load necessary libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(writexl)

# Read the Excel file
SURTIDO <- read_excel("path/to/PRUEBA_SURTIDO.xlsx")

# Verify column names
print(names(SURTIDO))

# Get unique stores
stores <- unique(SURTIDO$ID_TIENDA)

# Function to generate listings
generate_listing <- function(store) {
  # Filter data for the current store
  store_data <- SURTIDO %>% filter(ID_TIENDA == store)
  
  # Create listing content
  listing <- store_data %>%
    mutate(Description = paste("Need", CANTIDAD, "items of type", ID_ARTICULO, ART)) %>%
    select(Description)
  
  # Create text plot
  p <- ggplot() +
    annotate("text", x = 0.5, y = seq_along(listing$Description), label = listing$Description, size = 5, hjust = 0.5, vjust = 0.5, color = "black") +
    theme_void() +
    labs(title = paste("Item listing for store", store)) +
    theme(
      plot.title = element_text(hjust = 0.5, color = "black", size = 14, face = "bold"),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(20, 20, 20, 20)
    )
  
  # Adjust plot size
  height <- max(4, nrow(listing) * 0.3 + 2)
  
  # Save plot as .png file
  ggsave(filename = paste0("store_", store, ".png"), plot = p, width = 8, height = height)
}

# Generate listings for all stores
for (store in stores) {
  generate_listing(store)
}

# Function to generate text listing for each store
generate_text_listing_by_store <- function(SURTIDO) {
  # Get unique stores
  stores <- unique(SURTIDO$ID_TIENDA)
  
  # Iterate over each store and generate a text file for each
  for (store in stores) {
    # Filter data for the current store
    store_data <- SURTIDO %>% filter(ID_TIENDA == store)
    
    # Create listing content
    listing <- store_data %>%
      mutate(Description = paste("Need", CANTIDAD, "items of type", ID_ARTICULO, ART)) %>%
      select(Description)
    
    # Create listing text
    text <- paste("Item listing for store", store, ":\n", paste(listing$Description, collapse = "\n"))
    
    # Save text to a file
    text_file <- paste0("store_", store, ".txt")
    writeLines(text, text_file)
    
    # Print the path of the generated text file
    print(paste("Text file generated for store", store, ":", text_file))
  }
}

# Call the function to generate text listings by store
generate_text_listing_by_store(SURTIDO)

```

## Python Script

The Python script convert_text_to_audio.py reads the text files generated by the R script and converts them into audio files using gTTS.

#### Example Code

```py
from gtts import gTTS
import os
import time
import requests

# Directory where the text files are located
text_dir = 'path/to/text_files/'

# Directory where the audio files will be saved
audio_dir = 'path/to/audio_files/'

# Check if the directory for audio files exists, if not, create it
if not os.path.exists(audio_dir):
    os.makedirs(audio_dir)

# Function to convert text to speech with retries
def convert_text_to_speech(text, audio_file, retries=3, wait=5):
    for attempt in range(retries):
        try:
            # Convert text to speech using gTTS
            tts = gTTS(text=text, lang='en')
            # Save the audio file
            tts.save(audio_file)
            print(f'Audio file generated: {audio_file}')
            return
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 429:
                print(f'Error 429 (Too Many Requests): You have reached the request limit. Waiting longer. Attempt {attempt + 1} of {retries}')
                time.sleep(wait * (attempt + 1))  # Incremental wait
            else:
                print(f'Unexpected HTTP error: {e}. Attempt {attempt + 1} of {retries}')
                time.sleep(wait)
        except requests.exceptions.RequestException as e:
            print(f'Error connecting to Google service: {e}. Attempt {attempt + 1} of {retries}')
            time.sleep(wait)
        except Exception as e:
            print(f'Unexpected error while generating audio file: {e}. Attempt {attempt + 1} of {retries}')
            time.sleep(wait)
    print(f'Error: Could not generate audio file after {retries} attempts')

# Iterate over each text file in the directory
for text_file in os.listdir(text_dir):
    if text_file.endswith('.txt'):
        try:
            # Define the audio file
            audio_file = os.path.join(audio_dir, os.path.splitext(text_file)[0] + '.mp3')
            
            # Check if the audio file already exists
            if os.path.exists(audio_file):
                print(f'The audio file already exists: {audio_file}')
                continue
            
            # Read the content of the text file
            with open(os.path.join(text_dir, text_file), 'r', encoding='utf-8') as f:
                text = f.read()
            
            # Convert text to speech with retries
            convert_text_to_speech(text, audio_file)
        except FileNotFoundError as e:
            print(f'Error: The file {text_file} was not found: {e}')
        except IOError as e:
            print(f'I/O error processing the file {text_file}: {e}')
        except Exception as e:
            print(f'Error processing the file {text_file}: {e}')

```

## Example Workflow

Example Workflow

Below is an example of how the scripts work together:

    Run the R Script: Generates text files and images of item listings by store.
        Input: Excel file with stock data.
        Output: Text files and PNG images.

Rscript generate_listings.R

Run the Python Script: Converts the text files into audio files.

    Input: Text files generated by the R script.
    Output: MP3 audio files.

python convert_text_to_audio.py

## Example Outputs

## Example Outputs

### Stock Data (Excel)

| ID_TIENDA | ID_ARTICULO | ART  | CANTIDAD |
|-----------|-------------|------|----------|
| 1         | 123         | ITEM 123  | 10       |
| 1         | 456         | ITEM 456  | 5        |
| 2         | 789         | ITEM 789  | 7        |
| 2         | 101         | ITEM 101  | 3        |
| 3         | 21         | ITEM 21  | 5       |
| 3         | 15         | ITEM 15  | 5        |
| 3         | 14         | ITEM 14  | 5        |
| 3         | 13         | ITEM 13  | 2        |
| 3         | 11         | ITEM 11  | 2        |

### Text File

Item listing for store 1:

- Need 10 items of type 123 ABC
- Need 5 items of type 456 DEF

## Image

![Example Listing for Store 3](tienda_3_example.png)

## Audio

The audio file corresponding to the above text file will be generated and saved in the specified directory.

![Ejemplo de archivo de audio](tienda_3_example.mp3)

## Contribution

Contributions are welcome. Please open an issue or pull request to discuss any changes.




