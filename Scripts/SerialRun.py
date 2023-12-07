import time
import serial

def recv():
    device = serial.Serial("COM4", 9600)
    while True:
        try:
            print(f"Recv: {device.read_all()}")
            time.sleep(1)
        except KeyboardInterrupt:
            break

def main():
    device = serial.Serial("COM4", 9600)

    count = 0
    while True:
        try:
            string_enc = str(count)
            rest = device.write(string_enc.encode())
            print(f"Send: {string_enc} | result: {rest}")
            time.sleep(1)
            count += 1
        except KeyboardInterrupt:
            break

def interactive():
    device = serial.Serial("COM4", 9600)

    interactive_string = None
    while True:
        try:
            interactive_string = str(input("Char Send: "))
            rest = device.write(interactive_string.encode())
            print(f"Send: {interactive_string} | result: {rest} | recv: {device.read_all()}")
        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    interactive()