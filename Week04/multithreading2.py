import threading
import time
import concurrent.futures
import os

def worker():
    print("Worker Assigned to thread: {}".format(threading.current_thread().name))
    print("Worker thread running")





print("Main thread continuing to run")

def wordcount(text) :
    print("Assigned to thread: {} - {}".format(threading.current_thread().name, text))
    arr = text.upper().split(" ")
    wc = {}
    for word in arr :
        if word in wc.keys() :
            wc[word] = wc[word]+1
        else :
            wc[word] = 1
    return wc


start_time = time.perf_counter()
thread_pool = concurrent.futures.ThreadPoolExecutor(max_workers=2)
thread_pool.submit(worker)
thread_pool.submit(worker)
thread_pool.shutdown(wait=True)
finish_time = time.perf_counter()
print("Worker Program finished in {} seconds".format(finish_time-start_time))
print("---")

start_time = time.perf_counter()
thread_pool = concurrent.futures.ThreadPoolExecutor(max_workers=2)
str = "The quick brown fox jumped over the lazy dog."
future = thread_pool.submit(wordcount, str)
print(future.result())
thread_pool.shutdown(wait=True)
finish_time = time.perf_counter()
print("Result from Pool Program finished in {} seconds".format(finish_time-start_time))
print("---")

wc = {}    
str1 = "The quick brown fox jumped over the lazy dog."
str2 = "Sally sells sea shells by the sea shore."
str3 = "How much wood would a woodchuck chuck if a woodchuck could chuck wood?"
str4 = "Roberta ran rings around the Roman ruins"
str5 = "The sixth sick sheik's sixth sheep's sick"
str6 = "Four furious friends fought for the phone"
str7 = "Fuzzy Wuzzy was a bear. Fuzzy Wuzzy had no hair. Fuzzy Wuzzy wasn't very fuzzy, was he?"
str8 = "Which witch switched the Swiss wristwatches"
str9 = "I scream, you scream, we all scream for ice cream"
str10 = "Peter Piper picked a peck of pickled peppers"
str11 = "A big black bug bit a big black bear."
str12 = "Betty Botter bought some butter, but she said the butter's bitter. If I put it in my batter, it will make my batter bitter."
str13 = "How many cans can a canner can if a canner can can cans? A canner can can as many cans as a canner can, if a canner can can cans."
str14 = "I thought a thought, but the thought I thought wasn't the thought I thought I thought."
str15 = "If practice makes perfect and perfect needs practice, I’m perfectly practiced and practically perfect."

with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
    futures = [executor.submit(wordcount, str) for str in [str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15]]
    
    results = [future.result() for future in concurrent.futures.as_completed(futures)]
 

for result in results :
    for key in result.keys() : 
        if key in wc.keys() :
            wc[key] = wc[key] + result[key]
        else :
            wc[key] = result[key]
print(wc)

print("---")