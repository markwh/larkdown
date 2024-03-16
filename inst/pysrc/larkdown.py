# First go at larkdown.py
from langserve import RemoteRunnable
from langchain.memory import ChatMessageHistory
from langchain_core.messages import SystemMessage


def parse_larkdown_to_tuples(text, open_delim=">", close_delim=">/"):
    """
    Returns a list of tuples
    """
  
    lines = text.split('\n')
    tuples = []
    current_speaker = None
    current_message = []
    ignore_block = False
    message_open = False  # Indicates if we're within an open message block

    for line in lines:
        trimmed_line = line.strip()
        
        if trimmed_line.startswith('<!-- ignore -->'):
            ignore_block = True
        elif trimmed_line.startswith('<!-- endignore -->'):
            ignore_block = False
        elif ignore_block:
            continue
        elif trimmed_line.startswith(close_delim):
            if current_speaker and current_message:
                tuples.append((current_speaker, '\n'.join(current_message)))
                current_message = []
            message_open = False  # Close the current message block
        elif trimmed_line.startswith(open_delim):
            if current_speaker and (current_message or message_open):
                # Close the previous message if it's open or there's content to save
                tuples.append((current_speaker, '\n'.join(current_message)))
                current_message = []
            current_speaker = trimmed_line[len(open_delim):].strip()
            message_open = True  # Mark the message block as open
        elif message_open:
            # Accumulate lines to the current message if a message block is open
            current_message.append(line)

    # Handle the last message if the document ends without a closing delimiter
    if current_speaker and current_message:
        tuples.append((current_speaker, '\n'.join(current_message)))

    return tuples

def parse_larkdown(text, open_delim=">", close_delim=">/"):
    """
    Returns a list of LangChain message objects
    """
    
    tuples = parse_larkdown_to_tuples(text, open_delim=open_delim, close_delim=close_delim)

    chat_history = ChatMessageHistory()
    for role, content in tuples:
        if role == "system":
            chat_history.add_message(SystemMessage(content))
        if role == "human":
            chat_history.add_user_message(content)
        elif role == "ai":
            chat_history.add_ai_message(content)
    
    return chat_history.messages



def append_file(file, text):
    with open(file, 'a') as f:
        f.write(text)

def stream_to_file(messages, endpoint, file):
    # with open(file, 'a') as f:
        # # Append prompt for new AI user message
        # f.write('\n\n>ai\n')
        # for chunk in endpoint.stream({"messages": messages}):
        #     f.write(chunk)
        # # Append prompt for new Human user message
        # f.write('\n\n>human\n')

        # The same using my new append_file function
    append_file(file, '\n\n>ai\n')
    for chunk in endpoint.stream({"messages": messages}):
        append_file(file, chunk)
    append_file(file, '\n\n>human\n')



# main function will need to use argparse to parse the command line arguments
def main():
    import argparse

    # arguments are the file and the endpoint url
    parser = argparse.ArgumentParser(description='Convert larkdown to a stream of messages')
    parser.add_argument('file', help='The file to convert')
    parser.add_argument('endpoint_url', help='The langserve endpoint to use')

    args = parser.parse_args()

    with open(args.file, 'r') as f:
        text = f.read()
    
    messages = parse_larkdown(text)
    endpoint = RemoteRunnable(args.endpoint_url)
    stream_to_file(messages, endpoint, args.file)


if __name__ == '__main__':
    main()
