# First go at larkdown.py
from langserve import RemoteRunnable
from langchain.memory import ChatMessageHistory
from langchain_core.messages import SystemMessage

def parse_larkdown(text):
    lines = text.split('\n')
    tuples = []
    current_speaker = None
    current_message = []
    ignore_block = False

    for line in lines:
        if line.startswith('<!-- ignore -->'):
            ignore_block = True
        elif line.startswith('<!-- endignore -->'):
            ignore_block = False
        elif ignore_block:
            continue
        elif line.startswith('>'):
            if current_speaker:
                tuples.append((current_speaker, '\n'.join(current_message)))
            current_speaker = line[1:].strip()
            current_message = []
        else:
            current_message.append(line)

    # Don't forget to add the last speaker and message
    if current_speaker and current_message:
        tuples.append((current_speaker, '\n'.join(current_message)))

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
