from langserve import RemoteRunnable
from langchain_core.messages import SystemMessage, AIMessage, HumanMessage
from langchain_community.chat_message_histories import ChatMessageHistory
from pytube import YouTube 

def get_yt_description(url):
    """
    Copied from https://github.com/pytube/pytube/issues/1626#issuecomment-1775501965
    """
    yt = YouTube(url)
    for n in range(6):
        try:
            description =  yt.initial_data["engagementPanels"][n]["engagementPanelSectionListRenderer"]["content"]["structuredDescriptionContentRenderer"]["items"][1]["expandableVideoDescriptionBodyRenderer"]["attributedDescriptionBodyText"]["content"]            
            return description
        except:
            continue
    return False

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
    message_list = [parse_message_tuple(msg) for msg in tuples]
    
    chat_history = ChatMessageHistory()
    chat_history.add_messages(message_list)
    
    return chat_history.messages
  
def parse_message_tuple(message_tuple):
    role = message_tuple[0]
    content = message_tuple[1]
    if role == "system":
        msg = SystemMessage(content)
    elif role == "human":
        msg = parse_human_message(content)
    elif role == "ai":
        msg = AIMessage(content)
        
    return msg

def parse_human_message(text):
    """
    text could contain an image endcoded as a bytestring. In which case it should follow the following model:

message = HumanMessage(
    content=[
        {"type": "text", "text": "describe the weather in this image"},
        {
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{image_data}"},
        },
    ],
)

This bytestring can always be recognized as being contained within the following delimiters:
  <<image_begin>>
  <<image_end>>
  
    """
    if "<<image_begin>>" in text:
        text = text.split("<<image_begin>>")
        text0 = text[0]
        text1 = text[1].split("<<image_end>>")
        
        image_data = text1[0]
        keep_text = text0 + text1[1]
        message = HumanMessage(
            content=[
                {"type": "text", "text": keep_text},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{image_data}"},
                },
            ],
        )
    else:
        message = HumanMessage(content=text)
    
    return message

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
