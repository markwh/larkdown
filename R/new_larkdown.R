
#' Creates a new Rmarkdown file with a Larkdown template, then opens the file
#'
#' @param filename path to save Rmarkdown file
#' @param system_message optional character, uses a simple default if not specified
#' @param message_list optional list of messages to populate larkdown conversation
#' @param header_text optional text to insert before the system prompt
#' @param template which template file to use
#' @param open if TRUE (default), open the document in the Rstudio IDE
#' 
#' @export
new_larkdown <- function(filename = ts_filename(prefix = "larkdown"), 
                         system_message = NULL,
                         message_list = list(),
                         header_text = "",
                         template="larkdown-glue",
                         open = TRUE) {
  
  # Get system message
  system_message_from_list <- get_system_message_text(message_list)
  default_system_message <- "You are a helpful assistant."
  
  system_message <- if (!is.null(system_message)) {
    system_message
  } else if (!is.na(system_message_from_list)) {
    system_message_from_list
  } else {
    default_system_message
  }
  
  # Write the template file
  prompt_chr <- getOption("ld_prompt", default = "@")[1]
  rmarkdown::draft(filename, 
                   template = template, 
                   package = "larkdown", 
                   edit = FALSE)
  
  text_raw <- file_text(filename)
  text_filled <- glue::glue(text_raw, 
                            header_text = header_text,
                            ld_prompt = prompt_chr,
                            system_prompt = system_message, 
                            .open = "{{", 
                            .close = "}}",
                            .trim = FALSE)
  
  cat(text_filled, file = filename, append = FALSE)
  
  message_types <- purrr::map_chr(message_list, ~ld_message_type(.))
  convo_messages <- message_list[message_types != "system"]
  convo_text <- ld_convo_text(message_list = convo_messages)
  
  # Add a human prompt unless the last message is a human message
  last_message_type <- if (!length(message_types)) "system" else 
      message_types[length(message_types)] 
  
  if (last_message_type != "human") {
    convo_text <- paste(convo_text, sprintf("\n\n%shuman\n", prompt_chr))
  }
  
  cat(convo_text, file = filename, append = TRUE)
  
  if (open) 
    rstudioapi::documentOpen(filename)
  
  invisible(filename)
}


#' Launches a journaling session for the current day. 
#' 
#' @param base_path directory in which to save the journal
#' @param date Which date to open journal for, defaults to today's date
#' 
#' @export
journal <- function(base_path = Sys.getenv("LARKDOWN_DIR"), date = Sys.Date()) {
  
  stopifnot(length(date) == 1L, lubridate::is.Date(date))
  
  filename <- file.path(base_path,
                        sprintf("notebook%s.Rmd", format(date, "%Y%m%d")))
  if (file.exists(filename)) {
    rstudioapi::documentOpen(filename)
  } else {
    new_larkdown(filename, template = "larkdown-journal")
  }
  return(TRUE)
}

#' Returns "system", "human", or "ai"
#' 
#' @param message LangChain `BaseMessage` object
#' @export
ld_message_type <- function(message) {
  out <- case_when(
    grepl("SystemMessage$", class(message)[1]) ~ "system",
    grepl("HumanMessage$", class(message)[1]) ~ "human",
    grepl("AIMessage$", class(message)[1]) ~ "ai",
    TRUE ~ NA_character_
  )
  out
}

#' Creates a larkdown-formatted character string from a list of messages
#' 
#' Used to populate a larkdown file (which is just a textfile) from a message list
#' 
#' @param message_list a list of LangChain `BaseMessage` objects
#' @param larkdown_prompt Larkdown prompt character to use, defaults to `"@"`
#' 
#' @export
ld_convo_text <- function(message_list, larkdown_prompt = "@") {
  message_fmt_list <- message_list %>% 
    purrr::map(~glue::glue(
      "{ld_prompt}{msg_type}\n\n{msg_txt}",
      ld_prompt = larkdown_prompt,
      msg_type =ld_message_type(.),
      msg_txt = .$content))
  out <- paste(message_fmt_list, collapse = "\n")
  out
}

#' Returns a character string with the text of a message lists's system message
#'
#' @param message_list a list of LangChain `BaseMessage` objects
#' 
#' @export
get_system_message_text <- function(message_list) {
  message_types <- purrr::map_chr(message_list, ~ld_message_type(.))
  system_message <- message_list[message_types == "system"]
  
  if (length(system_message) != 1L) return(NA_character_)
  
  out <- system_message[[1]][["content"]]
  out
}

