import threading
import time

def wordcount(text) :
    arr = text.upper().split(" ")
    wc = {}
    for word in arr :
        if word in wc.keys() :
            wc[word] = wc[word]+1
        else :
            wc[word] = 1
    print(wc)

str = "The quick brown fox jumped over the lazy dog."

start_time = time.perf_counter()
thread = threading.Thread(target=wordcount, args=(str, ))
thread.start()
thread.join()
finish_time = time.perf_counter()
print("Program finished in {} seconds - using multithreading".format(finish_time-start_time))
print("---")

start_time = time.perf_counter()
wordcount(str)
finish_time = time.perf_counter()
print("Program finished in {} seconds - using direct calls".format(finish_time-start_time))
print("---")

str = open("transcript.txt","r").read()
start_time = time.perf_counter()
thread = threading.Thread(target=wordcount, args=(str, ))
thread.start()
thread.join()
finish_time = time.perf_counter()
print("Program finished in {} seconds - using multithreading".format(finish_time-start_time))
print("---")