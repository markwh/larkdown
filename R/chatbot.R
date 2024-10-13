# chatbot.R
# Functions for working with pre-configured chatbots.


#' Returns the file text for a component of a chatbot's system prompt.
#' 
#' @param name name of the chatbot
#' @param piece which piece of the systme prompt--persona, instructions, context, protocol--to get
#' @param root_dir root directory of chatbots
#' @export
read_chatbot_piece <- function(name,
                               piece, 
                               root_dir = Sys.getenv("CHATBOT_ROOT")) {
  piece_path <- chatbot_piece_path(name, piece, root_dir)
  file_text(piece_path)
}

#' Opens the chatbot piece file in rstudio
#' 
#' @inheritParams read_chatbot_piece
#' @export
edit_chatbot_piece <- function(name,
                               piece, 
                               root_dir = Sys.getenv("CHATBOT_ROOT")){
  
  piece_path <- chatbot_piece_path(name, piece, root_dir)
  rstudioapi::documentOpen(piece_path)
  return(invisible(piece_path)) 
}

#' Returns the file path for a chatbot piece
#' @inheritParams read_chatbot_piece
#' @export
chatbot_piece_path <- function(name,
                               piece, 
                               root_dir = Sys.getenv("CHATBOT_ROOT")) {
  file.path(root_dir, name, piece, sprintf("%s-%s.Rmd", name, piece))
}

#' Returns the system prompt for a chatbot
#'
#' To be used with `larkdown::new_larkdown()`
#' @inheritParams read_chatbot_piece
#' @export
chatbot_sys_prompt <- function(chatbot_name, root_dir = Sys.getenv("CHATBOT_ROOT")) {
  name <- chatbot_name
  persona <- read_chatbot_piece(name, "persona", root_dir)
  context <- read_chatbot_piece(name, "context", root_dir)
  instructions <- read_chatbot_piece(name, "instructions", root_dir)
  protocol <- read_chatbot_piece(name, "protocol", root_dir)  
  
  # out <- glue::glue(sys_prompt_glue_tmpl, persona, instructions, context, protocol)
  out <- glue::glue(
    "{persona}", "{instructions}", "{context}", "{protocol}",
    persona = persona, 
    instructions = instructions,
    context = context,
    protocol = protocol,
    .trim = FALSE
  )
  out
}

#' List all currently available chatbots
#' 
#' @inheritParams read_chatbot_piece
#' @export
list_chatbots <- function(root_dir = Sys.getenv("CHATBOT_ROOT")) {
  list.files(root_dir)
}

#' Helper function to create files and directories as needed
#' @inheritParams read_chatbot_piece
#' @param edit if TRUE, open files for editing
create_path <- function(base_dir, path, edit = FALSE) {
  full_path <- file.path(base_dir, path)
  
  # If the path ends with a file extension, treat it as a file
  if (grepl("\\.", basename(full_path))) {
    # Create the necessary directories for the file
    dir.create(dirname(full_path), recursive = TRUE, showWarnings = FALSE)
    # Create the empty file
    file.create(full_path)
    
    if (edit) rstudioapi::documentOpen(full_path)
  } else {
    # Otherwise, treat it as a directory
    dir.create(full_path, recursive = TRUE, showWarnings = FALSE)
  }
}

#' Creates a new chatbot config directory 
#' @inheritParams read_chatbot_piece
#' @param edit if TRUE, open files for editing
#' @export
new_chatbot <- function(name, edit = TRUE) {
  # Get the root directory from the environment variable
  root_dir <- Sys.getenv("CHATBOT_ROOT")
  
  # Check if the root directory is set
  if (root_dir == "") {
    stop("The CHATBOT_ROOT environment variable is not set.")
  }
  
  # Construct the base directory path for the new chatbot
  base_dir <- file.path(root_dir, name)
  
  # Define the directory structure--could change in future
  dir_structure <- list(
    context = file.path("context", paste0(name, "-context.Rmd")),
    instructions = file.path("instructions", paste0(name, "-instructions.Rmd")),
    persona = file.path("persona", paste0(name, "-persona.Rmd")),
    protocol = file.path("protocol", paste0(name, "-protocol.Rmd")),
    tools = "tools"
  )
  
  # Apply the create_path function to each path in the directory structure
  lapply(dir_structure, create_path, base_dir = base_dir, edit = edit)
  
  # Return the base directory path for reference
  return(base_dir)
}