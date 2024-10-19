# Image generating functions

#' Create an image using Dall-E
#' 
#' @param prompt the image-generation prompt
#' @param model model name
#' @param size resolution of image
#' @param quality quality of image
#' @param n Number of images to generate
#' 
#' @export
dalle_image <- function(
    prompt,
    model = "dall-e-3", 
    size = "1024x1024",
    quality = "standard",
    n = 1L
){
  openai <- reticulate::import("openai")
  client <- openai$OpenAI()
  
  response <- client$images$generate(
    model = model,
    prompt = prompt,
    size = size,
    quality = quality,
    n = n
  )
  
  image_url <- response$data[[1]]$url
  
  print(image_url)
  
  # Use httr to download the image
  response <- httr::GET(image_url)
  
  # Check if the download was successful
  if (httr::status_code(response) == 200) {
    # Use magick to read the image from the raw content
    image <- magick::image_read(httr::content(response, "raw"))
    
    # Display the image
    print(image)
  } else {
    cat("Failed to download the image. Status code:", status_code(response), "\n")
  }
  
  return(image)
}