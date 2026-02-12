import socket
import select
try:
    import win32file
    import win32pipe
except ImportError:
    win32file = None
    win32pipe = None
    CONNECTIONS = set()

import time
import websockets
import asyncio
import threading

from . import config


async def register(websocket):
	CONNECTIONS.add(websocket)
	try:
		await websocket.wait_closed()
	finally:
		CONNECTIONS.remove(websocket)

def websocket_func():
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    ws_server = websockets.serve(register, 'localhost', 5678)

    loop.run_until_complete(ws_server)
    loop.run_forever()
    loop.close()

# Connect to LiveSplit and return socket
def connect() -> object:
    # Get connection type from config
    ls_connection_type = config.get("connection", "ls_connection_type")

    # Check if connection type is named pipe (0 indicates named pipe)
    if ls_connection_type == 0:
        if win32file is None:
            return False
            
        # Get named pipe host from config. Name is always LiveSplit
        ls_pipe_path = "\\\\" + config.get("connection", "ls_pipe_host") + "\\pipe\\LiveSplit"
        try:
            # Connect to named pipe
            ls_socket = win32file.CreateFile(ls_pipe_path, win32file.GENERIC_READ | win32file.GENERIC_WRITE, 0, None, win32file.OPEN_EXISTING, 0, None )
            # Set the pipe to byte mode
            win32pipe.SetNamedPipeHandleState(ls_socket, win32pipe.PIPE_READMODE_BYTE, None, None)
            return ls_socket
        except:
            return False
    # Check if connection type is TCP (1 indicates TCP)
    elif ls_connection_type == 1:
        try:
            # Initialize socket
            ls_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            # Get host and port from config and connect to host via TCP
            ls_socket.connect((config.get("connection", "ls_host"), config.get("connection", "ls_port")))
            return ls_socket
        except:
            try:
                # Initialise websocket
                server = threading.Thread(target=websocket_func, daemon=True)
                server.start()
            finally:
                return "websocket"
            
    else:
        return False


def disconnect(ls_socket) -> None:
    # Check if connection even exists
    if ls_socket is False:
        return
    try:
        ls_socket.close()
    except:
        # for websocket
        return


def check_connection(ls_socket) -> bool:
    try:
        if ls_socket == "websocket":
            return True
        # Check if connection has been established
        if (ls_socket == False):
            return False
        # Check if communication is possible and response is received
        if split_index(ls_socket) is False:
            return False
        else:
            return True
    except:
        return False


def send(ls_socket, command) -> None:
    # Check if connection type is pipe or socket
    # If it is a socket:
    if isinstance(ls_socket, socket.socket):
        # Send the command to the socket
        ls_socket.send(command.encode('utf-8'))
    # If it is a pipe:
    else:
        if ls_socket == "websocket":
            websockets.broadcast(CONNECTIONS, '{"command": "' + command + '"}')
        if win32file is None:
            return

        # Send the command to the pipe
        try:
            win32file.WriteFile(ls_socket, command.encode('utf-8'))
        except:
            raise Exception("LiveSplit connection lost")

def split(ls_socket) -> None:
    send(ls_socket, "splitOrStart" if ls_socket == "websocket" else "startorsplit\r\n")
    # send(ls_socket, "startorsplit\r\n")


def reset(ls_socket) -> None:
    send(ls_socket, "reset" if ls_socket == "websocket" else "reset\r\n")

def restart(ls_socket) -> None:
    send(ls_socket, "reset" if ls_socket == "websocket" else "reset\r\nstarttimer\r\n")
    if ls_socket == "websocket":
        send(ls_socket, "splitOrStart")

def skip(ls_socket) -> None:
    send(ls_socket, "skipSplit" if ls_socket == "websocket" else "skipsplit\r\n")


def undo(ls_socket) -> None:
    send(ls_socket, "undoSplit" if ls_socket == "websocket" else "unsplit\r\n")


def split_index(ls_socket):
    # Check if connection type is pipe or socket
    # If it is a socket:
    if isinstance(ls_socket, socket.socket):
        # Send the command to the socket
        try:
            ls_socket.send("getsplitindex\r\n".encode('utf-8'))
        except:
            return False
        
        # Wait for response
        readable = select.select([ls_socket], [], [], 0.5)
        if readable[0]:
            try:
                data = (ls_socket.recv(1000)).decode("utf-8")
                if not isinstance(data, bool):
                    return int(data)
                else:
                    return False
            except:
                return False
        else:
            return False
    # If it is a pipe:
    else:
        if win32file is None or win32pipe is None:
            return False

        # Send the command to the pipe
        try:
            win32file.WriteFile(ls_socket, "getsplitindex\r\n".encode('utf-8'))
        except:
            return False
        # Get current time
        start_time = time.time()
        # Set timeout to 0.5 seconds
        timeout = 0.5
        # Read from pipe until success or timeout
        while True:
            # Check if the timeout has occurred
            if time.time() - start_time > timeout:
                return False
            # Peek at the pipe to see if there is data as it is non-blocking
            try:
                peek_data, available , _ = win32pipe.PeekNamedPipe(ls_socket, 1000)
            except:
                raise Exception("LiveSplit connection lost")
            # If there is data available:
            if available > 0:
                # Read the data from the pipe
                data = win32file.ReadFile(ls_socket, 1000)[1].decode("utf-8")
                if not isinstance(data, bool):
                    return int(data)
                else:
                    return False