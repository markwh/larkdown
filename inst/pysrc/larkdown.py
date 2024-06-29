from langserve import RemoteRunnable
from langchain.memory import ChatMessageHistory
from langchain_core.messages import SystemMessage

def parse_larkdown_to_tuples(text, larkdown_prompt):
    """
    Returns a list of tuples
    """
    larkdown_identifiers = ['system', 'human', 'ai', '/', 'ignore', 'endignore']
    lines = text.strip().split('\n')
    tuples = []
    current_speaker = None
    current_message = []
    ignore_block = False
    message_open = False  # Indicates if we're within an open message block

    for line in lines:
        trimmed_line = line.strip()
        
        if ignore_block:
            if any(trimmed_line.startswith(f'{prompt}endignore') for prompt in larkdown_prompt):
                ignore_block = False
            continue
        
        if any(trimmed_line.startswith(f'{prompt}{identifier}') for prompt in larkdown_prompt for identifier in larkdown_identifiers):
            larkdown_identifier = next((identifier for identifier in larkdown_identifiers 
                                        if any(trimmed_line.startswith(f'{prompt}{identifier}') for prompt in larkdown_prompt)), None)
            if larkdown_identifier == 'ignore':
                ignore_block = True
                continue
            
            if current_speaker and current_message:
                tuples.append((current_speaker, '\n'.join(current_message).strip()))
                current_message = []
            
            if larkdown_identifier == '/':
                current_speaker = None
                message_open = False
            else:
                current_speaker = larkdown_identifier
                message_open = True
        elif message_open:
            current_message.append(line)

    # Handle the last message if the document ends without a closing delimiter
    if current_speaker and current_message:
        tuples.append((current_speaker, '\n'.join(current_message)))

    return tuples

def parse_larkdown(text, larkdown_prompt):
    """
    Returns a list of LangChain message objects
    """
    tuples = parse_larkdown_to_tuples(text, larkdown_prompt)

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
    append_file(file, '\n\n>ai\n')
    for chunk in endpoint.stream({"messages": messages}):
        append_file(file, chunk)
    append_file(file, '\n\n>human\n')

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Convert larkdown to a stream of messages')
    parser.add_argument('file', help='The file to convert')
    parser.add_argument('endpoint_url', help='The langserve endpoint to use')
    parser.add_argument('larkdown_prompt', nargs='+', help='The larkdown prompts to use for parsing')

    args = parser.parse_args()

    with open(args.file, 'r') as f:
        text = f.read()
    
    messages = parse_larkdown(text, args.larkdown_prompt)
    endpoint = RemoteRunnable(args.endpoint_url)
    stream_to_file(messages, endpoint, args.file)

if __name__ == '__main__':
    main()
