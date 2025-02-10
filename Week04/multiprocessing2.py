from random import random
from time import sleep
from multiprocessing import Queue
from multiprocessing import Process
 
# function to execute in a child process
def task(queue):
    # generate some data
    data = random()
    # block, to simulate computational effort
    print(f'Generated {data}', flush=True)
    sleep(data)
    # return data via queue
    queue.put(data)

def wordcount(text, queue, debug=True) :
#def wordcount(queue) :
    arr = text.upper().split(" ")
    wc = {}
    for word in arr :
        if word in wc.keys() :
            wc[word] = wc[word]+1
        else :
            wc[word] = 1
            if debug :
                print(word)
    queue.put(wc)
    #queue.put(5)

 
# protect the entry point
if __name__ == '__main__':
    # create the queue
    queue = Queue()
    # create a child process process
    process = Process(target=task, args=(queue,))
    # start the process
    process.start()
    # wait for the return value
    value = queue.get()
    # report return value
    print(f'Returned: {value}')
    
    str = "The quick brown fox jumped over the lazy dog."
    process = Process(target=wordcount, args=(str, queue,))
    # start the process
    process.start()
    # wait for the return value
    value = queue.get()
    # report return value
    print(f'Returned: {value}')

    str = open("transcript.txt","r").read()
    process = Process(target=wordcount, args=(str, queue, False))
    # start the process
    process.start()
    # wait for the return value
    value = queue.get()

    top_20_items = sorted(value.items(), key=lambda item: item[1], reverse=True)[:20]


    # report return value
    print(f'Top 20: {top_20_items}')