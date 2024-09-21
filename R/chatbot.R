# chatbot.R
# Functions for working with pre-configured chatbots.


#' Returns the file text for a component of a chatbot's system prompt.
#' 
#' @param chatbot_name name of the chatbot
#' @param piece which piece of the systme prompt--persona, instructions, context, protocol--to get
#' @param root_dir root directory of chatbots
#' @export
read_chatbot_piece <- function(chatbot_name,
                               piece, 
                               root_dir = Sys.getenv("CHATBOT_ROOT")) {
  name <- chatbot_name
  piece_path <- file.path(root_dir, name, piece, sprintf("%s-%s.Rmd", name, piece))
  file_text(piece_path)
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
    protocol = protocol
  )
  out
}