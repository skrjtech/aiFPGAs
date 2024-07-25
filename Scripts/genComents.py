#!/bin/python

import sys

def main():
    
    totaly_size = 125
    space = '    '
    space_size = len(space)
    
    while True:
        try:
            
            inp = str(input('Comment string: '))
            inp_size = len(inp)
            total = inp_size + space        
            
        except KeyboardInterrupt() as e:
            print("Ctrl + C!")
            break
    
if __name__ == "__main__":
    main()